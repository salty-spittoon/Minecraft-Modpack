!define MODPACK_VERSION "1.21.11.1"
!define MODPACK_NAME "Salty Spittoon Minecraft Modpack"

InstallDir  "$APPDATA\.minecraft"
Name        "${MODPACK_NAME} Installer ${MODPACK_VERSION}"
OutFile     "C:\Users\ratsc\Downloads\${MODPACK_NAME} Installer ${MODPACK_VERSION}.exe"
Icon        "icon.ico"
UninstallIcon "icon.ico"

VIProductVersion                 "${MODPACK_VERSION}"
VIAddVersionKey ProductName      "${MODPACK_NAME}"
VIAddVersionKey CompanyName      "Taylor Kerr"
VIAddVersionKey LegalCopyright   "(c) Taylor Kerr"
VIAddVersionKey FileDescription  "Minecraft modpack installer for the Salty Spittoon"
VIAddVersionKey FileVersion      "${MODPACK_VERSION}"

!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\SaltySpittoonModpack"

RequestExecutionLevel user

!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"
!include "FileFunc.nsh"
!include "WordFunc.nsh"

!define MUI_ICON "icon.ico"
!define MUI_UNICON "icon.ico"

Page custom ChoicePage ChoicePageLeave

!define MUI_PAGE_CUSTOMFUNCTION_SHOW InstFilesShow
!insertmacro MUI_PAGE_INSTFILES
!ifdef MUI_PAGE_CUSTOMFUNCTION_SHOW
  !undef MUI_PAGE_CUSTOMFUNCTION_SHOW
!endif

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Var Dialog
Var InfoLabel
Var InstallButton
Var UninstallButton
Var Choice
Var BackupFolder
Var YY
Var YYYY
Var MM
Var DD
Var HH
Var Min
Var HasPrevManifest
Var InstalledVersion
Var CompareResult
Var PrimaryAction
Var SecondaryAction
Var HideTimer
Var LocalTimePtr

Function .onInit
  SetShellVarContext current
  StrCpy $INSTDIR "$APPDATA\.minecraft"
  Call DetectInstalledState
FunctionEnd

Function InstFilesShow
  GetDlgItem $0 $HWNDPARENT 1
  SendMessage $0 ${BM_CLICK} 0 0
FunctionEnd

Function HideNavButtons
  GetDlgItem $0 $HWNDPARENT 1
  ShowWindow $0 ${SW_HIDE}
  EnableWindow $0 0

  GetDlgItem $1 $HWNDPARENT 3
  ShowWindow $1 ${SW_HIDE}
  EnableWindow $1 0
FunctionEnd

Function ShowNavButtons
  GetDlgItem $0 $HWNDPARENT 1
  ShowWindow $0 ${SW_SHOW}
  EnableWindow $0 1

  GetDlgItem $1 $HWNDPARENT 3
  ShowWindow $1 ${SW_SHOW}
  EnableWindow $1 1
FunctionEnd

Function TrimCRLF
  Exch $0
  Push $1

  StrCpy $1 $0 1 -1
  StrCmp $1 "$\n" 0 +2
    StrCpy $0 $0 -1

  StrCpy $1 $0 1 -1
  StrCmp $1 "$\r" 0 +2
    StrCpy $0 $0 -1

  Pop $1
  Exch $0
FunctionEnd

Function un.TrimCRLF
  Exch $0
  Push $1

  StrCpy $1 $0 1 -1
  StrCmp $1 "$\n" 0 +2
    StrCpy $0 $0 -1

  StrCpy $1 $0 1 -1
  StrCmp $1 "$\r" 0 +2
    StrCpy $0 $0 -1

  Pop $1
  Exch $0
FunctionEnd

