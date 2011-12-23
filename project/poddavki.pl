%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Copyright � 2011 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
  
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! GLOSSARY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% checkers            - ����� (����.)
% suicide checkers - �������� (also anti-checkers, giveaway checkers)
% checker             - �����
% king                  - �����
% computer           - ���������
% player               - �����
% figure                - ������ � ������(�����/�����)

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

% ���������� �� �����
onboard(X, Y):-
   X > -1, X < 8, Y > -1, Y < 8.

% ������ �����
empty(X, Y):-
	onboard(X, Y),
	not(computer_figure(X, Y)),
	not(player_figure(X, Y)),
	!.

% ���� ����� ������� �� ������ (X2, Y2) �� (X1, Y1), ����������� �� 1 ������ � ����������� (Dx, Dy)
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

% ��������� ����� � ��, ���� ����� ����� �� ����� ������
player_try_to_get_king(0, Y2):-
	player_figure(0, Y2),
	not(player_king(0, Y2)),                    % ���� �� ����� ������
	asserta(player_king(0, Y2)).              % ��������� �� � ������ ��
	
player_try_to_get_king(_, _).

% ��� ����� ������
player_checker_current(X1, Y1, X2, Y2):-
	Dx = X2 - X1,          % +1, ���� �������� ������������
	Dy = Y2 - Y1,          % -1, ���� �������� ������������
	X = X1 + Dx,                                 % X = ++X1 (��� --X1)
	Y = Y1 + Dy,                                  % Y = ++Y1 (��� --Y1)
	player_checker_current(X, Y, X2, Y2, 1).
														 
player_checker_current(X1, Y1, X2, Y2, 1):-
	not(X1 == X2),
	(computer_figure(X1, Y1) ; player_figure(X1, Y1)),
	!.
	
player_checker_current(X1, Y1, X2, Y2, 1):-
	not(X1 == X2),
	Dx = X2 - X1,          % +1, ���� �������� ������������
	Dy = Y2 - Y1,          % -1, ���� �������� ������������
	X = X1 + Dx,                                 % X = ++X1 (��� --X1)
	Y = Y1 + Dy,                                  % Y = ++Y1 (��� --Y1)
	player_checker_current(X, Y, X2, Y2, 1).                 

% �������� �� ��, ��� ����� ������ ������ ���� ������ �� (X1, Y1) ������ (Gx, Gy) ������� � (X2, Y2)
player_checker_need_kill(X1, Y1, X2, Y2, Gx, Gy):-
	computer_figure(Gx, Gy),		%������ ������ �� Gx, Gy
	Dx = Gx - X1,					       %������� ��������
	Dy = Gy - Y1,
	T1 = abs(Dx), 
	T1 == 1,							%���������, ��� ���������� �� �...
	T2 = abs(Dy), 
	T2 == 1,							%� y == 1
	X2 = Gx + Dx,					%���������� �������, 
	Y2 = Gy + Dy,					%� ������� ������ ������� ����� ����� ��������
	empty(X2, Y2).					 %��������������, ��� ��� �����

% ������ ������ �� (X1, Y1) ������ (Gx, Gy) ������� � (X2, Y2)
player_king_need_kill(X1, Y1, X2, Y2, Gx, Gy):-
	computer_figure(Gx,Gy),
	Dx = Gx - X1,
	Dy = Gy - Y1,
	T1 = abs(Dx),
	T2 = abs(Dy), 
	T2 == T1,			                                         %�������� ��� �����(� == �)
	not(player_checker_current(X1, Y1, Gx, Gy)), % ���� �� ��� ����� ������
	next_cell(Gx, Gy, Dx, Dy, X2, Y2),
	onboard(X2, Y2).

% ������� �����, ������� ����� ����
player_checker_can_kill(X, Y, Killed):-
	player_checker_need_kill(X, Y, _, _, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	!.

% ������� �����, ������� ����� ����
player_king_can_kill(X, Y, Killed):-
	player_king_need_kill(X, Y, _, _, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	!.

% �������� ���� �������� ����� �� ��
player_remove_all([]):-
	!.
	
player_remove_all([[X, Y] | T]):-
	retract(computer_figure(X, Y)),
	(retract(computer_king(X, Y)) ; !),
	player_remove_all(T).

% ������� ������ ���� �� �������
player_checker_can_continue(X2, Y2, X2, Y2, L):-
	not(player_checker_can_kill(X2, Y2, L)),
	player_remove_all(L),
	!.
	
player_checker_can_continue(X1, Y1, X2, Y2, Killed):-
	player_checker_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	player_checker_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy] | Killed]).

