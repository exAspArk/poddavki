%%%%%%%%%%% Glossary %%%%%%%%%%%%%%
% checkers - шашки (амер.)
% suicide checkers - поддавка (also anti-checkers, giveaway checkers)
% checker - шашка
% king - дамка
% computer - компьютер
% player - игрок
% figure - фигура в шашках

% координаты на доске
onboard(X, Y):-
  X > 0, X < 9, Y > 0, Y < 9. 
  
% клетка пуста
empty(X, Y):-
  not(computer_figure(X, Y)),
  not(player_figure(X, Y)),
  !.

% можно перейти на клетку (X, Y),
% если перейти на нее из (Cx1, Cy1), сместившись на 1 клетку в направлении (Dx, Dy)
next_cell(Cx1, Cy1, Dx, Dy, X, Y):-
  SDx is sign(Dx),                          % +1, если Dx > 0
  SDy is sign(Dy),                          % -1, если Dx < 0
  X is Cx1 + SDx,
  Y is Cy1 + SDy,
  onboard(X, Y),
  empty(X, Y).
next_cell(Cx1, Cy1, Dx, Dy, X, Y):-
  SDx is sign(Dx),
  SDy is sign(Dy),
  X1 is Cx1 + SDx,
  Y1 is Cy1 + SDy,
  onboard(X1, Y1),
  empty(X1, Y1),
  next_cell(X1, Y1, Dx, Dy, X, Y).

% сохраняем дамку в БД, если игрок дошел до верху шашкой
player_try_to_get_king(X2, 1):-
  not(player_king(X2, 1)),                  % если не дамка игрока
  asserta(player_king(X2, 1)).              % добавляем ее в начало БД
player_try_to_get_king(_, _).

% ход шашки игрока
player_checker_current(X1, Y1, X2, Y2):-
  Dx is X2 - X1, SDx is sign(Dx),          % +1, если разность положительна, черт, а упростить нельзя, я так понял?
  Dy is Y2 - Y1, SDy is sign(Dy),          % -1, если разность отрицательна
  X is X1 + SDx,                           % X = ++X1 (или --X1)
  Y is Y1 + SDy,                           % Y = ++Y1 (или --Y1)
  player_checker_current(X, Y, X2, Y2, 1).
                           
% ход шашки игрока ХЗ пока                                    
player_checker_current(X1, Y1, X2, Y2, 1):-
  not(X1 = X2),
  (computer_figure(X1, Y1);
player_figure(X1, Y1)),
  !.
player_checker_current(X1, Y1, X2, Y2, 1):-
  not(X1 = X2),
  Dx is X2 - X1, SDx is sign(Dx),          % +1, если разность положительна
  Dy is Y2 - Y1, SDy is sign(Dy),          % -1, если разность отрицательна
  X is X1 + SDx,                           % X = ++X1 (или --X1)
  Y is Y1 + SDy,                           % Y = ++Y1 (или --Y1)
  player_checker_current(X, Y, X2, Y2, 1).                 

% проверка на то, что шашка игрока должна есть фигуру
% из (X1, Y1) фигуру (Cx1, Cx2) перейдя в (X2, Y2)
player_checker_need_kill(X1, Y1, X2, Y2, Cx1, Cy1):-
  computer_figure(Cx1, Cy1),
  Dx is Cx1 - X1,
  Dy is Cy1 - Y1,
  T1 is abs(Dx), 
  T1 = 1,
  T2 is abs(Dy), 
  T2 = 1,
  X2 is Cx1 + Dx,
  Y2 is Cy1 + Dy,
  empty(X2, Y2),
  onboard(X2, Y2).

% съесть дамкой из (X1, Y1) фигуру (Cx1, Cy1) перейдя в (X2, Y2)
player_king_need_kill(X1, Y1, X2, Y2, Cx1, Cy1):-
  computer_figure(Cx1,Cy1),
  Dx is Cx1 - X1,
  Dy is Cy1 - Y1,
  T1 is abs(Dx),
  T2 is abs(Dy), 
  T2 = T1,
  not(player_checker_current(X1, Y1, Cx1, Cy1)), % если не ход шашки игрока
  next_cell(Cx1, Cy1, Dx, Dy, X2, Y2),
  onboard(X2, Y2).

