unit day_box;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Controls, SysUtils, Forms, ExtCtrls, Graphics, StdCtrls, LCL, Dialogs;

const

  { For TDayBox.mode}

  dmCurrentDay   =     0;
  dmInMonth      =     1;
  dmOutMonth     =     2;
  dmSelected     =     3;

type

  { TDayBox }

  TDayBox = class(TPanel)

  private
    border_color_pallet: Array[0..3] of TColor;
    bg_color_pallet: Array[0..3] of TColor;
    font_color_pallet: Array[0..3] of TColor;

    appt_preview_list: Array[0..2] of TPanel;
    appt_count: Word;


    day_mode: Integer;
    wrapper: TPanel;
    _selected: Boolean;
    default_color: TColor;
    default_bg_cl: TColor;
    default_font_color: TColor;

    function GetMode(): Integer;
    procedure SetMode(mode: Integer);

    function GetSelected(): Boolean;
    procedure SetSelected(b: Boolean);
  public
    constructor Create(selectEvt:TNotifyEvent; dblClickEvt: TNotifyEvent; mode: Integer);

    procedure AddAppt(title: String; hr, min: Integer);
    procedure ClearAppt();

    property mode: Integer read GetMode write SetMode;
    property Selected: Boolean read GetSelected write SetSelected;
  end;

implementation

function IntToStr2Dig(n: Integer): String;
begin
  if n < 10 then exit('0' + IntToStr(n));
  exit(IntToStr(n));
end;

{ TDayBox }

procedure TDayBox.ClearAppt();
var i: Integer;
begin
  if appt_count < 1 then exit();

  for i := 0 to appt_count - 1 do
  begin
    appt_preview_list[i].Caption:='';
  end;

  appt_count := 0;
end;

procedure TDayBox.AddAppt(title: String; hr, min: Integer);
begin
  if (appt_count > 3) then exit();

  appt_preview_list[appt_count].Caption := ' ' + IntToStr2Dig(hr) + ':' + IntToStr2Dig(min) + ' - ' + title;

  Inc(appt_count);
end;

function TDayBox.GetMode(): Integer;
begin
  exit(day_mode)
end;

procedure TDayBox.SetMode(mode: Integer);
begin
  if (mode > -1) and (mode < 3) then day_mode := mode
  else raise EInvalidOperation.Create('Mode must be between 0 and 2');

  Self.Color := border_color_pallet[mode];
  wrapper.Color := bg_color_pallet[mode];

  Self.Font.Color:=font_color_pallet[mode];
end;

function TDayBox.GetSelected(): Boolean;
begin
  exit(_selected);
end;

procedure TDayBox.SetSelected(b: Boolean);
begin
  _selected := b;
  if b then
  begin
    default_color := Self.Color;
    default_bg_cl := wrapper.Color;
    default_font_color:= Self.Font.Color;
    Self.Color := border_color_pallet[dmSelected];
    wrapper.Color := bg_color_pallet[dmSelected];
    Self.Font.Color := font_color_pallet[dmSelected];
  end
  else
  begin
    Self.Color := default_color;
    wrapper.Color := default_bg_cl;
    Self.Font.Color:=default_font_color;
  end;
end;


constructor TDayBox.Create(selectEvt:TNotifyEvent; dblClickEvt: TNotifyEvent; mode: Integer);
var i: Integer;
begin
  inherited Create(nil);

  border_color_pallet[dmCurrentDay] := clRed;
  border_color_pallet[dmInMonth]    := clBlack;
  border_color_pallet[dmOutMonth]   := clGray;
  border_color_pallet[dmSelected]   := clBlue;

  bg_color_pallet[dmSelected]       := TColor($FFA3A3);
  bg_color_pallet[dmInMonth]        := TColor($6B6B6B);
  bg_color_pallet[dmOutMonth]       := TColor($FFFFFF);
  bg_color_pallet[dmCurrentDay]     := TColor($A3C2FF);

  font_color_pallet[dmCurrentDay]   := clBlack;
  font_color_pallet[dmInMonth]      := clWhite;
  font_color_pallet[dmOutMonth]     := clBlack;
  font_color_pallet[dmSelected]     := clWhite;

  appt_count := 0;

  wrapper := TPanel.Create(Self);
  wrapper.Parent := Self;
  wrapper.OnDblClick := dblClickEvt;
  wrapper.OnClick:=selectEvt;
  wrapper.BorderSpacing.Around := 2;
  wrapper.Color := clWhite;
  wrapper.Align:=alClient;
  // wrapper.BevelOuter:=bvNone;
  wrapper.Color := bg_color_pallet[mode];
  wrapper.BorderSpacing.Top := 15;


  Self.Color:=border_color_pallet[mode];
  Self.BorderStyle:=bsNone;
  Self.BorderSpacing.Around:=5;
  Self.BevelOuter:=bvNone;
  Self.Alignment:=taLeftJustify;
  Self.VerticalAlignment:=taAlignTop;
  Self.Font.Bold:=True;
  // Self.Constraints.MaxWidth:=200;

  Self.OnClick:=selectEvt;
  Self.OnDblClick:=dblClickEvt;

  Self.Font.Color:=font_color_pallet[mode];

  _selected:=False;
  default_color:=border_color_pallet[mode];


  for i := 2 downto 0 do
  begin
    appt_preview_list[i] := TPanel.Create(Self.wrapper);
    appt_preview_list[i].Align := alTop;
    appt_preview_list[i].Parent := Self.wrapper;
    // appt_preview_list[i].Transparent := False;
    // appt_preview_list[i].Color := clGreen;
    appt_preview_list[i].Constraints.MaxHeight := 18;
    appt_preview_list[i].BevelOuter := bvNone;
    appt_preview_list[i].Alignment := taLeftJustify;
    appt_preview_list[i].OnClick := selectEvt;
    appt_preview_list[i].OnDblClick := dblClickEvt;
    appt_preview_list[i].Tag:=1;
  end;
end;

end.

