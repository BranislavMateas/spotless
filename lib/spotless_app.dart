import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:spotless/pages/login_page.dart';
import 'package:spotless/pages/track_list_page.dart';

class SpotlessApp extends StatefulWidget {
  const SpotlessApp({super.key});

  @override
  State<SpotlessApp> createState() => _SpotlessAppState();
}

class _SpotlessAppState extends State<SpotlessApp> {
  final Color seedColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          routes: {
            LoginPage.pageRoute: (context) => LoginPage(),
            TrackListPage.pageRoute: (context) => TrackListPage(),
          },
          debugShowCheckedModeBanner: false,
          initialRoute: LoginPage.pageRoute,
          title: 'Spotless',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme ??
                ColorScheme.fromSeed(
                  seedColor: seedColor,
                  brightness: Brightness.light,
                ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme ??
                ColorScheme.fromSeed(
                  seedColor: seedColor,
                  brightness: Brightness.dark,
                ),
          ),
        );
      },
    );
  }
}
