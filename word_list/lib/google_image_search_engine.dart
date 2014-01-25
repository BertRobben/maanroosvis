// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of search_engine;


class GoogleImageSearchEngine implements SearchEngine {
  String get name => 'Google Image Search';

  Stream<SearchResult> search(String input) {
    var query = {
      'q': '$input',
      'v': '1.0',
      'rsz' : '3',
      'hl' : 'nl',
      'as_sitesearch' : '.be',
    };
    var searchUri = new Uri.https(
        'ajax.googleapis.com',
        '/ajax/services/search/images',
        query);
    var controller = new StreamController();
    http_client.get(searchUri)
      .then((http_client.Response response) {
        if (response.statusCode != HttpStatus.OK) {
          throw "Bad status code: ${response.statusCode}, "
                "message: ${response.reasonPhrase}";
        }
        var json = JSON.decode(response.body);
        json['responseData']['results']
          .forEach((item) {
            controller.add(new SearchResult(
                input, item['url']));
          });
      })
      .catchError(controller.addError)
      .whenComplete(controller.close);
    return controller.stream;
  }
}