% наличие шашки, которую надо бить
player_checker_can_kill(X, Y, Killed):-
  player_checker_need_kill(X, Y, _, _, Cx, Cy),
  not(is_member([Cx, Cy], Killed)),
  !.

% наличие дамки, которую надо бить
player_king_can_kill(X, Y, Killed):-
  player_king_need_kill(X, Y, _, _, Cx, Cy),
  not(is_member([Cx, Cy], Killed)),
  !.

% удаление всех съеденых фигур из БД
player_remove_all([]):-
  !.
player_remove_all([[X, Y] | T]):-
  retract(computer_figure(X, Y)),
  (retract(computer_king(X, Y)); !),
  player_remove_all(T).

% съедать шашкой пока не наестся
player_checker_can_continue(X2, Y2, X2, Y2, L):-
  not(player_checker_can_kill(X2, Y2, L)),
  player_remove_all(L),
  !.
player_checker_can_continue(X1, Y1, X2, Y2, Killed):-
  player_checker_need_kill(X1, Y1, Ex1, Ey1, Cx1, Cy1),
  not(is_member([Cx1, Cy1], Killed)),
  player_checker_can_continue(Ex1, Ey1, X2, Y2, [[Cx1, Cy1] | Killed]).

% съедать дамкой пока не наестся
player_king_can_kill(X2, Y2, X2, Y2, L):-
  not(player_king_can_kill(X2, Y2, L)),
  player_remove_all(L),
  !.
player_king_can_continue(X1,Y1,X2,Y2,Killed):-
  player_king_need_kill(X1, Y1, Ex1, Ey1, Cx1, Cy1),
  not(is_member([Cx1, Cy1], Killed)),
  player_king_can_continue(Ex1, Ey1, X2, Y2, [[Cx1, Cy1] | Killed]).

% у игрока есть ход шашкой из (X1, Y1) в (X2, Y2)
player_can_move(X1, Y1, X2, Y2):-
  player_figure(X1, Y1),
  not(player_king(X1, Y1)),
  player_checker_need_kill(X1, Y1, Ex1, Ey1, Cx1, Cy1),
  player_checker_can_continue(Ex1, Ey1, X2, Y2, [[Cx1, Cy1]]),
  retract(player_figure(X1, Y1)),
  asserta(player_figure(X2, Y2)),
  player_try_to_get_king(X2,Y2).
player_can_move(X1, Y1, X2, Y2):-
  player_figure(X1, Y1),
  not(player_king(X1, Y1)),
  not(player_need_to_kill),
  empty(X2, Y2),
  T1 is abs(X2 - X1), T1 = 1,
  T2 is Y2 - Y1, T2 = -1,
  onboard(X2, Y2),
  retract(player_figure(X1, Y1)),
  asserta(player_figure(X2, Y2)),
  player_try_to_get_king(X2,Y2).
player_can_move(X1, Y1, X2, Y2):-
  player_king(X1, Y1),
  player_king_need_kill(X1, Y1, Ex1, Ey1, Cx1, Cy1),
  player_king_can_continue(Ex1, Ey1, X2, Y2, [[Cx1, Cy1]]),
  retract(player_figure(X1, Y1)),
  asserta(player_figure(X2, Y2)),
  retract(player_king(X1, Y1)),
  asserta(player_king(X2, Y2)).
player_can_move(X1, Y1, X2, Y2):-
  player_king(X1, Y1),
  not(player_need_to_kill),
  empty(X2, Y2),
  T1 is abs(X2 - X1),
  T2 is abs(Y2 - Y1),
  T1 = T2,
  onboard(X2, Y2),
  retract(player_figure(X1, Y1)),
  asserta(player_figure(X2, Y2)),
  retract(player_king(X1, Y1)),
  asserta(player_king(X2, Y2)).

