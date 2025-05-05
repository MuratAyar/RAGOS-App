import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'sign_up_screen.dart'; // Needed for logout redirection

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedIndex = 0;
  final List<bool> _open = List<bool>.filled(4, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          children: [
            /// Avatar and Name
            Center(
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Murat Ayar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            /// Expansion Cards
            _buildExpansionTile(
              index: 0,
              title: 'Account',
              children: [
                _buildInfoTile('Email', 'denememurat@gmail.com'),
                _buildInfoTile('Phone', '+905317158068'),
              ],
            ),
            const SizedBox(height: 16),
            _buildExpansionTile(
              index: 1,
              title: 'Password',
              children: [
                ListTile(
                  title: Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Change password action
                      },
                      child: const Text('Change Password', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildExpansionTile(
              index: 2,
              title: 'Membership',
              children: [
                _buildInfoTile('Current Plan', 'Pro Plan - 6 hours remaining'),
                ListTile(
                  title: Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Upgrade plan action
                      },
                      child: const Text('Upgrade Your Plan', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildExpansionTile(
              index: 3,
              title: 'Caregiver',
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Caregiver',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Assigned to your Profile:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Ayse Demir',
                          style: TextStyle(
                            color: Color(0xFFFCC120),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCC120),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: _selectedIndex),
    );
  }

  /// --- Build ExpansionTile
  Widget _buildExpansionTile({
  required int index,
  required String title,
  required List<Widget> children,
}) {
  return Theme(
    data: Theme.of(context).copyWith(
      dividerColor: Colors.transparent,
      splashColor: Colors.transparent, // <--- put here inside ThemeData
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    ),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 24),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        initiallyExpanded: _open[index],
        onExpansionChanged: (open) {
          setState(() {
            _open[index] = open;
          });
        },
        children: children,
      ),
    ),
  );
}


  /// --- Build InfoTile inside dropdown
  Widget _buildInfoTile(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
