import 'package:flutter/material.dart';
import '../Providers/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:krestelvpn/Widgets/customTextField.dart';

class ForgetPage extends StatelessWidget {
  const ForgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
        body: Container(
      color: Colors.black,
      child: Column(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
            ),
            Text(
              "Forgot Password",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              """Please enter your email we will send you \n password reset link to your email.""",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(
                height: 10,
              ),
              CustomTextField(
                controller: homeProvider.emailController,
                hintText: "Enter Your Email",
                obscureText: false,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          width: double.infinity,
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 12),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFFF335E), Color(0xFF0070FF)],
            ),
          ),
          child: Center(
            child: Text("Submit",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text("Back to login?",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 13,
              )),
        ),
      ]),
    ));
  }
}
