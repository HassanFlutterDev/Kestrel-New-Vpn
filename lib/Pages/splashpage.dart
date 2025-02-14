import 'package:flutter/material.dart';
import 'package:krestelvpn/Pages/homepage.dart';
import 'package:krestelvpn/Pages/consentpage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<Map<String, dynamic>> _checkInitialConditions() async {
    // Check both connection and login status simultaneously
    final connectivityResult = await Connectivity().checkConnectivity();
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('token');

    return {
      'hasConnection': connectivityResult != ConnectivityResult.none,
      'isLoggedIn': isLoggedIn && token != null, // Ensure both are present
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF000000)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 350),
            Column(
              children: [
                Image.asset(
                  "assets/images/krestel.png",
                  scale: 2,
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'The Ultimate Secure Browsing',
                    style: TextStyle(
                      color: Color(0xFFffffff),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 300),
            FutureBuilder<Map<String, dynamic>>(
              future: Future.delayed(
                const Duration(seconds: 3),
                _checkInitialConditions,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    if (!data['hasConnection']) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                'Please check your internet connection',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "Version 1.0.0",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      );
                    }

                    // Navigate based on login status
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (data['isLoggedIn']) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                          (route) => false,
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const ConsentPage()),
                          (route) => false,
                        );
                      }
                    });
                  }
                }
                
                // Loading state
                return Column(
                  children: const [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFffffff)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}