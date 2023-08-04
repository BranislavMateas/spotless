import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotless/pages/home_page.dart';
import 'package:spotless/pages/track_list_page.dart';
import 'package:spotless/providers/fetched_tracks_provider.dart';
import 'dart:math' as math;

import 'package:url_launcher/url_launcher.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static String pageRoute = "/login";

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController playlistUrlController = TextEditingController();

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
      appBar: AppBar(),
      body: Column(
        children: [
          Text("Enter the Url of your playlist"),
          TextField(controller: playlistUrlController),
          ElevatedButton(
            onPressed: () async {
              String accessToken = await SpotifySdk.getAccessToken(
                clientId: dotenv.env['CLIENT_ID']!,
                redirectUrl: dotenv.env['REDIRECT_URI']!,
                scope: "playlist-read-private",
              );
              await SpotifySdk.connectToSpotifyRemote(
                clientId: dotenv.env['CLIENT_ID']!,
                redirectUrl: dotenv.env['REDIRECT_URI']!,
                accessToken: accessToken,
                scope: "playlist-read-private",
              );

              await ref
                  .read(fetchedTracksProvider.notifier)
                  .fetchFromUrl(
                      Uri.parse(
                          "https://api.spotify.com/v1/playlists/34I7rGMy6g2wH1p3Lu0zHW/tracks"),
                      accessToken)
                  .then((_) {
                return ref
                    .read(fetchedTracksProvider.notifier)
                    .getFetchedTracks();
              });

              /*
              // Request User Authorization
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
              */

              // Request an access token

              if (mounted)
                Navigator.pushReplacementNamed(
                    context, TrackListPage.pageRoute);
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }
}
