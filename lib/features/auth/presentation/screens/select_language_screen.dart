import 'package:far_ish_bor/core/extensions/extensions.dart';
import 'package:far_ish_bor/core/locale/locale_cubit.dart';
import 'package:far_ish_bor/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:far_ish_bor/generated/l10n/l10n.dart';
import 'package:far_ish_bor/core/utils/custom_button.dart';
import 'package:far_ish_bor/core/utils/utils.dart';
import 'package:far_ish_bor/generated/assets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/get_it.dart';
import '../../data/datasource/local/user_local_data_source.dart';
import '../widgets/language_item.dart';
import 'login_screen.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  _SelectLanguageScreenState createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  UserLocalDatasource localDatasource = getIt<UserLocalDatasource>();
  String? selectedLangCode;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: YELLOW_COLOR,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: constraints.maxHeight * 0.45,
                  padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 50),
                  child: Image.asset(Assets.imagesLogoAuth),
                ),
                Container(
                  width: getScreenWidth(context),
                  height: constraints.maxHeight * 0.55,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: const BoxDecoration(
                    color: LIGHT_BACKGROUND_COLOR,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      32.height,
                      AutoSizeText(
                        S.of(context).selectLanguageTitle,
                        maxLines: 1,
                        style: lightTheme().textTheme.displayMedium?.copyWith(fontSize: 24),
                      ),
                      12.height,
                      Text(S.of(context).selectLanguageDescription, style: lightTheme().textTheme.bodyLarge),
                      26.height,
                      LanguageItem(
                        title: S.of(context).languageRussian,
                        flag: "🇷🇺",
                        isSelected: selectedLangCode == RU_LANG_KEY,
                        onTap: () {
                          setState(() => selectedLangCode = RU_LANG_KEY);
                          context.read<LocaleCubit>().setLocale(const Locale('ru'));
                        },
                      ),
                      12.height,
                      LanguageItem(
                        title: S.of(context).languageUzbek,
                        flag: "🇺🇿",
                        isSelected: selectedLangCode == UZ_LANG_KEY,
                        onTap: () {
                          setState(() => selectedLangCode = UZ_LANG_KEY);
                          context.read<LocaleCubit>().setLocale(const Locale('uz'));
                        },
                      ),
                      const Spacer(),
                      CustomButton(
                        title: "Davom etish / Продолжать",
                        isDisabled: selectedLangCode == null,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                      ),
                      50.height,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
