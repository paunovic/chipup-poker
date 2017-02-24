#define ApplicationName "ChipUP Poker"
#define ApplicationExe "chipuppoker.exe"
#define ApplicationPublisher "ChipUP Poker"
#define ApplicationPublisherURL "http://www.chipuppoker.com"
#define ApplicationInstanceMutex "CHIPUPINSTANCEMUTEX"
#define InstallerFilename "install_chipuppoker"
#define SkinName "Carbon.vsf"
#define AppID "ChipUPPoker"

[Setup]                                                                               
AppName={#ApplicationName}
AppVerName={#ApplicationName}
AppPublisher={#ApplicationPublisher}
AppPublisherURL={#ApplicationPublisherURL}
AppID={#AppID}
DefaultDirName={code:AppInstallPath}
DefaultGroupName={#ApplicationName}
UninstallFilesDir={app}\uninstall
UninstallDisplayName={#ApplicationName}
SolidCompression=yes
OutputDir=.\
DisableDirPage=yes
OutputBaseFilename={#InstallerFilename}
UninstallDisplayIcon={app}\{#ApplicationExe}
DisableProgramGroupPage=yes
DisableReadyPage=yes
AppMutex={#ApplicationInstanceMutex}
WizardImageFile=installer_images\installer-1.bmp
WizardSmallImageFile=installer_images\installer-2.bmp
PrivilegesRequired=lowest

[Files]
Source: "skins\VclStylesInno.dll"; DestDir: "{app}"; Flags: uninsneveruninstall ignoreversion
Source: "skins\{#SkinName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "files\*.*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs; Permissions: everyone-full
   
[Icons]
Name: "{code:StartMenuPath}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; WorkingDir: "{app}"; Tasks: startmenu
Name: "{code:StartMenuPath}\{#ApplicationName}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; WorkingDir: "{app}"; Tasks: startmenu
Name: "{code:StartMenuPath}\{#ApplicationName}\Uninstall"; Filename: "{uninstallexe}"; Tasks: startmenu
Name: "{code:QuickLaunchPath}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; Tasks: quicklaunch
Name: "{code:DesktopIconPath}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#ApplicationExe}"; Description: "Launch {#ApplicationName}"; Flags: postinstall nowait runascurrentuser

[Tasks]
Name: install_allusers; Description: "&All users"; GroupDescription: "Install for:"; Flags: exclusive; Check: IsAllUsersEnabled
Name: install_currentuser; Description: "&Current user"; GroupDescription: "Install for:"; Flags: exclusive unchecked; Check: IsCurrentUserEnabled

Name: desktopicon; Description: "&Desktop shortcut"; GroupDescription: "Shortcuts:"
Name: quicklaunch; Description: "&Quick launch shortcut"; GroupDescription: "Shortcuts:"
Name: startmenu; Description: "&Start menu shortcut"; GroupDescription: "Shortcuts:"

[UninstallDelete]
Type: files; Name: "{app}\assets\*.cpa"
Type: dirifempty; Name: "{app}\assets"

[Messages]
WizardSelectTasks=Select Tasks
SelectTasksDesc=Which tasks should be performed?
SelectTasksLabel2=Select the tasks you would like Setup to perform while installing [name], then click Install.

[Code]
procedure LoadVCLStyleS(VClStyleFile: String); external 'LoadVCLStyleW@files:VclStylesInno.dll stdcall setuponly';
procedure UnLoadVCLStylesS; external 'UnLoadVCLStyles@files:VclStylesInno.dll stdcall setuponly';

procedure LoadVCLStyleU(VClStyleFile: String); external 'LoadVCLStyleW@{app}\VclStylesInno.dll stdcall uninstallonly';
procedure UnLoadVCLStylesU; external 'UnLoadVCLStyles@{app}\VclStylesInno.dll stdcall uninstallonly';

var
  ApplicationUninstalled: Boolean;
  WizardInitialized: Boolean;

function InitializeSetup(): Boolean;
begin
  ExtractTemporaryFile('{#SkinName}');
  LoadVCLStyleS(ExpandConstant('{tmp}\{#SkinName}'));
  result := TRUE;
end;

procedure InitializeWizard();
begin
  WizardInitialized := TRUE;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  WizardForm.DirEdit.Text := ExpandConstant('{code:AppInstallPath}');
  result := '';
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
        DelTree(ExpandConstant('{localappdata}\{#ApplicationName}'), TRUE, TRUE, TRUE);
        DelTree(ExpandConstant('{userappdata}\{#ApplicationName}'), TRUE, TRUE, TRUE);
      end;
    end;  
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  case CurPageID of
    wpSelectTasks: WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);
  end;
end;

function IsCurrentUserInstallChecked: Boolean;
begin
  result := (WizardInitialized) and
            (IsTaskSelected('install_currentuser')); 
end;

function CurrentUserInstallPath: String;
begin
  result := ExpandConstant('{userappdata}\Programs\{#ApplicationName}');
end;

function AllUsersInstallPath: String;
begin
  result := ExpandConstant('{commonappdata}\Programs\{#ApplicationName}');
end;

function AppInstallPath(Param: String): String;
begin
  if IsCurrentUserInstallChecked then
    result := CurrentUserInstallPath
  else
    result := AllUsersInstallPath;
end;

function DesktopIconPath(Param: String): String;
begin
  if IsCurrentUserInstallChecked then
    result := ExpandConstant('{userdesktop}')
  else
    result := ExpandConstant('{commondesktop}');
end;

function StartMenuPath(Param: String): String;
begin
  if IsCurrentUserInstallChecked then
    result := ExpandConstant('{userprograms}')
  else
    result := ExpandConstant('{commonprograms}');
end;

function GetInstallPath(out APath: String): Boolean;
var
  uninstall_path: String;
begin
  result := FALSE;
  APath := '';
  uninstall_path := ExpandConstant('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  if not RegQueryStringValue(HKLM, uninstall_path, 'InstallLocation', APath) then
    RegQueryStringValue(HKCU, uninstall_path, 'InstallLocation', APath);
  result := APath <> '';
end;

function QuickLaunchPath(Param: String): String;
begin
  if IsCurrentUserInstallChecked then
    result := ExpandConstant('{userappdata}\Microsoft\Internet Explorer\Quick Launch')
  else
    result := ExpandConstant('{commonappdata}\Microsoft\Internet Explorer\Quick Launch')
end;

function CheckInstallPath(const APath: String): Boolean;
var
  path: String;
begin
  result := TRUE;
  if not GetInstallPath(path) then 
    Exit;
  result := LowerCase(AddBackslash(path)) = LowerCase(AddBackslash(APath));
end;

function IsAllUsersEnabled: Boolean;
begin
  result := (CheckInstallPath(AllUsersInstallPath)) and
            ((IsAdminLoggedOn) or
             (IsPowerUserLoggedOn));
end;

function IsCurrentUserEnabled: Boolean;
begin
  result := CheckInstallPath(CurrentUserInstallPath);
end;