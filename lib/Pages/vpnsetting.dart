import 'package:flutter/material.dart';
import 'package:krestelvpn/Providers/vpnProvider.dart';
import 'package:provider/provider.dart';

class VpnSetting extends StatefulWidget {
  const VpnSetting({super.key});

  @override
  State<VpnSetting> createState() => _VpnSettingState();
}

class _VpnSettingState extends State<VpnSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text("VPN Settings",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
      ),
      body: Column(
        children: [
          Consumer<VpnProvider>(
            builder: (context, vpnProvider, child) {
              return SwitchListTile.adaptive(
                title: Text(
                  'Auto Connect',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                value: vpnProvider.isAutoConnectEnabled,
                inactiveTrackColor: Colors.grey,
                activeColor: Color.fromARGB(253, 0, 85, 197),
                onChanged: (bool value) {
                  vpnProvider.toggleAutoConnect();
                },
              );
            },
          ),
          Consumer<VpnProvider>(
            builder: (context, vpnProvider, child) {
              return SwitchListTile.adaptive(
                title: Text(
                  'Disconnect on Sleep',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                inactiveTrackColor: Colors.grey,
                activeColor: Color.fromARGB(253, 0, 85, 197),
                value: vpnProvider.disconnectOnSleep,
                onChanged: (bool value) {
                  vpnProvider.toggleDisconnectOnSleep();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
