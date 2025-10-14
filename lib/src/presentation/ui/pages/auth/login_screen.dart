import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/core/validators/fields_validators.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/buttons/custom_red_button_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/inputs/custom_input_text_field_widget.dart';
import 'package:jenix_event_manager/src/routes_app.dart';

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
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                tileMode: TileMode.clamp,
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                stops: const [0.4, 0.75],
                colors: isDark
                    ? [
                        JenixColorsApp.darkBackground,
                        JenixColorsApp.darkGray,
                      ]
                    : [
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
                      child: Hero(
                        tag: 'app_logo',
                        child: SvgPicture.asset(
                          'assets/images/jenix_logo.svg',
                          width: isMobile ? 100 : 120,
                          height: isMobile ? 100 : 120,
                          colorFilter: ColorFilter.mode(
                            isDark 
                                ? JenixColorsApp.primaryRedLight 
                                : JenixColorsApp.backgroundWhite,
                            BlendMode.srcIn,
                          ),
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
                        vertical: isMobile ? 24 : 32,
                      ),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: SingleChildScrollView(
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
                                  // Welcome text
                                  Text(
                                    'Welcome back',
                                    style: TextStyle(
                                      fontSize: isMobile ? 24 : 28,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
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

                                  // Email field
                                  CustomInputTextFieldWidget(
                                    controller: _emailController,
                                    labelTitle: "Email",
                                    hintText: "Enter your email",
                                    textInputType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    isRequired: true,
                                    errorText: _emailError,
                                    prefix: Icon(
                                      Icons.email_outlined,
                                      color: JenixColorsApp.greyColorIcon,
                                      size: 20,
                                    ),
                                    validator: FieldsValidators.emailValidator,
                                    onChanged: (_) {
                                      if (_emailError != null) {
                                        setState(() => _emailError = null);
                                      }
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  // Password field
                                  CustomInputTextFieldWidget(
                                    controller: _passwordController,
                                    labelTitle: "Password",
                                    hintText: "Enter your password",
                                    isPassword: true,
                                    textInputAction: TextInputAction.done,
                                    isRequired: true,
                                    errorText: _passwordError,
                                    validator: FieldsValidators.fieldIsRequired,
                                    onFieldSubmitted: (_) => _loginValidation(),
                                    onChanged: (_) {
                                      if (_passwordError != null) {
                                        setState(() => _passwordError = null);
                                      }
                                    },
                                  ),

                                  const SizedBox(height: 12),

                                  // Remember me & Forgot password
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Remember me checkbox
                                      InkWell(
                                        onTap: () => setState(() => _rememberMe = !_rememberMe),
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
                                                    setState(() => _rememberMe = value ?? false);
                                                  },
                                                  activeColor: JenixColorsApp.primaryRed,
                                                  checkColor: theme.colorScheme.onPrimary,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  visualDensity: VisualDensity.compact,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4),
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
                                                      : JenixColorsApp.subtitleColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'OpenSansHebrew',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Forgot password button
                                      TextButton(
                                        onPressed: _handleForgotPassword,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          foregroundColor: isDark 
                                              ? JenixColorsApp.primaryRedLight 
                                              : JenixColorsApp.primaryRed,
                                        ),
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark 
                                                ? JenixColorsApp.primaryRedLight 
                                                : JenixColorsApp.primaryRed,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'OpenSansHebrew',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: isMobile ? 20 : 24),

                                  // Login button
                                  CustomRedButtonWidget(
                                    onPressed: _loginValidation,
                                    title: "Login",
                                    isLoading: _isLoading,
                                    icon: _isLoading ? null : Icons.login_rounded,
                                  ),

                                  const SizedBox(height: 20),

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
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
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

                                  // Sign up link
                                  Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
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
                                          borderRadius: BorderRadius.circular(4),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark 
                                                    ? JenixColorsApp.primaryRedLight 
                                                    : JenixColorsApp.primaryRed,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'OpenSansHebrew',
                                                decoration: TextDecoration.underline,
                                                decorationColor: isDark 
                                                    ? JenixColorsApp.primaryRedLight 
                                                    : JenixColorsApp.primaryRed,
                                              ),
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
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: JenixColorsApp.overlayColor,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Signing in...',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
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
  // VALIDATION & ACTIONS
  // ============================================================================

  void _loginValidation() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final emailError = FieldsValidators.emailValidator(_emailController.text);
    final passwordError = FieldsValidators.fieldIsRequired(_passwordController.text);

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
      // TODO: Implementar lógica de login con provider
      // await ref.read(authControllerProvider).login(
      //   email: _emailController.text,
      //   password: _passwordController.text,
      //   rememberMe: _rememberMe,
      // );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // TODO: Navegar a home
        // Navigator.pushReplacementNamed(context, RoutesApp.home);

        _showSnackBar(
          message: 'Login successful!',
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
      message: 'Forgot Password feature coming soon...',
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
    final theme = Theme.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onPrimary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'OpenSansHebrew',
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}