import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/premium_user.dart';
import '../services/premium_service.dart';
import '../services/firebase_service.dart';

/// Admin email yang diizinkan akses panel ini
const adminEmails = ['leimportant@gmail.com'];

class AdminScreen extends StatelessWidget {
  AdminScreen({super.key});
  final _premiumService = PremiumService();
  final _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            tooltip: 'Seed Vendor Data',
            onPressed: () async {
              final count = await _firebaseService.seedVendorData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(count > 0 ? '$count vendor berhasil ditambahkan!' : 'Data vendor sudah ada.')),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PremiumUser>>(
        stream: _premiumService.getAllRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('Belum ada request premium.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) => _UserTile(user: users[i], service: _premiumService),
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final PremiumUser user;
  final PremiumService service;
  const _UserTile({required this.user, required this.service});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm', 'id');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive ? Colors.green : Colors.orange,
          child: Icon(
            user.isActive ? Icons.verified : Icons.pending,
            color: Colors.white,
          ),
        ),
        title: Text(user.name ?? user.uid),
        subtitle: Text(
          '${user.email ?? "-"}\n'
          'Request: ${user.requestedAt != null ? dateFormat.format(user.requestedAt!) : "-"}',
        ),
        isThreeLine: true,
        trailing: user.isActive
            ? TextButton(
                onPressed: () => service.deactivatePremium(user.uid),
                child: const Text('Nonaktifkan', style: TextStyle(color: Colors.red)),
              )
            : FilledButton(
                onPressed: () => service.activatePremium(user.uid),
                child: const Text('Approve'),
              ),
      ),
    );
  }
}
