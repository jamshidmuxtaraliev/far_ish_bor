import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/anketa_models.dart';
import '../logic/auth_bloc.dart';
import '../widgets/anketa_steps/step1_personal.dart';
import '../widgets/anketa_steps/step2_location.dart';
import '../widgets/anketa_steps/step3_job.dart';
import '../widgets/anketa_steps/step4_skills.dart';
import '../widgets/anketa_steps/step5_additional.dart';

class AnketaScreen extends StatefulWidget {
  const AnketaScreen({super.key});

  @override
  State<AnketaScreen> createState() => _AnketaScreenState();
}

class _AnketaScreenState extends State<AnketaScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Step 1 — Personal
  final _fullnameController = TextEditingController();
  String? _gender;
  DateTime? _birthday;

  // Step 2 — Location
  RegionModel? _selectedRegion;
  DistrictModel? _selectedDistrict;

  // Step 3 — Job
  JobTypeModel? _selectedJobType;
  final _experienceController = TextEditingController();
  final _expectedSalaryController = TextEditingController();
  String? _workStatus;
  String? _workSchedule;

  // Step 4 — Skills
  List<String> _selectedLanguages = [];
  bool _hasLicense = false;
  bool _hasCar = false;
  bool _physicalWorkOk = false;
  bool _computerLiteracy = false;

  // Step 5 — Additional
  final _motivationController = TextEditingController();
  final _prevJobReasonController = TextEditingController();
  final _additionalContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AuthBloc>();
    bloc.add(LoadAnketaEvent());
    bloc.add(LoadRegionsEvent());
    bloc.add(LoadLanguagesEvent());
    bloc.add(LoadJobTypesEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullnameController.dispose();
    _experienceController.dispose();
    _expectedSalaryController.dispose();
    _motivationController.dispose();
    _prevJobReasonController.dispose();
    _additionalContactController.dispose();
    super.dispose();
  }

  void _prefillFromAnketa(AnketaModel anketa) {
    if (_fullnameController.text.isEmpty && anketa.fullname != null) {
      _fullnameController.text = anketa.fullname!;
    }
    _gender ??= anketa.gender;
    if (_birthday == null && anketa.birthday != null) {
      try {
        _birthday = DateTime.parse(anketa.birthday!);
      } catch (_) {}
    }
    if (_experienceController.text.isEmpty && anketa.experienceYear != null) {
      _experienceController.text = anketa.experienceYear.toString();
    }
    if (_expectedSalaryController.text.isEmpty && anketa.expectedSalary != null) {
      _expectedSalaryController.text = anketa.expectedSalary.toString();
    }
    _workStatus ??= anketa.workStatus;
    _workSchedule ??= anketa.workSchedule;
    if (_selectedLanguages.isEmpty && anketa.languages.isNotEmpty) {
      _selectedLanguages = List.from(anketa.languages);
    }
    _hasLicense = anketa.hasLicense ?? false;
    _hasCar = anketa.hasCar ?? false;
    _physicalWorkOk = anketa.physicalWorkOk ?? false;
    _computerLiteracy = anketa.computerLiteracy ?? false;
    if (_motivationController.text.isEmpty && anketa.motivation != null) {
      _motivationController.text = anketa.motivation!;
    }
    if (_prevJobReasonController.text.isEmpty && anketa.previousJobReason != null) {
      _prevJobReasonController.text = anketa.previousJobReason!;
    }
    if (_additionalContactController.text.isEmpty && anketa.additionalContact != null) {
      _additionalContactController.text = anketa.additionalContact!;
    }
    setState(() {});
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() {
    final data = <String, dynamic>{};

    if (_fullnameController.text.trim().isNotEmpty) {
      data['fullname'] = _fullnameController.text.trim();
    }
    if (_gender != null) data['gender'] = _gender;
    if (_birthday != null) {
      data['birthday'] =
          '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}';
    }
    if (_selectedRegion != null) data['region_id'] = _selectedRegion!.id;
    if (_selectedDistrict != null) data['district_id'] = _selectedDistrict!.id;
    if (_selectedJobType != null) data['job_type_id'] = _selectedJobType!.id;
    if (_experienceController.text.trim().isNotEmpty) {
      data['experience_year'] = int.tryParse(_experienceController.text.trim()) ?? 0;
    }
    if (_expectedSalaryController.text.trim().isNotEmpty) {
      data['expected_salary'] = int.tryParse(_expectedSalaryController.text.trim()) ?? 0;
    }
    if (_workStatus != null) data['work_status'] = _workStatus;
    if (_workSchedule != null) data['work_schedule'] = _workSchedule;
    if (_selectedLanguages.isNotEmpty) data['languages'] = _selectedLanguages;
    data['has_license'] = _hasLicense;
    data['has_car'] = _hasCar;
    data['physical_work_ok'] = _physicalWorkOk;
    data['computer_literacy'] = _computerLiteracy;
    if (_motivationController.text.trim().isNotEmpty) {
      data['motivation'] = _motivationController.text.trim();
    }
    if (_prevJobReasonController.text.trim().isNotEmpty) {
      data['previous_job_reason'] = _prevJobReasonController.text.trim();
    }
    if (_additionalContactController.text.trim().isNotEmpty) {
      data['additional_contact'] = _additionalContactController.text.trim();
    }

    context.read<AuthBloc>().add(UpdateAnketaEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.anketaStatus != curr.anketaStatus ||
          prev.updateAnketaStatus != curr.updateAnketaStatus,
      listener: (context, state) {
        if (state.anketaStatus.isSuccess && state.anketa != null) {
          _prefillFromAnketa(state.anketa!);
        }
        if (state.updateAnketaStatus.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Anketa muvaffaqiyatli saqlandi"),
              backgroundColor: GREEN_COLOR,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
        if (state.updateAnketaStatus.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error?.errorMessage ?? "Xatolik yuz berdi"),
              backgroundColor: RED_COLOR,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: LIGHT_GRAY_BG,
          body: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Step1Personal(
                      fullnameController: _fullnameController,
                      gender: _gender,
                      birthday: _birthday,
                      onGenderChanged: (v) => setState(() => _gender = v),
                      onBirthdayChanged: (v) => setState(() => _birthday = v),
                    ),
                    Step2Location(
                      selectedRegion: _selectedRegion,
                      selectedDistrict: _selectedDistrict,
                      onRegionChanged: (r) => setState(() {
                        _selectedRegion = r;
                        _selectedDistrict = null;
                      }),
                      onDistrictChanged: (d) => setState(() => _selectedDistrict = d),
                    ),
                    Step3Job(
                      selectedJobType: _selectedJobType,
                      experienceController: _experienceController,
                      expectedSalaryController: _expectedSalaryController,
                      workStatus: _workStatus,
                      workSchedule: _workSchedule,
                      onJobTypeChanged: (j) => setState(() => _selectedJobType = j),
                      onWorkStatusChanged: (v) => setState(() => _workStatus = v),
                      onWorkScheduleChanged: (v) => setState(() => _workSchedule = v),
                    ),
                    Step4Skills(
                      selectedLanguages: _selectedLanguages,
                      hasLicense: _hasLicense,
                      hasCar: _hasCar,
                      physicalWorkOk: _physicalWorkOk,
                      computerLiteracy: _computerLiteracy,
                      onLanguagesChanged: (v) => setState(() => _selectedLanguages = v),
                      onLicenseChanged: (v) => setState(() => _hasLicense = v),
                      onCarChanged: (v) => setState(() => _hasCar = v),
                      onPhysicalChanged: (v) => setState(() => _physicalWorkOk = v),
                      onComputerChanged: (v) => setState(() => _computerLiteracy = v),
                    ),
                    Step5Additional(
                      motivationController: _motivationController,
                      prevJobReasonController: _prevJobReasonController,
                      additionalContactController: _additionalContactController,
                    ),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      "Shaxsiy ma'lumotlar",
      "Manzil",
      "Kasb va tajriba",
      "Ko'nikmalar",
      "Qo'shimcha",
    ];
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevStep,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anketa to\'ldirish',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  titles[_currentStep],
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: PRIMARY_BLUE.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentStep + 1} / $_totalSteps',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final isCompleted = i < _currentStep;
          final isActive = i == _currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted
                    ? GREEN_COLOR
                    : isActive
                        ? PRIMARY_BLUE
                        : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.updateAnketaStatus != c.updateAnketaStatus,
      builder: (context, state) {
        final isLoading = state.updateAnketaStatus.isInProgress;
        final isLastStep = _currentStep == _totalSteps - 1;
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: Row(
            children: [
              if (_currentStep > 0) ...[
                GestureDetector(
                  onTap: _prevStep,
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: LIGHT_GRAY_BG,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: DARK_NAVY, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: isLoading ? null : _nextStep,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [PRIMARY_BLUE, SECONDARY_BLUE]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: PRIMARY_BLUE.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastStep ? 'Saqlash' : 'Davom etish',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
