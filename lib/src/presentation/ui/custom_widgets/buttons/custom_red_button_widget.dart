import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class CustomRedButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final bool isLoading;
  final double? width;
  final double? height;
  final double? fontSize;
  final IconData? icon;
  final bool isOutlined;

  const CustomRedButtonWidget({
    super.key,
    required this.onPressed,
    required this.title,
    this.isLoading = false,
    this.width,
    this.height,
    this.fontSize,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 900;

        // Adaptive dimensions
        final buttonHeight = height ??
            (isMobile
                ? 48.0
                : isTablet
                    ? 52.0
                    : 56.0);

        final textSize = fontSize ??
            (isMobile
                ? 14.0
                : isTablet
                    ? 15.0
                    : 16.0);

        final buttonWidth = width ?? double.infinity;

        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: isOutlined ? _buildOutlinedButton(textSize) : _buildFilledButton(textSize),
        );
      },
    );
  }

  Widget _buildFilledButton(double textSize) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: JenixColorsApp.jenixAppColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: JenixColorsApp.jenixAppColor.withValues(alpha: .6),
        disabledForegroundColor: Colors.white.withValues(alpha: .7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: textSize + 2),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
    );
  }

  Widget _buildOutlinedButton(double textSize) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: JenixColorsApp.jenixAppColor,
        side: BorderSide(
          color: JenixColorsApp.jenixAppColor,
          width: 2,
        ),
        disabledForegroundColor: JenixColorsApp.jenixAppColor.withValues(alpha: .5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  JenixColorsApp.jenixAppColor,
                ),
              ),
            )
          : icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: textSize + 2),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
    );
  }
}