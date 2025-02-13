import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider with ChangeNotifier {
    List<dynamic> _servers = [];
    List<dynamic> get servers => _servers;
    bool _isLoading = false;
    bool get isLoading => _isLoading;

    Future<void> getServers( bool hasNetwork) async {
      _isLoading = true;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      final storedServers = prefs.getString('servers');

      if (storedServers != null) {
      if (hasNetwork) {
        _servers = jsonDecode(storedServers);
        log('read local');
        try {
        final response = await http.get(Uri.parse("https://admin.kestrelvpn.com/api/servers"))
          .timeout(const Duration(seconds: 5));
        final data = jsonDecode(response.body);
        
        log('update local');
        _servers = data['servers'];
        await prefs.setString('servers', jsonEncode(_servers));
        
        // Log servers list
        log('Servers: ${_servers.toString()}');
        
        // // Show success snackbar
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //   content: Text('Servers updated successfully'),
        //   backgroundColor: Colors.green,
        //   ),
        // );
        } catch (e) {
        _servers = [];
        }
      } else {
        log('no internet read local');
        _servers = jsonDecode(storedServers);
      }
      } else {
      if (hasNetwork) {
        try {
        final response = await http.get(Uri.parse("https://admin.kestrelvpn.com/api/servers"))
          .timeout(const Duration(seconds: 5));
        final data = jsonDecode(response.body);
        _servers = data['servers'];
        await prefs.setString('servers', jsonEncode(_servers));
        log('add local');
        
        // Log servers list
        log('Servers: ${_servers.toString()}');
        
        // // Show success snackbar
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //   content: Text('Servers loaded successfully'),
        //   backgroundColor: Colors.green,
        //   ),
        // );
        } catch (e) {
        _servers = [];
        }
      } else {
        log('no net local');
      }
      
      for (var i = 0; i < _servers.length; i++) {
        if (_servers[i]['status'] == "0") {
        // changeCountry(i, 0);
        break;
        }
      }
      }

      _isLoading = false;
      notifyListeners();
    }
}