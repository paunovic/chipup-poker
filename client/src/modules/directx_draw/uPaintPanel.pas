unit uPaintPanel;

interface

uses
  System.Classes, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics;

type
  TPaintPanel = class(TCustomPanel)
  private
    FOnPaint: TNotifyEvent;
  protected
    procedure Paint; override;
  public
    constructor Create(const AOwner: TWinControl; const AOnPaint: TNotifyEvent); reintroduce;

    property Canvas;
    property OnClick;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

implementation

constructor TPaintPanel.Create(const AOwner: TWinControl; const AOnPaint: TNotifyEvent);
begin
  inherited Create(AOwner);

  Parent := AOwner;
  Color := clBlack;
  Caption := '';
  OnPaint := AOnPaint;
  Align := alClient;
  Brush.Style := bsClear;
end;

procedure TPaintPanel.Paint;
begin
  FOnPaint(self);
end;


end.
