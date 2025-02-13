import 'package:flutter/material.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  // Track selected plan
  String selectedPlan = '';

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
      body: Column(
        children: [
          Image.asset(
            "assets/images/crown.png",
            scale: 2,
          ),
          const Text(
            "Upgrade to Premium Now",
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
                      "Enjoy surfing without annoying ads ",
                      style: TextStyle(color: Color(0xFFA1A1AC), fontSize: 14),
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
                      "Increase connection speed ",
                      style: TextStyle(color: Color(0xFFA1A1AC), fontSize: 14),
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
                      "Access all server worldwide",
                      style: TextStyle(color: Color(0xFFA1A1AC), fontSize: 14),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30,),
          PlanContainer(
            title: "Weekly Plan",
            price: 4.99,
            period: "Week",
            planId: "weekly",
            isSelected: selectedPlan == "weekly",
            onChanged: (value) {
              setState(() {
                selectedPlan = value! ? "weekly" : '';
              });
            },
          ),
          SizedBox(
            height: 10,
          ),
          PlanContainer(
            title: "Monthly Plan",
            price: 14.99,
            period: "Month",
            planId: "monthly",
            isSelected: selectedPlan == "monthly",
            onChanged: (value) {
              setState(() {
                selectedPlan = value! ? "monthly" : '';
              });
            },
          ),
          SizedBox(
            height: 10,
          ),
          PlanContainer(
            title: "Yearly Plan",
            price: 79.99,
            period: "Year",
            planId: "yearly",
            isSelected: selectedPlan == "yearly",
            onChanged: (value) {
              setState(() {
                selectedPlan = value! ? "yearly" : '';
              });
            },
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF335E), Color(0xFF0070FF)],
              ),
            ),
            child: const Center(
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
          )
        ],
      ),
    );
  }
}

class PlanContainer extends StatelessWidget {
  final String title;
  final double price;
  final String period;
  final String planId;
  final bool isSelected;
  final Function(bool?) onChanged;

  const PlanContainer({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.planId,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  side: const BorderSide(color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Text(
                "\$ $price / $period",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
