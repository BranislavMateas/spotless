import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotless/spotless_app.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  Loggy.initLoggy();
  runApp(const ProviderScope(child: SpotlessApp()));
}
