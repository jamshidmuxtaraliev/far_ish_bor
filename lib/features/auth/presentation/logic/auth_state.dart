part of 'auth_bloc.dart';

@immutable
class AuthState extends Equatable {
  final FormzSubmissionStatus checkPhoneStatus;
  final FormzSubmissionStatus sendCodeStatus;
  final FormzSubmissionStatus verifyCodeStatus;
  final FormzSubmissionStatus registerStatus;
  final FormzSubmissionStatus loginStatus;
  final FormzSubmissionStatus getMeStatus;
  final FormzSubmissionStatus anketaStatus;
  final FormzSubmissionStatus updateAnketaStatus;
  final FormzSubmissionStatus regionsStatus;
  final FormzSubmissionStatus jobTypesStatus;
  final FormzSubmissionStatus languagesStatus;
  final FormzSubmissionStatus employerStatus;
  final FormzSubmissionStatus updateEmployerStatus;
  final FormzSubmissionStatus branchesStatus;
  final FormzSubmissionStatus saveBranchStatus;
  final FormzSubmissionStatus deleteBranchStatus;
  final FormzSubmissionStatus uploadLogoStatus;
  final FormzSubmissionStatus uploadPhotoStatus;
  final FormzSubmissionStatus resumeInfoStatus;
  final FormzSubmissionStatus downloadResumeStatus;
  final ErrorModel? error;
  final UserModel? user;
  final AnketaModel? anketa;
  final EmployerModel? employer;
  final List<BranchModel> branches;
  final List<RegionModel> regions;
  final List<JobTypeModel> jobTypes;
  final List<LanguageModel> languages;
  final ResumeInfoModel? resume;

  /// Oxirgi `check-phone` natijasi — qaysi ekranga o'tishni hal qiladi.
  final CheckPhoneModel? checkPhone;

  /// Oxirgi `send-code` natijasi; orqa sanoq `ttlSeconds` dan boshlanadi.
  final SendCodeModel? sendCodeInfo;

  /// Tasdiqlangan kod o'rniga berilgan 30 daqiqalik chipta.
  final String? regToken;

  /// [regToken] qachon eskirishi — ekranlar shunga qarab qayta kod so'raydi.
  final DateTime? regTokenExpiresAt;

  /// 0..1 — yuklab olish foizi.
  final double resumeProgress;

  /// Oxirgi saqlangan PDF yo'li (offline ochish uchun).
  final String? resumeFilePath;

  /// `/anketa/resume` 404 qaytardi — foydalanuvchi hali anketa to'ldirmagan.
  final bool anketaMissing;

  const AuthState({
    this.checkPhoneStatus = FormzSubmissionStatus.initial,
    this.sendCodeStatus = FormzSubmissionStatus.initial,
    this.verifyCodeStatus = FormzSubmissionStatus.initial,
    this.registerStatus = FormzSubmissionStatus.initial,
    this.loginStatus = FormzSubmissionStatus.initial,
    this.getMeStatus = FormzSubmissionStatus.initial,
    this.anketaStatus = FormzSubmissionStatus.initial,
    this.updateAnketaStatus = FormzSubmissionStatus.initial,
    this.regionsStatus = FormzSubmissionStatus.initial,
    this.jobTypesStatus = FormzSubmissionStatus.initial,
    this.languagesStatus = FormzSubmissionStatus.initial,
    this.employerStatus = FormzSubmissionStatus.initial,
    this.updateEmployerStatus = FormzSubmissionStatus.initial,
    this.branchesStatus = FormzSubmissionStatus.initial,
    this.saveBranchStatus = FormzSubmissionStatus.initial,
    this.deleteBranchStatus = FormzSubmissionStatus.initial,
    this.uploadLogoStatus = FormzSubmissionStatus.initial,
    this.uploadPhotoStatus = FormzSubmissionStatus.initial,
    this.resumeInfoStatus = FormzSubmissionStatus.initial,
    this.downloadResumeStatus = FormzSubmissionStatus.initial,
    this.error,
    this.user,
    this.anketa,
    this.employer,
    this.branches = const [],
    this.regions = const [],
    this.jobTypes = const [],
    this.languages = const [],
    this.resume,
    this.checkPhone,
    this.sendCodeInfo,
    this.regToken,
    this.regTokenExpiresAt,
    this.resumeProgress = 0,
    this.resumeFilePath,
    this.anketaMissing = false,
  });

