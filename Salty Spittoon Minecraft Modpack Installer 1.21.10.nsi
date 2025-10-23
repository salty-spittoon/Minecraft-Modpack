InstallDir  "$APPDATA\.minecraft"
Name        "Salty Spittoon Minecraft Modpack Installer 1.21.10"        
OutFile     "Modpack Installer 1.21.10.exe"
Icon        "icon.ico"
UninstallIcon "icon.ico"

VIProductVersion                 "1.21.10.0"
VIAddVersionKey ProductName      "Salty Spittoon Minecraft Modpack"
VIAddVersionKey Publisher        "salty5844"
VIAddVersionKey LegalCopyright   "Salty Spittoon"
VIAddVersionKey FileDescription  "Minecraft Modpack installer for Salty Spittoon"
VIAddVersionKey FileVersion      1.21.10.0

# Define registry key for uninstaller
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\SaltySpittoonModpack"

# Request admin privileges for folder operations
RequestExecutionLevel admin

# Include Modern UI and nsDialogs
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"

# MUI Settings - Icons
!define MUI_ICON "icon.ico"
!define MUI_UNICON "icon.ico"

# Pages
Page custom ChoicePage ChoicePageLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Languages
!insertmacro MUI_LANGUAGE "English"

# Variables
Var Dialog
Var Label
Var InstallButton
Var UninstallButton
Var Choice

# Custom choice page
Function ChoicePage
  nsDialogs::Create 1018
  Pop $Dialog
  
  ${If} $Dialog == error
    Abort
  ${EndIf}
  
  # Hide default Next/Back buttons so only our Install/Uninstall buttons are visible
  GetDlgItem $0 $HWNDPARENT 1
  ShowWindow $0 ${SW_HIDE}
  GetDlgItem $1 $HWNDPARENT 3
  ShowWindow $1 ${SW_HIDE}
  
  ${NSD_CreateLabel} 0 0 100% 20u "What would you like to do?"
  Pop $Label
  
  ${NSD_CreateButton} 80u 40u 80u 20u "Install"
  Pop $InstallButton
  ${NSD_OnClick} $InstallButton InstallButtonClick
  
  ${NSD_CreateButton} 170u 40u 80u 20u "Uninstall"
  Pop $UninstallButton
  ${NSD_OnClick} $UninstallButton UninstallButtonClick
  
  nsDialogs::Show
FunctionEnd

Function InstallButtonClick
  StrCpy $Choice "install"
  SendMessage $HWNDPARENT 0x408 1 0
FunctionEnd

Function UninstallButtonClick
  StrCpy $Choice "uninstall"
  SendMessage $HWNDPARENT 0x408 1 0
FunctionEnd

Function ChoicePageLeave
  # Restore default wizard buttons for subsequent pages
  GetDlgItem $0 $HWNDPARENT 1
  ShowWindow $0 ${SW_SHOW}
  GetDlgItem $1 $HWNDPARENT 3
  ShowWindow $1 ${SW_SHOW}

  ${If} $Choice == ""
    Abort
  ${EndIf}
FunctionEnd

Section
 
${If} $Choice == "uninstall"
  # Confirm uninstallation
  MessageBox MB_YESNO "This will remove all existing mods, resource packs, and shader packs from your .minecraft folder. Continue?" IDYES do_uninstall IDNO uninstall_cancel

  do_uninstall:
  # Remove contents of mods folder (mirror install clear logic)
  Delete "$INSTDIR\mods\*.*"
  RMDir /r "$INSTDIR\mods"
  CreateDirectory "$INSTDIR\mods"

  # Remove contents of resourcepacks folder
  Delete "$INSTDIR\resourcepacks\*.*"
  RMDir /r "$INSTDIR\resourcepacks"
  CreateDirectory "$INSTDIR\resourcepacks"

  # Remove contents of shaderpacks folder
  Delete "$INSTDIR\shaderpacks\*.*"
  RMDir /r "$INSTDIR\shaderpacks"
  CreateDirectory "$INSTDIR\shaderpacks"

  MessageBox MB_OK "Salty Spittoon modpack files have been removed successfully."
  Quit

  uninstall_cancel:
  Quit
