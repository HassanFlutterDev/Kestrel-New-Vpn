// ignore_for_file: unnecessary_string_interpolations

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:krestelvpn/Pages/accountInfo.dart';
import 'package:krestelvpn/Pages/deleteAccount.dart';
import 'package:krestelvpn/Pages/premiumpage.dart';
import 'package:krestelvpn/Pages/serverspage.dart';
import 'package:krestelvpn/Pages/speedTest.dart';
import 'package:krestelvpn/Pages/vpnsetting.dart';
import 'package:krestelvpn/Providers/authProvider.dart';
import 'package:krestelvpn/Providers/homeProvider.dart';
import 'package:krestelvpn/Providers/vpnProvider.dart';
import 'package:krestelvpn/Widgets/connectionTimer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    vpnProvider.getCurrentState(); // Get initial VPN state
    vpnProvider.initializeStateListener(context);
    homeProvider.selectBuildContext = context;
    homeProvider.getPremiumStatus(context);
    homeProvider.getAllPlans(context);
    homeProvider.getUserData(context);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final vpnProvider = Provider.of<VpnProvider>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PremiumPage(),
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
                "Kestrel VPN",
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
                    "Kestrel VPN",
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
                  Divider(height: 0.0, color: Colors.white30),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _isLoggedIn == false
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AccountInfoScreen(),
                                  ));
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.person,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Account Info",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          "View your account details",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                        SizedBox(
                          height: _isLoggedIn ? 35 : 0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SpeedTestScreen(),
                            ));
                          },
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.speedometer,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Speed Test",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    "Check your internet speed",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => VpnSetting(),
                            ));
                          },
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.settings,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "VPN Settings",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    "Change VPN Settings",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse(
                                'https://kestrelvpn.com/privacy-policy-2/'));
                          },
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.shield,
                                color: Colors.white,
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
                                    "Privacy policy of kestrel vpn",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        GestureDetector(
                          onTap: () {
                            authProvider.logOut(context);
                            var homeProvider = Provider.of<HomeProvider>(
                                context,
                                listen: false);
                            var vpnProvider = Provider.of<VpnProvider>(context,
                                listen: false);
                            homeProvider.selectedCurrentPlan = null;
                            vpnProvider.disconnect();
                          },
                          child: Row(
                            children: [
                              Icon(
                                _isLoggedIn ? Icons.logout : Icons.login,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isLoggedIn ? "Log Out" : "Log In",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    _isLoggedIn
                                        ? "Log Out of your account"
                                        : "Log in to your account",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        !_isLoggedIn
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return DeleteAccountPage();
                                  }));
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.delete,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Delete Account",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          "Delete Your Account",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
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
              // Replace your existing Container with status text
              Consumer<VpnProvider>(
                builder: (context, vpnProvider, child) {
                  return GestureDetector(
                    onTap: () {
                      vpnProvider.getCurrentState();
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: vpnProvider.state == VpnState.connected
                              ? Colors.transparent
                              : vpnProvider.state == VpnState.connecting
                                  ? Color.fromARGB(255, 206, 197, 136)
                                  : Colors.red,
                          border: vpnProvider.state == VpnState.connecting ||
                                  vpnProvider.state == VpnState.disconnecting
                              ? null
                              : vpnProvider.state == VpnState.connected
                                  ? GradientBoxBorder(
                                      gradient: LinearGradient(colors: [
                                        Color(0xFFFF477E),
                                        Color(0xFF477EFF),
                                      ]),
                                      width: 2,
                                    )
                                  : null),
                      child: Center(
                          child: Text(
                        "Status: ${vpnProvider.state == VpnState.disconnecting ? 'Disconnecting' : vpnProvider.state == VpnState.connecting ? 'Connecting' : vpnProvider.state == VpnState.connected ? 'Connected' : 'Disconnected'}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 35,
              ),
              Consumer2<VpnProvider, HomeProvider>(
                  builder: (context, vpnProvider, homeProvider, child) {
                return Text(
                  vpnProvider.state == VpnState.connecting ||
                          vpnProvider.state == VpnState.disconnecting
                      ? 'Please Hold On'
                      : vpnProvider.state == VpnState.connected
                          ? 'Connected to ${homeProvider.servers[homeProvider.selectedServerIndex]['name']}'
                          : 'Welcome to Kestrel VPN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFCFDFF),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.49,
                  ),
                );
              }),
              SizedBox(
                height: 20,
              ),

              // Add bytes in and out display
              Consumer<VpnProvider>(
                builder: (context, vpnProvider, child) {
                  if (vpnProvider.state == VpnState.connected) {
                    return Column(
                      children: [
                        ConnectionTimer(),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/download.png',
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${vpnProvider.bytesIn} Kbps',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/upload.png',
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${vpnProvider.bytesOut} Kbps',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Text(
                      vpnProvider.state == VpnState.disconnecting
                          ? 'Disconnecting...'
                          : vpnProvider.state == VpnState.connecting
                              ? 'Connecting...'
                              : vpnProvider.state == VpnState.connected
                                  ? 'While we connect to a high-\nspeed server'
                                  : 'Tap The Button Below To \n Connect With VPN',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    );
                  }
                },
              ),
              Consumer<VpnProvider>(builder: (context, vpnProvider, child) {
                return SizedBox(
                  height: vpnProvider.state == VpnState.connecting ||
                          vpnProvider.state == VpnState.disconnecting
                      ? 40
                      : vpnProvider.state == VpnState.connected
                          ? 40
                          : 20,
                );
              }),
              // Replace your existing GestureDetector with this:
              Consumer<VpnProvider>(
                builder: (context, vpnProvider, child) {
                  return GestureDetector(
                    onTap: () async {
                      log(vpnProvider.state.toString());
                      if (vpnProvider.state == VpnState.connected ||
                          vpnProvider.state == VpnState.connecting) {
                        await vpnProvider.disconnect();
                      } else if (vpnProvider.state == VpnState.disconnected ||
                          vpnProvider.state == VpnState.error) {
                        // You might want to handle server selection here
                        log('Connecting to server');
                        var serverProvider =
                            Provider.of<HomeProvider>(context, listen: false);
                        await vpnProvider.connect(
                          server: serverProvider
                                  .servers[serverProvider.selectedServerIndex]
                              ['sub_servers'][0]['ip_address'],
                          username: serverProvider
                                  .servers[serverProvider.selectedServerIndex]
                              ['sub_servers'][0]['ipsec_user'],
                          password: serverProvider
                                  .servers[serverProvider.selectedServerIndex]
                              ['sub_servers'][0]['ipsec_password'],
                          secret: serverProvider
                                  .servers[serverProvider.selectedServerIndex]
                              ['sub_servers'][0]['ipsec_key'],
                          userId: serverProvider.deviceId
                              .toString(), // Replace with actual user ID
                          address: serverProvider
                                  .servers[serverProvider.selectedServerIndex]
                              ['sub_servers'][0]['wg_panel_address'],
                          wgPassword: serverProvider
                                  .servers[serverProvider.selectedServerIndex]
                              ['sub_servers'][0]['wg_panel_password'],
                          context: context,
                        );
                      }
                    },
                    child: VpnButton(
                      stage: vpnProvider.state == VpnState.connecting ||
                              vpnProvider.state == VpnState.disconnecting
                          ? 'connecting'
                          : vpnProvider.state == VpnState.connected
                              ? 'connected'
                              : 'disconnected',
                    ),
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              Consumer<VpnProvider>(
                builder: (context, vpnProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Current IP: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${vpnProvider.currentIp}',
                        style: TextStyle(
                          color: vpnProvider.state == VpnState.connected
                              ? Colors.green
                              : Color.fromARGB(255, 217, 42, 80),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 6,
              ),
              GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ServersPage(),
                      )),
                  child: SelectLocation()),
            ],
          ),
        ),
      ),
    );
  }
}

