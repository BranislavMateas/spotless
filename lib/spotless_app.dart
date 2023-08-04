import 'package:flutter/material.dart';
import 'package:spotless/pages/home_page.dart';
import 'package:spotless/pages/login_page.dart';
import 'package:spotless/pages/track_list_page.dart';

class SpotlessApp extends StatelessWidget {
  const SpotlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        LoginPage.pageRoute: (context) => LoginPage(),
        HomePage.pageRoute: (context) => HomePage(),
        TrackListPage.pageRoute: (context) => TrackListPage(),
      },
      debugShowCheckedModeBanner: false,
      initialRoute: LoginPage.pageRoute,
      title: 'Spotless',
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
