// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:krestelvpn/Helper/snackbar.dart';
import 'package:krestelvpn/Pages/homepage.dart';
import 'package:krestelvpn/Pages/loginpage.dart';
import 'package:krestelvpn/Pages/noInternet.dart';
import 'package:krestelvpn/Providers/authProvider.dart';
import 'package:krestelvpn/Providers/vpnProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../Helper/plans.dart';

class HomeProvider with ChangeNotifier {
  List<dynamic> _servers = [];
  List<dynamic> get servers => _servers;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Add selected server index
  int _selectedServerIndex = 0;
  int get selectedServerIndex => _selectedServerIndex;
  String _selectedPlanID = '';
  String get selectedPlanId => _selectedPlanID;

  // Add Device ID property
  String? _deviceId;
  String? get deviceId => _deviceId;

  // Add user data property
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;
  bool _isLoadingUser = false;
  bool get isLoadingUser => _isLoadingUser;

  // Add premium properties
  bool _isPremium = false;
  bool get isPremium => _isPremium;
  bool _isLifetime = false;
  bool get isLifetime => _isLifetime;
  DateTime? _expiryDate;
  DateTime? get expiryDate => _expiryDate;

  // Add plans properties
  List<Plan> _plans = [];
  List<Plan> get plans => _plans;
  BuildContext? _cont;
  BuildContext? get cont => _cont;
  bool _isLoadingPlans = false;
  bool get isLoadingPlans => _isLoadingPlans;

  // Add current plan property
  Plan? _currentPlan;
  Plan? get currentPlan => _currentPlan;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final Set<String> _kIds = <String>{
    'kestrel_15_1w',
    'kestrel_50_1m',
    'kestrel_500_1y',
  };
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;
  late final InAppPurchase _inAppPurchase;

  HomeProvider() {
    _inAppPurchase = InAppPurchase.instance;
    _initPurchases();
    getDeviceId();
  }

