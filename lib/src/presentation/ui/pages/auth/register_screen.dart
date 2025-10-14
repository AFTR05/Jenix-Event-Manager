import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/core/validators/fields_validators.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/buttons/custom_red_button_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/inputs/custom_input_text_field_widget.dart';
import 'package:jenix_event_manager/src/routes_app.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _acceptTerms = false;
  bool disableValidationInPhone = true;
  String _phoneCode = "+507"; // Panama por defecto

  bool _loading = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final screenWidth = size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                tileMode: TileMode.clamp,
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                stops: [0.4, 0.75],
                colors: [
                  JenixColorsApp.loginBeginGradient,
                  JenixColorsApp.loginEndGradient,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Logo section
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/jenix_logo.svg',
                        width: screenWidth < 600 ? 100 : 120,
                        height: screenWidth < 600 ? 100 : 120,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),

                  // Form section
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 60 : 24,
                        vertical: 32,
                      ),
                      decoration: const BoxDecoration(
                        color: JenixColorsApp.backgroundWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 400 : double.infinity,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome text
                                const Text(
                                  'Create your account',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500,
                                    color: JenixColorsApp.subtitleColor,
                                    fontFamily: 'OpenSansHebrew',
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // First Name
                                CustomInputTextFieldWidget(
                                  controller: _firstNameController,
                                  labelTitle: "First Name",
                                  hintText: "Enter your first name",
                                  textInputType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  isRequired: true,
                                  errorText: _firstNameError,
                                  prefix: const Icon(
                                    Icons.person_outline,
                                    color: JenixColorsApp.greyColorIcon,
                                  ),
                                  validator: FieldsValidators.fieldIsRequired,
                                  onChanged: (_) {
                                    if (_firstNameError != null) {
                                      setState(() => _firstNameError = null);
                                    }
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Last Name
                                CustomInputTextFieldWidget(
                                  controller: _lastNameController,
                                  labelTitle: "Last Name",
                                  hintText: "Enter your last name",
                                  textInputType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  isRequired: true,
                                  errorText: _lastNameError,
                                  prefix: const Icon(
                                    Icons.person_outline,
                                    color: JenixColorsApp.greyColorIcon,
                                  ),
                                  validator: FieldsValidators.fieldIsRequired,
                                  onChanged: (_) {
                                    if (_lastNameError != null) {
                                      setState(() => _lastNameError = null);
                                    }
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Email
                                CustomInputTextFieldWidget(
                                  controller: _emailController,
                                  labelTitle: "Email",
                                  hintText: "Enter your email",
                                  textInputType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  isRequired: true,
                                  errorText: _emailError,
                                  prefix: const Icon(
                                    Icons.email_outlined,
                                    color: JenixColorsApp.greyColorIcon,
                                  ),
                                  validator: FieldsValidators.emailValidator,
                                  onChanged: (_) {
                                    if (_emailError != null) {
                                      setState(() => _emailError = null);
                                    }
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Phone Number
                                _buildPhoneField(),

                                const SizedBox(height: 20),

                                // Password
                                CustomInputTextFieldWidget(
                                  controller: _passwordController,
                                  labelTitle: "Password",
                                  hintText: "At least 6 characters",
                                  isPassword: true,
                                  textInputAction: TextInputAction.done,
                                  isRequired: true,
                                  errorText: _passwordError,
                                  validator: (value) =>
                                      FieldsValidators.passwordValidator(
                                        value,
                                        minLength: 6,
                                      ),
                                  onChanged: (_) {
                                    if (_passwordError != null) {
                                      setState(() => _passwordError = null);
                                    }
                                  },
                                  onFieldSubmitted: (_) => _registerAction(),
                                ),

                                const SizedBox(height: 16),

                                // Terms & Conditions
                                _buildTermsCheckbox(),

                                const SizedBox(height: 24),

                                // Register button
                                CustomRedButtonWidget(
                                  onPressed: _loading ? () {} : _registerAction,
                                  title: _loading
                                      ? "Creating..."
                                      : "Create Account",
                                  isLoading: _loading,
                                  icon: _loading ? null : Icons.person_add,
                                ),

                                const SizedBox(height: 24),

                                // Login link
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Already have an account? ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: JenixColorsApp.slateGray,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'OpenSansHebrew',
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            RoutesApp.login,
                                          );
                                        },
                                        child: const Text(
                                          'Log In',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: JenixColorsApp.primaryRed,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'OpenSansHebrew',
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                JenixColorsApp.primaryRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: SizedBox(
                    height: 48,
                    width: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // PHONE FIELD WIDGET
  // ============================================================================

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: JenixColorsApp.darkColorText,
              fontFamily: "OpenSansHebrew",
            ),
            children: [
              TextSpan(text: 'Phone Number'),
              TextSpan(
                text: ' (optional)',
                style: TextStyle(
                  color: JenixColorsApp.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: JenixColorsApp.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JenixColorsApp.inputBorder, width: 1),
          ),
          child: IntlPhoneField(
            controller: _phoneNumberController,
            disableLengthCheck: disableValidationInPhone,
            decoration: const InputDecoration(
              hintText: "Phone number",
              hintStyle: TextStyle(
                color: JenixColorsApp.placeholderColor,
                fontFamily: "OpenSansHebrew",
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            initialCountryCode: 'PA',
            dropdownIconPosition: IconPosition.trailing,
            style: const TextStyle(fontFamily: "OpenSansHebrew"),
            onChanged: (value) {
              setState(() {
                _phoneCode = value.countryCode; // incluye '+'
                disableValidationInPhone = value.number.isEmpty;
              });
            },
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TERMS CHECKBOX WIDGET
  // ============================================================================

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: JenixColorsApp.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: JenixColorsApp.subtitleColor,
                fontWeight: FontWeight.w400,
                fontFamily: 'OpenSansHebrew',
              ),
              children: [
                const TextSpan(text: 'I have read and agree to the '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: const TextStyle(
                    color: JenixColorsApp.primaryRed,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: JenixColorsApp.primaryRed,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _handleTermsTap,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy.',
                  style: const TextStyle(
                    color: JenixColorsApp.primaryRed,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: JenixColorsApp.primaryRed,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _handlePrivacyTap,
                ),
              ],
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // VALIDATION & ACTIONS
  // ============================================================================

  void _registerAction() {
    // Limpiar errores
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
    });

    // Validar términos
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept Terms & Privacy to continue.'),
          backgroundColor: JenixColorsApp.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validar campos
    final firstNameError = FieldsValidators.fieldIsRequired(
      _firstNameController.text,
    );
    final lastNameError = FieldsValidators.fieldIsRequired(
      _lastNameController.text,
    );
    final emailError = FieldsValidators.emailValidator(_emailController.text);
    final passwordError = FieldsValidators.passwordValidator(
      _passwordController.text,
      minLength: 6,
    );

    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        passwordError != null) {
      setState(() {
        _firstNameError = firstNameError;
        _lastNameError = lastNameError;
        _emailError = emailError;
        _passwordError = passwordError;
      });
      return;
    }

    // Si todo está bien, registrar
    _performRegistration();
  }

  Future<void> _performRegistration() async {
    setState(() => _loading = true);

    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final phoneRaw = _phoneNumberController.text.trim();
    final phone = phoneRaw.isEmpty ? null : '$_phoneCode$phoneRaw';

    //TODO: Lógica de registro real aquí
  }

  void _handleTermsTap() {
    // TODO: Navegar a términos y condiciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms and Conditions'),
        backgroundColor: JenixColorsApp.infoColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handlePrivacyTap() {
    // TODO: Navegar a política de privacidad
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Policy'),
        backgroundColor: JenixColorsApp.infoColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
