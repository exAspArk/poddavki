%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Copyright © 2011 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
  
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! GLOSSARY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% checkers            - шашки (амер.)
% suicide checkers - поддавка (also anti-checkers, giveaway checkers)
% checker             - шашка
% king                  - дамка
% computer           - компьютер
% player               - игрок
% figure                - фигура в шашках(дамка/шашка)

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! START POSITIONS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
:- dynamic 
	computer_figure/2.
:- dynamic 
	player_figure/2.
:- dynamic 
	computer_king/2.	
:- dynamic 
	player_king/2.

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%

% координаты на доске
onboard(X, Y):-
   X > -1, X < 8, Y > -1, Y < 8.

% клетка пуста
empty(X, Y):-
	onboard(X, Y),
	not(computer_figure(X, Y)),
	not(player_figure(X, Y)),
	!.

% если можно перейти на клетку (X2, Y2) из (X1, Y1), сместившись на 1 клетку в направлении (Dx, Dy)
next_cell(X1, Y1, Dx, Dy, X2, Y2):-
	X2 = X1 + Dx,
	Y2 = Y1 + Dx,
	empty(X2, Y2).
	
next_cell(X1, Y1, Dx, Dy, X2, Y2):-
	X = X1 + Dx,
	Y = Y1 + Dy,
	empty(X, Y),
	next_cell(X, Y, Dx, Dy, X2, Y2).

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! PLAYER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%

% сохраняем дамку в БД, если игрок дошел до верху шашкой
player_try_to_get_king(0, Y2):-
	player_figure(0, Y2),
	not(player_king(0, Y2)),                    % если не дамка игрока
	asserta(player_king(0, Y2)).              % добавляем ее в начало БД
	
player_try_to_get_king(_, _).

% ход шашки игрока
player_checker_current(X1, Y1, X2, Y2):-
	Dx = X2 - X1,          % +1, если разность положительна
	Dy = Y2 - Y1,          % -1, если разность отрицательна
	X = X1 + Dx,                                 % X = ++X1 (или --X1)
	Y = Y1 + Dy,                                  % Y = ++Y1 (или --Y1)
	player_checker_current(X, Y, X2, Y2, 1).
														 
player_checker_current(X1, Y1, X2, Y2, 1):-
	not(X1 == X2),
	(computer_figure(X1, Y1) ; player_figure(X1, Y1)),
	!.
	
player_checker_current(X1, Y1, X2, Y2, 1):-
	not(X1 == X2),
	Dx = X2 - X1,          % +1, если разность положительна
	Dy = Y2 - Y1,          % -1, если разность отрицательна
	X = X1 + Dx,                                 % X = ++X1 (или --X1)
	Y = Y1 + Dy,                                  % Y = ++Y1 (или --Y1)
	player_checker_current(X, Y, X2, Y2, 1).                 

% проверка на то, что шашка игрока должна есть фигуру из (X1, Y1) фигуру (Gx, Gy) перейдя в (X2, Y2)
player_checker_need_kill(X1, Y1, X2, Y2, Gx, Gy):-
	computer_figure(Gx, Gy),		%Фигура игрока на Gx, Gy
	Dx = Gx - X1,					       %Считаем смещение
	Dy = Gy - Y1,
	T1 = abs(Dx), 
	T1 == 1,							%Проверяем, что расстояние по х...
	T2 = abs(Dy), 
	T2 == 1,							%и y == 1
	X2 = Gx + Dx,					%Определяем позицию, 
	Y2 = Gy + Dy,					%в которую должна попасть шашка после съедания
	empty(X2, Y2).					 %Удостоверяемся, что там пусто

% съесть дамкой из (X1, Y1) фигуру (Gx, Gy) перейдя в (X2, Y2)
player_king_need_kill(X1, Y1, X2, Y2, Gx, Gy):-
	computer_figure(Gx,Gy),
	Dx = Gx - X1,
	Dy = Gy - Y1,
	T1 = abs(Dx),
	T2 = abs(Dy), 
	T2 == T1,			                                         %Смещение для дамки(х == у)
	not(player_checker_current(X1, Y1, Gx, Gy)), % если не ход шашки игрока
	next_cell(Gx, Gy, Dx, Dy, X2, Y2),
	onboard(X2, Y2).

