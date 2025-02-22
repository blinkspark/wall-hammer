import 'package:dart_nats/dart_nats.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/download_data.dart';
import 'page/downloadre.dart';
import 'page/file.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'data/app_data.dart';
import 'page/home.dart';
import 'page/login.dart';
import 'page/profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  final getIt = GetIt.I;
  final logger = Logger();
  getIt.registerSingleton<Logger>(logger);
  getIt.registerSingletonAsync<Client>(() async {
    final client = Client();
    client.acceptBadCert = true;
    await client.connect(Uri.parse('nats://demo.nats.io:4443'));
    return client;
  });
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final textTheme = GoogleFonts.notoSansSc();
    final seedColor = Colors.blue;
    var lightTheme = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true);
    lightTheme = lightTheme.copyWith(
        textTheme: GoogleFonts.notoSansScTextTheme(lightTheme.textTheme));
    var darkTheme = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor, brightness: Brightness.dark),
        useMaterial3: true);
    darkTheme = darkTheme.copyWith(
        textTheme: GoogleFonts.notoSansScTextTheme(darkTheme.textTheme));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppData()),
        ChangeNotifierProvider(create: (_) => DownloadData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => MainFrame(),
          '/login': (context) => LoginPage(),
        },
      ),
    );
  }
}

class MainFrame extends StatefulWidget {
  const MainFrame({super.key});

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      body: [HomePage(), FilePage(), DownloadPage(), ProfilePage()][_index],
      bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) {
            setState(() {
              _index = index;
            });
          },
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home), label: '主页'),
            NavigationDestination(icon: const Icon(Icons.folder), label: '文件'),
            NavigationDestination(
                icon: const Icon(Icons.download), label: '下载'),
            NavigationDestination(icon: const Icon(Icons.person), label: '我的'),
          ]),
    );
  }
}
