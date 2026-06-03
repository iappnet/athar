import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadAppFonts();
  await testMain();
}

Future<void> _loadAppFonts() async {
  final calibri = FontLoader('Calibri')
    ..addFont(_bytes('assets/fonts/calibri-light.ttf'))
    ..addFont(_bytes('assets/fonts/calibri-regular.ttf'))
    ..addFont(_bytes('assets/fonts/calibri-bold.ttf'));
  await calibri.load();

  final cairo = FontLoader('Cairo')
    ..addFont(_bytes('assets/fonts/Cairo-Regular.ttf'))
    ..addFont(_bytes('assets/fonts/Cairo-Medium.ttf'))
    ..addFont(_bytes('assets/fonts/Cairo-SemiBold.ttf'))
    ..addFont(_bytes('assets/fonts/Cairo-Bold.ttf'));
  await cairo.load();

  final jbMono = FontLoader('JetBrains Mono')
    ..addFont(_bytes('assets/fonts/JetBrainsMono-Light.ttf'))
    ..addFont(_bytes('assets/fonts/JetBrainsMono-Regular.ttf'))
    ..addFont(_bytes('assets/fonts/JetBrainsMono-Medium.ttf'));
  await jbMono.load();
}

Future<ByteData> _bytes(String path) async {
  final raw = await File(path).readAsBytes();
  return ByteData.sublistView(raw);
}
