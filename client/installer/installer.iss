#define ApplicationName "ChipUP Poker"
#define ApplicationExe "chipuppoker.exe"

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
Source: "client_files\*.*"; DestDir: "{app}"
Source: "ssl_libs\*.*"; DestDir: "{app}"

[Icons]
Name: "{group}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; WorkingDir: "{app}"
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#ApplicationExe}"; Description: "Launch ChipUP Poker"; Flags: postinstall nowait skipifsilent runascurrentuser

[Tasks]
Name: desktopicon; Description: "Create a desktop icon"

[Code]
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