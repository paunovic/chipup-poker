unit Poker.WindowMessages;

interface

uses
  Winapi.Messages;

const
  WM_SOCKET_SERVER_REPLY = WM_APP + 1;
  WM_SOCKET_STATE_CHANGE = WM_APP + 2;
  WM_DIRECTX_ANIMATION = WM_APP + 3;
  WM_TABLESTATUS_REFRESH = WM_APP + 4;

implementation

end.
