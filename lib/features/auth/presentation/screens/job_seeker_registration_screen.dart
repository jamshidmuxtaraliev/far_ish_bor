import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/anketa_models.dart';
import '../logic/auth_bloc.dart';
import '../../../main/presentation/screens/main_screen.dart';

class JobSeekerRegistrationScreen extends StatefulWidget {
  final String language;
  const JobSeekerRegistrationScreen({super.key, required this.language});

  @override
  State<JobSeekerRegistrationScreen> createState() => _JobSeekerRegistrationScreenState();
}

class _JobSeekerRegistrationScreenState extends State<JobSeekerRegistrationScreen> {
  final PageController _pageCtrl = PageController();
  int _step = 0;
  static const int _total = 11;

  // Step 1 – phone
  final _phone = TextEditingController();
  final _phoneMask = MaskTextInputFormatter(
    mask: '+998 (##) ### ## ##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Strips spaces and parentheses, e.g. "+998 (90) 123 45 67" -> "+998901234567"
  String get _cleanPhone => _phone.text.replaceAll(RegExp(r'[\s()]'), '');
  // Step 2 – sms code
  final _sms = TextEditingController();
  // Step 3 – name + gender
  final _fullname = TextEditingController();
  String? _gender;
  // Step 4 – birthday
  final _bdDay = TextEditingController();
  final _bdMonth = TextEditingController();
  final _bdYear = TextEditingController();
  // Step 5 – region / district / address
  RegionModel? _region;
  DistrictModel? _district;
  final _address = TextEditingController();
  // Step 6 – job type
  JobTypeModel? _jobType;
  final _jobSearch = TextEditingController();
  String _professionText = '';
  // Step 7 – experience + education
  int _experienceYear = 0;
  String _education = 'O\'rta';
  // Step 8 – salary
  final _salary = TextEditingController();
  // Step 9 – work schedule
  final Set<String> _schedules = {};
  // Step 10 – languages
  final Set<String> _languages = {};
  // Step 11 – extras
  bool _hasLicense = false;
  bool _hasCar = false;

  bool get isUz => widget.language == 'uz';

  final List<String> _educationOptions = [
    'O\'rta', 'O\'rta maxsus', 'Oliy', 'Magistr', 'Doktor'
  ];

  final List<Map<String, String>> _scheduleOptions = [
    {'key': 'full_time', 'label': 'To\'liq vaqt'},
    {'key': 'part_time', 'label': 'Yarim vaqt'},
    {'key': 'remote', 'label': 'Masofaviy'},
    {'key': 'flexible', 'label': 'Erkin grafik'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadRegionsEvent());
    context.read<AuthBloc>().add(LoadLanguagesEvent());
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _phone.dispose();
    _sms.dispose();
    _fullname.dispose();
    _bdDay.dispose();
    _bdMonth.dispose();
    _bdYear.dispose();
    _address.dispose();
    _jobSearch.dispose();
    _salary.dispose();
    super.dispose();
  }

  String? _validateStep() {
    switch (_step) {
      case 0:
        final p = _cleanPhone;
        if (p.isEmpty) return 'Telefon raqam kiriting';
        if (!p.startsWith('+998') || p.length < 13) return 'To\'g\'ri telefon raqam kiriting (+998...)';
        return null;
      case 1:
        if (_sms.text.trim().length < 6) return 'SMS kodni to\'liq kiriting';
        return null;
      case 2:
        if (_fullname.text.trim().isEmpty) return 'Ism-familiyangizni kiriting';
        if (_gender == null) return 'Jinsni tanlang';
        return null;
      case 3:
        final d = int.tryParse(_bdDay.text) ?? 0;
        final m = int.tryParse(_bdMonth.text) ?? 0;
        final y = int.tryParse(_bdYear.text) ?? 0;
        if (d < 1 || d > 31 || m < 1 || m > 12 || y < 1940 || y > 2006) {
          return 'To\'g\'ri tug\'ilgan sana kiriting (yosh 18–65)';
        }
        return null;
      case 4:
        if (_region == null) return 'Viloyat tanlang';
        if (_district == null) return 'Tuman tanlang';
        return null;
      case 5:
        if (_jobType == null && _professionText.isEmpty) return 'Kasb tanlang yoki kiriting';
        return null;
      case 7:
        final s = int.tryParse(_salary.text.replaceAll(' ', '').replaceAll(',', ''));
        if (s == null || s <= 0) return 'Kutilayotgan oylik kiriting';
        return null;
      case 8:
        if (_schedules.isEmpty) return 'Kamida bitta ish vaqtini tanlang';
        return null;
      case 9:
        if (_languages.isEmpty) return 'Kamida bitta til tanlang';
        return null;
      default:
        return null;
    }
  }

  void _next(BuildContext context) {
    final err = _validateStep();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red.shade600),
      );
      return;
    }
    if (_step == 0) {
      context.read<AuthBloc>().add(SendCodeEvent(_cleanPhone));
      return;
    }
    if (_step == _total - 1) {
      _doRegister(context);
      return;
    }
    _advance();
  }

  void _advance() {
    setState(() => _step++);
    _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _doRegister(BuildContext context) {
    final day = _bdDay.text.padLeft(2, '0');
    final month = _bdMonth.text.padLeft(2, '0');
    final year = _bdYear.text;
    final birthday = '$year-$month-$day';
    final salaryRaw = int.tryParse(_salary.text.replaceAll(' ', '').replaceAll(',', '')) ?? 0;

    final data = <String, dynamic>{
      'role': 'seeker',
      'phone': _cleanPhone,
      'sms_code': _sms.text.trim(),
      'fullname': _fullname.text.trim(),
      'gender': _gender,
      'birthday': birthday,
      'expected_salary': salaryRaw,
      'work_schedule': _schedules.toList(),
      'languages': _languages.toList(),
      'has_license': _hasLicense,
      'has_car': _hasCar,
      'experience_year': _experienceYear,
      'information': _education,
    };
    if (_region != null) data['region_id'] = _region!.id;
    if (_district != null) data['district_id'] = _district!.id;
    if (_address.text.trim().isNotEmpty) data['address'] = _address.text.trim();
    if (_jobType != null) {
      data['job_type_id'] = _jobType!.id;
      data['profession_text'] = _jobType!.name;
    } else if (_professionText.isNotEmpty) {
      data['profession_text'] = _professionText;
    }

    context.read<AuthBloc>().add(RegisterEvent(data));
  }

  double get _progress => (_step + 1) / _total;

  String get _nextLabel {
    if (_step == 0) return isUz ? 'SMS yuborish' : 'Отправить SMS';
    if (_step == _total - 1) return isUz ? 'Ro\'yxatdan o\'tish' : 'Зарегистрироваться';
    return isUz ? 'Keyingisi' : 'Далее';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.sendCodeStatus == FormzSubmissionStatus.success) {
          _advance();
        }
        if (state.sendCodeStatus == FormzSubmissionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error?.errorMessage ?? 'SMS yuborilmadi'), backgroundColor: Colors.red),
          );
        }
        if (state.registerStatus == FormzSubmissionStatus.success) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen(isEmployer: false)),
            (route) => false,
          );
        }
        if (state.registerStatus == FormzSubmissionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error?.errorMessage ?? 'Ro\'yxatdan o\'tish amalga oshmadi'), backgroundColor: Colors.red),
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
                _buildHeader(),
                _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StepPhone(ctrl: _phone, mask: _phoneMask, isUz: isUz),
                      _StepSms(ctrl: _sms, phone: _phone.text, isUz: isUz),
                      _StepNameGender(
                        ctrl: _fullname,
                        gender: _gender,
                        isUz: isUz,
                        onGender: (v) => setState(() => _gender = v),
                      ),
                      _StepBirthday(day: _bdDay, month: _bdMonth, year: _bdYear, isUz: isUz),
                      _StepLocation(
                        selectedRegion: _region,
                        selectedDistrict: _district,
                        addressCtrl: _address,
                        isUz: isUz,
                        onRegion: (r) => setState(() { _region = r; _district = null; }),
                        onDistrict: (d) => setState(() => _district = d),
                      ),
                      _StepJobType(
                        selectedJobType: _jobType,
                        searchCtrl: _jobSearch,
                        isUz: isUz,
                        onSelect: (jt) => setState(() => _jobType = jt),
                        onFreeText: (t) => setState(() { _professionText = t; _jobType = null; }),
                      ),
                      _StepExperience(
                        years: _experienceYear,
                        education: _education,
                        educationOptions: _educationOptions,
                        isUz: isUz,
                        onYears: (v) => setState(() => _experienceYear = v),
                        onEducation: (v) => setState(() => _education = v),
                      ),
                      _StepSalary(ctrl: _salary, isUz: isUz),
                      _StepSchedule(
                        selected: _schedules,
                        options: _scheduleOptions,
                        isUz: isUz,
                        onToggle: (k) => setState(() {
                          if (_schedules.contains(k)) _schedules.remove(k);
                          else _schedules.add(k);
                        }),
                        onSelectAll: () => setState(() {
                          if (_schedules.length == _scheduleOptions.length) _schedules.clear();
                          else _schedules.addAll(_scheduleOptions.map((e) => e['key']!));
                        }),
                      ),
                      _StepLanguages(
                        selected: _languages,
                        isUz: isUz,
                        onToggle: (code) => setState(() {
                          if (_languages.contains(code)) _languages.remove(code);
                          else _languages.add(code);
                        }),
                      ),
                      _StepExtras(
                        hasLicense: _hasLicense,
                        hasCar: _hasCar,
                        isUz: isUz,
                        onLicense: (v) => setState(() => _hasLicense = v),
                        onCar: (v) => setState(() => _hasCar = v),
                      ),
                    ],
                  ),
                ),
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: DARK_NAVY),
          ),
          const Spacer(),
          Text(
            'Qadam ${_step + 1} / $_total',
            style: const TextStyle(fontSize: 13, color: GRAY_TEXT, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${(_progress * 100).round()}%', style: const TextStyle(fontSize: 11, color: GRAY_TEXT)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              color: PRIMARY_BLUE,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.sendCodeStatus != c.sendCodeStatus || p.registerStatus != c.registerStatus,
      builder: (context, state) {
        final isLoading = state.sendCodeStatus.isInProgress || state.registerStatus.isInProgress;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              if (_step > 0) ...[
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: _back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DARK_NAVY,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(isUz ? 'Orqaga' : 'Назад'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _next(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_BLUE,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_nextLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Step widgets ─────────────────────────────────────────────────────────────

class _StepPhone extends StatelessWidget {
  final TextEditingController ctrl;
  final MaskTextInputFormatter mask;
  final bool isUz;
  const _StepPhone({required this.ctrl, required this.mask, required this.isUz});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.phone_outlined,
      title: isUz ? 'Telefon raqami' : 'Номер телефона',
      subtitle: isUz ? '+998 bilan boshlang' : 'Начните с +998',
      child: _Field(ctrl: ctrl, hint: '+998 (90) 123 45 67', keyboardType: TextInputType.phone, autofocus: true, inputFormatters: [mask]),
    );
  }
}

class _StepSms extends StatelessWidget {
  final TextEditingController ctrl;
  final String phone;
  final bool isUz;
  const _StepSms({required this.ctrl, required this.phone, required this.isUz});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.message_outlined,
      title: isUz ? 'SMS kodni kiriting' : 'Введите SMS код',
      subtitle: '$phone ga yuborildi',
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: DARK_NAVY, letterSpacing: 10),
        decoration: InputDecoration(
          hintText: '------',
          hintStyle: const TextStyle(color: GRAY_TEXT, letterSpacing: 10, fontSize: 28),
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 2)),
        ),
      ),
    );
  }
}

