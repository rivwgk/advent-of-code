:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(dcg/basics)).
:- use_module(library(pio)).

ranges([], []) -->
   [].
ranges([range(A, B) | T1], [range(C, D) | T2]) -->
   integer(A),"-",integer(B),",",integer(C),"-",integer(D),eol,ranges(T1, T2).

compare1(range(A, B), range(C, D), X) :-
   X #<==> ((A #=< C #/\ D #=< B) #\/ (C #=< A #/\ B #=< D)).

compare2(range(A, B), range(C, D), X) :-
   X #<==> #\ (B #< C #\/ D #< A).

task1(File, X) :-
   phrase_from_file(ranges(R1, R2), File),
   maplist(compare1, R1, R2, B),
   sumlist(B, X).

task2(File, X) :-
   phrase_from_file(ranges(R1, R2), File),
   maplist(compare2, R1, R2, B),
   sumlist(B, X).
