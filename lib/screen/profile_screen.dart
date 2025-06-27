import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_providers.dart';
import '../utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? _pickedImage;
  String? _avatarUrl;
  bool _isLoading = false;
  late TextEditingController _usernameController;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          _avatarUrl ??= user.avatar;
          _usernameController = TextEditingController(text: user.username);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showEditProfileDialog(context, authProvider, user);
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryColor,
                          child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                              ? (_avatarUrl!.startsWith('http')
                                  ? ClipOval(
                                      child: Image.network(
                                        _avatarUrl!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    )
                                  : ClipOval(
                                      child: Image.file(
                                        File(_avatarUrl!),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    ))
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Profile sections
                _buildProfileSection(
                  title: 'Account Information',
                  children: [
                    _buildProfileItem(
                      icon: Icons.person,
                      title: 'Username',
                      value: user.username,
                    ),
                    _buildProfileItem(
                      icon: Icons.email,
                      title: 'Email',
                      value: user.email,
                    ),
                    _buildProfileItem(
                      icon: Icons.calendar_today,
                      title: 'Member Since',
                      value: _formatDate(user.createdAt),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Actions section
                _buildProfileSection(
                  title: 'Actions',
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.edit, color: AppTheme.primaryColor),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showEditProfileDialog(context, authProvider, user);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings,
                          color: AppTheme.primaryColor),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showThemeDialog(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await authProvider.logout();
                                Navigator.pop(context);
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditProfileDialog(
      BuildContext context, AuthProvider authProvider, user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() {
                        _pickedImage = image;
                        _avatarUrl = image.path;
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryColor,
                    backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : (_avatarUrl != null && _avatarUrl!.startsWith('http'))
                            ? NetworkImage(_avatarUrl!) as ImageProvider
                            : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                ? FileImage(File(_avatarUrl!))
                                : null,
                    child: (_pickedImage == null &&
                            (_avatarUrl == null || _avatarUrl!.isEmpty))
                        ? const Icon(Icons.person,
                            size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    hintText: user.email ?? '',
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
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      String? avatarUrl = user.avatar;
                      if (_pickedImage != null) {
                        avatarUrl = _pickedImage!.path;
                      }
                      final success = await authProvider.updateProfile(
                        username: _usernameController.text.trim(),
                        avatar: avatarUrl,
                      );
                      setState(() => _isLoading = false);
                      if (success) {
                        setState(() {
                          // update tampilan profile utama
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update profile'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        AppThemeMode selected = themeProvider.themeMode;
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppThemeMode>(
                value: AppThemeMode.system,
                groupValue: selected,
                title: const Text('System Default'),
                onChanged: (val) {
                  themeProvider.setTheme(val!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<AppThemeMode>(
                value: AppThemeMode.light,
                groupValue: selected,
                title: const Text('Light'),
                onChanged: (val) {
                  themeProvider.setTheme(val!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<AppThemeMode>(
                value: AppThemeMode.dark,
                groupValue: selected,
                title: const Text('Dark'),
                onChanged: (val) {
                  themeProvider.setTheme(val!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
