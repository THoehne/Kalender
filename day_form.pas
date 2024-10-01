unit day_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ComCtrls, Buttons, ExtCtrls, Menus, time_dlg, LCLType, fpjson, IniFiles, base64,
  DateUtils;

type

  { TSaveFile }

  TSaveFile = TStringGrid;

  { TfrmDay }

  TfrmDay = class(TForm)
    bt_save: TButton;
    btn_abort: TButton;
    iml_system: TImageList;
    lbl_date: TLabel;
    MainMenu1: TMainMenu;
    mnu_btn_abort: TMenuItem;
    pnl_controlls: TPanel;
    btn_app_edt_plus: TSpeedButton;
    btn_app_edt_minus: TSpeedButton;
    stg_appointment: TStringGrid;
    tb_appointment_edit: TToolBar;
    procedure btn_app_edt_minusClick(Sender: TObject);
    procedure btn_app_edt_plusClick(Sender: TObject);
    procedure bt_saveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnu_btn_abortClick(Sender: TObject);
    procedure RegisterChange(Sender: TObject);
    procedure set_time(Sender: TObject);
    procedure load_appointements();
  private
    to_delete: TStringList;
    to_add: TStringList;
    to_change: TStringList;
  public
    procedure Setup(date: String);
  end;

var
  frmDay: TfrmDay;

implementation

{$R *.lfm}

{ TfrmDay }


function IntToStr2Dig(n: Integer): String;
begin
  if n < 10 then exit('0' + IntToStr(n));
  exit(IntToStr(n));
end;

function get_appointment_count(day: String; var save_file: TSaveFile): Integer;
var i: Integer;
begin
  i := 0;
  day := '(n) ' + day;


  i := save_file.Cols[0].IndexOf(day);

  if i = -1 then
  begin
    exit(-1);
  end;

  exit( StrToInt(save_file.Cols[1].ValueFromIndex[i]) );

end;

procedure get_appointment(id: Integer; day: String; var time, title: String; var save_file: TSaveFile);
begin
  time := save_file.Cols[1].ValueFromIndex[id];
  title := save_file.Cols[2].ValueFromIndex[id];
end;

procedure TfrmDay.btn_app_edt_plusClick(Sender: TObject);
var guid: TGuid;
begin
  stg_appointment.RowCount := stg_appointment.RowCount + 1;

  CreateGUID(guid);

  stg_appointment.Cells[2, stg_appointment.RowCount-1] := GUIDToString(guid);

  to_add.Add(GUIDToString(guid));
end;

procedure TfrmDay.bt_saveClick(Sender: TObject);
var appt_file: TIniFile;
    date: TStringArray;
    file_name: String;
    day: String;

    i: Integer;
    index: Integer;
    title: String;
    time_arr: TStringArray;
    dataset: String;

    ignore_empty: Boolean;
begin
  ignore_empty:=False;

  date := String(lbl_date.Caption).Split(['.'], 3);
  file_name := FloatToStr(EncodeDate(StrToInt(date[2]), StrToInt(date[1]), 1));
  appt_file := TIniFile.Create('appts/' + file_name + '.appt');

  day := FloatToStr(EncodeDate(StrToInt(date[2]), StrToInt(date[1]), StrToInt(date[0])));

  for i := 0 to to_add.Count - 1 do
  begin
    index := stg_appointment.Cols[2].IndexOf(to_add.ValueFromIndex[i]);
    title := stg_appointment.Cells[1, index];

    time_arr := stg_appointment.Cells[0, index].Split([':'], 2);
    if (title = '') or (time_arr[0] = '') then
    begin
      if not ignore_empty then if MessageDlg('Achtung!', 'Es ist nicht möglich Termine ohne Zeit oder Datum zu speichern. Sie werden automatisch übersprungen.', mtWarning, [mbOK,mbIgnore], 0) = mrIgnore then ignore_empty:=True;
      Continue;
    end;
    dataset := EncodeStringBase64(FloatToStr(EncodeTime(StrToInt(time_arr[0]), StrToInt(time_arr[1]), 0,0)) + '::' + EncodeStringBase64(title));

    try
      appt_file.WriteString(day, to_add.ValueFromIndex[i], dataset);
    except
      ShowMessage('Writing to file has failed');
    end;
  end;

  for i := 0 to to_change.Count - 1 do
  begin
    if to_change.ValueFromIndex[i] = '' then Continue;

    index := stg_appointment.Cols[2].IndexOf(to_change.ValueFromIndex[i]);
    title := stg_appointment.Cells[1, index];

    time_arr := stg_appointment.Cells[0, index].Split([':'], 2);
    if (title = '') or (time_arr[0] = '') then
    begin
      if not ignore_empty then if MessageDlg('Achtung!', 'Es ist nicht möglich Termine ohne Zeit oder Datum zu speichern. Sie werden automatisch übersprungen.', mtWarning, [mbOK,mbIgnore], 0) = mrIgnore then ignore_empty:=True;
      Continue;
    end;
    dataset := EncodeStringBase64(FloatToStr(EncodeTime(StrToInt(time_arr[0]), StrToInt(time_arr[1]), 0,0)) + '::' + EncodeStringBase64(title));

    try
      appt_file.WriteString(day, to_change.ValueFromIndex[i], dataset);
    except
      ShowMessage('Writing to file has failed');
    end;
  end;

  for i := 0 to to_delete.Count - 1 do
  begin
    appt_file.DeleteKey(day, to_delete.ValueFromIndex[i]);
  end;

  appt_file.Free;
