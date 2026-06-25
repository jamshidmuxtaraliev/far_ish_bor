part of 'interview_bloc.dart';

@immutable
class InterviewState extends Equatable {
  final FormzSubmissionStatus myStatus;
  final FormzSubmissionStatus employerStatus;
  final FormzSubmissionStatus liveStatus;
  final FormzSubmissionStatus travelUpdateStatus;

  final List<InterviewModel> myInterviews;
  final List<InterviewModel> employerInterviews;

  /// interview_id → oxirgi jonli koordinata (socket yoki `live` REST'dan).
  final Map<int, LiveLocation> liveById;

  /// interview_id → joriy travel_status (socket yoki REST yangilanishidan).
  final Map<int, String> travelById;

  final bool socketConnected;
  final ErrorModel? error;

  const InterviewState({
    this.myStatus = FormzSubmissionStatus.initial,
    this.employerStatus = FormzSubmissionStatus.initial,
    this.liveStatus = FormzSubmissionStatus.initial,
    this.travelUpdateStatus = FormzSubmissionStatus.initial,
    this.myInterviews = const [],
    this.employerInterviews = const [],
    this.liveById = const {},
    this.travelById = const {},
    this.socketConnected = false,
    this.error,
  });

  InterviewState copyWith({
    FormzSubmissionStatus? myStatus,
    FormzSubmissionStatus? employerStatus,
    FormzSubmissionStatus? liveStatus,
    FormzSubmissionStatus? travelUpdateStatus,
    List<InterviewModel>? myInterviews,
    List<InterviewModel>? employerInterviews,
    Map<int, LiveLocation>? liveById,
    Map<int, String>? travelById,
    bool? socketConnected,
    ErrorModel? error,
  }) {
    return InterviewState(
      myStatus: myStatus ?? this.myStatus,
      employerStatus: employerStatus ?? this.employerStatus,
      liveStatus: liveStatus ?? this.liveStatus,
      travelUpdateStatus: travelUpdateStatus ?? this.travelUpdateStatus,
      myInterviews: myInterviews ?? this.myInterviews,
      employerInterviews: employerInterviews ?? this.employerInterviews,
      liveById: liveById ?? this.liveById,
      travelById: travelById ?? this.travelById,
      socketConnected: socketConnected ?? this.socketConnected,
      error: error ?? this.error,
    );
  }

  /// Suhbatning eng so'nggi travel_status'i (jonli yangilanish ustun).
  String travelOf(InterviewModel i) => travelById[i.id] ?? i.travelStatus;

  @override
  List<Object?> get props => [
        myStatus,
        employerStatus,
        liveStatus,
        travelUpdateStatus,
        myInterviews,
        employerInterviews,
        liveById,
        travelById,
        socketConnected,
        error,
      ];
}
