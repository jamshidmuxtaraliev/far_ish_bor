import 'package:far_ish_bor/core/extensions/extensions.dart';
import 'package:far_ish_bor/core/theme/app_theme.dart';
import 'package:far_ish_bor/generated/l10n/l10n.dart';
import 'package:far_ish_bor/core/utils/custom_button.dart';
import 'package:far_ish_bor/core/utils/custom_switch.dart';
import 'package:far_ish_bor/core/utils/custom_textfield.dart';
import 'package:far_ish_bor/core/utils/utils.dart';
import 'package:far_ish_bor/features/auth/data/models/role_info_model.dart';
import 'package:far_ish_bor/generated/assets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/get_it.dart';
import '../../data/datasource/local/user_local_data_source.dart';
import '../../data/models/signin_params.dart';
import '../logic/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  final RoleInfoModel? roleInfo;

  const LoginScreen({super.key, this.roleInfo});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserLocalDatasource localDatasource = getIt<UserLocalDatasource>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isConfirmData = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final l10n = S.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: YELLOW_COLOR,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight * 0.45,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                child: Image.asset(Assets.imagesLogoAuth, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: getScreenWidth(context),
                height: screenHeight * 0.55,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: LIGHT_BACKGROUND_COLOR,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    40.height,
                    AutoSizeText(l10n.signInTitle, maxLines: 1, style: lightTheme().textTheme.displayMedium?.copyWith(fontSize: 24)),
                    AutoSizeText(l10n.signInDescription, maxLines: 1, style: lightTheme().textTheme.bodyLarge),
                    20.height,
                    CustomTextField(
                      controller: _usernameController,
                      title: l10n.loginOrEmail,
                      hint: l10n.loginHint,
                      fillColor: WHITE,
                      prefixIcon: const Icon(CupertinoIcons.mail),
                    ),
                    12.height,
                    CustomTextField(
                      controller: _passwordController,
                      title: l10n.password,
                      hint: l10n.passwordHint,
                      fillColor: WHITE,
                      obscureText: true,
                      prefixIcon: const Icon(CupertinoIcons.padlock),
                    ),
                    const Spacer(),
                    CustomCheckbox(
                      isChecked: isConfirmData,
                      label: l10n.personalDataConsent,
                      onChanged: () => setState(() => isConfirmData = !isConfirmData),
                    ),
                    20.height,
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state.signInStatus.isFailure) {
                          showError(context, state.error?.errorMessage ?? l10n.authError);
                        } else if (state.signInStatus == FormzSubmissionStatus.success) {
                          // TODO: navigate to home screen by role
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const _HomePlaceholder()),
                          );
                        }
                      },
                      builder: (context, state) {
                        return CustomButton(
                          title: l10n.signInButton,
                          onPressed: () {
                            if (!isConfirmData) {
                              showError(context, l10n.confirmConsentError);
                              return;
                            }
                            if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                              showError(context, l10n.fillAllFieldsError);
                              return;
                            }
                            context.read<AuthBloc>().add(SignInEvent(SignInParams(_usernameController.text, _passwordController.text)));
                          },
                          backgroundColor: isConfirmData ? BUTTON_COLOR : BUTTON_COLOR.withOpacity(.3),
                          isInProgress: state.signInStatus.isInProgress,
                        );
                      },
                    ),
                    40.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Home')), body: const Center(child: Text('Bosh sahifa')));
  }
}