% игрок может съесть кого-нибудь
player_need_to_kill:-
  player_figure(X, Y),
  (player_checker_can_kill(X, Y, []); (player_king_can_kill(X, Y, []), player_king(X, Y))).

% компьютер может бить, ходя из (X1, Y1) в (X2, Y2), съедая (Cx1, Cy1) ШАШКА ХЗ
computer_need_kill(X1, Y1, X2, Y2, Cx1, Cy1):-
  player_figure(Cx1, Cy1),
  Dx is Cx1 - X1,
  Dy is Cy1 - Y1,
  T1 is abs(Dx), T1 = 1,	% проверка, находится ли вражеская шашка рядом
  T2 is abs(Dy), T2 = 1,
  X2 is Cx1 + Dx,			    % X2 вычисляется как смещение на Dx
  Y2 is Cy1 + Dy, 		    % Y2 вычисляется как смещение на Dy
  empty(X2, Y2),
  onboard(X2, Y2).

computer_checker_can_continue(X2, Y2, X2, Y2, L):-
  not(computer_checker_can_kill(X2, Y2, L)),
  computer_remove_all(L),
  !.
computer_checker_can_continue(X1, Y1,X2,Y2,Killed):-
  computer_need_kill(X1, Y1, Ex1, Ey1, Cx1, Cy1),
  not(is_member([Cx1, Cy1], Killed)),
  computer_checker_can_continue(Ex1, Ey1, X2, Y2, [[Cx1, Cy1] | Killed]).

computer_checker_can_kill(X, Y, Killed):-
  computer_need_kill(X, Y, _, _, Cx, Cy),
  not(is_member([Cx, Cy], Killed)),
  !.

% определение направлений ходов (Xr, Yr) для фигуры из (X, Y)
computer_can_go(X, Y, Xr, Yr):-     % шашка в 2х направлениях
  not(computer_king(X, Y)),
  Xr is X - 1,
  Yr is Y + 1.
computer_can_go(X, Y, Xr, Yr):-
  not(computer_king(X, Y)),
  Xr is X + 1,
  Yr is Y + 1.
computer_can_go(X, Y, Xr, Yr):-     % дамка в 4х направлениях
  computer_king(X, Y),
  Xr is X + 1,
  Yr is Y + 1.
computer_can_go(X, Y, Xr, Yr):-
  computer_king(X, Y),
  Xr is X + 1,
  Yr is Y - 1.
computer_can_go(X, Y, Xr, Yr):-
  computer_king(X, Y), 
  Xr is X - 1,
  Yr is Y + 1.
computer_can_go(X, Y, Xr, Yr):-
  computer_king(X, Y),
  Xr is X - 1,
  Yr is Y - 1.

% вычисление хода из (X1, Y1) в (X2, Y2) такого, что игроку придется съесть
computer_next_step_player_can_to_kill(X1, Y1, X2, Y2):-
  retract(computer_figure(X1, Y1)),
  asserta(computer_figure(X2, Y2)),
  player_need_to_kill,
  retract(computer_figure(X2, Y2)),
  asserta(computer_figure(X1, Y1)),
  !.
computer_next_step_player_can_to_kill(X1, Y1, X2, Y2):-
  retract(computer_figure(X2,Y2)),
  asserta(computer_figure(X1,Y1)),
  !,
  fail.

% сохраняем дамку в БД, если компьютер дошел до низа шашкой
computer_try_to_get_king(X2, 8):-
  not(computer_king(X2, 8)),
  asserta(computer_king(X2, 8)).
computer_try_to_get_king(_, _).

% съесть дамкой из (X1, Y1) фигуру (Cx1, Cy1) перейдя в (X2, Y2)
computer_king_need_kill(X1, Y1, X2, Y2, Cx1, Cy1):-
  player_figure(Cx1, Cy1),
  Dx is Cx1 - X1,
  Dy is Cy1 - Y1,
  T1 is abs(Dx),
  T2 is abs(Dy),
  T2 = T1,
  not(player_checker_current(X1, Y1, Cx1, Cy1)),
  next_cell(Cx1, Cy1, Dx, Dy, X2, Y2),
  onboard(X2, Y2).

