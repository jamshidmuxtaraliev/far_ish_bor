enum MediaTypeEnum { photo, video, audio }

extension MediaTypeLabel on MediaTypeEnum {
  String get label {
    switch (this) {
      case MediaTypeEnum.photo:
        return 'Фото';
      case MediaTypeEnum.video:
        return 'Видео';
      case MediaTypeEnum.audio:
        return 'Аудио';
    }
  }
}
