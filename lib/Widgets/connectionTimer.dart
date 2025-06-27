// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionTimer extends StatefulWidget {
  const ConnectionTimer({Key? key}) : super(key: key);

  @override
  _ConnectionTimerState createState() => _ConnectionTimerState();
}

class _ConnectionTimerState extends State<ConnectionTimer> {
  Duration _duration = Duration();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadStoredTime();
    _startTimer();
  }

  // Load the stored time (if exists) from GetStorage
  void _loadStoredTime() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    log('Time loaded from storage: ${pref.getString('connectTime')}');
    // If no stored time, set to current time
    final storedTime = DateTime.parse(
      pref.getString('connectTime') ?? DateTime.now().toString(),
    );
    _duration = DateTime.now().difference(storedTime);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = _duration + Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigit(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigit(_duration.inHours);
    final minutes = twoDigit(_duration.inMinutes.remainder(60));
    final seconds = twoDigit(_duration.inSeconds.remainder(60));

    return Text(
      '$hours:$minutes:$seconds',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
    );
  }
}
