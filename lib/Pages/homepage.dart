import 'package:flutter/material.dart';
import 'package:krestelvpn/Pages/premiumpage.dart';
import 'package:krestelvpn/Pages/serverspage.dart';
import 'package:krestelvpn/Providers/homeProvider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    final serversProvider = Provider.of<HomeProvider>(context, listen: false);
    serversProvider.getServers(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>  PremiumPage(),
            )),
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Image.asset(
                "assets/images/crown.png",
                scale: 5,
              ),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white), // Added this line
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                size: 32,
              ), // You can change this to any other icon
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.asset(
                  "assets/images/krestel.png",
                  scale: 5,
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Krestel VPN",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        shape: const Border(
          right: BorderSide(
            color: Colors.white,
            width: 0.0,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 45,
            ),
            Column(
              children: [
                Image.asset(
                  "assets/images/krestel.png",
                  scale: 2,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Krestel VPN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "The Ultimate Secure Browsing",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("New Features | Coming Soon",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(
                  height: 15,
                ),
                Divider(height: 0.0, color: Colors.white30),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/share.png",
                            scale: 1.8,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Share Us",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18),
                              ),
                              Text(
                                "Secure your close ones!",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/rateus.png",
                            scale: 1.8,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rate Us",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18),
                              ),
                              Text(
                                "Keep Us Motivated!",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/comments.png",
                            scale: 1.8,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Help Us Improve",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18),
                              ),
                              Text(
                                "Review us on PlayStore!",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/rateus.png",
                            scale: 1.8,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Privacy Policy",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18),
                              ),
                              Text(
                                "Read all terms & Conditions",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF000000)],
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.red),
              child: Center(
                  child: Text(
                "Status: Not Connected",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              )),
            ),
            SizedBox(
              height: 35,
            ),
            Text(
              "Welcome to Krestel vpn",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Tap the button Below To \n Connect With VPN",
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
            ),
            GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ServersPage(),
                    )),
                child: SelectLocation()),
          ],
        ),
      ),
    );
  }
}

class SelectLocation extends StatelessWidget {
  const SelectLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 99,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
          ),
          Image.asset(
            "assets/images/earth.png",
            scale: 1.8,
          ),
          SizedBox(
            width: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Text(
                    "Select Location",
                    style: TextStyle(
                        color: Color(0xFF202B47),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Tap to select country",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 25,
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
