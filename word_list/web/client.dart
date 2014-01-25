// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html';


class Client {
  static const Duration RECONNECT_DELAY = const Duration(milliseconds: 500);

  bool connectPending = false;
  WebSocket webSocket;
  final DivElement log = new DivElement();
  DivElement statusElement = querySelector('#status');
  DivElement resultsElement = querySelector('#results');

  Client() {
    querySelector('#saveButton').onClick.listen((e) => save());
    connect();
  }

  void save() {
    var data = resultsElement.children.
        where((Element div) => !div.hidden).
        map((Element div) {
          return { 'word': div.children[0].innerHtml, 
            'url' : (div.children[1] as ImageElement).src };
      
    }).toList();
    var request = { 'request': 'save', 'data': data };
    webSocket.send(JSON.encode(request));    
  }
  
  Future readWordList() {
    var path = 'woordjes.json';
    return HttpRequest.getString(path)
        .then(_parseWordList);
  }

  void _parseWordList(String jsonString) {
    List ws = JSON.decode(jsonString);
    searchImages(ws.
        where((Map w) => !w.containsKey('url')).
        map((Map w) => w['word']).toList());
  }

  void searchImages(List<String> words) {
    words.forEach((String w) {
      var request = {
                   'request': 'search',
                   'input': w
                   };
      webSocket.send(JSON.encode(request));
    });
  }
  
  void connect() {
    connectPending = false;
    webSocket = new WebSocket('ws://${Uri.base.host}:${Uri.base.port}/ws');
    webSocket.onOpen.first.then((_) {
      onConnected();
      webSocket.onClose.first.then((_) {
        print("Connection disconnected to ${webSocket.url}");
        onDisconnected();
      });
    });
    webSocket.onError.first.then((_) {
      print("Failed to connect to ${webSocket.url}. "
            "Please run bin/server.dart and try again.");
      onDisconnected();
    });
  }

  void onConnected() {
    setStatus('');
    readWordList();
    webSocket.onMessage.listen((e) {
      onMessage(e.data);
    });
  }

  void onDisconnected() {
    if (connectPending) return;
    connectPending = true;
    setStatus('Disconnected - start \'bin/server.dart\' to continue');
    new Timer(RECONNECT_DELAY, connect);
  }

  void setStatus(String status) {
    statusElement.innerHtml = status;
  }


  void onMessage(data) {
    var json = JSON.decode(data);
    var response = json['response'];
    switch (response) {
      case 'searchResult':
        addResult(json['source'], json['title'], json['link']);
        break;

      case 'searchDone':
        setStatus(resultsElement.children.isEmpty ? "No results found" : "");
        break;

      default:
        print("Invalid response: '$response'");
    }
  }

  void addResult(String source, String title, String link) {
    var result = new DivElement();
    result.children.add(new HeadingElement.h2()..innerHtml = title);
    result.children.add(new ImageElement(src: link, width: 150 ));
    result.classes.add('result');
    result.onClick.listen((event) {
      resultsElement.children.forEach((Element e) {
        if (e != result) {
          e.hidden = e.hidden || e.children[0].innerHtml == title;
        }
      });
    });
    resultsElement.children.add(result);
  }

  void search(String input) {
    if (input.isEmpty) return;
    setStatus('Searching...');
    resultsElement.children.clear();
    var request = {
      'request': 'search',
      'input': input
    };
    webSocket.send(JSON.encode(request));
  }
}


void main() {
  var client = new Client();
}