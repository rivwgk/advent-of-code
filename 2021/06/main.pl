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

evolve(0, Pop, Pop).
evolve(N, [T0,T1,T2,T3,T4,T5,T6,T7,T8], Res) :-
   M #= N - 1,
   NT0 #= T1,
   NT1 #= T2,
   NT2 #= T3,
   NT3 #= T4,
   NT4 #= T5,
   NT5 #= T6,
   NT6 #= T7 + T0,
   NT7 #= T8,
   NT8 #= T0,
   evolve(M, [NT0,NT1,NT2,NT3,NT4,NT5,NT6,NT7,NT8], Res).

eq_b(X, Y, B) :-
   X #= Y #<==> B.

collect(Pop, Ns) :-
   collect(Pop, Ns, 0).
collect([], _Ns, 9) :-
   !.
collect([P | T], Ns, M) :-
   maplist(eq_b(M), Ns, Bs),
   sum(Bs, #=, P),
   NM #= M + 1,
   collect(T, Ns, NM).

task(File, X, N) :-
   read_values(File, Fishes),
   collect(Pop, Fishes),
   evolve(N, Pop, X).

task1(File, Z) :-
   task(File, Z, 80).

task2(File, Z) :-
   task(File, Z, 256).
