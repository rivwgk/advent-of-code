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

sumdiffs(K, N, X, S) :-
   sumdiffs(K, N, X, S, 0).
sumdiffs(_K, [], _, S, S).
sumdiffs(1, [H | T], X, Dist, Tmp) :-
   NTmp #= abs(H - X) + Tmp,
   sumdiffs(1, T, X, Dist, NTmp).
sumdiffs(2, [H | T], X, Dist, Tmp) :-
   Dum #= abs(H - X),
   NTmp #= Tmp + ((Dum*(Dum+1)) div 2),
   sumdiffs(2, T, X, Dist, NTmp).

mindiff(K, N, Min) :-
   min_list(N, Inf),
   max_list(N, Sup),
   sumdiffs(K, N, Inf, CMin),
   mindiff(K, N, [Inf, Sup], Min, CMin).
mindiff(K, N, [Inf, Sup], Min, CMin) :-
   Inf #=< Sup,
   sumdiffs(K, N, Inf, PMin),
   NMin #= min(CMin, PMin),
   NInf #= Inf + 1,
   mindiff(K, N, [NInf, Sup], Min, NMin).
mindiff(_K, _N, [X, Y], Min, Min) :-
   X #> Y.

task1(File, Dist) :-
   read_values(File, N),
   mindiff(1, N, Dist).

task2(File, Dist) :-
   read_values(File, N),
   mindiff(2, N, Dist).
