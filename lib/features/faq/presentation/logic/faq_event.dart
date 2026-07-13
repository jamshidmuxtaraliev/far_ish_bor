part of 'faq_bloc.dart';

sealed class FaqEvent extends Equatable {
  const FaqEvent();

  @override
  List<Object?> get props => [];
}

/// [audience] — `seeker` | `employer` | null (barchasi).
class LoadFaqEvent extends FaqEvent {
  final String? audience;

  const LoadFaqEvent({this.audience});

  @override
  List<Object?> get props => [audience];
}
