import 'package:flutter/material.dart';

class TrackListPage extends StatefulWidget {
  const TrackListPage({super.key});

  static String pageRoute = "/track-list";

  @override
  State<TrackListPage> createState() => _TrackListPageState();
}

class _TrackListPageState extends State<TrackListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // TODO create rest
          return Container();
        },
      ),
    );
  }
}
