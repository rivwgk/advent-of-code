:- use_module(library(clpfd)).

stream_lines(Fd, Lines) :-
   read_string(Fd, _, Str),
   split_string(Str, "\n", "", Lines).

actions([], [""]) :-
   !.
actions([action(A, K) | XT], [S | ST]) :-
   split_string(S, " ", "", [A, N]),
   number_string(K, N),
   actions(XT, ST).

read_values(File, X) :-
   setup_call_cleanup(
      open(File, read, Fd, []),
      (
         stream_lines(Fd, Lines),
         actions(X, Lines)
      ),
      close(Fd)
   ).

task1([], IH, ID, H, D) :-
   IH #= H,
   ID #= D.
task1([action("forward", K) | T], IH, ID, H, D) :-
   Hn #= IH + K,
   Dn #= ID,
   task1(T, Hn, Dn, H, D).
task1([action("down", K) | T], IH, ID, H, D) :-
   Hn #= IH,
   Dn #= ID + K,
   task1(T, Hn, Dn, H, D).
task1([action("up", K) | T], IH, ID, H, D) :-
   Hn #= IH,
   Dn #= ID - K,
   task1(T, Hn, Dn, H, D).

task2([], IH, ID, IA, H, D, A) :-
   IH #= H,
   ID #= D,
   IA #= A.
task2([action("forward", K) | T], IH, ID, IA, H, D, A) :-
   Hn #= IH + K,
   Dn #= ID + K * IA,
   An #= IA,
   task2(T, Hn, Dn, An, H, D, A).
task2([action("down", K) | T], IH, ID, IA, H, D, A) :-
   Hn #= IH,
   Dn #= ID,
   An #= IA + K,
   task2(T, Hn, Dn, An, H, D, A).
task2([action("up", K) | T], IH, ID, IA, H, D, A) :-
   Hn #= IH,
   Dn #= ID,
   An #= IA - K,
   task2(T, Hn, Dn, An, H, D, A).

task1(X) :-
   read_values("input", As),
   task1(As, 0, 0, H, D),
   X #= H * D.

task2(X) :-
   read_values("input", As),
   task2(As, 0, 0, 0, H, D, _A),
   X #= H * D.
