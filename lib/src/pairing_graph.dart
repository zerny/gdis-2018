import 'dart:math' show Random, min;
import '../exercises.dart';

/// Automated book-keeping.
var markVisitedAutomatically = true;
var collectChainAutomatically = false;
var avoidRevisitingAutomatically = false;

/// The graph.
DanceGraph graph;

/// The current error.
var error;

/// The collected list of graph commands.
final List<DanceGraphCommand> _undoStack = [];
final List<DanceGraphCommand> _redoStack = [];
bool _isUnOrRedoing = false;
List<DanceGraphCommand> _compoundCollector;

postCommand(DanceGraphCommand command) {
  if (_isUnOrRedoing) return;
  if (_compoundCollector != null) {
    _compoundCollector.add(command);
  } else {
    _undoStack.add(command);
    _redoStack.clear();
  }
}

inCommandBlock(void doSomething()) {
  final List<DanceGraphCommand> compound = [];
  _compoundCollector = compound;
  doSomething();
  _compoundCollector = null;
  if (compound.isNotEmpty) {
    postCommand(new CompoundDanceCommand(compound));
  }
}

clearUndoHistory() {
  _undoStack.clear();
  _redoStack.clear();
}

undo() {
  final DanceGraphCommand command = _undoStack.removeLast();
  _isUnOrRedoing = true;
  command.undo();
  _redoStack.add(command);
  _isUnOrRedoing = false;
}

redo() {
  final DanceGraphCommand command = _redoStack.removeLast();
  _isUnOrRedoing = true;
  command.redo();
  _undoStack.add(command);
  _isUnOrRedoing = false;
}

int get redoCount => _redoStack.length;
int get undoCount => _undoStack.length;

bool get canRedo => _redoStack.isNotEmpty;
bool get canUndo => _undoStack.isNotEmpty;

/// Inverts each edge of the `chain`, then clears `chain` and resets the
/// `graph` markings.
invertChain() {
  inCommandBlock(() {
    for (var edge in edgeStack) {
      invert(edge);
    }
  });
  inCommandBlock(() {
    for (var edge in edgeStack.toList().reversed) {
      unchain(edge);
    }
    for (var dancer in allDancers) {
      unmark(dancer);
    }
  });
}

/// Returns the edge between the two dancers in `graph`.
///
/// Fails with an error, if there is no such edge.
Edge edge(Dancer dancer1, Dancer dancer2) {
  for (final edge in graph.edgesInvolving(dancer1)) {
    if (edge.other(dancer1) == dancer2) {
      return edge;
    }
  }
  throw 'No edge between $dancer1 and $dancer2 in graph';
}

/// Inverts the pairing status of the `edge`.
void invert(Edge edge) {
  if (edge.isPairing) {
    breakPair(edge);
  } else {
    makePair(edge);
  }
}

/// Makes a pair at `edge`.
void makePair(Edge edge) {
  edge.makePair();
}

/// Breaks the pair at `edge`.
void breakPair(Edge edge) {
  edge.breakPair();
}

/// Returns whether the `dancer` is marked.
bool isMarked(Dancer dancer) {
  return dancer.isMarked;
}

/// Returns whether the `dancer` is unmarked.
bool isNotMarked(Dancer dancer) {
  return !dancer.isMarked;
}

/// Marks the `dancer`.
void mark(Dancer dancer) {
  dancer.mark();
}

/// Unmarks the `dancer`.
void unmark(Dancer dancer) {
  dancer.unmark();
}

/// Highlights the `dancer`.
void highlight(Dancer dancer) {
  dancer.highlight();
}

/// Returns whether the `dancer` is highlighted.
bool isHighlighted(Dancer dancer) {
  return dancer.isHighlighted;
}

/// Returns whether the `dancer` is not highlighted.
bool isNotHighlighted(Dancer dancer) {
  return !dancer.isHighlighted;
}

/// Lowlights the `dancer`.
void dim(Dancer dancer) {
  dancer.lowlight();
}

/// Clears the `dancer`'s light.
void resetLight(Dancer dancer) {
  dancer.clearLight();
}

