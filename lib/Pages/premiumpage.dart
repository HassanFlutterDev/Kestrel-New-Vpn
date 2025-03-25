// ignore_for_file: unrelated_type_equality_checks

import 'dart:developer';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:krestelvpn/Helper/snackbar.dart';
import 'package:krestelvpn/Pages/loginpage.dart';
import 'package:krestelvpn/Providers/homeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  // Track selected plan
  String? selectedPlanId;
  int selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Upgrade Plan",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Consumer<HomeProvider>(builder: (context, homeProvider, child) {
        if (homeProvider.isLoadingPlans) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                "assets/images/crown.png",
                scale: 2,
              ),
              const Text(
                "Upgrade to Pro Plan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/check-line.png",
                          scale: 4,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Access to all servers worldwide",
                          style:
                              TextStyle(color: Color(0xFFA1A1AC), fontSize: 14),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/check-line.png",
                          scale: 4,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Blistering Fast Internet Browsing",
                          style:
                              TextStyle(color: Color(0xFFA1A1AC), fontSize: 14),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/check-line.png",
                          scale: 4,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Unlimited Uploads/Downloads",
                          style:
                              TextStyle(color: Color(0xFFA1A1AC), fontSize: 14),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Dynamic plan list
              // Replace the spread operator and map with ListView.builder
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: homeProvider.plans.length,
                itemBuilder: (context, index) {
                  final plan = homeProvider.plans[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PlanContainer(
                      title: plan.name,
                      subtitle: plan.description,
                      price: homeProvider.products.length < index
                          ? "0"
                          : homeProvider.products[index].price,
                      period: plan.durationUnit,
                      planId: plan.id.toString(),
                      isSelected: selectedPlanId == plan.id.toString(),
                      onChanged: (value) {
                        setState(() {
                          selectedIndex = index; // Update the selected index
                          selectedPlanId = value! ? plan.id.toString() : null;
                        });
                      },
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          launchUrl(Uri.parse(
                              'https://kestrelvpn.com/privacy-policy-2/'));
                        },
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )),
                    TextButton(
                        onPressed: () {
                          launchUrl(Uri.parse(
                              'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                        },
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: selectedPlanId == null
                    ? null
                    : () async {
                        // Handle plan purchase
                        showDialog(
                            context: homeProvider.cont!,
                            barrierDismissible: false,
                            builder: (_) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ); // Show a loading indicator
                            });
                        var pref = await SharedPreferences.getInstance();
                        log(pref.getString('token').toString());
                        if (pref.getString('token') == null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LogInPage()));
                          showCustomSnackBar(context, EvaIcons.alertCircle,
                              'Error', 'Please login to continue', Colors.red);
                        } else {
                          final selectedPlan = homeProvider.plans.firstWhere(
                              (plan) => plan.id.toString() == selectedPlanId);
                          homeProvider.selectedPlanId =
                              selectedPlan.id.toString();
                          homeProvider.makePurchase(
                              homeProvider.products[selectedIndex]);
                        }
                        // TODO: Implement purchase logic
                      },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    gradient: selectedPlanId == null
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade700,
                              Colors.grey.shade500
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFFF335E), Color(0xFF0070FF)],
                          ),
                  ),
                  child: Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class PlanContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String period;
  final String planId;
  final bool isSelected;
  final Function(bool?) onChanged;

  const PlanContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.planId,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, homeProvider, child) {
      return Container(
        padding: const EdgeInsets.all(1),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFFFF335E), const Color(0xFF0070FF)]
                : [Colors.grey, Colors.grey],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$price",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  homeProvider.currentPlan == null
                      ? Checkbox(
                          value: isSelected,
                          onChanged: onChanged,
                          activeColor: const Color(0xFFFF335E),
                          checkColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        )
                      : homeProvider.currentPlan!.id == int.parse(planId)
                          ? Text('Already Purchased')
                          : Checkbox(
                              value: isSelected,
                              onChanged: onChanged,
                              activeColor: const Color(0xFFFF335E),
                              checkColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            )
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