% съедать дамкой пока не наестся
computer_king_can_continue(X2, Y2, X2, Y2, L):-
  not(computer_king_can_kill(X2, Y2, L)),
  computer_remove_all(L),
  !.
computer_king_can_continue(X1, Y1, X2, Y2, Killed):-
  computer_king_need_kill(X1, Y1, Ex1, Ey1, Cx1, Cy1),
  not(is_member([Cx1, Cy1], Killed)),
  computer_king_can_continue(Ex1, Ey1, X2, Y2, [[Cx1, Cy1] | Killed]).

% дамкой может съесть
computer_king_can_kill(X, Y, Killed):-
  computer_king_need_kill(X, Y, _, _, Cx, Cy),
  not(is_member([Cx, Cy], Killed)),
  !.

% шашка убивает
computer_move:-
  computer_figure(X1,Y1),		                % на (X1, Y1) шашка
  not(computer_king(X1,Y1)),
  computer_need_kill(X1, Y1, X2, Y2, Px1, Py1),
  computer_checker_can_continue(X2, Y2, Xr, Yr, [[Px1, Py1]]),
  retract(computer_figure(X1,Y1)),		      % удаление данных о предыдущем положении шашки компьютера
  asserta(computer_figure(Xr,Yr)),		      % запись данных о новом положении шашки компьютера
  computer_try_to_get_king(Xr,Yr),!.		  	% проверка на дамку

% дамка убивает
computer_move:-
  computer_king(X1,Y1),
  computer_king_need_kill(X1, Y1, X2, Y2, Px1, Py1),
  computer_king_can_continue(X2, Y2, Xr, Yr, [[Px1, Py1]]),
  retract(computer_figure(X1, Y1)),
  asserta(computer_figure(Xr, Yr)),
  retract(computer_king(X1, Y1)),
  asserta(computer_king(Xr, Yr)),
  !.

% дамка умно ходит
computer_move:-
  computer_king(X1, Y1),
  computer_can_go(X1, Y1, X21, Y21),
  next_cell(X1, Y1, X21, Y21, X2, Y2),
  empty(X2, Y2),
  onboard(X2, Y2),
  computer_next_step_player_can_to_kill(X1, Y1, X2, Y2),
  retract(computer_figure(X1, Y1)),
  asserta(computer_figure(X2, Y2)),
  retract(computer_king(X1, Y1)),
  asserta(computer_king(X2, Y2)),
!.
  
% шашка умно ходит
computer_move:-
  computer_figure(X1, Y1),
  not(computer_king(X1, Y1)),
  computer_can_go(X1, Y1, X2, Y2),
  empty(X2, Y2),
  onboard(X2, Y2),
  computer_next_step_player_can_to_kill(X1, Y1, X2, Y2),
  retract(computer_figure(X1, Y1)),
  asserta(computer_figure(X2, Y2)),
  computer_try_to_get_king(X2, Y2).
  
% фигура просто ходит, так как пока нету шанса, чтобы после хода компьютера игрок съел фигуру 
computer_move:-
  computer_figure(X1, Y1),
  computer_can_go(X1, Y1, X2, Y2),
  empty(X2, Y2),
  onboard(X2, Y2),
  retract(computer_figure(X1, Y1)),
  asserta(computer_figure(X2, Y2)),
  ((retract(computer_king(X1, Y1)), asserta(computer_king(X2, Y2))) ; !),
  computer_try_to_get_king(X2,Y2).

% удаление всех съеденых фигур из БД
computer_remove_all([]):-
  !.
computer_remove_all([[X, Y] | T]):-
  retract(player_figure(X, Y)),
  (retract(player_king(X, Y)) ; !),
  computer_remove_all(T).

% условия победы
computer_win:-
  not(computer_figure(_, _)).
player_win:-
  not(player_figure(_, _)).