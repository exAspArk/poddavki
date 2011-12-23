unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Grids, StdCtrls, ImgList, Amzi;

type
  TForm1 = class(TForm)
    DrawGrid1: TDrawGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    ImageList1: TImageList;
    LSE: TLSEngine;
    procedure N3Click(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NewGame;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
	var Sx,Sy,Fx,Fy:byte;
		draughts:array[1..8,1..8] of byte;	//������, � ������� �������� ��������� ��������:
		// 0 - empty
		// 1 - white
		// 2 - white king
		// 3 - black
		// 4 - black king
		gameover:boolean;					//...

	{$R *.DFM}
	procedure tform1.newGame;
	var i,j:byte;
		t:tterm;
	begin
		gameover:=false;
		fillchar(draughts,sizeof(draughts),0);	//��� ������ - ������
		for i:=1 to 8 do		//��������� ��������� �����
		begin
			for j:=1 to 3 do	//������(������)
				if odd(i+j) then
					draughts[i,j]:=3;
			for j:=6 to 8 do	//�����
				if odd(i+j) then
					draughts[i,j]:=1;
		end;
		 
		// draughts[6,1]:=2;
		//��������� �����
		//function ExecPStr(var tp: TTerm; s: string): Boolean;� ���������� ��������������, ����������� � ������;
		//��� �������� ������ �� ���� ������ ������ ��������� retract � retractall
		//�������� ���� ������
		lse.ExecPStr(t,'retractall(computer_king(_,_))');
		lse.ExecPStr(t,'retractall(player_king(_,_))');
		lse.ExecPStr(t,'retractall(computer_draugth(_,_))');
		lse.ExecPStr(t,'retractall(player_draugth(_,_))');
		
		//procedure AssertaPStr(s: string);� ���������� ��������� Asserta ��� ��������� �������;
		//�������� asserta ��������� ��������� ����� ����������� � ���� ������. asserta ��������� ����������� � ������ ���� ������
		for i:=1 to 8 do
			for j:=1 to 8 do
				case draughts[i,j] of
					1:lse.AssertaPStr('player_draugth('+inttostr(i)+','+inttostr(j)+')');	//����� ������
					2://�������?)
					begin
						lse.AssertaPStr('player_draugth('+inttostr(i)+','+inttostr(j)+')');
						lse.AssertaPStr('player_king('+inttostr(i)+','+inttostr(j)+')');
					end;
					3:lse.AssertaPStr('computer_draught('+inttostr(i)+','+inttostr(j)+')');	//����� ����������
					4:		//�������?)
					begin
						lse.AssertaPStr('computer_draught('+inttostr(i)+','+inttostr(j)+')');
						lse.AssertaPStr('computer_king('+inttostr(i)+','+inttostr(j)+')');
					end;
				end;
		
		//�����������
		DrawGrid1.Repaint;
	end;

	//��������
	procedure TForm1.N3Click(Sender: TObject);
	begin
		close;
	end;

	//���������� ����
	procedure TForm1.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
	begin
		DrawGrid1.canvas.Brush.Color:=clBtnFace;
		DrawGrid1.canvas.Brush.style:=bssolid;
		
		//�����
		if not odd(ACol+aRow) then
			DrawGrid1.Canvas.FillRect(rect);
		
		//�����\�����
		if draughts[acol+1,arow+1]<>0 then
			ImageList1.Draw(DrawGrid1.Canvas,rect.left,rect.top,draughts[acol+1,arow+1]-1);
	end;

	//�������� �����
	procedure TForm1.FormCreate(Sender: TObject);
	begin
		//procedure InitLS(xplname: String); � ������������� ����;
		lse.InitLS('podd');
		//procedure LoadXPL(xplname: String);� ������ ���� �� �����;
		lse.LoadXPL('podd');
		//�������)
		newGame;
	end;

	//����� ������������� ����
	procedure TForm1.N1Click(Sender: TObject);
	begin
		newgame;
	end;


	//���������� ������� ��������� ����� ��� ������� ������ ����
	procedure TForm1.DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
	begin
		Sx := X div DrawGrid1.DefaultColWidth;
		Sy := Y div DrawGrid1.DefaultRowHeight;
	end;

	//���������� ����� �������, �� ������� ���������� �����������
	procedure TForm1.DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
	var t:tterm;
		i,j:byte;
	begin
		
		//���� ���� �������� - ����� �� �������
		if gameover then exit;
		
		
		//����������� ����� ������� �������
		Fx:= X div DrawGrid1.DefaultColWidth;
		Fy:= Y div DrawGrid1.DefaultRowHeight;
		
		//����������� ���������� ��-�� ����, ��� �������� � ������� ���������� � 1
		inc(sx);
		inc(sy);
		inc(fx);
		inc(fy); 
		
		//���� �������� ��� �� Sx, Sy � Fx, Fy
		if LSE.ExecPStr(t,'player_can_move('+inttostr(Sx)+','+inttostr(Sy)+','+inttostr(Fx)+','+inttostr(Fy)+')') then
		begin
			//��������� �����
			lse.ExecPStr(t,'computer_move');
			
			//� ������ ������
			for i:=1 to 8 do
				for j:=1 to 8 do
				begin
					//���� �������� - ����������
					if not odd(i+j) then continue;
					
					//��������� ������ �� ���������� ���� ������
					if lse.ExecPStr(t,'player_king('+inttostr(i)+','+inttostr(j)+')') then
						draughts[i,j]:=2 
					else if lse.ExecPStr(t,'computer_king('+inttostr(i)+','+inttostr(j)+')') then
						draughts[i,j]:=4 
					else if lse.ExecPStr(t,'player_draught('+inttostr(i)+','+inttostr(j)+')') then
						draughts[i,j]:=1 
					else if lse.ExecPStr(t,'computer_draught('+inttostr(i)+','+inttostr(j)+')') then
						draughts[i,j]:=3 
					else
						draughts[i,j]:=0;
				end;
			
			//�����������
			DrawGrid1.repaint;
			//���� ��������� ������� - ����� ���������
			if lse.execpstr(t,'computer_win') then
			begin
				Application.MessageBox('������!','��������� �������!',mb_ok or MB_ICONINFORMATION);
				gameover:=true;
			end;
			//���� ������������ ������� - ����� ���������
			if lse.execpstr(t,'player_win') then
			begin
				Application.MessageBox('������!','������� �������!',mb_ok or MB_ICONINFORMATION);
				gameover:=true;
			end;
		end;
	end;

	//��������
	procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
	begin
		lse.CloseLS;
	end;

end.
