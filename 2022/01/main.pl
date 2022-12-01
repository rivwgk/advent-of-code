:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).

stream_lines(Fd, Lines) :-
   read_string(Fd, _, Str),
   split_string(Str, "\n", "", Lines).

elf_packing([], []).
elf_packing([[] | Elves], ["" | Lines]) :-
   elf_packing(Elves, Lines).
elf_packing([[H | T] | Elves], [Str | Lines]) :-
   number_string(H, Str),
   elf_packing([T | Elves], Lines).

read_values(File, Elves) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         stream_lines(Fd, Lines),
         elf_packing(Elves, Lines)
      ),
      close(Fd)
   ).

sum([], []).
sum([S | T], [[EH] | Elves]) :-
   S #= EH,
   sum(T, Elves).
sum([S | T], [[EH | ET] | Elves]) :-
   sum([O | T], [ET | Elves]),
   S #= O + EH.

task1(File, Max) :-
   read_values(File, Elves),
   sum(SElves, Elves),
   max_member(@=<, Max, SElves).

task2(File, [M1, M2, M3]) :-
   read_values(File, Elves),
   sum(SElves, Elves),
   max_member(@=<, M1, SElves),
   select(M1, SElves, SElves2),
   max_member(@=<, M2, SElves2),
   select(M2, SElves2, SElves3),
   max_member(@=<, M3, SElves3).