${EndIf}

# create a popup box, with an OK button and the text "Hello world!"
MessageBox MB_OK 'Salty Spittoon Minecraft Modpack Installer copies our current mods, resource packs, and shaders to your .minecraft folder. Fabric mod loader will be installed and there will be a new profile for you to use in the Minecraft Launcher called, "fabric-loader-1.21.10"'

# Clear existing mod folders before installation
MessageBox MB_YESNO "This will remove all existing mods, resource packs, and shader packs from your .minecraft folder. Continue?" IDYES clearfolders IDNO install_cancel

clearfolders:
# Remove contents of mods folder
Delete "$INSTDIR\mods\*.*"
RMDir /r "$INSTDIR\mods"
CreateDirectory "$INSTDIR\mods"

# Remove contents of resourcepacks folder
Delete "$INSTDIR\resourcepacks\*.*"
RMDir /r "$INSTDIR\resourcepacks"
CreateDirectory "$INSTDIR\resourcepacks"

# Remove contents of shaderpacks folder
Delete "$INSTDIR\shaderpacks\*.*"
RMDir /r "$INSTDIR\shaderpacks" 
CreateDirectory "$INSTDIR\shaderpacks"

Goto install

install_cancel:
Quit

install:
 
SectionEnd

Section
 
# define the output path for this file
SetOutPath $INSTDIR
 
# define what to install and place it in the output path
File /nonfatal /a /r "minecraft\"
 
SectionEnd

Section

File "fabric.exe"
ExecWait '"$INSTDIR\fabric.exe"'
Delete $INSTDIR\fabric.exe

# Create uninstaller
WriteUninstaller "$INSTDIR\uninstall_salty_spittoon.exe"

# Write registry entries for Add/Remove Programs
WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "Salty Spittoon Minecraft Modpack"
WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\uninstall_salty_spittoon.exe"'
WriteRegStr HKLM "${UNINST_KEY}" "QuietUninstallString" '"$INSTDIR\uninstall_salty_spittoon.exe" /S'
WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "1.21.10"
WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "salty5844"
WriteRegStr HKLM "${UNINST_KEY}" "DisplayIcon" "$INSTDIR\uninstall_salty_spittoon.exe"
WriteRegStr HKLM "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" 1
WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" 1

# end the section
Quit
SectionEnd

# Uninstaller section
Section "un.Uninstall"

# Confirm uninstallation
MessageBox MB_YESNO "This will remove all Salty Spittoon modpack files (mods, resource packs, and shader packs) from your .minecraft folder. Continue?" IDYES uninstall IDNO cancel

uninstall:
# Remove contents of mods folder (mirror install clear logic)
Delete "$INSTDIR\mods\*.*"
RMDir /r "$INSTDIR\mods"
CreateDirectory "$INSTDIR\mods"

# Remove contents of resourcepacks folder
Delete "$INSTDIR\resourcepacks\*.*"
RMDir /r "$INSTDIR\resourcepacks"
CreateDirectory "$INSTDIR\resourcepacks"

# Remove contents of shaderpacks folder
Delete "$INSTDIR\shaderpacks\*.*"
RMDir /r "$INSTDIR\shaderpacks"
CreateDirectory "$INSTDIR\shaderpacks"

# Remove uninstaller
Delete "$INSTDIR\uninstall_salty_spittoon.exe"

# Remove registry entries
DeleteRegKey HKLM "${UNINST_KEY}"

MessageBox MB_OK "Salty Spittoon Minecraft Modpack has been uninstalled successfully."
Goto done

cancel:
Quit

done:

SectionEnd

# Uninstaller initialization function
Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd