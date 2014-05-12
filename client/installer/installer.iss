#define ApplicationName "ChipUP Poker"
#define ApplicationExe "chipuppoker.exe"
#define SkinName "Carbon.vsf"

[Setup]
AppName={#ApplicationName}
AppVerName={#ApplicationName}
DefaultDirName={pf}\{#ApplicationName}
DefaultGroupName={#ApplicationName}
UninstallFilesDir={app}\uninstall
UninstallDisplayName={#ApplicationName}
Compression=lzma2                                                                                 
SolidCompression=yes
OutputDir=.\
OutputBaseFilename=install_chipuppoker
UninstallDisplayIcon={app}\{#ApplicationExe}
DisableProgramGroupPage=yes
AppMutex=CHIPUPINSTANCEMUTEX
WizardImageFile=installer_images\installer-1.bmp
WizardSmallImageFile=installer_images\installer-2.bmp

[Files]
Source: "skins\VclStylesInno.dll"; DestDir: {app}; Flags: uninsneveruninstall ignoreversion
Source: "skins\{#SkinName}"; DestDir: {app}; Flags: ignoreversion

Source: "root_files\*.*"; DestDir: "{app}"; Flags: ignoreversion
Source: "client_files\*.*"; DestDir: "{app}"; Flags: ignoreversion
Source: "ssl_libs\*.*"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; WorkingDir: "{app}"
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#ApplicationExe}"; Description: "Launch ChipUP Poker"; Flags: postinstall nowait runascurrentuser

[Tasks]
Name: desktopicon; Description: "Create a desktop icon"

[Code]
procedure LoadVCLStyleS(VClStyleFile: String); external 'LoadVCLStyleW@files:VclStylesInno.dll stdcall setuponly';
procedure UnLoadVCLStylesS; external 'UnLoadVCLStyles@files:VclStylesInno.dll stdcall setuponly';

procedure LoadVCLStyleU(VClStyleFile: String); external 'LoadVCLStyleW@{app}\VclStylesInno.dll stdcall uninstallonly';
procedure UnLoadVCLStylesU; external 'UnLoadVCLStyles@{app}\VclStylesInno.dll stdcall uninstallonly';

var
  ApplicationUninstalled: Boolean;

function InitializeSetup(): Boolean;
var
  C1    : Integer;
  silent: Boolean;
begin
  ExtractTemporaryFile('{#SkinName}');
  LoadVCLStyleS(ExpandConstant('{tmp}\{#SkinName}'));

  silent := FALSE;
  for C1 := 1 to ParamCount do
    if CompareText(ParamStr(C1), '/verysilent') = 0 then
    begin
      silent := TRUE;
      Break;
    end;

  if silent then
    Sleep(1000);

  result := TRUE;
end;
 
procedure DeinitializeSetup();
begin
  UnLoadVCLStylesS;
end;

function InitializeUninstall(): Boolean;
begin
  LoadVCLStyleU(ExpandConstant('{app}\{#SkinName}'));
  result := TRUE;
end;

procedure InitializeUninstallProgressForm();
begin
  ApplicationUninstalled := TRUE;
end;

procedure DeinitializeUninstall();
begin
  UnLoadVCLStylesU;
  UnloadDLL(ExpandConstant('{app}\VclStylesInno.dll'));

  if ApplicationUninstalled then
  begin
    DeleteFile(ExpandConstant('{app}\VclStylesInno.dll'));
    RemoveDir(ExpandConstant('{app}'));
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  mres: integer;
begin
  case CurUninstallStep of
    usPostUninstall: begin
      mres := MsgBox('Do you want to delete user data?', mbConfirmation, MB_YESNO or MB_DEFBUTTON2)
      if mres = IDYES then
      begin   
        DelTree(ExpandConstant('{localappdata}\ChipUP Poker'), TRUE, TRUE, TRUE);
        DelTree(ExpandConstant('{userappdata}\ChipUP Poker'), TRUE, TRUE, TRUE);
      end;
    end;  
  end;
end;