class _StepNameGender extends StatelessWidget {
  final TextEditingController ctrl;
  final String? gender;
  final bool isUz;
  final ValueChanged<String> onGender;
  const _StepNameGender({required this.ctrl, required this.gender, required this.isUz, required this.onGender});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.person_outline,
      title: isUz ? 'To\'liq ism va jins' : 'ФИО и пол',
      subtitle: isUz ? 'Familiya Ism Otasining ismi' : 'Фамилия Имя Отчество',
      child: Column(
        children: [
          _Field(ctrl: ctrl, hint: isUz ? 'Aliyev Vali Akmalovich' : 'Иванов Иван Иванович'),
          const SizedBox(height: 20),
          const Align(alignment: Alignment.centerLeft, child: _Label('Jins *')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _GenderBtn(label: isUz ? '👨 Erkak' : '👨 Мужской', value: 'male', selected: gender, onTap: onGender)),
              const SizedBox(width: 12),
              Expanded(child: _GenderBtn(label: isUz ? '👩 Ayol' : '👩 Женский', value: 'female', selected: gender, onTap: onGender)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderBtn extends StatelessWidget {
  final String label;
  final String value;
  final String? selected;
  final ValueChanged<String> onTap;
  const _GenderBtn({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? PRIMARY_BLUE : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? PRIMARY_BLUE : DARK_NAVY))),
      ),
    );
  }
}

