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
   " ",spaces.

letter(L) -->
   [L],
   { code_type(L, alnum) }.

pos(P) -->
   letter(X),letter(Y),letter(Z),
   { P = [X,Y,Z] }.

chart([ C | T ]) -->
   pos(P),spaces,"=",spaces,"(",pos(L),",",spaces,pos(R),")",blanks,chart(T),
   { C = path(P, p(L,R)) }.
chart([]) -->
   [].

map(A) -->
   string_without("\n",I),blanks,chart(C),
   { A = atlas(I, C) }.

pair(L, R, p(L, R)).
first(p(X,_), X).
second(p(_,X), X).
pathfirst(path(X,_), X).

findpath(Chart, P, L, R) :-
   member(path(P, p(L,R)), Chart).

traverse([_,_,'Z'], _, atlas(_,_), 0).
traverse(P, [], atlas(I, Chart), N) :-
   traverse(P, I, atlas(I, Chart), N).
traverse(P, ['L' | T], atlas(I, Chart), N) :-
   findpath(Chart, P, L, _),
   N #= M + 1,
   traverse(L, T, atlas(I, Chart), M).
traverse(P, ['R' | T], atlas(I, Chart), N) :-
   findpath(Chart, P, _, R),
   N #= M + 1,
   traverse(R , T, atlas(I, Chart), M).
traverse(atlas(Instr, Chart), Start, N) :-
   traverse(Start, Instr, atlas(Instr, Chart), N).

startpoint(path([_,_,'A'], p(_,_))).

lcm([X], X).
lcm([X, Y], Z) :-
   gcd(X, Y, T),
   Z #= X * Y // T.
lcm([X, Y | T], Z) :-
   gcd(X, Y, D),
   F #= X * Y // D,
   lcm(T, G),
   lcm([F, G], Z).

gcd(A, 0, A).
gcd(A, B, C) :-
   (  A #> B
   -> D #= (A mod B),
      gcd(B, D, C)
   ;  D #= (B mod A),
      gcd(A, D, C)
   ).
gcd([X], X).
gcd([X, Y], Z) :-
   gcd(X, Y, Z).
gcd([X, Y | T], Z) :-
   gcd(X, Y, F),
   gcd([F | T], Z).

product([F], F).
product([H | T], P) :-
   product(T, F),
   P #= H * F.

traverse2(atlas(Instr, Chart), N) :-
   include(startpoint, Chart, Starts),
   maplist(pathfirst, Starts, Points),
   maplist(traverse(atlas(Instr, Chart)), Points, N).

task1(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(map(A), Cs),
   traverse(A, "AAA", X).

task2(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(map(A), Cs),
   traverse2(A, Ns),
   lcm(Ns, X).
