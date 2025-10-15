import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/core/validators/fields_validators.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/buttons/custom_button_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/form/custom_form_element.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/inputs/custom_auth_text_field_widget.dart';
import 'package:jenix_event_manager/src/routes_app.dart';

/// RegisterScreen - Alexander von Humboldt Event Manager
///
/// **Autor:** AFTR05
/// **Última modificación:** 2025-10-15 20:09:01 UTC
/// **Versión:** 2.0.0
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // ============================================================================
  // CONTROLLERS & STATE
  // ============================================================================

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _acceptTerms = false;
  bool disableValidationInPhone = true;
  String _phoneCode = "+57"; // Colombia por defecto (Humboldt)

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
    final isMobile = size.width < 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ============================================================================
          // GRADIENT BACKGROUND
          // ============================================================================
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        JenixColorsApp.darkBackground, // #1E1E1E
                        JenixColorsApp.darkGray, // #242425
                      ]
                    : [
                        JenixColorsApp.loginBeginGradient, // #003A70
                        JenixColorsApp.loginEndGradient, // #1565C0
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ============================================================================
                  // LOGO SECTION
                  // ============================================================================
                  SizedBox(
                    height: isMobile ? 100 : 120,
                    child: Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: SvgPicture.asset(
                          'assets/images/humboldt_logo.svg',
                          width: isMobile ? 70 : 90,
                          height: isMobile ? 70 : 90,
                          colorFilter: ColorFilter.mode(
                            isDark
                                ? JenixColorsApp.primaryBlueLight
                                : JenixColorsApp.backgroundWhite,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ============================================================================
                  // FORM SECTION
                  // ============================================================================
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 60 : 24,
                        vertical: isMobile ? 16 : 24,
                      ),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: JenixColorsApp.shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 450 : double.infinity,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome text
                                Text(
                                  'Create your account',
                                  style: TextStyle(
                                    fontSize: isMobile ? 22 : 26,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? JenixColorsApp.backgroundWhite
                                        : JenixColorsApp.primaryBlue,
                                    fontFamily: 'OpenSansHebrew',
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Join Alexander von Humboldt University',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? JenixColorsApp.lightGray
                                        : JenixColorsApp.subtitleColor,
                                    fontFamily: 'OpenSansHebrew',
                                  ),
                                ),
                                SizedBox(height: isMobile ? 20 : 28),

                                // ✅ FIRST NAME con CustomFormElement
                                CustomFormElement(
                                  labelTitle: "First Name",
                                  isRequired: true,
                                  errorText: _firstNameError,
                                  widget: CustomAuthTextFieldWidget(
                                    controller: _firstNameController,
                                    hintText: "Enter your first name",
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    prefix: Icon(
                                      Icons.person_outline,
                                      color: isDark
                                          ? JenixColorsApp.lightGray
                                          : JenixColorsApp.greyColorIcon,
                                      size: 20,
                                    ),
                                    validator: FieldsValidators.fieldIsRequired,
                                    onChanged: (_) {
                                      if (_firstNameError != null) {
                                        setState(() => _firstNameError = null);
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // ✅ LAST NAME con CustomFormElement
                                CustomFormElement(
                                  labelTitle: "Last Name",
                                  isRequired: true,
                                  errorText: _lastNameError,
                                  widget: CustomAuthTextFieldWidget(
                                    controller: _lastNameController,
                                    hintText: "Enter your last name",
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    prefix: Icon(
                                      Icons.person_outline,
                                      color: isDark
                                          ? JenixColorsApp.lightGray
                                          : JenixColorsApp.greyColorIcon,
                                      size: 20,
                                    ),
                                    validator: FieldsValidators.fieldIsRequired,
                                    onChanged: (_) {
                                      if (_lastNameError != null) {
                                        setState(() => _lastNameError = null);
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // ✅ EMAIL con CustomFormElement
                                CustomFormElement(
                                  labelTitle: "Email",
                                  isRequired: true,
                                  errorText: _emailError,
                                  widget: CustomAuthTextFieldWidget(
                                    controller: _emailController,
                                    hintText: "your.email@cue.edu.co",
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    prefix: Icon(
                                      Icons.email_outlined,
                                      color: isDark
                                          ? JenixColorsApp.lightGray
                                          : JenixColorsApp.greyColorIcon,
                                      size: 20,
                                    ),
                                    validator: FieldsValidators.emailValidator,
                                    onChanged: (_) {
                                      if (_emailError != null) {
                                        setState(() => _emailError = null);
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Phone Number (mantiene estilo manual)
                                _buildPhoneField(isDark),

                                const SizedBox(height: 14),

                                // ✅ PASSWORD con CustomFormElement
                                CustomFormElement(
                                  labelTitle: "Password",
                                  isRequired: true,
                                  errorText: _passwordError,
                                  widget: CustomAuthTextFieldWidget(
                                    controller: _passwordController,
                                    hintText: "At least 6 characters",
                                    isPasswordField: true,
                                    textInputAction: TextInputAction.done,
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
                                ),

                                const SizedBox(height: 12),

                                // Terms & Conditions
                                _buildTermsCheckbox(isDark),

                                const SizedBox(height: 20),

                                // Register button
                                CustomButtonWidget(
                                  onPressed: _loading ? () {} : _registerAction,
                                  title: "Create Account",
                                  backgroundColor: isDark
                                      ? JenixColorsApp.primaryBlueLight
                                      : JenixColorsApp.buttonPrimary,
                                  isLoading: _loading,
                                  icon: _loading
                                      ? null
                                      : Icons.person_add_rounded,
                                ),

                                const SizedBox(height: 16),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: isDark
                                            ? JenixColorsApp.grayColor
                                            : JenixColorsApp.inputBorder,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? JenixColorsApp.lightGray
                                              : JenixColorsApp.subtitleColor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'OpenSansHebrew',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: isDark
                                            ? JenixColorsApp.grayColor
                                            : JenixColorsApp.inputBorder,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Login link
                                Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account? ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? JenixColorsApp.lightGray
                                              : JenixColorsApp.slateGray,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'OpenSansHebrew',
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _handleLogin,
                                        borderRadius: BorderRadius.circular(4),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          child: Text(
                                            'Log In',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'OpenSansHebrew',
                                              decoration:
                                                  TextDecoration.underline,
                                              color: isDark
                                                  ? JenixColorsApp
                                                        .primaryBlueLight
                                                  : JenixColorsApp.primaryBlue,
                                              decorationColor: isDark
                                                  ? JenixColorsApp
                                                        .primaryBlueLight
                                                  : JenixColorsApp.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Footer
                                Center(
                                  child: Text(
                                    '© 2025 Alexander von Humboldt',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? JenixColorsApp.grayColor
                                          : JenixColorsApp.lightGray,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'OpenSansHebrew',
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
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

          // ============================================================================
          // LOADING OVERLAY
          // ============================================================================
          if (_loading)
            Positioned.fill(
              child: Container(
                color: JenixColorsApp.overlayColor,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            JenixColorsApp.backgroundWhite,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Creating your account...',
                        style: TextStyle(
                          color: JenixColorsApp.backgroundWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'OpenSansHebrew',
                        ),
                      ),
                    ],
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

  Widget _buildPhoneField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? JenixColorsApp.backgroundWhite
                  : JenixColorsApp.darkColorText,
              fontFamily: "OpenSansHebrew",
            ),
            children: [
              const TextSpan(text: 'Phone Number'),
              TextSpan(
                text: ' (optional)',
                style: TextStyle(
                  color: isDark
                      ? JenixColorsApp.lightGray
                      : JenixColorsApp.secondaryTextColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Container
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? JenixColorsApp.darkGray
                : JenixColorsApp.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? JenixColorsApp.grayColor
                  : JenixColorsApp.inputBorder,
              width: 1.5,
            ),
          ),
          child: IntlPhoneField(
            controller: _phoneNumberController,
            disableLengthCheck: disableValidationInPhone,
            decoration: InputDecoration(
              hintText: "Phone number",
              hintStyle: TextStyle(
                color: isDark
                    ? JenixColorsApp.lightGray
                    : JenixColorsApp.placeholderColor,
                fontFamily: "OpenSansHebrew",
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            initialCountryCode: 'CO',
            dropdownIconPosition: IconPosition.trailing,
            dropdownIcon: Icon(
              Icons.arrow_drop_down,
              color: isDark
                  ? JenixColorsApp.lightGray
                  : JenixColorsApp.greyColorIcon,
            ),
            flagsButtonPadding: const EdgeInsets.only(left: 12),
            style: TextStyle(
              fontFamily: "OpenSansHebrew",
              fontSize: 14,
              color: isDark
                  ? JenixColorsApp.backgroundWhite
                  : JenixColorsApp.darkColorText,
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

  // ============================================================================
  // TERMS CHECKBOX WIDGET
  // ============================================================================

  Widget _buildTermsCheckbox(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: isDark
                ? JenixColorsApp.primaryBlueLight
                : JenixColorsApp.primaryBlue,
            checkColor: JenixColorsApp.backgroundWhite,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? JenixColorsApp.lightGray
                    : JenixColorsApp.subtitleColor,
                fontWeight: FontWeight.w400,
                fontFamily: 'OpenSansHebrew',
              ),
              children: [
                const TextSpan(text: 'I have read and agree to the '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: TextStyle(
                    color: isDark
                        ? JenixColorsApp.primaryBlueLight
                        : JenixColorsApp.primaryBlue,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: isDark
                        ? JenixColorsApp.primaryBlueLight
                        : JenixColorsApp.primaryBlue,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _handleTermsTap,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: isDark
                        ? JenixColorsApp.primaryBlueLight
                        : JenixColorsApp.primaryBlue,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: isDark
                        ? JenixColorsApp.primaryBlueLight
                        : JenixColorsApp.primaryBlue,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _handlePrivacyTap,
                ),
                const TextSpan(text: '.'),
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
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
    });

    if (!_acceptTerms) {
      _showSnackBar(
        message: 'You must accept Terms & Privacy to continue',
        icon: Icons.warning_rounded,
        backgroundColor: JenixColorsApp.warningColor,
      );
      return;
    }

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

    _performRegistration();
  }

  Future<void> _performRegistration() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSnackBar(
          message: 'Account created successfully! Welcome to Humboldt',
          icon: Icons.check_circle_outline_rounded,
          backgroundColor: JenixColorsApp.successColor,
        );

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, RoutesApp.login);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          message: 'Registration failed. Please try again.',
          icon: Icons.error_outline_rounded,
          backgroundColor: JenixColorsApp.errorColor,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _handleLogin() {
    Navigator.pushReplacementNamed(context, RoutesApp.login);
  }

  void _handleTermsTap() {
    _showSnackBar(
      message: 'Opening Terms and Conditions...',
      icon: Icons.description_outlined,
      backgroundColor: JenixColorsApp.infoColor,
    );
  }

  void _handlePrivacyTap() {
    _showSnackBar(
      message: 'Opening Privacy Policy...',
      icon: Icons.privacy_tip_outlined,
      backgroundColor: JenixColorsApp.infoColor,
    );
  }

  void _showSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: JenixColorsApp.backgroundWhite, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'OpenSansHebrew',
                  fontWeight: FontWeight.w500,
                  color: JenixColorsApp.backgroundWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
