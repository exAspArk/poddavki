%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Copyright © 2011 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
  
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! GLOSSARY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% checkers              - шашки (амер.)
% suicide checkers      - поддавка (also anti-checkers, giveaway checkers)
% computer              - компьютер
% player                - игрок
% checker               - шашка
% king                  - дамка

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
:- dynamic 
	computer_checker/2.
:- dynamic 
	player_checker/2.
:- dynamic 
	computer_king/2.	
:- dynamic 
	player_king/2.
:- dynamic
	is_member/2.
	
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! START POSITIONS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%

computer_checker(3,2).
computer_checker(3,6).
computer_checker(0,7).
player_king(5,0).

/*
computer_checker(0,1).
computer_checker(0,3).
computer_checker(0,5).
computer_checker(0,7).
computer_checker(1,0).
computer_checker(1,2).
computer_checker(1,4).
computer_checker(1,6).
computer_checker(2,1).
computer_checker(2,3).
computer_checker(2,5).
computer_checker(2,7).

player_checker(5,0).
player_checker(5,2).
player_checker(5,4).
player_checker(5,6).
player_checker(6,1).
player_checker(6,3).
player_checker(6,5).
player_checker(6,7).
player_checker(7,0).
player_checker(7,2).
player_checker(7,4).
player_checker(7,6).

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Test #1 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
computer_checker(2,1).
computer_checker(3,2).
computer_checker(1,4).
player_checker(4,3).
player_checker(5,4).
test:-
    computer_move,
    computer_checker(3,0),
    computer_checker(3,2),
    computer_checker(1,4),
    player_checker(4,3),
    player_checker(5,4).

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Test #2 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
computer_checker(1,6).
player_checker(1,2).
test:-
    player_move(1,2,0,3),
    not(player_checker(0,3)),
    player_king(0,3),
    not(player_win).

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Test #3 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
computer_checker(3,2).
computer_checker(3,6).
computer_checker(0,7).
player_king(5,0).
test:-
    player_move(5,0,4,7),
    empty(3,2),
    empty(3,6),
    empty(5,0),
    player_king(4,7).
    computer_checker(0,7).

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Test #4 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
player_checker(3,4).
player_checker(1,0).
player_checker(2,1).
player_checker(6,3).
computer_king(1,6).
test:-
    computer_move,
    empty(3,4),
    empty(6,3),
    player_checker(1,0),
    player_checker(2,1),
    empty(1,6),
    computer_king(7,4).

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Test #5 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
computer_checker(0,3).
computer_checker(2,1).
computer_checker(2,5).
computer_checker(3,4).  
player_checker(7,4).
test:-
    computer_move,
    computer_checker(0,3),
    computer_checker(2,1),
    computer_checker(2,5),
    computer_checker(4,3), 
    empty(3,4),
    player_checker(7,4).
   
*/
    
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% клетка пуста
empty(X, Y):-
	onboard(X, Y),
	not(computer_checker(X, Y)),
	not(player_checker(X, Y)),
	not(computer_king(X, Y)),
	not(player_king(X, Y)),
	!.

% координаты на доске
onboard(X, Y):-
   X > -1, X < 8, Y > -1, Y < 8.

% проверка, есть ли элемент X в большом списке []
is_member(X, [X | List]).
is_member(X, [Element | List]):-
	is_member(X, List).	
	
% получение длины списка
get_len_list([], N):-
    N is 0.
get_len_list([_ | List], N):-
    get_len_list(List, N1),
    N is N1 + 1.
    
% получение первого элемента списка
first_element(X, [X | _]).

% получение второго элемента списка  
second_element(X, [First | [Second | List]]):-
    X is Second.

% получение последнего элемента в списке
last([X], X).
last([_ | Tail], Elem) :- 
    last(Tail, Elem).

% удаление последнего элемента из списка
remove_last([X], []) :- 
    !.
remove_last([Head | Tail], [Head | S]) :-
    remove_last(Tail, S).

% получение предпоследнего элемента
penultimate(X, List) :-
    remove_last(List, New),
    last(New, X).

% добавление элемента в начало списка
add(X, List, [X | List]).

copy(List, List).

all_clear(X1, Y1, Sx1, Sy1, Gx, Gy) :-
	X is X1 + Sx1,
	Y is Y1 + Sy1,
	((X = Gx) ; (empty(X, Y), all_clear(X, Y, Sx1, Sy1, Gx, Gy))).
	
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! PLAYER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% сохраняем дамку в БД, если игрок дошел до верху шашкой
player_try_to_get_king(0, Y2):-
	player_checker(0, Y2),
	retract(player_checker(0, Y2)),		    % удаляем шашку
	assert(player_king(0, Y2)).             % добавляем дамку
	
