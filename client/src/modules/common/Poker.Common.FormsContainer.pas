unit Poker.Common.FormsContainer;

interface

uses
  System.Generics.Collections, Vcl.Forms;

type
  TForms = TObjectList<TForm>;
  TFormsContainer = class
  private
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
    procedure Close(const AFormClass: TFormClass);
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

implementation

uses
  Winapi.Windows, Poker.Common.Misc, System.SysUtils;


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
  FItems := TForms.Create(FALSE);
  FStates := TList<Boolean>.Create;
end;

destructor TFormsContainer.Destroy;
begin
  FStates.Free;
  FItems.Free;

  inherited;
end;

procedure TFormsContainer.Add(const AForm: TForm);
begin
  FItems.Add(AForm);
end;

procedure TFormsContainer.Remove(const AForm: TForm);
var
  index: Integer;
begin
  index := FItems.IndexOf(AForm);
  if index = -1 then
    Exit;

  FItems.Delete(index);
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
  for form in FItems do
    if form is AFormClass then
    begin
      AForm := form;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

function TFormsContainer.Contains(const AFormClass: TFormClass): Boolean;
var
  form: TForm;
begin
  for form in FItems do
    if form is AFormClass then
      Exit(TRUE);
  Exit(FALSE);
end;

procedure TFormsContainer.Close(const AFormClass: TFormClass);
var
  form: TForm;
begin
  while Find(AFormClass, form) do
  begin
    Remove(form);
    form.Close;
  end;
end;

procedure TFormsContainer.CloseAllForms;
var
  C1: Integer;
begin
  for C1 := 0 to FItems.Count - 1 do
    FItems[C1].Close;
  FItems.Clear;
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
    form := Poker.Common.Misc.RunForm(AFormClass, AOwner, AParams, AShow);
    Add(form);
    result := form;
  end;
end;

procedure TFormsContainer.DisableAll;
var
  C1: Integer;
begin
  for C1 := 0 to FItems.Count - 1 do
    EnableWindow(FItems[C1].Handle, FALSE);
end;

procedure TFormsContainer.ResetState;
var
  C1: Integer;
begin
  for C1 := 0 to FStates.Count - 1 do
    EnableWindow(FItems[C1].Handle, FStates[C1]);
end;

procedure TFormsContainer.SaveState;
var
  C1: Integer;
begin
  FStates.Clear;
  for C1 := 0 to FItems.Count - 1 do
    FStates.Add(IsWindowEnabled(FItems[C1].Handle));
end;

end.


