unit Poker.Common.FormsContainer;

interface

uses
  System.Generics.Collections, Vcl.Forms;

type
  TForms = TObjectList<TForm>;
  TFormsContainer = class
  private
    FItems: TForms;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure Add(const AForm: TForm);
    procedure Close(const AFormClass: TFormClass);
    procedure Remove(const AForm: TForm); overload;
    procedure Remove(const AFormClass: TFormClass); overload;
    function RunForm(const AFormClass: TFormClass; const AOwner: TForm; const AParams: array of pointer; const AAllowDuplicates: Boolean): TForm;
    procedure CloseAllForms;
    function Find(const AFormClass: TFormClass; out AForm: TForm): Boolean;

    property Items: TForms read FItems;
  end;

var
  FormsContainer: TFormsContainer;

implementation

uses
  Poker.Common.Misc, System.SysUtils;



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
end;

destructor TFormsContainer.Destroy;
begin
  FItems.Free;

  inherited;
end;

procedure TFormsContainer.Add(const AForm: TForm);
begin
  FItems.Add(AForm);
end;

procedure TFormsContainer.Remove(const AForm: TForm);
begin
  FItems.Remove(AForm);
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

procedure TFormsContainer.Close(const AFormClass: TFormClass);
var
  form: TForm;
begin
  while Find(AFormClass, form) do
  begin
    FItems.Remove(form);
    form.Close;
    form.Free;
  end;
end;

procedure TFormsContainer.CloseAllForms;
begin
  while FItems.Count > 0 do
  begin
    FItems[0].Close;
    FItems.Delete(0);
  end;
end;

function TFormsContainer.RunForm(const AFormClass: TFormClass; const AOwner: TForm; const AParams: array of pointer; const AAllowDuplicates: Boolean): TForm;
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
    form := Poker.Common.Misc.RunForm(AFormClass, AOwner, AParams);
    Add(form);
    result := form;
  end;
end;


end.