class VpnButton extends StatelessWidget {
  final String stage;

  VpnButton({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 233,
          height: 110,
          decoration: BoxDecoration(
            color: Color.fromARGB(0, 197, 197, 197),
          ),
          // Gradient for connect,
          child: Center(
            child: Container(
              width: 228,
              height: 88,
              decoration: _getBackborder(stage),
              child: Center(
                child: Container(
                  width: 226,
                  height: 86,
                  decoration: _getBackgroundDecoration(stage),
                ),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          left: stage == 'connecting' || stage == 'connected' ? 135 : 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 97,
            height: 97,
            clipBehavior: Clip.antiAlias,
            decoration: _getButtonDecoration(stage),
            child: Padding(
              padding: const EdgeInsets.all(19.0),
              child: _getIcon(stage),
            ),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _getBackborder(String stage) {
  switch (stage) {
    case 'connecting':
      return BoxDecoration(
        color: Color(0xFFFFDD00),
        borderRadius: BorderRadius.circular(100), // Solid color for connecting
      );
    case 'connected':
      return BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 217, 42, 80),
              Color.fromARGB(253, 0, 85, 197)
            ],
          )); //
    default:
      return BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: const Color(0xFFC5C5C5), // Solid color for default
      );
  }
}

// Method to get background decoration with gradient for connected case
BoxDecoration _getBackgroundDecoration(String stage) {
  switch (stage) {
    case 'connecting':
      return BoxDecoration(
        color: Color(0xFFFDF8D9),
        borderRadius: BorderRadius.circular(100), // Solid color for connecting
      );
    case 'connected':
      return BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 129, 25, 48),
            Color.fromARGB(255, 0, 58, 134),
          ],
        ), // Gradient for connected
      );
    default:
      return BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: const Color(0xFFC5C5C5), // Solid color for default
      );
  }
}

