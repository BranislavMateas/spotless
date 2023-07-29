import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotless/pages/home_page.dart';
import 'dart:math' as math;

import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static String pageRoute = "/login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String generateRandomString(length) {
    String text = '';
    String possible =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    for (int i = 0; i < length; i++) {
      text +=
          possible[(math.Random().nextDouble() * possible.length).truncate()];
    }
    return text;
  }

  String generateCodeChallenge(String codeVerifier) {
    List<int> data = utf8.encode(codeVerifier);
    Digest digest = sha256.convert(data);

    return base64Encode(digest.bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Column(
        children: [
          TextField(controller: usernameController),
          TextField(controller: passwordController),
          ElevatedButton(
            onPressed: () async {
              String verifier = generateRandomString(128);
              String challenge = generateCodeChallenge(verifier);

              String state = generateRandomString(16);
              String scope = 'user-read-private user-read-email';

              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setString('code_verifier', verifier);

              Uri targetUri = Uri(
                scheme: "https",
                host: "accounts.spotify.com",
                path: "authorize",
                queryParameters: {
                  "client_id": dotenv.env['CLIENT_ID'],
                  "response_type": 'code',
                  "redirect_uri": dotenv.env['REDIRECT_URI'],
                  "code_challenge_method": 'S256',
                  "scope": scope,
                  "state": state,
                  "code_challenge": challenge,
                },
              );

              if (await canLaunchUrl(targetUri)) {
                await launchUrl(
                  targetUri,
                  mode: LaunchMode.externalApplication,
                );
              }

              // Navigator.pushReplacementNamed(context, HomePage.pageRoute);
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }
}
