import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jenix_event_manager/src/core/validators/fields_validators.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/buttons/custom_button_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/form/custom_form_element.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/inputs/custom_auth_text_field_widget.dart';
import 'package:jenix_event_manager/src/routes_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jenix_event_manager/translations/locale_keys.g.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      body: Stack(
        children: [
          /// ===== FONDO INSTITUCIONAL =====
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

          /// ===== SOMBRA ROJA DECORATIVA =====
          Positioned(
            left: -100,
            bottom: -80,
            child: Container(
              height: 220,
              width: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22BE1723),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55BE1723),
                    blurRadius: 200,
                    spreadRadius: 100,
                  )
                ],
              ),
            ),
          ),

          /// ===== BOTÓN VOLVER =====
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, RoutesApp.index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            LocaleKeys.authLoginBackToHome.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
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

          /// ===== FORMULARIO PRINCIPAL =====
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
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ===== LOGO =====
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

                        /// ===== TITULO =====
                        Text(LocaleKeys.authLoginTitle.tr(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'OpenSansHebrew',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(LocaleKeys.authLoginSubtitle.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9DA9B9),
                            fontFamily: 'OpenSansHebrew',
                          ),
                        ),
                        const SizedBox(height: 32),

                        /// ===== CORREO =====
                        CustomFormElement(
                          labelTitle: LocaleKeys.authLoginEmailLabel.tr(),
                          isRequired: true,
                          errorText: _emailError,
                          widget: CustomAuthTextFieldWidget(
                            controller: _emailController,
                            hintText: LocaleKeys.authLoginEmailHint.tr(),
                            keyboardType: TextInputType.emailAddress,
                            prefix: const Icon(Icons.email_outlined,
                                color: Colors.white70, size: 20),
                            validator: FieldsValidators.emailValidator,
                            onChanged: (_) {
                              if (_emailError != null) {
                                setState(() => _emailError = null);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// ===== CONTRASEÑA =====
                        CustomFormElement(
                          labelTitle: LocaleKeys.authLoginButton.tr(),
                          isRequired: true,
                          errorText: _passwordError,
                          widget: CustomAuthTextFieldWidget(
                            controller: _passwordController,
                            hintText: LocaleKeys.authLoginForgotPassword.tr(),
                            isPasswordField: true,
                            prefix: const Icon(Icons.lock_outline_rounded,
                                color: Colors.white70, size: 20),
                            validator: FieldsValidators.fieldIsRequired,
                            onChanged: (_) {
                              if (_passwordError != null) {
                                setState(() => _passwordError = null);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        /// ===== RECORDARME =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) =>
                                          setState(() => _rememberMe = v ?? false),
                                      activeColor: const Color(0xFFBE1723),
                                      checkColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                            Text(
                                              LocaleKeys.authLoginRememberMe.tr(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'OpenSansHebrew',
                                              ),
                                            ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _handleForgotPassword,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFBE1723),
                              ),
                child: Text(
                  LocaleKeys.authLoginForgotPassword.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        /// ===== BOTÓN LOGIN =====
                        CustomButtonWidget(
                          onPressed: _loginValidation,
                          title: LocaleKeys.authLoginButton.tr(),
                          backgroundColor: const Color(0xFFBE1723),
                          isLoading: _isLoading,
                          icon: Icons.login_rounded,
                        ),
                        const SizedBox(height: 32),

                        /// ===== REGISTRO =====
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                                children: [
                                TextSpan(text: LocaleKeys.authLoginNoAccount.tr()),
                                TextSpan(
                                  text: LocaleKeys.authLoginRegisterHere.tr(),
                                  style: const TextStyle(
                                    color: Color(0xFFBE1723),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _handleSignUp,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            '© 2025 Universidad Alexander von Humboldt — Eventum',
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
          ),

          /// ===== LOADER =====
          if (_isLoading)
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

  // ====================== LÓGICA ======================

  void _loginValidation() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final emailError = FieldsValidators.emailValidator(_emailController.text);
    final passwordError =
        FieldsValidators.fieldIsRequired(_passwordController.text);

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
      final authController = ref.read(authenticationControllerProvider);
      final result = await authController.logIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _emailError = failure.message;
            _isLoading = false;
          });
          _showSnackBar(
              message: failure.message,
              icon: Icons.error_outline_rounded,
              backgroundColor: Colors.redAccent);
        },
        (user) {
      setState(() => _isLoading = false);
      _showSnackBar(
        message: LocaleKeys.loginWelcome.tr(namedArgs: {'name': user.name}),
        icon: Icons.check_circle_outline_rounded,
        backgroundColor: Colors.green);
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, RoutesApp.main);
            }
          });
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(
        message: LocaleKeys.loginUnexpectedError.tr(),
        icon: Icons.error_outline_rounded,
        backgroundColor: Colors.redAccent,
      );
    }
  }

  void _handleForgotPassword() {
    _showSnackBar(
      message: LocaleKeys.loginContactSupport.tr(),
      icon: Icons.info_outline_rounded,
      backgroundColor: Colors.blueAccent,
    );
  }

  void _handleSignUp() {
    Navigator.pushNamed(context, RoutesApp.register);
  }

  void _showSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
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
