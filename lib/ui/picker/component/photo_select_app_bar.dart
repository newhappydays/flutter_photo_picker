import 'package:flutter/material.dart';

import '../../../model/album.dart';

class PhotoSelectAppBar extends StatelessWidget implements PreferredSizeWidget {
  // 현재 선택된 앨범
  Album? currentAlbum;

  // 앨범 목록
  List<Album> albums;

  // 앨범 변경 처리 함수
  ValueChanged<Album?> onChanged;

  // 이미지 선택 완료 함수
  VoidCallback completeImageChoice;

  PhotoSelectAppBar(
      {Key? key,
      required this.currentAlbum,
      required this.albums,
      required this.onChanged,
      required this.completeImageChoice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _appBarTitle(),
      centerTitle: true,
      actions: [
        TextButton(
            onPressed: completeImageChoice,
            child: const Text(
              '확인',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ))
      ],
    );
  }

  Widget _appBarTitle() {
    if (albums.isEmpty || currentAlbum == null) {
      return const SizedBox();
    }

    return DropdownButton(
      value: currentAlbum,
      items: albums
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.name),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 55);
}
