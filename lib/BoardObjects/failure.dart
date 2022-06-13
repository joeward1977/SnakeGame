import 'package:flutter/widgets.dart';
import 'package:snake/BoardObjects/game_constants.dart';

class Failure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      // Screen at the of game
      // You may choose your color and text
      color: const Color(0xFFFFFFFF),
      width: BOARD_SIZE,
      height: BOARD_SIZE,
      padding: const EdgeInsets.all(TEXT_PADDING),
      child: Center(
        child: Text("Game over! Tap to play again!",
            textAlign: TextAlign.center,
            style: TextStyle(color: const Color(0xFFFF0C0C))),
      ),
    );
  }
}
