import 'dart:convert';
import 'package:http/http.dart';
import '../Helper/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:krestelvpn/Pages/homepage.dart';
import 'package:krestelvpn/Pages/loginpage.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isloading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser(context) async {
    try {
      isloading = true;
      notifyListeners();
      
      var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      };
      
      var request = await post(Uri.parse("https://admin.kestrelvpn.com/api/login"),
        headers: headers,
        body: jsonEncode({
        "name": emailController.text,
        "password": passwordController.text,
        }));
        
      var data = jsonDecode(request.body);
      String message = data['message'].toString().replaceAll('[', '').replaceAll(']', '');
      
      if (data['status'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
      await prefs.setString('token', data['access_token']);
      
      showCustomSnackBar(
        context,
        EvaIcons.checkmarkCircle2Outline, 
        'Success', 
        message,
        Colors.green
      );
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false
      );
      clearControllers();
      
      isloading = false;
      notifyListeners();
      } else {
        showCustomSnackBar(
          context,
          EvaIcons.alertCircle, 
          'Error', 
          message, 
          Colors.red
        );
        isloading = false;
        notifyListeners();
      }
    } catch (e) {
      isloading = false;
      notifyListeners();
      showCustomSnackBar(
        context, 
        EvaIcons.alertCircle, 
        'Error', 
        e.toString(), 
        Colors.red
      );
    }
  }

  Future<void> registerUser(context) async {
    try {
      isloading = true;
      notifyListeners();
      
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      var request = await post(Uri.parse("https://admin.kestrelvpn.com/api/signup"),
          headers: headers,
          body: jsonEncode({
            "name": usernameController.text.replaceAll(' ', ''),
            "email": emailController.text,
            "password": passwordController.text,
            "password_confirmation": passwordController.text,
          }));
          
      var data = jsonDecode(request.body);
      String message = data['message'].toString().replaceAll('[', '').replaceAll(']', '');
      
      if (data['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', emailController.text);
        await prefs.setString('password', passwordController.text);
        await prefs.setString('token', data['access_token']);
        
        showCustomSnackBar(
          context, 
          EvaIcons.checkmarkCircle2Outline,
          'Success',
          message,
          Colors.green
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogInPage()),
        );

        clearControllers();
        isloading = false;
        notifyListeners();
      } else {
        showCustomSnackBar(
          context,
          EvaIcons.alertCircle,
          'Error',
          message,
          Colors.red
        );
        clearControllers();
        isloading = false;
        notifyListeners();
      }
    } catch (e) {
      isloading = false;
      notifyListeners();
      showCustomSnackBar(
        context,
        EvaIcons.alertCircle,
        'Error',
        e.toString(),
        Colors.red
      );
    }
  }

  Future<void> logOut(BuildContext context) async {
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogInPage()),
          (route) => false
        );
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void clearControllers() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }
}