Function ReadManifestVersion
  Push $0
  Push $1
  Push $2
  Push $3

  StrCpy $0 "0.0.0.0"

  IfFileExists "$INSTDIR\salty_manifest.txt" 0 done

  ClearErrors
  FileOpen $1 "$INSTDIR\salty_manifest.txt" r
  IfErrors done

  loop:
    ClearErrors
    FileRead $1 $2
    IfErrors end

    Push $2
    Call TrimCRLF
    Pop $2

    StrCmp $2 "" loop

    StrCpy $3 $2 8
    StrCmp $3 "Version=" 0 end
      StrCpy $0 $2 "" 8
      Goto end

  end:
    FileClose $1

  done:
    Pop $3
    Pop $2
    Pop $1
    Exch $0
FunctionEnd

Function DetectInstalledState
  StrCpy $HasPrevManifest "0"
  StrCpy $InstalledVersion "0.0.0.0"
  StrCpy $CompareResult "1"

  IfFileExists "$INSTDIR\salty_manifest.txt" 0 done
    StrCpy $HasPrevManifest "1"
    Call ReadManifestVersion
    Pop $InstalledVersion
    ${VersionCompare} "${MODPACK_VERSION}" "$InstalledVersion" $CompareResult

  done:
FunctionEnd

; =========================
; INSTALLER-SIDE SHARED DELETE
; =========================
Function DeleteManifestListedFile
  Exch $0
  Push $1
  Push $2

  ; strip leading ".\" if present
  StrCpy $2 $0 2
  StrCmp $2 ".\" 0 +2
    StrCpy $0 $0 "" 2

  ; strip leading "\" if present
  StrCpy $2 $0 1
  StrCmp $2 "\" 0 +2
    StrCpy $0 $0 "" 1

  StrCpy $1 "$INSTDIR\$0"

  IfFileExists "$1" 0 done
  SetFileAttributes "$1" NORMAL
  Delete "$1"

  done:
    Pop $2
    Pop $1
    Pop $0
FunctionEnd

Function RemoveFilesFromManifest
  Exch $0
  Push $1
  Push $2
  Push $3
  Push $4

  IfFileExists "$0" 0 done

  ClearErrors
  FileOpen $1 "$0" r
  IfErrors done

  loop:
    ClearErrors
    FileRead $1 $2
    IfErrors end

    Push $2
    Call TrimCRLF
    Pop $3

    StrCmp $3 "" loop

    StrCpy $4 $3 8
    StrCmp $4 "Version=" loop

    StrCpy $4 $3 5
    StrCmp $4 "mods\" check_jar check_resourcepacks

  check_resourcepacks:
    StrCpy $4 $3 14
    StrCmp $4 "resourcepacks\" check_zip check_shaderpacks

  check_shaderpacks:
    StrCpy $4 $3 12
    StrCmp $4 "shaderpacks\" check_zip loop

  check_jar:
    StrCpy $4 $3 4 -4
    StrCmp $4 ".jar" 0 loop
    Push $3
    Call DeleteManifestListedFile
    Goto loop

  check_zip:
    StrCpy $4 $3 4 -4
    StrCmp $4 ".zip" 0 loop
    Push $3
    Call DeleteManifestListedFile
    Goto loop

  end:
    FileClose $1

  done:
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
FunctionEnd

; =========================
; UNINSTALLER-SIDE SHARED DELETE
; =========================
Function un.DeleteManifestListedFile
  Exch $0
  Push $1
  Push $2

  ; strip leading ".\" if present
  StrCpy $2 $0 2
  StrCmp $2 ".\" 0 +2
    StrCpy $0 $0 "" 2

  ; strip leading "\" if present
  StrCpy $2 $0 1
  StrCmp $2 "\" 0 +2
    StrCpy $0 $0 "" 1

  StrCpy $1 "$INSTDIR\$0"

  IfFileExists "$1" 0 done
  SetFileAttributes "$1" NORMAL
  Delete "$1"

  done:
    Pop $2
    Pop $1
    Pop $0
FunctionEnd

