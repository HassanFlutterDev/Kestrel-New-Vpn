import 'package:flutter/material.dart';
import 'package:krestelvpn/Pages/homepage.dart';
import 'package:krestelvpn/Pages/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/krestel.png',
                height: 120,
                width: 120,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to Kestrel VPN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Kestrel VPN is a free VPN service that allows you to access the internet securely & anonymously. \nBy using Kestrel VPN, you agree to our Terms of Service and Privacy Policy.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('onBoard', true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                        child: const Text(
                      "Continue As Guest",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('onBoard', true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LogInPage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF3D89), Color(0xFF3D9FFF)],
                        )),
                    child: Center(
                        child: const Text(
                      "login",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
