import 'package:flutter/material.dart';
import 'package:snake/BoardObjects/game_constants.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      // This is the beginning screen (slapsh screen)
      color: Colors.white70,
      width: BOARD_SIZE,
      height: BOARD_SIZE,
      padding: const EdgeInsets.all(TEXT_PADDING),
      child: Center(
        child: Text("Tap to Begin", textAlign: TextAlign.center, style: TextStyle(color: Colors.green[700])),
      ),
    );
  }
}
