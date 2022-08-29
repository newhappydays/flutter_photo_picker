import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_photo_picker/model/selected_image.dart';
import 'package:photo_manager/photo_manager.dart';

/*
* 선택된 이미지를 보여줄 horizon listView
*/
class HorizonImages extends StatelessWidget {
  // 현재 선택된 이미지 목록
  List<SelectedImage> selectedImages;

  ScrollController controller;

  // 선택 이미지 삭제 함수
  ValueChanged<SelectedImage> deleteTap;

  HorizonImages({
    Key? key,
    required this.selectedImages,
    required this.controller,
    required this.deleteTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: selectedImages
            .map((e) => Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      width: 100,
                      height: 100,
                    ),
                    _horizonImageItem(e),
                    _horizonImageDeleteIcon(e)
                  ],
                ))
            .toList(),
      ),
    );
  }

  /*
  * horizon listView Item 위젯입니다.
  * 카메라로 가져온 이미지는 Image.file 로 구현
  * 선택한 이미지는 AssetEntityImage 로 구현
  */
  Widget _horizonImageItem(SelectedImage image) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 80,
        height: 80,
        child: image.entity != null
            ? AssetEntityImage(
                image.entity!,
                fit: BoxFit.cover,
              )
            : Image.file(
                File(
                  image.file!.path,
                ),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  /*
  * 이미지 삭제 아이콘 위젯 입니다.
  */
  Widget _horizonImageDeleteIcon(SelectedImage image) {
    return Positioned(
      top: 10,
      right: 1,
      child: GestureDetector(
        onTap: () => deleteTap(image),
        child: const Icon(
          Icons.cancel,
          color: Colors.black87,
          size: 25,
        ),
      ),
    );
  }
}
