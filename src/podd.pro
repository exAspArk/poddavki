% c - компьютер(computer)
% p - игрок(player)
% draught - шашка!!!!!
% computer_draught(X,Y) 
% computer_king(X,Y)
% player_draught(X,Y)
% player_king(X,Y)

onboard(X,Y):-
  X>0,X<9,
  Y>0,Y<9. 
  
% клетка пуста
empty(X,Y):-
  not(computer_draught(X,Y)),
  not(player_draught(X,Y)),!.

test_player_king(X2,1):-not(player_king(X2,1)),asserta(player_king(X2,1)).

test_player_king(_,_).

player_draught_present(X1,Y1,X2,Y2):-
  Dx is X2-X1, SDx is sign(Dx),
  Dy is Y2-Y1, SDy is sign(Dy),
  X is X1+SDx,
  Y is Y1+SDy,
  player_draught_present(X,Y,X2,Y2,1).
  
player_draught_present(X1,Y1,X2,Y2,1):-
  not(X1=X2),
  (computer_draught(X1,Y1);
   player_draught(X1,Y1)),!.
   
player_draught_present(X1,Y1,X2,Y2,1):-
  not(X1=X2),
  Dx is X2-X1, SDx is sign(Dx),
  Dy is Y2-Y1, SDy is sign(Dy),
  X is X1+SDx,
  Y is Y1+SDy,
  player_draught_present(X,Y,X2,Y2,1).

player_need_kill(X1,Y1,X2,Y2,Cx1,Cy1):-
  computer_draught(Cx1,Cy1),
  Dx is Cx1-X1,
  Dy is Cy1-Y1,
  T1 is abs(Dx),T1=1,
  T2 is abs(Dy),T2=1,
  X2 is Cx1+Dx,
  Y2 is Cy1+Dy,
  empty(X2,Y2),
  onboard(X2,Y2).

next_cell(Cx1,Cy1,Dx,Dy,X,Y):-
  SDx is sign(Dx),
  SDy is sign(Dy),
  X is Cx1+SDx,
  Y is Cy1+SDy,
  onboard(X,Y),
  empty(X,Y).
next_cell(Cx1,Cy1,Dx,Dy,X,Y):-
  SDx is sign(Dx),
  SDy is sign(Dy),
  X1 is Cx1+SDx,
  Y1 is Cy1+SDy,
  onboard(X1,Y1),
  empty(X1,Y1),
  next_cell(X1,Y1,Dx,Dy,X,Y).
  
player_need_kill_king(X1,Y1,X2,Y2,Cx1,Cy1):-
  computer_draught(Cx1,Cy1),
  Dx is Cx1-X1,
  Dy is Cy1-Y1,
  T1 is abs(Dx),
  T2 is abs(Dy),T2=T1,
  not(player_draught_present(X1,Y1,Cx1,Cy1)),
  next_cell(Cx1,Cy1,Dx,Dy,X2,Y2),
  onboard(X2,Y2).

% наличие шашки которую надо бить
player_one_to_kill(X,Y,Killed):-
  player_need_kill(X,Y,_,_,Cx,Cy),
  not(is_member([Cx,Cy],Killed)),!.

player_one_to_kill_king(X,Y,Killed):-
  player_need_kill_king(X,Y,_,_,Cx,Cy),
  not(is_member([Cx,Cy],Killed)),!.

player_remove_all([]):-!.
player_remove_all([[X,Y]|T]):-
  retract(computer_draught(X,Y)),
  (retract(computer_king(X,Y));!),
  player_remove_all(T).

player_can_continue(X2,Y2,X2,Y2,L):-
  not(player_one_to_kill(X2,Y2,L)),
  player_remove_all(L),!.
player_can_continue(X1,Y1,X2,Y2,Killed):-
  player_need_kill(X1,Y1,Ex1,Ey1,Cx1,Cy1),
  not(is_member([Cx1,Cy1],Killed)),
  player_can_continue(Ex1,Ey1,X2,Y2,[[Cx1,Cy1]|Killed]).

player_can_continue_king(X2,Y2,X2,Y2,L):-
  not(player_one_to_kill_king(X2,Y2,L)),
  player_remove_all(L),!.
player_can_continue_king(X1,Y1,X2,Y2,Killed):-
  player_need_kill_king(X1,Y1,Ex1,Ey1,Cx1,Cy1),
  not(is_member([Cx1,Cy1],Killed)),
  player_can_continue_king(Ex1,Ey1,X2,Y2,[[Cx1,Cy1]|Killed]).
  
