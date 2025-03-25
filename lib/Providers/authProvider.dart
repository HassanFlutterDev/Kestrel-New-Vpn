import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:krestelvpn/Providers/homeProvider.dart';
import 'package:provider/provider.dart';
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

      var request =
          await post(Uri.parse("https://admin.kestrelvpn.com/api/login"),
              headers: headers,
              body: jsonEncode({
                "name": emailController.text,
                "password": passwordController.text,
              }));

      var data = jsonDecode(request.body);
      String message =
          data['message'].toString().replaceAll('[', '').replaceAll(']', '');

      if (data['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', emailController.text);
        await prefs.setString('password', passwordController.text);
        await prefs.setString('token', data['access_token']);

        showCustomSnackBar(context, EvaIcons.checkmarkCircle2Outline, 'Success',
            message, Colors.green);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false);
        clearControllers();

        isloading = false;
        notifyListeners();
      } else {
        showCustomSnackBar(
            context, EvaIcons.alertCircle, 'Error', message, Colors.red);
        isloading = false;
        notifyListeners();
      }
    } catch (e) {
      isloading = false;
      notifyListeners();
      showCustomSnackBar(
          context, EvaIcons.alertCircle, 'Error', e.toString(), Colors.red);
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

      var request =
          await post(Uri.parse("https://admin.kestrelvpn.com/api/signup"),
              headers: headers,
              body: jsonEncode({
                "name": usernameController.text.replaceAll(' ', ''),
                "email": emailController.text,
                "password": passwordController.text,
                "password_confirmation": passwordController.text,
              }));

      var data = jsonDecode(request.body);
      String message =
          data['message'].toString().replaceAll('[', '').replaceAll(']', '');

      if (data['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', emailController.text);
        await prefs.setString('password', passwordController.text);
        await prefs.setString('token', data['access_token']);

        showCustomSnackBar(context, EvaIcons.checkmarkCircle2Outline, 'Success',
            message, Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogInPage()),
        );

        clearControllers();
        isloading = false;
        notifyListeners();
      } else {
        showCustomSnackBar(
            context, EvaIcons.alertCircle, 'Error', message, Colors.red);
        isloading = false;
        log(message);
        notifyListeners();
      }
    } catch (e) {
      isloading = false;
      notifyListeners();
      showCustomSnackBar(
          context, EvaIcons.alertCircle, 'Error', e.toString(), Colors.red);
    }
  }

  Future<bool> deleteAccount(BuildContext context) async {
    try {
      isloading = true;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ); // Show a loading indicator
          });
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await delete(
        Uri.parse("https://admin.kestrelvpn.com/api/user/delete"),
        headers: headers,
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Clear all preferences and logout
        prefs.remove('isLoggedIn');
        prefs.remove('email');
        prefs.remove('password');
        prefs.remove('token');
        prefs.remove('selected_server_index');
        Navigator.pop(context);
        Provider.of<HomeProvider>(context, listen: false).selectedCurrentPlan =
            null;

        showCustomSnackBar(context, EvaIcons.checkmarkCircle2Outline, 'Success',
            'Account deleted successfully', Colors.green);

        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogInPage()),
          (route) => false,
        );

        isloading = false;
        notifyListeners();
        return true;
      } else {
        Navigator.pop(context);
        showCustomSnackBar(context, EvaIcons.alertCircle, 'Error',
            data['message'] ?? 'Failed to delete account', Colors.red);

        isloading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isloading = false;
      notifyListeners();
      Navigator.pop(context);

      showCustomSnackBar(
          context, EvaIcons.alertCircle, 'Error', e.toString(), Colors.red);
      return false;
    }
  }

  Future<void> logOut(BuildContext context) async {
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('isLoggedIn');
        prefs.remove('email');
        prefs.remove('password');
        prefs.remove('token');
        prefs.remove('selected_server_index');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogInPage()),
          (route) => false,
        );
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> forgotPassword(BuildContext context) async {
    try {
      isloading = true;
      notifyListeners();

      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var request = await post(
        Uri.parse("https://admin.kestrelvpn.com/api/reset-password"),
        headers: headers,
        body: jsonEncode({
          "email": emailController.text,
        }),
      );

      var data = jsonDecode(request.body);
      bool isSuccess = data['status'] ?? false;
      String message = isSuccess
          ? "We have sent you a reset link to your email"
          : (data['message']?.toString() ?? "Email not found");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF00406A),
            content: Container(
              height: 160,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    radius: 30,
                    child: Icon(
                      isSuccess
                          ? EvaIcons.emailOutline
                          : EvaIcons.alertTriangleOutline,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (isSuccess) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LogInPage(),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      isloading = false;
      notifyListeners();
    } catch (e) {
      isloading = false;
      notifyListeners();
      showCustomSnackBar(
        context,
        EvaIcons.alertCircle,
        'Error',
        e.toString(),
        Colors.red,
      );
    }
  }

  void clearControllers() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }
}
