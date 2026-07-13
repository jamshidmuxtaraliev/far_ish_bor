class FaqModel {
  final int id;
  final String question;
  final String? questionUzk;
  final String? questionRu;
  final String answer;
  final String? answerUzk;
  final String? answerRu;
  final String audience;
  final int position;

  const FaqModel({
    required this.id,
    required this.question,
    this.questionUzk,
    this.questionRu,
    required this.answer,
    this.answerUzk,
    this.answerRu,
    this.audience = 'all',
    this.position = 0,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      questionUzk: json['question_uzk'] as String?,
      questionRu: json['question_ru'] as String?,
      answer: json['answer'] as String? ?? '',
      answerUzk: json['answer_uzk'] as String?,
      answerRu: json['answer_ru'] as String?,
      audience: json['audience'] as String? ?? 'all',
      position: json['position'] as int? ?? 0,
    );
  }

  /// Bo'sh/null bo'lsa lotincha (`uz`) asosiy maydonga tushiladi.
  String questionFor(String lang) => switch (lang) {
    'uzk' => (questionUzk?.isNotEmpty == true) ? questionUzk! : question,
    'ru' => (questionRu?.isNotEmpty == true) ? questionRu! : question,
    _ => question,
  };

  String answerFor(String lang) => switch (lang) {
    'uzk' => (answerUzk?.isNotEmpty == true) ? answerUzk! : answer,
    'ru' => (answerRu?.isNotEmpty == true) ? answerRu! : answer,
    _ => answer,
  };
}
