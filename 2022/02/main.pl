:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).

stream_lines(Fd, Lines) :-
   read_string(Fd, _, Str),
   split_string(Str, "\n", "", Lines).

to_rounds([], [], _).
to_rounds([""], [], _).
to_rounds([Str | Lines], [round(D, E) | Rounds], X) :-
   split_string(Str, " ", "", [DS, ES]),
   actionE(DS, D),
   actionP(ES, E, X, D),
   to_rounds(Lines, Rounds, X).
actionE("A", rock).
actionE("B", paper).
actionE("C", scissors).
% for task one
actionP("X", rock, 1, _).
actionP("Y", paper, 1, _).
actionP("Z", scissors, 1, _).
% for task two
% X means lose
actionP("X", scissors, 2, rock).
actionP("X", rock, 2, paper).
actionP("X", paper, 2, scissors).
% Y means draw
actionP("Y", A, 2, A).
% Z means win
actionP("Z", scissors, 2, paper).
actionP("Z", rock, 2, scissors).
actionP("Z", paper, 2, rock).

read_values(File, Rounds, X) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         stream_lines(Fd, Lines),
         to_rounds(Lines, Rounds, X)
      ),
      close(Fd)
   ).

score(rock, 1).
score(paper, 2).
score(scissors, 3).
score(round(A, A), E) :-
   score(A, V),
   E #= 3 + V.
score(round(rock, paper), E) :-
   score(paper, V),
   E #= V + 6.
score(round(rock, scissors), E) :-
   score(scissors, V),
   E #= V + 0.
score(round(paper, rock), E) :-
   score(rock, V),
   E #= V + 0.
score(round(paper, scissors), E) :-
   score(scissors, V),
   E #= V + 6.
score(round(scissors, rock), E) :-
   score(rock, V),
   E #= V + 6.
score(round(scissors, paper), E) :-
   score(paper, V),
   E #= V + 0.

task1(File, Total) :-
   read_values(File, Rounds, 1),
   maplist(score, Rounds, Scores),
   sum_list(Scores, Total).

task2(File, Total) :-
   read_values(File, Rounds, 2),
   maplist(score, Rounds, Scores),
   sum_list(Scores, Total).