Function un.RemoveFilesFromManifest
  Exch $0
  Push $1
  Push $2
  Push $3
  Push $4

  IfFileExists "$0" 0 done

  ClearErrors
  FileOpen $1 "$0" r
  IfErrors done

  loop:
    ClearErrors
    FileRead $1 $2
    IfErrors end

    Push $2
    Call un.TrimCRLF
    Pop $3

    StrCmp $3 "" loop

    StrCpy $4 $3 8
    StrCmp $4 "Version=" loop

    StrCpy $4 $3 5
    StrCmp $4 "mods\" check_jar check_resourcepacks

  check_resourcepacks:
    StrCpy $4 $3 14
    StrCmp $4 "resourcepacks\" check_zip check_shaderpacks

  check_shaderpacks:
    StrCpy $4 $3 12
    StrCmp $4 "shaderpacks\" check_zip loop

  check_jar:
    StrCpy $4 $3 4 -4
    StrCmp $4 ".jar" 0 loop
    Push $3
    Call un.DeleteManifestListedFile
    Goto loop

  check_zip:
    StrCpy $4 $3 4 -4
    StrCmp $4 ".zip" 0 loop
    Push $3
    Call un.DeleteManifestListedFile
    Goto loop

  end:
    FileClose $1

  done:
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
FunctionEnd

Function MoveMatchingFiles
  Exch $2
  Exch 1
  Exch $1
  Exch 2
  Exch $0
  Push $3
  Push $4

  CreateDirectory "$2"

  FindFirst $3 $4 "$0\$1"
  StrCmp $4 "" done

  loop:
    Rename "$0\$4" "$2\$4"
    FindNext $3 $4
    StrCmp $4 "" done
    Goto loop

  done:
    FindClose $3

    Pop $4
    Pop $3
    Pop $0
    Pop $1
    Pop $2
FunctionEnd

Function MakeBackupFolders
  System::Alloc 16
  Pop $LocalTimePtr
  StrCpy $8 $LocalTimePtr
  System::Call "kernel32::GetLocalTime(p r8)"
  System::Call "*$8(&i2.r0,&i2.r1,&i2.r2,&i2.r3,&i2.r4,&i2.r5,&i2.r6,&i2.r7)"
  System::Free $8

  IntFmt $YYYY "%04u" $0
  IntFmt $MM   "%02u" $1
  IntFmt $DD   "%02u" $3
  IntFmt $HH   "%02u" $4
  IntFmt $Min  "%02u" $5
  IntFmt $6    "%02u" $6

  StrCpy $YY $YYYY 2 2
  StrCpy $BackupFolder "backup_$MM-$DD-$YY-$HH$Min$6"

  CreateDirectory "$INSTDIR\$BackupFolder"
  CreateDirectory "$INSTDIR\$BackupFolder\mods"
  CreateDirectory "$INSTDIR\$BackupFolder\resourcepacks"
  CreateDirectory "$INSTDIR\$BackupFolder\shaderpacks"

  CreateDirectory "$INSTDIR\mods"
  CreateDirectory "$INSTDIR\resourcepacks"
  CreateDirectory "$INSTDIR\shaderpacks"

  Push "$INSTDIR\mods"
  Push "*.jar"
  Push "$INSTDIR\$BackupFolder\mods"
  Call MoveMatchingFiles

  Push "$INSTDIR\resourcepacks"
  Push "*.zip"
  Push "$INSTDIR\$BackupFolder\resourcepacks"
  Call MoveMatchingFiles

  Push "$INSTDIR\shaderpacks"
  Push "*.zip"
  Push "$INSTDIR\$BackupFolder\shaderpacks"
  Call MoveMatchingFiles
FunctionEnd

Function RemoveInstalledModpack
  IfFileExists "$INSTDIR\salty_manifest.txt" 0 done

  Push "$INSTDIR\salty_manifest.txt"
  Call RemoveFilesFromManifest

  Delete "$INSTDIR\salty_manifest.txt"
  Delete "$INSTDIR\uninstall_salty_spittoon.exe"
  DeleteRegKey HKCU "${UNINST_KEY}"

  done:
FunctionEnd

