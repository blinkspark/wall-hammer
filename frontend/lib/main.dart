import 'package:flutter/material.dart';
import 'package:frontend/page/file.dart';
import 'app_data.dart';
import 'page/home.dart';
import 'page/login.dart';
import 'page/profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
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
    return ChangeNotifierProvider<AppData>(
      create: (context) => AppData(),
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
  const MainFrame({
    super.key,
  });

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      body: [HomePage(), FilePage(), ProfilePage()][_index],
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
            NavigationDestination(icon: const Icon(Icons.person), label: '我的'),
          ]),
    );
  }
}
