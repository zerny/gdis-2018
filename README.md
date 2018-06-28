# Girls' Day in Science, 2018

This repository contains the code for the codelab for GDIS'18 hosted at Google
in Aarhus. The codelab instructions and user interface are currently available
in Danish only.

To try out the codelab, install Dart 2 (https://www.dartlang.org/) and use its
`webdev` tool to launch a web server:
```
$ cd gdis-2018
$ webdev serve
```
Then navigate your browser to localhost:8080. Make code changes to
`gdis-2018/lib/exercises.dart` to solve the exercises set below.

# Programmeringsopgaver

## Kræsne jakker

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

## Populære kjoler
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

## Rivaler
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

## Maksimal parring

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