  AuthState copyWith({
    FormzSubmissionStatus? checkPhoneStatus,
    FormzSubmissionStatus? sendCodeStatus,
    FormzSubmissionStatus? verifyCodeStatus,
    FormzSubmissionStatus? registerStatus,
    FormzSubmissionStatus? loginStatus,
    FormzSubmissionStatus? getMeStatus,
    FormzSubmissionStatus? anketaStatus,
    FormzSubmissionStatus? updateAnketaStatus,
    FormzSubmissionStatus? regionsStatus,
    FormzSubmissionStatus? jobTypesStatus,
    FormzSubmissionStatus? languagesStatus,
    FormzSubmissionStatus? employerStatus,
    FormzSubmissionStatus? updateEmployerStatus,
    FormzSubmissionStatus? branchesStatus,
    FormzSubmissionStatus? saveBranchStatus,
    FormzSubmissionStatus? deleteBranchStatus,
    FormzSubmissionStatus? uploadLogoStatus,
    FormzSubmissionStatus? uploadPhotoStatus,
    FormzSubmissionStatus? resumeInfoStatus,
    FormzSubmissionStatus? downloadResumeStatus,
    ErrorModel? error,
    UserModel? user,
    AnketaModel? anketa,
    EmployerModel? employer,
    List<BranchModel>? branches,
    List<RegionModel>? regions,
    List<JobTypeModel>? jobTypes,
    List<LanguageModel>? languages,
    ResumeInfoModel? resume,
    CheckPhoneModel? checkPhone,
    SendCodeModel? sendCodeInfo,
    String? regToken,
    DateTime? regTokenExpiresAt,

    /// Chipta faqat shu bayroq bilan tozalanadi — `copyWith` null'ni e'tiborsiz
    /// qoldiradi.
    bool clearRegToken = false,
    double? resumeProgress,
    String? resumeFilePath,
    bool? anketaMissing,
  }) {
    return AuthState(
      checkPhoneStatus: checkPhoneStatus ?? this.checkPhoneStatus,
      sendCodeStatus: sendCodeStatus ?? this.sendCodeStatus,
      verifyCodeStatus: verifyCodeStatus ?? this.verifyCodeStatus,
      registerStatus: registerStatus ?? this.registerStatus,
      loginStatus: loginStatus ?? this.loginStatus,
      getMeStatus: getMeStatus ?? this.getMeStatus,
      anketaStatus: anketaStatus ?? this.anketaStatus,
      updateAnketaStatus: updateAnketaStatus ?? this.updateAnketaStatus,
      regionsStatus: regionsStatus ?? this.regionsStatus,
      jobTypesStatus: jobTypesStatus ?? this.jobTypesStatus,
      languagesStatus: languagesStatus ?? this.languagesStatus,
      employerStatus: employerStatus ?? this.employerStatus,
      updateEmployerStatus: updateEmployerStatus ?? this.updateEmployerStatus,
      branchesStatus: branchesStatus ?? this.branchesStatus,
      saveBranchStatus: saveBranchStatus ?? this.saveBranchStatus,
      deleteBranchStatus: deleteBranchStatus ?? this.deleteBranchStatus,
      uploadLogoStatus: uploadLogoStatus ?? this.uploadLogoStatus,
      uploadPhotoStatus: uploadPhotoStatus ?? this.uploadPhotoStatus,
      resumeInfoStatus: resumeInfoStatus ?? this.resumeInfoStatus,
      downloadResumeStatus: downloadResumeStatus ?? this.downloadResumeStatus,
      error: error ?? this.error,
      user: user ?? this.user,
      anketa: anketa ?? this.anketa,
      employer: employer ?? this.employer,
      branches: branches ?? this.branches,
      regions: regions ?? this.regions,
      jobTypes: jobTypes ?? this.jobTypes,
      languages: languages ?? this.languages,
      resume: resume ?? this.resume,
      checkPhone: checkPhone ?? this.checkPhone,
      sendCodeInfo: sendCodeInfo ?? this.sendCodeInfo,
      regToken: clearRegToken ? null : (regToken ?? this.regToken),
      regTokenExpiresAt:
          clearRegToken ? null : (regTokenExpiresAt ?? this.regTokenExpiresAt),
      resumeProgress: resumeProgress ?? this.resumeProgress,
      resumeFilePath: resumeFilePath ?? this.resumeFilePath,
      anketaMissing: anketaMissing ?? this.anketaMissing,
    );
  }

  @override
  List<Object?> get props => [
        checkPhoneStatus, sendCodeStatus, verifyCodeStatus,
        registerStatus, loginStatus, getMeStatus,
        anketaStatus, updateAnketaStatus, regionsStatus, jobTypesStatus, languagesStatus,
        employerStatus, updateEmployerStatus, uploadLogoStatus, uploadPhotoStatus,
        branchesStatus, saveBranchStatus, deleteBranchStatus,
        resumeInfoStatus, downloadResumeStatus,
        error, user, anketa, employer, branches, regions, jobTypes, languages,
        resume, checkPhone, sendCodeInfo, regToken, regTokenExpiresAt,
        resumeProgress, resumeFilePath, anketaMissing,
      ];
}
