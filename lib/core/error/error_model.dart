import 'package:equatable/equatable.dart';

class ErrorModel extends Equatable {
  final String errorMessage;
  int? errorCode = 200;

  ErrorModel(this.errorMessage, {this.errorCode});

  @override
  List<Object?> get props => [errorMessage, errorCode];
}
