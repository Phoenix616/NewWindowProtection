; Copyright (C) 2016 Max Lee (https://github.com/Phoenix616/)
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the Mozilla Public License as published by
; the Mozilla Foundation, version 2.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; Mozilla Public License v2.0 for more details.
;
; You should have received a copy of the Mozilla Public License v2.0
; along with this program. If not, see <http://mozilla.org/MPL/2.0/>.

#Persistent
#InstallKeybdHook
SetBatchLines, -1
Process, Priority,, High

global name := "NewWindowProtection"
global version := "1.0"

global lastNewWindow := 0

global logToFile := false ; Log everything to file
global showTrayTip := true ; Show tray tip when steal was blocked

global inStartMenu := 0 ; The last time the user pressed enter in the start menu
global inLaunchy := 0 ; The last time the user pressed enter in launchy

global inputOnly := 1000 ; Only stop input when keyboard typing was detected x amount of milliseconds before
global preventInput := 1000 ; Number of milliseconds in which we should prevent input in newly created windows

if(FileExist(name . ".ini")) {
    IniRead , logToFile, %name%.ini, Settings, filelog, filelog
    IniRead , showTrayTip, %name%.ini, Settings, notifications, notifications
    IniRead , inputOnly, %name%.ini, Settings, inputonly, inputOnly
    IniRead , preventInput, %name%.ini, Settings, preventinput, preventInput
} else {
    settings = 
    (
[Settings]
; Log everything to file
filelog=%logToFile%
; Show tray tip when input was blocked
notifications=%showTrayTip%
; Only stop input when keyboard typing was detected x amount of milliseconds before
inputonly=%inputOnly%
; Number of milliseconds in which we should prevent input in newly created windows
preventinput=%preventInput%
    )
    FileAppend , %settings%, %name%.ini
}

logToFile := logToFile && logToFile != "false"
showTrayTip := showTrayTip && showTrayTip != "false"
inputOnly := inputOnly && inputOnly != "false"

FileLog(name . " v" . version . " started!")
FileLog("Settings:")
FileLog(" logToFile: " . logToFile)
FileLog(" showTrayTip: " . showTrayTip)
FileLog(" inputOnly: " . inputOnly)
FileLog(" preventInput: " . preventInput)
showTip(name . " v" . version . " started!", "[Settings] logToFile: " . logToFile . " showTrayTip: " . showTrayTip . " inputOnly: " . inputOnly . " preventInput: " . preventInput)

; React on all the windows
Gui +LastFound
hWnd := WinExist()

DllCall( "RegisterShellHookWindow", UInt,hWnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "shellMessage" )

Return
   
shellMessage(wParam, lParam) {
    WinGetTitle, Title, ahk_id %lParam%
    msg := lParam . " | " . wParam . " | " . Title
    if(wParam = 1) { ;  HSHELL_WINDOWCREATED := 1
        lastNewWindow := A_TickCount
        if(stopInput()) {
            timeout := preventinput / 1000
            Input , text, I B T%timeout%
            if (StrLen(text) > 0) {
                DllCall("FlashWindow", UInt, lParam , Int, 1)
                msg .= " <<< Input stopped! (Debug: " . Title . " (" . A_TimeIdlePhysical . " " . lastNewWindow . " " . A_TickCount . ")"
                ShowTip(text, "Stopped input to " . Title . " (" . A_TimeIdlePhysical . " " . lastNewWindow . " " . A_TickCount . ")")
            }
        }
    }
    
    ; log it if it's enabled, useful for debugging stuff
    fileLog(msg)
}
    
showTip(title, text) {
    if(showTrayTip) {
        TrayTip, %title%, %text%, 10, 16
    }
    return
}

fileLog(text) {
    if(logToFile ) {
        FormatTime, CurrentDateTime,, yy-MM-dd HH:mm:ss
        FileAppend , `n[%CurrentDateTime%] %text%, %name%.log
    }
    return
}

stopInput() {
    IfWinActive, ahk_class DV2ControlHost
        IfWinActive, ahk_exe explorer.exe
            return false
    IfWinActive, ahk_class QTool 
        IfWinActive, ahk_exe Launchy.exe
            return false
    return (inputOnly > 0 && A_TimeIdlePhysical > inputOnly) || lastNewWindow + preventInput > A_TickCount
}

$Enter::
    if(stopInput())
        return
    SendInput {Enter}

$Esc::
    if(stopInput())
        return
    SendInput {Esc}