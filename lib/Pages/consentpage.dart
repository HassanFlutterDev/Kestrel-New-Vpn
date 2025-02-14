import 'package:flutter/material.dart';
import 'package:krestelvpn/Pages/guestpage.dart';

class ConsentPage extends StatelessWidget {
  const ConsentPage({super.key});

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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/krestel.png",
                        scale: 3,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Kestrel VPN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                Image.asset(
                  "assets/images/handshake.png",
                  scale: 2,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Usage Consent",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    height: 1,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: const [
                      BulletPoint(
                        text: 'By using Kestrel VPN, you agree not to engage in illegal activities.',
                      ),
                      SizedBox(height: 12),
                      BulletPoint(
                        text: 'We do not log browsing activities but collect non-personal information for analytics.',
                      ),
                      SizedBox(height: 12),
                      BulletPoint(
                        text: 'The app is provided \'as-is\' without warranties, and we are not liable for any damages.',
                      ),
                      SizedBox(height: 12),
                      BulletPoint(
                        text: 'Misuse of VPN will surely result in suspension.',
                      ),
                      SizedBox(height: 12),
                      BulletPoint(
                        text: 'You must be of legal age as per your country.',
                      ),
                      SizedBox(height: 12),
                      BulletPoint(
                        text: 'The VPN service may face disruptions, and we are not liable for damages or losses.',
                      ),
                      SizedBox(height: 12),
                      BulletPoint(
                        text: 'We may suspend or terminate your access for any misuse or violation of terms.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GradientButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const GuestPage()),
                        (route) => false,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22.0,
                    vertical: 15.0,
                  ),
                  child: const Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;

  const GradientButton({
    super.key,
    required this.onPressed,
    this.text = 'Continue',
    this.width = double.infinity,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF3D89), // Pink
            Color(0xFF3D9FFF), // Blue
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}