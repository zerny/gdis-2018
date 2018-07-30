import 'src/pairing_graph.dart';

// Exercises 1 and 2

highlightPickySuits() {
  for (var suit in allSuits) {
    if (edgeCount(suit) <= 1) {
      highlight(suit);
    }
  }
}

// Exercises 3 and 4

highlightPopularDresses() {
  for (var dress in allDresses) {
    // your code here
  }
}

// Exercise 5

highlightRivalsOfFirstSuit() {
  for (var dress in dressesAvailableFor(firstSuit)) {
    for (var suit in suitsAvailableFor(dress)) {
      if (suit != firstSuit) {
        highlight(suit);
      }
    }
  }
}

highlightRivalsOfFirstDress() {
  // your code here
}

// Exercise 6

highlightFirstDressAndFriends() {
  highlightDressAndFriends(firstDress);
}


/// Highlight the given dress and all friends, if not already done.
highlightDressAndFriends(dress) {
  if (isNotHighlighted(dress)) {
    highlight(dress);
    for (var suit in suitsAvailableFor(dress)) {
      // your code here
    }
  }
}

/// Highlight the given suit and all friends, if not already done.
highlightSuitAndFriends(suit) {
  // your code here
}

// Exercises 7 and 8

maxPairing() {
  while (canFindChain()) {
    invertChain();
  }
}

/// Is there a path from an unpaired suit to an unpaired dress?
canFindChain() {
  for (var suit in allSuits) {
    if (isNotPaired(suit) && canFindUnpairedDressFrom(suit)) {
      return true;
    }
  }
  return false;
}

/// Is there a path to an unpaired dress from the given suit?
canFindUnpairedDressFrom(suit) {
  return replace_by_your_solution(suit);
}

