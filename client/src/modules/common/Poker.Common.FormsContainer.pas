unit Poker.Common.FormsContainer;

interface

uses
  System.Generics.Collections, Vcl.Forms, Poker.Common.SafeMutex, System.Classes;

type
  TForms = TObjectList<TForm>;
  TFormsContainer = class
  private
    FLock: TSafeMutex;
    FItems: TForms;
    FStates: TList<Boolean>;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure DisableAll;

    procedure SaveState;
    procedure ResetState;

    procedure Add(const AForm: TForm);
    procedure Close(const AFormClass: TFormClass); overload;
    procedure Close(const AForm: TForm); overload;
    procedure Remove(const AForm: TForm); overload;
    procedure Remove(const AFormClass: TFormClass); overload;
    function RunForm(const AFormClass: TFormClass; const AOwner: TForm; const AParams: array of pointer; const AAllowDuplicates: Boolean; const AShow: Boolean = TRUE): TForm;
    procedure CloseAllForms;
    function Find(const AFormClass: TFormClass; out AForm: TForm): Boolean;
    function Contains(const AFormClass: TFormClass): Boolean;

    property Items: TForms read FItems;
  end;

var
  FormsContainer: TFormsContainer;

function RunModalForm(const AClassType: TFormClass; const AOwner: TForm; const AParams: array of pointer; const ACloseCallback: TNotifyEvent): TForm;
function RunForm(const AClassType: TFormClass; const AOwner: TForm; const AParams: array of pointer; const AShow: Boolean): TForm;

implementation

uses
  Winapi.Windows, Poker.Common.Misc, System.SysUtils, Poker.Interfaces.FormParams, Poker.Interfaces.ModalForm;



function RunModalForm(const AClassType: TFormClass; const AOwner: TForm; const AParams: array of pointer; const ACloseCallback: TNotifyEvent): TForm;
var
  form: TForm;
begin
  form := AClassType.Create(AOwner);

  if Assigned(AOwner) then
  begin
    form.PopupParent := AOwner;
    EnableWindow(AOwner.Handle, FALSE);
  end;

  if Length(AParams) > 0 then
    (form as IFormParams).SetParams(AParams);

  if Assigned(ACloseCallback) then
    (form as IModalForm).SetCloseCallback(ACloseCallback);

  form.Show;

  result := form;
end;

function RunForm(const AClassType: TFormClass; const AOwner: TForm; const AParams: array of pointer; const AShow: Boolean): TForm;
var
  form: TForm;
begin
  form := AClassType.Create(AOwner);

  if Assigned(AOwner) then
    form.PopupParent := AOwner;

  if Length(AParams) > 0 then
    (form as IFormParams).SetParams(AParams);

  if AShow then
    form.Show;

  result := form;
end;


class procedure TFormsContainer.Initialize;
begin
  FormsContainer := TFormsContainer.Create;
end;

class procedure TFormsContainer.Deinitialize;
begin
  FreeAndNil(FormsContainer);
end;


constructor TFormsContainer.Create;
begin
  FLock := TSafeMutex.Create;
  FItems := TForms.Create(FALSE);
  FStates := TList<Boolean>.Create;
end;

destructor TFormsContainer.Destroy;
begin
  FStates.Free;
  FItems.Free;
  FreeAndNil(FLock);
  inherited;
end;

procedure TFormsContainer.Add(const AForm: TForm);
begin
  FLock.Acquire;
  try
    FItems.Add(AForm);
  finally
    FLock.Release;
  end;
end;

procedure TFormsContainer.Remove(const AForm: TForm);
var
  index: Integer;
begin
  FLock.Acquire;
  try
    index := FItems.IndexOf(AForm);
    if index >= 0 then
      FItems.Delete(index);
  finally
    FLock.Release;
  end;
end;

procedure TFormsContainer.Remove(const AFormClass: TFormClass);
var
  form: TForm;
begin
  if Find(AFormClass, form) then
    Remove(form);
end;

function TFormsContainer.Find(const AFormClass: TFormClass; out AForm: TForm): Boolean;
var
  form: TForm;
begin
  FLock.Acquire;
  try
    for form in FItems do
      if form is AFormClass then
      begin
        AForm := form;
        Exit(TRUE);
      end;
    Exit(FALSE);
  finally
    FLock.Release;
  end;
end;

function TFormsContainer.Contains(const AFormClass: TFormClass): Boolean;
var
  form: TForm;
begin
  FLock.Acquire;
  try
    for form in FItems do
      if form is AFormClass then
        Exit(TRUE);
    Exit(FALSE);
  finally
    FLock.Release;
  end;
end;

procedure TFormsContainer.Close(const AFormClass: TFormClass);
var
  form: TForm;
begin
  while Find(AFormClass, form) do
  begin
    form.Close;
    Remove(form);
  end;
end;

procedure TFormsContainer.Close(const AForm: TForm);
var
  C1: Integer;
begin
  FLock.Acquire;
  try
    for C1 := FItems.Count - 1 downto 0 do
      if FItems[C1] = AForm then
      begin
        AForm.Close;
        FItems.Delete(C1);
      end;
  finally
    FLock.Release;
  end;
end;

procedure TFormsContainer.CloseAllForms;
var
  C1: Integer;
begin
  FLock.Acquire;
  try
    for C1 := 0 to FItems.Count - 1 do
      FItems[C1].Close;
    FItems.Clear;
  finally
    FLock.Release;
  end;
end;

function TFormsContainer.RunForm(const AFormClass: TFormClass; const AOwner: TForm; const AParams: array of pointer; const AAllowDuplicates: Boolean; const AShow: Boolean = TRUE): TForm;
var
  form: TForm;
begin
  if (not AAllowDuplicates) and
     (Find(AFormClass, form)) then
  begin
    form.SetFocus;
    result := form;
  end
  else
  begin
    form := Poker.Common.FormsContainer.RunForm(AFormClass, AOwner, AParams, AShow);
    Add(form);
    result := form;
  end;
end;

procedure TFormsContainer.DisableAll;
var
  C1: Integer;
begin
  FLock.Acquire;
  try
    for C1 := 0 to FItems.Count - 1 do
      EnableWindow(FItems[C1].Handle, FALSE);
  finally
    FLock.Release;
  end;
end;

procedure TFormsContainer.ResetState;
var
  C1: Integer;
begin
  FLock.Acquire;
  try
    for C1 := 0 to FStates.Count - 1 do
      EnableWindow(FItems[C1].Handle, FStates[C1]);
  finally
    FLock.Release;
  end;
end;

procedure TFormsContainer.SaveState;
var
  C1: Integer;
begin
  FLock.Acquire;
  try
    FStates.Clear;
    for C1 := 0 to FItems.Count - 1 do
      FStates.Add(IsWindowEnabled(FItems[C1].Handle));
  finally
    FLock.Release;
  end;
end;

end.


