import 'dart:js' as js;
import 'exercises.dart';
import 'src/teachers.dart';
import 'src/pairing_graph.dart';

const collectChain = true;
const markVisited = true;

graph0() {
  graph = random(suitCount: 4, dressCount: 4);
  visualize();
}

graph1() {
  graph = random(suitCount: 6, dressCount: 6);
  visualize();
}

graph2() {
  graph = random(suitCount: 10, dressCount: 12, edgeLimit: 8);
  visualize();
}

graph3() {
  graph = random(suitCount: 24, dressCount: 20, edgeLimit: 5);
  visualize();
}

graph4() {
  graph = random(suitCount: 50, dressCount: 60, edgeLimit: 5);
  visualize();
}

graph5() {
  final suitTeachers = <Teacher>[
    HansOS,
    Mads,
    Axel,
    Benny,
    Bjarne,
    Irvin,
  ];
  final dressTeachers = <Teacher>[
    Ane,
    ChristinaB,
    ChristinaTE,
    Anette,
    AnneM,
    Terese,
    AnneG,
  ];
  final edges = <Edge>[];
  edges.add(newEdge(inSuit(HansOS), inDress(ChristinaB)));
  edges.add(newEdge(inSuit(HansOS), inDress(Anette)));
  edges.add(newEdge(inSuit(HansOS), inDress(AnneG)));
  edges.add(newEdge(inSuit(Mads), inDress(Ane)));
  edges.add(newEdge(inSuit(Mads), inDress(Anette)));
  edges.add(newEdge(inSuit(Mads), inDress(AnneM)));
  edges.add(newEdge(inSuit(Mads), inDress(Terese)));
  edges.add(newEdge(inSuit(Axel), inDress(Terese)));
  edges.add(newEdge(inSuit(Benny), inDress(Anette)));
  edges.add(newEdge(inSuit(Benny), inDress(AnneG)));
  edges.add(newEdge(inSuit(Bjarne), inDress(ChristinaB)));
  edges.add(newEdge(inSuit(Bjarne), inDress(AnneM)));
  edges.add(newEdge(inSuit(Irvin), inDress(ChristinaTE)));
  edges.add(newEdge(inSuit(Irvin), inDress(Anette)));
  edges.add(newEdge(inSuit(Irvin), inDress(AnneG)));
  graph = new DanceGraph(
    suitTeachers.map(inSuit).toList(),
    dressTeachers.map(inDress).toList(),
    edges,
  );
  visualize();
}

graph6() {
  final suits = teachersMale.map(inSuit).toList();
  final dresses = teachersFemale.map(inDress).toList();
  final edges = <Edge>[];
  for (final male in teachersMale) {
    for (final female in teachersFemale) {
      if (canDance(male, female)) {
        edges.add(newEdge(inSuit(male), inDress(female)));
      }
    }
  }
  graph = new DanceGraph(suits, dresses, edges);
  visualize();
}

Suit inSuit(Teacher teacher) => new Suit(teacher.name, image: teacher.picture);
Dress inDress(Teacher teacher) =>
    new Dress(teacher.name, image: teacher.picture);

algorithm0() {
  withErrorHandling(highlightPickySuits);
  visualize();
}

algorithm1() {
  withErrorHandling(highlightPopularDresses);
  visualize();
}

algorithm2() {
  withErrorHandling(highlightRivalsOfFirstSuit);
  visualize();
}

algorithm3() {
  withErrorHandling(highlightRivalsOfFirstDress);
  visualize();
}

algorithm4() {
  withErrorHandling(highlightFirstDressAndFriends);
  visualize();
}

algorithm5() {
  withErrorHandling(() {
    withAutos(maxPairing);
  });
  visualize();
}

algorithm6() {
  withErrorHandling(naiveMaxPairing);
  visualize();
}

withErrorHandling(void actions()) {
  try {
    actions();
  } catch (e) {
    postCommand(new ErrorCommand(e));
    error = e;
  }
}

withAutos(void actions()) {
  collectChainAutomatically = collectChain;
  markVisitedAutomatically = markVisited;
  avoidRevisitingAutomatically = markVisited;
  try {
    actions();
  } finally {
    markVisitedAutomatically = true;
    collectChainAutomatically = false;
    avoidRevisitingAutomatically = false;
  }
}

reset() {
  error = null;
  for (var edge in edgeStack.toList().reversed) {
    unchain(edge);
  }
  for (var edge in graph.pairing) {
    breakPair(edge);
  }
  for (var dancer in allDancers) {
    unmark(dancer);
    resetLight(dancer);
  }
  clearUndoHistory();
  visualize();
}

goToStart() {
  while (canUndo) {
    undo();
  }
  visualize();
}

stepBackward() {
  if (!canUndo) return;
  undo();
  visualize();
}

stepForward() {
  if (!canRedo) return;
  redo();
  visualize();
}

goToEnd() {
  while (canRedo) {
    redo();
  }
  visualize();
}

visualize() {
  visualizeGraph();
  visualizeError();
}

visualizeError() {
  js.context.callMethod('visualizeError', [error?.toString()]);
}

visualizeGraph() {
  var nodesIndex = {};
  var nodes = new StringBuffer();
  var i = 0;

  var y = 1;
  var first = true;
  graph.suits.forEach((suit) {
    if (!first) {
      nodes.write(',');
    }
    first = false;
    String color =
        suit.isHighlighted ? "green" : (suit.isDimmed ? "gray" : "blue");
    if (suit.isMarked) {
      color = "dark$color";
    }
    nodes.write(
        '{"id": "${suit.name}", "x": 1, "y": ${y++}, "color": "$color", "img": "${suit.image}"}');
    nodesIndex[suit] = i++;
  });

  y = 1;
  graph.dresses.forEach((dress) {
    if (!first) {
      nodes.write(',');
    }
    first = false;
    String color =
        dress.isHighlighted ? "orange" : (dress.isDimmed ? "gray" : "red");
    if (dress.isMarked) {
      color = "dark$color";
    }
    nodes.write(
        '{"id": "${dress.name}", "x": 10, "y": ${y++}, "color": "$color", "img": "${dress.image}"}');
    nodesIndex[dress] = i++;
  });

  final edges = new StringBuffer();
  first = true;
  for (var edge in graph.edges) {
    if (!first) {
      edges.write(',');
    }
    first = false;
    edges.write(
        '{"source": ${nodesIndex[edge.suit]}, "target": ${nodesIndex[edge.dress]}, "width": ${edge.isOnChain ? 3 : 1}, "onChain": ${edge.isOnChain}, "selected": ${edge.isPairing}}');
  }
  js.context.callMethod('visualizeGraph', ["[$nodes]", "[$edges]"]);
}
