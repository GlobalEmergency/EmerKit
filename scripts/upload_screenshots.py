#!/usr/bin/env python3
"""Upload screenshots to App Store Connect (default listing + Custom Product Pages).

Usage:
    python scripts/upload_screenshots.py --default          # Upload default listing only
    python scripts/upload_screenshots.py --cpps-ipad        # Upload iPad to 7 CPPs
    python scripts/upload_screenshots.py --all              # Everything
"""
import jwt, time, json, urllib.request, urllib.error, ssl, os, sys, hashlib, struct

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
SCREENSHOTS_DIR = os.path.join(PROJECT_DIR, "screenshots", "custom_pages")

# --- Auth ---
with open(os.path.join(PROJECT_DIR, "android/app/signing/AuthKey_Z68N6TKGK9.p8"), "r") as f:
    private_key = f.read()

now = int(time.time())
token = jwt.encode(
    {"iss": "90591e44-9746-48f0-b603-f19bf8d517aa", "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
    private_key, algorithm="ES256",
    headers={"alg": "ES256", "kid": "Z68N6TKGK9", "typ": "JWT"}
)
ctx = ssl.create_default_context()

BASE = "https://api.appstoreconnect.apple.com/v1"

# --- API helpers ---
def api(method, url, data=None, raw_response=False):
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method, headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    })
    try:
        resp = urllib.request.urlopen(req, context=ctx)
        if raw_response:
            return resp
        content = resp.read()
        return json.loads(content) if content else {"ok": True}
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print(f"  ERROR {e.code}: {err[:500]}")
        return None

def upload_binary(url, headers_list, data):
    """Upload binary data with custom headers."""
    req = urllib.request.Request(url, data=data, method="PUT")
    for h in headers_list:
        req.add_header(h["name"], h["value"])
    try:
        resp = urllib.request.urlopen(req, context=ctx)
        return True
    except urllib.error.HTTPError as e:
        print(f"  UPLOAD ERROR {e.code}: {e.read().decode()[:300]}")
        return False

def md5_checksum(filepath):
    """Compute MD5 checksum of a file."""
    h = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

# --- Display type mapping ---
DISPLAY_TYPES = {
    "iPhones 6.9": "APP_IPHONE_67",
    "iPad 13": "APP_IPAD_PRO_3GEN_129",  # 2048x2732; may need APP_IPAD_PRO_13 for M4
}

# --- IDs ---
VERSION_ID = "9dd411d6-1774-44d2-898c-8166703d6621"  # v0.1.6

# Default listing localization IDs (v0.1.6)
DEFAULT_LOCS = {
    "es-ES": "6f355b84-07d1-4023-a44c-821da3716a5b",
    "en-US": "5235084c-fe48-4f86-a6e3-617d1922704c",
}

# CPP localization IDs
CPP_LOCS = {
    "TES": {
        "es-ES": "7472e75b-c42e-4076-899b-d4597a925c7a",
        "en-US": "2adac759-5a7f-4724-99ca-5341c2a69b0d",
    },
    "Paramedicos": {
        "es-ES": "a0893b47-55c6-4409-9b8e-62b4b461e748",
        "en-US": "4b56d4fa-3ba4-4ab3-a308-27fb24c5d78d",
    },
    "Enfermeria": {
        "es-ES": "d61d37bf-a3d8-4d6d-a2b4-79e88a5bc58a",
        "en-US": "543f0667-3131-4cf6-883f-e5b6ae2bcd8a",
    },
    "Medicos": {
        "es-ES": "a28d6834-66e3-40f5-aa09-525cd8f73164",
        "en-US": "63402458-eef1-4844-98b7-9dc9c9e5faad",
    },
    "RCP y Soporte Vital": {
        "es-ES": "b6b067d7-6b85-4553-9a99-c7e8c5101b72",
        "en-US": "eb688301-57c3-48e7-9ea0-967d2a0a6dc2",
    },
    "Escalas Clinicas": {
        "es-ES": "659962de-90df-429c-a4f5-c3b667d1c6b5",
        "en-US": "ea2b61a7-312d-4929-b59a-5cac4c2122a2",
    },
    "Triage y Emergencias": {
        "es-ES": "911375d1-1d2e-4cab-8f85-725000f1bf65",
        "en-US": "ff4c177d-4792-4356-b2fd-267ad8dbe888",
    },
}

# --- Screenshot operations ---

def get_screenshot_sets(localization_id, loc_type="appStoreVersionLocalizations"):
    """Get existing screenshot sets for a localization."""
    url = f"{BASE}/{loc_type}/{localization_id}/appScreenshotSets"
    result = api("GET", url)
    if result and "data" in result:
        return result["data"]
    return []

def get_screenshots_in_set(set_id):
    """Get screenshots in a screenshot set."""
    url = f"{BASE}/appScreenshotSets/{set_id}/appScreenshots"
    result = api("GET", url)
    if result and "data" in result:
        return result["data"]
    return []

def delete_screenshot(screenshot_id):
    """Delete a single screenshot."""
    return api("DELETE", f"{BASE}/appScreenshots/{screenshot_id}")

def create_screenshot_set(localization_id, display_type, loc_type="appStoreVersionLocalizations"):
    """Create a new screenshot set."""
    result = api("POST", f"{BASE}/appScreenshotSets", {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {
                "screenshotDisplayType": display_type
            },
            "relationships": {
                loc_type.rstrip("s"): {  # singular form
                    "data": {
                        "type": loc_type,
                        "id": localization_id
                    }
                }
            }
        }
    })
    if result and "data" in result:
        return result["data"]["id"]
    return None

