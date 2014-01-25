import 'dart:html';
import 'package:html5_dnd/html5_dnd.dart';
import 'package:maan_roos_vis/word.dart';
import 'dart:math' show Random;
import 'dart:async';

class Basics {

  DraggableGroup dragGroup;
  DropzoneGroup dropGroup;
  ButtonElement nextButton;
  
  void start() {
    dragGroup = new DraggableGroup()
    ..installAll(querySelectorAll('.dragLetter'));

    dropGroup = new DropzoneGroup()
    ..installAll(querySelectorAll('.dropLetter'))
      ..accept.add(dragGroup)
        ..onDrop.listen((DropzoneEvent event) {
          event.dropzone.innerHtml = event.draggable.innerHtml;
          _checkNextButtonState();
        });
    
    nextButton = querySelector('#next');
    WritingGame.newWritingGame().then(_installGame);
  }

  void _checkNextButtonState() {
    nextButton.disabled = !querySelectorAll('.dropLetter').every((TableCellElement e) => e.innerHtml != '.');
  }

  bool _solutionFound(WritingGame game) {
    List<String> chars = game.word.split();    
    return wordRowElement.childNodes.every((TableCellElement e) => 
        e.innerHtml == chars[e.cellIndex]);
  }

  void _installGame(WritingGame game) {
    nextButton.onClick.listen((_) {
      if (_solutionFound(game)) {
        game.nextWord();
        _showGame(game);
      } else {
        List<String> chars = game.word.split();
        wordRowElement.childNodes.forEach((TableCellElement c) {
          if (chars[c.cellIndex] != c.innerHtml) {
            c.innerHtml = '.';
          }
        });
        nextButton.disabled = true;
      }
    });
    _showGame(game);
  }
  
  TableRowElement get wordRowElement => (querySelector('#word') as TableElement).rows.first;
  
  void _showGame(WritingGame game) {
    (querySelector('#image') as ImageElement).src = game.word.imageUrl;
    TableRowElement wordRow = wordRowElement;
    wordRow.children.clear();
    dropGroup.installedElements.clear();
    game.word.split().forEach((_) {
      TableCellElement cell = wordRow.addCell();
      cell.classes.add('dropLetter');
      cell.innerHtml = '.';
      dropGroup.install(cell);
    });
    nextButton.disabled = true;
    ElementList dragLetters = querySelectorAll('.dragLetter');
    Iterator<String> chars = game.getCharacters(dragLetters.toList().length).iterator;
    Iterator<Element> it = dragLetters.iterator;
    while (it.moveNext() && chars.moveNext()) {
      it.current.innerHtml = chars.current;
    }
  }
}

class WritingGame {
  Word _word;
  List<Word> _words;
  final Random _rand = new Random();
  
  static Future<WritingGame> newWritingGame() {
    return Word.readWordList().then((words) => new WritingGame(words));
  }
  
  WritingGame(List<Word> words) {
    _words = words;
    nextWord();
  }
  
  void nextWord() {
    _word = _words[_rand.nextInt(_words.length)];
  }
  
  Word get word => _word;
  
  List<String> getCharacters(int n) {
    Set<String> allChars = new Set<String>();
    _words.forEach((Word w) => allChars.addAll(w.split()));
    var chars = word.split();
    allChars.removeAll(chars);
    while (allChars.length > n - chars.length) {
      allChars.remove(allChars.elementAt(_rand.nextInt(allChars.length)));
    }
    List<String> result = allChars.toList(growable: true);
    result.addAll(chars);
    result.shuffle(_rand);
    return result;
  }
}

void main() {
  var basics = new Basics();
  basics.start();
}