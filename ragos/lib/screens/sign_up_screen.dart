import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen_2.dart';

import '../core/services/auth_service.dart';


/// FIRST‑STEP REGISTRATION SCREEN – re‑validated email regex
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;


  String selectedCountryCode = '+90';
  String selectedCountryIsoCode = 'TR';
  late MaskTextInputFormatter phoneMask;

  @override
  void initState() {
    super.initState();
    phoneMask = MaskTextInputFormatter(
      mask: '(###) ###-##-##',
      filter: {'#': RegExp(r'[0-9]')},
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phoneNumber.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen2()));
    }
  }

  // ───────────────────────────────── helpers
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
        final value = v?.trim() ?? '';
        
        if (value.isEmpty) return 'Required';
        
        // Email validation (only if hint is 'Email')
        if (hint == 'Email' && 
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Invalid email';
        }
        
        // Password match check (only if hint is 'Confirm Password')
        if (hint == 'Confirm Password' && value != _password.text.trim()) {
          return 'Passwords do not match';
        }
        
        // Minimum password length (only if pwd=true)
        if (pwd && value.length < 6) return 'Password must be 6+ chars';
        
        return null; // Valid
      },
    );

  // ───────────────────────────────── UI
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final constrained = width < 420;
    

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
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
                          child: Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text('Sign Up', style: AppTextStyles.title),
                      ],
                    ),
                    const SizedBox(height: 32),

                    _field(_name, 'Full Name'),
                    const SizedBox(height: 16),

                    // Phone Number Field with Country Picker
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.inputBG,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CountryCodePicker(
                            initialSelection: 'TR',
                            favorite: ['TR'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            textStyle: AppTextStyles.input.copyWith(color: Colors.white),
                            dialogTextStyle: TextStyle(color: Colors.white),
                            searchStyle: TextStyle(color: Colors.white),
                            flagWidth: 24,
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.inputBG,
                            dialogBackgroundColor: AppColors.background,
                            onChanged: (CountryCode code) {
                              setState(() {
                                selectedCountryCode = code.dialCode ?? '+90';
                                selectedCountryIsoCode = code.code!.toUpperCase();
                                // Update mask based on country
                                if (selectedCountryIsoCode == 'TR') {
                                  phoneMask = MaskTextInputFormatter(
                                    mask: '(###) ###-##-##',
                                    filter: {'#': RegExp(r'[0-9]')},
                                  );
                                } else {
                                  phoneMask = MaskTextInputFormatter(
                                    mask: '#### ### ####',
                                    filter: {'#': RegExp(r'[0-9]')},
                                  );
                                }
                                // Apply new mask to current input
                                String currentDigits = _phoneNumber.text.replaceAll(RegExp(r'[^0-9]'), '');
                                _phoneNumber.text = phoneMask.maskText(currentDigits);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneNumber,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              phoneMask,
                            ],
                            style: AppTextStyles.input,
                            decoration: _decoration('Phone Number'),
                            validator: (value) {
                              final trimmedValue = value?.trim() ?? '';
                              if (trimmedValue.isEmpty) return 'Required';
                              String digits = trimmedValue.replaceAll(RegExp(r'[^0-9]'), '');
                              if (selectedCountryIsoCode == 'TR') {
                                if (digits.length != 10 || !digits.startsWith('5')) {
                                  return 'Invalid Turkish phone number';
                                }
                              } else {
                                if (digits.isEmpty || digits.length < 5 || digits.length > 15) {
                                  return 'Invalid phone number';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 16),
                    _field(_email, 'Email'),
                    const SizedBox(height: 16),
                    _field(_password, 'Password', pwd: true),
                    const SizedBox(height: 16),
                    _field(_confirm, 'Confirm Password', pwd: true),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                if (!(_formKey.currentState?.validate() ?? false)) return;

                                setState(() => _loading = true);

                                final authSvc = AuthService();
                                final user = await authSvc.signUp(
                                  fullName: _name.text.trim(),
                                  phone: _phoneNumber.text.trim(),
                                  email: _email.text.trim(),
                                  password: _password.text.trim(),
                                );

                                if (user != null) {
                                  Navigator.pushReplacementNamed(context, '/verify');
                                }

                                if (mounted) setState(() => _loading = false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            : Text('Next', style: AppTextStyles.button),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(children: const [
                      Expanded(child: Divider(color: Colors.white38)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('or', style: TextStyle(color: Colors.white70)),
                      ),
                      Expanded(child: Divider(color: Colors.white38)),
                    ]),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.lightBtn,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/google.svg', height: 18),
                            const SizedBox(width: 8),
                            const Text('Sign up with Google'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: Colors.white70)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                          child: Text('Login', style: AppTextStyles.link),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
