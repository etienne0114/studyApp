// lib/ui/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_scheduler/constants/app_colors.dart';
import 'package:study_scheduler/services/auth_service.dart';
import 'package:study_scheduler/ui/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;
  String _selectedLanguage = 'English';
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userData = authService.userData;
    
    final userName = userData?['name'] ?? 'Guest User';
    final userEmail = userData?['email'] ?? 'guest@example.com';
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Profile image
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        userName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // User details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _editProfile,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Settings section
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Theme settings
            Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      _showSettingsSavedMessage('Theme will be updated when you restart the app');
                    },
                    secondary: const Icon(Icons.brightness_4),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: Text(_selectedLanguage),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLanguageSelector,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Notification settings
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive app notifications'),
                    value: _pushNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _pushNotificationsEnabled = value;
                      });
                      _showSettingsSavedMessage('Push notification settings updated');
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive email reminders'),
                    value: _emailNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _emailNotificationsEnabled = value;
                      });
                      _showSettingsSavedMessage('Email notification settings updated');
                    },
                    secondary: const Icon(Icons.email),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // App info section
            const Text(
              'App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showAboutDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & Support coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: const Text('Rate the App'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rate the App feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Account actions
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy Policy coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
            
            // App version
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  void _editProfile() {
    // Show dialog to edit profile
    final nameController = TextEditingController(
      text: Provider.of<AuthService>(context, listen: false).userData?['name'] ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update profile
              if (nameController.text.isNotEmpty) {
                try {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  await authService.updateProfile({
                    'name': nameController.text.trim(),
                  });
                  
                  if (!mounted) return;
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showLanguageSelector() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              final isSelected = language == _selectedLanguage;
              
              return ListTile(
                title: Text(language),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = language;
                  });
                  Navigator.pop(context);
                  _showSettingsSavedMessage('Language updated to $_selectedLanguage');
                },
              );
            },
          ),
        ),
      ),
    );
  }
  
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Study Scheduler',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.calendar_today,
        size: 50,
        color: AppColors.primary,
      ),
      applicationLegalese: '© 2023 Study Scheduler Inc. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Study Scheduler is a comprehensive app designed to help students '
          'organize their study time efficiently and improve productivity. '
          'Create schedules, track progress, and access study materials all in one place.',
        ),
      ],
    );
  }
  
  void _handleLogout() async {
    // Show confirmation dialog
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    
    if (confirmLogout == true) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signOut();
        
        if (!mounted) return;
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: $e')),
        );
      }
    }
  }
  
  void _showSettingsSavedMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}