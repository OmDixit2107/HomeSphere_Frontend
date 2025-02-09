import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<List<String>> pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    return pickedFiles?.map((file) => file.path).toList() ?? [];
  }
}
