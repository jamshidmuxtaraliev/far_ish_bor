// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(number) => "Ответ ${number}";

  static String m1(grade, section) => "${grade} \"${section}\" - класс";

  static String m2(date) => "Сдать до: ${date}";

  static String m3(score) => "Оценка: ${score}";

  static String m4(date) => "Урок проведен ${date}";

  static String m5(email, password) =>
      "Информация для входа на платформу Аль-Хорезми:\n\nLogin: ${email}\nParol: ${password}";

  static String m6(day) => "Нет расписания на ${day}";

  static String m7(number) => "Вопрос №${number}";

  static String m8(grade, section) =>
      "Расписание ${grade} \"${section}\" класс";

  static String m9(className) => "Ученик - ${className} класс";

  static String m10(grade, section) =>
      "Ученик - ${grade} \"${section}\" - класс";

  static String m11(filePath) =>
      "Вы отправляете этот файл в ответ на задание:\n\n${filePath}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "absence": MessageLookupByLibrary.simpleMessage("Пропуск"),
        "absentFromLesson":
            MessageLookupByLibrary.simpleMessage("Отсутствующие на уроке"),
        "add": MessageLookupByLibrary.simpleMessage("Добавить"),
        "addAnswer": MessageLookupByLibrary.simpleMessage("+ Добавить вариант"),
        "addCaption":
            MessageLookupByLibrary.simpleMessage("Добавить подпись..."),
        "addChild": MessageLookupByLibrary.simpleMessage("Добавить Ребенок"),
        "addClass": MessageLookupByLibrary.simpleMessage("Добавить класс"),
        "addClassError": MessageLookupByLibrary.simpleMessage(
            "Ошибка при добавлении класса"),
        "addMore": MessageLookupByLibrary.simpleMessage("Добавить еше"),
        "addParent": MessageLookupByLibrary.simpleMessage("Добавить родителя"),
        "addPoints": MessageLookupByLibrary.simpleMessage("Добавить"),
        "addProduct": MessageLookupByLibrary.simpleMessage("Добавить товар"),
        "addProductButton":
            MessageLookupByLibrary.simpleMessage("Добавить предмет"),
        "addProductHint": MessageLookupByLibrary.simpleMessage(
            "Добавьте товар для обмена на баллы. Загрузите фото и описание с ценой предмета."),
        "addQuestion": MessageLookupByLibrary.simpleMessage("Добавить вопрос"),
        "addStudent": MessageLookupByLibrary.simpleMessage("Добавить ученика"),
        "addStudentError": MessageLookupByLibrary.simpleMessage(
            "Ошибка при добавлении ученика"),
        "addStudentSuccess":
            MessageLookupByLibrary.simpleMessage("Ученик успешно добавлен"),
        "addStudents":
            MessageLookupByLibrary.simpleMessage("Добавить учеников"),
        "addSubjectButton":
            MessageLookupByLibrary.simpleMessage("Добавить предмет"),
        "addTeacher": MessageLookupByLibrary.simpleMessage("Добавить учителя"),
        "addTeacherError": MessageLookupByLibrary.simpleMessage(
            "Ошибка при добавлении преподавателя"),
        "addTeacherLine": MessageLookupByLibrary.simpleMessage("Учитель"),
        "addTeacherSuccess": MessageLookupByLibrary.simpleMessage(
            "Преподаватель успешно добавлен"),
        "adminRole":
            MessageLookupByLibrary.simpleMessage("Администрация школы"),
        "adminRoleShort": MessageLookupByLibrary.simpleMessage("Администрация"),
        "adminRoleSubtitle":
            MessageLookupByLibrary.simpleMessage("Я управляющий в этой школе."),
        "allContests": MessageLookupByLibrary.simpleMessage("Все конкурсы >"),
        "allCorrect": MessageLookupByLibrary.simpleMessage("Все верно"),
        "allParents": MessageLookupByLibrary.simpleMessage("Все родители:"),
        "allSchedule": MessageLookupByLibrary.simpleMessage("Все расписание"),
        "allStudentsPresent":
            MessageLookupByLibrary.simpleMessage("Все ученики на уроке!"),
        "allSubjectsParenthesis":
            MessageLookupByLibrary.simpleMessage("(все предметы)"),
        "allTeachers": MessageLookupByLibrary.simpleMessage("Все учителя:"),
        "answerAllQuestions": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, ответьте на все вопросы."),
        "answerNumber": m0,
        "answerStatistics":
            MessageLookupByLibrary.simpleMessage("Статистика ответов"),
        "app_theme": MessageLookupByLibrary.simpleMessage("Тема приложения"),
        "assignHomeworkLabel":
            MessageLookupByLibrary.simpleMessage("Назначить домашнюю работу:"),
        "assignRewards": MessageLookupByLibrary.simpleMessage(
            "Установите награду за 1, 2 и 3-е призовые места"),
        "assignSubject":
            MessageLookupByLibrary.simpleMessage("Назначить предмет"),
        "assignTask":
            MessageLookupByLibrary.simpleMessage("Назначение задания"),
        "assignTaskHint": MessageLookupByLibrary.simpleMessage(
            "Здесь отображаются проведенные уроки по которым нужно отправить задание на дом."),
        "attendParentMeeting": MessageLookupByLibrary.simpleMessage(
            "Посещение родительского собрания"),
        "attendanceHint": MessageLookupByLibrary.simpleMessage(
            "Перед началом урока уточните кого нет в классе и после приступайте к уроку. Если ученика нет в классе, то не отмечайте его галочкой."),
        "attendancePercent":
            MessageLookupByLibrary.simpleMessage("Посещаемость, %"),
        "authError": MessageLookupByLibrary.simpleMessage("Ошибка авторизации"),
        "avgAttendance":
            MessageLookupByLibrary.simpleMessage("Средняя посещаемость"),
        "avgScore": MessageLookupByLibrary.simpleMessage("Средний балл"),
        "avgScoreBySubjects":
            MessageLookupByLibrary.simpleMessage("Средний балл по предметам"),
        "avgScoreForWeek": MessageLookupByLibrary.simpleMessage(
            "Среднее значение оценок за неделю"),
        "back": MessageLookupByLibrary.simpleMessage("Назад"),
        "badBehavior": MessageLookupByLibrary.simpleMessage("Плохое поведение"),
        "behavior": MessageLookupByLibrary.simpleMessage("Поведение"),
        "beingReviewed": MessageLookupByLibrary.simpleMessage("Проверяется"),
        "birthDateLabel":
            MessageLookupByLibrary.simpleMessage("Дата рождения:"),
        "camera": MessageLookupByLibrary.simpleMessage("Камера"),
        "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
        "cancellingRecording":
            MessageLookupByLibrary.simpleMessage("Отменяется..."),
        "cannotSetGrade": MessageLookupByLibrary.simpleMessage(
            "Невозможно выставить оценку, так как срок сдачи задания истек или задание не было сдано."),
        "cart": MessageLookupByLibrary.simpleMessage("Корзина"),
        "cartEmpty": MessageLookupByLibrary.simpleMessage("Корзина пуста"),
        "cartItemDetailsHint": MessageLookupByLibrary.simpleMessage(
            "Если у выбранного предмета имеются дополнительные детали: цвет, размер тд. То администрация уточнит их у вас"),
        "changeData": MessageLookupByLibrary.simpleMessage("Изменить данные"),
        "changeNumberButton":
            MessageLookupByLibrary.simpleMessage("Изменить номер"),
        "changeNumberTitle":
            MessageLookupByLibrary.simpleMessage("Изменение номера"),
        "changePasswordButton":
            MessageLookupByLibrary.simpleMessage("Изменить пароль"),
        "changePasswordTitle":
            MessageLookupByLibrary.simpleMessage("Изменение пароля"),
        "changePhoneNumber":
            MessageLookupByLibrary.simpleMessage("Изменить номер телефона"),
        "changePointsHint": MessageLookupByLibrary.simpleMessage(
            "Уточните кол-во баллов которые хотите добавить / забрать."),
        "changePointsTitle":
            MessageLookupByLibrary.simpleMessage("Изменение баллов"),
        "changeProfileCover":
            MessageLookupByLibrary.simpleMessage("Изменить обложку профиля"),
        "chatsUnavailable":
            MessageLookupByLibrary.simpleMessage("Чаты недоступны"),
        "chatsUnavailableHint": MessageLookupByLibrary.simpleMessage(
            "Чтобы начать новую беседу, нажмите кнопку «Отправить сообщение» в профиле пользователя."),
        "checkTask": MessageLookupByLibrary.simpleMessage("Проверка задания"),
        "checkTasks": MessageLookupByLibrary.simpleMessage("Проверка заданий"),
        "checkTasksHint": MessageLookupByLibrary.simpleMessage(
            "Здесь отображаются классы которым вы назначили задания. Для проверки откройте класс и выберите ученика."),
        "checkedStatus": MessageLookupByLibrary.simpleMessage("Проверено"),
        "checkedTasksLast30Days": MessageLookupByLibrary.simpleMessage(
            "Проверенные задания за последние 30 дней"),
        "childLabel": MessageLookupByLibrary.simpleMessage("Ребенок:"),
        "childProgressTitle":
            MessageLookupByLibrary.simpleMessage("Успеваемость\nребенка"),
        "children": MessageLookupByLibrary.simpleMessage("Дети"),
        "classCreated":
            MessageLookupByLibrary.simpleMessage("Класс успешно создан"),
        "classGradeSection": m1,
        "classLabel": MessageLookupByLibrary.simpleMessage("класс"),
        "classLabelColon": MessageLookupByLibrary.simpleMessage("Класс:"),
        "classLetterHint":
            MessageLookupByLibrary.simpleMessage("(А / Б / В / Г)"),
        "classLetterInput": MessageLookupByLibrary.simpleMessage("Буква"),
        "classLetterLabel":
            MessageLookupByLibrary.simpleMessage("Буква класса:"),
        "classLoadError": MessageLookupByLibrary.simpleMessage(
            "Ошибка загрузки данных класса"),
        "classManagement":
            MessageLookupByLibrary.simpleMessage("Классное руководство:"),
        "classNotSelected":
            MessageLookupByLibrary.simpleMessage("Класс не выбран"),
        "classNumberHint": MessageLookupByLibrary.simpleMessage("(1 -11)"),
        "classNumberInput": MessageLookupByLibrary.simpleMessage("Номер"),
        "classNumberLabel":
            MessageLookupByLibrary.simpleMessage("Номер класса:"),
        "classTeacher":
            MessageLookupByLibrary.simpleMessage("Классный руководитель:"),
        "classTeacherHint":
            MessageLookupByLibrary.simpleMessage("руководитель"),
        "classUpdated":
            MessageLookupByLibrary.simpleMessage("Класс успешно обновлён"),
        "classWork": MessageLookupByLibrary.simpleMessage("Работа в классе"),
        "classmatesAvgScore": MessageLookupByLibrary.simpleMessage(
            "Средний балл одноклассников:"),
        "coinBalance": MessageLookupByLibrary.simpleMessage("Баланс монеты"),
        "coinsAddedSuccess":
            MessageLookupByLibrary.simpleMessage("Монеты успешно добавлены"),
        "coinsCanTransferToChild": MessageLookupByLibrary.simpleMessage(
            "Их можно перевести вашему ребенку"),
        "coinsEarned": MessageLookupByLibrary.simpleMessage("Вам начислено:"),
        "coinsSuccessTransferred": MessageLookupByLibrary.simpleMessage(
            "Баллы успешно переданы ребенку"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("СКОРО"),
        "commentAddedSuccess": MessageLookupByLibrary.simpleMessage(
            "Комментарий успешно добавлен"),
        "commentPlaceholder":
            MessageLookupByLibrary.simpleMessage("Комментарий ..."),
        "comments": MessageLookupByLibrary.simpleMessage("Комментарии"),
        "commentsNotFound":
            MessageLookupByLibrary.simpleMessage("Комментарии не найдено"),
        "compareWithClass":
            MessageLookupByLibrary.simpleMessage("Сравнение с классом"),
        "compileSchedule":
            MessageLookupByLibrary.simpleMessage("Составление расписания"),
        "completeTaskBy":
            MessageLookupByLibrary.simpleMessage("Выполнить задание до:"),
        "completedPercent": MessageLookupByLibrary.simpleMessage("Выполнено"),
        "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
        "confirmAction":
            MessageLookupByLibrary.simpleMessage("Подтвердите действие"),
        "confirmConsentError": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, подтвердите согласие на обработку персональных данных"),
        "confirmMeeting":
            MessageLookupByLibrary.simpleMessage("Подтвердить собрание"),
        "confirmMonthPayment": MessageLookupByLibrary.simpleMessage(
            "Вы уверены что обучение за месяц оплачено ?"),
        "confirmOrder":
            MessageLookupByLibrary.simpleMessage("Подтвердить заявку"),
        "confirmRemoveFromClass": MessageLookupByLibrary.simpleMessage(
            "Вы точно хотите удалить из класса:"),
        "confirmYearPayment": MessageLookupByLibrary.simpleMessage(
            "Вы уверены что обучение за год оплачено ?"),
        "confirmation": MessageLookupByLibrary.simpleMessage("Подтверждение"),
        "congratulations":
            MessageLookupByLibrary.simpleMessage("Поздравляем !"),
        "contactNumber":
            MessageLookupByLibrary.simpleMessage("Номер для связи:"),
        "contactStudent":
            MessageLookupByLibrary.simpleMessage("Связаться с учеником"),
        "contestCompleted":
            MessageLookupByLibrary.simpleMessage("Конкурс завершен"),
        "contestCreated":
            MessageLookupByLibrary.simpleMessage("Конкурс успешно создан"),
        "contestDescription":
            MessageLookupByLibrary.simpleMessage("Описание конкурса"),
        "contestName":
            MessageLookupByLibrary.simpleMessage("Название конкурса"),
        "contestParticipation":
            MessageLookupByLibrary.simpleMessage("Участие в конкурсах"),
        "contestSuccessCompleted":
            MessageLookupByLibrary.simpleMessage("Конкурс успешно завершен"),
        "controlWork": MessageLookupByLibrary.simpleMessage("Контрольная"),
        "coverSetSuccess":
            MessageLookupByLibrary.simpleMessage("Обложка успешно установлена"),
        "coverUpdatedSuccess":
            MessageLookupByLibrary.simpleMessage("Обложка успешно обновлена"),
        "coverUpdating":
            MessageLookupByLibrary.simpleMessage("Обложка обновляется..."),
        "create": MessageLookupByLibrary.simpleMessage("Создать"),
        "createClass": MessageLookupByLibrary.simpleMessage("Создать класс"),
        "createContest":
            MessageLookupByLibrary.simpleMessage("Создать конкурс"),
        "createPoll": MessageLookupByLibrary.simpleMessage("Создать опрос"),
        "createPollTitle":
            MessageLookupByLibrary.simpleMessage("Создание опроса"),
        "createPublicationError": MessageLookupByLibrary.simpleMessage(
            "Ошибка при создании публикации"),
        "createSchedule":
            MessageLookupByLibrary.simpleMessage("Создать расписание"),
        "createScheduleTitle":
            MessageLookupByLibrary.simpleMessage("Создание расписания"),
        "currentContests":
            MessageLookupByLibrary.simpleMessage("Текущие конкурсы"),
        "currentDateLabel":
            MessageLookupByLibrary.simpleMessage("Текущая дата "),
        "currentPolls": MessageLookupByLibrary.simpleMessage("Текущие опросы"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("Темная тема"),
        "dataSavedSuccess":
            MessageLookupByLibrary.simpleMessage("Данные успешно сохранены"),
        "dateFormat": MessageLookupByLibrary.simpleMessage("ДД.ММ.ГГГГ"),
        "deadline": MessageLookupByLibrary.simpleMessage("Срок выполнения"),
        "deductPoints":
            MessageLookupByLibrary.simpleMessage("Списать/Добавить баллы"),
        "deduction": MessageLookupByLibrary.simpleMessage("Списание"),
        "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
        "deleteClassConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этот класс? Это действие нельзя будет отменить."),
        "deleteClassTitle":
            MessageLookupByLibrary.simpleMessage("Удалить класс ?"),
        "deleteMessage":
            MessageLookupByLibrary.simpleMessage("Удалить сообщение"),
        "deleteMessageConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы точно хотите удалить это сообщение?"),
        "deleteParentConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этого Родитель? Это действие нельзя будет отменить."),
        "deleteParentTitle":
            MessageLookupByLibrary.simpleMessage("Удалить Родитель ?"),
        "deletePoll": MessageLookupByLibrary.simpleMessage("Удалить опрос"),
        "deletePollConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этот опрос?"),
        "deletePollError":
            MessageLookupByLibrary.simpleMessage("Ошибка при удалении опроса"),
        "deleteProduct":
            MessageLookupByLibrary.simpleMessage("Удалить предмет"),
        "deleteProductConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этого предмет? Это действие нельзя будет отменить."),
        "deleteProductTitle":
            MessageLookupByLibrary.simpleMessage("Удалить предмет ?"),
        "deleteStudentConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этого ученика? Это действие нельзя будет отменить."),
        "deleteStudentError":
            MessageLookupByLibrary.simpleMessage("Ошибка удаления ученика"),
        "deleteStudentTitle":
            MessageLookupByLibrary.simpleMessage("Удалить ученика ?"),
        "deleteSubjectConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы точно хотите удалить этот предмет?"),
        "deleteSubjectTitle":
            MessageLookupByLibrary.simpleMessage("Удалить предмет"),
        "deleteTeacherConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этого преподавателя? Это действие нельзя будет отменить."),
        "deleteTeacherError": MessageLookupByLibrary.simpleMessage(
            "Ошибка удаления преподавателя"),
        "deleteTeacherTitle":
            MessageLookupByLibrary.simpleMessage("Удалить преподавателя ?"),
        "deletedUser":
            MessageLookupByLibrary.simpleMessage("Удалённый пользователь"),
        "descriptionHint": MessageLookupByLibrary.simpleMessage("описание"),
        "descriptionLabel": MessageLookupByLibrary.simpleMessage("Описание:"),
        "determinedAtContestEnd": MessageLookupByLibrary.simpleMessage(
            "Будет определено по итогам конкурса"),
        "diaryAllSubjects":
            MessageLookupByLibrary.simpleMessage("Дневник (все предметы)"),
        "diaryLabel": MessageLookupByLibrary.simpleMessage("Дневник "),
        "doNotSave": MessageLookupByLibrary.simpleMessage("Не сохранять"),
        "doNotSharePassword": MessageLookupByLibrary.simpleMessage(
            "Ни кому не сообщайте свой пароль !"),
        "done": MessageLookupByLibrary.simpleMessage("Готово"),
        "downloadStudentHomeworkHint": MessageLookupByLibrary.simpleMessage(
            "Скачайте домашнее задание ученика и проверьте его. Если задание без ошибок, то можно не загружать исправления."),
        "dueDate": m2,
        "edit": MessageLookupByLibrary.simpleMessage("Изменить"),
        "editButton": MessageLookupByLibrary.simpleMessage("Редактировать"),
        "editClass":
            MessageLookupByLibrary.simpleMessage("Редактировать класс"),
        "editPollTitle":
            MessageLookupByLibrary.simpleMessage("Редактирование опроса"),
        "editSchedule":
            MessageLookupByLibrary.simpleMessage("Изменить расписание"),
        "education": MessageLookupByLibrary.simpleMessage("Образование:"),
        "educationHint": MessageLookupByLibrary.simpleMessage("Образование"),
        "endDate": MessageLookupByLibrary.simpleMessage("Время окончания"),
        "enterAccountData":
            MessageLookupByLibrary.simpleMessage("Введите данные от аккаунта"),
        "enterCoinAmount":
            MessageLookupByLibrary.simpleMessage("Введите количество монет"),
        "enterData": MessageLookupByLibrary.simpleMessage("Введите данные"),
        "enterNewNumber":
            MessageLookupByLibrary.simpleMessage("Введите новый номер:"),
        "enterPersonalData": MessageLookupByLibrary.simpleMessage(
            "Введите персональные данные:"),
        "enterSmsCode":
            MessageLookupByLibrary.simpleMessage("Введите код из смс:"),
        "enterValidHours": MessageLookupByLibrary.simpleMessage(
            "Введите корректное кол-во часов в неделю"),
        "enterValidPhone": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите корректный номер телефона"),
        "enterValidSmsCode": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите корректный код из смс"),
        "error": MessageLookupByLibrary.simpleMessage("Ошибка"),
        "eventDate": MessageLookupByLibrary.simpleMessage("Дата проведения"),
        "everyMonth": MessageLookupByLibrary.simpleMessage("каждого месяца"),
        "excellent": MessageLookupByLibrary.simpleMessage("Отлично"),
        "exchangeOrders":
            MessageLookupByLibrary.simpleMessage("Заявки на обмен"),
        "failedToLoadData":
            MessageLookupByLibrary.simpleMessage("Не удалось загрузить данные"),
        "fatherName": MessageLookupByLibrary.simpleMessage("Отчество"),
        "fetchDataError":
            MessageLookupByLibrary.simpleMessage("Ошибка при получении данных"),
        "file": MessageLookupByLibrary.simpleMessage("Файл"),
        "fileUploading":
            MessageLookupByLibrary.simpleMessage("Загрузка файла..."),
        "fillAllFieldsError": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, заполните все поля"),
        "fillCurrentQuestionFirst": MessageLookupByLibrary.simpleMessage(
            "Перед добавлением нового вопроса заполните все поля текущего вопроса и его ответов"),
        "fillPollFields": MessageLookupByLibrary.simpleMessage(
            "Заполните тему опроса, все вопросы и их варианты ответов"),
        "fillSurvey": MessageLookupByLibrary.simpleMessage("Заполнение опроса"),
        "finish": MessageLookupByLibrary.simpleMessage("Завершить"),
        "finishContestTitle":
            MessageLookupByLibrary.simpleMessage("Завершение конкурса"),
        "finishLesson": MessageLookupByLibrary.simpleMessage("Закончить урок"),
        "finishLessonConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите закончить урок?"),
        "firstName": MessageLookupByLibrary.simpleMessage("Имя"),
        "friShort": MessageLookupByLibrary.simpleMessage("Пт"),
        "friday": MessageLookupByLibrary.simpleMessage("Пятница"),
        "fullNameLabel": MessageLookupByLibrary.simpleMessage("ФИО:"),
        "gallery": MessageLookupByLibrary.simpleMessage("Галерея"),
        "getPollError": MessageLookupByLibrary.simpleMessage(
            "Ошибка при получении данных опроса"),
        "goodBehavior":
            MessageLookupByLibrary.simpleMessage("Хорошее поведение"),
        "gradeBad": MessageLookupByLibrary.simpleMessage("Плохо"),
        "gradeExcellent": MessageLookupByLibrary.simpleMessage("5 (отлично)"),
        "gradeForBehavior":
            MessageLookupByLibrary.simpleMessage("Оценка за поведение"),
        "gradeForBehaviorHint": MessageLookupByLibrary.simpleMessage(
            "Выставляется только отрицательная оценка..."),
        "gradeForLesson":
            MessageLookupByLibrary.simpleMessage("Оценка за урок"),
        "gradeForLessonHint": MessageLookupByLibrary.simpleMessage(
            "Выставьте оценку за урок если ученик ответил..."),
        "gradeGood": MessageLookupByLibrary.simpleMessage("Хорошо"),
        "gradeGoodNum": MessageLookupByLibrary.simpleMessage("4 (хорошо)"),
        "gradeHistory": MessageLookupByLibrary.simpleMessage("История оценок:"),
        "gradeSatisfactory":
            MessageLookupByLibrary.simpleMessage("3 (удовлетворительно)"),
        "gradeScore": m3,
        "gradeSetSuccess":
            MessageLookupByLibrary.simpleMessage("Оценка успешно выставлена"),
        "gradeTask": MessageLookupByLibrary.simpleMessage("Оценка задания"),
        "gradeTaskHint": MessageLookupByLibrary.simpleMessage(
            "Выставьте справедливую оценку за выполнение задания учеником."),
        "gradeUnsatisfactory":
            MessageLookupByLibrary.simpleMessage("2 (неудовлетворительно)"),
        "gradesBySubjects":
            MessageLookupByLibrary.simpleMessage("Оценки по предметам:"),
        "gradesFilter": MessageLookupByLibrary.simpleMessage("Оценки"),
        "gradingTitle":
            MessageLookupByLibrary.simpleMessage("Выставление оценки"),
        "groupRating":
            MessageLookupByLibrary.simpleMessage("Ваш рейтинг в группе"),
        "groupRatingTab":
            MessageLookupByLibrary.simpleMessage("Рейтинг группы"),
        "groups": MessageLookupByLibrary.simpleMessage("Группы"),
        "homework": MessageLookupByLibrary.simpleMessage("Домашняя работа"),
        "homeworkBannerHint": MessageLookupByLibrary.simpleMessage(
            "Здесь вы скачиваете задания учителя и загружаете ответы на них."),
        "homeworkDeadlineTimer": MessageLookupByLibrary.simpleMessage(
            "Время до окончания приема ДЗ:"),
        "homeworkMissed":
            MessageLookupByLibrary.simpleMessage("Невыполнение ДЗ"),
        "homeworkNotUploaded": MessageLookupByLibrary.simpleMessage(
            "Домашнее задание не загружено"),
        "homeworkSubmitted": MessageLookupByLibrary.simpleMessage(
            "Домашнее задание успешно отправлено"),
        "homeworksTasks":
            MessageLookupByLibrary.simpleMessage("Домашние Задания"),
        "hourAbbr": MessageLookupByLibrary.simpleMessage("ЧЧ"),
        "hoursAbbreviation": MessageLookupByLibrary.simpleMessage("ч"),
        "hoursPerWeekField":
            MessageLookupByLibrary.simpleMessage("Кол-во часов в неделю"),
        "hoursPerWeekHint":
            MessageLookupByLibrary.simpleMessage("Кол-во часов"),
        "howToGetCoins":
            MessageLookupByLibrary.simpleMessage("Как получать монеты"),
        "howToLoseCoins":
            MessageLookupByLibrary.simpleMessage("Как потерять монеты"),
        "imageNotSaved":
            MessageLookupByLibrary.simpleMessage("Изображение не сохранено"),
        "itemDelivered":
            MessageLookupByLibrary.simpleMessage("Предмет вручен ученику"),
        "languageRussian": MessageLookupByLibrary.simpleMessage("Русский"),
        "languageUzbek": MessageLookupByLibrary.simpleMessage("O\'zbek tili"),
        "lastGrades": MessageLookupByLibrary.simpleMessage("Последние оценки"),
        "lastMessageFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "lastMessagePhoto": MessageLookupByLibrary.simpleMessage("Фото"),
        "lastMessageVideo": MessageLookupByLibrary.simpleMessage("Видео"),
        "lastMessageVoice":
            MessageLookupByLibrary.simpleMessage("Голосовое сообщение"),
        "lastName": MessageLookupByLibrary.simpleMessage("Фамилия"),
        "leaveCommentHint": MessageLookupByLibrary.simpleMessage(
            "Оставьте соответствующий комментарий ниже."),
        "lessonAbsence": MessageLookupByLibrary.simpleMessage("Пропуск урока"),
        "lessonAlreadyMarked": MessageLookupByLibrary.simpleMessage(
            "Посещение и оценки уже были добавлены для этого урока."),
        "lessonAttendance":
            MessageLookupByLibrary.simpleMessage("Посещаемость урока"),
        "lessonCompleted":
            MessageLookupByLibrary.simpleMessage("Урок успешно завершен"),
        "lessonDate": m4,
        "lessonStarted":
            MessageLookupByLibrary.simpleMessage("Урок успешно начат"),
        "lessonTaskNotAssigned": MessageLookupByLibrary.simpleMessage(
            "Домашнее задание для этого урока не задано"),
        "lessonType": MessageLookupByLibrary.simpleMessage("Урок"),
        "lessonsAttendanceDash": MessageLookupByLibrary.simpleMessage(
            "Средняя\nпосещаемость за сегодня"),
        "lessonsConflict":
            MessageLookupByLibrary.simpleMessage("Уроки пересекаются !"),
        "lessonsConflictDesc1": MessageLookupByLibrary.simpleMessage(
            "Вы не можете установить урок в "),
        "lessonsConflictDesc2":
            MessageLookupByLibrary.simpleMessage(" у класса "),
        "lessonsConflictDesc3": MessageLookupByLibrary.simpleMessage(
            ", так как в это время у учителя "),
        "lessonsConflictDesc4":
            MessageLookupByLibrary.simpleMessage(" урок в "),
        "lessonsConflictMessage": MessageLookupByLibrary.simpleMessage(
            "Вы можете оставить изменение и скорректировать расписание в другом классе что бы не было пересечения уроков."),
        "lessonsHint": MessageLookupByLibrary.simpleMessage(
            "Здесь отображаются уроки которые вы будете проводить на неделю вперед. (расписание)"),
        "lessonsScheduleTitle":
            MessageLookupByLibrary.simpleMessage("Расписание уроков"),
        "light_mode": MessageLookupByLibrary.simpleMessage("Светлая тема"),
        "loading": MessageLookupByLibrary.simpleMessage("Загрузка..."),
        "loadingTeachers":
            MessageLookupByLibrary.simpleMessage("Загрузка учителей..."),
        "loginDataHint": MessageLookupByLibrary.simpleMessage(
            "Сохраните и отправьте данные для входа"),
        "loginDataTitle":
            MessageLookupByLibrary.simpleMessage("Данные для входа"),
        "loginHint": MessageLookupByLibrary.simpleMessage("Логин...."),
        "loginInfoMessage": m5,
        "loginLabel": MessageLookupByLibrary.simpleMessage("Логин"),
        "loginOrEmail": MessageLookupByLibrary.simpleMessage("Логин или почта"),
        "loginToPlatform":
            MessageLookupByLibrary.simpleMessage("Вход на платформу"),
        "meeting": MessageLookupByLibrary.simpleMessage("Собрание"),
        "meetingCompleted":
            MessageLookupByLibrary.simpleMessage("Собрание успешно завершено"),
        "meetingDate": MessageLookupByLibrary.simpleMessage("Дата собрания: "),
        "meetingScheduled":
            MessageLookupByLibrary.simpleMessage("Собрание успешно назначено"),
        "meetingTime": MessageLookupByLibrary.simpleMessage("Время собрания:"),
        "menuCheck": MessageLookupByLibrary.simpleMessage("Проверка"),
        "menuChild": MessageLookupByLibrary.simpleMessage("Ребенок"),
        "menuClasses": MessageLookupByLibrary.simpleMessage("Классы"),
        "menuCoins": MessageLookupByLibrary.simpleMessage("Монеты"),
        "menuCoinsDescription": MessageLookupByLibrary.simpleMessage(
            "Можно потратить во внутреннем магазине"),
        "menuContests": MessageLookupByLibrary.simpleMessage("Конкурсы"),
        "menuDescription": MessageLookupByLibrary.simpleMessage("Описание"),
        "menuLessons": MessageLookupByLibrary.simpleMessage("Уроки"),
        "menuParents": MessageLookupByLibrary.simpleMessage("Родители"),
        "menuPolls": MessageLookupByLibrary.simpleMessage("Опросы"),
        "menuProfile": MessageLookupByLibrary.simpleMessage("Профиль"),
        "menuProgress": MessageLookupByLibrary.simpleMessage("Успеваемость"),
        "menuRating": MessageLookupByLibrary.simpleMessage("Рейтинг"),
        "menuSchedule": MessageLookupByLibrary.simpleMessage("Расписание"),
        "menuSettings": MessageLookupByLibrary.simpleMessage("Настройки"),
        "menuStatistics": MessageLookupByLibrary.simpleMessage("Статистика"),
        "menuStore": MessageLookupByLibrary.simpleMessage("Магазин"),
        "menuStudents": MessageLookupByLibrary.simpleMessage("Ученики"),
        "menuTasks": MessageLookupByLibrary.simpleMessage("Задания"),
        "menuTeachers": MessageLookupByLibrary.simpleMessage("Учителя"),
        "messageHint": MessageLookupByLibrary.simpleMessage("Сообщение"),
        "microphonePermissionDenied": MessageLookupByLibrary.simpleMessage(
            "Разрешение на микрофон не предоставлено. Включите в настройках."),
        "minOnceWeek":
            MessageLookupByLibrary.simpleMessage("Минимум 1 раз в неделю"),
        "minThreeTimesWeek":
            MessageLookupByLibrary.simpleMessage("Минимум 3 раза в неделю"),
        "minuteAbbr": MessageLookupByLibrary.simpleMessage("ММ"),
        "missedParentMeeting": MessageLookupByLibrary.simpleMessage(
            "Не пришли на родительское собрание"),
        "monShort": MessageLookupByLibrary.simpleMessage("Пн"),
        "monday": MessageLookupByLibrary.simpleMessage("Понедельник"),
        "monthApr": MessageLookupByLibrary.simpleMessage("апреля"),
        "monthAug": MessageLookupByLibrary.simpleMessage("августа"),
        "monthDec": MessageLookupByLibrary.simpleMessage("декабря"),
        "monthFeb": MessageLookupByLibrary.simpleMessage("февраля"),
        "monthJan": MessageLookupByLibrary.simpleMessage("января"),
        "monthJul": MessageLookupByLibrary.simpleMessage("июля"),
        "monthJun": MessageLookupByLibrary.simpleMessage("июня"),
        "monthMar": MessageLookupByLibrary.simpleMessage("марта"),
        "monthMay": MessageLookupByLibrary.simpleMessage("мая"),
        "monthNov": MessageLookupByLibrary.simpleMessage("ноября"),
        "monthOct": MessageLookupByLibrary.simpleMessage("октября"),
        "monthPaymentDone":
            MessageLookupByLibrary.simpleMessage("Оплата за месяц внесена"),
        "monthPaymentSuccess": MessageLookupByLibrary.simpleMessage(
            "Оплата за месяц успешно внесена"),
        "monthSep": MessageLookupByLibrary.simpleMessage("сентября"),
        "monthTab": MessageLookupByLibrary.simpleMessage("Месяц"),
        "myTasks": MessageLookupByLibrary.simpleMessage("Мои\nЗадания"),
        "nameHint": MessageLookupByLibrary.simpleMessage("Название"),
        "nameLabel": MessageLookupByLibrary.simpleMessage("Название:"),
        "nameNotEntered":
            MessageLookupByLibrary.simpleMessage("Имя не указано"),
        "newContests": MessageLookupByLibrary.simpleMessage("Новые конкурсы"),
        "newParticipantsMonth":
            MessageLookupByLibrary.simpleMessage("Новых участников за месяц:"),
        "newPasswordLabel":
            MessageLookupByLibrary.simpleMessage("Новый пароль:"),
        "newPublication":
            MessageLookupByLibrary.simpleMessage("Новая публикация"),
        "newStory": MessageLookupByLibrary.simpleMessage("Новая история"),
        "next": MessageLookupByLibrary.simpleMessage("Далее"),
        "no": MessageLookupByLibrary.simpleMessage("Нет"),
        "noContestsAssigned":
            MessageLookupByLibrary.simpleMessage("Конкурсов не назначено"),
        "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
        "noLessonsForDate": MessageLookupByLibrary.simpleMessage(
            "На эту дату нет ваших уроков"),
        "noLessonsHint": MessageLookupByLibrary.simpleMessage(
            "Возможно сегодня стоит отдохнуть\nили проверить домашние задания"),
        "noLessonsToday": MessageLookupByLibrary.simpleMessage(
            "На сегодня нет запланированных уроков."),
        "noMeetingSoon": MessageLookupByLibrary.simpleMessage(
            "Собрание в ближайшее время не запланированы."),
        "noNewTasks": MessageLookupByLibrary.simpleMessage("Нет новых заданий"),
        "noNotificationsYet": MessageLookupByLibrary.simpleMessage(
            "Вы еще не получили никаких уведомлений!"),
        "noOverdueTasks":
            MessageLookupByLibrary.simpleMessage("Нет просроченных заданий"),
        "noPermissionToViewStudent": MessageLookupByLibrary.simpleMessage(
            "Недостаточно прав для просмотра деталей ученика"),
        "noPollsYet": MessageLookupByLibrary.simpleMessage(
            "Пока нет ни одного опроса. Нажмите кнопку ниже, чтобы создать новый опрос."),
        "noProductsInShop": MessageLookupByLibrary.simpleMessage(
            "На данный момент товаров в магазине нет"),
        "noScheduleForDay": m6,
        "noSubjects": MessageLookupByLibrary.simpleMessage("Нет предметов"),
        "noSubmittedTasks":
            MessageLookupByLibrary.simpleMessage("Нет отправленных заданий"),
        "noTransactionsFound":
            MessageLookupByLibrary.simpleMessage("Транзакции не найдены"),
        "notAvailable": MessageLookupByLibrary.simpleMessage("Недоступно"),
        "notEnoughCoins": MessageLookupByLibrary.simpleMessage(
            "У вас недостаточно монет на счету!"),
        "notPaid": MessageLookupByLibrary.simpleMessage("Не оплачено"),
        "notParticipatingInContest": MessageLookupByLibrary.simpleMessage(
            "Ваш класс не учувствует ни в одном конкурсе. Попробуйте поговорить со своим классным руководителем, возможно он его проведет"),
        "notSelected": MessageLookupByLibrary.simpleMessage("Не выбрана"),
        "notSubmittedHomework": MessageLookupByLibrary.simpleMessage(
            "Не отправили домашнюю работу"),
        "oldPassword": MessageLookupByLibrary.simpleMessage("Старый пароль:"),
        "oldPasswordIncorrect": MessageLookupByLibrary.simpleMessage(
            "Старый пароль введён неверно"),
        "onceWeekMonth":
            MessageLookupByLibrary.simpleMessage("1 раз в неделю / месяц"),
        "online": MessageLookupByLibrary.simpleMessage("Онлайн"),
        "orderApprovalMessage": MessageLookupByLibrary.simpleMessage(
            "В ближайшее время вашу заявку одобрят в администрации и отправят заказ"),
        "orderSubmitError":
            MessageLookupByLibrary.simpleMessage("Ошибка при отправке заявки"),
        "orderedItems":
            MessageLookupByLibrary.simpleMessage("Заказанные предметы:"),
        "other_settings":
            MessageLookupByLibrary.simpleMessage("Другие настройки"),
        "overallAttendance":
            MessageLookupByLibrary.simpleMessage("Общая посещаемость уроков:"),
        "paid": MessageLookupByLibrary.simpleMessage("Оплачено"),
        "parentAdded":
            MessageLookupByLibrary.simpleMessage("Добавлен родитель"),
        "parentAddedMessage": MessageLookupByLibrary.simpleMessage(
            "Вы добавили нового родителя !"),
        "parentMeeting":
            MessageLookupByLibrary.simpleMessage("Родительское собрание"),
        "parentRole": MessageLookupByLibrary.simpleMessage("Родитель"),
        "parentRoleSubtitle": MessageLookupByLibrary.simpleMessage(
            "Мои дети учатся в этой школе."),
        "parentsList": MessageLookupByLibrary.simpleMessage("Список родителей"),
        "parentsNotFound":
            MessageLookupByLibrary.simpleMessage("Родители не найдены"),
        "parentsRatingHint": MessageLookupByLibrary.simpleMessage(
            "Ниже представлен рейтинг родителей среди школы."),
        "parentsRatingTitle":
            MessageLookupByLibrary.simpleMessage("Рейтинг родителей"),
        "participants": MessageLookupByLibrary.simpleMessage("Участники"),
        "password": MessageLookupByLibrary.simpleMessage("Пароль"),
        "passwordChangedSuccess":
            MessageLookupByLibrary.simpleMessage("Пароль успешно изменен"),
        "passwordHint": MessageLookupByLibrary.simpleMessage("Пароль..."),
        "passwordMismatch": MessageLookupByLibrary.simpleMessage(
            "Новый пароль и повторный пароль не совпадают"),
        "payOnTime": MessageLookupByLibrary.simpleMessage("Оплата вовремя"),
        "paymentDaySuffix": MessageLookupByLibrary.simpleMessage("число"),
        "paymentReceived":
            MessageLookupByLibrary.simpleMessage("Оплата получена"),
        "paymentSchedule":
            MessageLookupByLibrary.simpleMessage("График платежей:"),
        "pcsUnit": MessageLookupByLibrary.simpleMessage("шт"),
        "pendingConfirmation":
            MessageLookupByLibrary.simpleMessage("Ожидает подтверждения:"),
        "pendingExecution":
            MessageLookupByLibrary.simpleMessage("Ожидает выполнения:"),
        "personalDataConsent": MessageLookupByLibrary.simpleMessage(
            "Согласие на обработку персональных данных"),
        "phoneChangedSuccess": MessageLookupByLibrary.simpleMessage(
            "Номер телефона успешно изменен"),
        "phoneNumber": MessageLookupByLibrary.simpleMessage("Номер телефона"),
        "photo": MessageLookupByLibrary.simpleMessage("Фото"),
        "photoLabel": MessageLookupByLibrary.simpleMessage("Фотография:"),
        "pleaseAddChild": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, добавьте хотя бы одного ребенка"),
        "pleaseAddSubject": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, добавьте хотя бы один предмет"),
        "pleaseAssignRewards": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, назначьте награды за призовые места"),
        "pleaseEnterBirthDate": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите дату рождения"),
        "pleaseEnterClassLetter": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите букву класса"),
        "pleaseEnterContestDesc": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите описание конкурса"),
        "pleaseEnterContestName": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите название конкурса"),
        "pleaseEnterEducation": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите образование"),
        "pleaseEnterFatherName": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите отчество"),
        "pleaseEnterFirstName":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите имя"),
        "pleaseEnterLastName":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите фамилию"),
        "pleaseEnterLogin":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите логин"),
        "pleaseEnterPassword":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите пароль"),
        "pleaseEnterPaymentDay": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите число оплаты"),
        "pleaseEnterPhone": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите Номер телефона"),
        "pleaseEnterProductName": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите название предмета"),
        "pleaseEnterProductPrice": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите цену предмета"),
        "pleaseEnterSubject":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите предмет"),
        "pleaseEnterWorkExp": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите стаж работы"),
        "pleaseRemoveTeacherConflicts": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, уберите конфликты с учителями"),
        "pleaseSelectClass":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, выберите класс"),
        "pleaseSelectClassNumber": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, выберите номер класса"),
        "pleaseSelectClassTeacher": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, выберите классного руководителя"),
        "pleaseSelectContestClass": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, выберите хотя бы один класс для участия в конкурсе"),
        "pleaseSelectFirst": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста выберите первого призера"),
        "pleaseSelectGrade": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, выберите оценку перед выставлением."),
        "pleaseSelectSecond": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста выберите второго призера"),
        "pleaseSelectThird": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста выберите третьего призера"),
        "pleaseSetDeadline": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, установите срок выполнения задания."),
        "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, загрузите файл с заданием."),
        "pleaseUploadProductPhoto": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, загрузите фотографию предмета"),
        "pointsCount": MessageLookupByLibrary.simpleMessage("Кол-во баллов"),
        "pointsDeducted":
            MessageLookupByLibrary.simpleMessage("Баллы успешно списаны"),
        "pointsExchangeOrders":
            MessageLookupByLibrary.simpleMessage("Заявки на обмен баллов"),
        "poll": MessageLookupByLibrary.simpleMessage("Опрос"),
        "pollCompleted":
            MessageLookupByLibrary.simpleMessage("Вы завершили опрос"),
        "pollCreated":
            MessageLookupByLibrary.simpleMessage("Опрос успешно создан"),
        "pollTopic": MessageLookupByLibrary.simpleMessage("Тема опроса"),
        "pollUpdated":
            MessageLookupByLibrary.simpleMessage("Опрос успешно обновлен"),
        "pollsNotFound":
            MessageLookupByLibrary.simpleMessage("Опросов не найдено"),
        "pollsWillAppearSoon": MessageLookupByLibrary.simpleMessage(
            "Ожидайте, скоро опросы точно появятся, и мы обязательно ознакомимся с вашим мнением."),
        "preparingMaterials":
            MessageLookupByLibrary.simpleMessage("Подготавливаем материалы"),
        "priceHint": MessageLookupByLibrary.simpleMessage("Цена"),
        "priceLabel": MessageLookupByLibrary.simpleMessage("Цена:"),
        "prizePlaces": MessageLookupByLibrary.simpleMessage("Призовые места"),
        "productAddError": MessageLookupByLibrary.simpleMessage(
            "Произошла ошибка при добавлении предмета"),
        "productAddSuccess":
            MessageLookupByLibrary.simpleMessage("Предмет успешно добавлен"),
        "productDeleteSuccess":
            MessageLookupByLibrary.simpleMessage("Предмет успешно удален"),
        "publication": MessageLookupByLibrary.simpleMessage("Публикация"),
        "questionHint": MessageLookupByLibrary.simpleMessage("Вопрос"),
        "questionNumber": m7,
        "rankPlace": MessageLookupByLibrary.simpleMessage("место"),
        "ratingTimeframe":
            MessageLookupByLibrary.simpleMessage("Временные рамки рейтинга:"),
        "rejectOrder": MessageLookupByLibrary.simpleMessage("Отклонить заявку"),
        "removeParticipant":
            MessageLookupByLibrary.simpleMessage("Удалить участника"),
        "repeatPassword": MessageLookupByLibrary.simpleMessage("Повторите"),
        "replenishment": MessageLookupByLibrary.simpleMessage("Пополнение"),
        "rewardAmount":
            MessageLookupByLibrary.simpleMessage("Сумма вознаграждения"),
        "rewardTop1": MessageLookupByLibrary.simpleMessage("Награда за ТОП 1"),
        "rewardTop1120":
            MessageLookupByLibrary.simpleMessage("Награда за ТОП 11-20"),
        "rewardTop2": MessageLookupByLibrary.simpleMessage("Награда за ТОП 2"),
        "rewardTop3": MessageLookupByLibrary.simpleMessage("Награда за ТОП 3"),
        "rewardTop45":
            MessageLookupByLibrary.simpleMessage("Награда за ТОП 4-5"),
        "rewardTop610":
            MessageLookupByLibrary.simpleMessage("Награда за ТОП 6-10"),
        "rewardsAndPlaces":
            MessageLookupByLibrary.simpleMessage("Награды и места"),
        "satShort": MessageLookupByLibrary.simpleMessage("Сб"),
        "saturday": MessageLookupByLibrary.simpleMessage("Суббота"),
        "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
        "saveChanges":
            MessageLookupByLibrary.simpleMessage("Сохранить изменения"),
        "saveSchedule":
            MessageLookupByLibrary.simpleMessage("Сохранить расписание"),
        "scheduleMeeting":
            MessageLookupByLibrary.simpleMessage("Назначить собрание"),
        "scheduleSaved": MessageLookupByLibrary.simpleMessage(
            "Расписание успешно сохранено"),
        "scheduleTitle": m8,
        "scheduledMeetings":
            MessageLookupByLibrary.simpleMessage("Назначенные собрания:"),
        "school": MessageLookupByLibrary.simpleMessage("Школа"),
        "schoolRating":
            MessageLookupByLibrary.simpleMessage("Ваш рейтинг в школе"),
        "schoolRatingRewards":
            MessageLookupByLibrary.simpleMessage("Награды рейтинга школы:"),
        "schoolRatingTab":
            MessageLookupByLibrary.simpleMessage("Рейтинг школы"),
        "searchParent":
            MessageLookupByLibrary.simpleMessage("Поиск родители..."),
        "searchShort": MessageLookupByLibrary.simpleMessage("Поиск..."),
        "searchStudent":
            MessageLookupByLibrary.simpleMessage("Поиск ученики..."),
        "searchTeacher":
            MessageLookupByLibrary.simpleMessage("Поиск учителя..."),
        "select": MessageLookupByLibrary.simpleMessage("Выбрать"),
        "selectContestClassHint": MessageLookupByLibrary.simpleMessage(
            "Выберите класс в котором будет проводиться конкурс"),
        "selectDate": MessageLookupByLibrary.simpleMessage("Выбор даты"),
        "selectFirstPlace":
            MessageLookupByLibrary.simpleMessage("Выбор первого места"),
        "selectFromMedia":
            MessageLookupByLibrary.simpleMessage("Выберите из медиа"),
        "selectLanguageDescription": MessageLookupByLibrary.simpleMessage(
            "Далее приложение будет работать только на этом языке."),
        "selectLanguageTitle":
            MessageLookupByLibrary.simpleMessage("Выберите язык приложения"),
        "selectParallel":
            MessageLookupByLibrary.simpleMessage("Выберите параллель:"),
        "selectPrizeWinners": MessageLookupByLibrary.simpleMessage(
            "Выберите учеников занявших 1, 2 и 3 места."),
        "selectRoleDescription": MessageLookupByLibrary.simpleMessage(
            "Ученик, учитель или администрация школы."),
        "selectRoleTitle":
            MessageLookupByLibrary.simpleMessage("Выберите свою роль"),
        "selectRoleWarning":
            MessageLookupByLibrary.simpleMessage("Выбери роль!"),
        "selectStudent": MessageLookupByLibrary.simpleMessage("Выбор ученика"),
        "selectStudentHint": MessageLookupByLibrary.simpleMessage(
            "Выберите ученика, скачайте его задание и проверьте. Если обнаружите ошибки то загрузите файл с исправлениями и поставьте соответствующую оценку."),
        "selectSubjectAndTeacherError": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, выберите предмет и учителя"),
        "selectTime": MessageLookupByLibrary.simpleMessage("Выбор времени"),
        "selectedButton": MessageLookupByLibrary.simpleMessage("Выбрал"),
        "sendPushNotification":
            MessageLookupByLibrary.simpleMessage("Отправить пуш-уведомление"),
        "sendToWinner":
            MessageLookupByLibrary.simpleMessage("Отправить победителю"),
        "setDate": MessageLookupByLibrary.simpleMessage("Выставить дату"),
        "setDeadlineHint": MessageLookupByLibrary.simpleMessage(
            "Установите время выполнения задания."),
        "setEventDateTimeHint": MessageLookupByLibrary.simpleMessage(
            "Установите время и дату проведения мероприятия."),
        "setGrade": MessageLookupByLibrary.simpleMessage("Выставить оценку"),
        "setTime": MessageLookupByLibrary.simpleMessage("Выставить время"),
        "share": MessageLookupByLibrary.simpleMessage("Поделиться"),
        "shortDescription":
            MessageLookupByLibrary.simpleMessage("Краткое описание:"),
        "showLess": MessageLookupByLibrary.simpleMessage("Показать меньше"),
        "showMore": MessageLookupByLibrary.simpleMessage("Показать ещё"),
        "signInButton": MessageLookupByLibrary.simpleMessage("Войти"),
        "signInDescription": MessageLookupByLibrary.simpleMessage(
            "Введите логин и пароль который вам выдали"),
        "signInTitle":
            MessageLookupByLibrary.simpleMessage("Войдите в свой аккаунт"),
        "slideToCancel":
            MessageLookupByLibrary.simpleMessage("Проведите для отмены"),
        "smsCodeHint": MessageLookupByLibrary.simpleMessage(
            "Мы отправим смс с кодом подтверждением на новый номер телефона."),
        "smsCodeSent": MessageLookupByLibrary.simpleMessage(
            "Смс с кодом подтверждением отправлено на новый номер"),
        "startContest": MessageLookupByLibrary.simpleMessage("Начать конкурс"),
        "startDate": MessageLookupByLibrary.simpleMessage("Время начала"),
        "startLesson": MessageLookupByLibrary.simpleMessage("Начать урок"),
        "startMeeting": MessageLookupByLibrary.simpleMessage("Начать собрание"),
        "story": MessageLookupByLibrary.simpleMessage("История"),
        "studentAdded": MessageLookupByLibrary.simpleMessage("Добавлен ученик"),
        "studentAddedMessage": MessageLookupByLibrary.simpleMessage(
            "Вы добавили нового ученика !"),
        "studentClass": m9,
        "studentClassGradeSection": m10,
        "studentDeleteSuccess":
            MessageLookupByLibrary.simpleMessage("Ученик успешно удален"),
        "studentFile": MessageLookupByLibrary.simpleMessage("Файл ученика"),
        "studentListHeader":
            MessageLookupByLibrary.simpleMessage("№   ФИО ученика"),
        "studentRole": MessageLookupByLibrary.simpleMessage("Ученик"),
        "studentRoleSubtitle":
            MessageLookupByLibrary.simpleMessage("Я учусь в этой школе."),
        "studentsLabel": MessageLookupByLibrary.simpleMessage("Учеников"),
        "studentsNotFound":
            MessageLookupByLibrary.simpleMessage("Ученики не найдены"),
        "studentsParentsRatingHint": MessageLookupByLibrary.simpleMessage(
            "Ниже представлен рейтинг учеников и родителей"),
        "studentsRatingHint": MessageLookupByLibrary.simpleMessage(
            "Ниже представлен рейтинг учеников среди групп и школы в целом."),
        "studentsRatingTitle":
            MessageLookupByLibrary.simpleMessage("Рейтинг учеников"),
        "studentsSection": MessageLookupByLibrary.simpleMessage("Ученики:"),
        "studentsWithoutClass": MessageLookupByLibrary.simpleMessage(
            "Ученики без назначенного класса"),
        "subjectAttendanceLabel": MessageLookupByLibrary.simpleMessage(
            "Предметная посещаемость уроков:"),
        "subjectGrades":
            MessageLookupByLibrary.simpleMessage("Оценки по предметам"),
        "subjectHint": MessageLookupByLibrary.simpleMessage("Алгебра"),
        "subjectLabel": MessageLookupByLibrary.simpleMessage("Предмет:"),
        "subjectNameField":
            MessageLookupByLibrary.simpleMessage("Наименование предмета"),
        "subjectNameHint": MessageLookupByLibrary.simpleMessage("Наименование"),
        "subjectNotSpecified":
            MessageLookupByLibrary.simpleMessage("Предмет не указан"),
        "subjectsSection": MessageLookupByLibrary.simpleMessage("Предметы:"),
        "submitAnswer": MessageLookupByLibrary.simpleMessage("Отправить ответ"),
        "submitFileConfirmation": m11,
        "submitOrder": MessageLookupByLibrary.simpleMessage("Оставить заявку"),
        "submitTask": MessageLookupByLibrary.simpleMessage("Отправить задание"),
        "submittedHomework":
            MessageLookupByLibrary.simpleMessage("Отправили домашнюю работу"),
        "successExchanged": MessageLookupByLibrary.simpleMessage(
            "Вы успешно обменяли баллы на:"),
        "supportedFileFormats": MessageLookupByLibrary.simpleMessage(
            "Загрузить можно файлы: PDF, DOCX, JPG"),
        "tabNew": MessageLookupByLibrary.simpleMessage("Новые"),
        "tabOverdue": MessageLookupByLibrary.simpleMessage("Просрочил"),
        "tabSubmitted": MessageLookupByLibrary.simpleMessage("Сдал"),
        "takePoints": MessageLookupByLibrary.simpleMessage("Забрать"),
        "tapToSelect":
            MessageLookupByLibrary.simpleMessage("Нажмите для выбора"),
        "taskDeadlineLabel": MessageLookupByLibrary.simpleMessage(
            "Крайний срок выполнения задания"),
        "taskSubmitError": MessageLookupByLibrary.simpleMessage(
            "Ошибка при отправке задания."),
        "taskSubmitSuccess":
            MessageLookupByLibrary.simpleMessage("Задание успешно отправлено."),
        "teacherAdded":
            MessageLookupByLibrary.simpleMessage("Добавлен учитель"),
        "teacherAddedMessage": MessageLookupByLibrary.simpleMessage(
            "Вы добавили нового учителя !"),
        "teacherDeleteSuccess": MessageLookupByLibrary.simpleMessage(
            "Преподаватель успешно удален"),
        "teacherNotSelected":
            MessageLookupByLibrary.simpleMessage("Учитель не выбран"),
        "teacherRole": MessageLookupByLibrary.simpleMessage("Учитель"),
        "teacherRoleSubtitle": MessageLookupByLibrary.simpleMessage(
            "Я преподаватель в этой школе."),
        "teachersLabel": MessageLookupByLibrary.simpleMessage("Учителей"),
        "teachersNotFound":
            MessageLookupByLibrary.simpleMessage("Учителя не найдены"),
        "test": MessageLookupByLibrary.simpleMessage("Тест"),
        "testGrades": MessageLookupByLibrary.simpleMessage(
            "Оценки за контрольные / тесты"),
        "thuShort": MessageLookupByLibrary.simpleMessage("Чт"),
        "thursday": MessageLookupByLibrary.simpleMessage("Четверг"),
        "today": MessageLookupByLibrary.simpleMessage("Сегодня"),
        "todaySchedule":
            MessageLookupByLibrary.simpleMessage("Расписание на сегодня"),
        "topThreeWeek":
            MessageLookupByLibrary.simpleMessage("Попадание в топ-3 недели"),
        "totalAvgScore":
            MessageLookupByLibrary.simpleMessage("Общий средний балл"),
        "totalParticipants":
            MessageLookupByLibrary.simpleMessage("Участников всего:"),
        "transactionHistory":
            MessageLookupByLibrary.simpleMessage("История транзакций"),
        "transferAmountInputHint":
            MessageLookupByLibrary.simpleMessage("Введите количество монет"),
        "transferButton": MessageLookupByLibrary.simpleMessage("Передать"),
        "transferCoinError":
            MessageLookupByLibrary.simpleMessage("Ошибка передачи баллов"),
        "transferPoints":
            MessageLookupByLibrary.simpleMessage("Передать баллы"),
        "transferPointsCount":
            MessageLookupByLibrary.simpleMessage("Кол-во передаваемых баллов"),
        "transferPointsHint": MessageLookupByLibrary.simpleMessage(
            "Уточните кол-во баллов которые хотите передать."),
        "transferPointsTitle":
            MessageLookupByLibrary.simpleMessage("Передача баллов"),
        "tueShort": MessageLookupByLibrary.simpleMessage("Вт"),
        "tuesday": MessageLookupByLibrary.simpleMessage("Вторник"),
        "tuitionDayHint": MessageLookupByLibrary.simpleMessage("Число оплаты"),
        "tuitionDayLabel":
            MessageLookupByLibrary.simpleMessage("Число оплаты за обучение:"),
        "tuitionPayment":
            MessageLookupByLibrary.simpleMessage("Оплата обучения"),
        "understood": MessageLookupByLibrary.simpleMessage("Понятно"),
        "upload": MessageLookupByLibrary.simpleMessage("Загрузить"),
        "uploadErrors": MessageLookupByLibrary.simpleMessage("Загрузка ошибок"),
        "uploadErrorsHint": MessageLookupByLibrary.simpleMessage(
            "Если задание без ошибок, то можно не загружать файл с исправления."),
        "uploadFile": MessageLookupByLibrary.simpleMessage("Загрузить файл"),
        "uploadHomeworkHint": MessageLookupByLibrary.simpleMessage(
            "Загрузите файл с домашним заданием. Поддерживается формат:\nJPG / PDF / DOCS"),
        "uploadItem":
            MessageLookupByLibrary.simpleMessage("Загрузить\nпредмет"),
        "uploadYourCover":
            MessageLookupByLibrary.simpleMessage("Загрузить свою\nобложку"),
        "variable": MessageLookupByLibrary.simpleMessage("Вариативно"),
        "video": MessageLookupByLibrary.simpleMessage("Видео"),
        "viewChildProgress": MessageLookupByLibrary.simpleMessage(
            "Просмотр успеваемости ребёнка"),
        "warning": MessageLookupByLibrary.simpleMessage("Внимание !"),
        "wedShort": MessageLookupByLibrary.simpleMessage("Ср"),
        "wednesday": MessageLookupByLibrary.simpleMessage("Среда"),
        "weekTab": MessageLookupByLibrary.simpleMessage("Неделя"),
        "workExperience":
            MessageLookupByLibrary.simpleMessage("Стаж работы (в годах):"),
        "workExperienceLabel":
            MessageLookupByLibrary.simpleMessage("Опыт работы:"),
        "workExperienceShort":
            MessageLookupByLibrary.simpleMessage("Стаж работы:"),
        "yearPaymentDone":
            MessageLookupByLibrary.simpleMessage("Оплата за год внесена"),
        "yearPaymentSuccess": MessageLookupByLibrary.simpleMessage(
            "Оплата за год успешно внесена"),
        "yearSuffix": MessageLookupByLibrary.simpleMessage("год"),
        "yearTab": MessageLookupByLibrary.simpleMessage("Год"),
        "yearsAge": MessageLookupByLibrary.simpleMessage("Возраст:"),
        "yearsExperience": MessageLookupByLibrary.simpleMessage("года"),
        "yes": MessageLookupByLibrary.simpleMessage("Да"),
        "yesFinish": MessageLookupByLibrary.simpleMessage("Да, закончить"),
        "yesSubmit": MessageLookupByLibrary.simpleMessage("Да, отправить"),
        "yesterday": MessageLookupByLibrary.simpleMessage("Вчера"),
        "yourAvgScoreFor":
            MessageLookupByLibrary.simpleMessage("Ваш средний балл за:"),
        "yourAvgScoreForWeek": MessageLookupByLibrary.simpleMessage(
            "Среднее значение ваших оценок за неделю, месяц или год"),
        "yourBalance": MessageLookupByLibrary.simpleMessage("Ваш баланс:"),
        "yourRating": MessageLookupByLibrary.simpleMessage("Ваш рейтинг:"),
        "yourTeachers": MessageLookupByLibrary.simpleMessage("Ваши учителя:")
      };
}