class _StepBirthday extends StatelessWidget {
  final TextEditingController day, month, year;
  final bool isUz;
  const _StepBirthday({required this.day, required this.month, required this.year, required this.isUz});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.cake_outlined,
      title: isUz ? 'Tug\'ilgan sana' : 'Дата рождения',
      subtitle: isUz ? 'Yosh 18 dan 65 gacha bo\'lishi kerak' : 'Возраст от 18 до 65 лет',
      child: Row(
        children: [
          Expanded(flex: 2, child: _Field(ctrl: day, hint: 'KK', keyboardType: TextInputType.number, maxLength: 2, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('/', style: TextStyle(fontSize: 22, color: GRAY_TEXT))),
          Expanded(flex: 2, child: _Field(ctrl: month, hint: 'OO', keyboardType: TextInputType.number, maxLength: 2, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('/', style: TextStyle(fontSize: 22, color: GRAY_TEXT))),
          Expanded(flex: 3, child: _Field(ctrl: year, hint: 'YYYY', keyboardType: TextInputType.number, maxLength: 4, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
        ],
      ),
    );
  }
}

class _StepLocation extends StatelessWidget {
  final RegionModel? selectedRegion;
  final DistrictModel? selectedDistrict;
  final TextEditingController addressCtrl;
  final bool isUz;
  final ValueChanged<RegionModel> onRegion;
  final ValueChanged<DistrictModel> onDistrict;

  const _StepLocation({
    required this.selectedRegion,
    required this.selectedDistrict,
    required this.addressCtrl,
    required this.isUz,
    required this.onRegion,
    required this.onDistrict,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.location_on_outlined,
      title: isUz ? 'Joylashuv' : 'Местоположение',
      subtitle: isUz ? 'Viloyat, tuman va aniq manzil' : 'Область, район и адрес',
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (p, c) => p.regions != c.regions || p.regionsStatus != c.regionsStatus,
        builder: (context, state) {
          if (state.regionsStatus.isInProgress) {
            return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: PRIMARY_BLUE, strokeWidth: 2)));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Viloyat *'),
              const SizedBox(height: 6),
              _DropdownField<RegionModel>(
                value: selectedRegion,
                items: state.regions,
                display: (r) => r.name,
                hint: 'Viloyatni tanlang',
                onChanged: onRegion,
              ),
              const SizedBox(height: 16),
              const _Label('Tuman *'),
              const SizedBox(height: 6),
              _DropdownField<DistrictModel>(
                value: selectedDistrict,
                items: selectedRegion?.districts ?? [],
                display: (d) => d.name,
                hint: selectedRegion == null ? 'Avval viloyat tanlang' : 'Tumanni tanlang',
                onChanged: onDistrict,
              ),
              const SizedBox(height: 16),
              const _Label('Aniq manzil (ixtiyoriy)'),
              const SizedBox(height: 6),
              _Field(ctrl: addressCtrl, hint: 'Chilonzor 5-kvartal'),
            ],
          );
        },
      ),
    );
  }
}

