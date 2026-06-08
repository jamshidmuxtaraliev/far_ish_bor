import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../../core/constants/colors.dart';
import '../logic/auth_bloc.dart';
import 'verification_success_screen.dart';

class EmployerRegistrationScreen extends StatefulWidget {
  final String language;
  const EmployerRegistrationScreen({super.key, required this.language});

  @override
  State<EmployerRegistrationScreen> createState() => _EmployerRegistrationScreenState();
}

class _EmployerRegistrationScreenState extends State<EmployerRegistrationScreen> {
  final PageController _pageCtrl = PageController();
  int _step = 0;
  static const int _total = 7;

  final _companyName = TextEditingController();
  final _phone = TextEditingController();
  final _sms = TextEditingController();
  final _district = TextEditingController();
  final _contactPerson = TextEditingController();
  final _email = TextEditingController();
  String _region = '';
  String _activityType = '';

  bool get isUz => widget.language == 'uz';

  final _regions = ['Toshkent', 'Samarqand', 'Buxoro', 'Andijon', "Farg'ona", 'Namangan'];

  List<String> get _activities => isUz
      ? ['IT va texnologiya', 'Savdo', 'Qurilish', 'Moliya', "Ta'lim", 'Boshqa']
      : ['IT и технологии', 'Торговля', 'Строительство', 'Финансы', 'Образование', 'Другое'];

  // Phone entry is on step 1, SMS on step 2
  static const int _phoneStep = 1;
  static const int _lastStep = _total - 1;

  void _next() {
    if (_step == _phoneStep) {
      final phone = _phone.text.trim();
      if (phone.isEmpty) {
        _showError(isUz ? 'Telefon raqam kiriting' : 'Введите номер телефона');
        return;
      }
      context.read<AuthBloc>().add(SendCodeEvent(phone));
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
    final data = <String, dynamic>{
      'role': 'employer',
      'phone': _phone.text.trim(),
      'sms_code': _sms.text.trim(),
    };
    if (_companyName.text.trim().isNotEmpty) data['company_name'] = _companyName.text.trim();
    if (_contactPerson.text.trim().isNotEmpty) data['name'] = _contactPerson.text.trim();
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }

  String get _btnLabel {
    if (_step == _lastStep) return isUz ? 'Yakunlash' : 'Завершить';
    if (_step == _phoneStep) return isUz ? 'Kod olish' : 'Получить код';
    if (_step == 2) return isUz ? 'Tasdiqlash' : 'Подтвердить';
    return isUz ? 'Keyingi' : 'Далее';
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _companyName.dispose();
    _phone.dispose();
    _sms.dispose();
    _district.dispose();
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

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.sendCodeStatus == FormzSubmissionStatus.failure) {
          _showError(state.error?.errorMessage ?? (isUz ? 'Xato yuz berdi' : 'Произошла ошибка'));
        } else if (state.sendCodeStatus == FormzSubmissionStatus.success) {
          _advance();
        }
        if (state.registerStatus == FormzSubmissionStatus.failure) {
          _showError(state.error?.errorMessage ?? (isUz ? "Ro'yxatdan o'tishda xato" : 'Ошибка регистрации'));
        } else if (state.registerStatus == FormzSubmissionStatus.success) {
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
                          style: const TextStyle(fontSize: 16, color: DARK_NAVY),
                          decoration: _inputDeco('+998 XX XXX XX XX'),
                        ),
                      ),
                      _page(
                        icon: Icons.chat_bubble_outline,
                        title: isUz ? 'SMS kodni kiriting' : 'Введите SMS код',
                        subtitle: _phone.text,
                        child: TextField(
                          controller: _sms,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.bold, color: DARK_NAVY),
                          decoration: _inputDeco('_ _ _ _ _ _', counter: true),
                        ),
                      ),
                      _page(
                        icon: Icons.location_on_outlined,
                        title: isUz ? 'Joylashuv va faoliyat' : 'Местоположение и деятельность',
                        child: Column(
                          children: [
                            _dropdownField(isUz ? 'Viloyat' : 'Область', _regions, _region, (v) => setState(() => _region = v ?? '')),
                            const SizedBox(height: 16),
                            _labelField(isUz ? 'Tuman/Shahar' : 'Район/Город', _district),
                            const SizedBox(height: 16),
                            _dropdownField(isUz ? 'Faoliyat turi' : 'Вид деятельности', _activities, _activityType, (v) => setState(() => _activityType = v ?? '')),
                          ],
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
                    final isLoading = (_step == _phoneStep && state.sendCodeStatus.isInProgress) ||
                        (_step == _lastStep && state.registerStatus.isInProgress);
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
                          onPressed: isLoading ? null : _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMARY_BLUE,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: PRIMARY_BLUE.withValues(alpha: 0.7),
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

  Widget _page({required IconData icon, required String title, String? subtitle, required Widget child}) {
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
        ],
      ),
    );
  }
}