def upload_screenshot(set_id, filepath):
    """Upload a single screenshot: reserve -> upload binary -> commit."""
    filename = os.path.basename(filepath)
    filesize = os.path.getsize(filepath)
    checksum = md5_checksum(filepath)

    # 1. Reserve
    reserve = api("POST", f"{BASE}/appScreenshots", {
        "data": {
            "type": "appScreenshots",
            "attributes": {
                "fileName": filename,
                "fileSize": filesize
            },
            "relationships": {
                "appScreenshotSet": {
                    "data": {"type": "appScreenshotSets", "id": set_id}
                }
            }
        }
    })
    if not reserve or "data" not in reserve:
        print(f"    FAILED to reserve {filename}")
        return False

    ss_id = reserve["data"]["id"]
    upload_ops = reserve["data"]["attributes"].get("uploadOperations", [])

    # 2. Upload binary chunks
    with open(filepath, "rb") as f:
        file_data = f.read()

    for op in upload_ops:
        offset = op["offset"]
        length = op["length"]
        chunk = file_data[offset:offset + length]
        ok = upload_binary(op["url"], op["requestHeaders"], chunk)
        if not ok:
            print(f"    FAILED to upload chunk for {filename}")
            return False

    # 3. Commit
    commit = api("PATCH", f"{BASE}/appScreenshots/{ss_id}", {
        "data": {
            "type": "appScreenshots",
            "id": ss_id,
            "attributes": {
                "uploaded": True,
                "sourceFileChecksum": checksum
            }
        }
    })
    if commit:
        return True
    print(f"    FAILED to commit {filename}")
    return False

def get_or_create_set(localization_id, display_type, loc_type="appStoreVersionLocalizations"):
    """Find existing screenshot set or create a new one."""
    sets = get_screenshot_sets(localization_id, loc_type)
    for s in sets:
        if s["attributes"]["screenshotDisplayType"] == display_type:
            return s["id"]
    # Create new
    return create_screenshot_set(localization_id, display_type, loc_type)

def upload_screenshots_for_loc(localization_id, page_name, lang, device_folder, display_type,
                                loc_type="appStoreVersionLocalizations", delete_existing=False):
    """Upload 5 screenshots for a given localization + device."""
    print(f"\n  [{page_name}] {lang} / {device_folder}")

    # Get or create screenshot set
    set_id = get_or_create_set(localization_id, display_type, loc_type)
    if not set_id:
        print(f"    FAILED to get/create screenshot set")
        return 0

    # Delete existing if requested
    if delete_existing:
        existing = get_screenshots_in_set(set_id)
        if existing:
            print(f"    Deleting {len(existing)} existing screenshots...")
            for ss in existing:
                delete_screenshot(ss["id"])
            time.sleep(1)  # Brief pause after deletions

    # Upload new screenshots
    screenshot_dir = os.path.join(SCREENSHOTS_DIR, page_name, lang, "apple", device_folder)
    if not os.path.isdir(screenshot_dir):
        print(f"    Directory not found: {screenshot_dir}")
        return 0

    count = 0
    for i in range(1, 6):
        filepath = os.path.join(screenshot_dir, f"{i:02d}.png")
        if not os.path.exists(filepath):
            print(f"    {i:02d}.png not found, skipping")
            continue
        print(f"    Uploading {i:02d}.png...", end=" ", flush=True)
        if upload_screenshot(set_id, filepath):
            print("OK")
            count += 1
        else:
            print("FAILED")
    return count

# --- Main operations ---

def upload_default_listing():
    """Upload screenshots to the default listing (iPhone + iPad, ES + EN)."""
    print("=" * 60)
    print("UPLOADING DEFAULT LISTING SCREENSHOTS")
    print("=" * 60)
    total = 0

    for lang, loc_id in DEFAULT_LOCS.items():
        for device_folder, display_type in DISPLAY_TYPES.items():
            # For a fresh version, no need to delete
            delete = False
            count = upload_screenshots_for_loc(
                loc_id, "default", lang, device_folder, display_type,
                loc_type="appStoreVersionLocalizations",
                delete_existing=delete
            )
            total += count

    print(f"\nDefault listing: {total}/20 screenshots uploaded")
    return total

def upload_cpps_ipad():
    """Upload iPad screenshots to all 7 CPPs."""
    print("=" * 60)
    print("UPLOADING iPAD SCREENSHOTS TO 7 CPPs")
    print("=" * 60)
    total = 0
    device_folder = "iPad 13"
    display_type = DISPLAY_TYPES[device_folder]

    for cpp_name, locs in CPP_LOCS.items():
        for lang, loc_id in locs.items():
            count = upload_screenshots_for_loc(
                loc_id, cpp_name, lang, device_folder, display_type,
                loc_type="appCustomProductPageLocalizations",
                delete_existing=False
            )
            total += count

    print(f"\nCPP iPad: {total}/70 screenshots uploaded")
    return total

# --- CLI ---
if __name__ == "__main__":
    args = sys.argv[1:]
    if not args:
        print("Usage: python scripts/upload_screenshots.py [--default] [--cpps-ipad] [--all]")
        sys.exit(1)

    if "--all" in args:
        args = ["--default", "--cpps-ipad"]

    results = {}
    if "--default" in args:
        results["default"] = upload_default_listing()
    if "--cpps-ipad" in args:
        results["cpps_ipad"] = upload_cpps_ipad()

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    for key, count in results.items():
        print(f"  {key}: {count} screenshots uploaded")
    print("Done!")
