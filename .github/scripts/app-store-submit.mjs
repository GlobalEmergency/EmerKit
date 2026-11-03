#!/usr/bin/env node
/**
 * Submits an uploaded iOS build for App Store review through the App Store
 * Connect API. Node 24, no dependencies (fetch + node:crypto).
 * Adapted from sacadiez-app/.github/scripts/app-store-submit.mjs.
 *
 *   1. find the app by bundle id;
 *   2. wait until the build with this CFBundleVersion is processed (VALID);
 *   3. find or create the editable App Store version for the version string;
 *   4. attach the build;
 *   5. set "What's New" on every localization from WHATSNEW_DIR/<locale>.txt
 *      (Apple requires it on updates);
 *   6. add the version to a review submission (reusing an open one) and submit it.
 *
 * Idempotent: a version already waiting for or in review, or live, is left alone.
 *
 * Environment:
 *   APP_STORE_CONNECT_KEY_ID, APP_STORE_CONNECT_ISSUER_ID,
 *   APP_STORE_CONNECT_API_KEY (the .p8 PEM)       credentials
 *   BUNDLE_ID              online.globalemergency.emerkit
 *   APP_VERSION            0.1.20 (CFBundleShortVersionString)
 *   BUILD_NUMBER           120 (CFBundleVersion)
 *   WHATSNEW_DIR           folder with <locale>.txt release notes
 *   BUILD_TIMEOUT_MINUTES  optional, default 45
 *
 * Logs progress and Apple's error details, never the credentials.
 */
import { createPrivateKey, sign } from 'node:crypto';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const API = 'https://api.appstoreconnect.apple.com';
const EDITABLE_STATES = new Set([
  'PREPARE_FOR_SUBMISSION',
  'DEVELOPER_REJECTED',
  'REJECTED',
  'METADATA_REJECTED',
  'INVALID_BINARY',
]);
const ALREADY_SUBMITTED_STATES = new Set([
  'WAITING_FOR_REVIEW',
  'IN_REVIEW',
  'PENDING_DEVELOPER_RELEASE',
  'PENDING_APPLE_RELEASE',
  'PROCESSING_FOR_APP_STORE',
  'READY_FOR_SALE',
  'READY_FOR_DISTRIBUTION',
  'ACCEPTED',
]);
const OPEN_SUBMISSION_STATES = ['READY_FOR_REVIEW', 'UNRESOLVED_ISSUES'];
const IN_FLIGHT_SUBMISSION_STATES = ['WAITING_FOR_REVIEW', 'IN_REVIEW'];

const env = (name, fallback) => {
  const value = process.env[name] ?? fallback;
  if (value === undefined || value === '') fail(`${name} is not set`);
  return value;
};

const keyId = env('APP_STORE_CONNECT_KEY_ID');
const issuerId = env('APP_STORE_CONNECT_ISSUER_ID');
const privateKey = createPrivateKey(env('APP_STORE_CONNECT_API_KEY'));
const bundleId = env('BUNDLE_ID');
const versionString = env('APP_VERSION');
const buildNumber = env('BUILD_NUMBER');
const whatsNewDir = env('WHATSNEW_DIR');
const timeoutMinutes = Number(env('BUILD_TIMEOUT_MINUTES', '45'));

// ---------------------------------------------------------------- API client

let cachedToken = { value: '', expiresAt: 0 };

function token() {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken.expiresAt - now > 60) return cachedToken.value;
  const b64 = (obj) => Buffer.from(JSON.stringify(obj)).toString('base64url');
  const exp = now + 15 * 60; // Apple caps tokens at 20 minutes
  const unsigned = `${b64({ alg: 'ES256', kid: keyId, typ: 'JWT' })}.${b64({ iss: issuerId, iat: now, exp, aud: 'appstoreconnect-v1' })}`;
  const signature = sign('sha256', Buffer.from(unsigned), {
    key: privateKey,
    dsaEncoding: 'ieee-p1363',
  });
  cachedToken = {
    value: `${unsigned}.${signature.toString('base64url')}`,
    expiresAt: exp,
  };
  return cachedToken.value;
}

class AppleApiError extends Error {
  constructor(method, path, status, errors) {
    const lines = [];
    for (const e of errors ?? []) {
      lines.push(`  - [${e.code ?? e.status}] ${e.title ?? ''}: ${e.detail ?? ''}`);
      // Submission blockers (e.g. unanswered age rating questions) come here.
      for (const a of e.meta?.associatedErrors
        ? Object.values(e.meta.associatedErrors).flat()
        : []) {
        lines.push(`      · [${a.code ?? ''}] ${a.detail ?? a.title ?? ''}`);
      }
    }
    super(`${method} ${path} -> HTTP ${status}${lines.length ? `\n${lines.join('\n')}` : ''}`);
    this.status = status;
  }
}

