import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krestelvpn/Pages/splashpage.dart';
import 'package:krestelvpn/Providers/authProvider.dart';
import 'package:krestelvpn/Providers/homeProvider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => HomeProvider()) 
    ],
    child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KRESTEL VPN',
      theme: ThemeData(
      fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
