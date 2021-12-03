:- use_module(library(clpfd)).
:- use_module(library(apply)).

bin(L,N) :-
   length(L, N).

stream_lines(Fd, Lines) :-
   read_string(Fd, _, Str),
   split_string(Str, "\n", "", Lines).

bin_dec(bin(L,N), D) :-
   L ins 0..1,
   bin_dec(L, N, D).
bin_dec([], 0, 0).
bin_dec([H | T], N, D) :-
   D #= H * (2^(N-1)) + Dn,
   Nd #= N - 1,
   bin_dec(T, Nd, Dn).

pack([], []).
pack([H | T], [[H] | OT]) :-
   pack(T, OT).

string_to_bin(S, bin(L,Len)) :-
   string_chars(S, C),
   length(L,Len),
   pack(C, CPacked),
   maplist(number_chars, L, CPacked).

toggled(0, 1).
toggled(1, 0).
toggled(bin(L1,N), bin(L2,N)) :-
   maplist(toggled, L1, L2).

numbers([], [""]) :-
   !.
numbers([B | XT], [S | ST]) :-
   string_to_bin(S, B),
   numbers(XT, ST).

read_values(File, X) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         stream_lines(Fd, Lines),
         numbers(X, Lines)
      ),
      close(Fd)
   ).

inc_on_one(0, C, C).
inc_on_one(1, C, Cn) :-
   C #= Cn + 1.

geq(Y, X, B) :-
   X #>= Y #<==> B.

zeros([]).
zeros([0 | T]) :-
   zeros(T).
zeros(0, []).
zeros(N, [0|T]) :-
   M #= N - 1,
   zeros(M, T).

output_list([]) :-
   format("~n").
output_list([H|T]) :-
   format("~p ",[H]),
   output_list(T).

subtask1(Bs, Eps, Gamma) :-
   Bs = [bin(_, Len) | _],
   length(CList, Len),
   reduce(Bs, CList),
   length(DDigits, Len),
   D = bin(DDigits, Len),
   DDigits ins 0..1,
   length(Bs, N),
   HN #= N / 2,
   maplist(geq(HN), CList, DDigits),
   toggled(D, E),
   maplist(bin_dec, [D,E], [Eps,Gamma]).

reduce([], NList) :-
   zeros(NList).
reduce([bin(L1,Len) | T], CList) :-
   length(CList, Len),
   length(NList, Len),
   maplist(inc_on_one, L1, CList, NList),
   reduce(T, NList).

task1(File, X) :-
   read_values(File, Bs),
   subtask1(Bs, Eps, Gamma),
   X #= Eps * Gamma.

check_nthbit(N, K, bin(L, _)) :-
   nth0(N, L, B),
   K #= B.

oxy(Count, Len, K) :-
   2*Count #>= Len #<==> K.
co2(Count, Len, K) :-
   2*Count #< Len #<==> K.

filter_oxy([B], _, D) :-
   bin_dec(B, D).
filter_oxy(Bs, N, R) :-
   Bs = [bin(_, Len) | _],
   length(Bs, A),
   format("~p~n", [A]),
   length(CList, Len),
   reduce(Bs, CList),
   output_list(CList),
   nth0(N, CList, X),
   oxy(X, A, K),
   format("~p ~p~n", [X, K]),
   include(check_nthbit(N, K), Bs, NBs),
   M #= N + 1,
   filter_oxy(NBs, M, R).

filter_co2([B], _, D) :-
   bin_dec(B, D).
filter_co2(Bs, N, R) :-
   Bs = [bin(_, Len) | _],
   length(Bs, A),
   format("~p~n", [A]),
   length(CList, Len),
   reduce(Bs, CList),
   output_list(CList),
   nth0(N, CList, X),
   co2(X, A, K),
   format("~p ~p~n", [X, K]),
   include(check_nthbit(N, K), Bs, NBs),
   M #= N + 1,
   filter_co2(NBs, M, R).

task2(File, Z) :-
   read_values(File, Bs),
   filter_oxy(Bs, 0, X),
   filter_co2(Bs, 0, Y),
   Z #= X * Y.
