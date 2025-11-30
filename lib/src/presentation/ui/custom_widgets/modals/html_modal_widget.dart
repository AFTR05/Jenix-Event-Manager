import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_html/flutter_html.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class HtmlModalWidget {
  static Future<void> show({
    required BuildContext context,
    required String assetPath,
    required String title,
  }) async {
    String htmlContent;
    try {
      htmlContent = await rootBundle.loadString(assetPath);
    } catch (e) {
      htmlContent = '<p>No se pudo cargar el documento.</p>';
    }

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark 
            ? Colors.white 
            : JenixColorsApp.darkColorText;
        final backgroundColor = isDark 
            ? JenixColorsApp.backgroundDark 
            : JenixColorsApp.backgroundWhite;
        final headerBackground = isDark 
            ? JenixColorsApp.surfaceColor 
            : JenixColorsApp.backgroundLightGray;
        final borderColor = isDark 
            ? JenixColorsApp.darkGray 
            : JenixColorsApp.lightGrayBorder;
        final linkColor = isDark 
            ? JenixColorsApp.primaryBlueLight 
            : JenixColorsApp.primaryBlue;

        // Responsive sizing
        final size = MediaQuery.of(context).size;
        final isMobile = size.width < 600;
        final isTablet = size.width >= 600 && size.width < 1200;
        final isDesktop = size.width >= 1200;

        // Calculate responsive dimensions
        final modalWidth = isMobile 
            ? size.width * 0.95
            : isTablet 
                ? size.width * 0.85
                : size.width * 0.75;
        
        final modalHeight = isMobile
            ? size.height * 0.85
            : isTablet
                ? size.height * 0.80
                : size.height * 0.75;

        // Responsive font sizes
        final titleFontSize = isMobile ? 16.0 : isTablet ? 18.0 : 20.0;
        final contentFontSize = isMobile ? 13.0 : isTablet ? 14.0 : 15.0;
        final headingFontSize = isMobile ? 20.0 : isTablet ? 22.0 : 24.0;

        return Dialog(
          insetPadding: EdgeInsets.all(isMobile ? 12 : 16),
          backgroundColor: backgroundColor,
          child: SizedBox(
            width: modalWidth,
            height: modalHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: headerBackground,
                    border: Border(
                      bottom: BorderSide(
                        color: borderColor,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        iconSize: isMobile ? 24 : 28,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Container(
                    color: backgroundColor,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      child: Html(
                        data: htmlContent,
                        style: {
                          'body': Style(
                            color: textColor,
                            fontSize: FontSize(contentFontSize),
                            lineHeight: const LineHeight(1.6),
                            fontFamily: 'OpenSansHebrew',
                          ),
                          'p': Style(
                            color: textColor,
                            fontSize: FontSize(contentFontSize),
                            lineHeight: const LineHeight(1.6),
                            margin: Margins.all(isMobile ? 4 : 8),
                          ),
                          'h1': Style(
                            color: JenixColorsApp.primaryBlue,
                            fontSize: FontSize(headingFontSize),
                            fontWeight: FontWeight.bold,
                            margin: Margins.symmetric(
                              vertical: isMobile ? 8 : 16,
                            ),
                          ),
                          'h2': Style(
                            color: JenixColorsApp.primaryBlue,
                            fontSize: FontSize(headingFontSize * 0.85),
                            fontWeight: FontWeight.bold,
                            margin: Margins.symmetric(
                              vertical: isMobile ? 6 : 12,
                            ),
                          ),
                          'h3': Style(
                            color: JenixColorsApp.primaryBlue,
                            fontSize: FontSize(headingFontSize * 0.75),
                            fontWeight: FontWeight.w600,
                            margin: Margins.symmetric(
                              vertical: isMobile ? 5 : 10,
                            ),
                          ),
                          'li': Style(
                            color: textColor,
                            fontSize: FontSize(contentFontSize),
                            lineHeight: const LineHeight(1.6),
                            margin: Margins.symmetric(
                              vertical: isMobile ? 2 : 4,
                            ),
                          ),
                          'strong': Style(
                            fontWeight: FontWeight.bold,
                            color: JenixColorsApp.primaryRed,
                          ),
                          'a': Style(
                            color: linkColor,
                            textDecoration: TextDecoration.underline,
                          ),
                          'hr': Style(
                            border: Border(
                              top: BorderSide(
                                color: borderColor,
                                width: 1,
                              ),
                            ),
                            margin: Margins.symmetric(
                              vertical: isMobile ? 8 : 16,
                            ),
                          ),
                        },
                      ),
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: borderColor,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: JenixColorsApp.primaryBlue,
                        ),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
