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

integerlist([X]) -->
   integer(X).
integerlist([X | T]) -->
   integer(X), spaces, integerlist(T).

rangelist([range(Dst, Src, Len)]) -->
   integer(Dst),spaces,integer(Src),spaces,integer(Len).
rangelist([range(Dst, Src, Len) | T]) -->
   integer(Dst),spaces,integer(Src),spaces,integer(Len),blanks,rangelist(T).

almanac_grammar(A) -->
   "seeds:",spaces,integerlist(Seeds),blanks,
   "seed-to-soil map:",blanks,rangelist(StoS),blanks,
   "soil-to-fertilizer map:",blanks,rangelist(StoF),blanks,
   "fertilizer-to-water map:",blanks,rangelist(FtoW),blanks,
   "water-to-light map:",blanks,rangelist(WtoL),blanks,
   "light-to-temperature map:",blanks,rangelist(LtoT),blanks,
   "temperature-to-humidity map:",blanks,rangelist(TtoH),blanks,
   "humidity-to-location map:",blanks,rangelist(HtoL),blanks,
   { A = almanac(Seeds, StoS, StoF, FtoW, WtoL, LtoT, TtoH, HtoL) }.

almanac_pass(almanac(_,StoS,StoF,FtoW,WtoL,LtoT,TtoH,HtoL),Seed,Location) :-
   range_pass(Seed, StoS, Soil),
   range_pass(Soil, StoF, Fertilizer),
   range_pass(Fertilizer, FtoW, Water),
   range_pass(Water, WtoL, Light),
   range_pass(Light, LtoT, Temperature),
   range_pass(Temperature, TtoH, Humidity),
   range_pass(Humidity, HtoL, Location).

range_pass(X, [], X).
range_pass(X, [range(D, S, L) | T], Y) :-
   (  (S #=< X #/\ X #< S + L)
   -> Y #= D + (X - S)
   ;  range_pass(X, T, Y)
   ).

listminimum([], LM, LM).
listminimum([H | T], LM, M) :-
   NM #= min(H, LM),
   listminimum(T, NM, M).
listminimum([H | T], M) :-
   listminimum(T, H, M).

almanac_pass_intervals(almanac(_,StoS,StoF,FtoW,WtoL,LtoT,TtoH,HtoL),Is,Ls) :-
   range_pass_interval(Is, StoS, Soils),
   merge_intervallists(Soils, [], MS),
   range_pass_intervals(MS, StoF, Fertilizers),
   merge_intervallists(Fertilizers, [], MF),
   range_pass_intervals(MF, FtoW, Waters),
   merge_intervallists(Waters, [], MW),
   range_pass_intervals(MW, WtoL, Lights),
   merge_intervallists(Lights, [], ML),
   range_pass_intervals(ML, LtoT, Temperatures),
   merge_intervallists(Temperatures, [], MT),
   range_pass_intervals(MT, TtoH, Humidities),
   merge_intervallists(Humidities, [], MH),
   range_pass_intervals(MH, HtoL, Locations),
   merge_intervallists(Locations, [], Ls).

range_pass_interval(interval(L, U), [], [interval(L, U)]).
range_pass_interval(interval(IL, IU), [range(D, S, L) | T], Ints) :-
   (  (IU #< S #\/ S + L-1 #< IL)
   -> % no intersection
      range_pass_interval(interval(IL, IU), T, Ints)
   ;  ( IL #< S
      -> ( S + L-1 #< IU
         -> % interval contains range (3 output intervals)
            OL1 #= IL,
            OU1 #= S - 1,
            OL2 #= D,
            OU2 #= D + L - 1,
            OL3 #= S + L,
            OU3 #= IU,
            Ints = [interval(OL1, OU1), interval(OL2, OU2), interval(OL3, OU3)]
         ;  % interval contains lower end point of range (2 output intervals)
            OL1 #= IL,
            OU1 #= S - 1,
            OL2 #= D,
            OU2 #= D + (IU - S),
            Ints = [interval(OL1, OU1), interval(OL2, OU2)]
         )
      ;  ( S + L-1 #< IU
         -> % interval contains upper end point of range (2 output intervals)
            OL1 #= D + IL - S,
            OU1 #= D + L-1,
            OL2 #= S + L,
            OU2 #= IU,
            Ints = [interval(OL1, OU1), interval(OL2, OU2)] 
         ;  % interval is contained in range (1 output interval)
            OL #= D + IL - S,
            OU #= D + IU - S,
            Ints = [interval(OL, OU)]
         )
      )
   ).

range_pass_intervals([I], Rs, Ints) :-
   range_pass_interval(I, Rs, Ints).
range_pass_intervals([I | IT], Rs, Ints) :-
   range_pass_interval(I, Rs, HInts),
   range_pass_intervals(IT, Rs, TInts),
   append(HInts, TInts, Ints).

merge_intervals([interval(L1,U1),interval(L2,U2)], Out) :-
   (  (U1 #< L2-1 #\/ U2 #< L1-1)
   -> % distance > 1
      Out = [interval(L1,U1), interval(L2,U2)]
   ;  (  L1 #=< L2-1
      -> (  U2 #=< U1-1
         -> Out = [interval(L1, U1)]
         ;  Out = [interval(L1, U2)]
         )
      ;  (  U2 #=< U1-1
         -> Out = [interval(L2, U1)]
         ;  Out = [interval(L2, U2)]
         )
      )
   ).
merge_intervals(interval(L,U), [], [interval(L,U)]).
merge_intervals(interval(L,U), [H | T], Out) :-
   merge_intervals([interval(L,U), H], Try),
   length(Try, Len),
   (  Len #= 1
   -> [X] = Try,
      Out = [X | T]
   ;  merge_intervals(interval(L,U), T, X),
      Out = [H | X]
   ).
merge_intervallists([], M, M).
merge_intervallists([H | T], Storage, Out) :-
   merge_intervals(H, T, Try),
   length([H | T], OLen),
   length(Try, Len),
   (  OLen #= Len
   -> merge_intervallists(T, [H | Storage], Out)
   ;  merge_intervallists(Try, Storage, Out)
   ).

task1(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(almanac_grammar(A), Cs),
   A = almanac(S,_,_,_,_,_,_,_),
   maplist(almanac_pass(A), S, Ls),
   listminimum(Ls, X).

intervals([], []).
intervals([S, L | T], [interval(S, U) | IT]) :-
   U #= S + L - 1,
   intervals(T, IT).

intervallistminimum([], LM, LM).
intervallistminimum([interval(H,_) | T], LM, M) :-
   NM #= min(H, LM),
   intervallistminimum(T, NM, M).
intervallistminimum([interval(H,_) | T], M) :-
   intervallistminimum(T, H, M).

task2(File, X) :-
   read_file(File, L),
   string_chars(L, Cs),
   phrase(almanac_grammar(A), Cs),
   A = almanac(Ints,_,_,_,_,_,_,_),
   intervals(Ints, Is),
   maplist(almanac_pass_intervals(A), Is, OInts),
   append(OInts, RInts),
   intervallistminimum(RInts, X). 