class _StepJobType extends StatefulWidget {
  final JobTypeModel? selectedJobType;
  final TextEditingController searchCtrl;
  final bool isUz;
  final ValueChanged<JobTypeModel> onSelect;
  final ValueChanged<String> onFreeText;

  const _StepJobType({
    required this.selectedJobType,
    required this.searchCtrl,
    required this.isUz,
    required this.onSelect,
    required this.onFreeText,
  });

  @override
  State<_StepJobType> createState() => _StepJobTypeState();
}

class _StepJobTypeState extends State<_StepJobType> {
  final _freeCtrl = TextEditingController();

  @override
  void dispose() {
    _freeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.work_outline,
      title: widget.isUz ? 'Kasb' : 'Профессия',
      subtitle: widget.isUz ? 'Qidiring yoki qo\'lda kiriting' : 'Найдите или введите вручную',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(
            ctrl: widget.searchCtrl,
            hint: widget.isUz ? 'Kasbni qidiring...' : 'Поиск профессии...',
            onChanged: (v) {
              if (v.length >= 2) context.read<AuthBloc>().add(LoadJobTypesEvent(text: v));
            },
          ),
          if (widget.selectedJobType != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: PRIMARY_BLUE, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.selectedJobType!.name, style: const TextStyle(color: PRIMARY_BLUE, fontWeight: FontWeight.w600, fontSize: 14))),
                  GestureDetector(
                    onTap: () { widget.onFreeText(''); widget.searchCtrl.clear(); },
                    child: const Icon(Icons.close, color: PRIMARY_BLUE, size: 18),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (p, c) => p.jobTypes != c.jobTypes || p.jobTypesStatus != c.jobTypesStatus,
            builder: (context, state) {
              if (state.jobTypesStatus.isInProgress) {
                return const Padding(padding: EdgeInsets.all(8), child: Center(child: CircularProgressIndicator(color: PRIMARY_BLUE, strokeWidth: 2)));
              }
              if (state.jobTypes.isEmpty && widget.searchCtrl.text.length >= 2 && widget.selectedJobType == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Topilmadi. Qo\'lda kiriting:', style: TextStyle(fontSize: 12, color: GRAY_TEXT)),
                    const SizedBox(height: 8),
                    _Field(ctrl: _freeCtrl, hint: 'Kasbni kiriting...', onChanged: widget.onFreeText),
                  ],
                );
              }
              if (state.jobTypes.isEmpty || widget.selectedJobType != null) return const SizedBox.shrink();
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: state.jobTypes.take(7).map((jt) => ListTile(
                    dense: true,
                    title: Text(jt.name, style: const TextStyle(fontSize: 14, color: DARK_NAVY)),
                    onTap: () {
                      widget.onSelect(jt);
                      widget.searchCtrl.text = jt.name;
                    },
                  )).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepExperience extends StatelessWidget {
  final int years;
  final String education;
  final List<String> educationOptions;
  final bool isUz;
  final ValueChanged<int> onYears;
  final ValueChanged<String> onEducation;

  const _StepExperience({
    required this.years,
    required this.education,
    required this.educationOptions,
    required this.isUz,
    required this.onYears,
    required this.onEducation,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.school_outlined,
      title: isUz ? 'Tajriba va ta\'lim' : 'Опыт и образование',
      subtitle: isUz ? 'Ish staji va ta\'lim darajangiz' : 'Стаж работы и уровень образования',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Ish tajribasi (yil)'),
          const SizedBox(height: 12),
          Row(
            children: [
              _CounterBtn(icon: Icons.remove, onTap: years > 0 ? () => onYears(years - 1) : null),
              const SizedBox(width: 16),
              Container(
                width: 88,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text('$years yil', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PRIMARY_BLUE))),
              ),
              const SizedBox(width: 16),
              _CounterBtn(icon: Icons.add, isPrimary: true, onTap: years < 60 ? () => onYears(years + 1) : null),
            ],
          ),
          const SizedBox(height: 24),
          const _Label('Ta\'lim darajasi'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: educationOptions.map((e) {
              final isSelected = education == e;
              return GestureDetector(
                onTap: () => onEducation(e),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? PRIMARY_BLUE : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
                  ),
                  child: Text(e, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? PRIMARY_BLUE : DARK_NAVY)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  const _CounterBtn({required this.icon, this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? PRIMARY_BLUE : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : (onTap != null ? DARK_NAVY : GRAY_TEXT)),
      ),
    );
  }
}

class _StepSalary extends StatelessWidget {
  final TextEditingController ctrl;
  final bool isUz;
  const _StepSalary({required this.ctrl, required this.isUz});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.attach_money,
      title: isUz ? 'Kutilayotgan oylik' : 'Ожидаемая зарплата',
      subtitle: isUz ? 'So\'m hisobida kiriting' : 'Введите в сумах',
      child: _Field(
        ctrl: ctrl,
        hint: '8000000',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        suffix: 'so\'m',
      ),
    );
  }
}