  Future<void> _initPurchases() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      log('Store not available');
      return;
    }

    // Set up purchase stream listener
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Query product details
    if (Platform.isAndroid) {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        log('Products not found: ${response.notFoundIDs}');
      }
      _products = response.productDetails;
      _products.sort((a, b) => a.id.compareTo(b.id));
      notifyListeners();
    } else if (Platform.isIOS) {
      _products = [];
      // Query each product individually for iOS
      for (final id in _kIds) {
        final response = await _inAppPurchase.queryProductDetails({id});
        if (response.productDetails.isNotEmpty) {
          _products.add(response.productDetails.first);
        }
      }
      // await _inAppPurchase.restorePurchases();
      notifyListeners();
    }
  }

  getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      _deviceId = androidInfo.id; // Unique ID on Android
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      _deviceId = iosInfo.identifierForVendor; // Unique ID on iOS
    }
    notifyListeners();
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    log('In-app purchase error: $error');
  }

  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status.name == 'canceled') {
        Navigator.pop(cont!);
      }
      await _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      await _inAppPurchase.completePurchase(purchaseDetails);
      // Update premium status on server
      if (purchaseDetails.productID == 'kestrel_15_1w') {
        _selectedPlanID = '2';
      } else if (purchaseDetails.productID == 'kestrel_50_1m') {
        _selectedPlanID = '3';
      } else if (purchaseDetails.productID == 'kestrel_500_1y') {
        _selectedPlanID = '4';
      }
      await _updatePremiumStatus();
      notifyListeners();
    } else if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
      notifyListeners();
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      log('Purchase error: ${purchaseDetails.error?.message}');
    }
  }

  Future<void> _updatePremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('https://admin.kestrelvpn.com/api/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plan_id': _selectedPlanID,
        }),
      );

      log(response.body);
      if (cont != null) {
        Navigator.pushReplacement(
          cont!,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        getPremiumStatus(cont!);
      }
    } catch (e) {
      log('Error updating premium status: $e');
    }
  }

  set selectedPlanId(String value) {
    _selectedPlanID = value;
    notifyListeners();
  }

  set selectedCurrentPlan(Plan? value) {
    _currentPlan = value;
    notifyListeners();
  }

  set selectBuildContext(BuildContext context) {
    _cont = context;
    notifyListeners();
  }

  Future<void> makePurchase(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      log('Purchase failed: $e');
    }
  }

  // Add getAllPlans method
  Future<List<Plan>> getAllPlans(BuildContext context) async {
    try {
      _isLoadingPlans = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      final response = await http.get(
        Uri.parse('https://admin.kestrelvpn.com/api/plans'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Plans data: ${data['plans']}");

        // Parse plans and update state
        _plans = List<Plan>.from(data['plans'].map((x) => Plan.fromJson(x)));

        // Cache plans
        await prefs.setString('cached_plans', jsonEncode(data['plans']));

        return _plans;
      } else if (response.statusCode == 401) {
        return [];
      } else {
        throw Exception('Failed to load plans');
      }
    } catch (e) {
      log('Error getting plans: $e');
      // Load cached plans if available
      final prefs = await SharedPreferences.getInstance();
      final cachedPlans = prefs.getString('cached_plans');
      if (cachedPlans != null) {
        final plansData = jsonDecode(cachedPlans);
        _plans = List<Plan>.from(plansData.map((x) => Plan.fromJson(x)));
        return _plans;
      }
      return [];
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }

  // Add getPremiumStatus method
  Future<void> getPremiumStatus(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _isPremium = false;
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('https://admin.kestrelvpn.com/api/purchase/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['purchases'].isEmpty) {
          _isPremium = false;
          _isLifetime = false;
          _expiryDate = null;
          getUserData(context, isPremium: true);
        } else {
          final lastPurchase = data['purchases'].last;
          final premiumDate = DateTime.parse(lastPurchase['expires_at']);
          final now = DateTime.now();

          if (premiumDate.isBefore(now)) {
            _isPremium = false;
            _isLifetime = false;
            _expiryDate = null;
            getUserData(context, isPremium: true);
          } else {
            _expiryDate = premiumDate;
            _isPremium = true;
            getUserData(context, isPremium: true);

            if (lastPurchase['plan_id'] != null) {
              _currentPlan = _plans.firstWhere(
                (plan) => plan.id == lastPurchase['plan_id'],
              );
            }

            // Cache premium status
            await prefs.setBool('is_premium', _isPremium);
            await prefs.setBool('is_lifetime', _isLifetime);
            await prefs.setString(
                'expiry_date', _expiryDate?.toIso8601String() ?? '');
            if (_currentPlan != null) {
              await prefs.setString(
                  'current_plan', jsonEncode(_currentPlan!.toJson()));
            }
          }
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        var authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logOut(context);
      }
    } catch (e) {
      log('Error getting premium status: $e');
    }

    notifyListeners();
  }

  // Add getUserData method
  Future<void> getUserData(
    BuildContext context, {
    bool isPremium = false,
  }) async {
    try {
      _isLoadingUser = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('https://admin.kestrelvpn.com/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userData = data['user'];
        // Cache user data
        await prefs.setString('user_data', jsonEncode(_userData));
        if (isPremium == false) {
          await getPremiumStatus(context);
        }
      } else {
        // Load cached data if request fails
        final cachedData = prefs.getString('user_data');
        if (cachedData != null) {
          _userData = jsonDecode(cachedData);
        }
        log('Failed to get user data: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting user data: $e');
      // Load cached data on error
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('user_data');
      if (cachedData != null) {
        _userData = jsonDecode(cachedData);
      }
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }

  // Add method to select server
  void selectServer(int index, BuildContext context) async {
    if (index >= 0 && index < _servers.length) {
      _selectedServerIndex = index;
      _saveSelectedIndex();
      var vpnProvider = Provider.of<VpnProvider>(context, listen: false);
      if (vpnProvider.state == VpnState.connected) {
        vpnProvider.disconnect();
        await Future.delayed(const Duration(seconds: 2));
      }
      vpnProvider.connect(
        server: _servers[index]['sub_servers'][0]['ip_address'],
        username: _servers[index]['sub_servers'][0]['ipsec_user'],
        password: _servers[index]['sub_servers'][0]['ipsec_password'],
        secret: _servers[index]['sub_servers'][0]['ipsec_key'],
        userId: deviceId!,
        address: _servers[index]['sub_servers'][0]['wg_panel_address'],
        wgPassword: _servers[index]['sub_servers'][0]['wg_panel_password'],
        context: context,
      );
      notifyListeners();
    }
  }

  // Add method to save selected index
  Future<void> _saveSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_server_index', _selectedServerIndex);
  }

  // Add method to load selected index
  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('selected_server_index') == null) {
      for (int i = 0; i < _servers.length; i++) {
        if (_servers[i]['status'] == '0') {
          _selectedServerIndex = i;
          _saveSelectedIndex();
          break;
        }
      }
    } else {
      _selectedServerIndex = prefs.getInt('selected_server_index') ?? 0;
    }
    notifyListeners();
  }

  Future<void> getServers(bool hasNetwork, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedServers = prefs.getString('servers');

    if (storedServers != null) {
      if (hasNetwork) {
        _servers = jsonDecode(storedServers);
        log('read local');
        try {
          final response = await http
              .get(Uri.parse("https://admin.kestrelvpn.com/api/servers"))
              .timeout(const Duration(seconds: 10));
          final data = jsonDecode(response.body);

          log('update local');
          _servers = data['servers'];
          await prefs.setString('servers', jsonEncode(_servers));
        } catch (e) {
          showCupertinoDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NoInternetCupertinoDialog(),
          );
          _servers = jsonDecode(storedServers); // fallback to stored data
        }
      } else {
        log('no internet read local');
        _servers = jsonDecode(storedServers);
      }
    } else {
      if (hasNetwork) {
        try {
          final response = await http
              .get(Uri.parse("https://admin.kestrelvpn.com/api/servers"))
              .timeout(const Duration(seconds: 10));
          final data = jsonDecode(response.body);
          _servers = data['servers'];
          await prefs.setString('servers', jsonEncode(_servers));
          log('add local');
          // Log servers list
        } catch (e) {
          _servers = [];
        }
      } else {
        log('no net local');
      }

      await getUserData(context); // Fetch user data after loading servers
      await getAllPlans(context); // Fetch plans after loading servers
    }

    _loadSelectedIndex();

    _isLoading = false;
    notifyListeners();
  }

  // // Now we have to register the user in the VPS server and vps url is in sub_servers['ip_address']. now we have to get that server url and register the user in that server. we will register user at once in all servers.
  // Future getServersUrlFromSub() async {
  //   log("🔵 Getting servers URL from sub_servers");
  //   for (var server in _servers) {
  //     for (var subServer in server['sub_servers']) {
  //       final String? serverUrl = subServer['ip_address'];
  //       if (serverUrl != null && serverUrl.isNotEmpty) {
  //         bool registered = await registerUserInVPS('http://$serverUrl:5000');
  //         if (registered) {
  //           log("✅ User registered successfully in VPS server: $serverUrl");
  //         } else {
  //           log("❌ Failed to register user in VPS server: $serverUrl");
  //         }
  //       } else {
  //         log("❌ Server URL is null or empty for sub_server: ${subServer['name']}");
  //       }
  //     }
  //   }
  // }

  Future<bool> registerUserInVPS(String serverUrl) async {
    log("🔵 Registering user in VPS server: $serverUrl");
    try {
      log("🔵 Registering user in VPS server: $serverUrl");
      final prefs = await SharedPreferences.getInstance();

      final String? name = prefs.getString('name') ?? deviceId!;
      final String? password = prefs.getString('password') ?? "12345678";
      log("🔵 Name: $name, Password: $password");

      if (name == null || password == null) {
        log("❌ Name or password is missing");
        return false;
      }

      final String platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : 'desktop';

      const headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Token': 'a3f7b9c2-d1e5-4f68-8a0b-95c6e7f4d8a1',
      };

      final firstResponse = await http
          .post(
            Uri.parse("$serverUrl/api/ikev2/clients/generate"),
            headers: headers,
            body: jsonEncode({
              "name": "${name.replaceAll(' ', '-')}_$platform",
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 2));

      final firstBody = jsonDecode(firstResponse.body);

      if (firstBody["error"] != null) {
        var response = await http.delete(
          Uri.parse(
            "$serverUrl/api/ikev2/clients/${name.replaceAll(' ', '-')}_$platform",
          ),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final newResponse = await http.post(
            Uri.parse("$serverUrl/api/ikev2/clients/generate"),
            headers: headers,
            body: jsonEncode({
              "name": "${name.replaceAll(' ', '-')}_$platform",
              "password": password,
            }),
          );

          final responseBody = jsonDecode(newResponse.body);
          if (responseBody["success"] == true) {
            log("✅ Registered successfully on $serverUrl");
            return true;
          } else {
            log("❌ Registration failed on $serverUrl");
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      // log("❌ Exception during registration on $serverUrl: $e");
      return false;
    }
  }
}
