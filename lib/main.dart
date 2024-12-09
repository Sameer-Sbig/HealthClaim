import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_app/customProvider.dart';

import 'package:secure_app/Screens/splash.dart';

void main() async {
  // HttpOverrides.global = MyHttpOverrides();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // if (Platform.isAndroid) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.createToken();
    Timer.periodic(const Duration(seconds: 290), (timer) async {
      await appState.createToken();
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SBIG Secure',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        // '/register': (context) => const LayoutScreen(),
        // '/login': (context) => const LoginScreen(),
      },
      // home: const SplashScreen(),
    );
  }
}