player_try_to_get_king(_, _).

% проверка на то, что шашка игрока должна есть фигуру из (X1, Y1) фигуру (Gx, Gy) перейдя в (X2, Y2)
player_checker_need_kill(X1, Y1, X2, Y2, Gx, Gy):-
	(computer_checker(Gx, Gy) ; computer_king(Gx, Gy)),		% шашка компьютера на Gx, Gy
	Dx is Gx - X1,					% считаем смещение
	Dy is Gy - Y1,
	T1 is abs(Dx), 
	T1 = 1,						    % проверяем, что расстояние по х...
	T2 is abs(Dy), 
	T2 = 1,						    % и y == 1
	X2 is Gx + Dx,					% определяем позицию, 
	Y2 is Gy + Dy,					% в которую должна попасть шашка после съедания
	empty(X2, Y2).					% удостоверяемся, что там пусто

player_figure_in(Killed):-
    (computer_checker(Gx, Gy) ; computer_king(Gx, Gy)),
    is_member([Gx, Gy], Killed).

% съесть дамкой из (X1, Y1) перейдя в (X2, Y2) фигуру (Gx, Gy), 
% где Killed - список уже убитых (чтобы не убивать их снова), From - список, где была дамка (чтобы не возвращаться)
player_king_need_kill(X1, Y1, X2, Y2, Gx, Gy, Killed, From, Remove):-
	(computer_checker(Gx, Gy) ; computer_king(Gx, Gy)),     % фигура компьютера на Gx, Gy
    Dx is Gx - X1,
    Dy is Gy - Y1,
    T1 is abs(Dx),
    T2 is abs(Dy),
    T1 = T2,			            % смещение для дамки(х == у)
    Sx1 is sign(Dx),                % стороны смещения в направлении фигуры, которую надо съесть
    Sy1 is sign(Dy),
    add([X1, Y1], From, FromNew),	
	all_clear(X1, Y1, Sx1, Sy1, Gx, Gy),
	player_king_next_cell(Sx1, Sy1, X2, Y2, Gx, Gy, Killed, FromNew, Remove), 
    !.	
	
% определение вдоль направления (Sx1, Sy1) следующей клетки (X2, Y2), куда может ступить дамка после съедения фигуры (Gx, Gy)
player_king_next_cell(Sx1, Sy1, X2, Y2, Gx, Gy, Killed, From, Remove):-
	X is Gx + Sx1,					% определяем позицию, 
	Y is Gy + Sy1,					% в которую должна попасть шашка после съедания
	not(is_member([X, Y], From)),	
	empty(X, Y),					% удостоверяемся, что там пусто
    (
        (                           % элемент, который можно съесть
            (computer_checker(Gx, Gy) ; computer_king(Gx, Gy)), 
            copy(From, FromNew),
            add([Gx, Gy], Killed, KilledNew)
        ) ; 
        (                           % куда можно шагнуть
            copy(Killed, KilledNew), 
            add([Gx, Gy], From, FromNew)
        )
    ),
	(
	    (                           % шагнуть дальше, если нельзя съесть
            player_king_can_kill(X, Y, X2, Y2, KilledNew, FromNew, Remove) ; player_king_next_cell(Sx1, Sy1, X2, Y2, X, Y, KilledNew, FromNew, Remove)
    	) ;
    	(                           % если некуда шагать, конец
        	player_figure_in(KilledNew),
        	X2 is X,
        	Y2 is Y,
			((Remove = 1, player_remove_all(KilledNew)) ; !)
    	)
	), 
	!.

% наличие дамки, которой можно бить
player_king_can_kill(X, Y, X2, Y2, Killed, From, Remove):-
    (computer_checker(Gx, Gy) ; computer_king(Gx, Gy)),
    not(is_member([Gx, Gy], Killed)),    
	player_king_need_kill(X, Y, X1, Y1, Gx, Gy, Killed, From, Remove),
	X2 is X1,
	Y2 is Y1,
	!.	
	
