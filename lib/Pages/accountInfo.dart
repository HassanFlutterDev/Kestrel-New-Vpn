import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krestelvpn/Providers/homeProvider.dart';
import 'package:intl/intl.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Account Info",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.isLoadingUser) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final userData = homeProvider.userData;
          if (userData == null) {
            return const Center(
              child: Text(
                'No account information available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  'Account Details',
                  [
                    _buildInfoRow('Username', userData['name'] ?? 'N/A'),
                    _buildInfoRow('Email', userData['email'] ?? 'N/A'),
                    _buildInfoRow(
                        'ID', "User" + userData['id'].toString() ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Subscription Details',
                  [
                    _buildInfoRow(
                      'Premium Status',
                      homeProvider.isPremium ? 'Premium' : 'Free User',
                    ),
                    if (homeProvider.isPremium) ...[
                      _buildInfoRow(
                        'Subscription Type',
                        homeProvider.isLifetime ? 'Lifetime' : 'Time-limited',
                      ),
                      _buildInfoRow(
                        'Current Plan',
                        homeProvider.currentPlan?.name ?? 'N/A',
                      ),
                      if (!homeProvider.isLifetime) ...[
                        _buildInfoRow(
                          'Expires On',
                          homeProvider.expiryDate != null
                              ? DateFormat('MMM dd, yyyy')
                                  .format(homeProvider.expiryDate!)
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          'Days Remaining',
                          homeProvider.expiryDate != null
                              ? '${homeProvider.expiryDate!.difference(DateTime.now()).inDays}'
                              : 'N/A',
                        ),
                      ],
                    ],
                    if (homeProvider.currentPlan != null) ...[
                      _buildInfoRow(
                        'Plan Price',
                        '\$${double.parse(homeProvider.currentPlan!.price) - 0.01}',
                      ),
                      _buildInfoRow(
                        'Plan Duration',
                        '${homeProvider.currentPlan!.duration} ${homeProvider.currentPlan!.durationUnit}',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
