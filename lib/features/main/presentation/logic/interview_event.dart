part of 'interview_bloc.dart';

@immutable
sealed class InterviewEvent {
  const InterviewEvent();
}

/// Seeker: mening suhbatlarim ro'yxatini yuklash.
class LoadMyInterviewsEvent extends InterviewEvent {
  const LoadMyInterviewsEvent();
}

/// Employer: rejalashtirilgan suhbatlar ro'yxatini yuklash.
class LoadEmployerInterviewsEvent extends InterviewEvent {
  const LoadEmployerInterviewsEvent();
}

/// Employer: jonli (on_way) suhbatlarni tiklash (Track ochilganda).
class LoadLiveInterviewsEvent extends InterviewEvent {
  const LoadLiveInterviewsEvent();
}

/// Seeker: yo'l holatini o'zgartirish (on_way | arrived | stopped).
class UpdateTravelStatusEvent extends InterviewEvent {
  final int interviewId;
  final String travelStatus;
  const UpdateTravelStatusEvent(this.interviewId, this.travelStatus);
}

/// Socketni ulash / uzish.
class ConnectSocketEvent extends InterviewEvent {
  const ConnectSocketEvent();
}

class DisconnectSocketEvent extends InterviewEvent {
  const DisconnectSocketEvent();
}

/// Seeker: joriy GPS nuqtasini socket orqali yuborish.
class SendLocationEvent extends InterviewEvent {
  final int interviewId;
  final double lat;
  final double lng;
  final double? accuracy;
  final double? heading;
  const SendLocationEvent({
    required this.interviewId,
    required this.lat,
    required this.lng,
    this.accuracy,
    this.heading,
  });
}

// ── Ichki (socket oqimidan) ──────────────────────────────────────────────────

class _LiveLocationReceived extends InterviewEvent {
  final int interviewId;
  final LiveLocation location;
  const _LiveLocationReceived(this.interviewId, this.location);
}

class _LiveTravelReceived extends InterviewEvent {
  final int interviewId;
  final String travelStatus;
  const _LiveTravelReceived(this.interviewId, this.travelStatus);
}

class _SocketConnectionChanged extends InterviewEvent {
  final bool connected;
  const _SocketConnectionChanged(this.connected);
}