player_can_move(X1,Y1,X2,Y2):-
  player_draught(X1,Y1),
  not(player_king(X1,Y1)),
  player_need_kill(X1,Y1,Ex1,Ey1,Cx1,Cy1),
  player_can_continue(Ex1,Ey1,X2,Y2,[[Cx1,Cy1]]),
  retract(player_draught(X1,Y1)),
  asserta(player_draught(X2,Y2)),
  test_player_king(X2,Y2).

player_can_move(X1,Y1,X2,Y2):-
  player_draught(X1,Y1),
  not(player_king(X1,Y1)),
  not(player_need_something_kill),
  empty(X2,Y2),
  T1 is abs(X2-X1),T1=1,
  T2 is Y2-Y1,T2= -1,
  onboard(X2,Y2),
  retract(player_draught(X1,Y1)),
  asserta(player_draught(X2,Y2)),
  test_player_king(X2,Y2).

player_can_move(X1,Y1,X2,Y2):-
  player_king(X1,Y1),
  player_need_kill_king(X1,Y1,Ex1,Ey1,Cx1,Cy1),
  player_can_continue_king(Ex1,Ey1,X2,Y2,[[Cx1,Cy1]]),
  retract(player_draught(X1,Y1)),
  asserta(player_draught(X2,Y2)),
  retract(player_king(X1,Y1)),
  asserta(player_king(X2,Y2)).

player_can_move(X1,Y1,X2,Y2):-
  player_king(X1,Y1),
  not(player_need_something_kill),
  empty(X2,Y2),
  T1 is abs(X2-X1),
  T2 is abs(Y2-Y1),T1=T2,
  onboard(X2,Y2),
  retract(player_draught(X1,Y1)),
  asserta(player_draught(X2,Y2)),
  retract(player_king(X1,Y1)),
  asserta(player_king(X2,Y2)).

player_need_something_kill:-
  player_draught(X,Y),
  (player_one_to_kill(X,Y,[]);
   (player_one_to_kill_king(X,Y,[]),
    player_king(X,Y))).

% может ли компьютер бить, ходя из X1 Y1 в X2 Y2, съедая Cx1, Cy1 !!! Может быть шашка
computer_need_kill(X1,Y1,X2,Y2,Cx1,Cy1):-
  player_draught(Cx1,Cy1),			%шашка игрока
  Dx is Cx1-X1,
  Dy is Cy1-Y1,
  T1 is abs(Dx),T1=1,	%проверка, находится ли вражеская шашка
  T2 is abs(Dy),T2=1,	%рядом с фигурой компьютера
  X2 is Cx1+Dx,			%X2 вычисляется как смещение на Dx
  Y2 is Cy1+Dy, 		%Y2
  empty(X2,Y2),			%проверяем, что X2, Y2 свободна
  onboard(X2,Y2).		%проверяем, что находится на поле

computer_can_continue(X2,Y2,X2,Y2,L):-
  not(computer_one_to_kill(X2,Y2,L)),
  computer_remove_all(L),!.
computer_can_continue(X1,Y1,X2,Y2,Killed):-
  computer_need_kill(X1,Y1,Ex1,Ey1,Cx1,Cy1),
  not(is_member([Cx1,Cy1],Killed)),
  computer_can_continue(Ex1,Ey1,X2,Y2,[[Cx1,Cy1]|Killed]).

computer_one_to_kill(X,Y,Killed):-
  computer_need_kill(X,Y,_,_,Cx,Cy),
  not(is_member([Cx,Cy],Killed)),!.

computer_can_go(X,Y,Xr,Yr):-not(computer_king(X,Y)),Xr is X-1,Yr is Y+1.
computer_can_go(X,Y,Xr,Yr):-not(computer_king(X,Y)),Xr is X+1,Yr is Y+1.
computer_can_go(X,Y,Xr,Yr):-computer_king(X,Y),Xr is X+1,Yr is Y+1.
computer_can_go(X,Y,Xr,Yr):-computer_king(X,Y),Xr is X+1,Yr is Y-1.
computer_can_go(X,Y,Xr,Yr):-computer_king(X,Y),Xr is X-1,Yr is Y+1.
computer_can_go(X,Y,Xr,Yr):-computer_king(X,Y),Xr is X-1,Yr is Y-1.

test_player_kill(X1,Y1,X2,Y2):-
  retract(computer_draught(X1,Y1)),
  asserta(computer_draught(X2,Y2)),
  player_need_something_kill,
  retract(computer_draught(X2,Y2)),
  asserta(computer_draught(X1,Y1)),!.
test_player_kill(X1,Y1,X2,Y2):-
  retract(computer_draught(X2,Y2)),
  asserta(computer_draught(X1,Y1)),
  !,fail.

