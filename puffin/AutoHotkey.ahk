;;; Fn for acer
/*
sc178 up::
    MsgBox % "push Fn"
	return
*/
Capslock::Ctrl
f1::Send, ^c
f2::
	SetTitleMatchMode 2
	If WinActive("Xshell") {
	    Send, +{insert}
	}else if WinActive("posh") or WinActive("cmd.exe") {
		Send, RButton
	}else{
		Send, ^v
	}
	return
APPSKEY::Send, ^w

ActiveWin(title_name){
	SetTitleMatchMode 2
	If WinExist(title_name){
	    WinActivate
	}
}

;;; xshell
#x::
	ActiveWin("Xshell")
return

;;; git for zapya_cloud
#z::
	ActiveWin("posh~git ~ zapya_cloud")
return

;;; play debug
#y::
	ActiveWin("play debug")
return

;;; eclipse
#e::
	ActiveWin("Eclipse")
return

;;; sublime
#u::
	ActiveWin("Sublime")
return

;;; git extentions
#i::
	ActiveWin("Git Extentions")
return

;;; skype
#t::
	ActiveWin("TOM-Skype")
return