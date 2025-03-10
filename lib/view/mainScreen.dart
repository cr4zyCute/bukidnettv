import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../model/channels.dart'; // Import the channel model
import '../model/database_helper.dart';

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
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  int currentIndex = 0; // Track current channel
  bool isFavorite = false;
  List<String> favoriteChannels = [];
  List<Channel> filteredChannels = [];
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializePlayer(channels[currentIndex].url);
    filteredChannels = List.from(channels);
    _loadFavorites(); // Load favorites when the app starts
  }

  void _filterChannels(String query) {
    setState(() {
      filteredChannels =
          channels
              .where(
                (channel) =>
                    channel.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _initializePlayer(String url) {
    _videoPlayerController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: 16 / 9,
      showControls: true,
      customControls: OnlyFullscreenButton(), // Use only fullscreen button
    );
  }

  void _changeChannel(int index) {
    setState(() {
      currentIndex = index;
      _videoPlayerController.dispose();
      _chewieController.dispose();
      _initializePlayer(channels[currentIndex].url);

      // Update isFavorite when switching channels
      isFavorite = favoriteChannels.contains(channels[currentIndex].name);
    });
  }

  void _nextChannel() {
    if (currentIndex < channels.length - 1) {
      _changeChannel(currentIndex + 1);
    }
  }

  void _previousChannel() {
    if (currentIndex > 0) {
      _changeChannel(currentIndex - 1);
    }
  }

  void toggleFavorite() async {
    final db = DatabaseHelper.instance;
    if (isFavorite) {
      await db.removeFavorite(channels[currentIndex].name);
    } else {
      await db.addFavorite(channels[currentIndex].name);
    }
    _loadFavorites(); // Refresh favorites from the database
  }

  void _loadFavorites() async {
    final db = DatabaseHelper.instance;
    List<String> favorites = await db.getFavorites();
    setState(() {
      favoriteChannels = favorites;
      isFavorite = favoriteChannels.contains(channels[currentIndex].name);
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  void _removeFavorite(String channelName) async {
    final db = DatabaseHelper.instance;
    await db.removeFavorite(channelName);
    _loadFavorites(); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          "BukidNET - TV",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/bukidNet.jpg', height: 80),
                  const SizedBox(height: 20),
                  const Text(
                    "BukidNET - TV",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search Channels...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (query) {
                  _filterChannels(query);
                },
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Channels",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredChannels.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: Image.asset(filteredChannels[i].logo, height: 30),
                    title: Text(filteredChannels[i].name),
                    onTap: () {
                      _changeChannel(channels.indexOf(filteredChannels[i]));
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      backgroundColor: Colors.grey[300],
      body: Row(
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
                      channels[currentIndex].logo,
                      height: isLargeScreen ? 80 : 60,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      channels[currentIndex].name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Chewie(controller: _chewieController),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: toggleFavorite,
                    ),
                    const Text("Add to favorites"),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _previousChannel,
                              child: const Text("Previous"),
                            ),
                            ElevatedButton(
                              onPressed: _nextChannel,
                              child: const Text("Next"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Favorite Channels",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children:
                              favoriteChannels.map((channelName) {
                                // Find the channel object using the name
                                Channel? channel = channels.firstWhere(
                                  (ch) => ch.name == channelName,
                                  orElse:
                                      () => Channel(
                                        name: channelName,
                                        url: "",
                                        logo: "assets/default_logo.png",
                                      ), // Default image if not found
                                );

                                return ListTile(
                                  leading: Image.asset(
                                    channel.logo,
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(channel.name),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _removeFavorite(channel.name);
                                    },
                                  ),
                                  onTap: () {
                                    int index = channels.indexWhere(
                                      (ch) => ch.name == channel.name,
                                    );
                                    if (index != -1) {
                                      _changeChannel(index);
                                    }
                                  },
                                );
                              }).toList(),
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

  Widget _buildSidebarButton(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}

class OnlyFullscreenButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chewieController = ChewieController.of(context);

    return Align(
      alignment: Alignment.bottomRight,
      child: IconButton(
        icon: const Icon(Icons.fullscreen, color: Colors.white, size: 30),
        onPressed: () {
          chewieController.enterFullScreen();
        },
      ),
    );
  }
}
