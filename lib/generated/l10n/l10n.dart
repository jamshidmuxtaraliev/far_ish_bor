// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Загрузка...`
  String get loading {
    return Intl.message(
      'Загрузка...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Подготавливаем материалы`
  String get preparingMaterials {
    return Intl.message(
      'Подготавливаем материалы',
      name: 'preparingMaterials',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка`
  String get error {
    return Intl.message(
      'Ошибка',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Выберите язык приложения`
  String get selectLanguageTitle {
    return Intl.message(
      'Выберите язык приложения',
      name: 'selectLanguageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Далее приложение будет работать только на этом языке.`
  String get selectLanguageDescription {
    return Intl.message(
      'Далее приложение будет работать только на этом языке.',
      name: 'selectLanguageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Русский`
  String get languageRussian {
    return Intl.message(
      'Русский',
      name: 'languageRussian',
      desc: '',
      args: [],
    );
  }

  /// `O'zbek tili`
  String get languageUzbek {
    return Intl.message(
      'O\'zbek tili',
      name: 'languageUzbek',
      desc: '',
      args: [],
    );
  }

  /// `Выберите свою роль`
  String get selectRoleTitle {
    return Intl.message(
      'Выберите свою роль',
      name: 'selectRoleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ученик, учитель или администрация школы.`
  String get selectRoleDescription {
    return Intl.message(
      'Ученик, учитель или администрация школы.',
      name: 'selectRoleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Ученик`
  String get studentRole {
    return Intl.message(
      'Ученик',
      name: 'studentRole',
      desc: '',
      args: [],
    );
  }

  /// `Я учусь в этой школе.`
  String get studentRoleSubtitle {
    return Intl.message(
      'Я учусь в этой школе.',
      name: 'studentRoleSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Родитель`
  String get parentRole {
    return Intl.message(
      'Родитель',
      name: 'parentRole',
      desc: '',
      args: [],
    );
  }

  /// `Мои дети учатся в этой школе.`
  String get parentRoleSubtitle {
    return Intl.message(
      'Мои дети учатся в этой школе.',
      name: 'parentRoleSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Учитель`
  String get teacherRole {
    return Intl.message(
      'Учитель',
      name: 'teacherRole',
      desc: '',
      args: [],
    );
  }

  /// `Я преподаватель в этой школе.`
  String get teacherRoleSubtitle {
    return Intl.message(
      'Я преподаватель в этой школе.',
      name: 'teacherRoleSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Администрация школы`
  String get adminRole {
    return Intl.message(
      'Администрация школы',
      name: 'adminRole',
      desc: '',
      args: [],
    );
  }

  /// `Я управляющий в этой школе.`
  String get adminRoleSubtitle {
    return Intl.message(
      'Я управляющий в этой школе.',
      name: 'adminRoleSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Выбрал`
  String get selectedButton {
    return Intl.message(
      'Выбрал',
      name: 'selectedButton',
      desc: '',
      args: [],
    );
  }

  /// `Выбери роль!`
  String get selectRoleWarning {
    return Intl.message(
      'Выбери роль!',
      name: 'selectRoleWarning',
      desc: '',
      args: [],
    );
  }

  /// `Войдите в свой аккаунт`
  String get signInTitle {
    return Intl.message(
      'Войдите в свой аккаунт',
      name: 'signInTitle',
      desc: '',
      args: [],
    );
  }

  /// `Введите логин и пароль который вам выдали`
  String get signInDescription {
    return Intl.message(
      'Введите логин и пароль который вам выдали',
      name: 'signInDescription',
      desc: '',
      args: [],
    );
  }

  /// `Логин или почта`
  String get loginOrEmail {
    return Intl.message(
      'Логин или почта',
      name: 'loginOrEmail',
      desc: '',
      args: [],
    );
  }

  /// `Логин....`
  String get loginHint {
    return Intl.message(
      'Логин....',
      name: 'loginHint',
      desc: '',
      args: [],
    );
  }

  /// `Пароль`
  String get password {
    return Intl.message(
      'Пароль',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Пароль...`
  String get passwordHint {
    return Intl.message(
      'Пароль...',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Согласие на обработку персональных данных`
  String get personalDataConsent {
    return Intl.message(
      'Согласие на обработку персональных данных',
      name: 'personalDataConsent',
      desc: '',
      args: [],
    );
  }

  /// `Войти`
  String get signInButton {
    return Intl.message(
      'Войти',
      name: 'signInButton',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, подтвердите согласие на обработку персональных данных`
  String get confirmConsentError {
    return Intl.message(
      'Пожалуйста, подтвердите согласие на обработку персональных данных',
      name: 'confirmConsentError',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, заполните все поля`
  String get fillAllFieldsError {
    return Intl.message(
      'Пожалуйста, заполните все поля',
      name: 'fillAllFieldsError',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка авторизации`
  String get authError {
    return Intl.message(
      'Ошибка авторизации',
      name: 'authError',
      desc: '',
      args: [],
    );
  }

  /// `Профиль`
  String get menuProfile {
    return Intl.message(
      'Профиль',
      name: 'menuProfile',
      desc: '',
      args: [],
    );
  }

  /// `Статистика`
  String get menuStatistics {
    return Intl.message(
      'Статистика',
      name: 'menuStatistics',
      desc: '',
      args: [],
    );
  }

  /// `Расписание`
  String get menuSchedule {
    return Intl.message(
      'Расписание',
      name: 'menuSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Классы`
  String get menuClasses {
    return Intl.message(
      'Классы',
      name: 'menuClasses',
      desc: '',
      args: [],
    );
  }

  /// `Опросы`
  String get menuPolls {
    return Intl.message(
      'Опросы',
      name: 'menuPolls',
      desc: '',
      args: [],
    );
  }

  /// `Конкурсы`
  String get menuContests {
    return Intl.message(
      'Конкурсы',
      name: 'menuContests',
      desc: '',
      args: [],
    );
  }

  /// `Магазин`
  String get menuStore {
    return Intl.message(
      'Магазин',
      name: 'menuStore',
      desc: '',
      args: [],
    );
  }

  /// `Учителя`
  String get menuTeachers {
    return Intl.message(
      'Учителя',
      name: 'menuTeachers',
      desc: '',
      args: [],
    );
  }

  /// `Родители`
  String get menuParents {
    return Intl.message(
      'Родители',
      name: 'menuParents',
      desc: '',
      args: [],
    );
  }

  /// `Ученики`
  String get menuStudents {
    return Intl.message(
      'Ученики',
      name: 'menuStudents',
      desc: '',
      args: [],
    );
  }

  /// `Рейтинг`
  String get menuRating {
    return Intl.message(
      'Рейтинг',
      name: 'menuRating',
      desc: '',
      args: [],
    );
  }

  /// `Настройки`
  String get menuSettings {
    return Intl.message(
      'Настройки',
      name: 'menuSettings',
      desc: '',
      args: [],
    );
  }

  /// `Монеты`
  String get menuCoins {
    return Intl.message(
      'Монеты',
      name: 'menuCoins',
      desc: '',
      args: [],
    );
  }

  /// `Можно потратить во внутреннем магазине`
  String get menuCoinsDescription {
    return Intl.message(
      'Можно потратить во внутреннем магазине',
      name: 'menuCoinsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Задания`
  String get menuTasks {
    return Intl.message(
      'Задания',
      name: 'menuTasks',
      desc: '',
      args: [],
    );
  }

  /// `Ребенок`
  String get menuChild {
    return Intl.message(
      'Ребенок',
      name: 'menuChild',
      desc: '',
      args: [],
    );
  }

  /// `Успеваемость`
  String get menuProgress {
    return Intl.message(
      'Успеваемость',
      name: 'menuProgress',
      desc: '',
      args: [],
    );
  }

  /// `Проверка`
  String get menuCheck {
    return Intl.message(
      'Проверка',
      name: 'menuCheck',
      desc: '',
      args: [],
    );
  }

  /// `Уроки`
  String get menuLessons {
    return Intl.message(
      'Уроки',
      name: 'menuLessons',
      desc: '',
      args: [],
    );
  }

  /// `Описание`
  String get menuDescription {
    return Intl.message(
      'Описание',
      name: 'menuDescription',
      desc: '',
      args: [],
    );
  }

  /// `Дети`
  String get children {
    return Intl.message(
      'Дети',
      name: 'children',
      desc: '',
      args: [],
    );
  }

  /// `Собрание`
  String get meeting {
    return Intl.message(
      'Собрание',
      name: 'meeting',
      desc: '',
      args: [],
    );
  }

  /// `Собрание в ближайшее время не запланированы.`
  String get noMeetingSoon {
    return Intl.message(
      'Собрание в ближайшее время не запланированы.',
      name: 'noMeetingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Их можно перевести вашему ребенку`
  String get coinsCanTransferToChild {
    return Intl.message(
      'Их можно перевести вашему ребенку',
      name: 'coinsCanTransferToChild',
      desc: '',
      args: [],
    );
  }

  /// `Последние оценки`
  String get lastGrades {
    return Intl.message(
      'Последние оценки',
      name: 'lastGrades',
      desc: '',
      args: [],
    );
  }

  /// `Успеваемость\nребенка`
  String get childProgressTitle {
    return Intl.message(
      'Успеваемость\nребенка',
      name: 'childProgressTitle',
      desc: '',
      args: [],
    );
  }

  /// `Средний балл`
  String get avgScore {
    return Intl.message(
      'Средний балл',
      name: 'avgScore',
      desc: '',
      args: [],
    );
  }

  /// `Расписание на сегодня`
  String get todaySchedule {
    return Intl.message(
      'Расписание на сегодня',
      name: 'todaySchedule',
      desc: '',
      args: [],
    );
  }

  /// `Все расписание`
  String get allSchedule {
    return Intl.message(
      'Все расписание',
      name: 'allSchedule',
      desc: '',
      args: [],
    );
  }

  /// `На сегодня нет запланированных уроков.`
  String get noLessonsToday {
    return Intl.message(
      'На сегодня нет запланированных уроков.',
      name: 'noLessonsToday',
      desc: '',
      args: [],
    );
  }

  /// `класс`
  String get classLabel {
    return Intl.message(
      'класс',
      name: 'classLabel',
      desc: '',
      args: [],
    );
  }

  /// `Номер для связи:`
  String get contactNumber {
    return Intl.message(
      'Номер для связи:',
      name: 'contactNumber',
      desc: '',
      args: [],
    );
  }

  /// `Общий средний балл`
  String get totalAvgScore {
    return Intl.message(
      'Общий средний балл',
      name: 'totalAvgScore',
      desc: '',
      args: [],
    );
  }

  /// `Средний балл по предметам`
  String get avgScoreBySubjects {
    return Intl.message(
      'Средний балл по предметам',
      name: 'avgScoreBySubjects',
      desc: '',
      args: [],
    );
  }

  /// `Передать баллы`
  String get transferPoints {
    return Intl.message(
      'Передать баллы',
      name: 'transferPoints',
      desc: '',
      args: [],
    );
  }

  /// `Баллы успешно переданы ребенку`
  String get coinsSuccessTransferred {
    return Intl.message(
      'Баллы успешно переданы ребенку',
      name: 'coinsSuccessTransferred',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка передачи баллов`
  String get transferCoinError {
    return Intl.message(
      'Ошибка передачи баллов',
      name: 'transferCoinError',
      desc: '',
      args: [],
    );
  }

  /// `Передача баллов`
  String get transferPointsTitle {
    return Intl.message(
      'Передача баллов',
      name: 'transferPointsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Кол-во передаваемых баллов`
  String get transferPointsCount {
    return Intl.message(
      'Кол-во передаваемых баллов',
      name: 'transferPointsCount',
      desc: '',
      args: [],
    );
  }

  /// `Уточните кол-во баллов которые хотите передать.`
  String get transferPointsHint {
    return Intl.message(
      'Уточните кол-во баллов которые хотите передать.',
      name: 'transferPointsHint',
      desc: '',
      args: [],
    );
  }

  /// `Введите количество монет`
  String get transferAmountInputHint {
    return Intl.message(
      'Введите количество монет',
      name: 'transferAmountInputHint',
      desc: '',
      args: [],
    );
  }

  /// `Передать`
  String get transferButton {
    return Intl.message(
      'Передать',
      name: 'transferButton',
      desc: '',
      args: [],
    );
  }

  /// `Сравнение с классом`
  String get compareWithClass {
    return Intl.message(
      'Сравнение с классом',
      name: 'compareWithClass',
      desc: '',
      args: [],
    );
  }

  /// `Оценки по предметам:`
  String get gradesBySubjects {
    return Intl.message(
      'Оценки по предметам:',
      name: 'gradesBySubjects',
      desc: '',
      args: [],
    );
  }

  /// `Дневник (все предметы)`
  String get diaryAllSubjects {
    return Intl.message(
      'Дневник (все предметы)',
      name: 'diaryAllSubjects',
      desc: '',
      args: [],
    );
  }

  /// `Средний балл одноклассников:`
  String get classmatesAvgScore {
    return Intl.message(
      'Средний балл одноклассников:',
      name: 'classmatesAvgScore',
      desc: '',
      args: [],
    );
  }

  /// `История оценок:`
  String get gradeHistory {
    return Intl.message(
      'История оценок:',
      name: 'gradeHistory',
      desc: '',
      args: [],
    );
  }

  /// `Работа в классе`
  String get classWork {
    return Intl.message(
      'Работа в классе',
      name: 'classWork',
      desc: '',
      args: [],
    );
  }

  /// `Домашняя работа`
  String get homework {
    return Intl.message(
      'Домашняя работа',
      name: 'homework',
      desc: '',
      args: [],
    );
  }

  /// `Поведение`
  String get behavior {
    return Intl.message(
      'Поведение',
      name: 'behavior',
      desc: '',
      args: [],
    );
  }

  /// `Плохо`
  String get gradeBad {
    return Intl.message(
      'Плохо',
      name: 'gradeBad',
      desc: '',
      args: [],
    );
  }

  /// `Хорошо`
  String get gradeGood {
    return Intl.message(
      'Хорошо',
      name: 'gradeGood',
      desc: '',
      args: [],
    );
  }

  /// `Опросов не найдено`
  String get pollsNotFound {
    return Intl.message(
      'Опросов не найдено',
      name: 'pollsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Ожидайте, скоро опросы точно появятся, и мы обязательно ознакомимся с вашим мнением.`
  String get pollsWillAppearSoon {
    return Intl.message(
      'Ожидайте, скоро опросы точно появятся, и мы обязательно ознакомимся с вашим мнением.',
      name: 'pollsWillAppearSoon',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, ответьте на все вопросы.`
  String get answerAllQuestions {
    return Intl.message(
      'Пожалуйста, ответьте на все вопросы.',
      name: 'answerAllQuestions',
      desc: '',
      args: [],
    );
  }

  /// `Вопрос №{number}`
  String questionNumber(int number) {
    return Intl.message(
      'Вопрос №$number',
      name: 'questionNumber',
      desc: '',
      args: [number],
    );
  }

  /// `Отправить ответ`
  String get submitAnswer {
    return Intl.message(
      'Отправить ответ',
      name: 'submitAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Опрос`
  String get poll {
    return Intl.message(
      'Опрос',
      name: 'poll',
      desc: '',
      args: [],
    );
  }

  /// `Вы завершили опрос`
  String get pollCompleted {
    return Intl.message(
      'Вы завершили опрос',
      name: 'pollCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Вам начислено:`
  String get coinsEarned {
    return Intl.message(
      'Вам начислено:',
      name: 'coinsEarned',
      desc: '',
      args: [],
    );
  }

  /// `Понятно`
  String get understood {
    return Intl.message(
      'Понятно',
      name: 'understood',
      desc: '',
      args: [],
    );
  }

  /// `Ваш рейтинг:`
  String get yourRating {
    return Intl.message(
      'Ваш рейтинг:',
      name: 'yourRating',
      desc: '',
      args: [],
    );
  }

  /// `Мои\nЗадания`
  String get myTasks {
    return Intl.message(
      'Мои\nЗадания',
      name: 'myTasks',
      desc: '',
      args: [],
    );
  }

  /// `Выполнено`
  String get completedPercent {
    return Intl.message(
      'Выполнено',
      name: 'completedPercent',
      desc: '',
      args: [],
    );
  }

  /// `Ваш рейтинг в группе`
  String get groupRating {
    return Intl.message(
      'Ваш рейтинг в группе',
      name: 'groupRating',
      desc: '',
      args: [],
    );
  }

  /// `Ваш рейтинг в школе`
  String get schoolRating {
    return Intl.message(
      'Ваш рейтинг в школе',
      name: 'schoolRating',
      desc: '',
      args: [],
    );
  }

  /// `место`
  String get rankPlace {
    return Intl.message(
      'место',
      name: 'rankPlace',
      desc: '',
      args: [],
    );
  }

  /// `Баланс монеты`
  String get coinBalance {
    return Intl.message(
      'Баланс монеты',
      name: 'coinBalance',
      desc: '',
      args: [],
    );
  }

  /// `Как получать монеты`
  String get howToGetCoins {
    return Intl.message(
      'Как получать монеты',
      name: 'howToGetCoins',
      desc: '',
      args: [],
    );
  }

  /// `История транзакций`
  String get transactionHistory {
    return Intl.message(
      'История транзакций',
      name: 'transactionHistory',
      desc: '',
      args: [],
    );
  }

  /// `Транзакции не найдены`
  String get noTransactionsFound {
    return Intl.message(
      'Транзакции не найдены',
      name: 'noTransactionsFound',
      desc: '',
      args: [],
    );
  }

  /// `Как потерять монеты`
  String get howToLoseCoins {
    return Intl.message(
      'Как потерять монеты',
      name: 'howToLoseCoins',
      desc: '',
      args: [],
    );
  }

  /// `Оценки по предметам`
  String get subjectGrades {
    return Intl.message(
      'Оценки по предметам',
      name: 'subjectGrades',
      desc: '',
      args: [],
    );
  }

  /// `Оценки за контрольные / тесты`
  String get testGrades {
    return Intl.message(
      'Оценки за контрольные / тесты',
      name: 'testGrades',
      desc: '',
      args: [],
    );
  }

  /// `5 (отлично)`
  String get gradeExcellent {
    return Intl.message(
      '5 (отлично)',
      name: 'gradeExcellent',
      desc: '',
      args: [],
    );
  }

  /// `4 (хорошо)`
  String get gradeGoodNum {
    return Intl.message(
      '4 (хорошо)',
      name: 'gradeGoodNum',
      desc: '',
      args: [],
    );
  }

  /// `3 (удовлетворительно)`
  String get gradeSatisfactory {
    return Intl.message(
      '3 (удовлетворительно)',
      name: 'gradeSatisfactory',
      desc: '',
      args: [],
    );
  }

  /// `2 (неудовлетворительно)`
  String get gradeUnsatisfactory {
    return Intl.message(
      '2 (неудовлетворительно)',
      name: 'gradeUnsatisfactory',
      desc: '',
      args: [],
    );
  }

  /// `Хорошее поведение`
  String get goodBehavior {
    return Intl.message(
      'Хорошее поведение',
      name: 'goodBehavior',
      desc: '',
      args: [],
    );
  }

  /// `Плохое поведение`
  String get badBehavior {
    return Intl.message(
      'Плохое поведение',
      name: 'badBehavior',
      desc: '',
      args: [],
    );
  }

  /// `Участие в конкурсах`
  String get contestParticipation {
    return Intl.message(
      'Участие в конкурсах',
      name: 'contestParticipation',
      desc: '',
      args: [],
    );
  }

  /// `Попадание в топ-3 недели`
  String get topThreeWeek {
    return Intl.message(
      'Попадание в топ-3 недели',
      name: 'topThreeWeek',
      desc: '',
      args: [],
    );
  }

  /// `1 раз в неделю / месяц`
  String get onceWeekMonth {
    return Intl.message(
      '1 раз в неделю / месяц',
      name: 'onceWeekMonth',
      desc: '',
      args: [],
    );
  }

  /// `Вариативно`
  String get variable {
    return Intl.message(
      'Вариативно',
      name: 'variable',
      desc: '',
      args: [],
    );
  }

  /// `Пропуск урока`
  String get lessonAbsence {
    return Intl.message(
      'Пропуск урока',
      name: 'lessonAbsence',
      desc: '',
      args: [],
    );
  }

  /// `Невыполнение ДЗ`
  String get homeworkMissed {
    return Intl.message(
      'Невыполнение ДЗ',
      name: 'homeworkMissed',
      desc: '',
      args: [],
    );
  }

  /// `Вход на платформу`
  String get loginToPlatform {
    return Intl.message(
      'Вход на платформу',
      name: 'loginToPlatform',
      desc: '',
      args: [],
    );
  }

  /// `Минимум 3 раза в неделю`
  String get minThreeTimesWeek {
    return Intl.message(
      'Минимум 3 раза в неделю',
      name: 'minThreeTimesWeek',
      desc: '',
      args: [],
    );
  }

  /// `Просмотр успеваемости ребёнка`
  String get viewChildProgress {
    return Intl.message(
      'Просмотр успеваемости ребёнка',
      name: 'viewChildProgress',
      desc: '',
      args: [],
    );
  }

  /// `Минимум 1 раз в неделю`
  String get minOnceWeek {
    return Intl.message(
      'Минимум 1 раз в неделю',
      name: 'minOnceWeek',
      desc: '',
      args: [],
    );
  }

  /// `Посещение родительского собрания`
  String get attendParentMeeting {
    return Intl.message(
      'Посещение родительского собрания',
      name: 'attendParentMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Оплата вовремя`
  String get payOnTime {
    return Intl.message(
      'Оплата вовремя',
      name: 'payOnTime',
      desc: '',
      args: [],
    );
  }

  /// `Заполнение опроса`
  String get fillSurvey {
    return Intl.message(
      'Заполнение опроса',
      name: 'fillSurvey',
      desc: '',
      args: [],
    );
  }

  /// `Не пришли на родительское собрание`
  String get missedParentMeeting {
    return Intl.message(
      'Не пришли на родительское собрание',
      name: 'missedParentMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Домашнее задание успешно отправлено`
  String get homeworkSubmitted {
    return Intl.message(
      'Домашнее задание успешно отправлено',
      name: 'homeworkSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Новые`
  String get tabNew {
    return Intl.message(
      'Новые',
      name: 'tabNew',
      desc: '',
      args: [],
    );
  }

  /// `Сдал`
  String get tabSubmitted {
    return Intl.message(
      'Сдал',
      name: 'tabSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Просрочил`
  String get tabOverdue {
    return Intl.message(
      'Просрочил',
      name: 'tabOverdue',
      desc: '',
      args: [],
    );
  }

  /// `Загрузка файла...`
  String get fileUploading {
    return Intl.message(
      'Загрузка файла...',
      name: 'fileUploading',
      desc: '',
      args: [],
    );
  }

  /// `Сдать до: {date}`
  String dueDate(String date) {
    return Intl.message(
      'Сдать до: $date',
      name: 'dueDate',
      desc: '',
      args: [date],
    );
  }

  /// `Подтверждение`
  String get confirmation {
    return Intl.message(
      'Подтверждение',
      name: 'confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Вы отправляете этот файл в ответ на задание:\n\n{filePath}`
  String submitFileConfirmation(String filePath) {
    return Intl.message(
      'Вы отправляете этот файл в ответ на задание:\n\n$filePath',
      name: 'submitFileConfirmation',
      desc: '',
      args: [filePath],
    );
  }

  /// `Отмена`
  String get cancel {
    return Intl.message(
      'Отмена',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Да, отправить`
  String get yesSubmit {
    return Intl.message(
      'Да, отправить',
      name: 'yesSubmit',
      desc: '',
      args: [],
    );
  }

  /// `Проверяется`
  String get beingReviewed {
    return Intl.message(
      'Проверяется',
      name: 'beingReviewed',
      desc: '',
      args: [],
    );
  }

  /// `Проверенные задания за последние 30 дней`
  String get checkedTasksLast30Days {
    return Intl.message(
      'Проверенные задания за последние 30 дней',
      name: 'checkedTasksLast30Days',
      desc: '',
      args: [],
    );
  }

  /// `Оценка: {score}`
  String gradeScore(String score) {
    return Intl.message(
      'Оценка: $score',
      name: 'gradeScore',
      desc: '',
      args: [score],
    );
  }

  /// `Корзина`
  String get cart {
    return Intl.message(
      'Корзина',
      name: 'cart',
      desc: '',
      args: [],
    );
  }

  /// `Корзина пуста`
  String get cartEmpty {
    return Intl.message(
      'Корзина пуста',
      name: 'cartEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Оставить заявку`
  String get submitOrder {
    return Intl.message(
      'Оставить заявку',
      name: 'submitOrder',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при отправке заявки`
  String get orderSubmitError {
    return Intl.message(
      'Ошибка при отправке заявки',
      name: 'orderSubmitError',
      desc: '',
      args: [],
    );
  }

  /// `У вас недостаточно монет на счету!`
  String get notEnoughCoins {
    return Intl.message(
      'У вас недостаточно монет на счету!',
      name: 'notEnoughCoins',
      desc: '',
      args: [],
    );
  }

  /// `Поздравляем !`
  String get congratulations {
    return Intl.message(
      'Поздравляем !',
      name: 'congratulations',
      desc: '',
      args: [],
    );
  }

  /// `Вы успешно обменяли баллы на:`
  String get successExchanged {
    return Intl.message(
      'Вы успешно обменяли баллы на:',
      name: 'successExchanged',
      desc: '',
      args: [],
    );
  }

  /// `Отлично`
  String get excellent {
    return Intl.message(
      'Отлично',
      name: 'excellent',
      desc: '',
      args: [],
    );
  }

  /// `В ближайшее время вашу заявку одобрят в администрации и отправят заказ`
  String get orderApprovalMessage {
    return Intl.message(
      'В ближайшее время вашу заявку одобрят в администрации и отправят заказ',
      name: 'orderApprovalMessage',
      desc: '',
      args: [],
    );
  }

  /// `Рейтинг группы`
  String get groupRatingTab {
    return Intl.message(
      'Рейтинг группы',
      name: 'groupRatingTab',
      desc: '',
      args: [],
    );
  }

  /// `Рейтинг школы`
  String get schoolRatingTab {
    return Intl.message(
      'Рейтинг школы',
      name: 'schoolRatingTab',
      desc: '',
      args: [],
    );
  }

  /// `Домашние Задания`
  String get homeworksTasks {
    return Intl.message(
      'Домашние Задания',
      name: 'homeworksTasks',
      desc: '',
      args: [],
    );
  }

  /// `Проверено`
  String get checkedStatus {
    return Intl.message(
      'Проверено',
      name: 'checkedStatus',
      desc: '',
      args: [],
    );
  }

  /// `Проверка заданий`
  String get checkTasks {
    return Intl.message(
      'Проверка заданий',
      name: 'checkTasks',
      desc: '',
      args: [],
    );
  }

  /// `Здесь отображаются классы которым вы назначили задания. Для проверки откройте класс и выберите ученика.`
  String get checkTasksHint {
    return Intl.message(
      'Здесь отображаются классы которым вы назначили задания. Для проверки откройте класс и выберите ученика.',
      name: 'checkTasksHint',
      desc: '',
      args: [],
    );
  }

  /// `Выбор ученика`
  String get selectStudent {
    return Intl.message(
      'Выбор ученика',
      name: 'selectStudent',
      desc: '',
      args: [],
    );
  }

  /// `Выберите ученика, скачайте его задание и проверьте. Если обнаружите ошибки то загрузите файл с исправлениями и поставьте соответствующую оценку.`
  String get selectStudentHint {
    return Intl.message(
      'Выберите ученика, скачайте его задание и проверьте. Если обнаружите ошибки то загрузите файл с исправлениями и поставьте соответствующую оценку.',
      name: 'selectStudentHint',
      desc: '',
      args: [],
    );
  }

  /// `Отправили домашнюю работу`
  String get submittedHomework {
    return Intl.message(
      'Отправили домашнюю работу',
      name: 'submittedHomework',
      desc: '',
      args: [],
    );
  }

  /// `Не отправили домашнюю работу`
  String get notSubmittedHomework {
    return Intl.message(
      'Не отправили домашнюю работу',
      name: 'notSubmittedHomework',
      desc: '',
      args: [],
    );
  }

  /// `Нет новых заданий`
  String get noNewTasks {
    return Intl.message(
      'Нет новых заданий',
      name: 'noNewTasks',
      desc: '',
      args: [],
    );
  }

  /// `Домашнее задание для этого урока не задано`
  String get lessonTaskNotAssigned {
    return Intl.message(
      'Домашнее задание для этого урока не задано',
      name: 'lessonTaskNotAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Нет отправленных заданий`
  String get noSubmittedTasks {
    return Intl.message(
      'Нет отправленных заданий',
      name: 'noSubmittedTasks',
      desc: '',
      args: [],
    );
  }

  /// `Нет просроченных заданий`
  String get noOverdueTasks {
    return Intl.message(
      'Нет просроченных заданий',
      name: 'noOverdueTasks',
      desc: '',
      args: [],
    );
  }

  /// `Проверка задания`
  String get checkTask {
    return Intl.message(
      'Проверка задания',
      name: 'checkTask',
      desc: '',
      args: [],
    );
  }

  /// `Файл ученика`
  String get studentFile {
    return Intl.message(
      'Файл ученика',
      name: 'studentFile',
      desc: '',
      args: [],
    );
  }

  /// `Скачайте домашнее задание ученика и проверьте его. Если задание без ошибок, то можно не загружать исправления.`
  String get downloadStudentHomeworkHint {
    return Intl.message(
      'Скачайте домашнее задание ученика и проверьте его. Если задание без ошибок, то можно не загружать исправления.',
      name: 'downloadStudentHomeworkHint',
      desc: '',
      args: [],
    );
  }

  /// `Загрузка ошибок`
  String get uploadErrors {
    return Intl.message(
      'Загрузка ошибок',
      name: 'uploadErrors',
      desc: '',
      args: [],
    );
  }

  /// `Если задание без ошибок, то можно не загружать файл с исправления.`
  String get uploadErrorsHint {
    return Intl.message(
      'Если задание без ошибок, то можно не загружать файл с исправления.',
      name: 'uploadErrorsHint',
      desc: '',
      args: [],
    );
  }

  /// `Загрузить файл`
  String get uploadFile {
    return Intl.message(
      'Загрузить файл',
      name: 'uploadFile',
      desc: '',
      args: [],
    );
  }

  /// `Оценка задания`
  String get gradeTask {
    return Intl.message(
      'Оценка задания',
      name: 'gradeTask',
      desc: '',
      args: [],
    );
  }

  /// `Выставьте справедливую оценку за выполнение задания учеником.`
  String get gradeTaskHint {
    return Intl.message(
      'Выставьте справедливую оценку за выполнение задания учеником.',
      name: 'gradeTaskHint',
      desc: '',
      args: [],
    );
  }

  /// `Оценка успешно выставлена`
  String get gradeSetSuccess {
    return Intl.message(
      'Оценка успешно выставлена',
      name: 'gradeSetSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Выставить оценку`
  String get setGrade {
    return Intl.message(
      'Выставить оценку',
      name: 'setGrade',
      desc: '',
      args: [],
    );
  }

  /// `Невозможно выставить оценку, так как срок сдачи задания истек или задание не было сдано.`
  String get cannotSetGrade {
    return Intl.message(
      'Невозможно выставить оценку, так как срок сдачи задания истек или задание не было сдано.',
      name: 'cannotSetGrade',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, выберите оценку перед выставлением.`
  String get pleaseSelectGrade {
    return Intl.message(
      'Пожалуйста, выберите оценку перед выставлением.',
      name: 'pleaseSelectGrade',
      desc: '',
      args: [],
    );
  }

  /// `Домашнее задание не загружено`
  String get homeworkNotUploaded {
    return Intl.message(
      'Домашнее задание не загружено',
      name: 'homeworkNotUploaded',
      desc: '',
      args: [],
    );
  }

  /// `Задание успешно отправлено.`
  String get taskSubmitSuccess {
    return Intl.message(
      'Задание успешно отправлено.',
      name: 'taskSubmitSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при отправке задания.`
  String get taskSubmitError {
    return Intl.message(
      'Ошибка при отправке задания.',
      name: 'taskSubmitError',
      desc: '',
      args: [],
    );
  }

  /// `Урок проведен {date}`
  String lessonDate(String date) {
    return Intl.message(
      'Урок проведен $date',
      name: 'lessonDate',
      desc: '',
      args: [date],
    );
  }

  /// `Загрузите файл с домашним заданием. Поддерживается формат:\nJPG / PDF / DOCS`
  String get uploadHomeworkHint {
    return Intl.message(
      'Загрузите файл с домашним заданием. Поддерживается формат:\nJPG / PDF / DOCS',
      name: 'uploadHomeworkHint',
      desc: '',
      args: [],
    );
  }

  /// `Срок выполнения`
  String get deadline {
    return Intl.message(
      'Срок выполнения',
      name: 'deadline',
      desc: '',
      args: [],
    );
  }

  /// `Установите время выполнения задания.`
  String get setDeadlineHint {
    return Intl.message(
      'Установите время выполнения задания.',
      name: 'setDeadlineHint',
      desc: '',
      args: [],
    );
  }

  /// `Выбор даты`
  String get selectDate {
    return Intl.message(
      'Выбор даты',
      name: 'selectDate',
      desc: '',
      args: [],
    );
  }

  /// `Выбор времени`
  String get selectTime {
    return Intl.message(
      'Выбор времени',
      name: 'selectTime',
      desc: '',
      args: [],
    );
  }

  /// `Отправить задание`
  String get submitTask {
    return Intl.message(
      'Отправить задание',
      name: 'submitTask',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, загрузите файл с заданием.`
  String get pleaseUploadFile {
    return Intl.message(
      'Пожалуйста, загрузите файл с заданием.',
      name: 'pleaseUploadFile',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, установите срок выполнения задания.`
  String get pleaseSetDeadline {
    return Intl.message(
      'Пожалуйста, установите срок выполнения задания.',
      name: 'pleaseSetDeadline',
      desc: '',
      args: [],
    );
  }

  /// `Посещаемость урока`
  String get lessonAttendance {
    return Intl.message(
      'Посещаемость урока',
      name: 'lessonAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Перед началом урока уточните кого нет в классе и после приступайте к уроку. Если ученика нет в классе, то не отмечайте его галочкой.`
  String get attendanceHint {
    return Intl.message(
      'Перед началом урока уточните кого нет в классе и после приступайте к уроку. Если ученика нет в классе, то не отмечайте его галочкой.',
      name: 'attendanceHint',
      desc: '',
      args: [],
    );
  }

  /// `Урок успешно начат`
  String get lessonStarted {
    return Intl.message(
      'Урок успешно начат',
      name: 'lessonStarted',
      desc: '',
      args: [],
    );
  }

  /// `Начать урок`
  String get startLesson {
    return Intl.message(
      'Начать урок',
      name: 'startLesson',
      desc: '',
      args: [],
    );
  }

  /// `Здесь отображаются уроки которые вы будете проводить на неделю вперед. (расписание)`
  String get lessonsHint {
    return Intl.message(
      'Здесь отображаются уроки которые вы будете проводить на неделю вперед. (расписание)',
      name: 'lessonsHint',
      desc: '',
      args: [],
    );
  }

  /// `Посещение и оценки уже были добавлены для этого урока.`
  String get lessonAlreadyMarked {
    return Intl.message(
      'Посещение и оценки уже были добавлены для этого урока.',
      name: 'lessonAlreadyMarked',
      desc: '',
      args: [],
    );
  }

  /// `№   ФИО ученика`
  String get studentListHeader {
    return Intl.message(
      '№   ФИО ученика',
      name: 'studentListHeader',
      desc: '',
      args: [],
    );
  }

  /// `Выставление оценки`
  String get gradingTitle {
    return Intl.message(
      'Выставление оценки',
      name: 'gradingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Урок успешно завершен`
  String get lessonCompleted {
    return Intl.message(
      'Урок успешно завершен',
      name: 'lessonCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Закончить урок`
  String get finishLesson {
    return Intl.message(
      'Закончить урок',
      name: 'finishLesson',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите закончить урок?`
  String get finishLessonConfirm {
    return Intl.message(
      'Вы уверены, что хотите закончить урок?',
      name: 'finishLessonConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Да, закончить`
  String get yesFinish {
    return Intl.message(
      'Да, закончить',
      name: 'yesFinish',
      desc: '',
      args: [],
    );
  }

  /// `Урок`
  String get lessonType {
    return Intl.message(
      'Урок',
      name: 'lessonType',
      desc: '',
      args: [],
    );
  }

  /// `Контрольная`
  String get controlWork {
    return Intl.message(
      'Контрольная',
      name: 'controlWork',
      desc: '',
      args: [],
    );
  }

  /// `Тест`
  String get test {
    return Intl.message(
      'Тест',
      name: 'test',
      desc: '',
      args: [],
    );
  }

  /// `Оценка за урок`
  String get gradeForLesson {
    return Intl.message(
      'Оценка за урок',
      name: 'gradeForLesson',
      desc: '',
      args: [],
    );
  }

  /// `Выставьте оценку за урок если ученик ответил...`
  String get gradeForLessonHint {
    return Intl.message(
      'Выставьте оценку за урок если ученик ответил...',
      name: 'gradeForLessonHint',
      desc: '',
      args: [],
    );
  }

  /// `Оценка за поведение`
  String get gradeForBehavior {
    return Intl.message(
      'Оценка за поведение',
      name: 'gradeForBehavior',
      desc: '',
      args: [],
    );
  }

  /// `Выставляется только отрицательная оценка...`
  String get gradeForBehaviorHint {
    return Intl.message(
      'Выставляется только отрицательная оценка...',
      name: 'gradeForBehaviorHint',
      desc: '',
      args: [],
    );
  }

  /// `Оставьте соответствующий комментарий ниже.`
  String get leaveCommentHint {
    return Intl.message(
      'Оставьте соответствующий комментарий ниже.',
      name: 'leaveCommentHint',
      desc: '',
      args: [],
    );
  }

  /// `Комментарий ...`
  String get commentPlaceholder {
    return Intl.message(
      'Комментарий ...',
      name: 'commentPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Все верно`
  String get allCorrect {
    return Intl.message(
      'Все верно',
      name: 'allCorrect',
      desc: '',
      args: [],
    );
  }

  /// `Назначение задания`
  String get assignTask {
    return Intl.message(
      'Назначение задания',
      name: 'assignTask',
      desc: '',
      args: [],
    );
  }

  /// `Здесь отображаются проведенные уроки по которым нужно отправить задание на дом.`
  String get assignTaskHint {
    return Intl.message(
      'Здесь отображаются проведенные уроки по которым нужно отправить задание на дом.',
      name: 'assignTaskHint',
      desc: '',
      args: [],
    );
  }

  /// `Классное руководство:`
  String get classManagement {
    return Intl.message(
      'Классное руководство:',
      name: 'classManagement',
      desc: '',
      args: [],
    );
  }

  /// `Образование:`
  String get education {
    return Intl.message(
      'Образование:',
      name: 'education',
      desc: '',
      args: [],
    );
  }

  /// `Стаж работы (в годах):`
  String get workExperience {
    return Intl.message(
      'Стаж работы (в годах):',
      name: 'workExperience',
      desc: '',
      args: [],
    );
  }

  /// `Описание:`
  String get descriptionLabel {
    return Intl.message(
      'Описание:',
      name: 'descriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при получении данных`
  String get fetchDataError {
    return Intl.message(
      'Ошибка при получении данных',
      name: 'fetchDataError',
      desc: '',
      args: [],
    );
  }

  /// `Собрание успешно назначено`
  String get meetingScheduled {
    return Intl.message(
      'Собрание успешно назначено',
      name: 'meetingScheduled',
      desc: '',
      args: [],
    );
  }

  /// `Назначенные собрания:`
  String get scheduledMeetings {
    return Intl.message(
      'Назначенные собрания:',
      name: 'scheduledMeetings',
      desc: '',
      args: [],
    );
  }

  /// `Все родители:`
  String get allParents {
    return Intl.message(
      'Все родители:',
      name: 'allParents',
      desc: '',
      args: [],
    );
  }

  /// `Назначить собрание`
  String get scheduleMeeting {
    return Intl.message(
      'Назначить собрание',
      name: 'scheduleMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Собрание успешно завершено`
  String get meetingCompleted {
    return Intl.message(
      'Собрание успешно завершено',
      name: 'meetingCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Список родителей`
  String get parentsList {
    return Intl.message(
      'Список родителей',
      name: 'parentsList',
      desc: '',
      args: [],
    );
  }

  /// `Начать собрание`
  String get startMeeting {
    return Intl.message(
      'Начать собрание',
      name: 'startMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Нет`
  String get no {
    return Intl.message(
      'Нет',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Да`
  String get yes {
    return Intl.message(
      'Да',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Добавить`
  String get add {
    return Intl.message(
      'Добавить',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Изменить`
  String get edit {
    return Intl.message(
      'Изменить',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Удалить`
  String get delete {
    return Intl.message(
      'Удалить',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Выбрать`
  String get select {
    return Intl.message(
      'Выбрать',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `Создать`
  String get create {
    return Intl.message(
      'Создать',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить`
  String get save {
    return Intl.message(
      'Сохранить',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Готово`
  String get done {
    return Intl.message(
      'Готово',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Загрузить`
  String get upload {
    return Intl.message(
      'Загрузить',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить изменения`
  String get saveChanges {
    return Intl.message(
      'Сохранить изменения',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Редактировать`
  String get editButton {
    return Intl.message(
      'Редактировать',
      name: 'editButton',
      desc: '',
      args: [],
    );
  }

  /// `Нет данных`
  String get noData {
    return Intl.message(
      'Нет данных',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `Администрация`
  String get adminRoleShort {
    return Intl.message(
      'Администрация',
      name: 'adminRoleShort',
      desc: '',
      args: [],
    );
  }

  /// `Учеников`
  String get studentsLabel {
    return Intl.message(
      'Учеников',
      name: 'studentsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Учителей`
  String get teachersLabel {
    return Intl.message(
      'Учителей',
      name: 'teachersLabel',
      desc: '',
      args: [],
    );
  }

  /// `Ученики без назначенного класса`
  String get studentsWithoutClass {
    return Intl.message(
      'Ученики без назначенного класса',
      name: 'studentsWithoutClass',
      desc: '',
      args: [],
    );
  }

  /// `Новые конкурсы`
  String get newContests {
    return Intl.message(
      'Новые конкурсы',
      name: 'newContests',
      desc: '',
      args: [],
    );
  }

  /// `Все конкурсы >`
  String get allContests {
    return Intl.message(
      'Все конкурсы >',
      name: 'allContests',
      desc: '',
      args: [],
    );
  }

  /// `Расписание уроков`
  String get lessonsScheduleTitle {
    return Intl.message(
      'Расписание уроков',
      name: 'lessonsScheduleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Заявки на обмен баллов`
  String get pointsExchangeOrders {
    return Intl.message(
      'Заявки на обмен баллов',
      name: 'pointsExchangeOrders',
      desc: '',
      args: [],
    );
  }

  /// `Средняя\nпосещаемость за сегодня`
  String get lessonsAttendanceDash {
    return Intl.message(
      'Средняя\nпосещаемость за сегодня',
      name: 'lessonsAttendanceDash',
      desc: '',
      args: [],
    );
  }

  /// `Участников всего:`
  String get totalParticipants {
    return Intl.message(
      'Участников всего:',
      name: 'totalParticipants',
      desc: '',
      args: [],
    );
  }

  /// `Новых участников за месяц:`
  String get newParticipantsMonth {
    return Intl.message(
      'Новых участников за месяц:',
      name: 'newParticipantsMonth',
      desc: '',
      args: [],
    );
  }

  /// `Общая посещаемость уроков:`
  String get overallAttendance {
    return Intl.message(
      'Общая посещаемость уроков:',
      name: 'overallAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Предметная посещаемость уроков:`
  String get subjectAttendanceLabel {
    return Intl.message(
      'Предметная посещаемость уроков:',
      name: 'subjectAttendanceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Посещаемость, %`
  String get attendancePercent {
    return Intl.message(
      'Посещаемость, %',
      name: 'attendancePercent',
      desc: '',
      args: [],
    );
  }

  /// `Средняя посещаемость`
  String get avgAttendance {
    return Intl.message(
      'Средняя посещаемость',
      name: 'avgAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Пн`
  String get monShort {
    return Intl.message(
      'Пн',
      name: 'monShort',
      desc: '',
      args: [],
    );
  }

  /// `Вт`
  String get tueShort {
    return Intl.message(
      'Вт',
      name: 'tueShort',
      desc: '',
      args: [],
    );
  }

  /// `Ср`
  String get wedShort {
    return Intl.message(
      'Ср',
      name: 'wedShort',
      desc: '',
      args: [],
    );
  }

  /// `Чт`
  String get thuShort {
    return Intl.message(
      'Чт',
      name: 'thuShort',
      desc: '',
      args: [],
    );
  }

  /// `Пт`
  String get friShort {
    return Intl.message(
      'Пт',
      name: 'friShort',
      desc: '',
      args: [],
    );
  }

  /// `Сб`
  String get satShort {
    return Intl.message(
      'Сб',
      name: 'satShort',
      desc: '',
      args: [],
    );
  }

  /// `Текущие конкурсы`
  String get currentContests {
    return Intl.message(
      'Текущие конкурсы',
      name: 'currentContests',
      desc: '',
      args: [],
    );
  }

  /// `Конкурсов не назначено`
  String get noContestsAssigned {
    return Intl.message(
      'Конкурсов не назначено',
      name: 'noContestsAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Ваш класс не учувствует ни в одном конкурсе. Попробуйте поговорить со своим классным руководителем, возможно он его проведет`
  String get notParticipatingInContest {
    return Intl.message(
      'Ваш класс не учувствует ни в одном конкурсе. Попробуйте поговорить со своим классным руководителем, возможно он его проведет',
      name: 'notParticipatingInContest',
      desc: '',
      args: [],
    );
  }

  /// `Создать конкурс`
  String get createContest {
    return Intl.message(
      'Создать конкурс',
      name: 'createContest',
      desc: '',
      args: [],
    );
  }

  /// `Описание конкурса`
  String get contestDescription {
    return Intl.message(
      'Описание конкурса',
      name: 'contestDescription',
      desc: '',
      args: [],
    );
  }

  /// `Призовые места`
  String get prizePlaces {
    return Intl.message(
      'Призовые места',
      name: 'prizePlaces',
      desc: '',
      args: [],
    );
  }

  /// `Выберите учеников занявших 1, 2 и 3 места.`
  String get selectPrizeWinners {
    return Intl.message(
      'Выберите учеников занявших 1, 2 и 3 места.',
      name: 'selectPrizeWinners',
      desc: '',
      args: [],
    );
  }

  /// `Нажмите для выбора`
  String get tapToSelect {
    return Intl.message(
      'Нажмите для выбора',
      name: 'tapToSelect',
      desc: '',
      args: [],
    );
  }

  /// `Будет определено по итогам конкурса`
  String get determinedAtContestEnd {
    return Intl.message(
      'Будет определено по итогам конкурса',
      name: 'determinedAtContestEnd',
      desc: '',
      args: [],
    );
  }

  /// `Участники`
  String get participants {
    return Intl.message(
      'Участники',
      name: 'participants',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста выберите первого призера`
  String get pleaseSelectFirst {
    return Intl.message(
      'Пожалуйста выберите первого призера',
      name: 'pleaseSelectFirst',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста выберите второго призера`
  String get pleaseSelectSecond {
    return Intl.message(
      'Пожалуйста выберите второго призера',
      name: 'pleaseSelectSecond',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста выберите третьего призера`
  String get pleaseSelectThird {
    return Intl.message(
      'Пожалуйста выберите третьего призера',
      name: 'pleaseSelectThird',
      desc: '',
      args: [],
    );
  }

  /// `Конкурс завершен`
  String get contestCompleted {
    return Intl.message(
      'Конкурс завершен',
      name: 'contestCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Название конкурса`
  String get contestName {
    return Intl.message(
      'Название конкурса',
      name: 'contestName',
      desc: '',
      args: [],
    );
  }

  /// `Награды и места`
  String get rewardsAndPlaces {
    return Intl.message(
      'Награды и места',
      name: 'rewardsAndPlaces',
      desc: '',
      args: [],
    );
  }

  /// `Установите награду за 1, 2 и 3-е призовые места`
  String get assignRewards {
    return Intl.message(
      'Установите награду за 1, 2 и 3-е призовые места',
      name: 'assignRewards',
      desc: '',
      args: [],
    );
  }

  /// `Сумма вознаграждения`
  String get rewardAmount {
    return Intl.message(
      'Сумма вознаграждения',
      name: 'rewardAmount',
      desc: '',
      args: [],
    );
  }

  /// `Отправить победителю`
  String get sendToWinner {
    return Intl.message(
      'Отправить победителю',
      name: 'sendToWinner',
      desc: '',
      args: [],
    );
  }

  /// `Публикация`
  String get publication {
    return Intl.message(
      'Публикация',
      name: 'publication',
      desc: '',
      args: [],
    );
  }

  /// `История`
  String get story {
    return Intl.message(
      'История',
      name: 'story',
      desc: '',
      args: [],
    );
  }

  /// `Загрузить\nпредмет`
  String get uploadItem {
    return Intl.message(
      'Загрузить\nпредмет',
      name: 'uploadItem',
      desc: '',
      args: [],
    );
  }

  /// `Назначить предмет`
  String get assignSubject {
    return Intl.message(
      'Назначить предмет',
      name: 'assignSubject',
      desc: '',
      args: [],
    );
  }

  /// `Учитель`
  String get addTeacherLine {
    return Intl.message(
      'Учитель',
      name: 'addTeacherLine',
      desc: '',
      args: [],
    );
  }

  /// `Добавить еше`
  String get addMore {
    return Intl.message(
      'Добавить еше',
      name: 'addMore',
      desc: '',
      args: [],
    );
  }

  /// `Введите корректное кол-во часов в неделю`
  String get enterValidHours {
    return Intl.message(
      'Введите корректное кол-во часов в неделю',
      name: 'enterValidHours',
      desc: '',
      args: [],
    );
  }

  /// `Загрузка учителей...`
  String get loadingTeachers {
    return Intl.message(
      'Загрузка учителей...',
      name: 'loadingTeachers',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, выберите предмет и учителя`
  String get selectSubjectAndTeacherError {
    return Intl.message(
      'Пожалуйста, выберите предмет и учителя',
      name: 'selectSubjectAndTeacherError',
      desc: '',
      args: [],
    );
  }

  /// `Наименование предмета`
  String get subjectNameField {
    return Intl.message(
      'Наименование предмета',
      name: 'subjectNameField',
      desc: '',
      args: [],
    );
  }

  /// `Наименование`
  String get subjectNameHint {
    return Intl.message(
      'Наименование',
      name: 'subjectNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Кол-во часов в неделю`
  String get hoursPerWeekField {
    return Intl.message(
      'Кол-во часов в неделю',
      name: 'hoursPerWeekField',
      desc: '',
      args: [],
    );
  }

  /// `Кол-во часов`
  String get hoursPerWeekHint {
    return Intl.message(
      'Кол-во часов',
      name: 'hoursPerWeekHint',
      desc: '',
      args: [],
    );
  }

  /// `Уроки пересекаются !`
  String get lessonsConflict {
    return Intl.message(
      'Уроки пересекаются !',
      name: 'lessonsConflict',
      desc: '',
      args: [],
    );
  }

  /// `Вы не можете установить урок в `
  String get lessonsConflictDesc1 {
    return Intl.message(
      'Вы не можете установить урок в ',
      name: 'lessonsConflictDesc1',
      desc: '',
      args: [],
    );
  }

  /// ` у класса `
  String get lessonsConflictDesc2 {
    return Intl.message(
      ' у класса ',
      name: 'lessonsConflictDesc2',
      desc: '',
      args: [],
    );
  }

  /// `, так как в это время у учителя `
  String get lessonsConflictDesc3 {
    return Intl.message(
      ', так как в это время у учителя ',
      name: 'lessonsConflictDesc3',
      desc: '',
      args: [],
    );
  }

  /// ` урок в `
  String get lessonsConflictDesc4 {
    return Intl.message(
      ' урок в ',
      name: 'lessonsConflictDesc4',
      desc: '',
      args: [],
    );
  }

  /// `Вы можете оставить изменение и скорректировать расписание в другом классе что бы не было пересечения уроков.`
  String get lessonsConflictMessage {
    return Intl.message(
      'Вы можете оставить изменение и скорректировать расписание в другом классе что бы не было пересечения уроков.',
      name: 'lessonsConflictMessage',
      desc: '',
      args: [],
    );
  }

  /// `Не сохранять`
  String get doNotSave {
    return Intl.message(
      'Не сохранять',
      name: 'doNotSave',
      desc: '',
      args: [],
    );
  }

  /// `Изменение баллов`
  String get changePointsTitle {
    return Intl.message(
      'Изменение баллов',
      name: 'changePointsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Кол-во баллов`
  String get pointsCount {
    return Intl.message(
      'Кол-во баллов',
      name: 'pointsCount',
      desc: '',
      args: [],
    );
  }

  /// `Уточните кол-во баллов которые хотите добавить / забрать.`
  String get changePointsHint {
    return Intl.message(
      'Уточните кол-во баллов которые хотите добавить / забрать.',
      name: 'changePointsHint',
      desc: '',
      args: [],
    );
  }

  /// `Введите количество монет`
  String get enterCoinAmount {
    return Intl.message(
      'Введите количество монет',
      name: 'enterCoinAmount',
      desc: '',
      args: [],
    );
  }

  /// `Забрать`
  String get takePoints {
    return Intl.message(
      'Забрать',
      name: 'takePoints',
      desc: '',
      args: [],
    );
  }

  /// `Добавить`
  String get addPoints {
    return Intl.message(
      'Добавить',
      name: 'addPoints',
      desc: '',
      args: [],
    );
  }

  /// `Оплачено`
  String get paid {
    return Intl.message(
      'Оплачено',
      name: 'paid',
      desc: '',
      args: [],
    );
  }

  /// `Не оплачено`
  String get notPaid {
    return Intl.message(
      'Не оплачено',
      name: 'notPaid',
      desc: '',
      args: [],
    );
  }

  /// `Ученик - {className} класс`
  String studentClass(Object className) {
    return Intl.message(
      'Ученик - $className класс',
      name: 'studentClass',
      desc: '',
      args: [className],
    );
  }

  /// `Неделя`
  String get weekTab {
    return Intl.message(
      'Неделя',
      name: 'weekTab',
      desc: '',
      args: [],
    );
  }

  /// `Месяц`
  String get monthTab {
    return Intl.message(
      'Месяц',
      name: 'monthTab',
      desc: '',
      args: [],
    );
  }

  /// `Год`
  String get yearTab {
    return Intl.message(
      'Год',
      name: 'yearTab',
      desc: '',
      args: [],
    );
  }

  /// `Не удалось загрузить данные`
  String get failedToLoadData {
    return Intl.message(
      'Не удалось загрузить данные',
      name: 'failedToLoadData',
      desc: '',
      args: [],
    );
  }

  /// `Ваш средний балл за:`
  String get yourAvgScoreFor {
    return Intl.message(
      'Ваш средний балл за:',
      name: 'yourAvgScoreFor',
      desc: '',
      args: [],
    );
  }

  /// `Среднее значение оценок за неделю`
  String get avgScoreForWeek {
    return Intl.message(
      'Среднее значение оценок за неделю',
      name: 'avgScoreForWeek',
      desc: '',
      args: [],
    );
  }

  /// `Среднее значение ваших оценок за неделю, месяц или год`
  String get yourAvgScoreForWeek {
    return Intl.message(
      'Среднее значение ваших оценок за неделю, месяц или год',
      name: 'yourAvgScoreForWeek',
      desc: '',
      args: [],
    );
  }

  /// `Выберите класс в котором будет проводиться конкурс`
  String get selectContestClassHint {
    return Intl.message(
      'Выберите класс в котором будет проводиться конкурс',
      name: 'selectContestClassHint',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите название конкурса`
  String get pleaseEnterContestName {
    return Intl.message(
      'Пожалуйста, введите название конкурса',
      name: 'pleaseEnterContestName',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите описание конкурса`
  String get pleaseEnterContestDesc {
    return Intl.message(
      'Пожалуйста, введите описание конкурса',
      name: 'pleaseEnterContestDesc',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, назначьте награды за призовые места`
  String get pleaseAssignRewards {
    return Intl.message(
      'Пожалуйста, назначьте награды за призовые места',
      name: 'pleaseAssignRewards',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, выберите хотя бы один класс для участия в конкурсе`
  String get pleaseSelectContestClass {
    return Intl.message(
      'Пожалуйста, выберите хотя бы один класс для участия в конкурсе',
      name: 'pleaseSelectContestClass',
      desc: '',
      args: [],
    );
  }

  /// `Начать конкурс`
  String get startContest {
    return Intl.message(
      'Начать конкурс',
      name: 'startContest',
      desc: '',
      args: [],
    );
  }

  /// `Конкурс успешно завершен`
  String get contestSuccessCompleted {
    return Intl.message(
      'Конкурс успешно завершен',
      name: 'contestSuccessCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Конкурс успешно создан`
  String get contestCreated {
    return Intl.message(
      'Конкурс успешно создан',
      name: 'contestCreated',
      desc: '',
      args: [],
    );
  }

  /// `Завершение конкурса`
  String get finishContestTitle {
    return Intl.message(
      'Завершение конкурса',
      name: 'finishContestTitle',
      desc: '',
      args: [],
    );
  }

  /// `Завершить`
  String get finish {
    return Intl.message(
      'Завершить',
      name: 'finish',
      desc: '',
      args: [],
    );
  }

  /// `Выбор первого места`
  String get selectFirstPlace {
    return Intl.message(
      'Выбор первого места',
      name: 'selectFirstPlace',
      desc: '',
      args: [],
    );
  }

  /// `Заявки на обмен`
  String get exchangeOrders {
    return Intl.message(
      'Заявки на обмен',
      name: 'exchangeOrders',
      desc: '',
      args: [],
    );
  }

  /// `Добавить товар`
  String get addProduct {
    return Intl.message(
      'Добавить товар',
      name: 'addProduct',
      desc: '',
      args: [],
    );
  }

  /// `Добавьте товар для обмена на баллы. Загрузите фото и описание с ценой предмета.`
  String get addProductHint {
    return Intl.message(
      'Добавьте товар для обмена на баллы. Загрузите фото и описание с ценой предмета.',
      name: 'addProductHint',
      desc: '',
      args: [],
    );
  }

  /// `Введите данные`
  String get enterData {
    return Intl.message(
      'Введите данные',
      name: 'enterData',
      desc: '',
      args: [],
    );
  }

  /// `Название:`
  String get nameLabel {
    return Intl.message(
      'Название:',
      name: 'nameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Название`
  String get nameHint {
    return Intl.message(
      'Название',
      name: 'nameHint',
      desc: '',
      args: [],
    );
  }

  /// `Цена:`
  String get priceLabel {
    return Intl.message(
      'Цена:',
      name: 'priceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Цена`
  String get priceHint {
    return Intl.message(
      'Цена',
      name: 'priceHint',
      desc: '',
      args: [],
    );
  }

  /// `Фотография:`
  String get photoLabel {
    return Intl.message(
      'Фотография:',
      name: 'photoLabel',
      desc: '',
      args: [],
    );
  }

  /// `Произошла ошибка при добавлении предмета`
  String get productAddError {
    return Intl.message(
      'Произошла ошибка при добавлении предмета',
      name: 'productAddError',
      desc: '',
      args: [],
    );
  }

  /// `Предмет успешно добавлен`
  String get productAddSuccess {
    return Intl.message(
      'Предмет успешно добавлен',
      name: 'productAddSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Предмет успешно удален`
  String get productDeleteSuccess {
    return Intl.message(
      'Предмет успешно удален',
      name: 'productDeleteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Удалить предмет`
  String get deleteProduct {
    return Intl.message(
      'Удалить предмет',
      name: 'deleteProduct',
      desc: '',
      args: [],
    );
  }

  /// `Удалить предмет ?`
  String get deleteProductTitle {
    return Intl.message(
      'Удалить предмет ?',
      name: 'deleteProductTitle',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите удалить этого предмет? Это действие нельзя будет отменить.`
  String get deleteProductConfirm {
    return Intl.message(
      'Вы уверены, что хотите удалить этого предмет? Это действие нельзя будет отменить.',
      name: 'deleteProductConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите название предмета`
  String get pleaseEnterProductName {
    return Intl.message(
      'Пожалуйста, введите название предмета',
      name: 'pleaseEnterProductName',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите цену предмета`
  String get pleaseEnterProductPrice {
    return Intl.message(
      'Пожалуйста, введите цену предмета',
      name: 'pleaseEnterProductPrice',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, загрузите фотографию предмета`
  String get pleaseUploadProductPhoto {
    return Intl.message(
      'Пожалуйста, загрузите фотографию предмета',
      name: 'pleaseUploadProductPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Добавить предмет`
  String get addProductButton {
    return Intl.message(
      'Добавить предмет',
      name: 'addProductButton',
      desc: '',
      args: [],
    );
  }

  /// `На данный момент товаров в магазине нет`
  String get noProductsInShop {
    return Intl.message(
      'На данный момент товаров в магазине нет',
      name: 'noProductsInShop',
      desc: '',
      args: [],
    );
  }

  /// `Ожидает подтверждения:`
  String get pendingConfirmation {
    return Intl.message(
      'Ожидает подтверждения:',
      name: 'pendingConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Ожидает выполнения:`
  String get pendingExecution {
    return Intl.message(
      'Ожидает выполнения:',
      name: 'pendingExecution',
      desc: '',
      args: [],
    );
  }

  /// `Заказанные предметы:`
  String get orderedItems {
    return Intl.message(
      'Заказанные предметы:',
      name: 'orderedItems',
      desc: '',
      args: [],
    );
  }

  /// `Отклонить заявку`
  String get rejectOrder {
    return Intl.message(
      'Отклонить заявку',
      name: 'rejectOrder',
      desc: '',
      args: [],
    );
  }

  /// `Подтвердить заявку`
  String get confirmOrder {
    return Intl.message(
      'Подтвердить заявку',
      name: 'confirmOrder',
      desc: '',
      args: [],
    );
  }

  /// `Связаться с учеником`
  String get contactStudent {
    return Intl.message(
      'Связаться с учеником',
      name: 'contactStudent',
      desc: '',
      args: [],
    );
  }

  /// `Предмет вручен ученику`
  String get itemDelivered {
    return Intl.message(
      'Предмет вручен ученику',
      name: 'itemDelivered',
      desc: '',
      args: [],
    );
  }

  /// `Поиск учителя...`
  String get searchTeacher {
    return Intl.message(
      'Поиск учителя...',
      name: 'searchTeacher',
      desc: '',
      args: [],
    );
  }

  /// `Ваши учителя:`
  String get yourTeachers {
    return Intl.message(
      'Ваши учителя:',
      name: 'yourTeachers',
      desc: '',
      args: [],
    );
  }

  /// `Все учителя:`
  String get allTeachers {
    return Intl.message(
      'Все учителя:',
      name: 'allTeachers',
      desc: '',
      args: [],
    );
  }

  /// `Учителя не найдены`
  String get teachersNotFound {
    return Intl.message(
      'Учителя не найдены',
      name: 'teachersNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Добавить учителя`
  String get addTeacher {
    return Intl.message(
      'Добавить учителя',
      name: 'addTeacher',
      desc: '',
      args: [],
    );
  }

  /// `Удалить преподавателя ?`
  String get deleteTeacherTitle {
    return Intl.message(
      'Удалить преподавателя ?',
      name: 'deleteTeacherTitle',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите удалить этого преподавателя? Это действие нельзя будет отменить.`
  String get deleteTeacherConfirm {
    return Intl.message(
      'Вы уверены, что хотите удалить этого преподавателя? Это действие нельзя будет отменить.',
      name: 'deleteTeacherConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Удалить класс ?`
  String get deleteClassTitle {
    return Intl.message(
      'Удалить класс ?',
      name: 'deleteClassTitle',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите удалить этот класс? Это действие нельзя будет отменить.`
  String get deleteClassConfirm {
    return Intl.message(
      'Вы уверены, что хотите удалить этот класс? Это действие нельзя будет отменить.',
      name: 'deleteClassConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка удаления преподавателя`
  String get deleteTeacherError {
    return Intl.message(
      'Ошибка удаления преподавателя',
      name: 'deleteTeacherError',
      desc: '',
      args: [],
    );
  }

  /// `Преподаватель успешно удален`
  String get teacherDeleteSuccess {
    return Intl.message(
      'Преподаватель успешно удален',
      name: 'teacherDeleteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при добавлении преподавателя`
  String get addTeacherError {
    return Intl.message(
      'Ошибка при добавлении преподавателя',
      name: 'addTeacherError',
      desc: '',
      args: [],
    );
  }

  /// `Преподаватель успешно добавлен`
  String get addTeacherSuccess {
    return Intl.message(
      'Преподаватель успешно добавлен',
      name: 'addTeacherSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Введите персональные данные:`
  String get enterPersonalData {
    return Intl.message(
      'Введите персональные данные:',
      name: 'enterPersonalData',
      desc: '',
      args: [],
    );
  }

  /// `ФИО:`
  String get fullNameLabel {
    return Intl.message(
      'ФИО:',
      name: 'fullNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Имя`
  String get firstName {
    return Intl.message(
      'Имя',
      name: 'firstName',
      desc: '',
      args: [],
    );
  }

  /// `Фамилия`
  String get lastName {
    return Intl.message(
      'Фамилия',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }

  /// `Отчество`
  String get fatherName {
    return Intl.message(
      'Отчество',
      name: 'fatherName',
      desc: '',
      args: [],
    );
  }

  /// `Номер телефона`
  String get phoneNumber {
    return Intl.message(
      'Номер телефона',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Дата рождения:`
  String get birthDateLabel {
    return Intl.message(
      'Дата рождения:',
      name: 'birthDateLabel',
      desc: '',
      args: [],
    );
  }

  /// `ДД.ММ.ГГГГ`
  String get dateFormat {
    return Intl.message(
      'ДД.ММ.ГГГГ',
      name: 'dateFormat',
      desc: '',
      args: [],
    );
  }

  /// `Предмет:`
  String get subjectLabel {
    return Intl.message(
      'Предмет:',
      name: 'subjectLabel',
      desc: '',
      args: [],
    );
  }

  /// `Алгебра`
  String get subjectHint {
    return Intl.message(
      'Алгебра',
      name: 'subjectHint',
      desc: '',
      args: [],
    );
  }

  /// `Стаж работы:`
  String get workExperienceShort {
    return Intl.message(
      'Стаж работы:',
      name: 'workExperienceShort',
      desc: '',
      args: [],
    );
  }

  /// `год`
  String get yearSuffix {
    return Intl.message(
      'год',
      name: 'yearSuffix',
      desc: '',
      args: [],
    );
  }

  /// `Образование`
  String get educationHint {
    return Intl.message(
      'Образование',
      name: 'educationHint',
      desc: '',
      args: [],
    );
  }

  /// `Краткое описание:`
  String get shortDescription {
    return Intl.message(
      'Краткое описание:',
      name: 'shortDescription',
      desc: '',
      args: [],
    );
  }

  /// `описание`
  String get descriptionHint {
    return Intl.message(
      'описание',
      name: 'descriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Введите данные от аккаунта`
  String get enterAccountData {
    return Intl.message(
      'Введите данные от аккаунта',
      name: 'enterAccountData',
      desc: '',
      args: [],
    );
  }

  /// `Логин`
  String get loginLabel {
    return Intl.message(
      'Логин',
      name: 'loginLabel',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите имя`
  String get pleaseEnterFirstName {
    return Intl.message(
      'Пожалуйста, введите имя',
      name: 'pleaseEnterFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите фамилию`
  String get pleaseEnterLastName {
    return Intl.message(
      'Пожалуйста, введите фамилию',
      name: 'pleaseEnterLastName',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите отчество`
  String get pleaseEnterFatherName {
    return Intl.message(
      'Пожалуйста, введите отчество',
      name: 'pleaseEnterFatherName',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите дату рождения`
  String get pleaseEnterBirthDate {
    return Intl.message(
      'Пожалуйста, введите дату рождения',
      name: 'pleaseEnterBirthDate',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите Номер телефона`
  String get pleaseEnterPhone {
    return Intl.message(
      'Пожалуйста, введите Номер телефона',
      name: 'pleaseEnterPhone',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите предмет`
  String get pleaseEnterSubject {
    return Intl.message(
      'Пожалуйста, введите предмет',
      name: 'pleaseEnterSubject',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите стаж работы`
  String get pleaseEnterWorkExp {
    return Intl.message(
      'Пожалуйста, введите стаж работы',
      name: 'pleaseEnterWorkExp',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите образование`
  String get pleaseEnterEducation {
    return Intl.message(
      'Пожалуйста, введите образование',
      name: 'pleaseEnterEducation',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите логин`
  String get pleaseEnterLogin {
    return Intl.message(
      'Пожалуйста, введите логин',
      name: 'pleaseEnterLogin',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите пароль`
  String get pleaseEnterPassword {
    return Intl.message(
      'Пожалуйста, введите пароль',
      name: 'pleaseEnterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Добавлен учитель`
  String get teacherAdded {
    return Intl.message(
      'Добавлен учитель',
      name: 'teacherAdded',
      desc: '',
      args: [],
    );
  }

  /// `Вы добавили нового учителя !`
  String get teacherAddedMessage {
    return Intl.message(
      'Вы добавили нового учителя !',
      name: 'teacherAddedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Данные для входа`
  String get loginDataTitle {
    return Intl.message(
      'Данные для входа',
      name: 'loginDataTitle',
      desc: '',
      args: [],
    );
  }

  /// `Сохраните и отправьте данные для входа`
  String get loginDataHint {
    return Intl.message(
      'Сохраните и отправьте данные для входа',
      name: 'loginDataHint',
      desc: '',
      args: [],
    );
  }

  /// `Информация для входа на платформу Аль-Хорезми:\n\nLogin: {email}\nParol: {password}`
  String loginInfoMessage(String email, String password) {
    return Intl.message(
      'Информация для входа на платформу Аль-Хорезми:\n\nLogin: $email\nParol: $password',
      name: 'loginInfoMessage',
      desc: '',
      args: [email, password],
    );
  }

  /// `Опыт работы:`
  String get workExperienceLabel {
    return Intl.message(
      'Опыт работы:',
      name: 'workExperienceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Поиск родители...`
  String get searchParent {
    return Intl.message(
      'Поиск родители...',
      name: 'searchParent',
      desc: '',
      args: [],
    );
  }

  /// `Родители не найдены`
  String get parentsNotFound {
    return Intl.message(
      'Родители не найдены',
      name: 'parentsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Добавить родителя`
  String get addParent {
    return Intl.message(
      'Добавить родителя',
      name: 'addParent',
      desc: '',
      args: [],
    );
  }

  /// `Удалить Родитель ?`
  String get deleteParentTitle {
    return Intl.message(
      'Удалить Родитель ?',
      name: 'deleteParentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите удалить этого Родитель? Это действие нельзя будет отменить.`
  String get deleteParentConfirm {
    return Intl.message(
      'Вы уверены, что хотите удалить этого Родитель? Это действие нельзя будет отменить.',
      name: 'deleteParentConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Ребенок:`
  String get childLabel {
    return Intl.message(
      'Ребенок:',
      name: 'childLabel',
      desc: '',
      args: [],
    );
  }

  /// `Добавить Ребенок`
  String get addChild {
    return Intl.message(
      'Добавить Ребенок',
      name: 'addChild',
      desc: '',
      args: [],
    );
  }

  /// `Данные успешно сохранены`
  String get dataSavedSuccess {
    return Intl.message(
      'Данные успешно сохранены',
      name: 'dataSavedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, добавьте хотя бы одного ребенка`
  String get pleaseAddChild {
    return Intl.message(
      'Пожалуйста, добавьте хотя бы одного ребенка',
      name: 'pleaseAddChild',
      desc: '',
      args: [],
    );
  }

  /// `Добавлен родитель`
  String get parentAdded {
    return Intl.message(
      'Добавлен родитель',
      name: 'parentAdded',
      desc: '',
      args: [],
    );
  }

  /// `Вы добавили нового родителя !`
  String get parentAddedMessage {
    return Intl.message(
      'Вы добавили нового родителя !',
      name: 'parentAddedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Поиск ученики...`
  String get searchStudent {
    return Intl.message(
      'Поиск ученики...',
      name: 'searchStudent',
      desc: '',
      args: [],
    );
  }

  /// `Ученики:`
  String get studentsSection {
    return Intl.message(
      'Ученики:',
      name: 'studentsSection',
      desc: '',
      args: [],
    );
  }

  /// `Ученики не найдены`
  String get studentsNotFound {
    return Intl.message(
      'Ученики не найдены',
      name: 'studentsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Добавить ученика`
  String get addStudent {
    return Intl.message(
      'Добавить ученика',
      name: 'addStudent',
      desc: '',
      args: [],
    );
  }

  /// `Списать/Добавить баллы`
  String get deductPoints {
    return Intl.message(
      'Списать/Добавить баллы',
      name: 'deductPoints',
      desc: '',
      args: [],
    );
  }

  /// `Оплата обучения`
  String get tuitionPayment {
    return Intl.message(
      'Оплата обучения',
      name: 'tuitionPayment',
      desc: '',
      args: [],
    );
  }

  /// `Баллы успешно списаны`
  String get pointsDeducted {
    return Intl.message(
      'Баллы успешно списаны',
      name: 'pointsDeducted',
      desc: '',
      args: [],
    );
  }

  /// `Монеты успешно добавлены`
  String get coinsAddedSuccess {
    return Intl.message(
      'Монеты успешно добавлены',
      name: 'coinsAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Удалить ученика ?`
  String get deleteStudentTitle {
    return Intl.message(
      'Удалить ученика ?',
      name: 'deleteStudentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите удалить этого ученика? Это действие нельзя будет отменить.`
  String get deleteStudentConfirm {
    return Intl.message(
      'Вы уверены, что хотите удалить этого ученика? Это действие нельзя будет отменить.',
      name: 'deleteStudentConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка удаления ученика`
  String get deleteStudentError {
    return Intl.message(
      'Ошибка удаления ученика',
      name: 'deleteStudentError',
      desc: '',
      args: [],
    );
  }

  /// `Ученик успешно удален`
  String get studentDeleteSuccess {
    return Intl.message(
      'Ученик успешно удален',
      name: 'studentDeleteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Класс:`
  String get classLabelColon {
    return Intl.message(
      'Класс:',
      name: 'classLabelColon',
      desc: '',
      args: [],
    );
  }

  /// `Класс не выбран`
  String get classNotSelected {
    return Intl.message(
      'Класс не выбран',
      name: 'classNotSelected',
      desc: '',
      args: [],
    );
  }

  /// `число`
  String get paymentDaySuffix {
    return Intl.message(
      'число',
      name: 'paymentDaySuffix',
      desc: '',
      args: [],
    );
  }

  /// `Число оплаты за обучение:`
  String get tuitionDayLabel {
    return Intl.message(
      'Число оплаты за обучение:',
      name: 'tuitionDayLabel',
      desc: '',
      args: [],
    );
  }

  /// `Число оплаты`
  String get tuitionDayHint {
    return Intl.message(
      'Число оплаты',
      name: 'tuitionDayHint',
      desc: '',
      args: [],
    );
  }

  /// `каждого месяца`
  String get everyMonth {
    return Intl.message(
      'каждого месяца',
      name: 'everyMonth',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при добавлении ученика`
  String get addStudentError {
    return Intl.message(
      'Ошибка при добавлении ученика',
      name: 'addStudentError',
      desc: '',
      args: [],
    );
  }

  /// `Ученик успешно добавлен`
  String get addStudentSuccess {
    return Intl.message(
      'Ученик успешно добавлен',
      name: 'addStudentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите число оплаты`
  String get pleaseEnterPaymentDay {
    return Intl.message(
      'Пожалуйста, введите число оплаты',
      name: 'pleaseEnterPaymentDay',
      desc: '',
      args: [],
    );
  }

  /// `Добавлен ученик`
  String get studentAdded {
    return Intl.message(
      'Добавлен ученик',
      name: 'studentAdded',
      desc: '',
      args: [],
    );
  }

  /// `Вы добавили нового ученика !`
  String get studentAddedMessage {
    return Intl.message(
      'Вы добавили нового ученика !',
      name: 'studentAddedMessage',
      desc: '',
      args: [],
    );
  }

  /// `График платежей:`
  String get paymentSchedule {
    return Intl.message(
      'График платежей:',
      name: 'paymentSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Оплата за год внесена`
  String get yearPaymentDone {
    return Intl.message(
      'Оплата за год внесена',
      name: 'yearPaymentDone',
      desc: '',
      args: [],
    );
  }

  /// `Подтвердите действие`
  String get confirmAction {
    return Intl.message(
      'Подтвердите действие',
      name: 'confirmAction',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены что обучение за год оплачено ?`
  String get confirmYearPayment {
    return Intl.message(
      'Вы уверены что обучение за год оплачено ?',
      name: 'confirmYearPayment',
      desc: '',
      args: [],
    );
  }

  /// `Оплата получена`
  String get paymentReceived {
    return Intl.message(
      'Оплата получена',
      name: 'paymentReceived',
      desc: '',
      args: [],
    );
  }

  /// `Оплата за месяц внесена`
  String get monthPaymentDone {
    return Intl.message(
      'Оплата за месяц внесена',
      name: 'monthPaymentDone',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены что обучение за месяц оплачено ?`
  String get confirmMonthPayment {
    return Intl.message(
      'Вы уверены что обучение за месяц оплачено ?',
      name: 'confirmMonthPayment',
      desc: '',
      args: [],
    );
  }

  /// `Оплата за месяц успешно внесена`
  String get monthPaymentSuccess {
    return Intl.message(
      'Оплата за месяц успешно внесена',
      name: 'monthPaymentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Оплата за год успешно внесена`
  String get yearPaymentSuccess {
    return Intl.message(
      'Оплата за год успешно внесена',
      name: 'yearPaymentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Рейтинг учеников`
  String get studentsRatingTitle {
    return Intl.message(
      'Рейтинг учеников',
      name: 'studentsRatingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ниже представлен рейтинг учеников и родителей`
  String get studentsParentsRatingHint {
    return Intl.message(
      'Ниже представлен рейтинг учеников и родителей',
      name: 'studentsParentsRatingHint',
      desc: '',
      args: [],
    );
  }

  /// `Временные рамки рейтинга:`
  String get ratingTimeframe {
    return Intl.message(
      'Временные рамки рейтинга:',
      name: 'ratingTimeframe',
      desc: '',
      args: [],
    );
  }

  /// `Награды рейтинга школы:`
  String get schoolRatingRewards {
    return Intl.message(
      'Награды рейтинга школы:',
      name: 'schoolRatingRewards',
      desc: '',
      args: [],
    );
  }

  /// `Награда за ТОП 1`
  String get rewardTop1 {
    return Intl.message(
      'Награда за ТОП 1',
      name: 'rewardTop1',
      desc: '',
      args: [],
    );
  }

  /// `Награда за ТОП 2`
  String get rewardTop2 {
    return Intl.message(
      'Награда за ТОП 2',
      name: 'rewardTop2',
      desc: '',
      args: [],
    );
  }

  /// `Награда за ТОП 3`
  String get rewardTop3 {
    return Intl.message(
      'Награда за ТОП 3',
      name: 'rewardTop3',
      desc: '',
      args: [],
    );
  }

  /// `Награда за ТОП 4-5`
  String get rewardTop45 {
    return Intl.message(
      'Награда за ТОП 4-5',
      name: 'rewardTop45',
      desc: '',
      args: [],
    );
  }

  /// `Награда за ТОП 6-10`
  String get rewardTop610 {
    return Intl.message(
      'Награда за ТОП 6-10',
      name: 'rewardTop610',
      desc: '',
      args: [],
    );
  }

  /// `Награда за ТОП 11-20`
  String get rewardTop1120 {
    return Intl.message(
      'Награда за ТОП 11-20',
      name: 'rewardTop1120',
      desc: '',
      args: [],
    );
  }

  /// `Ниже представлен рейтинг учеников среди групп и школы в целом.`
  String get studentsRatingHint {
    return Intl.message(
      'Ниже представлен рейтинг учеников среди групп и школы в целом.',
      name: 'studentsRatingHint',
      desc: '',
      args: [],
    );
  }

  /// `Школа`
  String get school {
    return Intl.message(
      'Школа',
      name: 'school',
      desc: '',
      args: [],
    );
  }

  /// `Группы`
  String get groups {
    return Intl.message(
      'Группы',
      name: 'groups',
      desc: '',
      args: [],
    );
  }

  /// `Рейтинг родителей`
  String get parentsRatingTitle {
    return Intl.message(
      'Рейтинг родителей',
      name: 'parentsRatingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ниже представлен рейтинг родителей среди школы.`
  String get parentsRatingHint {
    return Intl.message(
      'Ниже представлен рейтинг родителей среди школы.',
      name: 'parentsRatingHint',
      desc: '',
      args: [],
    );
  }

  /// `Текущие опросы`
  String get currentPolls {
    return Intl.message(
      'Текущие опросы',
      name: 'currentPolls',
      desc: '',
      args: [],
    );
  }

  /// `Пока нет ни одного опроса. Нажмите кнопку ниже, чтобы создать новый опрос.`
  String get noPollsYet {
    return Intl.message(
      'Пока нет ни одного опроса. Нажмите кнопку ниже, чтобы создать новый опрос.',
      name: 'noPollsYet',
      desc: '',
      args: [],
    );
  }

  /// `Удалить опрос`
  String get deletePoll {
    return Intl.message(
      'Удалить опрос',
      name: 'deletePoll',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите удалить этот опрос?`
  String get deletePollConfirm {
    return Intl.message(
      'Вы уверены, что хотите удалить этот опрос?',
      name: 'deletePollConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при удалении опроса`
  String get deletePollError {
    return Intl.message(
      'Ошибка при удалении опроса',
      name: 'deletePollError',
      desc: '',
      args: [],
    );
  }

  /// `Создать опрос`
  String get createPoll {
    return Intl.message(
      'Создать опрос',
      name: 'createPoll',
      desc: '',
      args: [],
    );
  }

  /// `Редактирование опроса`
  String get editPollTitle {
    return Intl.message(
      'Редактирование опроса',
      name: 'editPollTitle',
      desc: '',
      args: [],
    );
  }

  /// `Создание опроса`
  String get createPollTitle {
    return Intl.message(
      'Создание опроса',
      name: 'createPollTitle',
      desc: '',
      args: [],
    );
  }

  /// `Тема опроса`
  String get pollTopic {
    return Intl.message(
      'Тема опроса',
      name: 'pollTopic',
      desc: '',
      args: [],
    );
  }

  /// `Вопрос`
  String get questionHint {
    return Intl.message(
      'Вопрос',
      name: 'questionHint',
      desc: '',
      args: [],
    );
  }

  /// `Ответ {number}`
  String answerNumber(int number) {
    return Intl.message(
      'Ответ $number',
      name: 'answerNumber',
      desc: '',
      args: [number],
    );
  }

  /// `+ Добавить вариант`
  String get addAnswer {
    return Intl.message(
      '+ Добавить вариант',
      name: 'addAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Добавить вопрос`
  String get addQuestion {
    return Intl.message(
      'Добавить вопрос',
      name: 'addQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Перед добавлением нового вопроса заполните все поля текущего вопроса и его ответов`
  String get fillCurrentQuestionFirst {
    return Intl.message(
      'Перед добавлением нового вопроса заполните все поля текущего вопроса и его ответов',
      name: 'fillCurrentQuestionFirst',
      desc: '',
      args: [],
    );
  }

  /// `Заполните тему опроса, все вопросы и их варианты ответов`
  String get fillPollFields {
    return Intl.message(
      'Заполните тему опроса, все вопросы и их варианты ответов',
      name: 'fillPollFields',
      desc: '',
      args: [],
    );
  }

  /// `Опрос успешно обновлен`
  String get pollUpdated {
    return Intl.message(
      'Опрос успешно обновлен',
      name: 'pollUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Опрос успешно создан`
  String get pollCreated {
    return Intl.message(
      'Опрос успешно создан',
      name: 'pollCreated',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при получении данных опроса`
  String get getPollError {
    return Intl.message(
      'Ошибка при получении данных опроса',
      name: 'getPollError',
      desc: '',
      args: [],
    );
  }

  /// `Статистика ответов`
  String get answerStatistics {
    return Intl.message(
      'Статистика ответов',
      name: 'answerStatistics',
      desc: '',
      args: [],
    );
  }

  /// `Отправить пуш-уведомление`
  String get sendPushNotification {
    return Intl.message(
      'Отправить пуш-уведомление',
      name: 'sendPushNotification',
      desc: '',
      args: [],
    );
  }

  /// `Создать класс`
  String get createClass {
    return Intl.message(
      'Создать класс',
      name: 'createClass',
      desc: '',
      args: [],
    );
  }

  /// `Классный руководитель:`
  String get classTeacher {
    return Intl.message(
      'Классный руководитель:',
      name: 'classTeacher',
      desc: '',
      args: [],
    );
  }

  /// `Учитель не выбран`
  String get teacherNotSelected {
    return Intl.message(
      'Учитель не выбран',
      name: 'teacherNotSelected',
      desc: '',
      args: [],
    );
  }

  /// `Недостаточно прав для просмотра деталей ученика`
  String get noPermissionToViewStudent {
    return Intl.message(
      'Недостаточно прав для просмотра деталей ученика',
      name: 'noPermissionToViewStudent',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка загрузки данных класса`
  String get classLoadError {
    return Intl.message(
      'Ошибка загрузки данных класса',
      name: 'classLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Добавить класс`
  String get addClass {
    return Intl.message(
      'Добавить класс',
      name: 'addClass',
      desc: '',
      args: [],
    );
  }

  /// `Номер класса:`
  String get classNumberLabel {
    return Intl.message(
      'Номер класса:',
      name: 'classNumberLabel',
      desc: '',
      args: [],
    );
  }

  /// `(1 -11)`
  String get classNumberHint {
    return Intl.message(
      '(1 -11)',
      name: 'classNumberHint',
      desc: '',
      args: [],
    );
  }

  /// `Номер`
  String get classNumberInput {
    return Intl.message(
      'Номер',
      name: 'classNumberInput',
      desc: '',
      args: [],
    );
  }

  /// `Буква класса:`
  String get classLetterLabel {
    return Intl.message(
      'Буква класса:',
      name: 'classLetterLabel',
      desc: '',
      args: [],
    );
  }

  /// `(А / Б / В / Г)`
  String get classLetterHint {
    return Intl.message(
      '(А / Б / В / Г)',
      name: 'classLetterHint',
      desc: '',
      args: [],
    );
  }

  /// `Буква`
  String get classLetterInput {
    return Intl.message(
      'Буква',
      name: 'classLetterInput',
      desc: '',
      args: [],
    );
  }

  /// `руководитель`
  String get classTeacherHint {
    return Intl.message(
      'руководитель',
      name: 'classTeacherHint',
      desc: '',
      args: [],
    );
  }

  /// `Добавить учеников`
  String get addStudents {
    return Intl.message(
      'Добавить учеников',
      name: 'addStudents',
      desc: '',
      args: [],
    );
  }

  /// `Удалить участника`
  String get removeParticipant {
    return Intl.message(
      'Удалить участника',
      name: 'removeParticipant',
      desc: '',
      args: [],
    );
  }

  /// `Вы точно хотите удалить из класса:`
  String get confirmRemoveFromClass {
    return Intl.message(
      'Вы точно хотите удалить из класса:',
      name: 'confirmRemoveFromClass',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, выберите номер класса`
  String get pleaseSelectClassNumber {
    return Intl.message(
      'Пожалуйста, выберите номер класса',
      name: 'pleaseSelectClassNumber',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите букву класса`
  String get pleaseEnterClassLetter {
    return Intl.message(
      'Пожалуйста, введите букву класса',
      name: 'pleaseEnterClassLetter',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, выберите классного руководителя`
  String get pleaseSelectClassTeacher {
    return Intl.message(
      'Пожалуйста, выберите классного руководителя',
      name: 'pleaseSelectClassTeacher',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при добавлении класса`
  String get addClassError {
    return Intl.message(
      'Ошибка при добавлении класса',
      name: 'addClassError',
      desc: '',
      args: [],
    );
  }

  /// `Класс успешно создан`
  String get classCreated {
    return Intl.message(
      'Класс успешно создан',
      name: 'classCreated',
      desc: '',
      args: [],
    );
  }

  /// `Редактировать класс`
  String get editClass {
    return Intl.message(
      'Редактировать класс',
      name: 'editClass',
      desc: '',
      args: [],
    );
  }

  /// `Класс успешно обновлён`
  String get classUpdated {
    return Intl.message(
      'Класс успешно обновлён',
      name: 'classUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Создать расписание`
  String get createSchedule {
    return Intl.message(
      'Создать расписание',
      name: 'createSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Понедельник`
  String get monday {
    return Intl.message(
      'Понедельник',
      name: 'monday',
      desc: '',
      args: [],
    );
  }

  /// `Вторник`
  String get tuesday {
    return Intl.message(
      'Вторник',
      name: 'tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Среда`
  String get wednesday {
    return Intl.message(
      'Среда',
      name: 'wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Четверг`
  String get thursday {
    return Intl.message(
      'Четверг',
      name: 'thursday',
      desc: '',
      args: [],
    );
  }

  /// `Пятница`
  String get friday {
    return Intl.message(
      'Пятница',
      name: 'friday',
      desc: '',
      args: [],
    );
  }

  /// `Суббота`
  String get saturday {
    return Intl.message(
      'Суббота',
      name: 'saturday',
      desc: '',
      args: [],
    );
  }

  /// `Нет расписания на {day}`
  String noScheduleForDay(String day) {
    return Intl.message(
      'Нет расписания на $day',
      name: 'noScheduleForDay',
      desc: '',
      args: [day],
    );
  }

  /// `Изменить расписание`
  String get editSchedule {
    return Intl.message(
      'Изменить расписание',
      name: 'editSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, выберите класс`
  String get pleaseSelectClass {
    return Intl.message(
      'Пожалуйста, выберите класс',
      name: 'pleaseSelectClass',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, добавьте хотя бы один предмет`
  String get pleaseAddSubject {
    return Intl.message(
      'Пожалуйста, добавьте хотя бы один предмет',
      name: 'pleaseAddSubject',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, уберите конфликты с учителями`
  String get pleaseRemoveTeacherConflicts {
    return Intl.message(
      'Пожалуйста, уберите конфликты с учителями',
      name: 'pleaseRemoveTeacherConflicts',
      desc: '',
      args: [],
    );
  }

  /// `Расписание успешно сохранено`
  String get scheduleSaved {
    return Intl.message(
      'Расписание успешно сохранено',
      name: 'scheduleSaved',
      desc: '',
      args: [],
    );
  }

  /// `Создание расписания`
  String get createScheduleTitle {
    return Intl.message(
      'Создание расписания',
      name: 'createScheduleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Выберите параллель:`
  String get selectParallel {
    return Intl.message(
      'Выберите параллель:',
      name: 'selectParallel',
      desc: '',
      args: [],
    );
  }

  /// `Предметы:`
  String get subjectsSection {
    return Intl.message(
      'Предметы:',
      name: 'subjectsSection',
      desc: '',
      args: [],
    );
  }

  /// `Нет предметов`
  String get noSubjects {
    return Intl.message(
      'Нет предметов',
      name: 'noSubjects',
      desc: '',
      args: [],
    );
  }

  /// `Добавить предмет`
  String get addSubjectButton {
    return Intl.message(
      'Добавить предмет',
      name: 'addSubjectButton',
      desc: '',
      args: [],
    );
  }

  /// `Составление расписания`
  String get compileSchedule {
    return Intl.message(
      'Составление расписания',
      name: 'compileSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Расписание {grade} "{section}" класс`
  String scheduleTitle(String grade, String section) {
    return Intl.message(
      'Расписание $grade "$section" класс',
      name: 'scheduleTitle',
      desc: '',
      args: [grade, section],
    );
  }

  /// `Оценки`
  String get gradesFilter {
    return Intl.message(
      'Оценки',
      name: 'gradesFilter',
      desc: '',
      args: [],
    );
  }

  /// `Вы еще не получили никаких уведомлений!`
  String get noNotificationsYet {
    return Intl.message(
      'Вы еще не получили никаких уведомлений!',
      name: 'noNotificationsYet',
      desc: '',
      args: [],
    );
  }

  /// `Чаты недоступны`
  String get chatsUnavailable {
    return Intl.message(
      'Чаты недоступны',
      name: 'chatsUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Чтобы начать новую беседу, нажмите кнопку «Отправить сообщение» в профиле пользователя.`
  String get chatsUnavailableHint {
    return Intl.message(
      'Чтобы начать новую беседу, нажмите кнопку «Отправить сообщение» в профиле пользователя.',
      name: 'chatsUnavailableHint',
      desc: '',
      args: [],
    );
  }

  /// `Тема приложения`
  String get app_theme {
    return Intl.message(
      'Тема приложения',
      name: 'app_theme',
      desc: '',
      args: [],
    );
  }

  /// `Светлая тема`
  String get light_mode {
    return Intl.message(
      'Светлая тема',
      name: 'light_mode',
      desc: '',
      args: [],
    );
  }

  /// `Темная тема`
  String get dark_mode {
    return Intl.message(
      'Темная тема',
      name: 'dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Другие настройки`
  String get other_settings {
    return Intl.message(
      'Другие настройки',
      name: 'other_settings',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить расписание`
  String get saveSchedule {
    return Intl.message(
      'Сохранить расписание',
      name: 'saveSchedule',
      desc: '',
      args: [],
    );
  }

  /// `ч`
  String get hoursAbbreviation {
    return Intl.message(
      'ч',
      name: 'hoursAbbreviation',
      desc: '',
      args: [],
    );
  }

  /// `Предмет не указан`
  String get subjectNotSpecified {
    return Intl.message(
      'Предмет не указан',
      name: 'subjectNotSpecified',
      desc: '',
      args: [],
    );
  }

  /// `Ваш баланс:`
  String get yourBalance {
    return Intl.message(
      'Ваш баланс:',
      name: 'yourBalance',
      desc: '',
      args: [],
    );
  }

  /// `Пополнение`
  String get replenishment {
    return Intl.message(
      'Пополнение',
      name: 'replenishment',
      desc: '',
      args: [],
    );
  }

  /// `Списание`
  String get deduction {
    return Intl.message(
      'Списание',
      name: 'deduction',
      desc: '',
      args: [],
    );
  }

  /// `Если у выбранного предмета имеются дополнительные детали: цвет, размер тд. То администрация уточнит их у вас`
  String get cartItemDetailsHint {
    return Intl.message(
      'Если у выбранного предмета имеются дополнительные детали: цвет, размер тд. То администрация уточнит их у вас',
      name: 'cartItemDetailsHint',
      desc: '',
      args: [],
    );
  }

  /// `шт`
  String get pcsUnit {
    return Intl.message(
      'шт',
      name: 'pcsUnit',
      desc: '',
      args: [],
    );
  }

  /// `Здесь вы скачиваете задания учителя и загружаете ответы на них.`
  String get homeworkBannerHint {
    return Intl.message(
      'Здесь вы скачиваете задания учителя и загружаете ответы на них.',
      name: 'homeworkBannerHint',
      desc: '',
      args: [],
    );
  }

  /// `Загрузить можно файлы: PDF, DOCX, JPG`
  String get supportedFileFormats {
    return Intl.message(
      'Загрузить можно файлы: PDF, DOCX, JPG',
      name: 'supportedFileFormats',
      desc: '',
      args: [],
    );
  }

  /// `Ученик - {grade} "{section}" - класс`
  String studentClassGradeSection(String grade, String section) {
    return Intl.message(
      'Ученик - $grade "$section" - класс',
      name: 'studentClassGradeSection',
      desc: '',
      args: [grade, section],
    );
  }

  /// `Имя не указано`
  String get nameNotEntered {
    return Intl.message(
      'Имя не указано',
      name: 'nameNotEntered',
      desc: '',
      args: [],
    );
  }

  /// `Недоступно`
  String get notAvailable {
    return Intl.message(
      'Недоступно',
      name: 'notAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Пропуск`
  String get absence {
    return Intl.message(
      'Пропуск',
      name: 'absence',
      desc: '',
      args: [],
    );
  }

  /// `Дневник `
  String get diaryLabel {
    return Intl.message(
      'Дневник ',
      name: 'diaryLabel',
      desc: '',
      args: [],
    );
  }

  /// `(все предметы)`
  String get allSubjectsParenthesis {
    return Intl.message(
      '(все предметы)',
      name: 'allSubjectsParenthesis',
      desc: '',
      args: [],
    );
  }

  /// `Назначить домашнюю работу:`
  String get assignHomeworkLabel {
    return Intl.message(
      'Назначить домашнюю работу:',
      name: 'assignHomeworkLabel',
      desc: '',
      args: [],
    );
  }

  /// `Время до окончания приема ДЗ:`
  String get homeworkDeadlineTimer {
    return Intl.message(
      'Время до окончания приема ДЗ:',
      name: 'homeworkDeadlineTimer',
      desc: '',
      args: [],
    );
  }

  /// `{grade} "{section}" - класс`
  String classGradeSection(String grade, String section) {
    return Intl.message(
      '$grade "$section" - класс',
      name: 'classGradeSection',
      desc: '',
      args: [grade, section],
    );
  }

  /// `На эту дату нет ваших уроков`
  String get noLessonsForDate {
    return Intl.message(
      'На эту дату нет ваших уроков',
      name: 'noLessonsForDate',
      desc: '',
      args: [],
    );
  }

  /// `Возможно сегодня стоит отдохнуть\nили проверить домашние задания`
  String get noLessonsHint {
    return Intl.message(
      'Возможно сегодня стоит отдохнуть\nили проверить домашние задания',
      name: 'noLessonsHint',
      desc: '',
      args: [],
    );
  }

  /// `Отсутствующие на уроке`
  String get absentFromLesson {
    return Intl.message(
      'Отсутствующие на уроке',
      name: 'absentFromLesson',
      desc: '',
      args: [],
    );
  }

  /// `Все ученики на уроке!`
  String get allStudentsPresent {
    return Intl.message(
      'Все ученики на уроке!',
      name: 'allStudentsPresent',
      desc: '',
      args: [],
    );
  }

  /// `Назад`
  String get back {
    return Intl.message(
      'Назад',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Время собрания:`
  String get meetingTime {
    return Intl.message(
      'Время собрания:',
      name: 'meetingTime',
      desc: '',
      args: [],
    );
  }

  /// `Выставить время`
  String get setTime {
    return Intl.message(
      'Выставить время',
      name: 'setTime',
      desc: '',
      args: [],
    );
  }

  /// `ЧЧ`
  String get hourAbbr {
    return Intl.message(
      'ЧЧ',
      name: 'hourAbbr',
      desc: '',
      args: [],
    );
  }

  /// `ММ`
  String get minuteAbbr {
    return Intl.message(
      'ММ',
      name: 'minuteAbbr',
      desc: '',
      args: [],
    );
  }

  /// `Дата собрания: `
  String get meetingDate {
    return Intl.message(
      'Дата собрания: ',
      name: 'meetingDate',
      desc: '',
      args: [],
    );
  }

  /// `Не выбрана`
  String get notSelected {
    return Intl.message(
      'Не выбрана',
      name: 'notSelected',
      desc: '',
      args: [],
    );
  }

  /// `Текущая дата `
  String get currentDateLabel {
    return Intl.message(
      'Текущая дата ',
      name: 'currentDateLabel',
      desc: '',
      args: [],
    );
  }

  /// `Крайний срок выполнения задания`
  String get taskDeadlineLabel {
    return Intl.message(
      'Крайний срок выполнения задания',
      name: 'taskDeadlineLabel',
      desc: '',
      args: [],
    );
  }

  /// `Выполнить задание до:`
  String get completeTaskBy {
    return Intl.message(
      'Выполнить задание до:',
      name: 'completeTaskBy',
      desc: '',
      args: [],
    );
  }

  /// `Выставить дату`
  String get setDate {
    return Intl.message(
      'Выставить дату',
      name: 'setDate',
      desc: '',
      args: [],
    );
  }

  /// `Родительское собрание`
  String get parentMeeting {
    return Intl.message(
      'Родительское собрание',
      name: 'parentMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Дата проведения`
  String get eventDate {
    return Intl.message(
      'Дата проведения',
      name: 'eventDate',
      desc: '',
      args: [],
    );
  }

  /// `Установите время и дату проведения мероприятия.`
  String get setEventDateTimeHint {
    return Intl.message(
      'Установите время и дату проведения мероприятия.',
      name: 'setEventDateTimeHint',
      desc: '',
      args: [],
    );
  }

  /// `Подтвердить собрание`
  String get confirmMeeting {
    return Intl.message(
      'Подтвердить собрание',
      name: 'confirmMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Новая публикация`
  String get newPublication {
    return Intl.message(
      'Новая публикация',
      name: 'newPublication',
      desc: '',
      args: [],
    );
  }

  /// `Новая история`
  String get newStory {
    return Intl.message(
      'Новая история',
      name: 'newStory',
      desc: '',
      args: [],
    );
  }

  /// `Добавить подпись...`
  String get addCaption {
    return Intl.message(
      'Добавить подпись...',
      name: 'addCaption',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при создании публикации`
  String get createPublicationError {
    return Intl.message(
      'Ошибка при создании публикации',
      name: 'createPublicationError',
      desc: '',
      args: [],
    );
  }

  /// `Поделиться`
  String get share {
    return Intl.message(
      'Поделиться',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Изображение не сохранено`
  String get imageNotSaved {
    return Intl.message(
      'Изображение не сохранено',
      name: 'imageNotSaved',
      desc: '',
      args: [],
    );
  }

  /// `Галерея`
  String get gallery {
    return Intl.message(
      'Галерея',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Далее`
  String get next {
    return Intl.message(
      'Далее',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Выберите из медиа`
  String get selectFromMedia {
    return Intl.message(
      'Выберите из медиа',
      name: 'selectFromMedia',
      desc: '',
      args: [],
    );
  }

  /// `Пароль успешно изменен`
  String get passwordChangedSuccess {
    return Intl.message(
      'Пароль успешно изменен',
      name: 'passwordChangedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Изменение пароля`
  String get changePasswordTitle {
    return Intl.message(
      'Изменение пароля',
      name: 'changePasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ни кому не сообщайте свой пароль !`
  String get doNotSharePassword {
    return Intl.message(
      'Ни кому не сообщайте свой пароль !',
      name: 'doNotSharePassword',
      desc: '',
      args: [],
    );
  }

  /// `Старый пароль:`
  String get oldPassword {
    return Intl.message(
      'Старый пароль:',
      name: 'oldPassword',
      desc: '',
      args: [],
    );
  }

  /// `Новый пароль:`
  String get newPasswordLabel {
    return Intl.message(
      'Новый пароль:',
      name: 'newPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Повторите`
  String get repeatPassword {
    return Intl.message(
      'Повторите',
      name: 'repeatPassword',
      desc: '',
      args: [],
    );
  }

  /// `Новый пароль и повторный пароль не совпадают`
  String get passwordMismatch {
    return Intl.message(
      'Новый пароль и повторный пароль не совпадают',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Старый пароль введён неверно`
  String get oldPasswordIncorrect {
    return Intl.message(
      'Старый пароль введён неверно',
      name: 'oldPasswordIncorrect',
      desc: '',
      args: [],
    );
  }

  /// `Смс с кодом подтверждением отправлено на новый номер`
  String get smsCodeSent {
    return Intl.message(
      'Смс с кодом подтверждением отправлено на новый номер',
      name: 'smsCodeSent',
      desc: '',
      args: [],
    );
  }

  /// `Номер телефона успешно изменен`
  String get phoneChangedSuccess {
    return Intl.message(
      'Номер телефона успешно изменен',
      name: 'phoneChangedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Изменение номера`
  String get changeNumberTitle {
    return Intl.message(
      'Изменение номера',
      name: 'changeNumberTitle',
      desc: '',
      args: [],
    );
  }

  /// `Мы отправим смс с кодом подтверждением на новый номер телефона.`
  String get smsCodeHint {
    return Intl.message(
      'Мы отправим смс с кодом подтверждением на новый номер телефона.',
      name: 'smsCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `Введите новый номер:`
  String get enterNewNumber {
    return Intl.message(
      'Введите новый номер:',
      name: 'enterNewNumber',
      desc: '',
      args: [],
    );
  }

  /// `Введите код из смс:`
  String get enterSmsCode {
    return Intl.message(
      'Введите код из смс:',
      name: 'enterSmsCode',
      desc: '',
      args: [],
    );
  }

  /// `Подтвердить`
  String get confirm {
    return Intl.message(
      'Подтвердить',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Изменить номер`
  String get changeNumberButton {
    return Intl.message(
      'Изменить номер',
      name: 'changeNumberButton',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите корректный номер телефона`
  String get enterValidPhone {
    return Intl.message(
      'Пожалуйста, введите корректный номер телефона',
      name: 'enterValidPhone',
      desc: '',
      args: [],
    );
  }

  /// `Пожалуйста, введите корректный код из смс`
  String get enterValidSmsCode {
    return Intl.message(
      'Пожалуйста, введите корректный код из смс',
      name: 'enterValidSmsCode',
      desc: '',
      args: [],
    );
  }

  /// `Обложка успешно обновлена`
  String get coverUpdatedSuccess {
    return Intl.message(
      'Обложка успешно обновлена',
      name: 'coverUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Обложка обновляется...`
  String get coverUpdating {
    return Intl.message(
      'Обложка обновляется...',
      name: 'coverUpdating',
      desc: '',
      args: [],
    );
  }

  /// `Обложка успешно установлена`
  String get coverSetSuccess {
    return Intl.message(
      'Обложка успешно установлена',
      name: 'coverSetSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Изменить обложку профиля`
  String get changeProfileCover {
    return Intl.message(
      'Изменить обложку профиля',
      name: 'changeProfileCover',
      desc: '',
      args: [],
    );
  }

  /// `Изменить номер телефона`
  String get changePhoneNumber {
    return Intl.message(
      'Изменить номер телефона',
      name: 'changePhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Изменить пароль`
  String get changePasswordButton {
    return Intl.message(
      'Изменить пароль',
      name: 'changePasswordButton',
      desc: '',
      args: [],
    );
  }

  /// `Изменить данные`
  String get changeData {
    return Intl.message(
      'Изменить данные',
      name: 'changeData',
      desc: '',
      args: [],
    );
  }

  /// `Комментарии`
  String get comments {
    return Intl.message(
      'Комментарии',
      name: 'comments',
      desc: '',
      args: [],
    );
  }

  /// `Комментарии не найдено`
  String get commentsNotFound {
    return Intl.message(
      'Комментарии не найдено',
      name: 'commentsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Комментарий успешно добавлен`
  String get commentAddedSuccess {
    return Intl.message(
      'Комментарий успешно добавлен',
      name: 'commentAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Сообщение`
  String get messageHint {
    return Intl.message(
      'Сообщение',
      name: 'messageHint',
      desc: '',
      args: [],
    );
  }

  /// `Показать ещё`
  String get showMore {
    return Intl.message(
      'Показать ещё',
      name: 'showMore',
      desc: '',
      args: [],
    );
  }

  /// `Показать меньше`
  String get showLess {
    return Intl.message(
      'Показать меньше',
      name: 'showLess',
      desc: '',
      args: [],
    );
  }

  /// `года`
  String get yearsExperience {
    return Intl.message(
      'года',
      name: 'yearsExperience',
      desc: '',
      args: [],
    );
  }

  /// `Возраст:`
  String get yearsAge {
    return Intl.message(
      'Возраст:',
      name: 'yearsAge',
      desc: '',
      args: [],
    );
  }

  /// `Загрузить свою\nобложку`
  String get uploadYourCover {
    return Intl.message(
      'Загрузить свою\nобложку',
      name: 'uploadYourCover',
      desc: '',
      args: [],
    );
  }

  /// `Онлайн`
  String get online {
    return Intl.message(
      'Онлайн',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// `Камера`
  String get camera {
    return Intl.message(
      'Камера',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Фото`
  String get photo {
    return Intl.message(
      'Фото',
      name: 'photo',
      desc: '',
      args: [],
    );
  }

  /// `Видео`
  String get video {
    return Intl.message(
      'Видео',
      name: 'video',
      desc: '',
      args: [],
    );
  }

  /// `Файл`
  String get file {
    return Intl.message(
      'Файл',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  /// `Голосовое сообщение`
  String get lastMessageVoice {
    return Intl.message(
      'Голосовое сообщение',
      name: 'lastMessageVoice',
      desc: '',
      args: [],
    );
  }

  /// `Фото`
  String get lastMessagePhoto {
    return Intl.message(
      'Фото',
      name: 'lastMessagePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Видео`
  String get lastMessageVideo {
    return Intl.message(
      'Видео',
      name: 'lastMessageVideo',
      desc: '',
      args: [],
    );
  }

  /// `Файл`
  String get lastMessageFile {
    return Intl.message(
      'Файл',
      name: 'lastMessageFile',
      desc: '',
      args: [],
    );
  }

  /// `Удалить сообщение`
  String get deleteMessage {
    return Intl.message(
      'Удалить сообщение',
      name: 'deleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Вы точно хотите удалить это сообщение?`
  String get deleteMessageConfirm {
    return Intl.message(
      'Вы точно хотите удалить это сообщение?',
      name: 'deleteMessageConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Поиск...`
  String get searchShort {
    return Intl.message(
      'Поиск...',
      name: 'searchShort',
      desc: '',
      args: [],
    );
  }

  /// `СКОРО`
  String get comingSoon {
    return Intl.message(
      'СКОРО',
      name: 'comingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Удалённый пользователь`
  String get deletedUser {
    return Intl.message(
      'Удалённый пользователь',
      name: 'deletedUser',
      desc: '',
      args: [],
    );
  }

  /// `Удалить предмет`
  String get deleteSubjectTitle {
    return Intl.message(
      'Удалить предмет',
      name: 'deleteSubjectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Вы точно хотите удалить этот предмет?`
  String get deleteSubjectConfirm {
    return Intl.message(
      'Вы точно хотите удалить этот предмет?',
      name: 'deleteSubjectConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Сегодня`
  String get today {
    return Intl.message(
      'Сегодня',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Вчера`
  String get yesterday {
    return Intl.message(
      'Вчера',
      name: 'yesterday',
      desc: '',
      args: [],
    );
  }

  /// `Разрешение на микрофон не предоставлено. Включите в настройках.`
  String get microphonePermissionDenied {
    return Intl.message(
      'Разрешение на микрофон не предоставлено. Включите в настройках.',
      name: 'microphonePermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Отменяется...`
  String get cancellingRecording {
    return Intl.message(
      'Отменяется...',
      name: 'cancellingRecording',
      desc: '',
      args: [],
    );
  }

  /// `Проведите для отмены`
  String get slideToCancel {
    return Intl.message(
      'Проведите для отмены',
      name: 'slideToCancel',
      desc: '',
      args: [],
    );
  }

  /// `января`
  String get monthJan {
    return Intl.message(
      'января',
      name: 'monthJan',
      desc: '',
      args: [],
    );
  }

  /// `февраля`
  String get monthFeb {
    return Intl.message(
      'февраля',
      name: 'monthFeb',
      desc: '',
      args: [],
    );
  }

  /// `марта`
  String get monthMar {
    return Intl.message(
      'марта',
      name: 'monthMar',
      desc: '',
      args: [],
    );
  }

  /// `апреля`
  String get monthApr {
    return Intl.message(
      'апреля',
      name: 'monthApr',
      desc: '',
      args: [],
    );
  }

  /// `мая`
  String get monthMay {
    return Intl.message(
      'мая',
      name: 'monthMay',
      desc: '',
      args: [],
    );
  }

  /// `июня`
  String get monthJun {
    return Intl.message(
      'июня',
      name: 'monthJun',
      desc: '',
      args: [],
    );
  }

  /// `июля`
  String get monthJul {
    return Intl.message(
      'июля',
      name: 'monthJul',
      desc: '',
      args: [],
    );
  }

  /// `августа`
  String get monthAug {
    return Intl.message(
      'августа',
      name: 'monthAug',
      desc: '',
      args: [],
    );
  }

  /// `сентября`
  String get monthSep {
    return Intl.message(
      'сентября',
      name: 'monthSep',
      desc: '',
      args: [],
    );
  }

  /// `октября`
  String get monthOct {
    return Intl.message(
      'октября',
      name: 'monthOct',
      desc: '',
      args: [],
    );
  }

  /// `ноября`
  String get monthNov {
    return Intl.message(
      'ноября',
      name: 'monthNov',
      desc: '',
      args: [],
    );
  }

  /// `декабря`
  String get monthDec {
    return Intl.message(
      'декабря',
      name: 'monthDec',
      desc: '',
      args: [],
    );
  }

  /// `Время начала`
  String get startDate {
    return Intl.message(
      'Время начала',
      name: 'startDate',
      desc: '',
      args: [],
    );
  }

  /// `Время окончания`
  String get endDate {
    return Intl.message(
      'Время окончания',
      name: 'endDate',
      desc: '',
      args: [],
    );
  }

  /// `Внимание !`
  String get warning {
    return Intl.message(
      'Внимание !',
      name: 'warning',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'uz'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