async function api(method, path, body) {
  for (let attempt = 1; ; attempt++) {
    const res = await fetch(`${API}${path}`, {
      method,
      headers: {
        Authorization: `Bearer ${token()}`,
        'Content-Type': 'application/json',
      },
      body: body ? JSON.stringify(body) : undefined,
    });
    if (res.status === 204) return undefined;
    const text = await res.text();
    const json = text ? JSON.parse(text) : undefined;
    if (res.ok) return json;
    // Rate limits and transient server errors: retry a few times.
    if ((res.status === 429 || res.status >= 500) && attempt < 4) {
      log(`  ${method} ${path} -> HTTP ${res.status}, retrying (${attempt}/3)`);
      await sleep(attempt * 10_000);
      continue;
    }
    throw new AppleApiError(method, path, res.status, json?.errors);
  }
}

const rel = (type, id) => ({ data: { type, id } });

// ---------------------------------------------------------------- steps

async function findApp() {
  const res = await api(
    'GET',
    `/v1/apps?filter[bundleId]=${encodeURIComponent(bundleId)}&limit=1`,
  );
  const app = res.data?.[0];
  if (!app) fail(`No app with bundle id "${bundleId}" in App Store Connect.`);
  log(`App: ${app.attributes.name} (${app.id})`);
  return app;
}

async function waitForBuild(appId) {
  const deadline = Date.now() + timeoutMinutes * 60_000;
  const query =
    `/v1/builds?filter[app]=${appId}&filter[version]=${encodeURIComponent(buildNumber)}` +
    `&filter[preReleaseVersion.version]=${encodeURIComponent(versionString)}&limit=1`;
  let lastState = '';
  for (;;) {
    const build = (await api('GET', query)).data?.[0];
    const state = build ? build.attributes.processingState : 'NOT_YET_VISIBLE';
    if (state !== lastState) {
      log(`Build ${versionString} (${buildNumber}): ${state}`);
      lastState = state;
    }
    if (state === 'VALID') return build;
    if (state === 'FAILED' || state === 'INVALID') {
      fail(
        `Build ${buildNumber} is ${state} in App Store Connect: check the email Apple sent about it.`,
      );
    }
    if (Date.now() > deadline) {
      fail(
        `Build ${buildNumber} not processed after ${timeoutMinutes} min (last state ${state}).\n` +
          '  The upload is done: once Apple finishes processing, re-run only the failed "Submit to App Review" job.',
      );
    }
    await sleep(30_000);
  }
}

async function ensureExportCompliance(build) {
  // Info.plist declares ITSAppUsesNonExemptEncryption = false, which normally
  // answers this. Fallback for a build where Apple still asks.
  if (build.attributes.usesNonExemptEncryption == null) {
    await api('PATCH', `/v1/builds/${build.id}`, {
      data: {
        type: 'builds',
        id: build.id,
        attributes: { usesNonExemptEncryption: false },
      },
    });
    log('Export compliance: declared no non-exempt encryption');
  }
}

const stateOf = (v) =>
  v.attributes.appVersionState ?? v.attributes.appStoreState;

/** Returns the version to submit, or undefined if this version is already submitted or live. */
async function findOrCreateVersion(appId) {
  const versions =
    (
      await api(
        'GET',
        `/v1/apps/${appId}/appStoreVersions?filter[platform]=IOS&limit=200`,
      )
    ).data ?? [];
  const same = versions.find(
    (v) => v.attributes.versionString === versionString,
  );
  if (same) {
    const state = stateOf(same);
    if (EDITABLE_STATES.has(state)) {
      log(`App Store version ${versionString}: exists (${state})`);
      return same;
    }
    if (ALREADY_SUBMITTED_STATES.has(state)) {
      log(
        `App Store version ${versionString} is already ${state}: nothing to submit.`,
      );
      return undefined;
    }
    fail(
      `App Store version ${versionString} is in state ${state}, which cannot be edited or submitted.`,
    );
  }

  // Only one version can be editable at a time: reuse it under the new number.
  const editable = versions.find((v) => EDITABLE_STATES.has(stateOf(v)));
  if (editable) {
    log(
      `App Store version: renaming editable "${editable.attributes.versionString}" (${stateOf(editable)}) to ${versionString}`,
    );
    const res = await api('PATCH', `/v1/appStoreVersions/${editable.id}`, {
      data: {
        type: 'appStoreVersions',
        id: editable.id,
        attributes: { versionString },
      },
    });
    return res.data;
  }

  log(`App Store version ${versionString}: creating`);
  const res = await api('POST', '/v1/appStoreVersions', {
    data: {
      type: 'appStoreVersions',
      attributes: {
        platform: 'IOS',
        versionString,
        releaseType: 'AFTER_APPROVAL',
      },
      relationships: { app: rel('apps', appId) },
    },
  });
  return res.data;
}