// Color of the toggle button
BoxDecoration _getButtonDecoration(String stage) {
  switch (stage) {
    case 'connecting':
      return BoxDecoration(
          color: Color(0xFFFFDD00), // Solid color for connecting
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(62, 26, 26, 26),
              blurRadius: 0.5,
              offset: Offset(0, 0),
              spreadRadius: 2,
            ),
          ]);
    case 'connected':
      return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF325D),
              Color(0xFF006FFF),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(62, 26, 26, 26),
              blurRadius: 0.5,
              offset: Offset(0, 0),
              spreadRadius: 2,
            ),
          ]);
    default:
      return BoxDecoration(
          color: const Color(0xFFD9D9D9), // Solid color for default
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(62, 26, 26, 26),
              blurRadius: 0.5,
              offset: Offset(0, 0),
              spreadRadius: 2,
            ),
          ]);
  }
}

// Border color for the button and track
// Color _getBorderColor(String stage) {
//   switch (stage) {
//     case 'connecting':
//       return Color(0xFFFFDD00); // Orange for connecting
//     case 'connected':
//       return Colors.green; // Green for connected
//     default:
//       return Colors.white; // White for default
//   }
// }

Color _getmainBorderColor(String stage) {
  switch (stage) {
    case 'connecting':
      return Color(0xFFFFDD00); // Orange for connecting
    case 'connected':
      return Colors.green; // Green for connected
    default:
      return Colors.white; // White for default
  }
}

// Icon inside the toggle button
Widget _getIcon(String stage) {
  switch (stage) {
    case 'connecting':
      return Image.asset(
        'assets/images/klogo.png', // Replace with your actual asset path
        width: 45,
        height: 45,
        color: Colors.white, // Optional icon tint
      ); // Icon for connecting
    case 'connected':
      return Image.asset(
        'assets/images/klogo.png', // Replace with your actual asset path
        width: 45,
        height: 45,
        color: Colors.white, // Optional icon tint
      ); // Icon for connected
    default:
      return Image.asset(
        'assets/images/klogo.png', // Replace with your actual asset path
        width: 45,
        height: 45,
        color: Color(0xFFC5C5C5), // Optional icon tint
      ); // Icon for default
  }
}

class SelectLocation extends StatelessWidget {
  const SelectLocation({super.key});

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<HomeProvider>(context);
    return Consumer<HomeProvider>(builder: (context, serverProvider, child) {
      return Container(
        width: MediaQuery.of(context).size.width - 99,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: serverProvider.servers.isEmpty
                    ? ''
                    : serverProvider.servers[serverProvider.selectedServerIndex]
                        ['image_url'],
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
                      serverProvider.servers.isEmpty
                          ? ''
                          : serverProvider
                                  .servers[serverProvider.selectedServerIndex]
                              ['name'],
                      style: TextStyle(
                          color: Color(0xFF202B47),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      serverProvider.servers.isEmpty
                          ? ''
                          : serverProvider
                                  .servers[serverProvider.selectedServerIndex]
                              ['sub_servers'][0]['name'],
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
    });
  }
}
