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
Source: "skins\VclStylesInno.dll"; DestDir: {app}; Flags: uninsneveruninstall
Source: "skins\{#SkinName}"; DestDir: {app}

Source: "client_files\*.*"; DestDir: "{app}"
Source: "ssl_libs\*.*"; DestDir: "{app}"

Source: "fonts\Sintony-Regular.ttf"; DestDir: "{fonts}"; FontInstall: "Sintony"; Flags: uninsneveruninstall
Source: "fonts\Sintony-Bold.ttf"; DestDir: "{fonts}"; FontInstall: "Sintony"; Flags: uninsneveruninstall
Source: "fonts\Barmeno-Regular.ttf"; DestDir: "{fonts}"; FontInstall: "Barmeno"; Flags: uninsneveruninstall
Source: "fonts\Barmeno-Bold.ttf"; DestDir: "{fonts}"; FontInstall: "Barmeno"; Flags: uninsneveruninstall

[Icons]
Name: "{group}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; WorkingDir: "{app}"
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#ApplicationExe}"; Description: "Launch ChipUP Poker"; Flags: postinstall nowait skipifsilent runascurrentuser

[Tasks]
Name: desktopicon; Description: "Create a desktop icon"

[Code]
procedure LoadVCLStyleS(VClStyleFile: String); external 'LoadVCLStyleW@files:VclStylesInno.dll stdcall setuponly';
procedure UnLoadVCLStylesS; external 'UnLoadVCLStyles@files:VclStylesInno.dll stdcall setuponly';

procedure LoadVCLStyleU(VClStyleFile: String); external 'LoadVCLStyleW@{app}\VclStylesInno.dll stdcall uninstallonly';
procedure UnLoadVCLStylesU; external 'UnLoadVCLStyles@{app}\VclStylesInno.dll stdcall uninstallonly';

function InitializeSetup(): Boolean;
begin
  ExtractTemporaryFile('{#SkinName}');
  LoadVCLStyleS(ExpandConstant('{tmp}\{#SkinName}'));
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

procedure DeinitializeUninstall();
begin
  UnLoadVCLStylesU;
  UnloadDLL(ExpandConstant('{app}\VclStylesInno.dll'));
  DeleteFile(ExpandConstant('{app}\VclStylesInno.dll'));
  RemoveDir(ExpandConstant('{app}'));
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