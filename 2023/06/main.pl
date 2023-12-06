:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(dcg/basics)).

:- set_prolog_flag(double_quotes, chars).

read_file(File, Data) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         read_string(Fd, _, Data)
      ),
      close(Fd)
   ).


spaces -->
   " ".
spaces -->
   " ", spaces.

integerlist([X]) -->
   integer(X).
integerlist([X | T]) -->
   integer(X), spaces, integerlist(T).

integerspaced(I) -->
   digit(D0),
   digitsspaced(D),blanks,
   { number_codes(I, [D0|D]) }.
digitsspaced([D|T]) -->
   spaces,digit(D),!,digitsspaced(T) |
   digit(D),!,digitsspaced(T).
digitsspaced([]) -->
   [].

racetimes(RT) -->
   "Time:",spaces,integerlist(T),blanks,
   "Distance:",spaces,integerlist(D),blanks,
   { RT = races(T, D) }.

racetime(RT) -->
   "Time:",spaces,integerspaced(T),blanks,
   "Distance:",spaces,integerspaced(D),blanks,
   { RT = races([T], [D]) }.

bestduration(races([],[]), []).
bestduration(races([HT | TT], [_HD | TD]), [H | T]) :-
   H #= HT // 2,
   bestduration(races(TT, TD), T).

winningdurations(races([],[]), []).
winningdurations(races([HT | TT], [HD | TD]), [H | T]) :-
   L is ceil(HT / 2 - sqrt(HT*HT/4 - HD-1)),
   U is floor(HT / 2 + sqrt(HT*HT/4 - HD-1)),
   H is U - L + 1,
   winningdurations(races(TT, TD), T).

product([], 1).
product([H | T], P) :-
   product(T, F),
   P #= H * F.

dist(T, TT, D) :-
   D is T * (TT - T).

task1(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(racetimes(R), Cs),
   winningdurations(R, NDs),
   product(NDs, X).

task2(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(racetime(R), Cs),
   winningdurations(R, NDs),
   product(NDs, X).
