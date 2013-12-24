#include httpQuery-0-3-6.ahk
url := "http://www.baidu.com"
html := httpQuery(url)
MsgBox %html%