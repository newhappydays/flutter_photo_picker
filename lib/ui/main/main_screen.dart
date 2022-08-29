import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../model/selected_image.dart';
import '../picker/photo_picker_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // photo_picker_screen.dart 에서 가져온 이미지 목록
  final List<SelectedImage> _selectedImages = [];

  // 이미지 제한 수 (변경 가능)
  final _limitImageCount = 10;

  /*
  * photo_picker_screen.dart 로 이동합니다
  * 이미지를 선택하지 않았다면 images = null
  * 이미지를 선택했다면 List<SelectedImage> 값이 넘어 옵니다.
  * images null check 후 _selectedImages 상태를 갱신합니다.
  */
  void _loadPhotoPicker() async {
    final List<SelectedImage>? images = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPickerScreen(
            currentImageCount: _selectedImages.length,
            limitImageCount: _limitImageCount,
          ),
        ));

    if (images != null) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Picker'),
      ),
      body: _gridPhoto(),
      floatingActionButton: _floatingActionButton(),
    );
  }

  /*
  * photo_picker_screen.dart 에서 가져온 이미지를 뿌리는 GridView 입니다.
  * _selectedImages 를 이용하여 _gridPhotoItem 목록을 만들어 뿌립니다.
  */
  Widget _gridPhoto() {
    return _selectedImages.isNotEmpty
        ? GridView(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3),
      children: _selectedImages.map(_gridPhotoItem).toList(),
    )
        : const Center(
      child: Text('이미지를 선택해주세요.'),
    );
  }

  /*
  * GridView Item 입니다.
  * 카메라로 가져온 이미지 (AssetEntity = null) 는 Image.file 로 구현
  * 이미지 선택으로 가져온 이미지 (XFile = null) 는 AssetEntityImage 로 구현
  * Stack 을 이용해서 이미지 우측 상단에 X 버튼을 넣었습니다.
  * X 버튼을 누르면 이미지 삭제 후 _selectedImages 상태를 갱신합니다.
  */
  Widget _gridPhotoItem(SelectedImage image) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Positioned.fill(
              child: image.entity != null
                  ? AssetEntityImage(
                image.entity!,
                fit: BoxFit.cover,
              )
                  : Image.file(
                File(image.file!.path),
                fit: BoxFit.cover,
              )),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImages.remove(image);
                });
              },
              child: const Icon(
                Icons.cancel_rounded,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }

  /*
  * _loadPhotoPicker 를 실행시키는 플로팅 버튼입니다.
  * _selectedImages.length 가 _limitImageCount 와 같다면 플로팅 버튼은 없어집니다.
  */
  Widget _floatingActionButton() {
    return _selectedImages.length != _limitImageCount
        ? FloatingActionButton(
      onPressed: _loadPhotoPicker,
      child: const Icon(Icons.add),
    )
        : const SizedBox();
  }
}
