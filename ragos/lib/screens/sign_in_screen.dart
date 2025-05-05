// lib/screens/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/services/auth_service.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  final _authSvc  = AuthService();

  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // ───────────────────────── helpers
  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.input.copyWith(color: Colors.white54),
        filled: true,
        fillColor: AppColors.inputBG,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _field(TextEditingController ctl, String hint, {bool pwd = false}) =>
      TextFormField(
        controller: ctl,
        obscureText: pwd,
        style: AppTextStyles.input,
        decoration: _decoration(hint),
        validator: (v) {
          final value = (v ?? '').trim();
          if (value.isEmpty) return 'Required';

          if (hint == 'Email' &&
              !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[A-Za-z]{2,7}$')
                  .hasMatch(value)) {
            return 'Invalid email';
          }
          if (pwd && value.length < 6) return '6+ chars';
          return null;
        },
      );

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      final user = await _authSvc.login(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user == null) {
        throw FirebaseAuthException(
            code: 'unknown', message: 'Login failed; please try again.');
      }

      if (!user.emailVerified) {
        // Go to verification screen
        Navigator.pushReplacementNamed(context, '/verify');
      } else {
        // Success → Home
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found'   => 'No user with that e-mail.',
        'wrong-password'   => 'Wrong password.',
        'invalid-credential' => 'Invalid credentials.',
        'too-many-requests'  => 'Too many attempts. Try later.',
        _ => e.message ?? 'Login error.'
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ───────────────────────── UI
  @override
  Widget build(BuildContext context) {
    final width      = MediaQuery.of(context).size.width;
    final constrained = width < 420;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constrained ? 320 : 400),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.inputBG,
                        child: Icon(Icons.lock, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text('Sign In', style: AppTextStyles.title),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _field(_email, 'Email'),
                  const SizedBox(height: 16),
                  _field(_password, 'Password', pwd: true),
                  const SizedBox(height: 32),

                  // ------- LOGIN BUTTON ---------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Login', style: AppTextStyles.button),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ------- “Create one” LINK ---------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, '/sign_up'),
                        child: Text('Create one', style: AppTextStyles.link),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
