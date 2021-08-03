import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String keyboardKey(String designer, String name) {
  return "$designer-$name".toLowerCase();
}

Widget createStyledTextButton(String text, void Function() onPressed) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      textStyle: const TextStyle(fontSize: 15),
    ),
    child: Text(text),
  );
}
