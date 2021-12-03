:- use_module(library(clpfd)).

stream_lines(Fd, Lines) :-
   read_string(Fd, _, Str),
   split_string(Str, "\n", "", Lines).

numbers([_], [""]) :-
   !.
numbers([X | XT], [S | ST]) :-
   number_string(X, S),
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

task(0, []).
task(0, [_]).
task(0, [H1, H2]) :-
   H1 #>= H2, !.
task(1, [H1, H2]) :-
   H1 #< H2, !.
task(N, [H1, H2 | T]) :-
   H1 #< H2,
   task(M, [H2 | T]),
   N #= M + 1.
task(N, [H1, H2 | T]) :-
   H1 #>= H2,
   task(N, [H2 | T]).

task1(File, N) :-
   read_values(File, X),
   task(N, X).

window3([L], [H1, H2, H3]) :-
   L #= H1 + H2 + H3, !.
window3([L | LT], [H1, H2, H3 | T]) :-
   L #= H1 + H2 + H3,
   window3(LT, [H2, H3 | T]).

task2(File, N) :-
   read_values(File, X),
   window3(Fold, X),
   task(N, Fold).
