import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Get configuration for a user
  Future<String?> getConfig(String userId, String address) async {
    var isRegistered = await registerUserInServer(address, userId);
    if (!isRegistered) {
      log("❌ User registration failed on $address");
      return null;
    } else {
      log("✅ User registered successfully on $address");
      // now fetch the configuration
      var config = await getSelectedWireguardVPNConfig(address, userId);
      if (config == null) {
        log("❌ Failed to fetch WireGuard config from $address");
        return null;
      } else {
        log("✅ WireGuard config fetched successfully from $address");
        return config;
      }
    }
  }

  Future<String?> getSelectedWireguardVPNConfig(
      String serverUrl, userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? name = prefs.getString('name') ?? userId;

      if (name == null) {
        log("❌ Name or password is missing");
        return null;
      }

      final String platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : Platform.isWindows
                  ? 'windows'
                  : 'macos';

      const headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Token': 'a3f7b9c2-d1e5-4f68-8a0b-95c6e7f4d8a1',
      };

      // Make API call to get WireGuard config
      final response = await http.get(
        Uri.parse(
          "http://$serverUrl:5000/api/clients/${name.replaceAll(' ', '-')}_$platform",
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract config from response
        final String wireguardConfig = responseData['config'];
        final String ipAddress = responseData['ip'];
        final String clientName = responseData['name'];
        final String qrCode = responseData['qr_code'];

        log("WireGuard config saved successfully in GetStorage");
        return wireguardConfig;
      } else {
        log("Failed to get WireGuard config: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error getting WireGuard config: $e");
      return null;
    }
  }

  Future<bool> registerUserInServer(String serverUrl, userId) async {
    log("🔵 Registering user in VPS server: $serverUrl");
    try {
      log("🔵 Registering user in VPS server: $serverUrl");
      final prefs = await SharedPreferences.getInstance();

      final String? name = prefs.getString('name') ?? userId;

      if (name == null) {
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
            Uri.parse("http://$serverUrl:5000/api/clients/generate"),
            headers: headers,
            body: jsonEncode({
              "name": "${name.replaceAll(' ', '-')}_$platform",
            }),
          )
          .timeout(const Duration(seconds: 2));
      log("🔵 First response status code: ${firstResponse.body}");
      final firstBody = jsonDecode(firstResponse.body);

      if (firstBody["error"] != null) {
        var response = await http.delete(
          Uri.parse(
            "http://$serverUrl:5000/api/clients/${name.replaceAll(' ', '-')}_$platform",
          ),
          headers: headers,
        );
        log("🔵 Deletion response status code: ${response.statusCode}");
        if (response.statusCode == 200) {
          final newResponse = await http.post(
            Uri.parse("http://$serverUrl:5000/api/clients/generate"),
            headers: headers,
            body: jsonEncode({
              "name": "${name.replaceAll(' ', '-')}_$platform",
            }),
          );

          final responseBody = jsonDecode(newResponse.body);
          log("🔵 New response body: $responseBody");
          if (newResponse.statusCode == 200) {
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
      log("❌ Exception during registration on $serverUrl: $e");
      return false;
    }
  }
}
