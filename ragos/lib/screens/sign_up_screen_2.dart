import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'sign_in_screen.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// SECOND-STEP REGISTRATION SCREEN – fixed const‑list issue
class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({super.key});

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  final _formKey = GlobalKey<FormState>();
  final _kitchens = TextEditingController();
  final _bedrooms = TextEditingController();
  final _livingRooms = TextEditingController();
  final _extraRooms = TextEditingController();
  final _caregiverPhoneNumber = TextEditingController();
  String? _planPath;

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
    _kitchens.dispose();
    _bedrooms.dispose();
    _livingRooms.dispose();
    _extraRooms.dispose();
    _caregiverPhoneNumber.dispose();
    super.dispose();
  }

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

  Widget _numberField(TextEditingController ctl, String hint) => TextFormField(
        controller: ctl,
        keyboardType: TextInputType.number,
        style: AppTextStyles.input,
        decoration: _decoration(hint),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (int.tryParse(v.trim()) == null || int.parse(v.trim()) < 0) return 'Enter a valid number';
          return null;
        },
      );

  Future<void> _pickFile() async {
    setState(() => _planPath = 'floorplan.pdf');
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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
                        child: Icon(Icons.home, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text('Home Details', style: AppTextStyles.title),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _numberField(_kitchens, 'Number of Kitchens'),
                  const SizedBox(height: 16),
                  _numberField(_bedrooms, 'Number of Bedrooms'),
                  const SizedBox(height: 16),
                  _numberField(_livingRooms, 'Number of Living Rooms'),
                  const SizedBox(height: 16),
                  _numberField(_extraRooms, 'Number of Extra Rooms'),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.lightBtn,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.upload_file),
                      label: Text(_planPath ?? 'Upload floor plan (optional)'),
                      onPressed: _pickFile,
                    ),
                  ),
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
                                String currentDigits = _caregiverPhoneNumber.text.replaceAll(RegExp(r'[^0-9]'), '');
                                _caregiverPhoneNumber.text = phoneMask.maskText(currentDigits);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _caregiverPhoneNumber,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              phoneMask,
                            ],
                            style: AppTextStyles.input,
                            decoration: _decoration('Caregiver Phone Number'),
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

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _submit,
                      child: Text('Finish', style: AppTextStyles.button),
                    ),
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