class _StepSchedule extends StatelessWidget {
  final Set<String> selected;
  final List<Map<String, String>> options;
  final bool isUz;
  final ValueChanged<String> onToggle;
  final VoidCallback onSelectAll;

  const _StepSchedule({required this.selected, required this.options, required this.isUz, required this.onToggle, required this.onSelectAll});

  @override
  Widget build(BuildContext context) {
    final allSelected = selected.length == options.length;
    return _StepWrapper(
      icon: Icons.schedule_outlined,
      title: isUz ? 'Ish vaqti' : 'График работы',
      subtitle: isUz ? 'Bir yoki bir nechta tanlang' : 'Выберите один или несколько',
      child: Column(
        children: [
          _SelectableCard(
            label: isUz ? 'Barchasini tanlash' : 'Выбрать все',
            isSelected: allSelected,
            onTap: onSelectAll,
          ),
          const SizedBox(height: 8),
          ...options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SelectableCard(
              label: opt['label']!,
              isSelected: selected.contains(opt['key']!),
              onTap: () => onToggle(opt['key']!),
            ),
          )),
        ],
      ),
    );
  }
}

class _StepLanguages extends StatelessWidget {
  final Set<String> selected;
  final bool isUz;
  final ValueChanged<String> onToggle;

  const _StepLanguages({required this.selected, required this.isUz, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.language_outlined,
      title: isUz ? 'Tillar' : 'Языки',
      subtitle: isUz ? 'Biladigan tillaringizni tanlang' : 'Выберите языки',
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (p, c) => p.languages != c.languages || p.languagesStatus != c.languagesStatus,
        builder: (context, state) {
          if (state.languagesStatus.isInProgress) {
            return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE, strokeWidth: 2));
          }
          final langs = state.languages.isNotEmpty
              ? state.languages
              : [
                  LanguageModel(code: 'uz', name: "O'zbek tili"),
                  LanguageModel(code: 'ru', name: 'Rus tili'),
                  LanguageModel(code: 'en', name: 'Ingliz tili'),
                ];
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: langs.map((lang) {
              final isSelected = selected.contains(lang.code);
              return GestureDetector(
                onTap: () => onToggle(lang.code),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? PRIMARY_BLUE : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
                  ),
                  child: Text(lang.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? PRIMARY_BLUE : DARK_NAVY)),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _StepExtras extends StatelessWidget {
  final bool hasLicense, hasCar;
  final bool isUz;
  final ValueChanged<bool> onLicense, onCar;

  const _StepExtras({required this.hasLicense, required this.hasCar, required this.isUz, required this.onLicense, required this.onCar});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      icon: Icons.more_horiz,
      title: isUz ? 'Qo\'shimcha ma\'lumot' : 'Дополнительно',
      subtitle: isUz ? 'Ixtiyoriy, lekin foydali' : 'Необязательно, но полезно',
      child: Column(
        children: [
          _CheckCard(
            label: isUz ? 'Haydovchilik guvohnomasi bor' : 'Есть водительские права',
            value: hasLicense,
            icon: Icons.drive_eta_outlined,
            onChanged: onLicense,
          ),
          const SizedBox(height: 12),
          _CheckCard(
            label: isUz ? 'Shaxsiy avtomobili bor' : 'Есть личный автомобиль',
            value: hasCar,
            icon: Icons.directions_car_outlined,
            onChanged: onCar,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: PRIMARY_BLUE, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isUz
                        ? 'Anketangiz to\'ldirilgandan so\'ng mos vakansiyalar ko\'rsatiladi'
                        : 'После заполнения анкеты будут показаны подходящие вакансии',
                    style: const TextStyle(fontSize: 13, color: PRIMARY_BLUE),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _StepWrapper extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget child;

  const _StepWrapper({required this.icon, required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [PRIMARY_BLUE, Color(0xFF3B82F6)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DARK_NAVY)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DARK_NAVY));
  }
}

class _SelectableCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SelectableCard({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? PRIMARY_BLUE : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? PRIMARY_BLUE : DARK_NAVY))),
            if (isSelected) const Icon(Icons.check_circle, color: PRIMARY_BLUE, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  final String label;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _CheckCard({required this.label, required this.value, required this.icon, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value ? PRIMARY_BLUE : const Color(0xFFE2E8F0), width: value ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: value ? PRIMARY_BLUE : GRAY_TEXT, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: value ? PRIMARY_BLUE : DARK_NAVY))),
            Icon(value ? Icons.check_box : Icons.check_box_outline_blank, color: value ? PRIMARY_BLUE : GRAY_TEXT, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType? keyboardType;
  final bool autofocus;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffix;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.ctrl,
    required this.hint,
    this.keyboardType,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      autofocus: autofocus,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: DARK_NAVY),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: GRAY_TEXT),
        counterText: '',
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) display;
  final String hint;
  final ValueChanged<T> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.display,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                    final isSelected = value != null && display(value as T) == display(item);
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
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value != null ? PRIMARY_BLUE : const Color(0xFFE2E8F0), width: value != null ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? display(value as T) : hint,
                style: TextStyle(fontSize: 15, color: value != null ? DARK_NAVY : GRAY_TEXT),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: GRAY_TEXT),
          ],
        ),
      ),
    );
  }
}
