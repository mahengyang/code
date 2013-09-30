;;; Fn for acer
/*
sc178 up::
    MsgBox % "push Fn"
	return
*/
;;; 大写键浪费了，映射为ctrl
Capslock::Ctrl

;;; f1映射为ctrl + c
f1::Send, ^c

;;; 映射f2键为粘贴键，不同的程序粘贴键不一样
f2::
	; 设置匹配模式为正则模式  
	SetTitleMatchMode 2
	; Xshell的粘贴键是shift + insert
	If WinActive("Xshell") {
	    Send, +{insert}
	; dos窗口的粘贴键是鼠标右键
	}else if WinActive("posh") or WinActive("cmd.exe") {
		Send, RButton
	; 其它程序都映射为Ctrl + v
	}else{
		Send, ^v
	}
	return

;;; 应用程序键（位于右alt和ctrl之间）映射为ctrl + w，关闭标签页
APPSKEY::Send, ^w

;;; 激活窗口函数
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