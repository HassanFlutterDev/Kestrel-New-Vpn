import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:krestelvpn/Pages/premiumpage.dart';
import 'package:krestelvpn/Providers/homeProvider.dart';
import 'package:provider/provider.dart';

class ServersPage extends StatelessWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text("All locations",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFFF335E), Color(0xFF0070FF)],
              )),
              child: Center(
                child: Text(
                  "High-Speed | High-Performance | Stable Servers",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
              child: Text(
                "Free Servers",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Opacity(
                opacity: 0.2,
                child: Divider(
                  color: Color(0xFFD9D9D9),
                  height: 1.0,
                ),
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: homeProvider
                  .servers.length, // Adjust number of items as needed
              itemBuilder: (context, index) {
                var server = homeProvider.servers[index];
                return server['status'] != '0'
                    ? Container()
                    : Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              homeProvider.selectServer(index, context);
                              Navigator.pop(context);
                            },
                            child: CountryWidget(
                              countryName: server['name'],
                              imageData: server['image_url'],
                              location: server['sub_servers'][0]['name'],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
              },
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
              child: Text(
                "Premium Servers",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Opacity(
                opacity: 0.2,
                child: Divider(
                  color: Color(0xFFD9D9D9),
                  height: 1.0,
                ),
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: homeProvider
                  .servers.length, // Adjust number of items as needed
              itemBuilder: (context, index) {
                var server = homeProvider.servers[index];
                return server['status'] != '1'
                    ? Container()
                    : Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              log(homeProvider.isPremium.toString());
                              if (homeProvider.isPremium) {
                                homeProvider.selectServer(index, context);
                                Navigator.pop(context);
                              } else {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text(
                                      "Premium Server",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: const Text(
                                      "This server is only available for premium users. Upgrade to premium to access this server.",
                                      style: TextStyle(
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel",
                                            style: TextStyle(
                                              color: CupertinoColors.black,
                                            )),
                                      ),
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PremiumPage()));
                                        },
                                        child: const Text(
                                          "Upgrade",
                                          style: TextStyle(
                                            color: CupertinoColors.systemRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: CountryWidget(
                              countryName: server['name'],
                              imageData: server['image_url'],
                              location: server['sub_servers'][0]['name'],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CountryWidget extends StatelessWidget {
  final String imageData;
  final String countryName;
  final String location;
  const CountryWidget(
      {super.key,
      required this.imageData,
      required this.countryName,
      required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF335E),
              Color(0xFF0070FF),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(
              36), // Optional: if you want rounded corners
        ),
        child: Padding(
          padding: EdgeInsets.all(1), // This creates the border width
          child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black, // Inner container background color
                borderRadius: BorderRadius.circular(
                    36), // Should be less than outer radius
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: imageData,
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return CircularProgressIndicator();
                            },
                            errorWidget: (context, url, error) {
                              return Icon(Icons.error);
                            },
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            countryName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                          Text(
                            location,
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          )
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  )
                ],
              )),
        ));
  }
}

class ComingSoonCountry extends StatelessWidget {
  const ComingSoonCountry({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(
              36), // Optional: if you want rounded corners
        ),
        child: Padding(
          padding: EdgeInsets.all(1), // This creates the border width
          child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black, // Inner container background color
                borderRadius: BorderRadius.circular(
                    36), // Should be less than outer radius
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Image.asset(
                      "assets/images/canada.png",
                      scale: 2,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Germany",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                      Text(
                        "Free Server",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 160,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  )
                ],
              )),
        ));
  }
}