% наличие шашки, которой можно бить
player_checker_can_kill(X, Y, Killed):-
	player_checker_need_kill(X, Y, _, _, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	!.

% наличие дамки, которой можно бить
player_king_can_kill(X, Y, Killed):-
	player_king_need_kill(X, Y, _, _, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	!.

% удаление всех съеденых фигур из БД
player_remove_all([]):-
	!.
	
player_remove_all([[X, Y] | T]):-
	retract(computer_figure(X, Y)),
	(retract(computer_king(X, Y)) ; !),
	player_remove_all(T).

% съедать шашкой пока не наестся
player_checker_can_continue(X2, Y2, X2, Y2, L):-
	not(player_checker_can_kill(X2, Y2, L)),
	player_remove_all(L),
	!.
	
player_checker_can_continue(X1, Y1, X2, Y2, Killed):-
	player_checker_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	player_checker_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy] | Killed]).

% съедать дамкой пока не наестся
player_king_can_continue(X2, Y2, X2, Y2, L):-
	not(player_king_can_kill(X2, Y2, L)),
	player_remove_all(L),
	!.
	
player_king_can_continue(X1,Y1,X2,Y2,Killed):-
	player_king_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	player_king_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy] | Killed]).

% у игрока есть ход шашкой из (X1, Y1) в (X2, Y2)
player_move(X1, Y1, X2, Y2):-
	player_figure(X1, Y1),
	not(player_king(X1, Y1)),
	player_checker_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	player_checker_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy]]),
	retract(player_figure(X1, Y1)),
	asserta(player_figure(X2, Y2)),
	player_try_to_get_king(X2,Y2).

player_move(X1, Y1, X2, Y2):-
	player_figure(X1, Y1),
	not(player_king(X1, Y1)),
	not(player_need_to_kill),
	empty(X2, Y2),
	T1 = X2 - X1, 
	T1 == -1,
	T2 = abs(Y2 - Y1),
	T2 == 1,
	onboard(X2, Y2),
	retract(player_figure(X1, Y1)),
	asserta(player_figure(X2, Y2)),
	player_try_to_get_king(X2, Y2).

player_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1),
	player_king_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	player_king_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy]]),
	retract(player_figure(X1, Y1)),
	asserta(player_figure(X2, Y2)),
	retract(player_king(X1, Y1)),
	asserta(player_king(X2, Y2)).

% ход дамкой
player_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1),			  % Дамка
	not(player_need_to_kill),		% Не надо никого съедать
	empty(X2, Y2),					    % В клетке пусто
	T1 = abs(X2 - X1),		% Смещение по х
	T2 = abs(Y2 - Y1),	     % и у
	T1 == T2,						        % равное.
	onboard(X2, Y2),				    % Клетка на столе(опять же, кажется, что не там, где надо)
	retract(player_figure(X1, Y1)),	% Удалить данные о шашке
	asserta(player_figure(X2, Y2)),	% Записать данные о шашке 
	retract(player_king(X1, Y1)),	 % Удалить данные о дамке
	asserta(player_king(X2, Y2)).	% Записать данные о дамке

% игрок может съесть кого-нибудь
player_need_to_kill:-
	player_figure(X, Y),
	(player_checker_can_kill(X, Y, []) ; (player_king(X, Y), player_king_can_kill(X, Y, []))).
	
% определение направлений ходов (X2, Y2) для фигуры из (X1, Y1)
player_can_move(X1, Y1, X2, Y2):-     % шашка в 2х направлениях
	player_figure(X1, Y1),
	not(player_king(X1, Y1)),
	X2 = X1 - 1,
	Y2 = Y1 - 1.
player_can_move(X1, Y1, X2, Y2):-
	player_figure(X1, Y1),
	not(player_king(X1, Y1)),
	X2 = X1 - 1,
	Y2 = Y1 + 1.
player_can_move(X1, Y1, X2, Y2):-     % дамка в 4х направлениях 
	player_king(X1, Y1),
	X2 = X1 + 1,
	Y2 = Y1 + 1.
