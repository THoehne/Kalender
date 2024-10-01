unit untutorial;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

const
  tmNote = 0;
  tmAstTut = 1;

type


  { TfrmTutorial }

  TfrmTutorial = class(TForm)
    btn_skip_tut: TButton;
    btn_ok: TButton;
    lbl_tut_info: TLabel;
    Panel1: TPanel;
    pnl_wrapper: TPanel;
  private

  public
    procedure Execute(msg: String; mode: Integer);
    procedure SetPos(x,y: Integer);
    procedure SetLblAlign(AAlignment: TAlignment);
  end;

var
  frmTutorial: TfrmTutorial;

implementation

{$R *.lfm}

{ TfrmTutorial }

procedure TfrmTutorial.Execute(msg: String; mode: Integer);
begin
  if mode = tmAstTut then
  begin
    btn_skip_tut.Visible := True;
  end
  else
  begin
    Self.Position:=poDesigned;
    btn_skip_tut.Visible := False;
  end;

  lbl_tut_info.Caption := msg;

  Self.ShowModal;
end;

procedure TfrmTutorial.SetPos(x,y: Integer);
begin
  Self.Top := y;
  Self.Left:= x;
  alClient;
end;

procedure TfrmTutorial.SetLblAlign(AAlignment: TAlignment);
begin
  lbl_tut_info.Alignment := AAlignment;
end;

end.