% ������� ������ ���� �� �������
player_king_can_continue(X2, Y2, X2, Y2, L):-
	not(player_king_can_kill(X2, Y2, L)),
	player_remove_all(L),
	!.
	
player_king_can_continue(X1,Y1,X2,Y2,Killed):-
	player_king_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	player_king_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy] | Killed]).

% � ������ ���� ��� ������ �� (X1, Y1) � (X2, Y2)
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

% ��� ������
player_move(X1, Y1, X2, Y2):-
	player_king(X1, Y1),			  % �����
	not(player_need_to_kill),		% �� ���� ������ �������
	empty(X2, Y2),					    % � ������ �����
	T1 = abs(X2 - X1),		% �������� �� �
	T2 = abs(Y2 - Y1),	     % � �
	T1 == T2,						        % ������.
	onboard(X2, Y2),				    % ������ �� �����(����� ��, �������, ��� �� ���, ��� ����)
	retract(player_figure(X1, Y1)),	% ������� ������ � �����
	asserta(player_figure(X2, Y2)),	% �������� ������ � ����� 
	retract(player_king(X1, Y1)),	 % ������� ������ � �����
	asserta(player_king(X2, Y2)).	% �������� ������ � �����

% ����� ����� ������ ����-������
player_need_to_kill:-
	player_figure(X, Y),
	(player_checker_can_kill(X, Y, []) ; (player_king(X, Y), player_king_can_kill(X, Y, []))).
	
% ����������� ����������� ����� (X2, Y2) ��� ������ �� (X1, Y1)
player_can_move(X1, Y1, X2, Y2):-     % ����� � 2� ������������
	player_figure(X1, Y1),
	not(player_king(X1, Y1)),
	X2 = X1 - 1,
	Y2 = Y1 - 1.
player_can_move(X1, Y1, X2, Y2):-
	player_figure(X1, Y1),
	not(player_king(X1, Y1)),
	X2 = X1 - 1,
	Y2 = Y1 + 1.
player_can_move(X1, Y1, X2, Y2):-     % ����� � 4� ������������ 
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
	
% ��������� ����� ����, ���� �� (X1, Y1) � (X2, Y2), ������ (Gx, Gy)
computer_checker_need_kill(X1, Y1, X2, Y2, Gx, Gy):-
	player_figure(Gx, Gy),
	Dx = Gx - X1,
	Dy = Gy - Y1,
	T1 = abs(Dx), 
	T1 == 1,	   % ��������, ��������� �� ��������� ����� �����
	T2 = abs(Dy), 
	T2 == 1,
	X2 = Gx + Dx,			    % X2 ����������� ��� �������� �� Dx
	Y2 = Gy + Dy, 		        % Y2 ����������� ��� �������� �� Dy
	empty(X2, Y2).

% ������� ������ ���� �� �������
computer_checker_can_continue(X2, Y2, X2, Y2, L):-
	not(computer_checker_can_kill(X2, Y2, L)),
	computer_remove_all(L),
	!.
	
computer_checker_can_continue(X1, Y1, X2, Y2, Killed):-
	computer_checker_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),							% �������� �� ��, ��� �������� Gx, Gy ��� � ������ ������
	computer_checker_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy] | Killed]).

% ����� ���������� ����� ����
computer_checker_can_kill(X, Y, Killed):-
	computer_checker_need_kill(X, Y, _, _, Gx, Gy),		% ���������� ���������� �����, ������� ����� ����
	not(is_member([Gx, Gy], Killed)),			% ���������, ��� ��� �� ��������� � ������ ������
	!.

% ����������� ����������� ����� (X2, Y2) ��� ������ �� (X1, Y1)
computer_can_move(X1, Y1, X2, Y2):-     % ����� � 2� ������������
	computer_figure(X1, Y1),
	not(computer_king(X1, Y1)),
	X2 = X1 + 1,
	Y2 = Y1 - 1.
