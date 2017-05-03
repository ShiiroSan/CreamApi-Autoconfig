#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=CreamApiFileCreator_99.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Automatically create files for CreamAPI made by deadmau5. This program is made by Shiirosan & Anomaly, it is open-source and free for use. If you paid for this, well... you got fucked.
#AutoIt3Wrapper_Res_Description=Automatically make ini files for CreamAPI, as well as importing the .dll file.
#AutoIt3Wrapper_Res_Fileversion=3.0.0.4
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=deadmau5 for CreamAPI
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Array.au3>
#include <IE.au3>
;~ #include "IEModShiiro.au3"
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include <GuiButton.au3>
#include <INet.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3>
#include <Constants.au3>
#include <File.au3>


Func _StringLikeMath($a, $op, $b)
	Local $ret
	If $op = "-" Then
		$ret = StringReplace($a, $b, "", 1, 1)
	ElseIf $op = "+" Then
		$ret = $a & $b
	ElseIf $op = "*" Then
		For $i = 1 To $b
			$ret &= $a
		Next
	ElseIf $op = "/" Then
		$ret = "Not sure what to do... ERROR! EEP! =P"
	EndIf
	Return $ret
EndFunc   ;==>_StringLikeMath


$baseDirSteam = RegRead("HKCU\Software\Valve\Steam\", "SteamPath")
$confSteamFile = FileOpen($baseDirSteam & "\config\config.vdf")
$confFileRead = FileRead($confSteamFile)
$line9clear = _StringBetween2($confFileRead, '"BaseInstallFolder_1"		', '				"SentryFile"')
$line9clear = StringRegExpReplace($line9clear, "\\\\", "\\")
$line9clear = StringRegExpReplace($line9clear, "\""", "")
$line9clear = StringLeft($line9clear, StringLen($line9clear) - 1)
$defaultGameFolder = $line9clear & "\SteamApps\common\"
$gameDir = FileSelectFolder("Directory of the game", $defaultGameFolder, 0)

$guessGameName = _StringLikeMath($gameDir, "-", $defaultGameFolder)

#Region ### START Koda GUI section ### Form=
Global $searchForm = GUICreate("Game name to search", 311, 105, 277, 191)
Global $gameName = GUICtrlCreateInput($guessGameName, 8, 8, 297, 28, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
GUICtrlSetFont(-1, 12, 400, 0, "Small Fonts")
GUICtrlSetColor(-1, 0x000000)
Global $gameSearch = GUICtrlCreateButton("Search for this game!", 8, 40, 297, 57)
GUICtrlSetState(-1, 512)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Local $hGUI, $hImage
$hGUI = GUICreate("Game list", 400, 400)
$hButtonSelect = GUICtrlCreateButton("Get DLC for selected AppID", 4, 275, 150, 75)
$g_hListView = _GUICtrlListView_Create($hGUI, "", 2, 2, 394, 268)
_GUICtrlListView_SetExtendedListViewStyle($g_hListView, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
GUISetState(@SW_HIDE)

Local $DLCGui
$DLCGui = GUICreate("DLC List for selected games", 450, 400)
$hButtonMaker = GUICtrlCreateButton("Make DLC list export", 4, 275, 150, 75)
$DLCListView = _GUICtrlListView_Create($DLCGui, "", 2, 2, 446, 268)
_GUICtrlListView_SetExtendedListViewStyle($DLCListView, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
GUISetState(@SW_HIDE)
$DLC = ""
$oIE = 0
Func __fnDLCGet($DLCUrl) ;**** INTERNAL ONLY ****
	$qTest = _IECreate($DLCUrl, 0, 0)
	$qText = _IEBodyReadText($qTest)
	If Not StringInStr($qText, "DLCs") Then
		MsgBox(0, "Error!", "The game you looked for does not have DLCs.")
		_IEQuit($oIE)
		_IEQuit($qTest)
		Exit
	EndIf
	_IEQuit($qTest)
	_IEQuit($oIE)

	$THOTTBOT = _INetGetSource($DLCUrl)
	$String = _StringBetween2($THOTTBOT, '<div class="tab-pane selected" id="dlc">', '</div>')
	$DLC = _IECreate("", 0, 0)
	_IEBodyWriteHTML($DLC, $String)
	Local $DLCTable = _IETableGetCollection($DLC, 0)
	Global $DLCTableData = _IETableWriteToArray($DLCTable, 1)
	_GUICtrlListView_InsertColumn($DLCListView, 0, $DLCTableData[0][0], 50)
	_GUICtrlListView_InsertColumn($DLCListView, 1, $DLCTableData[0][1], 350)
	_GUICtrlListView_AddArray($DLCListView, $DLCTableData)
	_GUICtrlListView_DeleteItem($DLCListView, 0)
	GUISetState(@SW_SHOW, $DLCGui)
EndFunc   ;==>__fnDLCGet

$Exit = 0
While 1
	$nMsg = GUIGetMsg(1)
	Switch $nMsg[1]
		Case $searchForm
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE
					Exit
				Case $gameSearch
					If GUICtrlRead($gameName) = "" Then
						MsgBox(0, "Error!", "You must enter a game name before searching!")
					Else
;~ 						TODO: Add a way to show it's currently showing, like loading bar, rotationg mouse or shit like this
						$oIE = _IECreate("https://steamdb.info/search/?a=app&q=" & GUICtrlRead($gameName) & "&type=1&category=0", 0, 0)
						$sText = _IEBodyReadText($oIE)
						If StringInStr($sText, "Nothing was found matching your request") Then
							_IEQuit($oIE)
							MsgBox(0, "Error!", "The game you looked for does not exist.")
						Else
							Local $oTable = _IETableGetCollection($oIE, 0)
							Local $aTableData = _IETableWriteToArray($oTable, 1)
							$uiGameNumber = UBound($aTableData) - 1
							If $uiGameNumber > 1 Then
								_GUICtrlListView_InsertColumn($g_hListView, 0, $aTableData[0][0], 75)
								_GUICtrlListView_InsertColumn($g_hListView, 1, $aTableData[0][1], 75)
								_GUICtrlListView_InsertColumn($g_hListView, 2, $aTableData[0][2], 200)
								_GUICtrlListView_AddArray($g_hListView, $aTableData)
								_GUICtrlListView_DeleteItem($g_hListView, 0)
								GUISetState(@SW_SHOW, $hGUI)
								GUIDelete($searchForm)
							Else
								$g_hListView = $aTableData
								_ArrayDelete($g_hListView, 0)
								Global $aItem = $g_hListView[0][0]
								$DLCUrl = 'https://steamdb.info/app/' & $aItem & '/dlc/'
								__fnDLCGet($DLCUrl)
;~ 								GUIDelete($searchForm)
							EndIf
						EndIf
					EndIf
			EndSwitch
		Case $hGUI
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE
					ExitLoop
				Case $hButtonSelect
					$aItem = _GUICtrlListView_GetItemTextArray($g_hListView)
					$DLCUrl = 'https://steamdb.info/app/' & $aItem[1] & '/dlc/'
					__fnDLCGet($DLCUrl)
					_IEQuit($oIE)
					GUISetState(@SW_HIDE, $hGUI)
			EndSwitch
		Case $DLCGui
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE
					GUIDelete($DLCGui)
					GUIDelete($hGUI)
					ExitLoop
				Case $hButtonMaker
					$num = 0
					$dlcnum = 0
					Dim $DLCData[UBound($DLCTableData) + 1][2]
					ReDim $DLCTableData[UBound($DLCTableData) + 1][3]
					For $i = 0 To UBound($DLCTableData) Step 1
						If $DLCTableData[$i][1] == "" Then ExitLoop
						$DLCData[$num][0] = $DLCTableData[$i][0]
						$DLCData[$num][1] = $DLCTableData[$i][1]
						$num = $num + 1
						ConsoleWrite($i & @CR)
					Next
					exportCreamApi()
			EndSwitch
	EndSwitch
WEnd

_IEQuit($oIE)
_IEQuit($DLC)

Func _StringBetween2($s, $from, $to)
	$x = StringInStr($s, $from) + StringLen($from)
	$y = StringInStr(StringTrimLeft($s, $x), $to)
	Return StringMid($s, $x, $y)
EndFunc   ;==>_StringBetween2

Func exportCreamApi()
	If FileExists($gameDir & "\steam_api.dll") Or FileExists($gameDir & "\steam_api64.dll") Then
		
	Else
		MsgBox(0, "Error!", "Sorry, steam_api(64).dll can't be found... Will now open a file selection to know where to search for it.")
		$newGameDir = FileOpenDialog("Specify folder of steamapi(64).dll", $gameDir, "Steamapi DLL (steam_api.dll;steam_api64.dll)")
		$isOkFor86DLL = StringRegExp($newGameDir, "steam_api.dll")
		$isOkFor64DLL = StringRegExp($newGameDir, "steam_api64.dll")
		If $isOkFor86DLL Or Then
			If $isOkFor86DLL Then
				$bFound = 1
				$newGameDir = StringRegExpReplace($newGameDir, "steam_api.dll", "")
				$gameDir = $newGameDir
			EndIf
			If $isOkFor64DLL Then
				$bFound = 1
				$newGameDir = StringRegExpReplace($newGameDir, "steam_api64.dll", "")
				$gameDir = $newGameDir
			EndIf
		EndIf
	EndIf
	If FileExists($gameDir & "\steam_api_o.dll") == 0 Or FileExists($gameDir & "\steam_api64_o.dll") == 0 Then
		If FileExists($gameDir & "\steam_api.dll") Then
			FileMove($gameDir & "\steam_api.dll", $gameDir & "\steam_api_o.dll")
			FileCopy(@ScriptDir & "\steam_api.dll", $gameDir & "\steam_api.dll")
		ElseIf FileExists(@ScriptDir & "\steam_api64.dll") Then
			FileMove($gameDir & "\steam_api64.dll", $gameDir & "\steam_api64_o.dll")
			FileCopy(@ScriptDir & "\steam_api64.dll", $gameDir & "\steam_api64.dll")
		EndIf
	EndIf
	FileCopy(@ScriptDir & "\cream_api.ini", $gameDir & "\cream_api.ini")
	$creamApiPoint = $gameDir & "\cream_api.ini"
	If $aItem=="" Then
		IniWrite($creamApiPoint, "steam", "appid", " " + $aItem[1])
	Else
		IniWrite($creamApiPoint, "steam", "appid", " " + $aItem)
	EndIf
	IniWrite($creamApiPoint, "steam", "unlockall", " true")
	IniWrite($creamApiPoint, "steam", "log", " true")
	$dlcnum = -1
	For $i = 1 To UBound($DLCData) Step 1
		If $DLCData[$i][0] <> "" Then
			$dlcnum = $dlcnum + 1
			IniWrite($creamApiPoint, "dlc_subscription", $DLCData[$i][0], "true")
			IniWrite($creamApiPoint, "dlc_index", $dlcnum, $DLCData[$i][0])
			IniWrite($creamApiPoint, "dlc_names", $dlcnum, $DLCData[$i][1])
		Else
			ExitLoop
		EndIf
	Next
	$dlcnum = 0

	; From here the next 13 lines are code to correct some spacing in cream_api.ini
	Local $sFind = "=  "
	Local $sReplace = "="
	Local $sFileName = $creamApiPoint

	Local $iRetval = _ReplaceStringInFile($sFileName, $sFind, $sReplace)
	$iMsg = FileRead($sFileName, 1000)

	Local $sFind = ";   "
	Local $sReplace = "; "
	Local $sFileName = $creamApiPoint

	Local $iRetval = _ReplaceStringInFile($sFileName, $sFind, $sReplace)
	$iMsg = FileRead($sFileName, 1000)

	WinKill($DLCGui)
	MsgBox(0, "Done!", "cream_api.ini is done." & @CR _
			 & "Made by ShiiroSan & Anomaly for cs.rin.ru communities. Thanks to deadmau5 for CreamAPI.")
EndFunc   ;==>exportCreamApi

Func exportSteamAppID()
	FileWriteLine("steam_appid.ini", "[Steam]")
	FileWriteLine("steam_appid.ini", "RealAppId=" & $aItem[1])
	FileWriteLine("steam_appid.ini", "#Generated with ShiiroSan Exporter DLC List")
	FileWriteLine("steam_appid.ini", "#Thanks to https://steamdb.info ; http://revolt.loginto.me ; cs.rin.ru community. ")
	FileWriteLine("steam_appid.ini", "")
	For $i = 1 To UBound($DLCData) Step 1
		If $DLCData[$i][0] <> "" Then
			$dlcnum = $dlcnum + 1
			FileWriteLine("steam_appid.ini", "#" & $DLCData[$i][1])
			If $i < 10 Then
				FileWriteLine("steam_appid.ini", "DLC00" & $dlcnum & "=" & $DLCData[$i][0])
			Else
				FileWriteLine("steam_appid.ini", "DLC0" & $dlcnum & "=" & $DLCData[$i][0])
			EndIf
		Else
			ExitLoop
		EndIf
	Next
	FileWriteLine("steam_appid.ini", "[Settings]")
EndFunc   ;==>exportSteamAppID

; #FUNCTION# ====================================================================================================================
; Name ..........: _FindInFile
; Description ...: Search for a string within files located in a specific directory.
; Syntax ........: _FindInFile($sSearch, $sFilePath[, $sMask = '*'[, $fRecursive = True[, $fLiteral = Default[,
;                  $fCaseSensitive = Default[, $fDetail = Default]]]]])
; Parameters ....: $sSearch             - The keyword to search for.
;                  $sFilePath           - The folder location of where to search.
;                  $sMask               - [optional] A list of filetype extensions separated with ';' e.g. '*.au3;*.txt'. Default is all files.
;                  $fRecursive          - [optional] Search within subfolders. Default is True.
;                  $fLiteral            - [optional] Use the string as a literal search string. Default is False.
;                  $fCaseSensitive      - [optional] Use Search is case-sensitive searching. Default is False.
;                  $fDetail             - [optional] Show filenames only. Default is False.
; Return values .: Success - Returns a one-dimensional and is made up as follows:
;                            $aArray[0] = Number of rows
;                            $aArray[1] = 1st file
;                            $aArray[n] = nth file
;                  Failure - Returns an empty array and sets @error to non-zero
; Author ........: guinness
; Remarks .......: For more details: http://ss64.com/nt/findstr.html
; Example .......: Yes
; ===============================================================================================================================
Func _FindInFile($sSearch, $sFilePath, $sMask = '*', $fRecursive = True, $fLiteral = Default, $fCaseSensitive = Default, $fDetail = Default)
	Local $sCaseSensitive = $fCaseSensitive ? '' : '/i', $sDetail = $fDetail ? '/n' : '/m', $sRecursive = ($fRecursive Or $fRecursive = Default) ? '/s' : ''
	If $fLiteral Then
		$sSearch = ' /c:' & $sSearch
	EndIf
	If $sMask = Default Then
		$sMask = '*'
	EndIf

	$sFilePath = StringRegExpReplace($sFilePath, '[\\/]+$', '') & '\'
	Local Const $aMask = StringSplit($sMask, ';')
	Local $iPID = 0, $sOutput = ''
	For $i = 1 To $aMask[0]
		$iPID = Run(@ComSpec & ' /c ' & 'findstr ' & $sCaseSensitive & ' ' & $sDetail & ' ' & $sRecursive & ' "' & $sSearch & '" "' & $sFilePath & $aMask[$i] & '"', @SystemDir, @SW_HIDE, $STDOUT_CHILD)
		ProcessWaitClose($iPID)
		$sOutput &= StdoutRead($iPID)
	Next
	Return StringSplit(StringStripWS(StringStripCR($sOutput), BitOR($STR_STRIPLEADING, $STR_STRIPTRAILING)), @LF)
EndFunc   ;==>_FindInFile