; =========================
; UI Page
; =========================
Function ChoicePage
  nsDialogs::Create 1018
  Pop $Dialog
  ${If} $Dialog == error
    Abort
  ${EndIf}

  Call HideNavButtons
  nsDialogs::CreateTimer HideNavButtons 25
  Pop $HideTimer

  StrCpy $PrimaryAction ""
  StrCpy $SecondaryAction ""

  ${If} $HasPrevManifest == "0"
    ${NSD_CreateLabel} 0 0 100% 30u "No Salty Spittoon installation was detected.$\r$\n$\r$\nWould you like to install version ${MODPACK_VERSION}?"
    Pop $InfoLabel

    ${NSD_CreateButton} 125u 40u 80u 20u "Install"
    Pop $InstallButton
    ${NSD_OnClick} $InstallButton PrimaryButtonClick

    StrCpy $PrimaryAction "install"

  ${Else}
    ${If} $CompareResult == "1"
      ${NSD_CreateLabel} 0 0 100% 36u "Older version detected: $InstalledVersion$\r$\n$\r$\nWould you like to upgrade to version ${MODPACK_VERSION} or uninstall the existing version?"
      Pop $InfoLabel

      ${NSD_CreateButton} 80u 48u 80u 20u "Upgrade"
      Pop $InstallButton
      ${NSD_OnClick} $InstallButton PrimaryButtonClick

      ${NSD_CreateButton} 170u 48u 80u 20u "Uninstall"
      Pop $UninstallButton
      ${NSD_OnClick} $UninstallButton SecondaryButtonClick

      StrCpy $PrimaryAction "update"
      StrCpy $SecondaryAction "uninstall"

    ${ElseIf} $CompareResult == "0"
      ${NSD_CreateLabel} 0 0 100% 30u "Version $InstalledVersion is already installed.$\r$\n$\r$\nWould you like to uninstall it?"
      Pop $InfoLabel

      ${NSD_CreateButton} 125u 40u 80u 20u "Uninstall"
      Pop $InstallButton
      ${NSD_OnClick} $InstallButton PrimaryButtonClick

      StrCpy $PrimaryAction "uninstall"

    ${Else}
      ${NSD_CreateLabel} 0 0 100% 36u "Newer version detected: $InstalledVersion$\r$\n$\r$\nWould you like to downgrade to version ${MODPACK_VERSION} or uninstall the existing version?"
      Pop $InfoLabel

      ${NSD_CreateButton} 80u 48u 80u 20u "Downgrade"
      Pop $InstallButton
      ${NSD_OnClick} $InstallButton PrimaryButtonClick

      ${NSD_CreateButton} 170u 48u 80u 20u "Uninstall"
      Pop $UninstallButton
      ${NSD_OnClick} $UninstallButton SecondaryButtonClick

      StrCpy $PrimaryAction "downgrade"
      StrCpy $SecondaryAction "uninstall"
    ${EndIf}
  ${EndIf}

  nsDialogs::Show
FunctionEnd

Function PrimaryButtonClick
  StrCpy $Choice $PrimaryAction
  SendMessage $HWNDPARENT 0x408 1 0
FunctionEnd

Function SecondaryButtonClick
  StrCpy $Choice $SecondaryAction
  SendMessage $HWNDPARENT 0x408 1 0
FunctionEnd

Function ChoicePageLeave
  StrCmp $HideTimer "" +2
    nsDialogs::KillTimer $HideTimer

  Call ShowNavButtons

  ${If} $Choice == ""
    Abort
  ${EndIf}
FunctionEnd

