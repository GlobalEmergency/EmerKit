import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final udid = Platform.environment['CAPTURE_UDID'];
  final output = Platform.environment['CAPTURE_OUTPUT'];
  if (udid == null || output == null) {
    throw StateError('CAPTURE_UDID and CAPTURE_OUTPUT are required');
  }
  await Directory(output).create(recursive: true);
  final driver = await FlutterDriver.connect().timeout(
    const Duration(seconds: 90),
  );
  Process? recording;
  Future<void>? recordingComplete;

  Future<void> native(List<String> args) async {
    final result = await Process.run('xcrun', ['simctl', ...args]).timeout(
      const Duration(seconds: 30),
    );
    if (result.exitCode != 0) {
      throw StateError('simctl failed: ${result.stderr}');
    }
  }

  Future<void> capture(String name, String marker) async {
    stderr.writeln('Capture $name: waiting for $marker');
    await driver.waitFor(find.text(marker),
        timeout: const Duration(seconds: 30));
    await Future<void>.delayed(const Duration(milliseconds: 700));
    await native(['io', udid, 'screenshot', '$output/$name.png']);
    if (await File('$output/$name.png').length() < 10000) {
      throw StateError('Capture $name is empty');
    }
  }

  Future<void> openTool(String label, String title) async {
    await driver.tap(find.byType('TextField'),
        timeout: const Duration(seconds: 30));
    stderr.writeln('Open tool: $label');
    await driver.enterText(label, timeout: const Duration(seconds: 30));
    await driver.tap(
        find.descendant(
          of: find.byType('ToolCard'),
          matching: find.text(label),
        ),
        timeout: const Duration(seconds: 30));
    await driver.waitFor(find.text(title),
        timeout: const Duration(seconds: 30));
  }

  Future<void> home() async {
    stderr.writeln('Return to home');
    await driver.tap(find.pageBack(), timeout: const Duration(seconds: 30));
    await driver.waitFor(find.byType('TextField'),
        timeout: const Duration(seconds: 30));
    await driver.tap(find.byType('TextField'),
        timeout: const Duration(seconds: 30));
    await driver.enterText('', timeout: const Duration(seconds: 30));
  }

  try {
    await driver.waitFor(find.byType('TextField'),
        timeout: const Duration(seconds: 30));
    await capture('01-home', 'Buscar herramienta...');
    if (Platform.environment['CAPTURE_VIDEO'] == 'true') {
      recording = await Process.start('xcrun', [
        'simctl',
        'io',
        udid,
        'recordVideo',
        '--codec=h264',
        '$output/07-preview-raw.mov',
      ]);
      unawaited(recording.stdout.drain<void>());
      unawaited(recording.stderr.drain<void>());
      final process = recording;
      recordingComplete = () async {
        // Keep two seconds of margin before the final exact 20-second export.
        await Future<void>.delayed(const Duration(seconds: 22));
        process.kill(ProcessSignal.sigint);
        final exitCode = await process.exitCode;
        if (exitCode != 0) throw StateError('Simulator recording failed');
      }();
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    await openTool('Glasgow', 'Escala de Glasgow');
    await capture('02-glasgow', 'Escala de Glasgow');
    await Future<void>.delayed(const Duration(seconds: 2));
    await home();
    await openTool('RCP', 'RCP');
    await capture('03-rcp', 'RCP');
    await Future<void>.delayed(const Duration(seconds: 2));
    await home();
    await openTool('Triage START', 'Triage START');
    await capture('04-triage', 'Triage START');
    await home();
    await openTool('Electrodos ECG', 'Electrodos ECG');
    await capture('05-ecg', 'Electrodos ECG');
    await home();
    await driver.scrollUntilVisible(
      find.byType('ListView'),
      find.text('Vendajes'),
      dyScroll: -300,
      alignment: 0.35,
      timeout: const Duration(seconds: 30),
    );
    await capture('06-home-scroll', 'Vendajes');
    await recordingComplete;
  } finally {
    recording?.kill(ProcessSignal.sigint);
    await driver.close();
  }
}
