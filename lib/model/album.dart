
/*
* photo_manager 를 통해 가져온 앨범 정보 입니다.
* DropDownButton 에 쓰입니다.
* DropDown 으로 앨범 변경시 id 값을 통해 앨범 정보를 가져 옵니다.
*/
class Album {
  String id;
  String name;

  Album({
    required this.id,
    required this.name,
  });
}