player_can_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1),
	X2 = X1 + 1,
	Y2 = Y1 - 1.
player_can_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1), 
	X2 = X1 - 1,
	Y2 = Y1 + 1.
player_can_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1),
	X2 = X1 - 1,
	Y2 = Y1 - 1.
	
player_try_move(X1, Y1):-
	player_figure(X1,Y1),
	not(player_king(X1,Y1)),
	player_checker_need_kill(X1, Y1, X2, Y2, Px1, Py1),
	!.
player_try_move(X1, Y1):-
	player_king(X1, Y1),
	player_king_need_kill(X1, Y1, X2, Y2, Px1, Py1).
	
%player_try_move(X1, Y1):-
%	player_figure(X1, Y1),
%	player_can_move(X1, Y1, X2, Y2),
%	empty(X2, Y2).	
	
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! AI !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
	
% компьютер может бить, ходя из (X1, Y1) в (X2, Y2), съедая (Gx, Gy)
computer_checker_need_kill(X1, Y1, X2, Y2, Gx, Gy):-
	player_figure(Gx, Gy),
	Dx = Gx - X1,
	Dy = Gy - Y1,
	T1 = abs(Dx), 
	T1 == 1,	   % проверка, находится ли вражеская шашка рядом
	T2 = abs(Dy), 
	T2 == 1,
	X2 = Gx + Dx,			    % X2 вычисляется как смещение на Dx
	Y2 = Gy + Dy, 		        % Y2 вычисляется как смещение на Dy
	empty(X2, Y2).

% съедать шашкой пока не наестся
computer_checker_can_continue(X2, Y2, X2, Y2, L):-
	not(computer_checker_can_kill(X2, Y2, L)),
	computer_remove_all(L),
	!.
	
computer_checker_can_continue(X1, Y1, X2, Y2, Killed):-
	computer_checker_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),							% проверка на то, что элемента Gx, Gy нет в списке убитых
	computer_checker_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy] | Killed]).

% шашке компьютера нужно бить
computer_checker_can_kill(X, Y, Killed):-
	computer_checker_need_kill(X, Y, _, _, Gx, Gy),		% определяем координаты шашки, которую нужно бить
	not(is_member([Gx, Gy], Killed)),			% проверяем, что она не находится в списке убитых
	!.

% определение направлений ходов (X2, Y2) для фигуры из (X1, Y1)
computer_can_move(X1, Y1, X2, Y2):-     % шашка в 2х направлениях
	computer_figure(X1, Y1),
	not(computer_king(X1, Y1)),
	X2 = X1 + 1,
	Y2 = Y1 - 1.
computer_can_move(X1, Y1, X2, Y2):-
	computer_figure(X1, Y1),
	not(computer_king(X1, Y1)),
	X2 = X1 + 1,
	Y2 = Y1 + 1.
computer_can_move(X1, Y1, X2, Y2):-     % дамка в 4х направлениях 
	computer_king(X1, Y1),
	X2 = X1 + 1,
	Y2 = Y1 + 1.
computer_can_move(X1, Y1, X2, Y2):-
	computer_king(X1, Y1),
	X2 = X1 + 1,
	Y2 = Y1 - 1.
computer_can_move(X1, Y1, X2, Y2):-
	computer_king(X1, Y1), 
	X2 = X1 - 1,
	Y2 = Y1 + 1.
computer_can_move(X1, Y1, X2, Y2):-
	computer_king(X1, Y1),
	X2 = X1 - 1,
	Y2 = Y1 - 1.

% вычисление хода из (X1, Y1) в (X2, Y2) такого, что игроку придется съесть
computer_next_step_player_can_to_kill(X1, Y1, X2, Y2):-
	retract(computer_figure(X1, Y1)),
	asserta(computer_figure(X2, Y2)),
	player_need_to_kill,
	retract(computer_figure(X2, Y2)),
	asserta(computer_figure(X1, Y1)),
	!.
	
computer_next_step_player_can_to_kill(X1, Y1, X2, Y2):-
	retract(computer_figure(X2, Y2)),
	asserta(computer_figure(X1, Y1)),
	!,
	fail.

