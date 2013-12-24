;;; hot string
:c*:my163::mahengyang163@163.com
:c*:mygmail::hengyangma@gmail.com
:c*:myblog::http://my.oschina.net/enyo/blog

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
	}else if WinActive("posh") or WinActive("cmd.exe") or WinActive("Bash") {
		Send, {RButton}
	; 其它程序都映射为Ctrl + v
	}else{
		Send, ^v
	}
	return

;;; Ctrl + < 映射为Ctrl + Shift + Tab，用于切换标签页
^,::^+Tab

;;; Ctrl + > 映射为Ctrl + Tab，用于切换标签页
^.::^Tab

;^n::
;	; 设置匹配模式为正则模式  
;	SetTitleMatchMode 2
;	; Xshell的新建标签页是alt + shift + n
;	If WinActive("Xshell") {
;	    Send, !+n
;	}else{
;		Send, ^n
;	}
;	return

;;; 激活窗口函数
ActiveWin(title_name){
	SetTitleMatchMode 2
	If WinExist(title_name){
	    WinActivate
	    WinWaitActive
	}
}

;;; 截屏键映射为ctrl + w，关闭标签页
PrintScreen::Send, ^w

;;; xshell
PrintScreen & x::
	ActiveWin("Xshell")
return

;;; git for zapya_cloud
PrintScreen & z::
	ActiveWin("posh~git")
return

;;; play debug
PrintScreen & p::
	ActiveWin("debug")
return

;;; eclipse
PrintScreen & e::
	ActiveWin("Eclipse")
	ActiveWin("Java - ")
return

;;; sublime
PrintScreen & s::
	ActiveWin("Sublime")
return

;;; git extentions
PrintScreen & g::
	ActiveWin("Git Extensions")
	Sleep, 1000
	Send, {Enter}
return

;;; skype
PrintScreen & k::
	ActiveWin("TOM-Skype")
return
