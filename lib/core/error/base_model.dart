class BaseData<T> {
  final bool success;
  final String? message;
  final int? errorCode;
  final T? data;

  BaseData({required this.success, this.message, this.errorCode, this.data});

  factory BaseData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    final isSuccess = json['success'] as bool? ?? false;
    return BaseData<T>(
      success: isSuccess,
      message: json['message'] as String?,
      errorCode: json['error_code'] as int?,
      data: (isSuccess && fromJsonT != null && json['data'] != null)
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
