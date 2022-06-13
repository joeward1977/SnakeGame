import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake/BoardObjects/apple.dart';
import 'package:snake/BoardObjects/failure.dart';
import 'package:snake/BoardObjects/game_constants.dart';
import 'package:snake/BoardObjects/snake_piece.dart';
import 'package:snake/BoardObjects/point.dart';
import 'package:snake/BoardObjects/splash.dart';
import 'package:snake/BoardObjects/victory.dart';

class Board extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BoardState();
}

enum Direction { LEFT, RIGHT, UP, DOWN }

enum GameState { SPLASH, RUNNING, VICTORY, FAILURE }

class _BoardState extends State<Board> {
  var _snakePiecePositions;
  Point _applePosition;
  Timer _timer;
  Direction _direction = Direction.UP;
  var _gameState = GameState.SPLASH;

  @override
  Widget build(BuildContext context) {
    return new Container(
        // Settings of game board
        color: Colors.amber,
        width: BOARD_SIZE,
        height: BOARD_SIZE,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (tapUpDetails) {
            _handleTap(tapUpDetails);
          },
          child: _getBoardChildBasedOnGameState(),
        ));
  }

  Widget _getBoardChildBasedOnGameState() {
    var child;

    switch (_gameState) {
      // Game has not started yet
      case GameState.SPLASH:
        child = Splash();
        break;

      // Game is being played!!
      case GameState.RUNNING:
        List<Positioned> snakePiecesAndApple = [];
        // Loop through the length of snake and add parts of snake to list
        _snakePiecePositions.forEach((curPiece) {
          var piece = Positioned(
            child: SnakePiece(),
            left: curPiece.x * PIECE_SIZE,
            top: curPiece.y * PIECE_SIZE,
          );
          snakePiecesAndApple.add(piece);
        });

        // Add apple to list
        final apple = Positioned(
          child: Apple(),
          left: _applePosition.x * PIECE_SIZE,
          top: _applePosition.y * PIECE_SIZE,
        );
        snakePiecesAndApple.add(apple);

        // Add list of objects to board
        child = Stack(children: snakePiecesAndApple);
        break;

      // Player has won the game
      case GameState.VICTORY:
        _timer.cancel();
        child = Victory();
        break;

      // Player has lost the game
      case GameState.FAILURE:
        _timer.cancel();
        child = Failure();
        break;
    }

    return child;
  }

  // What happens on each iteration (second) of the game
  void _onTimerTick(Timer timer) {
    _move();

    if (_isWallCollision()) {
      _changeGameState(GameState.FAILURE);
      return;
    }

    if (_isAppleCollision()) {
      if (_isBoardFilled()) {
        _changeGameState(GameState.VICTORY);
      } else {
        _generateNewApple();
        _grow();
      }
      return;
    }
  }

  // Methods to move and grow snake (Notice how similar they are)
  void _move() {
    setState(() {
      _snakePiecePositions.insert(0, _getNewHeadPosition());
      _snakePiecePositions.removeLast();
    });
  }

  void _grow() {
    setState(() {
      _snakePiecePositions.insert(0, _getNewHeadPosition());
    });
  }

  // Check for collision into wall or apple by using location of head of snake
  bool _isWallCollision() {
    var currentHeadPos = _snakePiecePositions.first;
    if (currentHeadPos.x < 0 || currentHeadPos.y < 0 || currentHeadPos.x > BOARD_SIZE / PIECE_SIZE || currentHeadPos.y > BOARD_SIZE / PIECE_SIZE) {
      return true;
    }
    return false;
  }

  bool _isAppleCollision() {
    var currentHeadPos = _snakePiecePositions.first;
    if (currentHeadPos.x == _applePosition.x && currentHeadPos.y == _applePosition.y) {
      return true;
    }
    return false;
  }

  // Get number of spaces on board
  // See if it matches numbers of parts of snake
  bool _isBoardFilled() {
    final totalPiecesThatBoardCanFit = (BOARD_SIZE * BOARD_SIZE) / (PIECE_SIZE * PIECE_SIZE);
    if (_snakePiecePositions.length == totalPiecesThatBoardCanFit) {
      return true;
    }

    return false;
  }

  // Depending on the direction, place the new snake head in correct position
  Point _getNewHeadPosition() {
    var newHeadPos;

    switch (_direction) {
      case Direction.LEFT:
        var currentHeadPos = _snakePiecePositions.first;
        newHeadPos = Point(currentHeadPos.x - 1, currentHeadPos.y);
        break;

      case Direction.RIGHT:
        var currentHeadPos = _snakePiecePositions.first;
        newHeadPos = Point(currentHeadPos.x + 1, currentHeadPos.y);
        break;

      case Direction.UP:
        var currentHeadPos = _snakePiecePositions.first;
        newHeadPos = Point(currentHeadPos.x, currentHeadPos.y - 1);
        break;

      case Direction.DOWN:
        var currentHeadPos = _snakePiecePositions.first;
        newHeadPos = Point(currentHeadPos.x, currentHeadPos.y + 1);
        break;
    }

    return newHeadPos;
  }

  // What to do if the screen is touched(tapped)
  // This differs depending on the state of the game
  void _handleTap(TapUpDetails tapUpDetails) {
    switch (_gameState) {
      case GameState.SPLASH:
        _moveFromSplashToRunningState();
        break;
      case GameState.RUNNING:
        _changeDirectionBasedOnTap(tapUpDetails);
        break;
      case GameState.VICTORY:
        _changeGameState(GameState.SPLASH);
        break;
      case GameState.FAILURE:
        _changeGameState(GameState.SPLASH);
        break;
    }
  }

  // Initial startup of running game
  void _moveFromSplashToRunningState() {
    _generateFirstSnakePosition();
    _generateNewApple();
    _direction = Direction.UP;
    _changeGameState(GameState.RUNNING);
    _timer = new Timer.periodic(new Duration(milliseconds: 500), _onTimerTick);
  }

  // Method to change snake's movement based on location of tap
  void _changeDirectionBasedOnTap(TapUpDetails tapUpDetails) {
    // Get local frame/container which holds the game board
    // The find the posotion in this box which has been tapped
    // Then convert this to a grid location
    RenderBox getBox = context.findRenderObject();
    var localPosition = getBox.globalToLocal(tapUpDetails.globalPosition);
    final x = (localPosition.dx / PIECE_SIZE).round();
    final y = (localPosition.dy / PIECE_SIZE).round();

    final currentHeadPos = _snakePiecePositions.first;

    // Depending on the position of the tap relative to the snake's head
    // change the direction the snake is moving
    switch (_direction) {
      case Direction.LEFT:
        if (y < currentHeadPos.y) {
          setState(() {
            _direction = Direction.UP;
          });
          return;
        }

        if (y > currentHeadPos.y) {
          setState(() {
            _direction = Direction.DOWN;
          });
          return;
        }
        break;

      case Direction.RIGHT:
        if (y < currentHeadPos.y) {
          setState(() {
            _direction = Direction.UP;
          });
          return;
        }

        if (y > currentHeadPos.y) {
          setState(() {
            _direction = Direction.DOWN;
          });
          return;
        }
        break;

      case Direction.UP:
        if (x < currentHeadPos.x) {
          setState(() {
            _direction = Direction.LEFT;
          });
          return;
        }

        if (x > currentHeadPos.x) {
          setState(() {
            _direction = Direction.RIGHT;
          });
          return;
        }
        break;

      case Direction.DOWN:
        if (x < currentHeadPos.x) {
          setState(() {
            _direction = Direction.LEFT;
          });
          return;
        }

        if (x > currentHeadPos.x) {
          setState(() {
            _direction = Direction.RIGHT;
          });
          return;
        }
        break;
    }
  }

  // Method to change game state
  void _changeGameState(GameState gameState) {
    setState(() {
      _gameState = gameState;
    });
  }

  // Create snake in center of board vertically
  void _generateFirstSnakePosition() {
    setState(() {
      final midPoint = (BOARD_SIZE / PIECE_SIZE / 2);
      _snakePiecePositions = [
        Point(midPoint, midPoint - 2),
        Point(midPoint, midPoint - 1),
        Point(midPoint, midPoint),
        Point(midPoint, midPoint + 1),
        Point(midPoint, midPoint + 2),
      ];
    });
  }

  // Randomly place a new apple on the board
  void _generateNewApple() {
    setState(() {
      Random rng = Random();
      var min = 0;
      var max = BOARD_SIZE ~/ PIECE_SIZE;
      var nextX = min + rng.nextInt(max - min);
      var nextY = min + rng.nextInt(max - min);

      var newApple = Point(nextX.toDouble(), nextY.toDouble());

      // Check to make sure new apple is not on snake
      if (_snakePiecePositions.contains(newApple)) {
        _generateNewApple();
      } else {
        _applePosition = newApple;
      }
    });
  }
}
