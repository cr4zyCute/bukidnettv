import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() {
  runApp(const BukidNetTVApp());
}

class BukidNetTVApp extends StatelessWidget {
  const BukidNetTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BukidNetTVScreen(),
    );
  }
}

class BukidNetTVScreen extends StatefulWidget {
  const BukidNetTVScreen({super.key});

  @override
  _BukidNetTVScreenState createState() => _BukidNetTVScreenState();
}

class _BukidNetTVScreenState extends State<BukidNetTVScreen> {
  late VlcPlayerController _vlcController;
  bool isFavorite = false;
  bool isFullscreen = false;
  List<String> favoriteChannels = [];
  String currentChannel = "Animax";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String streamUrl =
      "https://livetv-fa.tubi.video/outsidetv2/playlist.m3u8"; // Replace with a valid IPTV URL

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      streamUrl,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _vlcController.stop();
    _vlcController.dispose();
    super.dispose();
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      if (isFavorite) {
        favoriteChannels.add(currentChannel);
      } else {
        favoriteChannels.remove(currentChannel);
      }
    });
  }

  void toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar:
          isFullscreen
              ? null
              : AppBar(
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                title: const Text(
                  "BukidNET - Tv",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/bukidNet.jpg', height: 80),
                  const SizedBox(height: 20),
                  const Text(
                    "BukidNET - Tv",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text("Search Channel"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.tv),
              title: const Text("Channels"),
              onTap: () {},
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[300],
      body:
          isFullscreen
              ? _buildFullscreenPlayer()
              : Row(
                children: [
                  if (isLargeScreen)
                    Container(
                      width: screenWidth * 0.20,
                      color: Colors.black,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Image.asset('assets/bukidNet.jpg', height: 100),
                          const SizedBox(height: 20),
                          const Text(
                            "BukidNet - TV",
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          _buildSidebarButton(Icons.tv, "Channels"),
                          _buildSidebarButton(Icons.favorite, "Favorites"),
                          _buildSidebarButton(Icons.search, "Search"),
                        ],
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/animax_logo.png',
                              height: isLargeScreen ? 80 : 60,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentChannel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Stack(
                                children: [
                                  VlcPlayer(
                                    controller: _vlcController,
                                    aspectRatio: 16 / 9,
                                    placeholder: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                      ),
                                      onPressed: toggleFullscreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: toggleFavorite,
                            ),
                            const Text("Add to favorites"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Previous"),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Next"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildFullscreenPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: VlcPlayer(
              controller: _vlcController,
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: toggleFullscreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}
