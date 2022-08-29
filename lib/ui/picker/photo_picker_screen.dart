import 'package:flutter/material.dart';
import 'package:flutter_photo_picker/model/selected_image.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../model/album.dart';
import 'component/grid_photo.dart';
import 'component/horizon_images.dart';
import 'component/photo_select_app_bar.dart';
import 'component/selectable_count_text.dart';

class PhotoPickerScreen extends StatefulWidget {
  int currentImageCount;
  int limitImageCount;

  PhotoPickerScreen({
    required this.currentImageCount,
    required this.limitImageCount,
    Key? key,
  }) : super(key: key);

  @override
  State<PhotoPickerScreen> createState() => _PhotoPickerScreenState();
}

class _PhotoPickerScreenState extends State<PhotoPickerScreen> {
  // 기기의 모든 이미지 정보
  List<AssetPathEntity>? _paths;

  // 기기의 앨범 목록 - DropDownButton 에 사용됩니다.
  List<Album> _albums = [];

  // 현재 선택된 앨범의 이미지 목록
  late List<AssetEntity> _images;

  // 현재 선택된 앨범의 이미지 목록 페이지
  int _currentPage = 0;

  // 현재 선택된 앨범
  Album? _currentAlbum;

  // 현재 선택된 이미지 목록
  final List<SelectedImage> _selectedImages = [];

  // horizon listView 의 ScrollController
  final ScrollController _controller = ScrollController();

