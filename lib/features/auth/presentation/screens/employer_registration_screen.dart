import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:formz/formz.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/anketa_models.dart';
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
  final _phoneMask = MaskTextInputFormatter(
    mask: '+998 (##) ### ## ##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _sms = TextEditingController();
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
  static const int _lastStep = _total - 1;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadRegionsEvent());
  }

  void _next() {
    if (_step == _phoneStep) {
      final phone = _cleanPhone;
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
      'phone': _cleanPhone,
      'sms_code': _sms.text.trim(),
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
                          inputFormatters: [_phoneMask],
                          style: const TextStyle(fontSize: 16, color: DARK_NAVY),
                          decoration: _inputDeco('+998 (90) 123 45 67'),
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
