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
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Darker background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "VPN Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Protocol Selection Section
            Consumer<VpnProvider>(
              builder: (context, vpnProvider, _) {
                return _buildSettingsCard(
                  title: "VPN Protocol",
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<VpnProtocol>(
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2A2A2A),
                      value: vpnProvider.protocol,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      onChanged: (VpnProtocol? newValue) {
                        if (newValue != null)
                          vpnProvider.changeProtocol(newValue);
                      },
                      items: VpnProtocol.values.map((VpnProtocol protocol) {
                        return DropdownMenuItem<VpnProtocol>(
                          value: protocol,
                          child: Text(
                            protocol == VpnProtocol.wireguard
                                ? 'WireGuard'
                                : 'IKev2',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            // Auto Connect Section
            Consumer<VpnProvider>(
              builder: (context, vpnProvider, _) {
                return _buildSettingsCard(
                  title: "Connection Settings",
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        title: 'Auto Connect',
                        subtitle: 'Automatically connect when app starts',
                        value: vpnProvider.isAutoConnectEnabled,
                        onChanged: (value) => vpnProvider.toggleAutoConnect(),
                      ),
                      const Divider(color: Color(0xFF3A3A3A), height: 1),
                      _buildSwitchTile(
                        title: 'Disconnect on Sleep',
                        subtitle: 'Disconnect VPN when device goes to sleep',
                        value: vpnProvider.disconnectOnSleep,
                        onChanged: (value) =>
                            vpnProvider.toggleDisconnectOnSleep(),
                      ),
                      SizedBox(
                        height: 16,
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: const Color.fromARGB(253, 0, 85, 197),
        inactiveTrackColor: Colors.grey.shade800,
      ),
    );
  }
}
