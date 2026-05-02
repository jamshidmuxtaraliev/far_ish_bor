import 'package:far_ish_bor/core/theme/app_theme.dart';
import 'package:far_ish_bor/core/utils/utils.dart';
import 'package:far_ish_bor/generated/l10n/l10n.dart';
import 'package:far_ish_bor/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/get_it.dart';
import '../../data/datasource/local/user_local_data_source.dart';
import '../logic/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  UserLocalDatasource localDatasource = getIt<UserLocalDatasource>();
  DateTime? _startTime;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    if (localDatasource.getToken() != '') {
      context.read<AuthBloc>().add(GetUserEvent('fcmToken'));
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isNavigated && mounted) {
          _isNavigated = true;
          _goToSelectLanguage();
        }
      });
    }
  }

  void _goToSelectLanguage() {
    // TODO: replace with your SelectLanguageScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _PlaceholderScreen(title: 'Til tanlash')),
    );
  }

  Future<void> _navigateAfterMinimumTime(Widget screen) async {
    if (_isNavigated) return;

    final elapsed = DateTime.now().difference(_startTime!);
    const minimumDuration = Duration(seconds: 2);

    if (elapsed < minimumDuration) {
      await Future.delayed(minimumDuration - elapsed);
    }

    if (mounted && !_isNavigated) {
      _isNavigated = true;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.getUserStatus.isFailure) {
          showError(context, state.error?.errorMessage ?? S.of(context).error);
        } else if (state.getUserStatus.isSuccess) {
          // TODO: navigate by role
          _navigateAfterMinimumTime(const _PlaceholderScreen(title: 'Home'));
        }
      },
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: YELLOW_COLOR,
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: constraints.maxHeight * 0.6,
                      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 50),
                      child: Image.asset(Assets.imagesLogoAuth),
                    ),
                    Container(
                      width: getScreenWidth(context),
                      height: constraints.maxHeight * 0.4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.yellow),
                          Text(S.of(context).loading, style: lightTheme().textTheme.displayMedium),
                          Text(S.of(context).preparingMaterials, style: lightTheme().textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
  }
}
