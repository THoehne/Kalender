unit unmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, ComCtrls, Menus, DateUtils, day_form, day_box, IniFiles, base64,
  unselect_month, untutorial, time_dlg, LCLTranslator;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    img_system: TImageList;
    lbl_header_0: TLabel;
    lbl_header_1: TLabel;
    lbl_header_2: TLabel;
    lbl_header_3: TLabel;
    lbl_header_4: TLabel;
    lbl_header_5: TLabel;
    lbl_header_6: TLabel;
    lbl_month: TLabel;
    mnu_btn_tutorial_start: TMenuItem;
    mnu_btn_open: TMenuItem;
    mnu_btn_back: TMenuItem;
    mnu_btn_next: TMenuItem;
    mnu_main: TMainMenu;
    btn_heute: TMenuItem;
    pnl_weekday_header: TPanel;
    viewport: TPanel;
    pnl_header: TPanel;
    pnl_main_viewport: TPanel;
    btn_prev_m: TSpeedButton;
    btn_suc_m: TSpeedButton;
    procedure btn_heuteClick(Sender: TObject);
    procedure btn_prev_mClick(Sender: TObject);
    procedure btn_suc_mClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnu_btn_tutorial_startClick(Sender: TObject);
    procedure mnu_btn_openClick(Sender: TObject);
    procedure mnu_btn_backClick(Sender: TObject);
    procedure mnu_btn_nextClick(Sender: TObject);
    procedure OpenSetMonth(Sender: TObject);
    procedure Setup();

    procedure LoadViewport();
    procedure LoadApptPreview(start_day: Double);
    procedure InitViewport();
    procedure SetApptPreview(appt_file: TIniFile; day_box: TDayBox; date: TDateTime);

    procedure OpenDay(Sender: TObject);
    procedure SelectDay(Sender: TObject);

    procedure CycleMonth(n: Integer);
    procedure SetVisibilityLastWeek(b: Boolean);
  private
    current_month: Integer;
    current_year: Integer;

    selected_day: TDayBox;
  public

  end;

var
  frmMain: TfrmMain;
  months: Array[1..12] of String;
  days: Array[0..41] of TDayBox;
  prev_days_amount: Integer;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.OpenDay(Sender: TObject);
var frm_day_form: TfrmDay;
    day: TDayBox;
begin
  if Sender is TDayBox then day := (Sender as TDayBox)
  else if (Sender is TPanel) and ((Sender as TPanel).Tag = 1) then day := (((Sender as TPanel).Parent as TPanel).Parent as TDayBox)
  else day := ((Sender as TPanel).Parent as TDayBox);

  frm_day_form := TfrmDay.Create(Self);
  frm_day_form.Setup(day.Caption);
  frm_day_form.ShowModal;

  if frm_day_form.ModalResult = mrOK then LoadViewport();
end;

procedure TFrmMain.SelectDay(Sender: TObject);
var day: TDayBox;
begin
  if selected_day <> nil then selected_day.Selected:=False;

  if Sender is TDayBox then day := (Sender as TDayBox)
  else if (Sender is TPanel) and ((Sender as TPanel).Tag = 1) then day := (((Sender as TPanel).Parent as TPanel).Parent as TDayBox)
  else day := ((Sender as TPanel).Parent as TDayBox);

  day.Selected:= True;
  selected_day := day;
end;

procedure TfrmMain.SetVisibilityLastWeek(b: Boolean);
begin
  days[35].Visible:=b;
  days[36].Visible:=b;
  days[37].Visible:=b;
  days[38].Visible:=b;
  days[39].Visible:=b;
  days[40].Visible:=b;
  days[41].Visible:=b;
end;

procedure TfrmMain.InitViewport();
var i: Integer;
    comp_day: TDayBox;
begin
  for i := 0 to 41 do
  begin
    comp_day := TDayBox.Create(@SelectDay, @OpenDay, dmOutMonth);
    comp_day.Parent := viewport;
    days[i] := comp_day;
  end;
  prev_days_amount:=41;
end;

procedure TfrmMain.LoadViewport;
var i: Integer;
    days_back: Double;

    start_day: Double;

    render_date: TDateTime;
begin
  days_back := DayOfTheWeek(EncodeDate(current_year, current_month, 1));

  start_day := Double(EncodeDate(current_year, current_month, 1)) - days_back + 1;

  if days_back + DaysInAMonth(current_year, current_month) - 1 > 35 then SetVisibilityLastWeek(True)
  else SetVisibilityLastWeek(False);

  for i := 0 to 41 do
  begin
    render_date := start_day + i;

    if MonthOf(render_date) <> current_month then days[i].mode := dmOutMonth
    else if CompareDate(render_date, Now) = 0 then days[i].mode := dmCurrentDay
    else days[i].mode := dmInMonth;

    days[i].Caption := ' ' + DateToStr(render_date);
  end;

  LoadApptPreview(start_day);