% наличие шашки, которой можно бить
player_checker_can_kill(X, Y, Killed):-
	player_checker_need_kill(X, Y, _, _, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	!.

% удаление всех съеденых фигур из БД
player_remove_all([]):-
	!.
	
player_remove_all([[X, Y] | T]):-
	(retract(computer_checker(X, Y)) ; retract(computer_king(X, Y))),
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

% у игрока есть ход шашкой из (X1, Y1) в (X2, Y2)
player_move(X1, Y1, X2, Y2):-
	player_checker(X1, Y1),
	player_checker_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	player_checker_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy]]),
	retract(player_checker(X1, Y1)),
	assert(player_checker(X2, Y2)),
	player_try_to_get_king(X2,Y2), !.

player_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1),
	player_king_need_kill(X1, Y1, X3, Y3, Gx, Gy, [], [], 0),
	
	write(X1), write(Y1), nl,
	write(X2), write(Y2), nl,
	write(X3), write(Y3), nl,
	
	X2 = X3,
	Y2 = Y3,

	write(need), nl,
	retract(player_king(X1, Y1)),
	assert(player_king(X2, Y2)),
	player_king_need_kill(X1, Y1, X2, X2, Gx, Gy, [], [], 1),
	
	write(after), nl,
	

	!.

player_move(X1, Y1, X2, Y2):-
	player_checker(X1, Y1),
	not(player_need_kill),
	empty(X2, Y2),
	T1 is X2 - X1, 
	T1 = -1,
	T2 is abs(Y2 - Y1),
	T2 = 1,
	retract(player_checker(X1, Y1)),
	assert(player_checker(X2, Y2)),
	player_try_to_get_king(X2, Y2), !.	
	
% ход дамкой
player_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1),			    % дамка
	not(player_need_kill),		        % не надо никого съедать	
	Dx is X2 - X1,
    Dy is Y2 - Y1,
    Sx1 is sign(Dx),                	% стороны смещения в направлении фигуры, которую надо съесть
    Sy1 is sign(Dy),
	all_clear(X1, Y1, Sx1, Sy1, X2, Y2),
	empty(X2, Y2),					    % в клетке пусто
	T1 is abs(X2 - X1),		            % cмещение по х
	T2 is abs(Y2 - Y1),	                % и у
	T1 = T2,						    % равное
	retract(player_king(X1, Y1)),	    % Удалить данные о дамке
	assert(player_king(X2, Y2)).	    % Записать данные о дамке	
	
/*
player_move(5,0,4,1).
player_move(5,0,4,7).

player_king_need_kill(5,0, 4, 7, Gx, Gy, [], [], 1).

computer_checker(X,Y).

computer_checker(3,2).
computer_checker(3,6).
computer_checker(0,7).

*/	
	
% игрок может съесть кого-нибудь
player_need_kill:-
	((
	    player_checker(X, Y), 
	    player_checker_can_kill(X, Y, [])
	) ; 
    (
        player_king(X, Y), 
        player_king_can_kill(X, Y, _, _, [], [], 0)
    )), !.
	
% определение направлений ходов (X2, Y2) для фигуры из (X1, Y1)
player_can_move(X1, Y1, X2, Y2):-     % шашка в 2х направлениях
	player_checker(X1, Y1),
	X2 is X1 - 1,
	Y2 is Y1 - 1.
player_can_move(X1, Y1, X2, Y2):-
	player_checker(X1, Y1),
	X2 is X1 - 1,
	Y2 is Y1 + 1.
player_can_move(X1, Y1, X2, Y2):-     % дамка в 4х направлениях 
	player_king(X1, Y1),
	X2 is X1 + 1,
	Y2 is Y1 + 1.
player_can_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1),
	X2 is X1 + 1,
	Y2 is Y1 - 1.
player_can_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1), 
	X2 is X1 - 1,
	Y2 is Y1 + 1.
player_can_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1),
	X2 is X1 - 1,
	Y2 is Y1 - 1.
	
player_try_move(X1, Y1):-
	player_checker(X1,Y1),
	player_checker_need_kill(X1, Y1, X2, Y2, Px1, Py1),
	!.
player_try_move(X1, Y1):-
	player_king(X1, Y1),
	player_king_need_kill(X1, Y1, X2, Y2, Px1, Py1, [], [], 0),
	!.
player_try_move(X1, Y1):-
	(player_checker(X1, Y1) ; player_king(X1, Y1)),
	player_can_move(X1, Y1, X2, Y2),
	empty(X2, Y2).	

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! AI !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% компьютер может бить, ходя из (X1, Y1) в (X2, Y2), съедая (Gx, Gy)
computer_checker_need_kill(X1, Y1, X2, Y2, Gx, Gy):-
	(player_checker(Gx, Gy) ; player_king(Gx, Gy)),
	Dx is Gx - X1,
	Dy is Gy - Y1,
	T1 is abs(Dx), 
	T1 = 1,	                    % проверка, находится ли вражеская шашка рядом
	T2 is abs(Dy), 
	T2 = 1,
	X2 is Gx + Dx,			    % X2 вычисляется как смещение на Dx
	Y2 is Gy + Dy, 		        % Y2 вычисляется как смещение на Dy
	empty(X2, Y2).

