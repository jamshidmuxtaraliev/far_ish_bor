import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../enums/media_type_enum.dart';

Future<String?> pickMediaPath(MediaTypeEnum type) async {
  switch (type) {
    case MediaTypeEnum.photo:
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      return picked?.path;

    case MediaTypeEnum.video:
      final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
      return picked?.path;

    case MediaTypeEnum.audio:
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'flac', 'aac', 'ogg', 'alac', 'wma', 'aiff', 'amr', 'pcm'],
        allowMultiple: false,
      );
      return result?.files.single.path;
  }
}
