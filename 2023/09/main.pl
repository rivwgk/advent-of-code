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
   " ",spaces.

sinteger(X) -->
   "-",integer(Y),
   { X #= -Y }.
sinteger(X) -->
   integer(X).

integerlist([X | T]) -->
   sinteger(X),spaces,integerlist(T).
integerlist([X]) -->
   sinteger(X).

history([H | T]) -->
   integerlist(H),blanks,history(T).
history([]) -->
   [].

allzero([]).
allzero([0 | T]) :-
   allzero(T).

diff([_], []).
diff([X, Y | T], [Z | T2]) :-
   Z #= Y - X,
   diff([Y | T], T2).

diffs(L, Ds) :-
   diff(L, D),
   (  allzero(D)
   -> Ds = [L, D]
   ;  diffs(D, LDs),
      Ds = [L | LDs]
   ).

predict(Ds, F, P) :-
   maplist(reverse, Ds, RDs),
   predictfront(0, Ds, F),
   predictback(0, RDs, P).
predictfront(V, [], V).
predictfront(D, [[H | _] | TDs], P) :-
   D #= H - ND,
   predictfront(ND, TDs, P).
predictback(V, [], V).
predictback(D, [[H | _] | TDs], P) :-
   D #= ND - H,
   predictback(ND, TDs, P).


task1(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(history(H), Cs),
   maplist(diffs, H, Ds),
   maplist(reverse, Ds, RDs),!,
   maplist(predict, RDs, _, Ps),
   sum_list(Ps, X).

task2(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(history(H), Cs),
   maplist(diffs, H, Ds),
   maplist(reverse, Ds, RDs),
   maplist(predict, RDs, Ps, _),
   print(Ps),
   sum_list(Ps, X).
