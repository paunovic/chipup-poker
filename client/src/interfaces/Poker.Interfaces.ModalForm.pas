unit Poker.Interfaces.ModalForm;

interface

uses
  System.Classes;

type
  IModalForm = interface
  ['{8508D3A7-345C-407E-B06A-0663445099E6}']
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;


implementation

end.
