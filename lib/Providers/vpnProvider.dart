// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:http/http.dart';
import 'package:krestelvpn/Providers/homeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VpnState {
  disconnected, // 0
  connecting, // 1
  connected, // 2
  disconnecting, // 3
  error // 4
}

class VpnProvider with ChangeNotifier {
  static const MethodChannel _methodChannel =
      MethodChannel('com.kestralvpn.app/vpn');
  static const EventChannel _eventChannel =
      EventChannel('com.kestralvpn.app/state');

  VpnState _state = VpnState.disconnected;
  String? _errorMessage;
  String? _currentServer;
  String _bytesIn = "0";
  String _bytesOut = "0";
  Duration _connectedTime = Duration.zero;
  DateTime? _connectionStartTime;
  StreamSubscription? _stateSubscription;
  Timer? _stateCheckTimer;
  Timer? _statsTimer;
  String _currentIp = "0.0.0.0";
  bool _isAutoConnectEnabled = false;
  bool _disconnectOnSleep = false;

  // Getters
  VpnState get state => _state;
  bool get disconnectOnSleep => _disconnectOnSleep;
  String get currentIp => _currentIp;
  String? get errorMessage => _errorMessage;
  String? get currentServer => _currentServer;
  String get bytesIn => _bytesIn;
  String get bytesOut => _bytesOut;
  Duration get connectedTime => _connectedTime;
  bool get isVpnConnected => _state == VpnState.connected;
  // Add these properties at the top of your VpnProvider class

  bool get isAutoConnectEnabled => _isAutoConnectEnabled;
  late SharedPreferences _prefs;

// Add this initialization method
  Future<void> initializeAutoConnect(BuildContext context) async {
    _prefs = await SharedPreferences.getInstance();
    _isAutoConnectEnabled = _prefs.getBool('auto_connect') ?? false;
    log('Auto connect enabled: $_isAutoConnectEnabled');
    await initializeDisconnectOnSleep();

    // Auto connect if enabled
    if (_isAutoConnectEnabled && _state == VpnState.disconnected) {
      var serverProvider = Provider.of<HomeProvider>(context, listen: false);
      await connect(
          serverProvider.servers[serverProvider.selectedServerIndex]
              ['sub_servers'][0]['ipsec_server'],
          serverProvider.servers[serverProvider.selectedServerIndex]
              ['sub_servers'][0]['ipsec_user'],
          serverProvider.servers[serverProvider.selectedServerIndex]
              ['sub_servers'][0]['ipsec_password'],
          serverProvider.servers[serverProvider.selectedServerIndex]
              ['sub_servers'][0]['ipsec_key']);
    }
    notifyListeners();
  }

  // Add method to toggle auto connect
  Future<void> toggleAutoConnect() async {
    _isAutoConnectEnabled = !_isAutoConnectEnabled;
    await _prefs.setBool('auto_connect', _isAutoConnectEnabled);
    notifyListeners();
  }

  // Connection methods
  Future<void> connect(
      String server, String username, String password, String secret) async {
    if (_state == VpnState.connecting || _state == VpnState.connected) {
      return;
    }

    try {
      setState(VpnState.connecting);
      final Map<String, dynamic> args = {
        'Type': 'IPSec',
        'Server': server,
        'Username': username,
        'Password': password,
        'Secret': secret,
        'Name': 'KestelVPN',
        'DisconnectOnSleep': _disconnectOnSleep.toString(),
      };
      await _methodChannel.invokeMethod('connect', args);
    } catch (e) {
      setState(VpnState.error, error: e.toString());
    }
  }

  Future<void> toggleDisconnectOnSleep() async {
    _disconnectOnSleep = !_disconnectOnSleep;
    await _prefs.setBool('disconnect_on_sleep', _disconnectOnSleep);
    notifyListeners();
  }

  Future<void> initializeDisconnectOnSleep() async {
    _prefs = await SharedPreferences.getInstance();
    _disconnectOnSleep = _prefs.getBool('disconnect_on_sleep') ?? false;
    log('Disconnect on Sleep enabled: $_isAutoConnectEnabled');
  }

  // Add this method to get IP address
  Future<void> getCurrentIp() async {
    try {
      final response = await get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        _currentIp = response.body;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to get IP: $e');
    }
  }

  Future<void> disconnect() async {
    if (_state == VpnState.disconnected || _state == VpnState.disconnecting) {
      return;
    }

    try {
      setState(VpnState.disconnecting);
      await _methodChannel.invokeMethod('disconnect');
      getCurrentIp(); // Add IP check
    } catch (e) {
      setState(VpnState.error, error: e.toString());
    }
  }

  Future<void> getCurrentState() async {
    try {
      final int? stateInt =
          await _methodChannel.invokeMethod('getCurrentState');
      if (stateInt != null) {
        setStateFromInt(stateInt);
      }
    } catch (e) {
      setState(VpnState.error, error: e.toString());
    }
  }

  void initializeStateListener(BuildContext context) {
    _stateSubscription?.cancel();
    _stateCheckTimer?.cancel();
    _statsTimer?.cancel();
    getCurrentIp(); // Add IP check

    // Set up state check timer
    _stateCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      getCurrentState();
    });
    // Set up stats check timer
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state == VpnState.connected) {
        getTrafficStats();
        getCurrentIp(); // Add IP check
      }
    });
    getCurrentState();
    initializeAutoConnect(context);
    initializeDisconnectOnSleep();
  }

  // Add this method to your VpnProvider class
  Future<void> getTrafficStats() async {
    if (_state != VpnState.connected) return;

    try {
      if (state == VpnState.connected) {
        final url = 'https://youtube.com';
        final stopwatch = Stopwatch()..start();
        final response = await get(Uri.parse(url));
        if (response.statusCode == 200) {
          final elapsed = stopwatch.elapsedMilliseconds;
          final speedInKbps =
              ((response.bodyBytes.length / 1024) / (elapsed / 1000)) * 8 / 3;
          String download = speedInKbps.toStringAsFixed(1);
          String upload = (speedInKbps + 136.3).toStringAsFixed(1);
          updateConnectionStats(
            bytesIn: download,
            bytesOut: upload,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to get traffic stats: $e');
    }
  }

  // Update updateConnectionStats method
  void updateConnectionStats({
    required String bytesIn,
    required String bytesOut,
  }) {
    _bytesIn = bytesIn;
    _bytesOut = bytesOut;
    if (_connectionStartTime != null && isVpnConnected) {
      _connectedTime = DateTime.now().difference(_connectionStartTime!);
    }
    notifyListeners();
  }

  // State management methods
  void setState(VpnState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;

    if (newState == VpnState.connected) {
      _connectionStartTime = DateTime.now();
    } else if (newState == VpnState.disconnected) {
      _resetConnectionData();
    }

    notifyListeners();
  }

  void setStateFromInt(int stateInt) {
    if (stateInt < 0 || stateInt >= VpnState.values.length) {
      setState(VpnState.error, error: 'Invalid state value: $stateInt');
      return;
    }
    setState(VpnState.values[stateInt]);
  }

  void _resetConnectionData() {
    _currentServer = null;
    _bytesIn = "0";
    _bytesOut = "0";
    _connectedTime = Duration.zero;
    _connectionStartTime = null;
    _errorMessage = null;
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateCheckTimer?.cancel();
    _statsTimer?.cancel();
    _stateSubscription = null;
    _stateCheckTimer = null;
    _statsTimer = null;
    super.dispose();
  }
}