; =========================
; Install / Update / Uninstall decision
; =========================
Section "DecideInstallUpdateUninstall"
  SetShellVarContext current
  StrCpy $INSTDIR "$APPDATA\.minecraft"

  ${If} $Choice == "uninstall"
    IfFileExists "$INSTDIR\salty_manifest.txt" 0 uninstall_no_manifest

    MessageBox MB_OK "Uninstalling ${MODPACK_NAME}. Configuration files and backup folders will remain."
    Call RemoveInstalledModpack
    MessageBox MB_OK "${MODPACK_NAME} has been uninstalled successfully."
    Quit

    uninstall_no_manifest:
      MessageBox MB_OK "No installed manifest was found. Nothing was removed."
      Quit
  ${EndIf}

  ${If} $Choice == "update"
    MessageBox MB_YESNO "This will upgrade ${MODPACK_NAME} to version ${MODPACK_VERSION}.$\r$\n$\r$\nContinue?" IDYES do_update IDNO cancel_update

    do_update:
      Call RemoveInstalledModpack
      Goto done_decide

    cancel_update:
      Quit
  ${EndIf}

  ${If} $Choice == "downgrade"
    MessageBox MB_YESNO "This will downgrade ${MODPACK_NAME} to version ${MODPACK_VERSION}.$\r$\n$\r$\nContinue?" IDYES do_downgrade IDNO cancel_downgrade

    do_downgrade:
      Call RemoveInstalledModpack
      Goto done_decide

    cancel_downgrade:
      Quit
  ${EndIf}

  ${If} $Choice == "install"
    MessageBox MB_OK "A backup of your mods, resourcepacks, and shaderpacks will be placed inside your .minecraft folder."
    Call MakeBackupFolders
    Goto done_decide
  ${EndIf}

  done_decide:
SectionEnd

Section "CopyModpackFiles"
  SetOutPath "$INSTDIR"
  File "salty_manifest.txt"
  File /nonfatal /a /r "minecraft\"
SectionEnd

Section "FinalizeInstall"
  File "fabric.exe"
  ExecWait '"$INSTDIR\fabric.exe"'
  Delete "$INSTDIR\fabric.exe"

  WriteUninstaller "$INSTDIR\uninstall_salty_spittoon.exe"

  WriteRegStr HKCU "${UNINST_KEY}" "DisplayName" "${MODPACK_NAME}"
  WriteRegStr HKCU "${UNINST_KEY}" "UninstallString" '"$INSTDIR\uninstall_salty_spittoon.exe"'
  WriteRegStr HKCU "${UNINST_KEY}" "QuietUninstallString" '"$INSTDIR\uninstall_salty_spittoon.exe" /S'
  WriteRegStr HKCU "${UNINST_KEY}" "DisplayVersion" "${MODPACK_VERSION}"
  WriteRegStr HKCU "${UNINST_KEY}" "Publisher" "Taylor Kerr"
  WriteRegStr HKCU "${UNINST_KEY}" "DisplayIcon" "$INSTDIR\uninstall_salty_spittoon.exe"
  WriteRegStr HKCU "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegDWORD HKCU "${UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINST_KEY}" "NoRepair" 1

  Quit
SectionEnd

; =========================
; Uninstaller EXE / Programs and Features
; =========================
Section "un.Uninstall"
  SetShellVarContext current
  StrCpy $INSTDIR "$APPDATA\.minecraft"

  IfFileExists "$INSTDIR\salty_manifest.txt" 0 no_manifest

  MessageBox MB_OK "Uninstalling ${MODPACK_NAME}. Configuration files and backup folders will remain."

  Push "$INSTDIR\salty_manifest.txt"
  Call un.RemoveFilesFromManifest

  Delete "$INSTDIR\salty_manifest.txt"
  Delete "$INSTDIR\uninstall_salty_spittoon.exe"
  DeleteRegKey HKCU "${UNINST_KEY}"

  MessageBox MB_OK "${MODPACK_NAME} has been uninstalled successfully."
  Goto done

  no_manifest:
    MessageBox MB_OK "No installed manifest was found. Nothing was removed."

  done:
SectionEnd

Function un.onInit
  SetShellVarContext current
  StrCpy $INSTDIR "$APPDATA\.minecraft"
FunctionEnd

!finalize '"C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe" sign /v /fd SHA256 /td SHA256 /tr http://timestamp.acs.microsoft.com /d "Salty Spittoon Minecraft Modpack Installer" /dlib "C:\Users\ratsc\AppData\Local\Microsoft\MicrosoftArtifactSigningClientTools\Azure.CodeSigning.Dlib.dll" /dmdf "${__FILEDIR__}\metadata.json" "C:\Users\ratsc\Downloads\${MODPACK_NAME} Installer ${MODPACK_VERSION}.exe"'