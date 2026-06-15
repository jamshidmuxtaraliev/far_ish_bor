import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/get_it.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
import '../../../main/presentation/screens/main_screen.dart';
import '../logic/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  final String language;

  const LoginScreen({super.key, required this.language});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _phoneMask = MaskTextInputFormatter(
    mask: '+998 (##) ### ## ##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Strips spaces and parentheses, e.g. "+998 (90) 123 45 67" -> "+998901234567"
  String get _cleanPhone => _phoneController.text.replaceAll(RegExp(r'[\s()]'), '');

  int _step = 0; // 0 = phone, 1 = otp

  bool get isUz => widget.language == 'uz';

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _onSendCode(BuildContext context) {
    final phone = _cleanPhone;
    if (phone.isEmpty) return;
    context.read<AuthBloc>().add(SendCodeEvent(phone));
  }

  void _onLogin(BuildContext context) {
    final phone = _cleanPhone;
    final code = _codeController.text.trim();
    if (phone.isEmpty || code.isEmpty) return;
    context.read<AuthBloc>().add(LoginEvent(phone, code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.sendCodeStatus == FormzSubmissionStatus.success) {
          setState(() => _step = 1);
          Future.delayed(const Duration(milliseconds: 100), () => _codeFocus.requestFocus());
        }
        if (state.sendCodeStatus == FormzSubmissionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error?.errorMessage ?? 'Xato yuz berdi'), backgroundColor: Colors.red),
          );
        }
        if (state.loginStatus == FormzSubmissionStatus.success) {
          final role = getIt<UserLocalDatasource>().getRole();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainScreen(isEmployer: role == 'employer')),
            (route) => false,
          );
        }
        if (state.loginStatus == FormzSubmissionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error?.errorMessage ?? 'Kirish amalga oshmadi'), backgroundColor: Colors.red),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_step == 1) {
                            setState(() => _step = 0);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: DARK_NAVY),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [PRIMARY_BLUE, SECONDARY_BLUE]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: PRIMARY_BLUE.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                          ),
                          child: const Icon(Icons.lock_open_outlined, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _step == 0
                              ? (isUz ? 'Kirish' : 'Войти')
                              : (isUz ? 'SMS kodni kiriting' : 'Введите SMS код'),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: DARK_NAVY),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _step == 0
                              ? (isUz ? 'Telefon raqamingizni kiriting' : 'Введите номер телефона')
                              : (isUz
                                  ? '${_phoneController.text} ga yuborilgan 6 raqamli kodni kiriting'
                                  : 'Введите 6-значный код, отправленный на ${_phoneController.text}'),
                          style: const TextStyle(fontSize: 14, color: GRAY_TEXT),
                        ),
                        const SizedBox(height: 40),
                        if (_step == 0) _buildPhoneStep(context),
                        if (_step == 1) _buildOtpStep(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.sendCodeStatus.isInProgress;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isUz ? 'Telefon raqami' : 'Номер телефона', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DARK_NAVY)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: LIGHT_GRAY_BG,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                autofocus: true,
                inputFormatters: [_phoneMask],
                style: const TextStyle(fontSize: 16, color: DARK_NAVY),
                decoration: InputDecoration(
                  hintText: '+998 (90) 123 45 67',
                  hintStyle: const TextStyle(color: GRAY_TEXT),
                  prefixIcon: const Icon(Icons.phone_outlined, color: GRAY_TEXT, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _onSendCode(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_BLUE,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(isUz ? 'Kodni yuborish' : 'Отправить код', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOtpStep(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.loginStatus.isInProgress;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isUz ? 'Tasdiqlash kodi' : 'Код подтверждения', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DARK_NAVY)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: LIGHT_GRAY_BG,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _codeController,
                focusNode: _codeFocus,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DARK_NAVY, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '------',
                  hintStyle: TextStyle(color: GRAY_TEXT, letterSpacing: 8),
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _onLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_BLUE,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(isUz ? 'Kirish' : 'Войти', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: isLoading ? null : () => _onSendCode(context),
                child: Text(
                  isUz ? 'Kodni qayta yuborish' : 'Отправить код повторно',
                  style: const TextStyle(color: PRIMARY_BLUE, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
