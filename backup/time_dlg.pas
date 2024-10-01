unit time_dlg;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Menus, DateUtils;

type

  { TfrmTimeDlg }

  TfrmTimeDlg = class(TForm)
    btn_ok: TButton;
    btn_abort: TButton;
    edt_hr_in: TEdit;
    edt_min_in: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ud_hour: TUpDown;
    ud_minute: TUpDown;

    procedure edt_hr_inChange(Sender: TObject);
    procedure edt_min_inChange(Sender: TObject);
    procedure ud_hourClick(Sender: TObject; Button: TUDBtnType);
    procedure ud_minuteClick(Sender: TObject; Button: TUDBtnType);
    function GetResult(): TDateTime;

    constructor Create(hour, min: Integer);
  private

  public

  end;

var
  frmTimeDlg: TfrmTimeDlg;

implementation

{$R *.lfm}

{ TfrmTimeDlg }

constructor TfrmTimeDlg.Create(hour, min: Integer);
begin
  inherited Create(nil);

  edt_hr_in.Text := IntToStr(hour);
  edt_min_in.Text := IntToStr(min);
end;

function Wrap(n, min, max: Integer): Integer;
begin
  if n > max then Result := (min - 1) + (n - max)
  else if n < min then Result := max
  else Result := n;
end;

procedure TfrmTimeDlg.ud_hourClick(Sender: TObject; Button: TUDBtnType);
begin
  if Button = btNext then
  begin
    edt_hr_in.Text := IntToStr(Wrap(StrToInt(edt_hr_in.Text) + 1, 0, 23));
  end
  else
  begin
    edt_hr_in.Text := IntToStr(Wrap(StrToInt(edt_hr_in.Text) - 1, 0, 23));
  end;
end;

procedure TfrmTimeDlg.edt_hr_inChange(Sender: TObject);
var num: Integer;
begin
  if edt_hr_in.Text = '' then exit();

  try
    num := StrToInt(edt_hr_in.Text);

    if (num < 0) or (num > 23) then edt_hr_in.Text := '0';
  except
    edt_hr_in.Text := '';
  end;

end;

procedure TfrmTimeDlg.edt_min_inChange(Sender: TObject);
var num: Integer;
begin
  if edt_min_in.Text = '' then exit();

  try
    num := StrToInt(edt_min_in.Text);

    if (num < 0) or (num > 59) then edt_min_in.Text := '0';
  except
    edt_min_in.Text := '';
  end;

end;

procedure TfrmTimeDlg.ud_minuteClick(Sender: TObject; Button: TUDBtnType);
begin
  if Button = btNext then
  begin
    edt_min_in.Text := IntToStr(Wrap(StrToInt(edt_min_in.Text) + 1, 0, 59));
  end
  else
  begin
    edt_min_in.Text := IntToStr(Wrap(StrToInt(edt_min_in.Text) - 1, 0, 59));
  end;
end;

function TfrmTimeDlg.GetResult(): TDateTime;
var time: TDateTime;
begin
  if edt_hr_in.Text = '' then edt_hr_in.Text := '0';
  if edt_min_in.Text = '' then edt_min_in.Text := '0';

  time := EncodeTime(StrToInt(edt_hr_in.Text), StrToInt(edt_min_in.Text), 0, 0);
  exit(time);
end;

end.

