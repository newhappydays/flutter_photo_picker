import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../model/selected_image.dart';

class GridPhoto extends StatefulWidget {
  // 앨범의 이미지 목록
  List<AssetEntity> images;

  // 선택된 이미지 목록
  List<SelectedImage> selectedImages;

  // 이미지 선택 처리
  ValueChanged<SelectedImage> onTap;

  // main_screen.dart 의 현재 이미지 갯수
  int currentImageCount;

  // 이미지 제한 숫자
  int limitImageCount;

  GridPhoto({
    required this.images,
    required this.selectedImages,
    required this.onTap,
    required this.currentImageCount,
    required this.limitImageCount,
    Key? key,
  }) : super(key: key);

  @override
  State<GridPhoto> createState() => _GridPhotoState();
}

class _GridPhotoState extends State<GridPhoto> {
  final _picker = ImagePicker();

  /*
  * 이미지를 선택 했을 때 제한 숫자를 넘었는지 확인하는 함수입니다.
  * 제한에 걸렸다면 스낵바 노출
  * 제한에 걸리지 않았다면 AssetEntity null check 합니다
  * null 이라면 카메라 실행 , 아니라면 이미지 선택 처리
  */
  void _limitImageCountCheck(AssetEntity? e) {
    final imageCount = widget.currentImageCount + widget.selectedImages.length;
    if (imageCount != widget.limitImageCount) {

      e != null ? _selectImage(e) : _loadCamera();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지는 ${widget.limitImageCount - widget.currentImageCount}장 까지 선택할 수 있습니다.'),
        ),
      );
    }
  }

  /*
  * image_picker 의 카메라 실행
  * 카메라로 이미지를 가져왔다면 선택 처리 (이미지 추가)
  */
  void _loadCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      final item = SelectedImage(entity: null, file: file);
      widget.onTap(item);
    }
  }

  /*
  * 이미 선택된 이미지인지 확인하는 함수입니다.
  */
  bool _selectedImageCheck(AssetEntity e) {
    return widget.selectedImages.any((element) => element.entity == e);
  }

  /*
  * 이미지 선택 처리 함수입니다.
  */
  void _selectImage(AssetEntity e) {
    final item = SelectedImage(entity: e, file: null);
    widget.onTap(item);
  }

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      children: widget.images.map((e) {
        if (e.id == 'camera') {
          return _cameraButton();
        } else {
          return _gridPhotoItem(e);
        }
      }).toList(),
    );
  }

  /*
  * 카메라 버튼 위젯입니다.
  * _limitImageCountCheck 으로 제한 숫자 확인 후 카메라를 실행합니다.
  */
  Widget _cameraButton() {
    return GestureDetector(
      onTap: () => _limitImageCountCheck(null),
      child: Container(
        color: Colors.black,
        child: const Icon(
          CupertinoIcons.camera,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }

  /*
  * GridView Item 입니다.
  * 클릭 시 selectedImage 에 포함되어있는지 확인 합니다
  * 포함 되어 있다면 onTap 을 통해 선택해제 처리 합니다.
  * 포함 되어 있지 않다면 _limitImageCountCheck 로 이미지 갯수 체크 후 선택처리 합니다.
  */
  Widget _gridPhotoItem(AssetEntity e) {
    return GestureDetector(
      onTap: () {
        if (_selectedImageCheck(e)) {
          _selectImage(e);
        } else {
          _limitImageCountCheck(e);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: AssetEntityImage(
                e,
                isOriginal: false,
                fit: BoxFit.cover,
              ),
            ),
            _dimContainer(e),
            _selectNumberContainer(e)
          ],
        ),
      ),
    );
  }

  /*
  * 이미지를 dim 처리하는 위젯입니다.
  * 현재 이미지가 selectedImages 에 포함되어있다면 dim 처리 합니다.
  */
  Widget _dimContainer(AssetEntity e) {
    final isSelected =
        widget.selectedImages.any((element) => element.entity == e);
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.black38 : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.lightBlue : Colors.transparent,
            width: 5,
          ),
        ),
      ),
    );
  }

  /*
  * 선택된 이미지 순번을 표현하는 위젯입니다.
  */
  Widget _selectNumberContainer(AssetEntity e) {
    final num =
        widget.selectedImages.indexWhere((element) => element.entity == e) + 1;
    return Positioned(
        right: 10,
        top: 10,
        child: num != 0
            ? Container(
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$num',
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : const SizedBox());
  }
}
