import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jenix_event_manager/src/core/validators/fields_validators.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/buttons/custom_button_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/form/custom_form_element.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/inputs/custom_auth_text_field_widget.dart';
import 'package:jenix_event_manager/src/routes_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jenix_event_manager/translations/locale_keys.g.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;
  bool disableValidationInPhone = true;
  String _phoneCode = "+57";
  bool _loading = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A2647),
                  Color(0xFF103E69),
                  Color(0xFF09131E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 80 : 24,
                  vertical: 40,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12263F).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Center(
                        child: Hero(
                          tag: 'app_logo',
                          child: SvgPicture.asset(
                            'assets/images/humboldt_logo.svg',
                            width: isMobile ? 70 : 90,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title and subtitle
                      Text(
                        LocaleKeys.registerWelcome.tr(namedArgs: {'name': ''}).replaceAll('{name}', ''),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'OpenSansHebrew',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocaleKeys.registerOpeningPrivacy.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9DA9B9),
                          fontFamily: 'OpenSansHebrew',
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Form fields
                      CustomFormElement(
                        labelTitle: LocaleKeys.authRegisterEmailHint.tr(),
                        isRequired: true,
                        errorText: _nameError,
                        widget: CustomAuthTextFieldWidget(
                          controller: _nameController,
                          hintText: "Ej: Camilo Correa",
                          prefix: const Icon(Icons.person_outline, color: Colors.white70),
                          keyboardType: TextInputType.name,
                          onChanged: (_) => setState(() => _nameError = null),
                        ),
                      ),

                      const SizedBox(height: 14),
                      CustomFormElement(
                        labelTitle: LocaleKeys.authRegisterEmailHint.tr(),
                        isRequired: true,
                        errorText: _emailError,
                        widget: CustomAuthTextFieldWidget(
                          controller: _emailController,
                          hintText: LocaleKeys.authRegisterEmailHint.tr(),
                          prefix: const Icon(Icons.email_outlined, color: Colors.white70),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() => _emailError = null),
                        ),
                      ),

                      const SizedBox(height: 14),
                      _buildPhoneField(),

                      const SizedBox(height: 14),
                      CustomFormElement(
                        labelTitle: LocaleKeys.authRegisterPasswordHint.tr(),
                        isRequired: true,
                        errorText: _passwordError,
                        widget: CustomAuthTextFieldWidget(
                          controller: _passwordController,
                          hintText: LocaleKeys.authRegisterPasswordHint.tr(),
                          isPasswordField: true,
                          prefix: const Icon(Icons.lock_outline, color: Colors.white70),
                          onChanged: (_) => setState(() => _passwordError = null),
                        ),
                      ),

                      const SizedBox(height: 14),
                      CustomFormElement(
                        labelTitle: LocaleKeys.authRegisterConfirmPasswordHint.tr(),
                        isRequired: true,
                        errorText: _confirmPasswordError,
                        widget: CustomAuthTextFieldWidget(
                          controller: _confirmPasswordController,
                          hintText: LocaleKeys.authRegisterConfirmPasswordHint.tr(),
                          isPasswordField: true,
                          prefix: const Icon(Icons.lock_person_outlined, color: Colors.white70),
                          onChanged: (_) => setState(() => _confirmPasswordError = null),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildTermsCheckbox(),

                      const SizedBox(height: 24),

                      // Submit
                      CustomButtonWidget(
                        onPressed: _loading ? () {} : _registerAction,
                        title: LocaleKeys.authRegisterLoginHere.tr(),
                        backgroundColor: const Color(0xFFBE1723),
                        isLoading: _loading,
                        icon: Icons.person_add_alt_1,
                      ),

                      const SizedBox(height: 32),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'OpenSansHebrew',
                              color: Colors.white70,
                            ),
                            children: [
                              TextSpan(text: LocaleKeys.authRegisterAlreadyHaveAccount.tr()),
                              TextSpan(
                                text: LocaleKeys.authRegisterLoginHere.tr(),
                                style: const TextStyle(
                                  color: Color(0xFFBE1723),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = _handleLogin,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          LocaleKeys.homeFooterCopyright.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loader overlay
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.registerPhoneOptionalLabel.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'OpenSansHebrew',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A2B44),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: IntlPhoneField(
            controller: _phoneNumberController,
            disableLengthCheck: disableValidationInPhone,
            initialCountryCode: 'CO',
            style: const TextStyle(color: Colors.white),
            dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Ej: 3101234567",
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) {
              setState(() {
                _phoneCode = value.countryCode;
                disableValidationInPhone = value.number.isEmpty;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          checkColor: Colors.white,
          onChanged: (v) => setState(() => _acceptTerms = v ?? false),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: LocaleKeys.authRegisterTermsPrefix.tr(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: LocaleKeys.authRegisterTerms.tr(),
                  style: const TextStyle(
                    color: Color(0xFFBE1723),
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _handleTermsTap,
                ),
                TextSpan(text: LocaleKeys.authRegisterAndThe.tr()),
                TextSpan(
                  text: LocaleKeys.authRegisterPrivacyPolicy.tr(),
                  style: const TextStyle(
                    color: Color(0xFFBE1723),
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _handlePrivacyTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // VALIDATION & ACTIONS (idéntico al tuyo)
  // ============================================================================

  void _registerAction() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (!_acceptTerms) {
      _showSnackBar(LocaleKeys.registerAcceptTermsError.tr(), color: Colors.redAccent);
      return;
    }

    final nameError = FieldsValidators.fieldIsRequired(_nameController.text);
    final emailError = FieldsValidators.emailValidator(_emailController.text);
    final passwordError =
        FieldsValidators.passwordValidator(_passwordController.text);
    String? confirmPasswordError;

    if (_confirmPasswordController.text != _passwordController.text) {
      confirmPasswordError = LocaleKeys.registerPasswordsNoMatch.tr();
    }

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      setState(() {
        _nameError = nameError;
        _emailError = emailError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
      });
      return;
    }

    _performRegistration();
  }

  Future<void> _performRegistration() async {
    setState(() => _loading = true);
    final authController = ref.read(authenticationControllerProvider);
    final fullPhone = '$_phoneCode${_phoneNumberController.text.trim()}';

    try {
      final result = await authController.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: fullPhone,
        role: 'user',
        rememberMe: true,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      result.fold(
        (failure) => _showSnackBar(LocaleKeys.registerErrorPrefix.tr(namedArgs: {'message': failure.message}), color: Colors.redAccent),
        (user) {
          _showSnackBar(LocaleKeys.registerWelcome.tr(namedArgs: {'name': user.name}));
          Navigator.pushReplacementNamed(context, RoutesApp.main);
        },
      );
    } catch (_) {
      setState(() => _loading = false);
      _showSnackBar(LocaleKeys.registerUnexpectedError.tr(), color: Colors.redAccent);
    }
  }

  void _handleLogin() {
    Navigator.pushReplacementNamed(context, RoutesApp.login);
  }

  void _handleTermsTap() {
    _showSnackBar(LocaleKeys.registerOpeningTerms.tr());
  }

  void _handlePrivacyTap() {
    _showSnackBar(LocaleKeys.registerOpeningPrivacy.tr());
  }

  void _showSnackBar(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
