$fExtract=StringRegExp(StringTrimRight("CreamAPI_Release_v3.0.0.3_Hotfix.7z", 3), "(.*)_Release_v(.*)", 1)
$zipExtractDir = @ScriptDir & "\" & $fExtract[0] & " " & $fExtract[1]
MsgBox(0,"",$zipExtractDir)
MsgBox(0,"",@DesktopDir&"\7za.exe x "&@ScriptDir&'\CreamAPI_Release_v3.0.0.3_Hotfix.7z -o "'&$zipExtractDir&'"')
ClipPut($zipExtractDir)
RunWait(@DesktopDir&"\7za.exe x "&@ScriptDir&'\CreamAPI_Release_v3.0.0.3_Hotfix.7z -o"'&$zipExtractDir&'"')