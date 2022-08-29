import 'package:flutter/material.dart';

/*
* 선택 가능한 이미지 갯수 위젯입니다.
*/
class SelectableCountText extends StatelessWidget {
  String countText;
  SelectableCountText({Key? key, required this.countText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Text(
        countText,
        style: const TextStyle(color: Colors.white, fontSize: 20.0),
      ),
    );
  }
}