end;

procedure TfrmDay.FormCreate(Sender: TObject);
begin
  to_add := TStringList.Create;
  to_delete := TStringList.Create;
  to_change := TStringList.Create;
end;

procedure TfrmDay.mnu_btn_abortClick(Sender: TObject);
begin
  ModalResult:=mrAbort;
end;

procedure TfrmDay.RegisterChange(Sender: TObject);
begin
  if (to_add.IndexOf(stg_appointment.Cells[2, stg_appointment.Row]) = -1) and (to_change.IndexOf(stg_appointment.Cells[2, stg_appointment.Row]) = -1) then
  begin
    to_change.Add(stg_appointment.Cells[2, stg_appointment.Row]);
  end;

end;

procedure TfrmDay.load_appointements();
var appt_file: TIniFile;
    day: String;

    file_name: String;
    date: TStringArray;
    section: TStringList;

    i: Integer;
    title: String;
    hr, min, s, ms: Word;
    dataset: TStringArray;
begin
  date := String(lbl_date.Caption).Split(['.'], 3);
  file_name := FloatToStr(EncodeDate(StrToInt(date[2]), StrToInt(date[1]), 1));

  appt_file := TIniFile.Create('appts/' + file_name + '.appt');

  day := FloatToStr(EncodeDate(StrToInt(date[2]), StrToInt(date[1]), StrToInt(date[0])));

  if not (appt_file.SectionExists(day)) then
  begin
    stg_appointment.RowCount := 1;
    exit();
  end;

  section := TStringList.Create;

  appt_file.ReadSection(day, section);

  stg_appointment.RowCount := section.Count+1;

  for i := 0 to section.Count - 1 do
  begin
    dataset := DecodeStringBase64(appt_file.ReadString(day, section.ValueFromIndex[i], '')).Split(['::'], 2);
    DecodeTime(StrToFloat(dataset[0]), hr, min, s, ms);
    title := DecodeStringBase64(dataset[1]);

    stg_appointment.Cells[0, i+1] := IntToStr2Dig(hr) + ':' + IntToStr2Dig(min);
    stg_appointment.Cells[1, i+1] := title;
    stg_appointment.Cells[2, i+1] := section.ValueFromIndex[i];
  end;

  appt_file.Free;
end;

procedure TfrmDay.set_time(Sender: TObject);
var dlg: TfrmTimeDlg;
    current_time: String;
    time_sp: TStringArray;
    hr, min, sec, msec: Word;
    s_hr, s_min: String;
begin
  if stg_appointment.Row = 0 then exit();

  current_time := stg_appointment.Cells[0, stg_appointment.Row];



  if not (current_time = '') then
  begin
    time_sp := current_time.Split([':'], 2);
    hr := StrToInt(time_sp[0]);
    min := StrToInt(time_sp[1]);
  end;


  dlg := TfrmTimeDlg.Create(hr, min);
  dlg.ShowModal;

  if (dlg.ModalResult = mrAbort) then exit();

  hr := 0;
  min := 0;
  sec := 0;
  msec := 0;

  DecodeTime(dlg.GetResult(), hr, min, sec, msec);

  s_hr := IntToStr(hr);
  s_min := IntToStr(min);

  if Length(s_hr) = 1 then s_hr := '0' + s_hr;
  if Length(s_min) = 1 then s_min := '0' + s_min;

  stg_appointment.Cells[0, stg_appointment.Row] := s_hr + ':' + s_min;
end;

procedure TfrmDay.btn_app_edt_minusClick(Sender: TObject);
var Reply: Integer;
    guid: String;
begin
  if stg_appointment.Row = 0 then exit();

  Reply := MessageDlg('Löschen?', stg_appointment.Cells[1, stg_appointment.Row], mtConfirmation, [mbYes, mbAbort], 0);

  if not (Reply = mrYes) then exit();

  if stg_appointment.Row <> 0 then
  begin
    guid := stg_appointment.Cells[2, stg_appointment.Row];

    if not (to_add.IndexOf(guid) = -1) then to_add.Delete(to_add.IndexOf(guid))
    else to_delete.Add(guid);

    stg_appointment.DeleteRow(stg_appointment.Row);

    // ShowMessage(IntToStr(to_add.Count) + ' : ' + IntToStr(to_delete.Count) + ' : ' + IntToStr(to_change.Count));

    if not (to_change.IndexOf(guid) = -1) then to_change.Delete(to_change.IndexOf(guid));
  end;
end;

procedure TfrmDay.Setup(date: String);
begin
  lbl_date.Caption := date;
  Caption := date;

  load_appointements();
end;

end.

