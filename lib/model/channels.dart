class Channel {
  final String name;
  final String logo;
  final String url;

  Channel({required this.name, required this.logo, required this.url});
}

List<Channel> channels = [
  Channel(
    name: "Outside TV",
    logo: "assets/outsidetv.png",
    url: "https://livetv-fa.tubi.video/outsidetv2/playlist.m3u8",
  ),
  Channel(
    name: "Tubi TV The FBI Files",
    logo: "assets/tubi.png",
    url: "https://apollo.production-public.tubi.io/live/ac-the-fbi-files.m3u8",
  ),
  Channel(
    name: "kloudtv",
    logo: "assets/kloudtv.png",
    url: "https://a-cdn.klowdtv.com/live3/law_720p/playlist.m3u8",
  ),
  // Add more channels as needed
];