% съедать шашкой пока не наестся
computer_checker_can_continue(X2, Y2, X2, Y2, L):-
	not(computer_checker_can_kill(X2, Y2, L)),
	computer_remove_all(L),
	!.
	
computer_checker_can_continue(X1, Y1, X2, Y2, Killed):-
	computer_checker_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),					% проверка на то, что элемента Gx, Gy нет в списке убитых
	computer_checker_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy] | Killed]).

% шашке компьютера нужно бить
computer_checker_can_kill(X, Y, Killed):-
	computer_checker_need_kill(X, Y, _, _, Gx, Gy),		% определяем координаты шашки, которую нужно бить
	not(is_member([Gx, Gy], Killed)),			        % проверяем, что она не находится в списке убитых
	!.

% определение направлений ходов (X2, Y2) для фигуры из (X1, Y1)
computer_can_move(X1, Y1, X2, Y2):-     % шашка в 2х направлениях
	computer_checker(X1, Y1),
	X2 is X1 + 1,
	Y2 is Y1 - 1.
computer_can_move(X1, Y1, X2, Y2):-
	computer_checker(X1, Y1),
	X2 is X1 + 1,
	Y2 is Y1 + 1.
computer_can_move(X1, Y1, X2, Y2):-     % дамка в 4х направлениях 
	computer_king(X1, Y1),
	X2 is X1 + 1,
	Y2 is Y1 + 1.
computer_can_move(X1, Y1, X2, Y2):-
	computer_king(X1, Y1),
	X2 is X1 + 1,
	Y2 is Y1 - 1.
computer_can_move(X1, Y1, X2, Y2):-
	computer_king(X1, Y1), 
	X2 is X1 - 1,
	Y2 is Y1 + 1.
computer_can_move(X1, Y1, X2, Y2):-
	computer_king(X1, Y1),
	X2 is X1 - 1,
	Y2 is Y1 - 1.

% вычисление хода шашкой из (X1, Y1) в (X2, Y2) такого, что игроку придется съесть
computer_checker_next_step_player_can_kill(X1, Y1, X2, Y2):-
	retract(computer_checker(X1, Y1)),
	assert(computer_checker(X2, Y2)),
	player_need_kill,	
	!.
	
computer_checker_next_step_player_can_kill(X1, Y1, X2, Y2):-
	retract(computer_checker(X2, Y2)),
	assert(computer_checker(X1, Y1)),
	!, fail.

computer_king_next_step_player_can_kill(X1, Y1, X2, Y2, N) :- 
	computer_king(X1, Y1),
	X2 is X1 + N,
	Y2 is Y1 + N,
	all_clear(X1, Y1, 1, 1, X2, Y2),
	empty(X2, Y2), 
	retract(computer_king(X1, Y1)),
	assert(computer_king(X2, Y2)),
	(player_need_kill ; (retract(computer_king(X2, Y2)), assert(computer_king(X1, Y1)), fail)),
	!.
computer_king_next_step_player_can_kill(X1, Y1, X2, Y2, N):-
	computer_king(X1, Y1),
	X2 is X1 + N,
	Y2 is Y1 - N,
	all_clear(X1, Y1, 1, -1, X2, Y2),
	empty(X2, Y2),
	retract(computer_king(X1, Y1)),
	assert(computer_king(X2, Y2)),
	(player_need_kill ; (retract(computer_king(X2, Y2)), assert(computer_king(X1, Y1)), fail)),
	!.
computer_king_next_step_player_can_kill(X1, Y1, X2, Y2, N):-
	computer_king(X1, Y1), 
	X2 is X1 - N,
	Y2 is Y1 + N,
	all_clear(X1, Y1, -1, 1, X2, Y2),
	empty(X2, Y2), 
	retract(computer_king(X1, Y1)),
	assert(computer_king(X2, Y2)),
	(player_need_kill ; (retract(computer_king(X2, Y2)), assert(computer_king(X1, Y1)), fail)),
	!.
