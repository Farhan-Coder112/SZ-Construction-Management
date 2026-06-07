[Setup]
AppName=SZ Construction Management
AppVersion=1.1.0
AppPublisher=SZ Group
DefaultDirName={commonpf}\SZ Construction Management
DefaultGroupName=SZ Construction Management
OutputBaseFile=SZ_Construction_Management_Setup_v1.1.0
Compression=lzma
SolidCompression=yes
WizardImageFile=assets\images\logo.png
WizardSmallImageFile=assets\images\logo.png
UninstallDisplayIcon={app}\sz_construction_management.exe
SetupIconFile=assets\images\logo.png
PrivilegesRequired=admin

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\SZ Construction Management"; Filename: "{app}\sz_construction_management.exe"
Name: "{group}\Uninstall SZ Construction Management"; Filename: "{uninstallexe}"
Name: "{commondesktop}\SZ Construction Management"; Filename: "{app}\sz_construction_management.exe"

[Run]
Filename: "{app}\sz_construction_management.exe"; Description: "Launch SZ Construction Management"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
