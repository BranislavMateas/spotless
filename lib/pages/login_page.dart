import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotless/pages/track_list_page.dart';
import 'package:spotless/providers/access_token_provider.dart';
import 'package:spotless/providers/fetched_tracks_provider.dart';
import 'package:spotless/providers/playlist_id_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static String pageRoute = "/login";

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController playlistUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
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

                // TODO check for input text
                var playlistId = Uri.parse(playlistUrlController.value.text)
                    .pathSegments
                    .last;

                ref.read(accessTokenProvider.notifier).state = accessToken;
                ref.read(playlistIdProvider.notifier).state = playlistId;

                await ref
                    .read(fetchedTracksProvider.notifier)
                    .fetchFromPlaylistId(
                      playlistId: playlistId,
                      accessToken: accessToken,
                    );

                if (mounted) {
                  Navigator.pushNamed(context, TrackListPage.pageRoute);
                }
              },
              child: const Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