computer_king_next_step_player_can_kill(X1, Y1, X2, Y2, N):-
	computer_king(X1, Y1),
	X2 is X1 - N,
	Y2 is Y1 - N,	
	all_clear(X1, Y1, -1, -1, X2, Y2),
	empty(X2, Y2), 
	retract(computer_king(X1, Y1)),
	assert(computer_king(X2, Y2)),
	(player_need_kill ; (retract(computer_king(X2, Y2)), assert(computer_king(X1, Y1)), fail)),
	!.
computer_king_next_step_player_can_kill(X1, Y1, X2, Y2, N):-
	N1 is N + 1,
	N1 < 8,
	computer_king_next_step_player_can_kill(X1, Y1, X2, Y2, N1).

% сохраняем дамку в БД, если компьютер дошел до низа шашкой
computer_try_to_get_king(7, Y2):-
	computer_checker(7, Y2),
	retract(computer_checker(7, Y2)),
	assert(computer_king(7, Y2)).
computer_try_to_get_king(_, _).

computer_try_move(X1, Y1):-
	computer_checker(X1,Y1),
	computer_checker_need_kill(X1, Y1, X2, Y2, Px1, Py1),
	!.
computer_try_move(X1, Y1):-
	computer_king(X1, Y1),
	computer_king_need_kill(X1, Y1, X2, Y2, Px1, Py1, [], [], 0),
	!.
computer_try_move(X1, Y1):-
	(computer_checker(X1, Y1) ; computer_king(X1, Y1)),
	computer_can_move(X1, Y1, X2, Y2),
	empty(X2, Y2).
	
computer_figure_in(Killed):-
    (player_checker(Gx, Gy) ; player_king(Gx, Gy)),
    is_member([Gx, Gy], Killed).
		
% съесть дамкой из (X1, Y1) перейдя в (X2, Y2) фигуру (Gx, Gy), 
% где Killed - список уже убитых (чтобы не убивать их снова), From - список, где была дамка (чтобы не возвращаться)
computer_king_need_kill(X1, Y1, X2, Y2, Gx, Gy, Killed, From, Remove):-
	(player_checker(Gx, Gy) ; player_king(Gx, Gy)),     % фигура компьютера на Gx, Gy
    Dx is Gx - X1,
    Dy is Gy - Y1,
    T1 is abs(Dx),
    T2 is abs(Dy),
    T1 = T2,			            % смещение для дамки(х == у)
    Sx1 is sign(Dx),                % стороны смещения в направлении фигуры, которую надо съесть
    Sy1 is sign(Dy),
    add([X1, Y1], From, FromNew),
	all_clear(X1, Y1, Sx1, Sy1, Gx, Gy),
    computer_king_next_cell(Sx1, Sy1, X2, Y2, Gx, Gy, Killed, FromNew, Remove), 
    !.

% определение вдоль направления (Sx1, Sy1) следующей клетки (X2, Y2), куда может ступить дамка после съедения фигуры (Gx, Gy)
computer_king_next_cell(Sx1, Sy1, X2, Y2, Gx, Gy, Killed, From, Remove):-
	X is Gx + Sx1,					% определяем позицию, 
	Y is Gy + Sy1,					% в которую должна попасть шашка после съедания
	not(is_member([X, Y], From)),	
	empty(X, Y),					% удостоверяемся, что там пусто
    (
        (                           % элемент, который можно съесть
            (player_checker(Gx, Gy) ; player_king(Gx, Gy)), 
            copy(From, FromNew),
            add([Gx, Gy], Killed, KilledNew)
        ) ; 
        (                           % куда можно шагнуть
            copy(Killed, KilledNew), 
            add([Gx, Gy], From, FromNew)
        )
    ),
	(
	    (                           % шагнуть дальше, если нельзя съесть
            computer_king_can_kill(X, Y, X2, Y2, KilledNew, FromNew, Remove) ; computer_king_next_cell(Sx1, Sy1, X2, Y2, X, Y, KilledNew, FromNew, Remove)
    	) ;
    	(                           % если некуда шагать, конец
        	computer_figure_in(KilledNew),
        	X2 is X,
        	Y2 is Y,
        	((Remove = 1, computer_remove_all(KilledNew)) ; !)
    	)
	), !.

% наличие дамки, которой можно бить
computer_king_can_kill(X, Y, X2, Y2, Killed, From, Remove):-
    (player_checker(Gx, Gy) ; player_king(Gx, Gy)),
    not(is_member([Gx, Gy], Killed)),    
	computer_king_need_kill(X, Y, X1, Y1, Gx, Gy, Killed, From, Remove),
	X2 is X1,
	Y2 is Y1,
	!.	
	
