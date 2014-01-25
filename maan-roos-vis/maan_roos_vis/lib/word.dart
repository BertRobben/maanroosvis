library word;

import 'dart:convert' show JSON;
import 'dart:async' show Future;
import 'dart:html';

class Word {
  String _word;
  String _imageUrl;
  Word(String word, String imageUrl) {
    _word = word;
    _imageUrl = imageUrl;
  }
  String get imageUrl => _imageUrl;
  String get word => _word;
  
  Word.fromJSON(String jsonString) {
    Map stored = JSON.decode(jsonString);
    _word = stored['word'];
    _imageUrl = stored['image'];
  }
  
  List<String> split() {
    List<String> result = [];
    var i = 0;
    while (i < _word.length) {
      var s = _word.substring(i, i+1);
      if (i < _word.length - 1) {
        var ss = _word.substring(i, i+2);
        if (_belongsTogether(ss)) {
          s = ss;
        }
      }
      result.add(s);
      i = i + s.length;
    }
    return result;
  }
  
  bool _belongsTogether(String s) => 
      ['aa','ee','ie','oo','ui', 'eu', 'oe', 'ij', 'au', 'ou', 'ei', 'uu', 'ui'].contains(s);
  
  static Future<List<Word>> readWordList() {
    var path = 'woordjes.json';
    return HttpRequest.getString(path).then(_parseWordList);
  }

  static List<Word> _parseWordList(String jsonString) {
    List ws = JSON.decode(jsonString);
    return ws.map((Map w) => new Word(w['word'], w['image'])).toList();
  }


}
