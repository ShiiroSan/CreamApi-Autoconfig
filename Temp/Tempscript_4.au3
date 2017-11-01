#include <Array.au3>
#include <File.au3>

Local $caFolderEx = _FileListToArray("C:\Users\CVDB5085\Desktop\Prog\creamapi-autoconfig", "CreamAPI *", 2)
If @error == 1 Or @error == 4 Then
	MsgBox(0,"","No version found!")
Else
_ArrayDisplay($caFolderEx)
If $caFolderEx[0] > 1 Then
	Local $installedVersion = StringRegExp($caFolderEx[$caFolderEx[0]], "CreamAPI (.*)", 1)[0]
Else
	Local $installedVersion = StringRegExp($caFolderEx[1], "CreamAPI (.*)", 1)[0]
EndIf
MsgBox(0,"",$installedVersion)
EndIf