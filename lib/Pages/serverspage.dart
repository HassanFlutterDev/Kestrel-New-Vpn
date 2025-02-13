import 'package:flutter/material.dart';
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
      body: Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
            child: Text(
              "Free Servers",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Opacity(
              opacity: 0.2,
              child: Divider(
                color: Color(0xFFD9D9D9),
                height: 1.0,
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: homeProvider
                  .servers.length, // Adjust number of items as needed
              itemBuilder: (context, index) {
                var server = homeProvider.servers[index];
                return Column(
                  children: [
                    CountryWidget(
                      countryName: server['name'],
                      imageData: server['image_url'],
                    ),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          //   child: Opacity(
          //     opacity: 0.2,
          //     child: Divider(
          //       color: Color(0xFFD9D9D9),
          //       height: 1.0,
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
          //   child: Text(
          //     "Coming Soon",
          //     style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         color: Colors.white,
          //         fontSize: 18),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          //   child: Opacity(
          //     opacity: 0.2,
          //     child: Divider(
          //       color: Color(0xFFD9D9D9),
          //       height: 1.0,
          //     ),
          //   ),
          // ),
          // SizedBox(height: 20),
          // ComingSoonCountry(),
          // SizedBox(height: 20),
          // ComingSoonCountry(),
          // SizedBox(height: 20),
          // ComingSoonCountry(),
        ],
      ),
    );
  }
}

class CountryWidget extends StatelessWidget {
  final String imageData;
  final String countryName;
  const CountryWidget(
      {super.key, required this.imageData, required this.countryName});

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
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Image.network(
                      imageData,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  SizedBox(
                    width: 230,
                    child: Column(
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
                          "Free server",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        )
                      ],
                    ),
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
