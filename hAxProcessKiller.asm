;******
; hAx Process Killer
; by Zak Farrington alias fritz <http://root-hack.org && http://hax-studios.net>
; Copyright (C) hAx Studios Ltd. 2004
;
; Feel free to modify this file to your liking, but give credit where it is due
;
;
;******
.386
.model flat,stdcall
option casemap:none

;**
; Include our libraries
;**
include \masm32\include\windows.inc
include \masm32\include\shell32.inc
include \masm32\include\kernel32.inc
include \MASM32\INCLUDE\masm32.inc
include \MASM32\INCLUDE\user32.inc
includelib \masm32\lib\kernel32.lib
includelib \MASM32\LIB\masm32.lib
includelib \MASM32\lib\user32.lib
includelib \MASM32\lib\shell32.lib

DialogProc  proto :DWORD,:DWORD,:DWORD,:DWORD   ;Declare our dialog process
Refresh     proto                               ;Declare our refresh function

;-------

;**
; START: Dialog Refrences (from resource file)
;***
IDD_MAINDLG     equ 100 ;Dialog ID

IDI_MAIN        equ 1   ;Icon ID

IDC_LIST        equ 200 ;List box ID
IDB_REFRESH     equ 201 ;Refresh button
IDB_KILL        equ 202 ;Terminate Process Button
IDB_ABOUT       equ 203 ;About Button
IDB_CLOSE       equ 204 ;Close Button

;***
; END: Dialog Refrences
;**

;-------

.data                               ;Start our variable declerations(data)


;** 
; START: About Box Strings
;***
    abtMessage  db "hAx Process Killer by fritz <http://root-hack.org && http://hax-studios.net>", 0Ah
                db 0Ah, 0Ah
                db "A simple process killer.  Easily and efficiently view and kill processes, visible or hidden, on your machine.",0
    abtTitle    db "[:: About ::]",0
;***
; END: About Box Strings
;**

;-------

;**
; START: Conformation message strings
;***
    conMessage  db "Are you sure you want to kill the selected process?",0
    conTitle    db "[:: Are you sure? ::]", 0
;***
; END: Conformation message strings
;**

;-------

.data?					
    hInstance   HINSTANCE   ?			
    hProcess    dd          ?	
    hIcon       dd          ?
    hList       dd          ?
    hSnapshot   dd          ?

    uProcess    PROCESSENTRY32  <>

;-------

.code                                           ;Start the code

main:				

invoke GetModuleHandle, NULL                    ;No need to change this
mov    [hInstance], eax                         ;Load our instance into eax
invoke DialogBoxParam, eax, IDD_MAINDLG ,0, addr DialogProc, eax 
                                                ;^^ Launch our dialog
invoke ExitProcess, NULL                        ;If done making it, exit this process.

;**
; START: Dialog Process
;***

DialogProc Proc hWnd: DWORD, uMsg: DWORD, wParam: DWORD, lParam: DWORD 

    .if uMsg == WM_INITDIALOG                   ;If the dialog created

        invoke LoadIcon, [lParam], IDI_MAIN     ;Load our icon
        mov [hIcon], eax                        ;Load hIcon with eax
        invoke SendMessage, [hWnd], WM_SETICON, IMAGE_ICON, eax
                                                ;^ Send WM_SETICON message to our dialog

        invoke GetDlgItem, [hWnd], IDC_LIST     ;Get our list box
        mov [hList], eax                        ;And move it into hList

        call Refresh

   
    .elseif uMsg == WM_COMMAND                  ;If a button is pushed, check

        .if wParam == IDB_CLOSE                 ;If the quit is push, if so exit
            invoke EndDialog,hWnd,0             ;quit
        	
        .elseif wParam == IDB_ABOUT             ;If the about button is pushed
            invoke MessageBox, hWnd, addr abtMessage, addr abtTitle, MB_OK + MB_ICONINFORMATION

        .elseif wParam == IDB_REFRESH
            call Refresh                        ;Refresh our list

        .elseif wParam == IDB_KILL
            invoke MessageBox, hWnd, addr conMessage, addr conTitle, MB_YESNO + MB_ICONQUESTION
            cmp eax, IDYES
            jne EndKill
            invoke SendMessage, [hList], LB_GETCURSEL, 0, 0
            invoke SendMessage, [hList], LB_GETITEMDATA, eax, 0
            invoke OpenProcess, PROCESS_TERMINATE, 1, eax
            invoke TerminateProcess, eax, 0
EndKill:
            call Refresh
        .endif                                  ;Close checking which button has been pushed

					
    .elseif uMsg == WM_CLOSE                    ;If the 'x' or Close is hit
        invoke EndDialog,hWnd,0                 ;end dialog
        
    .ENDIF                                      ;Stop checking the dialog for events

xor eax, eax                                    ;Erase all registers
ret                                             ;return
DialogProc endp

;***
; END: Dialog Process
;**

;-------


;**
; START: Set up our Refresh function
;***
Refresh proc
    invoke SendMessage, [hList], LB_RESETCONTENT, 0, 0

    mov [uProcess.dwSize], sizeof uProcess
    invoke CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS, 0
    mov [hSnapshot], eax
    invoke Process32First, eax, addr uProcess

    .while eax
        invoke SendMessage, [hList], LB_ADDSTRING, 0, addr uProcess.szExeFile
        invoke SendMessage, [hList], LB_SETITEMDATA, eax, [uProcess.th32ProcessID]
        invoke Process32Next, [hSnapshot], addr uProcess
    .endw

    invoke CloseHandle, [hSnapshot]
    ret

Refresh endp
;***
; END: Set up our Refresh funcion
;**
        

;** by fritz <http://hax-studios.net && http://root-hack.org>

end main