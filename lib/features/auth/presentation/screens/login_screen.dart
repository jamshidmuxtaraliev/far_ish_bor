import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/get_it.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
import '../../../main/presentation/screens/main_screen.dart';
import '../../data/models/auth_error_kind.dart';
import '../logic/auth_bloc.dart';
import '../widgets/auth_snack.dart';
import '../widgets/otp_countdown.dart';
import 'user_type_screen.dart';

class LoginScreen extends StatefulWidget {
  final String language;

  /// Ro'yxatdan o'tish ekranidan o'tkazilganda raqam avtomatik to'ldiriladi.
  final String? initialPhone;

  /// Nega bu ekranga tushib qolgani haqida izoh.
  final String? notice;

  const LoginScreen({
    super.key,
    required this.language,
    this.initialPhone,
    this.notice,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with OtpCountdownMixin {
  late final TextEditingController _phoneController;
  final _codeController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _codeFocus = FocusNode();
  late final MaskTextInputFormatter _phoneMask;

  /// `check-phone` javobini kutayotgan raqam — SMS shu raqamga ketadi.
  String _pendingPhone = '';

  // Strips spaces and parentheses, e.g. "+998 (90) 123 45 67" -> "+998901234567"
  String get _cleanPhone => _phoneController.text.replaceAll(RegExp(r'[\s()]'), '');

  int _step = 0; // 0 = phone, 1 = otp

  bool get isUz => widget.language == 'uz';

  @override
  void initState() {
    super.initState();
    // Maskaga faqat 9 xonali lokal qism beriladi — '+998' mask ichida literal.
    final digits = (widget.initialPhone ?? '').replaceAll(RegExp(r'\D'), '');
    final local = digits.length > 9 ? digits.substring(digits.length - 9) : digits;
    _phoneMask = MaskTextInputFormatter(
      mask: '+998 (##) ### ## ##',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
      initialText: local.isEmpty ? null : local,
    );
    _phoneController = TextEditingController(text: local.isEmpty ? '' : _phoneMask.getMaskedText());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _showError(String message, {String? actionLabel, VoidCallback? onAction}) {
    showAuthSnack(context, message, actionLabel: actionLabel, onAction: onAction);
  }

  /// 1-qadam: raqam bazada bormi? Yo'q bo'lsa bekorga SMS yubormaymiz.
  void _onContinuePhone(BuildContext context) {
    final phone = _cleanPhone;
    if (phone.isEmpty || !phone.startsWith('+998') || phone.length < 13) {
      _showError(isUz
          ? 'To\'g\'ri telefon raqam kiriting (+998...)'
          : 'Введите корректный номер (+998...)');
      return;
    }
    _pendingPhone = phone;
    context.read<AuthBloc>().add(CheckPhoneEvent(phone));
  }

  void _sendCode(BuildContext context) {
    context.read<AuthBloc>().add(SendCodeEvent(_pendingPhone.isEmpty ? _cleanPhone : _pendingPhone));
  }

  void _onLogin(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.length < 6 || otpExpired) return;
    context.read<AuthBloc>().add(LoginEvent(_pendingPhone, smsCode: code));
  }

  void _goToRegistration() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => UserTypeScreen(
          language: widget.language,
          initialPhone: _pendingPhone.isEmpty ? _cleanPhone : _pendingPhone,
          notice: isUz
              ? 'Bu raqam hali ro\'yxatdan o\'tmagan'
              : 'Этот номер ещё не зарегистрирован',
        ),
      ),
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state.checkPhoneStatus == FormzSubmissionStatus.success) {
      // Ro'yxatdan o'tmagan raqamga SMS yubormaymiz.
      if (state.checkPhone?.canLogin == false) {
        _goToRegistration();
        return;
      }
      _sendCode(context);
    }
    if (state.checkPhoneStatus == FormzSubmissionStatus.failure) {
      _showError(_messageFor(state, fallback: isUz ? 'Xato yuz berdi' : 'Произошла ошибка'));
    }

    if (state.sendCodeStatus == FormzSubmissionStatus.success) {
      _codeController.clear();
      startOtpCountdown(state.sendCodeInfo?.ttlSeconds ?? 300);
      final info = state.sendCodeInfo;
      if (info != null) showSendCodeChannelHint(context, info, isUz: isUz);
      setState(() => _step = 1);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _codeFocus.requestFocus();
      });
    }
    if (state.sendCodeStatus == FormzSubmissionStatus.failure) {
      _showError(
        _messageFor(state, fallback: isUz ? 'SMS yuborilmadi' : 'SMS не отправлен'),
        // SMS shlyuzi ishlamasa — Telegram muqobili.
        actionLabel: state.error?.kind == AuthErrorKind.smsGatewayDown
            ? (isUz ? 'Telegram orqali' : 'Через Telegram')
            : null,
        onAction: state.error?.kind == AuthErrorKind.smsGatewayDown
            ? () => context.read<AuthBloc>().add(SendCodeEvent(_pendingPhone, channel: 'telegram'))
            : null,
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
      final error = state.error;
      if (error?.kind == AuthErrorKind.userNotFound) {
        _showError(error!.errorMessage);
        _goToRegistration();
        return;
      }
      if (error != null && error.needsFreshCode) {
        _codeController.clear();
        stopOtpCountdown();
      }
      _showError(_messageFor(state, fallback: isUz ? 'Kirish amalga oshmadi' : 'Не удалось войти'));
    }
  }

  String _messageFor(AuthState state, {required String fallback}) {
    final error = state.error;
    if (error == null) return fallback;
    if (error.kind == AuthErrorKind.rateLimited) {
      return isUz
          ? 'Juda ko\'p so\'rov — biroz kutib qayta urinib ko\'ring'
          : 'Слишком много запросов — попробуйте позже';
    }
    return error.errorMessage.isEmpty ? fallback : error.errorMessage;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // AuthBloc ilova bo'yicha yagona — boshqa ekran ustimizda ochiq bo'lsa
        // uning holat o'zgarishlariga aralashmaymiz.
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
        _handleState(context, state);
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
                        if (_step == 0 && widget.notice != null) ...[
                          const SizedBox(height: 16),
                          _Notice(text: widget.notice!),
                        ],
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
        final isLoading = state.checkPhoneStatus.isInProgress || state.sendCodeStatus.isInProgress;
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
                onPressed: isLoading ? null : () => _onContinuePhone(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_BLUE,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
        final resending = state.sendCodeStatus.isInProgress;
        // Sanoq tugagach faqat "Qayta yuborish" ishlaydi.
        final canSubmit = !isLoading && !otpExpired && _codeController.text.trim().length == 6;
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
                enabled: !otpExpired,
                onChanged: (_) => setState(() {}),
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
            const SizedBox(height: 16),
            OtpCountdownBar(
              secondsLeft: otpSecondsLeft,
              verified: false,
              isUz: isUz,
              resendInProgress: resending,
              onResend: () => _sendCode(context),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canSubmit ? () => _onLogin(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_BLUE,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isUz ? 'Kirish' : 'Войти', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Boshqa ekrandan o'tkazilganda ko'rsatiladigan sariq izoh.
class _Notice extends StatelessWidget {
  final String text;
  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFFB45309)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF92400E), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
