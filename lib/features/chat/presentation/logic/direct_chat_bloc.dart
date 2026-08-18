import 'chat_bloc.dart';

/// PROMPT_OTKLIK_MOBILE.md §7 — ish beruvchi ↔ nomzod (`direct:*`) suhbati.
///
/// Operator suhbati (`support:*`) bilan bir vaqtda ochiq turishi mumkin,
/// shuning uchun alohida bloc nusxasi: ikkalasi ham bitta socket'ni ulashadi va
/// har biri o'z `session_key`iga tegishli eventlarnigina qabul qiladi.
class DirectChatBloc extends ChatBloc {
  DirectChatBloc(super.realtime, super.remote);
}