/// Returns whether the `dancer` is paired.
bool isPaired(Dancer dancer) {
  return !graph.isAlone(dancer);
}

/// Returns whether the `dancer` is alone.
bool isNotPaired(Dancer dancer) {
  return graph.isAlone(dancer);
}

/// Make the 'edge' part of the chain.
void chain(Edge edge) {
  edge.chain();
}

/// Removes the 'edge' from the chain.
void unchain(Edge edge) {
  edge.unchain();
}

/// Returns the number of edges involving `dancer`.
int edgeCount(Dancer dancer) {
  return graph.edgesInvolving(dancer).length;
}

/// Returns the suits available to the `dress`. To be used in for loops only.
///
/// If marks are managed automatically, suits will be marked as they are handed
/// out, and already marked suits will be ignored.
///
/// If chain is collected automatically, it will be adjusted to end with the
/// edge from `dress` to the last suit handed out.
Iterable<Suit> suitsAvailableFor(Dress dress) {
  return graph.edgesInvolving(dress).map((edge) {
    final Suit suit = edge.suit;
    if (avoidRevisitingAutomatically && suit.isMarked) {
      return null;
    } else {
      consideringEdge(edge);
      return suit;
    }
  }).where((suit) => suit != null);
}

/// Returns the dresses available to the `suit`. To be used in for loops only.
///
/// If marks are managed automatically, dresses will be marked as they are handed
/// out, and already marked dresses will be ignored.
///
/// If chain is collected automatically, it will be adjusted to end with the
/// edge from `suit` to the last dress handed out.
Iterable<Dress> dressesAvailableFor(Suit suit) {
  return graph.edgesInvolving(suit).map((edge) {
    final Dress dress = edge.dress;
    if (avoidRevisitingAutomatically && dress.isMarked) {
      return null;
    } else {
      consideringEdge(edge);
      return dress;
    }
  }).where((dress) => dress != null);
}

/// Returns the suit currently paired with `dress`. Error if `dress` is alone.
///
/// If marks are managed automatically, the suit will be marked.
///
/// If chain is collected automatically, it will be adjusted to end with the
/// edge from `dress` to the suit returned.
Suit suitPairedWith(Dress dress) {
  final Edge edge = graph
      .edgesInvolving(dress)
      .firstWhere((edge) => edge.isPairing, orElse: () => null);
  if (edge == null) {
    throw '$dress is not paired';
  }
  consideringEdge(edge);
  return edge.suit;
}

/// Returns the dress currently paired with `suit`. Error if `suit` is alone.
///
/// If marks are managed automatically, the dress will be marked.
///
/// If chain is collected automatically, it will be adjusted to end with the
/// edge from `suit` to the dress returned.
Dress dressPairedWith(Suit suit) {
  final Edge edge = graph
      .edgesInvolving(suit)
      .firstWhere((edge) => edge.isPairing, orElse: () => null);
  if (edge == null) {
    throw '$suit is not paired';
  }
  consideringEdge(edge);
  return edge.dress;
}

/// All dancers in `graph`.
Iterable<Dancer> get allDancers {
  return graph.dancers.map<Dancer>(consideringDancer);
}

/// All suits in `graph`.
Iterable<Suit> get allSuits {
  return graph.suits.map<Suit>(consideringDancer);
}

/// All dresses in `graph`.
Iterable<Dress> get allDresses {
  return graph.dresses.map<Dress>(consideringDancer);
}

/// First dress in `graph`.
Dress get firstDress => consideringDancer<Dress>(graph.dresses.first);

/// First suit in `graph`.
Suit get firstSuit => consideringDancer<Suit>(graph.suits.first);

List<Edge> edgeStack = [];

T consideringDancer<T extends Dancer>(T dancer) {
  if (markVisitedAutomatically) {
    mark(dancer);
  }
  return dancer;
}

