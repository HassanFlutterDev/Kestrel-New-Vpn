// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:http/http.dart';
import 'package:krestelvpn/Providers/api_services.dart';
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

enum VpnProtocol {
  wireguard,
  ipsec,
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
  VpnProtocol _protocol = VpnProtocol.wireguard;
  bool _gettingConfig = false;

  // Getters
  bool get isGettingConfig => _gettingConfig;
  VpnProtocol get protocol => _protocol;
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

  VpnProvider() {
    initWireguard();
    _loadSavedProtocol();
  }

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
        server: serverProvider.servers[serverProvider.selectedServerIndex]
            ['sub_servers'][0]['ipsec_server'],
        username: serverProvider.servers[serverProvider.selectedServerIndex]
            ['sub_servers'][0]['ipsec_user'],
        password: serverProvider.servers[serverProvider.selectedServerIndex]
            ['sub_servers'][0]['ipsec_password'],
        secret: serverProvider.servers[serverProvider.selectedServerIndex]
            ['sub_servers'][0]['ipsec_key'],
        userId: serverProvider.servers[serverProvider.selectedServerIndex]
            ['sub_servers'][0]['user_id'],
        address: serverProvider.servers[serverProvider.selectedServerIndex]
            ['sub_servers'][0]['wg_panel_address'],
        wgPassword: serverProvider.servers[serverProvider.selectedServerIndex]
            ['sub_servers'][0]['wg_panel_password'],
        context: context,
      );
    }
    notifyListeners();
  }

  // Add method to toggle auto connect
  Future<void> toggleAutoConnect() async {
    _isAutoConnectEnabled = !_isAutoConnectEnabled;
    await _prefs.setBool('auto_connect', _isAutoConnectEnabled);
    notifyListeners();
  }

  initWireguard() async {
    log('Initializing WireGuard');
    await _methodChannel.invokeMethod('initializeWireguard');
  }

  // Add this helper method to extract server from WireGuard config
  String? _extractServerFromConfig(String config) {
    try {
      final lines = config.split('\n');
      for (String line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.startsWith('Endpoint')) {
          // Extract the endpoint value
          final parts = trimmedLine.split('=');
          if (parts.length >= 2) {
            final endpoint = parts[1].trim();
            // Extract just the IP/domain part (before the port)
            final serverParts = endpoint.split(':');
            if (serverParts.isNotEmpty) {
              return serverParts[0].trim();
            }
          }
        }
      }
    } catch (e) {
      log('Error extracting server from config: $e');
    }
    return null;
  }

  // Connection methods
  Future<void> connect({
    String server = '',
    String username = '',
    String password = '',
    String secret = '',
    String userId = '',
    String address = '',
    String wgPassword = '',
    BuildContext? context,
  }) async {
    if (_state == VpnState.connecting || _state == VpnState.connected) {
      return;
    }

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('connectTime', DateTime.now().toString());
      if (protocol == VpnProtocol.wireguard) {
        setState(VpnState.connecting);
        _gettingConfig = true;

        String? config = await getWireguardConfig(userId, server);
        if (config == null) {
          setState(VpnState.disconnected,
              error: 'Failed to get WireGuard config');
          _gettingConfig = false;
          return;
        }
        _gettingConfig = false;
        log('WireGuard config 32: $config');
        // Extract server from config
        final String? extractedServer = _extractServerFromConfig(config);
        final String updatedConfig =
            updateDnsInWireguardConfig(config, "8.8.8.8, 1.1.1.1");
        config = updatedConfig;
        if (extractedServer == null) {
          setState(VpnState.disconnected,
              error: 'Failed to extract server from config');
          return;
        }
        final Map<String, dynamic> args = {
          'VpnType': 'wireguard',
          'Server': extractedServer,
          'WireGuardConfig': config,
          'ProviderBundleIdentifier': 'com.kestralvpn.app.VPNExtension',
        };
        await _methodChannel.invokeMethod('connect', args);
      } else {
        setState(VpnState.connecting);
        _gettingConfig = true;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var username = prefs.getString('name') ?? userId;
        var password = prefs.getString('password') ?? '12345678';
        var platform = Platform.isIOS ? 'ios' : 'android';
        var homeProvider = Provider.of<HomeProvider>(context!, listen: false);
        await homeProvider.registerUserInVPS('http://${server}:5000');
        _gettingConfig = false;
        log('Connecting to IKEv2 with server: $server, username: $username');
        final Map<String, dynamic> args = {
          'VpnType': 'ikev2',
          'Server': server,
          'Username': "${username}_$platform",
          'Password': password,
          'Name': 'Kestrel VPN Ikev2',
          'DisconnectOnSleep': _disconnectOnSleep.toString(),
        };
        await _methodChannel.invokeMethod('connect', args);
      }
    } catch (e) {
      setState(VpnState.error, error: e.toString());
    }
  }

  String updateDnsInWireguardConfig(String config, String newDns) {
    final lines = config.split('\n');
    bool dnsFound = false;
    final updatedLines = <String>[];

    for (var line in lines) {
      if (line.trim().startsWith('DNS')) {
        updatedLines.add('DNS = $newDns');
        dnsFound = true;
      } else {
        updatedLines.add(line);
      }
    }

    // If DNS was not found, add it after the [Interface] section
    if (!dnsFound) {
      final interfaceIndex =
          updatedLines.indexWhere((l) => l.trim() == '[Interface]');
      if (interfaceIndex != -1) {
        updatedLines.insert(interfaceIndex + 2, 'DNS = $newDns');
      } else {
        // If [Interface] not found, just add at the top
        updatedLines.insert(0, 'DNS = $newDns');
      }
    }

    return updatedLines.join('\n');
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
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove('connectTime');
      setState(VpnState.disconnecting);
      if (protocol == VpnProtocol.wireguard) {
        await _methodChannel.invokeMethod('disconnectWireguard');
      } else {
        await _methodChannel.invokeMethod('disconnect');
      }
      getCurrentIp(); // Add IP check
    } catch (e) {
      setState(VpnState.error, error: e.toString());
    }
  }

  Future<void> getCurrentState() async {
    try {
      if (protocol == VpnProtocol.wireguard) {
        final String? state =
            await _methodChannel.invokeMethod('getWireguardStatus');
        print('WireGuard state: $state');
        if (isGettingConfig) {
          setState(VpnState.connecting);
          return;
        }
        if (state != null) {
          if (state == 'connected') {
            setState(VpnState.connected);
          } else if (state == 'disconnected') {
            setState(VpnState.disconnected);
          } else if (state == 'connecting') {
            setState(VpnState.connecting);
          } else if (state == 'disconnecting') {
            setState(VpnState.disconnecting);
          } else {
            setState(VpnState.error, error: state);
          }
        }
      } else {
        final Map<String, dynamic> args = {
          'VpnType': protocol == VpnProtocol.wireguard ? 'wireguard' : 'ipsec',
        };
        final int? stateInt =
            await _methodChannel.invokeMethod('getCurrentState', args);
        if (isGettingConfig) {
          setState(VpnState.connecting);
          return;
        }
        if (stateInt != null) {
          setStateFromInt(stateInt);
        }
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

  // Add these functions after your existing getters

  // Function to change VPN protocol
  Future<void> changeProtocol(VpnProtocol newProtocol) async {
    if (_state == VpnState.connected || _state == VpnState.connecting) {
      // Disconnect current VPN connection before changing protocol
      await disconnect();
    }

    // Clean up all VPN configurations
    await _methodChannel.invokeMethod('cleanupVPNs');

    // Wait for cleanup to complete
    await Future.delayed(Duration(milliseconds: 500));

    _protocol = newProtocol;

    // Save the protocol preference
    await _prefs.setString('vpn_protocol', newProtocol.toString());

    // If we were connected, try to reconnect with new protocol
    if (_state == VpnState.connected) {
      // Implement reconnect logic based on protocol
      if (newProtocol == VpnProtocol.wireguard) {
        await initWireguard();
      }
    }

    notifyListeners();
  }

  // Function to load saved protocol preference
  Future<void> _loadSavedProtocol() async {
    _prefs = await SharedPreferences.getInstance();
    final savedProtocol = _prefs.getString('vpn_protocol');
    if (savedProtocol != null) {
      _protocol = VpnProtocol.values.firstWhere(
        (p) => p.toString() == savedProtocol,
        orElse: () => VpnProtocol.wireguard,
      );
    }
  }

  //wireguard get config
  Future<String?> getWireguardConfig(userId, address) async {
    final String? config = await ApiService().getConfig(userId, address);
    log('WireGuard config: $config');
    return config;
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
