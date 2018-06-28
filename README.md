# Girls' Day in Science, 2018

This repository contains the code for the codelab for GDIS'18 hosted at Google
in Aarhus. TA introduction is available below, in English. Exercise sheet and
user interface are currently available in Danish only.

To try out the codelab, install Dart 2 (https://www.dartlang.org/) and use its
`webdev` tool to launch a web server:
```
$ cd gdis-2018
$ webdev serve
```
Then navigate your browser to localhost:8080. Make code changes to
`gdis-2018/lib/exercises.dart` to solve the exercises set below.

## TA introduction

### The problem

In preparation for [the prom](https://en.wikipedia.org/wiki/Prom#Denmark) at the
local gymnasium, the students need to form pairs for the traditional Les Lanciers
partner dance. We obviously want as many pairs as possible, but a set of constraints
must be observed since not everybody wants to dance with everybody else. For each
student, there is thus a set of other students with whom acceptable pairs can be
formed. We want to create a computer program that given this input finds the largest
possible set of acceptable pairs that we can form for the dance.

### Math: clarifying the problem

Math is helpful to clearly state a problem (definitions) and for finding inspiration
for its solution (theorems).

Our problem can be represented as a **graph** with **nodes** representing students
and **edges** representing acceptable pairs. Our graph will be **bipartite**, meaning
we have two kinds of node ("suit" and "dress"), and edges will always be between a
suit and a dress.

A selection of edges with non-overlapping nodes in a graph is called a **pairing**.
Our problem is then to find a maximal pairing in a bipartite graph. "Maximal" meaning
one that cannot be improved; there is no global maximum.

### Computer science: solving the problem

Computer science makes math concrete enough to execute on a computer. We invent
**algorithms** that specify the basic computational steps needed to solve any concrete
problem instance, thereby solving the problem in general.

Two common algorithmic ideas are as follows:

* **Break down the problem** into smaller problems. Solve those. Then combine the small
  solutions into a solution to the original problem. You'd need to know how to solve
  small problem instances directly.

* **Grow the solution** from an initial (probably poor) solution that you repeatedly
  improve until it cannot be improved anymore.

We can break down an instance of maximal pairing by taking out the first edge of the
graph, and then solve the problem twice for the remaining graph: first assuming that
the removed edge is paired (so removing also its nodes), second assuming it is not.
We then combine the two solutions by keeping the larger one. The empty graph cannot
be broken down, but we already know the solution here.

It is probably less clear how to grow a solution. We can start with the empty pairing,
but how do we improve it, and how do we know that we cannot improve it any further?
We'll look at some examples, and maybe get an idea. Otherwise, we can ask math for
help. Is there are way to characterize a maximal pairing?

[Berge's lemma](https://en.wikipedia.org/wiki/Berge%27s_lemma) tells us that a given
pairing is maximal iff there is no augmenting chain, that is, a chain of edges starting
and ending with unpaired nodes, and which alternates between edges in and not in the
pairing.

The chain is called "augmenting" because we can use it to improve our current solution
by one edge. We do that by inverting the pairing status of every edge on the chain.
That leads to the following algorithm:

**Algorithm** maxPairing(graph):
  **while** graph has chain
    invert chain
  **return** edges in graph marked as part of pairing

Efficiency concerns will often lead us to prefer one algorithm over another one. We'll
look at the relative efficiency of our two algorithms and talk about exponential (2ⁿ)
vs polynomial (n²) growth.

### Programming: implementing the solution

We'll do some warm-up exercises (numbered 1 through 5) to familiarize ourselves with
programming graph algorithms with suits and dresses. Then we'll implement a core part
("graph has chain") of the more efficient algorithm above as exercises 6 and 7.

Participants will be given a paper listing of the exercises and the available graph
operations and queries. Everything will be based on top-level functions implemented
with for/while/if-else. No visible method calls, no visible types. The graph and chain
will be global variables. Participants will work in groups of two or three, sharing a
single MacBook. Programming will be done in Dart using a simple editor (like Atom or
TextMate) with `webdev serve` feeding a web UI for fast visual feedback on code changes.

Alert! Algorithms are executed in full before being visualized, collecting graph
modifications such as node highlights or edge pairings. The end state is visualized
first, and participants can then rewind and single-step through each change using the
control panel on the left above. Infinite loops will leave the UI hanging and then
presumably crash the browser tab as it runs out of heap or stack space.

Solutions to the exercises are available on request.

### Notes on max pairing exercises

For the max pairing exercise (6), the provided backing code (which the participants do
not have to see) handles chain collection as a side effect of calling
`dressesAvailableFor` and `suitPairedWith` and their symmetric graph-navigating
functions. The same goes for marking graph nodes to avoid visiting the same node twice.

*Alert! This means that calling the `dressesAvailableFor` or `suitsAvailableFor`
functions twice in your solution to Exercise 6 with the same argument will return
an empty iterable on the second call, because then the connected dresses and suits
will have already been visited!*

Chain and markings are cleared as a side effect of calling `invertChain`.

The final "stretch" exercise (7) asks participants to let go of these training wheels,
and redo exercise 6 while implementing chain collection and/or graph markings
themselves. The automated side-effects are turned off by setting one or both the two
global flags (`collectChain`, `markVisited`) to false at the top of the `gdis.dart`
file.

## Exercise sheet (in Danish)

### Kræsne jakker

Her er noget kode, der fremhæver de jakke-knuder i vores graf, som er "kræsne"
i den forstand, at de er forbundet med højst én kjole-knude:

```dart
highlightPickySuits() {
  for (var suit in allSuits) {
    if (edgeCount(suit) <= 1) {
      highlight(suit);
    }
  }
}
```

Læs og forstå koden med hjælp fra jeres vejleder. Prøv at køre den på nogle
eksempler.

`allSuits` er alle jakke-knuder i grafen.  
`edgeCount(x)` er antallet af kanter knyttet til knuden x.  
`highlight(x)` fremhæver knuden x i grafen.  

**Opgave 1** Ret koden, så det at være kræsen i stedet betyder, at der højst er
to kjoler, man vil danse med. Gem ændringen og afprøv koden på nogle eksempler.

**Opgave 2** Ret koden, så det at være kræsen i stedet betyder, at der er én
eller to kjoler, man vil danse med. I koden skriver man `==` for at teste om to
værdier er ens (og `!=` for at teste, om de er forskellige -- det skal vi bruge
senere.) I får også brug for at kunne kombinere betingelser. Man skriver `||`
for "eller":

```dart
if (x == 7 || y == 3) {
  // do something, if x=7 or y=3 (or both)
}
```
Tilsvarende skriver man `&&` for "og". Det skal vi også bruge senere.

Afprøv jeres kode på nogle eksempler (husk at gemme ændringerne).

### Populære kjoler
Her er en skabelon til noget kode, der fremhæver de populære kjole-knuder i grafen:

```dart
highlightPopularDresses() {
  for (var dress in allDresses) {
    // your code here
  }
}
```

**Opgave 3** Indsæt jeres egen løsning. Det er op til jer, hvor mange jakker, en
kjole skal kunne danse med for at være populær. I kan anvende `edgeCount(dress)`
og `highlight(dress)` på samme måde som vi gjorde for jakker i opgave 1 og 2.

**Opgave 4** Tilret jeres kode, så ikke-populære kjoler bliver nedtonet. I kan
bruge følgende skabelon:

```dart
    if (condition) {
      // do something, if condition is true
    } else {
      // do something else, if not
    }
```
`dim(x)` nedtoner knuden x i grafen.

Afprøv jeres kode på nogle eksempler.

### Rivaler
Her er noget kode, der fremhæver den første jakke-knudes rivaler:

```dart
highlightRivalsOfFirstSuit() {
  for (var dress in dressesAvailableFor(firstSuit)) {
    for (var suit in suitsAvailableFor(dress)) {
      if (suit != firstSuit) {
        highlight(suit);
      }
    }
  }
}
```
Læs og forstå koden med hjælp fra jeres vejleder. Prøv at køre den på nogle
eksempler.

`firstSuit` er den første jakke i grafen.  
`dressesAvailableFor(x)` er de kjoler, der kan danse med jakken x.  
`suitsAvailableFor(x)` er de jakker, der kan danse med kjolen x.  

**Opgave 5** Benyt skabelonen nedenfor til at fremhæve rivalerne til
`firstDress`, den første kjole i grafen:

```dart
highlightRivalsOfFirstDress() {
  // your code here
}
```
I kan kopiere koden øverst på siden og bytte om på rollerne.  
Afprøv jeres løsning.

### Maksimal parring

OK, lad os så finde en maksimal parring! Algoritmen fra tidligere på dagen ser
sådan ud i kode:

```dart
maxPairing() {
  while (canFindChain()) {
    invertChain();
  }
}
```
Det er jeres opgave at skrive en del af `canFindChain`:

```dart
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
  // your code instead of this:
  return replace_by_your_solution(suit);
}
```
Læs og forstå koden med hjælp fra jeres vejleder. Prøv også at køre koden på
nogle eksempler og klik gennem de enkelte graf-ændringer, den foretager.

(I tilfælde af, at I undrer jer over, hvordan vi opsamler og husker skiftevejen,
så vi kan vende den bagefter: Vi gør det bag om ryggen på jer, som en del af
søgningen. Det samme gælder markering af knuder, således at vi undgår at
behandle den samme knude mere end én gang. I opgave 7 skal I håndtere begge dele
selv.)

**Opgave 6** Skriv `canFindUnpairedDressFrom` selv, idet I genbruger strukturen
af `canFindChain`. Her er nogle brikker til puslespillet (I skal ikke bruge dem
alle sammen):

`isNotPaired(x)` er sand, hvis knuden x ikke er med i et dansepar lige nu.  
`dressesAvailableFor(x)` er de kjoler, der kan danse med jakken x.  
`suitsAvailableFor(x)` er de jakker, der kan danse med kjolen x.  
`dressPairedWith(x)` er den kjole, der lige nu er parret med jakken x.  
`suitPairedWith(x)` er den jakke, der lige nu er parret med kjolen x.

De sidste to virker kun, hvis x er med i et dansepar.

**Opgave 7** (til de meget hurtige) Få jeres vejleder til at fjerne
støttehjulene, så I selv skal håndtere opsamling af skiftevej og/eller markering
af behandlede knuder. Og skriv så `canFindUnpairedDressFrom` igen.

I får brug for følgende:

`chain(e)` tilføjer kanten e til skiftevejen.  
`edge(x,y)` er kanten mellem knuderne x og y (virker kun, hvis der findes en
sådan kant).  
`mark(x)` markerer knuden x som behandlet.  
`isNotMarked(x)` er sand, hvis knuden x er endnu ikke er markeret.  
