import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';


/*
* grid_photo.dar 의 GridView 에서 이미지를 선택하거나 카메라로 촬영했을 때 가져온 정보입니다.
* 화면 상단 horizon listView 에 쓰입니다.
* 이 프로젝트에서는 main_screen.dart 에서 GridView 를 띄워줄 때 쓰입니다.
* GridView 에서 이미지를 선택했다면 file 은 null 이고
* 카메라 촬영을 통해 이미지를 가져왔다면 AssetEntity 는 null 입니다.
*
*/
class SelectedImage {
  AssetEntity? entity;
  XFile? file;

  SelectedImage({
    required this.entity,
    required this.file,
  });
}
