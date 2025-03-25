import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krestelvpn/Pages/splashpage.dart';

class NoInternetCupertinoDialog extends StatefulWidget {
  const NoInternetCupertinoDialog({Key? key}) : super(key: key);

  @override
  State<NoInternetCupertinoDialog> createState() =>
      _NoInternetCupertinoDialogState();
}

class _NoInternetCupertinoDialogState extends State<NoInternetCupertinoDialog> {
  void _exitApp() {
    exit(0); // This will force close the app on iOS
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dialog dismissal
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: const Color.fromARGB(111, 0, 0, 0),
        child: CupertinoAlertDialog(
          title: Column(
            children: [
              Icon(
                CupertinoIcons.wifi_slash,
                size: 44,
                color: CupertinoColors.systemRed,
              ),
              SizedBox(height: 8),
              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please check your internet connection and try again.',
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              onPressed: () {
                // Add your retry logic here
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) {
                  return SplashPage(); // Replace with your screen
                }));
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true, // Makes the text red
              child: Text(
                'Exit App',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              onPressed: _exitApp,
            ),
          ],
        ),
      ),
    );
  }
}
