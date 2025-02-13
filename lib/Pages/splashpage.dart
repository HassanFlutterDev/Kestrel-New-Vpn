// ignore_for_file: unrelated_type_equality_checks
import 'package:flutter/material.dart';
import 'package:krestelvpn/Pages/consentpage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<bool> _checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    // Return true if connected (wifi or mobile), false if no connection
    return connectivityResult != ConnectivityResult.none;
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
            SizedBox(
              height: 350,
            ),
            Column(
              children: [
                Image.asset(
                  "assets/images/krestel.png",
                  scale: 2,
                ),
                const SizedBox(
                  height: 10,
                ),
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
            SizedBox(
              height: 300,
            ),
            // ... existing imports and code ...

            FutureBuilder(
              future: Future.delayed(const Duration(seconds: 3))
                  .then((_) => _checkConnection()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == true) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ConsentPage(),
                        ),
                      );
                    });
                   // return Column(
                    //   children: [
                    //     const CircularProgressIndicator(
                    //       strokeWidth: 3,
                    //       valueColor:
                    //           AlwaysStoppedAnimation<Color>(Color(0xFFffffff)),
                    //     ),
                    //     Text("Version 1.0.0",
                    //         style:
                    //             TextStyle(color: Colors.white, fontSize: 12)),
                    //   ],
                    // );
                  } else {
                    print('No Internet Connection');
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'Please check your internet connection',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text("Version 1.0.0",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    );
                  }
                }
                return Column(
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFffffff)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Version 1.0.0",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
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