/// Implements automatic chain collection and marking.
void consideringEdge(Edge edge) {
  bool canExtend(Edge other) {
    if (edge.isPairing) {
      return other != null && !other.isPairing && edge.dress == other.dress;
    } else {
      return other == null || other.isPairing && edge.suit == other.suit;
    }
  }

  inCommandBlock(() {
    if (markVisitedAutomatically) {
      edge.mark();
    }
    if (collectChainAutomatically) {
      while (!canExtend(edgeStack.isEmpty ? null : edgeStack.last)) {
        unchain(edgeStack.last);
      }
      chain(edge);
    }
  });
}

/// Graph implementation.
class DanceGraph {
  final List<Suit> suits;
  final List<Dress> dresses;
  final Map<Dancer, List<Edge>> edgesForDancer;

  DanceGraph(this.suits, this.dresses, List<Edge> edges) : edgesForDancer = {} {
    for (final dancer in dancers) {
      this.edgesForDancer[dancer] = [];
    }
    // Canonicalize and sort edges.
    final Map<Suit, Suit> suitInstances = {};
    final Map<Dress, Dress> dressInstances = {};
    for (final suit in suits) {
      suitInstances[suit] = suit;
    }
    for (final dress in dresses) {
      dressInstances[dress] = dress;
    }
    edges.sort();
    for (final edge in edges) {
      final canonicalEdge =
          new Edge(suitInstances[edge.suit], dressInstances[edge.dress]);
      this.edgesForDancer[canonicalEdge.suit].add(canonicalEdge);
      this.edgesForDancer[canonicalEdge.dress].add(canonicalEdge);
    }
  }

  Iterable<Dancer> get dancers => [suits, dresses].expand((dancers) => dancers);
  Iterable<Edge> get edges => suits.expand((suit) => edgesForDancer[suit]);

  Iterable<Edge> edgesInvolving(Dancer dancer) {
    return edgesForDancer[dancer];
  }

  bool isAlone(Dancer dancer) =>
      edgesInvolving(dancer).where((edge) => edge.isPairing).isEmpty;

  List<Edge> get pairing {
    final List<Edge> pairing = edges.where((edge) => edge.isPairing).toList();
    Set<Dancer> dancers = new Set();
    for (var edge in pairing) {
      if (!dancers.add(edge.dress)) {
        throw 'Illegal pairing: ${edge.dress} reused';
      }
      if (!dancers.add(edge.suit)) {
        throw 'Illegal pairing: ${edge.suit} reused';
      }
    }
    return pairing;
  }

  @override
  String toString() {
    final StringBuffer buffer = new StringBuffer();
    buffer.write('Suits : ');
    buffer.writeln(suits.join(', '));
    buffer.write('Dresses: ');
    buffer.writeln(dresses.join(', '));
    buffer.writeln('Edges:');
    for (var suit in suits) {
      for (var edge in edgesInvolving(suit)) {
        buffer.writeln('  $edge');
      }
    }
    return buffer.toString();
  }
}

/// Pairable edge between a suit and a dress.
class Edge implements Comparable<Edge> {
  final Suit suit;
  final Dress dress;
  bool isPairing = false;
  bool isOnChain = false;

  Edge(this.suit, this.dress) {
    assert(suit != null);
    assert(dress != null);
  }

  void makePair() {
    if (!isPairing) {
      postCommand(new EdgeCommand(this, EdgeEventKind.paired));
      isPairing = true;
    }
  }

  void breakPair() {
    if (isPairing) {
      postCommand(new EdgeCommand(this, EdgeEventKind.unpaired));
      isPairing = false;
    }
  }

  void chain() {
    assert(!isOnChain);
    postCommand(new EdgeCommand(this, EdgeEventKind.chained));
    edgeStack.add(this);
    isOnChain = true;
  }

  void unchain() {
    assert(isOnChain);
    postCommand(new EdgeCommand(this, EdgeEventKind.unchained));
    isOnChain = false;
    edgeStack.removeLast();
  }

  bool get isMarked => suit.isMarked || dress.isMarked;

  void mark() {
    suit.mark();
    dress.mark();
  }

  void unmark() {
    suit.unmark();
    dress.unmark();
  }

  Dancer other(Dancer dancer) {
    if (dancer == suit) {
      return dress;
    } else if (dancer == dress) {
      return suit;
    } else {
      throw 'Dancer $dancer not involved in $this';
    }
  }

