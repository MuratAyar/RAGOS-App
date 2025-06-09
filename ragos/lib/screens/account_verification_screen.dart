import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() => _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  bool _waiting = false;
  final _auth = FirebaseAuth.instance;

  Future<void> _checkVerified() async {
    await _auth.currentUser!.reload();
    if (_auth.currentUser!.emailVerified) {
      await FirebaseFirestore.instance
          .doc('users/${_auth.currentUser!.uid}')
          .update({'verified': true});
      Navigator.pushReplacementNamed(context, '/sign_up_2');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail not verified yet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final constrained = width < 420;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify your e-mail'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title.copyWith(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constrained ? 320 : 400),
            child: Column(
              children: [
                const Icon(Icons.email_outlined, color: Colors.white, size: 120),
                const SizedBox(height: 32),
                const Text(
                  'We sent a verification link to your e-mail.\n'
                  'Open it, then tap “I verified”',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _waiting ? null : _checkVerified,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _waiting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('I Verified', style: AppTextStyles.button),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () async {
                    setState(() => _waiting = true);
                    await _auth.currentUser!.sendEmailVerification();
                    setState(() => _waiting = false);
                  },
                  child: const Text(
                    'Resend Verification E-mail',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
