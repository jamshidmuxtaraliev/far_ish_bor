part of 'faq_bloc.dart';

class FaqState extends Equatable {
  final List<FaqModel> faqList;
  final FormzSubmissionStatus status;
  final ErrorModel? error;

  const FaqState({
    this.faqList = const [],
    this.status = FormzSubmissionStatus.initial,
    this.error,
  });

  FaqState copyWith({
    List<FaqModel>? faqList,
    FormzSubmissionStatus? status,
    ErrorModel? error,
  }) {
    return FaqState(
      faqList: faqList ?? this.faqList,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [faqList, status, error];
}
