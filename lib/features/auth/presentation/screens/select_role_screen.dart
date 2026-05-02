import 'package:far_ish_bor/core/extensions/extensions.dart';
import 'package:far_ish_bor/core/theme/app_theme.dart';
import 'package:far_ish_bor/generated/l10n/l10n.dart';
import 'package:far_ish_bor/core/utils/custom_button.dart';
import 'package:far_ish_bor/core/utils/utils.dart';
import 'package:far_ish_bor/features/auth/data/models/role_info_model.dart';
import 'package:far_ish_bor/features/auth/presentation/screens/login_screen.dart';
import 'package:far_ish_bor/generated/assets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/get_it.dart';
import '../../data/datasource/local/user_local_data_source.dart';
import '../widgets/language_item.dart';
import '../widgets/role_item.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  _SelectRoleScreenState createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  UserLocalDatasource localDatasource = getIt<UserLocalDatasource>();
  RoleInfoModel? selectedRole;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final List<RoleInfoModel> roles = [
      RoleInfoModel(emoji: Assets.iconsUchenik, title: l10n.studentRole, subtitle: l10n.studentRoleSubtitle),
      RoleInfoModel(emoji: Assets.iconsRoditel, title: l10n.parentRole, subtitle: l10n.parentRoleSubtitle),
      RoleInfoModel(emoji: Assets.iconsUchitel, title: l10n.teacherRole, subtitle: l10n.teacherRoleSubtitle),
      RoleInfoModel(emoji: Assets.iconsAdminstrator, title: l10n.adminRole, subtitle: l10n.adminRoleSubtitle),
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: YELLOW_COLOR,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: constraints.maxHeight * 0.35,
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Image.asset(Assets.imagesLogoAuth),
                  ),
                  Container(
                    width: getScreenWidth(context),
                    height: constraints.maxHeight * 0.65,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: LIGHT_BACKGROUND_COLOR,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        20.height,
                        AutoSizeText(l10n.selectRoleTitle, maxLines: 1, style: lightTheme().textTheme.displayMedium?.copyWith(fontSize: 24)),
                        AutoSizeText(l10n.selectRoleDescription, maxLines: 1, style: lightTheme().textTheme.bodyLarge),
                        20.height,
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: roles.length,
                            separatorBuilder: (context, index) => 12.height,
                            itemBuilder: (context, index) {
                              final role = roles[index];
                              return RoleItem(
                                emoji: role.emoji,
                                title: role.title,
                                subtitle: role.subtitle,
                                isSelected: selectedRole?.title == role.title,
                                onTap: () => setState(() => selectedRole = role),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          title: l10n.selectedButton,
                          backgroundColor: selectedRole == null ? BUTTON_COLOR.withOpacity(.3) : BUTTON_COLOR,
                          onPressed: () {
                            if (selectedRole != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => LoginScreen(roleInfo: selectedRole)),
                              );
                            } else {
                              showWarning(context, l10n.selectRoleWarning);
                            }
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
      ),
    );
  }
}
