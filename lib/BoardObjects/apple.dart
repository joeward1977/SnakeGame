import 'package:flutter/material.dart';
import 'package:snake/BoardObjects/game_constants.dart';

class Apple extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      width: PIECE_SIZE,
      height: PIECE_SIZE,
      decoration: new BoxDecoration(color: Colors.red, border: new Border.all(color: Colors.white), borderRadius: BorderRadius.circular(PIECE_SIZE)),
    );
  }
}
