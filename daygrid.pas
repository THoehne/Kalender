unit DayGrid;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids, Dialogs, Math, StdCtrls, Controls;

type

  { TDayGrid }

  TDayGrid = class(TCustomGrid)

  public
    constructor Create(AOwner: TComponent); override;

    procedure SetColumnCount(n: Integer);
    procedure SetRowCount(n: Integer);
    procedure ReloadSize();
    function IndexToCell(i: Integer): TRect;

    procedure SetDays();
  private
    dayCells: Array of Array of TGroupBox;
    function SetDayCell(pos: TRect; title:String): TGroupBox;
  end;

implementation

constructor TDayGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.FixedCols := 0;
  Self.FixedRows := 0;

  Self.AutoFillColumns:=True;

  SetDays();
end;

function TDayGrid.IndexToCell(i: Integer): TRect;
var x,y: Integer;
    j: Integer;
begin
  y := 0;
  x := 0;

  for j := 0 to i - 1 do
  begin
    x := x + 1;
    if (x = Self.ColCount) then
    begin
      x := 0;
      y := y + 1;
    end;
  end;

  exit(Self.CellRect(x,y));
end;

function TDayGrid.SetDayCell(pos: TRect; title:String): TGroupBox;
var group_box: TGroupBox;
    appointment_list: TStringGrid;
begin
  group_box := TGroupBox.Create(Self);
  appointment_list := TStringGrid.Create(Self);
  appointment_list.Parent := group_box;
  appointment_list.FixedCols:=0;
  appointment_list.FixedRows:=0;
  appointment_list.ColCount:=2;
  appointment_list.RowCount:=1;
  appointment_list.Align:=alClient;

  group_box.Caption:=title;
  group_box.Parent := Self;
  group_box.Width:=pos.Width;
  group_box.SetBounds(pos.Left, pos.Top, pos.Width, pos.Height);
end;

procedure TDayGrid.SetDays;
var i: Integer;
    days: Integer;
    pos: TRect;
begin

  SetLength(dayCells, Self.ColCount, Self.RowCount);
  days := Self.ColCount * Self.RowCount-1;
  for i := 0 to days do
  begin
    pos := IndexToCell(i);
    SetDayCell(pos, 'Test');
  end;
end;

procedure TDayGrid.ReloadSize();
begin
  Self.DefaultRowHeight := Floor(Self.Height / Self.RowCount) - 1;
end;

procedure TDayGrid.SetColumnCount(n: Integer);
begin
  if (n < 0) then exit();
  Self.ColCount := n;
end;

procedure TDayGrid.SetRowCount(n: Integer);
begin
  if (n < 0) then exit();
  Self.RowCount := n;
  ReloadSize();
end;

end.