end;

procedure TfrmMain.SetApptPreview(appt_file: TIniFile; day_box: TDayBox; date: TDateTime);
var section: TStringList;
    i: Integer;
    day: String;

    dataset: TStringArray;
    hr, min, s, ms: Word;
    title: String;

    appt_count: Word;
begin
  section := TStringList.Create;

  day := FloatToStr(date);
  appt_file.ReadSection(day, section);

  appt_count:=section.Count;
  if section.Count > 3 then appt_count:=3;

  for i := 0 to appt_count - 1 do
  begin
    dataset := DecodeStringBase64(appt_file.ReadString(day, section.ValueFromIndex[i], '')).Split(['::'], 2);
    DecodeTime(StrToFloat(dataset[0]), hr, min, s, ms);
    title := DecodeStringBase64(dataset[1]);

    day_box.AddAppt(title, hr, min);
  end;
end;

procedure TfrmMain.LoadApptPreview(start_day: Double);
var i: Integer;
    render_date: TDateTime;

    appt_file_name: String;
    appt_file: TIniFile;
begin
  appt_file_name := FloatToStr(EncodeDate(current_year, current_month, 1)) + '.appt';

  appt_file := TIniFile.Create('appts/' + appt_file_name);

  for i := 0 to 41 do
  begin
    days[i].ClearAppt();

    render_date := start_day + i;

    if MonthOf(render_date) <> current_month then days[i].mode := dmOutMonth
    else if CompareDate(render_date, Now) = 0 then days[i].mode := dmCurrentDay
    else days[i].mode := dmInMonth;

    days[i].Caption := ' ' + DateToStr(render_date);

    SetApptPreview(appt_file, days[i], render_date);
  end;

  appt_file.Free;
end;

procedure TfrmMain.Setup;
var current_time: TDateTime;
begin
  months[1] := 'Januar';
  months[2] := 'Februar';
  months[3] := 'März';
  months[4] := 'April';
  months[5] := 'Mai';
  months[6] := 'Juni';
  months[7] := 'Juli';
  months[8] := 'August';
  months[9] := 'September';
  months[10] := 'Oktober';
  months[11] := 'November';
  months[12] := 'Dezember';

  current_time := Now;

  current_month:=MonthOfTheYear(current_time);
  current_year:=YearOf(current_time);

  lbl_month.Caption := months[MonthOfTheYear(current_time)] + ' ' + IntToStr(current_year) + ' (Heute)';

  InitViewport();
  LoadViewport();
end;

procedure TfrmMain.CycleMonth(n: Integer);
var current_time: TDateTime;
begin
  current_month := current_month + n;

  if (current_month < 1) then
  begin
    current_month:=12;
    current_year := current_year - 1;
  end
  else if (current_month > 12) then
  begin
      current_month:=1;
      current_year := current_year + 1;
  end;

  if current_year < 1900 then
  begin
    current_month := 1;
    current_year := 1900;
  end;

  lbl_month.Caption := months[current_month] + ' ' + IntToStr(current_year);

  current_time := Now;
  if (current_month = MonthOfTheYear(current_time)) and (current_year = YearOf(current_time)) then lbl_month.Caption := lbl_month.Caption + ' (Heute)';

  LoadViewport();
end;

procedure TfrmMain.FormCreate(Sender: TObject);

begin
  setup;
end;

procedure TfrmMain.mnu_btn_tutorial_startClick(Sender: TObject);
var tut_window: TfrmTutorial;
    setup_file: TIniFile;
    pos, screen_pos: TPoint;

    tut_w_month_select: TfrmSelectMonth;
    tut_w_appt_form: TfrmDay;
    time_format_settings: TFormatSettings;
    tut_w_set_time_dlg: TfrmTimeDlg;
    guid_of_sim_appt: String;