  /*
  * 이미지 파일 접근에 관한 권한을 체크 합니다.
  * 수락하면 앨범 정보를 가져오고 거절하면 안내 다이얼로그를 띄웁니다.
  */
  Future<void> checkPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      await getAlbum();
    } else {
      _permissionDeniedDialog();
    }
  }

  /*
  * 권한을 거절했을 때 띄우는 다이얼로그 입니다.
  * 확인 -> 권한 설정 페이지 이동
  * 취소 -> 화면을 닫습니다.
  */
  void _permissionDeniedDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text('권한 설정'),
            content: const Text('이미지 파일 접근 권한이 필요합니다.\n권한을 수락해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  await PhotoManager.openSetting();
                },
                child: const Text('확인'),
              ),
            ],
          );
        });
  }

  /*
  * 기기의 모든 이미지 정보를 _paths 에 넣습니다.
  * DropDownButton 구현을 위해 _albums 를 만들어서 넣어줍니다.
  * isAll 이 ture 는 '모든 사진' 이라는 앨범명을 붙여줍니다.
  * 최초 선택된 앨범은 '모든 사진 입니다.'
  */
  Future<void> getAlbum() async {
    _paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    _albums = _paths!.map((e) {
      return Album(
        id: e.id,
        name: e.isAll ? '모든 사진' : e.name,
      );
    }).toList();

    await getPhotos(_albums[0], albumChange: true);
  }


  /*
  * 해당 앨범의 이미지를 불러오는 함수이며 두가지 상황에 호출됩니다.
  * 앨범이 변경되었을 때
  * 다음 페이지로 넘어갔을 때
  * 이 두가지 상황은 albumChange 로 구분
  * 앨범 변경은 _currentPage 를 0 으로 , 다음 페이지는 _currentPage++ 해줍니다.
  * '모든 사진' 일 때 첫번째 이미지 칸에는 카메라가 붙어야 하므로 앨범 변경시 _isAllCheck 해줍니다.
  * 페이지 넘김이면 addAll 해주어 _images 상태를 갱신해줍니다.
  */
  Future<void> getPhotos(
    Album album, {
    bool albumChange = false,
  }) async {
    _currentAlbum = album;
    albumChange ? _currentPage = 0 : _currentPage++;

    final getAlbum = _paths!.singleWhere((element) => element.id == album.id);
    final loadImages = await getAlbum.getAssetListPaged(
      page: _currentPage,
      size: 20,
    );

    setState(() {
      if (albumChange) {
        _images = _isAllCheck(loadImages, getAlbum.isAll);
      } else {
        _images.addAll(loadImages);
      }
    });
  }


  /*
  * 변경된 앨범이 '모든 사진' 인지 확인하는 함수입니다.
  * isAll 로 확인하며 '모든 사진' 앨범이라면 첫번째에 dummy 를 넣어주어 리턴합니다.
  */
  List<AssetEntity> _isAllCheck(List<AssetEntity> loadImages, bool isAll) {
    if (isAll) {
      const dummy = AssetEntity(id: 'camera', typeInt: 0, width: 0, height: 0);
      loadImages.insert(0, dummy);
    }
    return loadImages;
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }


  /*
  * 우측 상단 확인 버튼을 눌렀을 때 실행되는 함수입니다.
  * 선택된 이미지가 없다면 alert 을 띄우고
  * 이미지를 선택했다면 _selectedImages 값을 넘겨주고 pop 합니다.
  */
  void _completeImageChoice() {
    if (_selectedImages.isNotEmpty) {
      Navigator.pop(context, _selectedImages);
    } else {
      _imageCheckDialog();
    }
  }

  /*
  * 이미지를 선택하지 않고 '확인' 버튼을 눌렀을 때 alert 입니다.
  */
  void _imageCheckDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('이미지를 선택해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PhotoSelectAppBar(
        currentAlbum: _currentAlbum,
        albums: _albums,
        onChanged: (value) => getPhotos(value!, albumChange: true),
        completeImageChoice: _completeImageChoice,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _horizonImages(),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scroll) {
                      final scrollPixels = scroll.metrics.pixels /
                          scroll.metrics.maxScrollExtent;

                      if (scrollPixels > 0.33) getPhotos(_currentAlbum!);

                      return false;
                    },
                    child: _paths == null
                        ? const Center(child: CircularProgressIndicator())
                        : GridPhoto(
                            images: _images,
                            selectedImages: _selectedImages,
                            onTap: _selectImage,
                            currentImageCount: widget.currentImageCount,
                            limitImageCount: widget.limitImageCount,
                          ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: SelectableCountText(
                countText: '${_selectedImages.length}'
                    ' / '
                    '${widget.limitImageCount - widget.currentImageCount}',
              ),
            )
          ],
        ),
      ),
    );
  }

  /*
  * 선택된 이미지가 추가된 이미지인지 확인하는 함수 입니다.
  */
  bool _addedImageCheck(SelectedImage image, SelectedImage compareImage) {
    return image.entity == compareImage.entity &&
        image.file == compareImage.file;
  }

  /*
  * 이미지를 선택/선택해제 했거나 horizon listView 에서 이미지를 삭제 했을 떄 호출됩니다.
  * 인자로 넘어온 image 가 _selectedImages 에 있는지 확인합니다.
  * 추가된 이미지라면 삭제, 추가된 이미지가 아니라면 추가 후 상태를 갱신합니다.
  * 이미지가 추가되었다면 _controller 를 통해 horizon listView 의 스크롤 위치를 변경합니다.
  */
  void _selectImage(SelectedImage image) {
    final addedImageCheck =
        _selectedImages.any((e) => _addedImageCheck(image, e));

    setState(() {
      if (addedImageCheck) {
        _selectedImages.removeWhere((e) => _addedImageCheck(image, e));
      } else {
        final item = SelectedImage(entity: image.entity, file: image.file);
        _selectedImages.add(item);
      }
    });

    if (!addedImageCheck && _controller.hasClients) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  /*
  * 선택한 이미지를 구현한 horizon listView 입니다.
  */
  Widget _horizonImages() {
    return _selectedImages.isNotEmpty
        ? HorizonImages(
            selectedImages: _selectedImages,
            controller: _controller,
            deleteTap: _selectImage,
          )
        : const SizedBox();
  }
}