  @override
  int compareTo(Edge other) {
    final c = suit.compareTo(other.suit);
    if (c != 0) return c;
    return dress.compareTo(other.dress);
  }

  @override
  operator ==(o) => o is Edge && o.suit == suit && o.dress == dress;

  @override
  int get hashCode => suit.hashCode ^ dress.hashCode;

  @override
  String toString() {
    if (isPairing) {
      if (isOnChain) {
        return '$suit=!=$dress';
      } else {
        return '$suit-!-$dress';
      }
    } else {
      if (isOnChain) {
        return '$suit=?=$dress';
      } else {
        return '$suit-?-$dress';
      }
    }
  }
}

/// Dancer. May be a Suit or a Dress.
class Dancer {
  final String name;
  final String image;
  bool isMarked = false;
  bool _light = null;

  Dancer(this.name, {this.image});

  bool get isHighlighted => _light == true;
  bool get isDimmed => _light == false;

  void highlight() {
    postCommand(new DancerCommand(this, DancerEventKind.highlighted));
    _light = true;
  }

  void lowlight() {
    postCommand(new DancerCommand(this, DancerEventKind.lowlighted));
    _light = false;
  }

  void clearLight() {
    _light = null;
  }

  void mark() {
    if (!isMarked) {
      postCommand(new DancerCommand(this, DancerEventKind.marked));
      isMarked = true;
    }
  }

  void unmark() {
    if (isMarked) {
      postCommand(new DancerCommand(this, DancerEventKind.unmarked));
      isMarked = false;
    }
  }

  @override
  operator ==(o) => o?.runtimeType == this.runtimeType && o.name == name;

  @override
  int get hashCode => name.hashCode;
}

/// Suit dancer.
class Suit extends Dancer implements Comparable<Suit> {
  Suit(String name, {String image = 'pictures/suit.jpg'}) : super(name, image: image);

  @override
  String toString() => this.isMarked ? '[[$name]]' : '[$name]';

  @override
  int compareTo(Suit other) => name.compareTo(other.name);
}

/// Dress dancer.
class Dress extends Dancer implements Comparable<Dress> {
  Dress(String name, {String image = 'pictures/dress.jpg'}) : super(name, image: image);

  @override
  String toString() => this.isMarked ? '(($name))' : '($name)';

  @override
  int compareTo(Dress other) => name.compareTo(other.name);
}

/// Graph change Command object.
abstract class DanceGraphCommand {
  void redo();
  void undo();
}

enum DancerEventKind { marked, unmarked, highlighted, lowlighted }
enum EdgeEventKind { paired, unpaired, chained, unchained }

class CompoundDanceCommand extends DanceGraphCommand {
  final List<DanceGraphCommand> commands;
  CompoundDanceCommand(this.commands);

  @override
  void undo() {
    for (final DanceGraphCommand command in commands.reversed) {
      command.undo();
    }
  }

  @override
  void redo() {
    for (final DanceGraphCommand command in commands) {
      command.redo();
    }
  }
}

/// Command object that modifies an Dancer.
class DancerCommand extends DanceGraphCommand {
  final Dancer dancer;
  final DancerEventKind kind;
  DancerCommand(this.dancer, this.kind);

  @override
  void redo() {
    switch (kind) {
      case DancerEventKind.marked:
        dancer.mark();
        break;
      case DancerEventKind.unmarked:
        dancer.unmark();
        break;
      case DancerEventKind.highlighted:
        dancer.highlight();
        break;
      case DancerEventKind.lowlighted:
        dancer.lowlight();
        break;
    }
  }

  @override
  void undo() {
    switch (kind) {
      case DancerEventKind.marked:
        dancer.unmark();
        break;
      case DancerEventKind.unmarked:
        dancer.mark();
        break;
      case DancerEventKind.highlighted:
        dancer.clearLight();
        break;
      case DancerEventKind.lowlighted:
        dancer.clearLight();
        break;
    }
  }

  @override
  String toString() => '$kind $dancer';
}

