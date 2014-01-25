library gameContainer;

import 'package:polymer/polymer.dart';
import 'dart:html';

abstract class WordGame {
  void newChallenge(Arbiter arbiter);
}

abstract class Arbiter {
  void attempt(bool successful);
}

@CustomTag('game-container')
class GameContainer extends PolymerElement with Arbiter {

  int _challenges = 0;
  int _score = 0;
  bool _firstGuess;
  PolymerElement _child;

  @observable String score;
  @observable String title;
  
  GameContainer.created() : super.created() {
    print('Creating GameContainer');
    install('click-game');
  }

  void install(String wordGameElementName) {    
    title = wordGameElementName;
    _child = new Element.tag(wordGameElementName);
    $['gamePanel'].children.add(_child);
    start();
  }
  
  void start() {
    _challenges = 0;
    _score = 0;
    _firstGuess = true;
    _show(true);
    install(($['gameSelect'] as SelectElement).selectedOptions[0].value);
    challenge();
  }
  
  void _show(bool inProgress) {
    $['gamePanel'].hidden = !inProgress;
    $['gameSelect'].hidden = inProgress;
    $['scorePanel'].hidden = inProgress;
  }
  
  void challenge() {
    _challenges = _challenges + 1;
    _firstGuess = true;
    (_child as WordGame).newChallenge(this);
  }

  void attempt(bool right) {
    if (right) {
      if (_firstGuess) _score = _score + 1;
      if (_challenges == 10) {
        score = '$_score / $_challenges';
        _show(false);
      } else {
        challenge();
      }
    } else {
      _firstGuess = false;
    }  
  }
  
}