% сохраняем дамку в БД, если компьютер дошел до низа шашкой
computer_try_to_get_king(7, Y2):-
	computer_figure(7, Y2),
	not(computer_king(7, Y2)),
	asserta(computer_king(7, Y2)).
computer_try_to_get_king(_, _).

% съесть дамкой из (X1, Y1) фигуру (Gx, Gy) перейдя в (X2, Y2)
computer_king_need_kill(X1, Y1, X2, Y2, Gx, Gy):-
	player_figure(Gx, Gy),
	Dx = Gx - X1,
	Dy = Gy - Y1,
	T1 = abs(Dx),
	T2 = abs(Dy),
	T2 == T1,
	not(player_checker_current(X1, Y1, Gx, Gy)),
	next_cell(Gx, Gy, Dx, Dy, X2, Y2),
	onboard(X2, Y2).

% съедать дамкой пока не наестся
computer_king_can_continue(X2, Y2, X2, Y2, L):-
	not(computer_king_can_kill(X2, Y2, L)),
	computer_remove_all(L),
	!.
	
computer_king_can_continue(X1, Y1, X2, Y2, Killed):-
	computer_king_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	computer_king_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy1] | Killed]).

% дамкой может съесть
computer_king_can_kill(X, Y, Killed):-
	computer_king_need_kill(X, Y, _, _, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	!.

computer_try_move(X1, Y1):-
	computer_figure(X1,Y1),
	not(computer_king(X1,Y1)),
	computer_checker_need_kill(X1, Y1, X2, Y2, Px1, Py1),
	!.
computer_try_move(X1, Y1):-
	computer_king(X1, Y1),
	computer_king_need_kill(X1, Y1, X2, Y2, Px1, Py1).

%computer_try_move(X1, Y1):-
%	computer_figure(X1, Y1),
%	computer_can_move(X1, Y1, X2, Y2),
%	empty(X2, Y2).
	
% шашка убивает
computer_move:-
	computer_figure(X1,Y1),		                % на (X1, Y1) шашка
	not(computer_king(X1,Y1)),
	computer_checker_need_kill(X1, Y1, X2, Y2, Px1, Py1),
	computer_checker_can_continue(X2, Y2, Xr, Yr, [[Px1, Py1]]),
	retract(computer_figure(X1,Y1)),		      % удаление данных о предыдущем положении шашки компьютера
	asserta(computer_figure(Xr,Yr)),		      % запись данных о новом положении шашки компьютера
	computer_try_to_get_king(Xr,Yr),			  % проверка на дамку
	!.		  	

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
	computer_can_move(X1, Y1, X21, Y21),
	empty(X2, Y2),        
	computer_next_step_player_can_to_kill(X1, Y1, X2, Y2),
	retract(computer_figure(X1, Y1)),
	asserta(computer_figure(X2, Y2)),
	retract(computer_king(X1, Y1)),
	asserta(computer_king(X2, Y2)),
	!.

% шашка ходит из X1 Y1 в X2 Y2
computer_move:-
	computer_figure(X1, Y1),			      % Фигура компьютера на Х1, У1
	not(computer_king(X1, Y1)),			    % Это не дамка
	computer_can_move(X1, Y1, X2, Y2),	% Проверка на ходы(для шашек x = y = 1, для дамок x = y)
	empty(X2, Y2),						           % Клетка X2, Y2 пуста
	computer_next_step_player_can_to_kill(X1, Y1, X2, Y2),
	retract(computer_figure(X1, Y1)),	   % Удаление данных о предущей позиции пешки
	asserta(computer_figure(X2, Y2)),	  % Запись новой позиции
	computer_try_to_get_king(X2, Y2).

% фигура просто ходит, так как пока нету шанса, чтобы после хода компьютера игрок съел фигуру 
computer_move:-
	computer_figure(X1, Y1),
	computer_can_move(X1, Y1, X2, Y2),
	empty(X2, Y2),
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
	not(computer_figure(_, _));
	(computer_figure(_, _), not(computer_try_move(_, _))).
player_win:-
	not(player_figure(_, _));
	(player_figure(_, _), not(player_try_move(_, _))).
