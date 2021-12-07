:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).

stream_lines(Fd, Lines) :-
   read_string(Fd, _, Str),
   split_string(Str, "\n", "", Lines).

read_values(File, X) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         stream_lines(Fd, [Str | _]),
         split_string(Str, ",", "", Nums),
         maplist(number_string, X, Nums)
      ),
      close(Fd)
   ).

eq_b(X, Y, B) :-
   X #= Y #<==> B.

subtask(N, Min, Dist) :-
   subtask(N, Min, Dist, 0).
subtask([], _, Dist, Dist).
subtask([H | T], Min, Dist, Tmp) :-
   NTmp #= abs(Min - H) + Tmp,
   subtask(T, Min, Dist, NTmp).

task(File, [Min, Dist]) :-
   read_values(File, N),
   min_list(N, Inf),
   max_list(N, Sup),
   length(N, Len),
   SupDist #= (Sup - Inf)*Len,
   Min in Inf..Sup,
   Dist in 0..SupDist,
   labeling([min(Dist)],[Dist,Min]),
   subtask(N, Min, Dist).

task1(File, Z) :-
   task(File, Z, 80).

task2(File, Z) :-
   task(File, Z, 256).
