library clickGame;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'package:maan_roos_vis/game_container.dart';


@CustomTag('click-game')
class ClickGame extends PolymerElement with WordGame {

  Arbiter _arbiter;
  
  ClickGame.created() : super.created();

  void yes(Event e, var detail, Node target) {    
    _arbiter.attempt(true);
  }

  void no(Event e, var detail, Node target) {    
    _arbiter.attempt(false);
  }

  void newChallenge(Arbiter arbiter) {
    _arbiter = arbiter;
  }
}