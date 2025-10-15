import 'package:expense_track/screens/category_management_page.dart';
import 'package:expense_track/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userEmail = authService.currentUser?.email ?? 'User';
    final userName =
        authService.currentUser?.displayName ?? userEmail.split('@')[0];

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final isDesktop = maxWidth >= 1100;
          final isTablet = maxWidth >= 600 && maxWidth < 1100;
          final horizontalPadding = isDesktop
              ? 48.0
              : isTablet
              ? 32.0
              : 16.0;
          final avatarRadius = isDesktop
              ? 80.0
              : isTablet
              ? 70.0
              : 60.0;
          final userNameFont = isDesktop
              ? 32.0
              : isTablet
              ? 26.0
              : 22.0;
          final emailFont = isDesktop
              ? 18.0
              : isTablet
              ? 17.0
              : 15.0;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 900 : 700),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isDesktop ? 48 : 32),

                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: avatarRadius * 0.6,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: isDesktop ? 24 : 16),

                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: userNameFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: emailFont,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: isDesktop ? 36 : 28),

                    // Menu Items
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding / 2,
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Account',
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            title: 'SettingscURRENCY',
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.import_export_outlined,
                            title: 'Export Data',
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.category_outlined,
                            title: 'Manage Categories',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CategoryManagementPage(),
                                ),
                              );
                            },
                          ),

                          // In your main screen somewhere
                          // ElevatedButton(
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => TestCloudinaryScreen(
                          //           userId: 'test_user_id',
                          //         ),
                          //       ),
                          //     );
                          //   },
                          //   child: Text('Test Cloudinary'),
                          // ),
                          const SizedBox(height: 12),

                          // push logout to bottom on taller screens
                          if (!isDesktop) const SizedBox(height: 8),

                          _buildMenuItem(
                            icon: Icons.logout,
                            title: 'Logout',
                            onTap: () async {
                              await authService.signOut();
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            isLogout: true,
                          ),

                          SizedBox(height: isDesktop ? 32 : 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.grey[700],
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isLogout ? Colors.red : Colors.grey[500],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }
}