% если компьютер доходит до низа и он не дамка - он становится дамкой
test_computer_king(X2,8):-not(computer_king(X2,8)),asserta(computer_king(X2,8)).
test_computer_king(_,_).

computer_need_kill_king(X1,Y1,X2,Y2,Cx1,Cy1):-
  player_draught(Cx1,Cy1),
  Dx is Cx1-X1,
  Dy is Cy1-Y1,
  T1 is abs(Dx),
  T2 is abs(Dy),T2=T1,
  not(player_draught_present(X1,Y1,Cx1,Cy1)),
  next_cell(Cx1,Cy1,Dx,Dy,X2,Y2),
  onboard(X2,Y2).

computer_can_continue_king(X2,Y2,X2,Y2,L):-
  not(computer_one_to_kill_king(X2,Y2,L)),
  computer_remove_all(L),!.
computer_can_continue_king(X1,Y1,X2,Y2,Killed):-
  computer_need_kill_king(X1,Y1,Ex1,Ey1,Cx1,Cy1),
  not(is_member([Cx1,Cy1],Killed)),
  computer_can_continue_king(Ex1,Ey1,X2,Y2,[[Cx1,Cy1]|Killed]).

computer_one_to_kill_king(X,Y,Killed):-
  computer_need_kill_king(X,Y,_,_,Cx,Cy),
  not(is_member([Cx,Cy],Killed)),!.

 %ход компьютера
 
% пешка убивает
computer_move:-
  computer_draught(X1,Y1),		%на х1 у1 шашка
  not(computer_king(X1,Y1)),	%на х1 у1 не дамка
  computer_need_kill(X1,Y1,X2,Y2,Px1,Py1),	%если компьютеру нужно бить ??
  computer_can_continue(X2,Y2,Xr,Yr,[[Px1,Py1]]), %
  retract(computer_draught(X1,Y1)),		%удаление данных о предыдущем положении пешки компьютера
  asserta(computer_draught(Xr,Yr)),		%запись данных о новом положении пешки компьютера
  test_computer_king(Xr,Yr),!.			% проверка на дамку

% дамка убивает
computer_move:-
  computer_king(X1,Y1),
  computer_need_kill_king(X1,Y1,X2,Y2,Px1,Py1),
  computer_can_continue_king(X2,Y2,Xr,Yr,[[Px1,Py1]]),
  retract(computer_draught(X1,Y1)),
  asserta(computer_draught(Xr,Yr)),
  retract(computer_king(X1,Y1)),
  asserta(computer_king(Xr,Yr)),!.

 % дамка ходит
computer_move:-
  computer_king(X1,Y1),
  computer_can_go(X1,Y1,X21,Y21),
  next_cell(X1,Y1,X21,Y21,X2,Y2),
  empty(X2,Y2),
  onboard(X2,Y2),
  test_player_kill(X1,Y1,X2,Y2),
  retract(computer_draught(X1,Y1)),
  asserta(computer_draught(X2,Y2)),
  retract(computer_king(X1,Y1)),
  asserta(computer_king(X2,Y2)),!.
  
 % шашка ходит
computer_move:-
  computer_draught(X1,Y1),
  not(computer_king(X1,Y1)),
  computer_can_go(X1,Y1,X2,Y2),
  empty(X2,Y2),
  onboard(X2,Y2),
  test_player_kill(X1,Y1,X2,Y2),
  retract(computer_draught(X1,Y1)),
  asserta(computer_draught(X2,Y2)),
  test_computer_king(X2,Y2).
  
computer_move:-
  computer_draught(X1,Y1),
%  not(computer_king(X1,Y1)),
  computer_can_go(X1,Y1,X2,Y2),
  empty(X2,Y2),
  onboard(X2,Y2),
  retract(computer_draught(X1,Y1)),
  asserta(computer_draught(X2,Y2)),
  ((retract(computer_king(X1,Y1)), asserta(computer_king(X2,Y2)));!),
  test_computer_king(X2,Y2).
/*computer_move:-
  computer_king(X1,Y1),
  computer_can_go(X1,Y1,X2,Y2),
  empty(X2,Y2),
  onboard(X2,Y2),
  retract(computer_draught(X1,Y1)),
  asserta(computer_draught(X2,Y2)),*/

computer_remove_all([]):-!.
computer_remove_all([[X,Y]|T]):-
  retract(player_draught(X,Y)),
  (retract(player_king(X,Y));!),
  computer_remove_all(T).

computer_win:-not(computer_draught(_,_)).
player_win:-not(player_draught(_,_)).