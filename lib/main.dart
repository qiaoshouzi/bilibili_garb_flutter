import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bili_garb/views/home.dart';
import 'package:bili_garb/views/about.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState of(BuildContext context) {
    final MyAppState? result = context.findAncestorStateOfType<MyAppState>();
    if (result != null) {
      return result;
    }
    throw FlutterError('MyAppState not found in context');
  }

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  void changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  ThemeMode get currentThemeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _initNetworkPermission();
  }

  Future<void> _initNetworkPermission() async {
    if (Platform.isIOS) {
      try {
        await http
            .head(Uri.parse('https://www.baidu.com'))
            .timeout(Duration(seconds: 2));
      } catch (e) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiliBili 装扮获取',
      themeMode: _themeMode,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.pink)),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: .fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});
  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isTablet = width >= 600;

    return Scaffold(
      appBar: AppBar(title: [Text('首页'), Text('关于')][currentPageIndex]),
      bottomNavigationBar: isTablet
          ? null
          : NavigationBar(
              onDestinationSelected: (int index) {
                setState(() => currentPageIndex = index);
              },
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: '首页',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.info),
                  icon: Icon(Icons.info_outlined),
                  label: '关于',
                ),
              ],
            ),
      body: Row(
        children: [
          if (isTablet)
            NavigationRail(
              onDestinationSelected: (int index) {
                setState(() => currentPageIndex = index);
              },
              selectedIndex: currentPageIndex,
              labelType: NavigationRailLabelType.all,
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: Text('首页'),
                ),
                NavigationRailDestination(
                  selectedIcon: Icon(Icons.info),
                  icon: Icon(Icons.info_outlined),
                  label: Text('关于'),
                ),
              ],
            ),
          Expanded(
            child: [const HomePage(), const AboutPage()][currentPageIndex],
          ),
        ],
      ),
    );
  }
}