begin
  setup_file := TIniFile.Create('setup.ini');
  mnu_btn_tutorial_start.Visible:=False;

  tut_window := TfrmTutorial.Create(Self);

  tut_window.Execute('Willkommen zu diesem Kalender. Im folgenden Tutorial werden einige Funktionen erklärt.', tmAstTut);

  if tut_window.ModalResult = mrAbort then
  begin
    setup_file.WriteBool('Tutorial', 'status', True);
    setup_file.Free;
    mnu_btn_tutorial_start.Visible:=True;
    exit();
  end;

  pos := Point(Self.Left + (Self.Width div 2 - 241), Self.Top + 100);
  tut_window.SetPos(pos.x, pos.y);
  tut_window.Execute('Ganz oben befindet sich die Kontrolle. Hier kann man einen bestimmten Monat im Jahr auswählen.', tmNote);
  tut_window.Execute('In der Mitte kann man sehen, welcher Monat und welches Jahr gerade sichtbar ist.', tmNote);
  tut_window.Execute('Haben Sie das "Heute" in Klammern rechts daneben gesehen? Wenn "(Heute)" neben dem Jahr steht, dann bedeutet das, dass sie sich im momentanen Monat befinden.', tmNote);

  pos := Point(btn_prev_m.Left, btn_prev_m.Top);
  screen_pos := ClientToScreen(pos);
  tut_window.SetPos(screen_pos.x + 50, screen_pos.y - 15);
  tut_window.SetLblAlign(taLeftJustify);
  tut_window.Execute('<- Dieser Knopf links außen dient dazu, einen Monat zurück zu springen.', tmNote);

  pos := Point(btn_suc_m.Left, btn_suc_m.Top);
  screen_pos := ClientToScreen(pos);
  tut_window.SetPos(screen_pos.x - 482, screen_pos.y - 15);
  tut_window.SetLblAlign(taRightJustify);
  tut_window.Execute('Dieser Knopf rechts außen dient dazu, einen Monat vorwärts zu springen. ->', tmNote);

  pos := Point(Self.Left + (Self.Width div 2 - 241), Self.Top + 100);
  tut_window.SetPos(pos.x, pos.y);
  tut_window.SetLblAlign(taCenter);
  tut_window.Execute('Ein Doppelklick auf den Monat bzw. das Jahr, öffnet ein weiteres Fenster.', tmNote);

  tut_w_month_select := TfrmSelectMonth.Create(nil);
  tut_w_month_select.Show;

  tut_window.Execute('In diesem Fenster kann man effizient zu einer anderen Zeit springen.', tmNote);

  pos := Point(Self.Left + (Self.Width div 2), Self.Top + (Self.Height div 2));
  tut_window.SetPos(pos.X + 100, pos.Y - 45);
  tut_window.SetLblAlign(taLeftJustify);
  tut_window.Execute('<- Im ersten Feld kann man einen Monat im Jahr auswählen.', tmNote);

  tut_window.SetPos(pos.X + 100, pos.Y);
  tut_window.Execute('<- Im zweiten Feld kann man nun ein Jahr auswählen.', tmNote);

  tut_window.SetPos(pos.X + 120, pos.Y);
  tut_w_month_select.SetTime(1970, 'Januar');

  tut_window.SetLblAlign(taCenter);
  tut_window.Execute('Lass uns eine kleine Zeitreise machen. In das Jahr 1970.', tmNote);

  tut_w_month_select.Destroy;
  current_year:=1970;
  current_month:=1;
  LoadViewport();

  pos := Point(Self.Left + (Self.Width div 2 - 241), Self.Top + (Self.Height div 2 - 60));
  tut_window.SetPos(pos.x, pos.y);
  tut_window.Execute('Seit dem 1. Januar 1970 zählt der unix timestamp, einer der wichtigsten Zeitstempel unserer Zeit, die Sekunden die seit diesem Datum vergangen sind.', tmNote);
  tut_window.Execute('Die meisten Server welche heute existieren nutzen diesen Zeitstempel um zu wissen welcher Tag und welche Uhrzeit gerade ist.', tmNote);
  tut_window.Execute('Aber genug Geschichte. Lass uns zurück in die Gegenwart kehren.', tmNote);

  pos := Point(Self.Left+10, Self.Top + 50);
  tut_window.SetPos(pos.x, pos.y);
  tut_window.SetLblAlign(taLeftJustify);
  tut_window.Execute('^ Dafür müssen Sie nur den Knopf Heute oben links drücken.', tmNote);

  current_year:=YearOf(Now);
  current_month:=MonthOf(Now);
  LoadViewport();

  pos := Point(Self.Left + (Self.Width div 2 - 241), Self.Top + (Self.Height div 2 - 60));
  tut_window.SetPos(pos.x, pos.y);
  tut_window.SetLblAlign(taCenter);
  tut_window.Execute('Versuchen wir jetzt mal einen Termin für morgen zu erstellen.', tmNote);
  tut_window.Execute('Dafür muss man nur einen Doppelklick auf den gewünschten Tag machen. Rot markiert ist der heutige Tag. Morgen ist also der rechts daneben.', tmNote);

  tut_w_appt_form := TfrmDay.Create(nil);
  time_format_settings.ShortDateFormat := 'dd.mm.yyyy';
  tut_w_appt_form.Setup(DateToStr(Now + 1, time_format_settings));
  tut_w_appt_form.Show;

  pos := Point(Self.Left + (Self.Width div 2 - 241) - 470, Self.Top + (Self.Height div 2 - 60) - 80);
  tut_window.SetPos(pos.x, pos.y);
  tut_window.SetLblAlign(taRightJustify);
  tut_window.Execute('Mit der Kontrollzeile kann man Termine hinzufügen (+) und löschen (-). ->', tmNote);

  tut_window.SetLblAlign(taCenter);
  tut_w_appt_form.btn_app_edt_plusClick(nil);
  tut_window.Execute('Bei "Titel" kann man einen kurze Beschreibung einfügen.', tmNote);
  tut_w_appt_form.stg_appointment.Cells[1, tut_w_appt_form.stg_appointment.RowCount - 1] := 'Müll raus bringen!!!';
  tut_window.Execute('Um auch eine Zeit einzufügen muss man nun doppelt auf die den gewünschten Termin klicken.', tmNote);

  tut_w_set_time_dlg := TfrmTimeDlg.Create(9,30);
  tut_w_set_time_dlg.Show;

  tut_window.Execute('In diesem Dialog kann man nun eine gewünschte Zeit setzen.', tmNote);

  tut_window.Execute('Nun einfach Ok drücken und schon ist eine Zeit gesetzt.', tmNote);
  tut_w_set_time_dlg.Destroy;

  tut_w_appt_form.stg_appointment.Cells[0,tut_w_appt_form.stg_appointment.RowCount - 1] := '09:30';

  tut_window.Execute('Das letzte was getan werden muss ist "Speichern" drücken und schon ist ein Termin für den Tag gesetzt.', tmNote);

  guid_of_sim_appt := tut_w_appt_form.stg_appointment.Cells[2, tut_w_appt_form.stg_appointment.RowCount - 1];

  tut_w_appt_form.bt_saveClick(nil);
  tut_w_appt_form.Destroy;
  LoadViewport();

  pos := Point(Self.Left + (Self.Width div 2 - 241), Self.Top + (Self.Height div 2 - 60));
  tut_window.SetPos(pos.x, pos.y);
  tut_window.SetLblAlign(taCenter);
  tut_window.Execute('Den Termin kann man jetzt in der Vorschau des Tages leicht erkennen.', tmNote);
  tut_window.Execute('Es werden bis zu drei Termine angezeigt.', tmNote);

  tut_window.Execute('Nun wissen Sie alles was sie müssen um den Kalender zu bedienen.', tmNote);

  setup_file.WriteBool('Tutorial', 'status', True);
  setup_file.Free;
  mnu_btn_tutorial_start.Visible:=True;
  tut_window.Destroy;

  setup_file := TIniFile.Create('appts/' + FloatToStr(EncodeDate(current_year, current_month, 1)) + '.appt');
  setup_file.DeleteKey(FloatToStr(EncodeDate(current_year, current_month, DayOf(Now) + 1)), guid_of_sim_appt);
  LoadViewport();
  setup_file.Free;
