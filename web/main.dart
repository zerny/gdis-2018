// Copyright (c) 2017, kasperl. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'package:gdis/gdis.dart';
import 'package:gdis/src/pairing_graph.dart';

final graphs = [
  graph0,
  graph1,
  graph2,
  graph3,
  graph4,
  graph5,
  graph6,
];

final algorithms = [
  algorithm0,
  algorithm1,
  algorithm2,
  algorithm3,
  algorithm4,
  algorithm5,
];

Timer _timer;

_play() {
  _timer = new Timer.periodic(const Duration(milliseconds: 600), (Timer t) {
    if (canRedo) {
      stepForward();
      _resetStepCounter();
    } else {
      _stop();
    }
  });
  _resetEnablement();
}

_stop() {
  if (_timer != null) {
    _timer.cancel();
    _timer = null;
  }
  _resetEnablement();
}

_resetEnablement() {
  final int totalSteps = redoCount + undoCount;
  runButton.disabled = totalSteps != 0;
  goToStartButton.disabled = (_timer != null || !canUndo);
  stepBackwardButton.disabled = (_timer != null || !canUndo);
  stepForwardButton.disabled = (_timer != null || !canRedo);
  goToEndButton.disabled = (_timer != null || !canRedo);
  playButton.disabled = (_timer != null || !canRedo);
  stopButton.disabled = (_timer == null);
  _resetStepCounter();
}

_resetStepCounter() {
  final int totalSteps = redoCount + undoCount;
  if (totalSteps == 0) {
    stepCounterElement.text = "";
  } else if (undoCount == totalSteps) {
    stepCounterElement.text = "Executed ${undoCount} steps";
  } else {
    stepCounterElement.text = "Executed ${undoCount} steps of $totalSteps";
  }
}

final SelectElement algorithmSelector = querySelector("#algorithmSelection");
final ButtonElement runButton = querySelector("#run");
final ButtonElement goToStartButton = querySelector("#goToStart");
final ButtonElement stepBackwardButton = querySelector("#stepBackward");
final ButtonElement stepForwardButton = querySelector("#stepForward");
final ButtonElement goToEndButton = querySelector("#goToEnd");
final Element stepCounterElement = querySelector("#stepCounter");
final ButtonElement playButton = querySelector("#play");
final ButtonElement stopButton = querySelector("#stop");

main() {
  final int graphIndex = js.context['graphIndex'];

  graphs[graphIndex]();

  algorithmSelector.onChange.listen((Event e) {
    reset();
    _stop();
  });
  runButton.onClick.listen((MouseEvent e) {
    final int algorithmIndex = js.context['algorithmIndex'];
    algorithms[algorithmIndex]();
    _resetEnablement();
  });
  goToStartButton.onClick.listen((MouseEvent e) {
    goToStart();
    _resetEnablement();
  });
  stepBackwardButton.onClick.listen((MouseEvent e) {
    stepBackward();
    _resetEnablement();
  });
  stepForwardButton.onClick.listen((MouseEvent e) {
    stepForward();
    _resetEnablement();
  });
  goToEndButton.onClick.listen((MouseEvent e) {
    goToEnd();
    _resetEnablement();
  });
  playButton.onClick.listen((MouseEvent e) {
    _play();
  });
  stopButton.onClick.listen((MouseEvent e) {
    _stop();
  });
  _resetEnablement();
}
