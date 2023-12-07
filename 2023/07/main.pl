:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(dcg/basics)).

:- set_prolog_flag(double_quotes, chars).

read_file(File, Data) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         read_string(Fd, _, Data)
      ),
      close(Fd)
   ).

spaces -->
   " ".
spaces -->
   " ", spaces.

hist(L, H) :-
   sort(0, @=<, L, [ C | T ]),
   hist(T, [r(C,1)], H).
hist([], X, X).
hist([ C | T ], [ r(K,N) | RT ], H) :-
   (  C = K
   -> M #= N + 1,
      hist(T, [r(K, M) | RT], H)
   ;  hist(T, [r(C, 1), r(K,N) | RT], H)
   ).

hands([]) -->
   [].
hands([ H | T ]) -->
   string(C),spaces,integer(B),blanks,hands(T),
   { hist(C, Hist), H = hand(C, Hist, B) }.

type(hand(_, Hist, _), five_of_a_kind) :-
   member(r(_, 5), Hist), !.
type(hand(_, Hist, _), four_of_a_kind) :-
   member(r(_, 4), Hist), !.
type(hand(_, Hist, _), full_house) :-
   member(r(_, 3), Hist),
   member(r(_, 2), Hist), !.
type(hand(_, Hist, _), three_of_a_kind) :-
   member(r(_, 3), Hist),
   member(r(_, 1), Hist), !.
type(hand(_, Hist, _), two_pair) :-
   member(r(X, 2), Hist),
   member(r(Y, 2), Hist),
   X \= Y, !.
type(hand(_, Hist, _), one_pair) :-
   member(r(_, 2), Hist), !.
type(hand(_, Hist, _), high_card) :-
   is_set(Hist), !.

type2(hand(_, Hist, _), five_of_a_kind) :-
   member(r('J', N), Hist),
   member(r(A, M), Hist),
   A \= 'J',
   5 #= N + M, !.
type2(hand(_, Hist, _), four_of_a_kind) :-
   member(r('J', N), Hist),
   member(r(A, M), Hist),
   A \= 'J',
   4 #= N + M, !.
