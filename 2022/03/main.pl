:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).

stream_lines(Fd, Lines) :-
   read_string(Fd, _, Str),
   split_string(Str, "\n", "", Lines).

split(Str, N, rucksack(A, B)) :-
   string_codes(Str, L),
   split(L, N, A, B).
split(B, 0, [], B).
split([H | T], N, [H | A], B) :-
   V #= N - 1,
   split(T, V, A, B).

rucksacks([], []).
rucksacks(["" | T], RT) :-
   rucksacks(T, RT).
rucksacks([Str | T], [rucksack(A, B) | RT]) :-
   string_length(Str, N),
   NHalf #= N // 2,
   split(Str, NHalf, rucksack(A, B)),
   rucksacks(T, RT). 

read_values(File, Rucksacks) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         stream_lines(Fd, Lines),
         rucksacks(Lines, Rucksacks)
      ),
      close(Fd)
   ).

priority([], []).
priority([X | XT], [V | VT]) :-
   97 #=< X, X #=< 122,
   V #= 1 + X - 97,
   priority(XT, VT).
priority([X | XT], [V | VT]) :-
   65 #=< X, X #=< 90,
   V #= 27 + X - 65,
   priority(XT, VT).

intersection(rucksack(A, B), D) :-
   intersection(A, B, C),
   list_to_set(C, D).

intersection(rucksack(A1, B1), rucksack(A2, B2), rucksack(A3, B3), D) :-
   union(A1, B1, C1),
   union(A2, B2, C2),
   union(A3, B3, C3),
   intersection(C1, C2, T1),
   intersection(T1, C3, T2),
   list_to_set(T2, D).

three_split([], [], [], []).
three_split([A, B, C | T], [A | T1], [B | T2], [C | T3]) :-
   three_split(T, T1, T2, T3).

task1(File, Total) :-
   read_values(File, Rucksacks),
   maplist(intersection, Rucksacks, Intersections),
   maplist(priority, Intersections, Priorities),
   maplist(sum_list, Priorities, Sums),
   sum_list(Sums, Total).

task2(File, Total) :-
   read_values(File, Rucksacks),
   three_split(Rucksacks, R1, R2, R3),
   maplist(intersection, R1, R2, R3, Intersections),
   maplist(priority, Intersections, Priorities),
   maplist(sum_list, Priorities, Sums),
   sum_list(Sums, Total).
