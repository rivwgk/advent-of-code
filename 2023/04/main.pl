:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(dcg/basics)).

read_values(File, Data) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         read_string(Fd, _, Data)
      ),
      close(Fd)
   ).

spaces -->
   [' '].
spaces -->
   [' '], spaces.

integerlist([X]) -->
   integer(X).
integerlist([X | T]) -->
   integer(X), spaces, integerlist(T).

scratchcard(G) -->
   ['C','a','r','d'], spaces, integer(Id), [':'], spaces,
   integerlist(WNs), spaces, ['|'], spaces, integerlist(Ns),
   { G = card(Id, WNs, Ns) }.
scratchcardlist([G]) -->
   scratchcard(G), blanks.
scratchcardlist([G | T]) -->
   scratchcard(G), blanks, scratchcardlist(T).

winningnums(card(_, _, []), []).
winningnums(card(_, WNs, [H | T]), X) :-
   (  member(H, WNs)
   -> X = [H | XT],
      winningnums(card(_, WNs, T), XT)
   ;  winningnums(card(_, WNs, T), X)
   ). 

points(0, 0).
points(E, P) :-
   P #= 2 ^ (E - 1).

task1(File, X) :-
   read_values(File, L),
   string_chars(L, Cs),
   phrase(scratchcardlist(Gs), Cs),
   maplist(winningnums, Gs, WNs),
   maplist(length, WNs, Exps),
   maplist(points, Exps, Pts),
   sumlist(Pts, X).

ones([], 0).
ones([1 | T], N) :-
   M #= N - 1,
   ones(T, M).

newcards(0, _, X, X).
newcards(Times, N, [HL | TL], [HR | TR]) :-
   NTimes #= Times - 1,
   HR #= HL + N,
   newcards(NTimes, N, TL, TR).

getcards([], [], []).
getcards([M | T], [HCur | TCur], [HCur | TAll]) :-
   newcards(M, HCur, TCur, Res),
   getcards(T, Res, TAll).

task2(File, X) :-
   read_values(File, L),
   string_chars(L, Cs),
   phrase(scratchcardlist(Gs), Cs),
   maplist(winningnums, Gs, WNs),
   maplist(length, WNs, Mults),
   length(Gs, NCards),
   ones(Init, NCards),
   getcards(Mults, Init, TCs),
   sumlist(TCs, X).