type2(hand(_, Hist, _), full_house) :-
   member(r('J', N), Hist),
   member(r(A, M), Hist),
   member(r(B, K), Hist),
   A \= B, A \= 'J', B \= 'J', N #= X + Y,
   X #>= 0, Y #>= 0,
   (  (3 #= X + M, 2 #= Y + K)
   ;  (2 #= X + M, 3 #= Y + K)
   ), !.
type2(hand(_, Hist, _), three_of_a_kind) :-
   member(r('J', N), Hist),
   member(r(A, M), Hist),
   A \= 'J',
   3 #= N + M, !.
type2(hand(_, Hist, _), two_pair) :-
   member(r('J', N), Hist),
   member(r(A, M), Hist),
   member(r(B, K), Hist),
   A \= B, A \= 'J', B \= 'J', N #= X + Y,
   X #>= 0, Y #>= 0,
   2 #= X + M, 2 #= Y + K, !.
type2(hand(_, Hist, _), one_pair) :-
   member(r('J', N), Hist),
   member(r(A, M), Hist),
   A \= 'J',
   2 #= N + M, !.
type2(hand(_, Hist, _), T) :-
   type(hand(_, Hist, _), T), !.

cmptype(five_of_a_kind, 6) :- !.
cmptype(four_of_a_kind, 5) :- !.
cmptype(full_house, 4) :- !.
cmptype(three_of_a_kind, 3) :- !.
cmptype(two_pair, 2) :- !.
cmptype(one_pair, 1) :- !.
cmptype(high_card, 0) :- !.

cmpcard('A', 14) :- !.
cmpcard('K', 13) :- !.
cmpcard('Q', 12) :- !.
cmpcard('J', 11) :- !.
cmpcard('T', 10) :- !.
cmpcard('9', 9) :- !.
cmpcard('8', 8) :- !.
cmpcard('7', 7) :- !.
cmpcard('6', 6) :- !.
cmpcard('5', 5) :- !.
cmpcard('4', 4) :- !.
cmpcard('3', 3) :- !.
cmpcard('2', 2) :- !.
cmpcard('1', 1) :- !.

gttype(X, Y) :-
   type(X,TX), type(Y,TY),
   cmptype(TX,A), cmptype(TY,B),
   A > B.
gtcard(X, Y) :-
   cmpcard(X,A), cmpcard(Y,B), A > B.

pair([], [], []).
pair([H1 | T1], [H2 | T2], [p(H1, H2) | TP]) :-
   pair(T1, T2, TP).

second([], []).
second([p(_, S) | T], [S | TS]) :-
   second(T, TS).

split([], X, X).
split([p(K,H) | T], [[p(N,H2) | T2] | T3], X) :-
   (  K = N
   -> split(T, [ [p(K,H), p(N,H2) | T2] | T3 ], X)
   ;  split(T, [ [p(K,H)], [p(N,H2) | T2] | T3 ], X)
   ).
split([p(N,H) | T], SSP) :-
   split(T, [[p(N, H)]], SSP).

cardsgt([],[]) :-
   !,fail.
cardsgt([H1 | T1], [H2 | T2]) :-
   (  gtcard(H1, H2)
   -> !,true
   ;  (  gtcard(H2, H1)
      -> !,fail
      ;  cardsgt(T1, T2)
      )
   ).
handgt(p(T1,hand(C1,_,_)), p(T2,hand(C2,_,_))) :-
   (  T1 #> T2
   -> !,true
   ;  (  T2 #> T1
      -> !,fail
      ;  cardsgt(C1, C2)
      )
   ).

maxhand([], H, H, []).
maxhand([H | T], LM, M, X) :-
   (  handgt(LM, H)
   -> maxhand(T, LM, M, Y),
      X = [H | Y]
   ;  maxhand(T, H, M, Y),
      X = [LM | Y]
   ).
maxhand([LM | L], M, LL) :-
   maxhand(L, LM, M, LL).

sortbycards([X], [X]).
sortbycards(L, [M | T]) :-
   maxhand(L, M, LL),!,
   sortbycards(LL, T).

rank(1, Hs, Rs) :-
   maplist(type, Hs, Ts),
   maplist(cmptype, Ts, Ns),
   pair(Ns, Hs, Ps),
   sort(1, @=<, Ps, SPs),!,
   split(SPs, SSPs),
   maplist(sortbycards, SSPs, Sorted),
   append(Sorted, Flattened),
   reverse(Flattened, Rs).

rank(2, Hs, Rs) :-
   maplist(type2, Hs, Ts),
   maplist(cmptype, Ts, Ns),
   maplist(unjoker, Hs, NHs),
   pair(Ns, NHs, Ps),
   sort(1, @=<, Ps, SPs),!,
   split(SPs, SSPs),
   maplist(sortbycards, SSPs, Sorted),
   append(Sorted, Flattened),
   reverse(Flattened, Rs).

jokertoone([], []).
jokertoone(['J' | T], ['1' | NT]) :-
   jokertoone(T, NT).
jokertoone([X | T], [X | NT]) :-
   jokertoone(T, NT).
unjoker(hand(C, H, B), hand(CH, H, B)) :-
   jokertoone(C, CH).

winnings(Rank, [hand(_,_,Bid)], [W]) :-
   W #= Rank * Bid.
winnings(Rank, [hand(_,_,Bid) | T], [W | WT]) :-
   W #= Rank * Bid,
   NRank #= Rank + 1,
   winnings(NRank, T, WT).

println(X) :-
   print(X),nl.

task1(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(hands(Hs), Cs),!,
   rank(1, Hs, Rs),
   maplist(println, Rs),
   second(Rs, S),
   winnings(1, S, Ws),
   sum_list(Ws, X).

task2(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(hands(Hs), Cs),!,
   rank(2, Hs, Rs),
   maplist(println, Rs),
   second(Rs, S),
   winnings(1, S, Ws),
   sum_list(Ws, X).
