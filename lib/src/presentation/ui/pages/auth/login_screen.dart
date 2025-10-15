import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/core/validators/fields_validators.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/buttons/custom_button_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/form/custom_form_element.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/inputs/custom_auth_text_field_widget.dart';
import 'package:jenix_event_manager/src/routes_app.dart';

/// LoginScreen - Alexander von Humboldt Event Manager
///
/// **Autor:** AFTR05
/// **Última modificación:** 2025-10-15 20:06:31 UTC
/// **Versión:** 2.0.0
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _rememberMe = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [JenixColorsApp.darkBackground, JenixColorsApp.darkGray]
                    : [
                        JenixColorsApp.loginBeginGradient,
                        JenixColorsApp.loginEndGradient,
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Logo
                  SizedBox(
                    height: isMobile ? 110 : 130,
                    child: Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: SvgPicture.asset(
                          'assets/images/humboldt_logo.svg',
                          width: isMobile ? 90 : 110,
                          height: isMobile ? 90 : 110,
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

                  // Form
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 60 : 24,
                        vertical: isMobile ? 24 : 32,
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back',
                                    style: TextStyle(
                                      fontSize: isMobile ? 24 : 28,
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
                                    'Please login to continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? JenixColorsApp.lightGray
                                          : JenixColorsApp.subtitleColor,
                                      fontFamily: 'OpenSansHebrew',
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 24 : 32),

                                  // ✅ EMAIL con CustomFormElement
                                  CustomFormElement(
                                    labelTitle: "Email",
                                    isRequired: true,
                                    errorText: _emailError,
                                    widget: CustomAuthTextFieldWidget(
                                      controller: _emailController,
                                      hintText:
                                          "Enter your institutional email",
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      prefix: Icon(
                                        Icons.email_outlined,
                                        color: isDark
                                            ? JenixColorsApp.lightGray
                                            : JenixColorsApp.greyColorIcon,
                                        size: 20,
                                      ),
                                      validator:
                                          FieldsValidators.emailValidator,
                                      onChanged: (_) {
                                        if (_emailError != null) {
                                          setState(() => _emailError = null);
                                        }
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ✅ PASSWORD con CustomFormElement
                                  CustomFormElement(
                                    labelTitle: "Password",
                                    isRequired: true,
                                    errorText: _passwordError,
                                    widget: CustomAuthTextFieldWidget(
                                      controller: _passwordController,
                                      hintText: "Enter your password",
                                      isPasswordField: true,
                                      textInputAction: TextInputAction.done,
                                      validator:
                                          FieldsValidators.fieldIsRequired,
                                      onFieldSubmitted: (_) =>
                                          _loginValidation(),
                                      onChanged: (_) {
                                        if (_passwordError != null) {
                                          setState(() => _passwordError = null);
                                        }
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Remember me & Forgot
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => setState(
                                          () => _rememberMe = !_rememberMe,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 4,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: Checkbox(
                                                  value: _rememberMe,
                                                  onChanged: (value) {
                                                    setState(
                                                      () => _rememberMe =
                                                          value ?? false,
                                                    );
                                                  },
                                                  activeColor: isDark
                                                      ? JenixColorsApp
                                                            .primaryBlueLight
                                                      : JenixColorsApp
                                                            .primaryBlue,
                                                  checkColor: JenixColorsApp
                                                      .backgroundWhite,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Remember me',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? JenixColorsApp.lightGray
                                                      : JenixColorsApp
                                                            .subtitleColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'OpenSansHebrew',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _handleForgotPassword,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          foregroundColor: isDark
                                              ? JenixColorsApp.primaryBlueLight
                                              : JenixColorsApp.primaryBlue,
                                        ),
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? JenixColorsApp
                                                      .primaryBlueLight
                                                : JenixColorsApp.primaryBlue,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'OpenSansHebrew',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: isMobile ? 20 : 24),

                                  CustomButtonWidget(
                                    onPressed: _loginValidation,
                                    title: "Login",
                                    backgroundColor: isDark
                                        ? JenixColorsApp.primaryBlueLight
                                        : JenixColorsApp.buttonPrimary,
                                    isLoading: _isLoading,
                                    icon: _isLoading
                                        ? null
                                        : Icons.login_rounded,
                                  ),

                                  const SizedBox(height: 20),

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

                                  const SizedBox(height: 20),

                                  Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
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
                                          onTap: _handleSignUp,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'OpenSansHebrew',
                                                decoration:
                                                    TextDecoration.underline,
                                                color: isDark
                                                    ? JenixColorsApp
                                                          .primaryBlueLight
                                                    : JenixColorsApp
                                                          .primaryBlue,
                                                decorationColor: isDark
                                                    ? JenixColorsApp
                                                          .primaryBlueLight
                                                    : JenixColorsApp
                                                          .primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

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
                                ],
                              ),
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

          if (_isLoading)
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
                        'Signing in...',
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

  void _loginValidation() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final emailError = FieldsValidators.emailValidator(_emailController.text);
    final passwordError = FieldsValidators.fieldIsRequired(
      _passwordController.text,
    );

    if (emailError != null || passwordError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
      });
      return;
    }

    _loginAction();
  }

  Future<void> _loginAction() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSnackBar(
          message: 'Login successful! Welcome to Humboldt Event Manager',
          icon: Icons.check_circle_outline_rounded,
          backgroundColor: JenixColorsApp.successColor,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _emailError = 'Invalid credentials');

        _showSnackBar(
          message: 'Login failed. Please check your credentials.',
          icon: Icons.error_outline_rounded,
          backgroundColor: JenixColorsApp.errorColor,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    _showSnackBar(
      message: 'Please contact IT support for password recovery',
      icon: Icons.info_outline_rounded,
      backgroundColor: JenixColorsApp.infoColor,
    );
  }

  void _handleSignUp() {
    Navigator.pushNamed(context, RoutesApp.register);
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
