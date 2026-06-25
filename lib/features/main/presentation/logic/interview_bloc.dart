import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/error_model.dart';
import '../../data/datasource/interview_realtime_datasource.dart';
import '../../data/datasource/remote/interview_remote_data_source.dart';
import '../../data/models/interview_model.dart';

part 'interview_event.dart';
part 'interview_state.dart';

/// Suhbatlar — ro'yxatlar (seeker/employer), yo'l holati va jonli GPS oqimi.
class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final InterviewRemoteDataSource remote;
  final InterviewRealtimeDatasource realtime;

  StreamSubscription? _locationSub;
  StreamSubscription? _travelSub;
  StreamSubscription? _connSub;

  InterviewBloc(this.remote, this.realtime) : super(const InterviewState()) {
    on<LoadMyInterviewsEvent>(_onLoadMy);
    on<LoadEmployerInterviewsEvent>(_onLoadEmployer);
    on<LoadLiveInterviewsEvent>(_onLoadLive);
    on<UpdateTravelStatusEvent>(_onUpdateTravel);
    on<ConnectSocketEvent>(_onConnect);
    on<DisconnectSocketEvent>(_onDisconnect);
    on<SendLocationEvent>(_onSendLocation);
    on<_LiveLocationReceived>(_onLiveLocation);
    on<_LiveTravelReceived>(_onLiveTravel);
    on<_SocketConnectionChanged>(_onConnChanged);

    _locationSub = realtime.onLocation.listen(
      (e) => add(_LiveLocationReceived(e.interviewId, e.location)),
    );
    _travelSub = realtime.onTravelStatus.listen(
      (e) => add(_LiveTravelReceived(e.interviewId, e.travelStatus)),
    );
    _connSub = realtime.onConnectionChanged.listen(
      (c) => add(_SocketConnectionChanged(c)),
    );
  }

  Future<void> _onLoadMy(
      LoadMyInterviewsEvent event, Emitter<InterviewState> emit) async {
    emit(state.copyWith(myStatus: FormzSubmissionStatus.inProgress));
    final result = await remote.getMyInterviews();
    result.fold(
      (f) => emit(state.copyWith(
          myStatus: FormzSubmissionStatus.failure, error: f)),
      (list) => emit(state.copyWith(
          myStatus: FormzSubmissionStatus.success, myInterviews: list)),
    );
  }

  Future<void> _onLoadEmployer(
      LoadEmployerInterviewsEvent event, Emitter<InterviewState> emit) async {
    emit(state.copyWith(employerStatus: FormzSubmissionStatus.inProgress));
    final result = await remote.getEmployerInterviews();
    result.fold(
      (f) => emit(state.copyWith(
          employerStatus: FormzSubmissionStatus.failure, error: f)),
      (list) => emit(state.copyWith(
          employerStatus: FormzSubmissionStatus.success,
          employerInterviews: list)),
    );
  }

  Future<void> _onLoadLive(
      LoadLiveInterviewsEvent event, Emitter<InterviewState> emit) async {
    emit(state.copyWith(liveStatus: FormzSubmissionStatus.inProgress));
    final result = await remote.getLiveInterviews();
    result.fold(
      (f) => emit(state.copyWith(
          liveStatus: FormzSubmissionStatus.failure, error: f)),
      (list) {
        final live = Map<int, LiveLocation>.from(state.liveById);
        final travel = Map<int, String>.from(state.travelById);
        for (final i in list) {
          travel[i.id] = i.travelStatus;
          if (i.seekerLat != null && i.seekerLng != null) {
            live[i.id] = LiveLocation(
              lat: i.seekerLat!,
              lng: i.seekerLng!,
              accuracy: i.seekerAccuracy,
              heading: i.seekerHeading,
              at: i.locationAt ?? DateTime.now(),
            );
          }
        }
        emit(state.copyWith(
          liveStatus: FormzSubmissionStatus.success,
          liveById: live,
          travelById: travel,
        ));
      },
    );
  }

  Future<void> _onUpdateTravel(
      UpdateTravelStatusEvent event, Emitter<InterviewState> emit) async {
    emit(state.copyWith(travelUpdateStatus: FormzSubmissionStatus.inProgress));
    final result =
        await remote.updateTravelStatus(event.interviewId, event.travelStatus);
    result.fold(
      (f) => emit(state.copyWith(
          travelUpdateStatus: FormzSubmissionStatus.failure, error: f)),
      (_) {
        final travel = Map<int, String>.from(state.travelById)
          ..[event.interviewId] = event.travelStatus;
        emit(state.copyWith(
          travelUpdateStatus: FormzSubmissionStatus.success,
          travelById: travel,
        ));
      },
    );
    emit(state.copyWith(travelUpdateStatus: FormzSubmissionStatus.initial));
  }

  void _onConnect(ConnectSocketEvent event, Emitter<InterviewState> emit) {
    realtime.connect();
  }

  void _onDisconnect(
      DisconnectSocketEvent event, Emitter<InterviewState> emit) {
    realtime.disconnect();
  }

  void _onSendLocation(SendLocationEvent event, Emitter<InterviewState> emit) {
    realtime.sendLocation(
      interviewId: event.interviewId,
      lat: event.lat,
      lng: event.lng,
      accuracy: event.accuracy,
      heading: event.heading,
    );
  }

  void _onLiveLocation(
      _LiveLocationReceived event, Emitter<InterviewState> emit) {
    final live = Map<int, LiveLocation>.from(state.liveById)
      ..[event.interviewId] = event.location;
    emit(state.copyWith(liveById: live));
  }

  void _onLiveTravel(_LiveTravelReceived event, Emitter<InterviewState> emit) {
    final travel = Map<int, String>.from(state.travelById)
      ..[event.interviewId] = event.travelStatus;
    emit(state.copyWith(travelById: travel));
  }

  void _onConnChanged(
      _SocketConnectionChanged event, Emitter<InterviewState> emit) {
    emit(state.copyWith(socketConnected: event.connected));
  }

  @override
  Future<void> close() {
    _locationSub?.cancel();
    _travelSub?.cancel();
    _connSub?.cancel();
    realtime.disconnect();
    return super.close();
  }
}