computer_can_move(X1, Y1, X2, Y2):-
	computer_figure(X1, Y1),
	not(computer_king(X1, Y1)),
	X2 = X1 + 1,
	Y2 = Y1 + 1.
computer_can_move(X1, Y1, X2, Y2):-     % ����� � 4� ������������ 
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

% ���������� ���� �� (X1, Y1) � (X2, Y2) ������, ��� ������ �������� ������
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

% ��������� ����� � ��, ���� ��������� ����� �� ���� ������
computer_try_to_get_king(7, Y2):-
	computer_figure(7, Y2),
	not(computer_king(7, Y2)),
	asserta(computer_king(7, Y2)).
computer_try_to_get_king(_, _).

% ������ ������ �� (X1, Y1) ������ (Gx, Gy) ������� � (X2, Y2)
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

% ������� ������ ���� �� �������
computer_king_can_continue(X2, Y2, X2, Y2, L):-
	not(computer_king_can_kill(X2, Y2, L)),
	computer_remove_all(L),
	!.
	
computer_king_can_continue(X1, Y1, X2, Y2, Killed):-
	computer_king_need_kill(X1, Y1, Ex1, Ey1, Gx, Gy),
	not(is_member([Gx, Gy], Killed)),
	computer_king_can_continue(Ex1, Ey1, X2, Y2, [[Gx, Gy1] | Killed]).

% ������ ����� ������
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
	
% ����� �������
computer_move:-
	computer_figure(X1,Y1),		                % �� (X1, Y1) �����
	not(computer_king(X1,Y1)),
	computer_checker_need_kill(X1, Y1, X2, Y2, Px1, Py1),
	computer_checker_can_continue(X2, Y2, Xr, Yr, [[Px1, Py1]]),
	retract(computer_figure(X1,Y1)),		      % �������� ������ � ���������� ��������� ����� ����������
	asserta(computer_figure(Xr,Yr)),		      % ������ ������ � ����� ��������� ����� ����������
	computer_try_to_get_king(Xr,Yr),			  % �������� �� �����
	!.		  	

% ����� �������
computer_move:-
	computer_king(X1,Y1),
	computer_king_need_kill(X1, Y1, X2, Y2, Px1, Py1),
	computer_king_can_continue(X2, Y2, Xr, Yr, [[Px1, Py1]]),
	retract(computer_figure(X1, Y1)),
	asserta(computer_figure(Xr, Yr)),
	retract(computer_king(X1, Y1)),
	asserta(computer_king(Xr, Yr)),
	!.

% ����� ���� �����
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

% ����� ����� �� X1 Y1 � X2 Y2
computer_move:-
	computer_figure(X1, Y1),			      % ������ ���������� �� �1, �1
	not(computer_king(X1, Y1)),			    % ��� �� �����
	computer_can_move(X1, Y1, X2, Y2),	% �������� �� ����(��� ����� x = y = 1, ��� ����� x = y)
	empty(X2, Y2),						           % ������ X2, Y2 �����
	computer_next_step_player_can_to_kill(X1, Y1, X2, Y2),
	retract(computer_figure(X1, Y1)),	   % �������� ������ � �������� ������� �����
	asserta(computer_figure(X2, Y2)),	  % ������ ����� �������
	computer_try_to_get_king(X2, Y2).

% ������ ������ �����, ��� ��� ���� ���� �����, ����� ����� ���� ���������� ����� ���� ������ 
computer_move:-
	computer_figure(X1, Y1),
	computer_can_move(X1, Y1, X2, Y2),
	empty(X2, Y2),
	retract(computer_figure(X1, Y1)),
	asserta(computer_figure(X2, Y2)),
	((retract(computer_king(X1, Y1)), asserta(computer_king(X2, Y2))) ; !),
	computer_try_to_get_king(X2,Y2).

% �������� ���� �������� ����� �� ��
computer_remove_all([]):-
	!.
	
computer_remove_all([[X, Y] | T]):-
	retract(player_figure(X, Y)),
	(retract(player_king(X, Y)) ; !),
	computer_remove_all(T).

% ������� ������
computer_win:-
	not(computer_figure(_, _));
	(computer_figure(_, _), not(computer_try_move(_, _))).
player_win:-
	not(player_figure(_, _));
	(player_figure(_, _), not(player_try_move(_, _))).
