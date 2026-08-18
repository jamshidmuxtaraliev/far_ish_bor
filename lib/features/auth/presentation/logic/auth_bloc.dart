import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/error_model.dart';
import '../../../../core/services/get_it.dart';
import '../../data/datasource/local/user_local_data_source.dart';
import '../../data/models/anketa_models.dart';
import '../../data/models/employer_model.dart';
import '../../data/models/resume_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/auth_repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(const AuthState()) {
    on<SendCodeEvent>(_onSendCode);
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<GetMeEvent>(_onGetMe);
    on<LoadAnketaEvent>(_onLoadAnketa);
    on<UpdateAnketaEvent>(_onUpdateAnketa);
    on<LoadRegionsEvent>(_onLoadRegions);
    on<LoadJobTypesEvent>(_onLoadJobTypes);
    on<LoadLanguagesEvent>(_onLoadLanguages);
    on<LoadEmployerEvent>(_onLoadEmployer);
    on<UpdateEmployerEvent>(_onUpdateEmployer);
    on<UploadLogoEvent>(_onUploadLogo);
    on<UploadPhotoEvent>(_onUploadPhoto);
    on<LoadResumeInfoEvent>(_onLoadResumeInfo);
    on<DownloadResumeEvent>(_onDownloadResume);
    on<ResumeProgressEvent>(
      (event, emit) => emit(state.copyWith(resumeProgress: event.progress)),
    );
  }

  Future<void> _onSendCode(SendCodeEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(sendCodeStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.sendCode(event.phone);
    result.fold(
      (failure) => emit(state.copyWith(sendCodeStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) => emit(state.copyWith(sendCodeStatus: FormzSubmissionStatus.success)),
    );
    emit(state.copyWith(sendCodeStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(registerStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.register(event.data);
    result.fold(
      (failure) => emit(state.copyWith(registerStatus: FormzSubmissionStatus.failure, error: failure)),
      (response) {
        getIt<UserLocalDatasource>().saveToken(response.token);
        getIt<UserLocalDatasource>().saveRole(response.role);
        // Cached user is what builds the support-chat session_key.
        if (response.user != null) {
          getIt<UserLocalDatasource>().saveUser(response.user!);
        }
        emit(state.copyWith(registerStatus: FormzSubmissionStatus.success, user: response.user));
      },
    );
    emit(state.copyWith(registerStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.login(event.phone, event.smsCode);
    result.fold(
      (failure) => emit(state.copyWith(loginStatus: FormzSubmissionStatus.failure, error: failure)),
      (response) {
        getIt<UserLocalDatasource>().saveToken(response.token);
        getIt<UserLocalDatasource>().saveRole(response.role);
        if (response.user != null) {
          getIt<UserLocalDatasource>().saveUser(response.user!);
        }
        emit(state.copyWith(loginStatus: FormzSubmissionStatus.success, user: response.user));
      },
    );
    emit(state.copyWith(loginStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onGetMe(GetMeEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(getMeStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getMe();
    result.fold(
      (failure) => emit(state.copyWith(getMeStatus: FormzSubmissionStatus.failure, error: failure)),
      (user) {
        getIt<UserLocalDatasource>().saveUser(user);
        emit(state.copyWith(getMeStatus: FormzSubmissionStatus.success, user: user));
      },
    );
    emit(state.copyWith(getMeStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadAnketa(LoadAnketaEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(anketaStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getAnketa();
    result.fold(
      (failure) => emit(state.copyWith(anketaStatus: FormzSubmissionStatus.failure, error: failure)),
      (anketa) => emit(state.copyWith(anketaStatus: FormzSubmissionStatus.success, anketa: anketa)),
    );
    emit(state.copyWith(anketaStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onUpdateAnketa(UpdateAnketaEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(updateAnketaStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.updateAnketa(event.data);
    await result.fold(
      (failure) async => emit(state.copyWith(updateAnketaStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(updateAnketaStatus: FormzSubmissionStatus.success));
        final refresh = await repository.getAnketa();
        refresh.fold((_) {}, (anketa) => emit(state.copyWith(anketa: anketa)));
        final meRefresh = await repository.getMe();
        meRefresh.fold((_) {}, (user) => emit(state.copyWith(user: user)));
        // Tahrirdan keyin submission_status "yangi"ga qaytadi → rezyume yopiladi.
        final resume = await repository.getResumeInfo();
        resume.fold((_) {}, (info) => emit(state.copyWith(resume: info)));
      },
    );
    emit(state.copyWith(updateAnketaStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadRegions(LoadRegionsEvent event, Emitter<AuthState> emit) async {
    if (state.regions.isNotEmpty) return;
    emit(state.copyWith(regionsStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getRegions();
    result.fold(
      (failure) => emit(state.copyWith(regionsStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(regionsStatus: FormzSubmissionStatus.success, regions: list)),
    );
    emit(state.copyWith(regionsStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadJobTypes(LoadJobTypesEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(jobTypesStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getJobTypes(text: event.text);
    result.fold(
      (failure) => emit(state.copyWith(jobTypesStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(jobTypesStatus: FormzSubmissionStatus.success, jobTypes: list)),
    );
    emit(state.copyWith(jobTypesStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadLanguages(LoadLanguagesEvent event, Emitter<AuthState> emit) async {
    if (state.languages.isNotEmpty) return;
    emit(state.copyWith(languagesStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getLanguages();
    result.fold(
      (failure) => emit(state.copyWith(languagesStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(languagesStatus: FormzSubmissionStatus.success, languages: list)),
    );
    emit(state.copyWith(languagesStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadEmployer(LoadEmployerEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(employerStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getEmployer();
    result.fold(
      (failure) => emit(state.copyWith(employerStatus: FormzSubmissionStatus.failure, error: failure)),
      (employer) => emit(state.copyWith(employerStatus: FormzSubmissionStatus.success, employer: employer)),
    );
    emit(state.copyWith(employerStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onUploadLogo(UploadLogoEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(uploadLogoStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.uploadLogo(event.filePath);
    await result.fold(
      (failure) async => emit(state.copyWith(uploadLogoStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(uploadLogoStatus: FormzSubmissionStatus.success));
        final refresh = await repository.getEmployer();
        refresh.fold((_) {}, (employer) => emit(state.copyWith(employer: employer)));
      },
    );
    emit(state.copyWith(uploadLogoStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onUploadPhoto(UploadPhotoEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(uploadPhotoStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.uploadPhoto(event.filePath);
    await result.fold(
      (failure) async => emit(state.copyWith(uploadPhotoStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(uploadPhotoStatus: FormzSubmissionStatus.success));
        final refresh = await repository.getAnketa();
        refresh.fold((_) {}, (anketa) => emit(state.copyWith(anketa: anketa)));
        // Surat qo'shilishi rezyume tugmasini ochib yuborishi mumkin.
        final resume = await repository.getResumeInfo();
        resume.fold((_) {}, (info) => emit(state.copyWith(resume: info)));
      },
    );
    emit(state.copyWith(uploadPhotoStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadResumeInfo(LoadResumeInfoEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(resumeInfoStatus: FormzSubmissionStatus.inProgress));

    // Oldingi sessiyada yuklangan fayl hali turgan bo'lsa — internetsiz ham
    // ochib berish uchun tiklaymiz.
    if (state.resumeFilePath == null) {
      final saved = await _savedResumePath();
      if (saved != null) emit(state.copyWith(resumeFilePath: saved));
    }

    final result = await repository.getResumeInfo();
    result.fold(
      (failure) => emit(state.copyWith(
        resumeInfoStatus: FormzSubmissionStatus.failure,
        error: failure,
        // 404 — anketa umuman yo'q; boshqa xatolar (tarmoq) bunday emas.
        anketaMissing: failure.errorCode == 404,
      )),
      (info) => emit(state.copyWith(
        resumeInfoStatus: FormzSubmissionStatus.success,
        resume: info,
        anketaMissing: false,
      )),
    );
    emit(state.copyWith(resumeInfoStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onDownloadResume(DownloadResumeEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(
      downloadResumeStatus: FormzSubmissionStatus.inProgress,
      resumeProgress: 0,
    ));

    // Havola har chaqiruvda yangilanadi — eskisini ishlatib bo'lmaydi.
    final infoResult = await repository.getResumeInfo();
    final info = infoResult.fold<ResumeInfoModel?>((failure) {
      emit(state.copyWith(downloadResumeStatus: FormzSubmissionStatus.failure, error: failure));
      return null;
    }, (info) {
      emit(state.copyWith(resume: info));
      return info;
    });

    if (info == null) {
      emit(state.copyWith(downloadResumeStatus: FormzSubmissionStatus.initial));
      return;
    }

    if (!info.ready || info.url == null) {
      emit(state.copyWith(
        downloadResumeStatus: FormzSubmissionStatus.failure,
        error: ErrorModel(
          info.message ?? 'Rezyume hozircha tayyor emas',
          errorCode: -1,
        ),
      ));
      emit(state.copyWith(downloadResumeStatus: FormzSubmissionStatus.initial));
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/${_safeFilename(info.filename)}';
    void onProgress(int received, int total) {
      final expected = total > 0 ? total : (info.size ?? 0);
      if (expected > 0) {
        add(ResumeProgressEvent((received / expected).clamp(0.0, 1.0)));
      }
    }

    var result = await repository.downloadResume(
      info.url!,
      savePath,
      onProgress: onProgress,
    );
    if (result.isLeft()) {
      // Tokensiz havola ishlamadi — zaxira yo'l: token bilan /resume.pdf.
      add(ResumeProgressEvent(0));
      final fallback = await repository.downloadResumeDirect(
        savePath,
        onProgress: onProgress,
      );
      if (fallback.isRight()) result = fallback;
    }

    await result.fold(
      (failure) async => emit(state.copyWith(
        downloadResumeStatus: FormzSubmissionStatus.failure,
        error: failure,
      )),
      (path) async {
        await getIt<UserLocalDatasource>().saveResumeFilename(path.split('/').last);
        emit(state.copyWith(
          downloadResumeStatus: FormzSubmissionStatus.success,
          resumeFilePath: path,
          resumeProgress: 1,
        ));
      },
    );
    emit(state.copyWith(downloadResumeStatus: FormzSubmissionStatus.initial));
  }

  /// Saqlangan nom bo'yicha faylni topadi — yo'q bo'lsa `null`.
  Future<String?> _savedResumePath() async {
    final name = getIt<UserLocalDatasource>().getResumeFilename();
    if (name == null || name.isEmpty) return null;
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$name';
    return await File(path).exists() ? path : null;
  }

  /// Serverdan kelgan nomni ishlatamiz, lekin papkadan chiqib ketmasligi uchun
  /// faqat oxirgi segmentni olamiz.
  String _safeFilename(String? filename) {
    final base = (filename ?? '').split(RegExp(r'[\\/]')).last.trim();
    return base.isEmpty ? 'rezyume.pdf' : base;
  }

  Future<void> _onUpdateEmployer(UpdateEmployerEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(updateEmployerStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.updateEmployer(event.data);
    await result.fold(
      (failure) async => emit(state.copyWith(updateEmployerStatus: FormzSubmissionStatus.failure, error: failure)),
      (employer) async {
        emit(state.copyWith(updateEmployerStatus: FormzSubmissionStatus.success, employer: employer));
        final meRefresh = await repository.getMe();
        meRefresh.fold((_) {}, (user) => emit(state.copyWith(user: user)));
      },
    );
    emit(state.copyWith(updateEmployerStatus: FormzSubmissionStatus.initial));
  }
}