% шашка убивает
computer_move:-
	computer_checker(X1,Y1),		                % на (X1, Y1) шашка
	computer_checker_need_kill(X1, Y1, X2, Y2, Px1, Py1),
	computer_checker_can_continue(X2, Y2, Xr, Yr, [[Px1, Py1]]),
	retract(computer_checker(X1,Y1)),		        % удаление данных о предыдущем положении шашки компьютера
	assert(computer_checker(Xr,Yr)),		        % запись данных о новом положении шашки компьютера
	computer_try_to_get_king(Xr,Yr),			    % проверка на дамку
	!.		  	

% дамка убивает
computer_move:-
	computer_king(X1,Y1),
	computer_king_need_kill(X1, Y1, X2, Y2, Gx, Gy, [], [], 1),
	retract(computer_king(X1, Y1)),
	assert(computer_king(X2, Y2)),
	!.

% дамка умно ходит
computer_move:-
	computer_king(X1, Y1),    
	computer_king_next_step_player_can_kill(X1, Y1, X2, Y2, 1),
	!.

% шашка ходит из X1 Y1 в X2 Y2
computer_move:-
	computer_checker(X1, Y1),			    % шашка компьютера на Х1, У1
	computer_can_move(X1, Y1, X2, Y2),	    % проверка на ходы(для шашек x is y is 1, для дамок x is y)
	empty(X2, Y2),						    % клетка X2, Y2 пуста
	computer_checker_next_step_player_can_kill(X1, Y1, X2, Y2),
	computer_try_to_get_king(X2, Y2), 
	!.

% шашка просто ходит, так как пока нету шанса, чтобы после хода компьютера игрок съел фигуру 
computer_move:-
    computer_checker_smart_go_first(6, Y, X2, Y2),
	retract(computer_checker(X, Y)),
	assert(computer_checker(X2, Y2)),
	computer_try_to_get_king(X2,Y2),
	!.
	
% шашка просто ходит, так как пока нету шанса, чтобы после хода компьютера игрок съел фигуру 
computer_move:-
	computer_checker(X1, Y1),
	computer_can_move(X1, Y1, X2, Y2),
	empty(X2, Y2),
	retract(computer_checker(X1, Y1)),
	assert(computer_checker(X2, Y2)),
	computer_try_to_get_king(X2, Y2),
	!.

% дамка просто ходит, так как пока нету шанса, чтобы после хода компьютера игрок съел фигуру 
computer_move:-
	computer_king(X1, Y1),
	computer_can_move(X1, Y1, X2, Y2),
	Dx is X2 - X1,
    Dy is Y2 - Y1,
    Sx1 is sign(Dx),                	% стороны смещения в направлении фигуры, которую надо съесть
    Sy1 is sign(Dy),
	all_clear(X1, Y1, Sx1, Sy1, X2, Y2),
	empty(X2, Y2),
	retract(computer_king(X1, Y1)),
	assert(computer_king(X2, Y2)).

% приоритет ходьбы у первого фронта пешек компьютера, чтобы занять как можно больше территории, если промежуток до вражеской безопасен (> 2)
computer_checker_smart_go_first(X, Y, X2, Y2):-
    (
        (
			computer_checker(X, Y), 
			computer_can_move(X, Y, X2, Y2),
			empty(X2, Y2),
			not(player_next_step(X2, Y2))
		) ;
    	(X1 is X - 1, X1 >= 0, computer_checker_smart_go_first(X1, Y, X2, Y2))
    ), !.

player_next_step(X, Y):-
	(player_checker(X2,Y2) ; player_king(X2,Y2)),
	player_can_move(X2, Y2, Nx, Ny),
	D1 is X - Nx,
	D2 is Y - Ny,
	T1 is abs(D1),
	T2 is abs(D2),
	T1 = 1,
	T2 = 1.
	
% удаление всех съеденых фигур из БД
computer_remove_all([]):-
	!.
	
computer_remove_all([[X, Y] | T]):-
	(retract(player_checker(X, Y)) ; retract(player_king(X, Y))),
	computer_remove_all(T).

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WIN !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% условия победы
computer_win:-
	(not(computer_checker(_, _)), not(computer_king(_, _)));
	((computer_checker(_, _) ; computer_king(_, _)), not(computer_try_move(_, _))).
player_win:-
    (not(player_checker(_, _)), not(player_king(_, _)));
    ((player_checker(_, _) ; player_king(_, _)), not(player_try_move(_, _))).
