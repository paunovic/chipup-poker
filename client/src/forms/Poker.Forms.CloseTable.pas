unit Poker.Forms.CloseTable;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Poker.Interfaces.ModalForm, Poker.Interfaces.FormParams, Poker.Objects.Games.Game,
  Vcl.ActnList, cxButtons, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore, ChipUpPokerDarkSkin, Vcl.StdCtrls;

type
  TfrmCloseTable = class(TForm, IFormParams, IModalForm)
    btCloseInstant: TcxButton;
    ActionList: TActionList;
    acCloseAfterCurrentHand: TAction;
    acCloseAfter5Mins: TAction;
    acCloseAfter15Mins: TAction;
    btClose5: TcxButton;
    btClose15: TcxButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure acCloseAfterCurrentHandExecute(Sender: TObject);
    procedure acCloseAfter5MinsExecute(Sender: TObject);
    procedure acCloseAfter15MinsExecute(Sender: TObject);
  private
    FCloseCallback: TNotifyEvent;
  public
    FGame: TGameInfo;

    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.FormsContainer, Poker.Server.Socket.Commands, Poker.Protobufs.Objects.CloseGameData;


procedure TfrmCloseTable.FormDestroy(Sender: TObject);
begin
  FormsContainer.Remove(self);
end;

procedure TfrmCloseTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(FCloseCallback) then
    FCloseCallback(self);
end;

procedure TfrmCloseTable.SetParams(const AParams: array of pointer);
begin
  FGame := AParams[0];
end;

procedure TfrmCloseTable.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;


procedure TfrmCloseTable.acCloseAfter15MinsExecute(Sender: TObject);
begin
  ServerSocket.CloseGame(FGame.MongoId, cgtFifteenMinutes);
  Close;
end;

procedure TfrmCloseTable.acCloseAfter5MinsExecute(Sender: TObject);
begin
  ServerSocket.CloseGame(FGame.MongoId, cgtFiveMinutes);
  Close;
end;

procedure TfrmCloseTable.acCloseAfterCurrentHandExecute(Sender: TObject);
begin
  ServerSocket.CloseGame(FGame.MongoId, cgtCurrentHand);
  Close;
end;

end.



