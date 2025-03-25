import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krestelvpn/Providers/vpnProvider.dart';
import 'package:provider/provider.dart';
import 'package:krestelvpn/Pages/splashpage.dart';
import 'package:krestelvpn/Providers/authProvider.dart';
import 'package:krestelvpn/Providers/homeProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  ).then((_) {
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => HomeProvider()),
      ChangeNotifierProvider(create: (context) => VpnProvider()),
    ], child: const MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return MaterialApp(
      // navigatorKey: navigatorKey,
      title: 'Kestrel VPN',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Color.fromARGB(255, 217, 42, 80),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        primaryColor: Color.fromARGB(255, 217, 42, 80),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