/// Command object that modifies an Edge.
class EdgeCommand extends DanceGraphCommand {
  final Edge edge;
  final EdgeEventKind kind;
  EdgeCommand(this.edge, this.kind);

  @override
  void redo() {
    switch (kind) {
      case EdgeEventKind.paired:
        edge.makePair();
        break;
      case EdgeEventKind.unpaired:
        edge.breakPair();
        break;
      case EdgeEventKind.chained:
        edge.chain();
        break;
      case EdgeEventKind.unchained:
        edge.unchain();
        break;
    }
  }

  @override
  void undo() {
    switch (kind) {
      case EdgeEventKind.paired:
        edge.breakPair();
        break;
      case EdgeEventKind.unpaired:
        edge.makePair();
        break;
      case EdgeEventKind.chained:
        edge.unchain();
        break;
      case EdgeEventKind.unchained:
        edge.chain();
        break;
    }
  }

  @override
  String toString() => '$kind $edge';
}

/// Command object that displays an error.
class ErrorCommand extends DanceGraphCommand {
  final newError;
  final oldError;

  ErrorCommand(this.newError): oldError = error;

  @override
  void redo() {
    error = newError;
  }

  @override
  void undo() {
    error = oldError;
  }
}

/// Naive max pairing algorithm. Exponential.
void naiveMaxPairing() {
  inCommandBlock(() {
    for (final edge in graph.edges) {
      breakPair(edge);
    }
  });
  final solution = _naiveMaxPairing(graph, graph.edges);
  inCommandBlock(() {
    for (final edge in solution) {
      makePair(edge);
    }
  });
}

/// Returns the best pairing possible using [edges] and observing
/// pairing already made by other edges. Has no net effect on the graph.
List<Edge> _naiveMaxPairing(DanceGraph graph, Iterable<Edge> edges) {
  if (edges.isEmpty) {
    return <Edge>[];
  }
  final Edge edge = edges.first;
  if (isNotPaired(edge.suit) && isNotPaired(edge.dress)) {
    makePair(edge);
    final bestWithEdge = _naiveMaxPairing(graph, edges.skip(1));
    breakPair(edge);
    final bestWithoutEdge = _naiveMaxPairing(graph, edges.skip(1));
    if (bestWithoutEdge.length <= bestWithEdge.length) {
      return bestWithEdge..add(edge);
    } else {
      return bestWithoutEdge;
    }
  }
  return _naiveMaxPairing(graph, edges.skip(1));
}

replace_by_your_solution(suit) {
  if (collectChainAutomatically && avoidRevisitingAutomatically) {
    // Simple solution when chain collection and marking is handled automatically.
    for (var dress in dressesAvailableFor(suit)) {
      if (isNotPaired(dress) ||
          canFindUnpairedDressFrom(suitPairedWith(dress))) {
        return true;
      }
    }
    return false;
  } else if (avoidRevisitingAutomatically) {
    // Solution when we must collect the chain ourselves.
    for (var dress in dressesAvailableFor(suit)) {
      if (isNotPaired(dress)) {
        chain(edge(dress, suit));
        return true;
      } else {
        var nextSuit = suitPairedWith(dress);
        if (canFindUnpairedDressFrom(nextSuit)) {
          chain(edge(nextSuit, dress));
          chain(edge(dress, suit));
          return true;
        }
      }
    }
    return false;
  } else if (collectChainAutomatically) {
    // Solution when we must handle marking ourselves.
    // We can get away with marking only the dresses.
    for (var dress in dressesAvailableFor(suit)) {
      if (isMarked(dress)) {
        continue;
      }
      mark(dress);
      if (isNotPaired(dress) ||
          canFindUnpairedDressFrom(suitPairedWith(dress))) {
        return true;
      }
    }
    return false;
  } else {
    // Solution when we must handle chain collection and marking ourselves.
    // We can get away with marking only the dresses.
    for (var dress in dressesAvailableFor(suit)) {
      if (isMarked(dress)) {
        continue;
      }
      mark(dress);
      if (isNotPaired(dress)) {
        chain(edge(suit, dress));
        return true;
      } else {
        var nextSuit = suitPairedWith(dress);
        if (canFindUnpairedDressFrom(nextSuit)) {
          chain(edge(dress, nextSuit));
          chain(edge(suit, dress));
          return true;
        }
      }
    }
    return false;
  }
}

