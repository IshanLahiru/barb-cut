import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 14)),
        toolbarHeight: 22,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Guest User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'guest@barbcut.app',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Account',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _buildTile(icon: Icons.edit, title: 'Edit Profile'),
          _buildTile(icon: Icons.payment, title: 'Payment Methods'),
          _buildTile(icon: Icons.history, title: 'Appointments'),
          const SizedBox(height: 20),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _buildTile(icon: Icons.notifications, title: 'Notifications'),
          _buildTile(icon: Icons.lock, title: 'Privacy & Security'),
          _buildTile(icon: Icons.palette, title: 'Appearance'),
          _buildTile(icon: Icons.help_outline, title: 'Help & Support'),
          const SizedBox(height: 20),
          _buildTile(
            icon: Icons.logout,
            title: 'Sign Out',
            onTap: () => context.read<AuthController>().logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 20, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
