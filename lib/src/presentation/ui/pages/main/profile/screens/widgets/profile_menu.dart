import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/core/helpers/language_app.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/role_enum.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/general_widgets/selection_bottom_sheet_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/screens/widgets/profile_menu_tile.dart';
import 'package:jenix_event_manager/src/routes_app.dart';
import 'package:jenix_event_manager/translations/locale_keys.g.dart';

class ProfileMenu extends ConsumerStatefulWidget {
  /// Color del texto en elementos de menú.
  final Color textColor;

  /// Color del icono en elementos de menú.
  final Color iconColor;

  /// Constructor con parámetros obligatorios.
  const ProfileMenu({
    super.key,
    required this.textColor,
    required this.iconColor,
  });

  @override
  ConsumerState<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends ConsumerState<ProfileMenu> {
  /// Lista estática de ítems que componen el menú.
  List<ProfileMenuItem> get menuItems => [
    ProfileMenuItem(
      label: LocaleKeys.profileEditProfileLabel.tr(),
      iconAsset: 'assets/images/icons/user_edit_icon.svg',
      route: RoutesApp.editProfile,
    ),
    //ProfileMenuItem(
    //  label: LocaleKeys.selectLanguageLabel.tr(),
    //  icon: Icons.language_outlined,
    //  onTap: (context, ref) {
    //    _showLanguageSelectionBottomSheet(context);
    //  },
    //),
    if (ref.read(loginProviderProvider)?.role == RoleEnum.admin) ...[
      ProfileMenuItem(
        label: LocaleKeys.profileMyEventsLabel.tr(),
        iconAsset: 'assets/images/icons/calendar_icon.svg',
        route: RoutesApp.myEvents,
      ),
    ],
    ProfileMenuItem(
      label: "Mis Inscripciones",
      icon: Icons.event_note_outlined,
      route: RoutesApp.myEnrollments,
    ),
    ProfileMenuItem(
      label: LocaleKeys.profileLogoutLabel.tr(),
      iconAsset: 'assets/images/icons/logout_icon.svg',
      isLogout: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return ProfileMenuTile(
          item: item,
          textColor: widget.textColor,
          iconColor: widget.iconColor,
        );
      },
    );
  }

  void _showLanguageSelectionBottomSheet(BuildContext context) {
    final currentLanguageName =
        LanguagesApp.nameLanguages[context.locale.languageCode] ?? 'English';
    final languageNames = LanguagesApp.availableLanguages
        .map((locale) => LanguagesApp.nameLanguages[locale.languageCode] ?? '')
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (bottomSheetContext) => SelectionBottomSheetWidget(
        title: LocaleKeys.selectLanguageLabel.tr(),
        currentValue: currentLanguageName,
        options: languageNames,
        onSelected: (selectedLanguageName) async {
          // Find the locale code from the selected language name
          final selectedLocale = LanguagesApp.availableLanguages.firstWhere(
            (locale) =>
                LanguagesApp.nameLanguages[locale.languageCode] ==
                selectedLanguageName,
            orElse: () => const Locale('en'),
          );

          // Change the app language using the parent context (not bottomSheetContext)
          // This will rebuild the entire app
          await context.setLocale(selectedLocale);

          // EasyLocalization rebuilds the widget tree after setLocale;
          // no manual setState() is required here.
          // Note: The bottom sheet will close automatically via SelectionBottomSheetWidget's onTap
        },
      ),
    );
  }
}
