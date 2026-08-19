import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:formz/formz.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/anketa_models.dart';
import '../../data/models/auth_error_kind.dart';
import '../logic/auth_bloc.dart';
import '../widgets/auth_snack.dart';
import '../widgets/otp_countdown.dart';
import 'login_screen.dart';
import 'verification_success_screen.dart';

class EmployerRegistrationScreen extends StatefulWidget {
  final String language;

  /// Kirish ekranidan o'tkazilganda raqam avtomatik to'ldiriladi.
  final String? initialPhone;

  const EmployerRegistrationScreen({super.key, required this.language, this.initialPhone});

  @override
  State<EmployerRegistrationScreen> createState() => _EmployerRegistrationScreenState();
}

class _EmployerRegistrationScreenState extends State<EmployerRegistrationScreen>
    with OtpCountdownMixin {
  final PageController _pageCtrl = PageController();
  int _step = 0;
  static const int _total = 7;

  final _companyName = TextEditingController();
  late final TextEditingController _phone;
  late final MaskTextInputFormatter _phoneMask;
  final _sms = TextEditingController();

  /// Kod ana shu raqamga yuborilgan.
  String _pendingPhone = '';
  final _contactPerson = TextEditingController();
  final _email = TextEditingController();
  RegionModel? _region;
  DistrictModel? _district;
  String _activityType = '';

  bool get isUz => widget.language == 'uz';

  List<String> get _activities => isUz
      ? ['IT va texnologiya', 'Savdo', 'Qurilish', 'Moliya', "Ta'lim", 'Boshqa']
      : ['IT и технологии', 'Торговля', 'Строительство', 'Финансы', 'Образование', 'Другое'];

  // Strips spaces and parentheses, e.g. "+998 (90) 123 45 67" -> "+998901234567"
  String get _cleanPhone => _phone.text.replaceAll(RegExp(r'[\s()]'), '');

  // Phone entry is on step 1, SMS on step 2
  static const int _phoneStep = 1;
  static const int _smsStep = 2;
  static const int _lastStep = _total - 1;

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
    _phone = TextEditingController(text: local.isEmpty ? '' : _phoneMask.getMaskedText());
    context.read<AuthBloc>().add(LoadRegionsEvent());
    // Oldingi ekranda qolgan chipta bu oqimga tegishli emas.
    context.read<AuthBloc>().add(ClearRegTokenEvent());
  }

  void _next() {
    if (_step == _phoneStep) {
      final phone = _cleanPhone;
      if (!phone.startsWith('+998') || phone.length < 13) {
        _showError(isUz
            ? 'To\'g\'ri telefon raqam kiriting (+998...)'
            : 'Введите корректный номер (+998...)');
        return;
      }
      // Bekorga SMS ketmasin: raqam bazada bo'lsa Kirish ekraniga o'tkazamiz.
      _pendingPhone = phone;
      context.read<AuthBloc>().add(CheckPhoneEvent(phone));
      return;
    }
    if (_step == _smsStep) {
      // Tasdiqlangan kod bilan orqaga qaytib kelingan bo'lsa qayta so'ramaymiz.
      if (otpVerified) {
        _advance();
        return;
      }
      if (otpExpired) {
        _showError(isUz ? 'Kod muddati tugadi — yangi kod oling' : 'Срок кода истёк — запросите новый');
        return;
      }
      if (_sms.text.trim().length < 6) {
        _showError(isUz ? 'SMS kodni to\'liq kiriting' : 'Введите код полностью');
        return;
      }
      context.read<AuthBloc>().add(VerifyCodeEvent(_pendingPhone, _sms.text.trim()));
      return;
    }
    if (_step == _lastStep) {
      _doRegister();
      return;
    }
    _advance();
  }

  void _advance() {
    if (_step < _total - 1) {
      setState(() => _step++);
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _doRegister() {
    final regToken = context.read<AuthBloc>().state.regToken;
    final data = <String, dynamic>{
      'role': 'employer',
      'phone': _pendingPhone.isEmpty ? _cleanPhone : _pendingPhone,
      // Chipta bor bo'lsa kod allaqachon sarflangan — `sms_code` yuborilmaydi.
      if (regToken != null) 'reg_token': regToken else 'sms_code': _sms.text.trim(),
    };
    if (_companyName.text.trim().isNotEmpty) data['company_name'] = _companyName.text.trim();
    if (_contactPerson.text.trim().isNotEmpty) data['name'] = _contactPerson.text.trim();
    if (_region != null) data['region_id'] = _region!.id;
    if (_district != null) data['district_id'] = _district!.id;
    context.read<AuthBloc>().add(RegisterEvent(data));
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showError(String message, {String? actionLabel, VoidCallback? onAction}) {
    showAuthSnack(context, message, actionLabel: actionLabel, onAction: onAction);
  }

  /// Chipta eskirganda kod qadamiga qaytadi — to'ldirilgan anketa saqlanadi.
  void _returnToSmsStep() {
    _sms.clear();
    stopOtpCountdown();
    setState(() {
      otpVerified = false;
      _step = _smsStep;
    });
    _pageCtrl.jumpToPage(_smsStep);
    context.read<AuthBloc>().add(SendCodeEvent(_pendingPhone));
  }

  void _goToLogin(String notice) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          language: widget.language,
          initialPhone: _pendingPhone.isEmpty ? _cleanPhone : _pendingPhone,
          notice: notice,
        ),
      ),
    );
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

  static const String _alreadyRegisteredUz =
      'Bu raqam allaqachon ro\'yxatdan o\'tgan — kirish uchun kod oling';
  static const String _alreadyRegisteredRu =
      'Этот номер уже зарегистрирован — получите код для входа';

  void _handleState(AuthState state) {
    if (state.checkPhoneStatus == FormzSubmissionStatus.success) {
      if (state.checkPhone?.registered == true) {
        _goToLogin(isUz ? _alreadyRegisteredUz : _alreadyRegisteredRu);
        return;
      }
      context.read<AuthBloc>().add(SendCodeEvent(_pendingPhone));
    }
    if (state.checkPhoneStatus == FormzSubmissionStatus.failure) {
      _showError(_messageFor(state, fallback: isUz ? 'Raqamni tekshirib bo\'lmadi' : 'Не удалось проверить номер'));
    }

    if (state.sendCodeStatus == FormzSubmissionStatus.success) {
      _sms.clear();
      startOtpCountdown(state.sendCodeInfo?.ttlSeconds ?? 300);
      if (_step == _phoneStep) _advance();
      final info = state.sendCodeInfo;
      if (info != null) showSendCodeChannelHint(context, info, isUz: isUz);
    }
    if (state.sendCodeStatus == FormzSubmissionStatus.failure) {
      final gatewayDown = state.error?.kind == AuthErrorKind.smsGatewayDown;
      _showError(
        _messageFor(state, fallback: isUz ? 'SMS yuborilmadi' : 'SMS не отправлен'),
        // SMS shlyuzi ishlamasa — Telegram muqobili.
        actionLabel: gatewayDown ? (isUz ? 'Telegram orqali' : 'Через Telegram') : null,
        onAction: gatewayDown
            ? () => context.read<AuthBloc>().add(SendCodeEvent(_pendingPhone, channel: 'telegram'))
            : null,
      );
    }

    if (state.verifyCodeStatus == FormzSubmissionStatus.success) {
      if (state.checkPhone?.registered == true) {
        _goToLogin(isUz ? _alreadyRegisteredUz : _alreadyRegisteredRu);
        return;
      }
      markOtpVerified();
      _advance();
    }
    if (state.verifyCodeStatus == FormzSubmissionStatus.failure) {
      // Xato kod bilan keyingi qadamga o'tkazilmaydi.
      _sms.clear();
      if (state.error?.needsFreshCode ?? false) stopOtpCountdown();
      _showError(_messageFor(state, fallback: isUz ? 'Kod tasdiqlanmadi' : 'Код не подтверждён'));
    }

    if (state.registerStatus == FormzSubmissionStatus.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerificationSuccessScreen(
            language: widget.language,
            isEmployer: true,
            name: _companyName.text.isEmpty ? 'Kompaniya' : _companyName.text,
          ),
        ),
      );
    }
    if (state.registerStatus == FormzSubmissionStatus.failure) {
      final error = state.error;
      if (error?.kind == AuthErrorKind.phoneAlreadyRegistered) {
        _goToLogin(error!.errorMessage);
        return;
      }
      if (error?.kind == AuthErrorKind.regTokenInvalid) {
        _showError(error!.errorMessage);
        _returnToSmsStep();
        return;
      }
      _showError(_messageFor(state, fallback: isUz ? "Ro'yxatdan o'tishda xato" : 'Ошибка регистрации'));
    }
  }

  String get _btnLabel {
    if (_step == _lastStep) return isUz ? 'Yakunlash' : 'Завершить';
    if (_step == _phoneStep) return isUz ? 'Kod olish' : 'Получить код';
    if (_step == _smsStep) return isUz ? 'Davom etish' : 'Продолжить';
    return isUz ? 'Keyingi' : 'Далее';
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _companyName.dispose();
    _phone.dispose();
    _sms.dispose();
    _contactPerson.dispose();
    _email.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String hint, {bool counter = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: GRAY_TEXT),
      counterText: counter ? null : '',
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 2)),
    );
  }

  Widget _labelField(String label, TextEditingController ctrl, {TextInputType type = TextInputType.text, String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DARK_NAVY)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 15, color: DARK_NAVY),
          decoration: _inputDeco(hint),
        ),
      ],
    );
  }

  Widget _dropdownField(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DARK_NAVY)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value.isEmpty ? null : value,
          hint: Text(isUz ? 'Tanlang' : 'Выберите', style: const TextStyle(color: GRAY_TEXT)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          style: const TextStyle(color: DARK_NAVY, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _modelDropdown<T>(String label, List<T> items, T? value, String Function(T) display, ValueChanged<T?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DARK_NAVY)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            if (items.isEmpty) return;
            final result = await showModalBottomSheet<T>(
              context: context,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (ctx) => Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: items.map((item) {
                        final isSelected = value != null && display(value) == display(item);
                        return ListTile(
                          title: Text(display(item), style: TextStyle(fontSize: 14, color: isSelected ? PRIMARY_BLUE : DARK_NAVY, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                          trailing: isSelected ? const Icon(Icons.check, color: PRIMARY_BLUE) : null,
                          onTap: () => Navigator.pop(ctx, item),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
            if (result != null) onChanged(result);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: value != null ? PRIMARY_BLUE : const Color(0xFFE5E7EB), width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? display(value) : (isUz ? 'Tanlang' : 'Выберите'),
                    style: TextStyle(fontSize: 15, color: value != null ? DARK_NAVY : GRAY_TEXT),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: GRAY_TEXT),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // AuthBloc ilova bo'yicha yagona — boshqa ekran ustimizda ochiq bo'lsa
        // uning holat o'zgarishlariga aralashmaymiz.
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
        _handleState(state);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _back,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: _step == 0 ? const Color(0xFFD1D5DB) : DARK_NAVY,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${isUz ? "Qadam" : "Шаг"} ${_step + 1} ${isUz ? "dan" : "из"} $_total',
                            style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _total,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(PRIMARY_BLUE),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _page(
                        icon: Icons.business_outlined,
                        title: isUz ? 'Kompaniya nomi' : 'Название компании',
                        child: TextField(
                          controller: _companyName,
                          style: const TextStyle(fontSize: 16, color: DARK_NAVY),
                          decoration: _inputDeco(isUz ? 'Kompaniya nomini kiriting' : 'Введите название компании'),
                        ),
                      ),
                      _page(
                        icon: Icons.phone_outlined,
                        title: isUz ? 'Telefon raqam' : 'Номер телефона',
                        subtitle: isUz ? 'SMS kod yuboramiz' : 'Отправим SMS код',
                        child: TextField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneMask],
                          style: const TextStyle(fontSize: 16, color: DARK_NAVY),
                          decoration: _inputDeco('+998 (90) 123 45 67'),
                        ),
                      ),
                      _page(
                        icon: Icons.chat_bubble_outline,
                        title: isUz ? 'SMS kodni kiriting' : 'Введите SMS код',
                        subtitle: _phone.text,
                        footer: OtpCountdownBar(
                          secondsLeft: otpSecondsLeft,
                          verified: otpVerified,
                          isUz: isUz,
                          onResend: () => context.read<AuthBloc>().add(SendCodeEvent(_pendingPhone)),
                        ),
                        child: TextField(
                          controller: _sms,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          enabled: !otpVerified && !otpExpired,
                          onChanged: (_) => setState(() {}),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.bold, color: DARK_NAVY),
                          decoration: _inputDeco('_ _ _ _ _ _', counter: true),
                        ),
                      ),
                      _page(
                        icon: Icons.location_on_outlined,
                        title: isUz ? 'Joylashuv va faoliyat' : 'Местоположение и деятельность',
                        child: BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (p, c) => p.regions != c.regions || p.regionsStatus != c.regionsStatus,
                          builder: (context, state) {
                            if (state.regionsStatus.isInProgress) {
                              return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: PRIMARY_BLUE, strokeWidth: 2)));
                            }
                            return Column(
                              children: [
                                _modelDropdown<RegionModel>(
                                  isUz ? 'Viloyat' : 'Область',
                                  state.regions,
                                  _region,
                                  (r) => r.name,
                                  (v) => setState(() { _region = v; _district = null; }),
                                ),
                                const SizedBox(height: 16),
                                _modelDropdown<DistrictModel>(
                                  isUz ? 'Tuman/Shahar' : 'Район/Город',
                                  _region?.districts ?? [],
                                  _district,
                                  (d) => d.name,
                                  (v) => setState(() => _district = v),
                                ),
                                const SizedBox(height: 16),
                                _dropdownField(isUz ? 'Faoliyat turi' : 'Вид деятельности', _activities, _activityType, (v) => setState(() => _activityType = v ?? '')),
                              ],
                            );
                          },
                        ),
                      ),
                      _page(
                        icon: Icons.person_outline,
                        title: isUz ? "Mas'ul shaxs" : 'Контактное лицо',
                        child: TextField(
                          controller: _contactPerson,
                          style: const TextStyle(fontSize: 16, color: DARK_NAVY),
                          decoration: _inputDeco(isUz ? 'Ism Familiya' : 'Имя Фамилия'),
                        ),
                      ),
                      _page(
                        icon: Icons.mail_outline,
                        title: isUz ? "Bog'lanish" : 'Контакты',
                        child: _labelField('Email', _email, type: TextInputType.emailAddress, hint: 'company@example.com'),
                      ),
                      _page(
                        icon: Icons.camera_alt_outlined,
                        title: isUz ? 'Kompaniya logotipi (ixtiyoriy)' : 'Логотип компании (необязательно)',
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.business_outlined, size: 48, color: GRAY_TEXT),
                              const SizedBox(height: 16),
                              Text(
                                isUz ? 'Kompaniya logotipini yuklang' : 'Загрузите логотип компании',
                                style: const TextStyle(color: GRAY_TEXT, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = (_step == _phoneStep &&
                            (state.checkPhoneStatus.isInProgress || state.sendCodeStatus.isInProgress)) ||
                        (_step == _smsStep &&
                            (state.verifyCodeStatus.isInProgress || state.sendCodeStatus.isInProgress)) ||
                        (_step == _lastStep && state.registerStatus.isInProgress);
                    // Kod qadamida: sanoq tugagan bo'lsa faqat "Qayta yuborish" ishlaydi.
                    final blockedOnOtp = _step == _smsStep && !otpVerified && otpExpired;
                    return Container(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading || blockedOnOtp ? null : _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMARY_BLUE,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                blockedOnOtp ? const Color(0xFFCBD5E1) : PRIMARY_BLUE.withValues(alpha: 0.7),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(_btnLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _page({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,

    /// Maydondan keyin qo'yiladigan qo'shimcha blok (masalan, orqa sanoq).
    Widget? footer,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [PRIMARY_BLUE, SECONDARY_BLUE]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DARK_NAVY)),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: GRAY_TEXT, fontSize: 14)),
          ],
          const SizedBox(height: 24),
          child,
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer,
          ],
        ],
      ),
    );
  }
}
