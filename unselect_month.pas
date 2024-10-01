unit unselect_month;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, DateUtils;

type

  { TfrmSelectMonth }

  TfrmSelectMonth = class(TForm)
    btn_ok: TButton;
    btn_abort: TButton;
    cmb_month: TComboBox;
    cmb_year: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    function GetMonth(): Integer;
    function GetYear(): Integer;

  public
    property month: Integer read GetMonth;
    property year: Integer read GetYear;

    procedure SetTime(Ayear: Integer; Amonth: String);
  end;

var
  frmSelectMonth: TfrmSelectMonth;

implementation

{$R *.lfm}

{ TfrmSelectMonth }

procedure TfrmSelectMonth.FormCreate(Sender: TObject);
begin
  cmb_month.ItemIndex := MonthOf(Now) - 1;
  cmb_year.ItemIndex := YearOf(Now) - 1900;
end;

function TfrmSelectMonth.GetMonth(): Integer;
begin
  Result := cmb_month.ItemIndex + 1;
end;

function TfrmSelectMonth.GetYear(): Integer;
begin
  Result := cmb_year.ItemIndex + 1900;
end;

procedure TfrmSelectMonth.SetTime(Ayear: Integer; Amonth: String);
begin
  cmb_month.ItemIndex:=cmb_month.Items.IndexOf(Amonth);
  cmb_year.ItemIndex:=cmb_year.Items.IndexOf(IntToStr(Ayear));
end;

end.

