import 'dart:html';
import 'dart:math' show Random;
import 'dart:async' show Future;
import 'package:maan_roos_vis/word.dart';

Element wordElement;
List<Word> words;
List<ImageController> imageControllers;
Game currentGame;

void main() {
  List<ImageElement> imageElements = [ querySelector('#image1'), querySelector('#image2'), querySelector('#image3') ];
  imageControllers = imageElements.map((ImageElement ie) => new ImageController(ie)).toList();
  wordElement = querySelector('#word');
  querySelector('#newGame').onClick.listen((e) => startNewGame());
  Word.readWordList().then((ws) {
    words = ws; 
    startNewGame(); 
  });
}

void startNewGame() {
  currentGame = new Game();
  currentGame.challenge();
  querySelector('#gamePanel').hidden = false;
  querySelector('#scoreLine').hidden = true;
}

void showScore(int score, int challenges) {
  querySelector('#gamePanel').hidden = true;
  querySelector('#scoreLine').hidden = false;
  querySelector('#score').text = '$score / $challenges';
}

class Game {
  int _challenges = 0;
  int _score = 0;
  bool _firstGuess;
  Random _r = new Random();

  void challenge() {
    imageControllers.forEach((ImageController ic) => ic.word = words[_r.nextInt(words.length)]);
    wordElement.text = imageControllers[_r.nextInt(imageControllers.length)].word.word;
    _challenges = _challenges + 1;
    _firstGuess = true;
  }

  void guess(bool right) {
    if (right) {
      if (_firstGuess) _score = _score + 1;
      if (_challenges == 10) {
        showScore(_score, _challenges);
      } else {
        challenge();
      }
    } else {
      _firstGuess = false;
    }  
  }

}


class ImageController {
  ImageElement _image;
  Word _word;
  
  ImageController(ImageElement image) {
    _image = image;
    _image.onClick.listen((evt) => click());
  }
  
  void click() {
    currentGame.guess(word.word == wordElement.text);
  }

  Word get word => _word;
  
  void set word(Word word) {
    _word = word;
    _image.src = word.imageUrl;
  }
}