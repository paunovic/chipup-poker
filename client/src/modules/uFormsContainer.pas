unit uFormsContainer;

interface

uses
  System.Generics.Collections, Vcl.Forms;

type
  TFormsContainer = class
  private
    FItems: TObjectList<TForm>;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure Add(const AForm: TForm);
    procedure Remove(const AForm: TForm); overload;
    procedure Remove(const AFormClass: TFormClass); overload;
    function RunForm(const AFormClass: TFormClass; const AOwner: TForm; const AParams: array of pointer; const AAllowDuplicates: Boolean): TForm;
    procedure CloseAllForms;
    function Find(const AFormClass: TFormClass; out AForm: TForm): Boolean;
  end;

var
  FormsContainer: TFormsContainer;

implementation

uses
  uCommon, System.SysUtils;



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
  FItems := TObjectList<TForm>.Create(FALSE);
end;

destructor TFormsContainer.Destroy;
begin
  CloseAllForms;
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

procedure TFormsContainer.CloseAllForms;
var
  form: TForm;
begin
  for form in FItems do
    form.Free;
  FItems.Clear;
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
    form := uCommon.RunForm(AFormClass, AOwner, AParams);
    Add(form);
    result := form;
  end;
end;


end.


