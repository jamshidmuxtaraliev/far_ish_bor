import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/error/error_model.dart';
import '../../data/datasource/remote/faq_remote_data_source.dart';
import '../../data/models/faq_model.dart';

part 'faq_event.dart';
part 'faq_state.dart';

class FaqBloc extends Bloc<FaqEvent, FaqState> {
  final FaqRemoteDataSource dataSource;

  FaqBloc(this.dataSource) : super(const FaqState()) {
    on<LoadFaqEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadFaqEvent event, Emitter<FaqState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getFaqList(audience: event.audience);
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormzSubmissionStatus.failure, error: failure),
      ),
      (list) => emit(
        state.copyWith(status: FormzSubmissionStatus.success, faqList: list),
      ),
    );
  }
}
