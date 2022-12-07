:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).

stream_lines(Fd, Lines) :-
   read_string(Fd, _, Str),
   split_string(Str, "\n", "", Lines).

read_values(File, L) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         stream_lines(Fd, [L | _])
      ),
      close(Fd)
   ).

sop(L, 4) :-
   length(P, 4),
   prefix(P, L),
   is_set(P).
sop(L, N) :-
   L = [_ | T],
   sop(T, M),
   N #= M + 1.
som(L, 14) :-
   length(P, 14),
   prefix(P, L),
   is_set(P).
som(L, N) :-
   L = [_ | T],
   som(T, M),
   N #= M + 1.

task1(File, X) :-
   read_values(File, L),
   string_chars(L, Cs),
   sop(Cs, X).

task2(File, X) :-
   read_values(File, L),
   string_chars(L, Cs),
   som(Cs, X).