async function attachBuild(version, build) {
  await api(
    'PATCH',
    `/v1/appStoreVersions/${version.id}/relationships/build`,
    rel('builds', build.id),
  );
  log(`Build ${buildNumber} attached to version ${versionString}`);
}

async function setWhatsNew(version) {
  const localizations =
    (
      await api(
        'GET',
        `/v1/appStoreVersions/${version.id}/appStoreVersionLocalizations?limit=50`,
      )
    ).data ?? [];
  for (const l of localizations) {
    const { locale } = l.attributes;
    const file = join(whatsNewDir, `${locale}.txt`);
    if (!existsSync(file)) {
      fail(`No release notes for ${locale}: add ${file} (Apple requires "What's New" on updates).`);
    }
    await api('PATCH', `/v1/appStoreVersionLocalizations/${l.id}`, {
      data: {
        type: 'appStoreVersionLocalizations',
        id: l.id,
        attributes: { whatsNew: readFileSync(file, 'utf8').trim() },
      },
    });
    log(`What's New (${locale}): set`);
  }
}

async function submitForReview(appId, version) {
  const list = async (states) =>
    (
      await api(
        'GET',
        `/v1/reviewSubmissions?filter[app]=${appId}&filter[platform]=IOS&filter[state]=${states.join(',')}&limit=50`,
      )
    ).data ?? [];

  for (const submission of await list(IN_FLIGHT_SUBMISSION_STATES)) {
    if (await submissionHasVersion(submission.id, version.id)) {
      log(
        `Version ${versionString} is already in review submission ${submission.id} (${submission.attributes.state}).`,
      );
      return;
    }
  }

  let submission = (await list(OPEN_SUBMISSION_STATES))[0];
  if (submission) {
    log(
      `Review submission: reusing ${submission.id} (${submission.attributes.state})`,
    );
  } else {
    submission = (
      await api('POST', '/v1/reviewSubmissions', {
        data: {
          type: 'reviewSubmissions',
          attributes: { platform: 'IOS' },
          relationships: { app: rel('apps', appId) },
        },
      })
    ).data;
    log(`Review submission: created ${submission.id}`);
  }

  if (await submissionHasVersion(submission.id, version.id)) {
    log(`Review submission already contains version ${versionString}`);
  } else {
    await api('POST', '/v1/reviewSubmissionItems', {
      data: {
        type: 'reviewSubmissionItems',
        relationships: {
          reviewSubmission: rel('reviewSubmissions', submission.id),
          appStoreVersion: rel('appStoreVersions', version.id),
        },
      },
    });
    log(`Review submission: version ${versionString} added`);
  }

  await api('PATCH', `/v1/reviewSubmissions/${submission.id}`, {
    data: {
      type: 'reviewSubmissions',
      id: submission.id,
      attributes: { submitted: true },
    },
  });
  log(
    `Submitted version ${versionString} (build ${buildNumber}) for App Store review.`,
  );
}

async function submissionHasVersion(submissionId, versionId) {
  const items =
    (
      await api(
        'GET',
        `/v1/reviewSubmissions/${submissionId}/items?include=appStoreVersion&limit=50`,
      )
    ).data ?? [];
  return items.some(
    (item) => item.relationships?.appStoreVersion?.data?.id === versionId,
  );
}

// ---------------------------------------------------------------- main

function log(message) {
  console.log(message);
}

function fail(message) {
  console.error(`::error::${message.split('\n')[0]}`);
  console.error(message);
  process.exit(1);
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  log(
    `Submitting ${bundleId} ${versionString} (build ${buildNumber}) for App Store review`,
  );
  const app = await findApp();
  const build = await waitForBuild(app.id);
  await ensureExportCompliance(build);
  const version = await findOrCreateVersion(app.id);
  if (!version) return;
  await attachBuild(version, build);
  await setWhatsNew(version);
  await submitForReview(app.id, version);
}

main().catch((err) =>
  fail(err instanceof AppleApiError ? err.message : (err.stack ?? String(err))),
);
