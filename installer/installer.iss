#define ApplicationName "BadassPoker"
#define ApplicationExe "badasspoker.exe"

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
OutputBaseFilename=setup
UninstallDisplayIcon={app}\{#ApplicationExe}
DisableProgramGroupPage=yes
AppMutex=FileSyncerClientInstanceMutex
WizardImageFile=setup_images\big.bmp
WizardSmallImageFile=setup_images\small.bmp
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "pfiles_x86\*.*"; DestDir: "{app}"; Check: not Is64BitInstallMode
Source: "pfiles_x64\*.*"; DestDir: "{app}"; Check: Is64BitInstallMode

[Icons]
Name: "{group}\{#ApplicationName}"; Filename: "{app}\{#ApplicationExe}"; WorkingDir: "{app}"
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#ApplicationExe}"; Description: "Launch BadassPoker"; Flags: postinstall nowait skipifsilent runascurrentuser