// Sample graphs.

DanceGraph danceGraph(
  List<Suit> suits,
  List<Dress> dresses,
  List<Edge> edges,
) =>
    new DanceGraph(
      suits,
      dresses,
      edges,
    );
Suit suit(int s) => new Suit('S$s');
Dress dress(int d) => new Dress('D$d');
Edge newEdge(Suit left, Dress right) => new Edge(left, right);
final alice = new Dress('Alice');
final bob = new Suit('Bob');
final carol = new Dress('Carol');
final dean = new Suit('Dean');
final eve = new Dress('Eve');
final frank = new Suit('Frank');
final ginny = new Dress('Ginny');
final harry = new Suit('Harry');
final isa = new Dress('Isa');
final john = new Suit('John');
final karen = new Dress('Karen');
final lloyd = new Suit('Lloyd');
final mary = new Dress('Mary');
final nat = new Suit('Nat');
DanceGraph get empty => danceGraph([], [], []);
DanceGraph get noEdges => danceGraph([bob], [alice], []);
DanceGraph get twoByTwo => danceGraph(
      [bob, dean],
      [alice, carol],
      [newEdge(bob, alice), newEdge(bob, carol), newEdge(dean, alice)],
    );
DanceGraph get threeByThree => danceGraph(
      [bob, dean, frank],
      [alice, carol, eve],
      [
        newEdge(bob, alice),
        newEdge(bob, carol),
        newEdge(dean, alice),
        newEdge(dean, eve),
        newEdge(frank, alice),
        newEdge(frank, carol),
        newEdge(frank, eve),
      ],
    );
DanceGraph get sevenBySeven => danceGraph(
      [bob, dean, frank, harry, john, lloyd, nat],
      [alice, carol, eve, ginny, isa, karen, mary],
      [
        newEdge(bob, carol),
        newEdge(bob, mary),
        newEdge(dean, alice),
        newEdge(dean, ginny),
        newEdge(dean, mary),
        newEdge(frank, alice),
        newEdge(frank, carol),
        newEdge(frank, mary),
        newEdge(harry, carol),
        newEdge(harry, eve),
        newEdge(harry, ginny),
        newEdge(harry, isa),
        newEdge(harry, mary),
        newEdge(john, alice),
        newEdge(john, ginny),
        newEdge(john, mary),
        newEdge(lloyd, carol),
        newEdge(lloyd, mary),
        newEdge(nat, alice),
        newEdge(nat, eve),
        newEdge(nat, isa),
        newEdge(nat, karen),
      ],
    );
