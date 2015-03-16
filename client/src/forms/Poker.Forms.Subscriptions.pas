unit Poker.Forms.Subscriptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  dxSkinsCore, ChipUpPokerDarkSkin, cxGroupBox, cxRadioGroup, Vcl.Menus, cxButtons,
  cxLabel, Vcl.ActnList;

type
  TfrmSubscriptions = class(TForm)
    Panel1: TPanel;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    cxLabel1: TcxLabel;
    Panel2: TPanel;
    cxButton4: TcxButton;
    cxButton5: TcxButton;
    cxLabel2: TcxLabel;
    alSubscriptionForm: TActionList;
    acPayPal: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure acPayPalExecute(Sender: TObject);
  private
    FCallbacksId: Integer;
    procedure CSRSubscriptionPlanChange(const AMethodId: Integer; const AObject: TObject);
  public
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.FormsContainer, Poker.Server.MessageContainer, Poker.Server.MessageCallbacks, Poker.Protobufs.Enum.ServerCodes,
  Poker.Server.Socket, Poker.Protobufs.Objects.User, Poker.Common.Misc, Poker.Protobufs.Objects.SubscriptionPlanChange, Poker.Types;

procedure TfrmSubscriptions.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srSubscriptionPlanChange, CSRSubscriptionPlanChange)
                  ]);
end;

procedure TfrmSubscriptions.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmSubscriptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmSubscriptions.acPayPalExecute(Sender: TObject);
var
  plan: TPlayerSubscriptionPlan;
begin
  if cxButton1.Down then
    plan := pspBasic
  else
    if cxButton2.Down then
      plan := pspNormal
    else
      if cxButton3.Down then
        plan := pspSuper
      else
        Exit;

  ServerSocket.SubscriptionPlanChange(plan);
end;

procedure TfrmSubscriptions.CSRSubscriptionPlanChange(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_SubscriptionPlanChange;
begin
  if not TTypes.TryCast<TPB_SubscriptionPlanChange>(AObject, proto) then
    Exit;
  ShellOpen(PChar(proto.Url));
end;


end.
