:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).

stream_lines(Fd, Lines) :-
   read_string(Fd, _, Str),
   split_string(Str, "\n", "", Lines).

ranges([], [], []).
ranges([""], [], []).
ranges([Str | T], [range(A, B) | T1], [range(C, D) | T2]) :-
   split_string(Str, ",", "", [X, Y]),
   split_string(X, "-", "", [SA, SB]),
   split_string(Y, "-", "", [SC, SD]),
   maplist(number_string, [A, B, C, D], [SA, SB, SC, SD]),
   ranges(T, T1, T2).

read_values(File, [R1, R2]) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         stream_lines(Fd, Lines),
         ranges(Lines, R1, R2)
      ),
      close(Fd)
   ).

compare1(range(A, B), range(C, D), X) :-
   X #<==> ((A #=< C #/\ D #=< B) #\/ (C #=< A #/\ B #=< D)).

compare2(range(A, B), range(C, D), X) :-
   X #<==> #\ (B #< C #\/ D #< A).

task1(File, X) :-
   read_values(File, [R1, R2]),
   maplist(compare1, R1, R2, B),
   sumlist(B, X).

task2(File, X) :-
   read_values(File, [R1, R2]),
   maplist(compare2, R1, R2, B),
   sumlist(B, X).