DanceGraph get vorrevang => danceGraph(
      new List.generate(33, suit),
      new List.generate(23, dress),
      [
        newEdge(suit(0), dress(0)),
        newEdge(suit(0), dress(1)),
        newEdge(suit(0), dress(12)),
        newEdge(suit(0), dress(17)),
        newEdge(suit(1), dress(9)),
        newEdge(suit(1), dress(11)),
        newEdge(suit(2), dress(7)),
        newEdge(suit(2), dress(10)),
        newEdge(suit(2), dress(15)),
        newEdge(suit(3), dress(10)),
        newEdge(suit(3), dress(17)),
        newEdge(suit(3), dress(20)),
        newEdge(suit(4), dress(3)),
        newEdge(suit(4), dress(8)),
        newEdge(suit(4), dress(15)),
        newEdge(suit(4), dress(17)),
        newEdge(suit(4), dress(19)),
        newEdge(suit(5), dress(4)),
        newEdge(suit(5), dress(5)),
        newEdge(suit(5), dress(10)),
        newEdge(suit(6), dress(6)),
        newEdge(suit(6), dress(7)),
        newEdge(suit(6), dress(8)),
        newEdge(suit(6), dress(22)),
        newEdge(suit(7), dress(8)),
        newEdge(suit(7), dress(9)),
        newEdge(suit(7), dress(10)),
        newEdge(suit(7), dress(17)),
        newEdge(suit(8), dress(2)),
        newEdge(suit(8), dress(9)),
        newEdge(suit(8), dress(12)),
        newEdge(suit(9), dress(4)),
        newEdge(suit(9), dress(5)),
        newEdge(suit(9), dress(8)),
        newEdge(suit(10), dress(3)),
        newEdge(suit(10), dress(10)),
        newEdge(suit(10), dress(13)),
        newEdge(suit(11), dress(10)),
        newEdge(suit(11), dress(19)),
        newEdge(suit(12), dress(0)),
        newEdge(suit(12), dress(16)),
        newEdge(suit(13), dress(6)),
        newEdge(suit(13), dress(7)),
        newEdge(suit(13), dress(10)),
        newEdge(suit(13), dress(11)),
        newEdge(suit(13), dress(12)),
        newEdge(suit(14), dress(13)),
        newEdge(suit(14), dress(14)),
        newEdge(suit(15), dress(8)),
        newEdge(suit(15), dress(18)),
        newEdge(suit(16), dress(6)),
        newEdge(suit(16), dress(7)),
        newEdge(suit(16), dress(10)),
        newEdge(suit(16), dress(12)),
        newEdge(suit(16), dress(15)),
        newEdge(suit(16), dress(21)),
        newEdge(suit(17), dress(4)),
        newEdge(suit(17), dress(5)),
        newEdge(suit(17), dress(6)),
        newEdge(suit(17), dress(7)),
        newEdge(suit(18), dress(20)),
        newEdge(suit(18), dress(21)),
        newEdge(suit(19), dress(2)),
        newEdge(suit(19), dress(4)),
        newEdge(suit(19), dress(5)),
        newEdge(suit(19), dress(6)),
        newEdge(suit(19), dress(8)),
        newEdge(suit(20), dress(10)),
        newEdge(suit(20), dress(14)),
        newEdge(suit(20), dress(16)),
        newEdge(suit(20), dress(17)),
        newEdge(suit(21), dress(11)),
        newEdge(suit(21), dress(13)),
        newEdge(suit(21), dress(15)),
        newEdge(suit(21), dress(16)),
        newEdge(suit(21), dress(17)),
        newEdge(suit(21), dress(19)),
        newEdge(suit(22), dress(3)),
        newEdge(suit(22), dress(8)),
        newEdge(suit(23), dress(17)),
        newEdge(suit(23), dress(18)),
        newEdge(suit(23), dress(19)),
        newEdge(suit(24), dress(20)),
        newEdge(suit(25), dress(9)),
        newEdge(suit(25), dress(13)),
        newEdge(suit(25), dress(15)),
        newEdge(suit(25), dress(16)),
        newEdge(suit(26), dress(0)),
        newEdge(suit(26), dress(1)),
        newEdge(suit(26), dress(18)),
        newEdge(suit(27), dress(10)),
        newEdge(suit(27), dress(15)),
        newEdge(suit(27), dress(18)),
        newEdge(suit(27), dress(19)),
        newEdge(suit(28), dress(12)),
        newEdge(suit(28), dress(18)),
        newEdge(suit(29), dress(12)),
        newEdge(suit(29), dress(16)),
        newEdge(suit(30), dress(13)),
        newEdge(suit(30), dress(14)),
        newEdge(suit(31), dress(20)),
        newEdge(suit(31), dress(21)),
        newEdge(suit(32), dress(20)),
        newEdge(suit(32), dress(21)),
      ],
    );

DanceGraph random(
    {int suitCount = 5, int dressCount = 5, int edgeLimit, Random random}) {
  edgeLimit ??= min(suitCount, dressCount);
  random ??= new Random();
  List<int> dressIndices = new List.generate(dressCount, (index) => index);
  return danceGraph(
      new List.generate(suitCount, suit),
      new List.generate(dressCount, dress),
      new Iterable.generate(suitCount, (suitIndex) {
        dressIndices.shuffle(random);
        return new List.generate(random.nextInt(edgeLimit),
            (i) => newEdge(suit(suitIndex), dress(dressIndices[i])));
      }).expand((edges) => edges).toList());
}