end;

procedure TfrmMain.mnu_btn_openClick(Sender: TObject);
begin
  if selected_day <> nil then OpenDay(selected_day);
end;

procedure TfrmMain.mnu_btn_backClick(Sender: TObject);
begin
  CycleMonth(-1)
end;

procedure TfrmMain.mnu_btn_nextClick(Sender: TObject);
begin
  CycleMonth(1);
end;

procedure TfrmMain.OpenSetMonth(Sender: TObject);
var select_month_dlg: TfrmSelectMonth;
begin
  select_month_dlg := TfrmSelectMonth.Create(nil);
  select_month_dlg.ShowModal;

  if select_month_dlg.ModalResult = mrOK then
  begin
    current_month:=select_month_dlg.month;
    current_year:=select_month_dlg.year;
  end;

  CycleMonth(0);
  LoadViewport();
end;

procedure TfrmMain.btn_prev_mClick(Sender: TObject);
begin
  CycleMonth(-1);
end;

procedure TfrmMain.btn_heuteClick(Sender: TObject);
begin
  current_year := YearOf(Now);
  current_month:= MonthOf(Now);
  CycleMonth(0);
end;

procedure TfrmMain.btn_suc_mClick(Sender: TObject);
begin
  CycleMonth(1);
end;

procedure TfrmMain.FormActivate(Sender: TObject);
var setup_file: TIniFile;
begin
  setup_file := TIniFile.Create('setup.ini');

  if setup_file.SectionExists('Tutorial') then
  begin
    setup_file.Free;
    exit();
  end
  else mnu_btn_tutorial_startClick(nil);
end;

end.

