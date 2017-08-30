#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=CreamApiFileCreator_99.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Automatically create files for CreamAPI made by deadmau5. This program is made by Shiirosan & Anomaly, it is open-source and free for use. If you paid for this, well... you got fucked.
#AutoIt3Wrapper_Res_Description=Automatically make ini files for CreamAPI, as well as importing the .dll file.
#AutoIt3Wrapper_Res_Fileversion=3.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=deadmau5 for CreamAPI
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Array.au3>
#include <IE.au3>
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

#Region GUI Includes
#include "Forms/CreamApiConfigurator.isf"
#include "Forms/searchForm.isf"
#EndRegion

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

Global $debug = 0

If FileExists("caconfig.ini") Then
	$language = IniRead("caconfig.ini","default","language","English")
	$useOffline = IniRead("caconfig.ini","default","offlineMode",False)
	$extraProtectionBypass = IniRead("caconfig.ini","default","extraProtectionBypass",False)
Else
	
EndIf

GUISetState(@SW_SHOW,$CreamApiConfigurator)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_ConfirmClose()
		Case $cancelConfBtn
			_ConfirmClose()
		Case $setDefaultBtn
			$setDefault = MsgBox(266273,"Are you sure?","By setting this as default you'll never see this windows again and the option above will be use each time you make a patch. " & @CRLF & "You can always remove the default options by deleting caconfig.ini on [working dir].",0)
			switch $setDefault
				case 1 ;OK
				IniWrite("caconfig.ini","default","language",GUICtrlRead($languageCombo))
				IniWrite("caconfig.ini","default","extraProtectionBypass",_IsChecked($extraProtecBypassCheckbox))
				IniWrite("caconfig.ini","default","$offlineMode",_IsChecked($offlineCheckbox))
				IniWrite("caconfig.ini","default","userdataFolder",_IsChecked($userdataFolderCheckxox))
				IniWrite("caconfig.ini","default","lowviolence",_IsChecked($lowviolenceCheckbox))
				IniWrite("caconfig.ini","default","$wrapperMode",_IsChecked($wrapperCheckbox))
				case 2 ;CANCEL
				;nothing to do folk
			endswitch
		
	EndSwitch
WEnd


$baseDirSteam = RegRead("HKCU\Software\Valve\Steam\", "SteamPath")
$confSteamFile = FileOpen($baseDirSteam & "\config\config.vdf")
$confFileRead = FileRead($confSteamFile)
$line9clear = _StringBetween2($confFileRead, '"BaseInstallFolder_1"		', '				"SentryFile"')
$line9clear = StringRegExpReplace($line9clear, "\\\\", "\\")
$line9clear = StringRegExpReplace($line9clear, "\""", "")
$line9clear = StringLeft($line9clear, StringLen($line9clear) - 1)
$defaultGameFolder = $line9clear & "\SteamApps\common\"

$gameDir = FileSelectFolder("Directory of the game", $defaultGameFolder, 0)

If $gameDir == "" Then
	$noGame = True
Else
	$noGame = False
EndIf
If Not $noGame Then
	$ARRfullDirWGameName = StringSplit($gameDir, "\")
	$guessGameName = $ARRfullDirWGameName[$ARRfullDirWGameName[0]]
EndIf

#Region ### START Koda GUI section ### Form=$searchForm
If Not $noGame Then
	GUICtrlSetData($gameNameInput, $guessGameName)
Else
	;Nothing to do otherwise idiot.
EndIf
GUISetState(@SW_SHOW, $searchForm)
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
$DLCCheckLang = GUICtrlCreateCheckbox("Set languages manually", 230, 290, 150, 21, -1, -1)
$DLCComboLang = GUICtrlCreateCombo("Languages", 230, 320, 150, 21, -1, -1)
GUICtrlSetData(-1, "French|English|Chinese|German|Spanish|Italian")
GUICtrlSetState(-1, $GUI_DISABLE)
GUISetState(@SW_HIDE)

$DLC = ""
$oIE = 0

Func __fnDLCGet($DLCUrl) ;**** INTERNAL ONLY ****
	$qTest = _IECreate($DLCUrl, 0, 0)
	$qText = _IEBodyReadText($qTest)
	If Not StringInStr($qText, "DLCs") Then
		MsgBox(0, "Error!", "The game you looked for does not have DLCs.")
		_IEQuit($qTest)
		Exit
	EndIf
	_IEQuit($qTest)

	$THOTTBOT = _INetGetSource($DLCUrl)
	$String = _StringBetween2($THOTTBOT, '<div class="tab-pane selected" id="dlc">', '</div>')
	$DLC = _IECreate("", 0, 0)
	_IEBodyWriteHTML($DLC, $String)
	Local $DLCTable = _IETableGetCollection($DLC, 0)
	Global $DLCTableData = _IETableWriteToArray($DLCTable, 1)
	_IEQuit($DLC)
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
					If GUICtrlRead($gameNameInput) = "" Then
						MsgBox(0, "Error!", "You must enter a game name before searching!")
					Else
;~ 						TODO: Add a way to show it's currently showing, like loading bar, rotationg mouse or shit like this
						$oIE = _IECreate("https://steamdb.info/search/?a=app&q=" & GUICtrlRead($gameNameInput), 0, 0)
						$sText = _IEBodyReadText($oIE)
						If StringInStr($sText, "Nothing was found matching your request") Then
							MsgBox(0, "Error!", "The game you looked for does not exist.")
						Else ;if game's found
							Local $oTable = _IETableGetCollection($oIE, 0)
							Local $aTableData = _IETableWriteToArray($oTable, 1)
							$uiGameNumber = UBound($aTableData) - 1
							Local $aItem[4]
							If $uiGameNumber > 1 Then ;more than 1 game is found
								local $posToDelete
								Local $iToDel=0
								For $i = 1 To UBound($aTableData,1) - 1 Step 1 ;this whole part is needed to get only game on multi-game search
									If $aTableData[$i][1] <> "Game" Then
										$iToDel+=1
										If $iToDel > 1 Then $posToDelete = $posToDelete & ";"
										$posToDelete = $posToDelete & $i
									EndIf
								Next
								_GUICtrlListView_InsertColumn($g_hListView, 0, $aTableData[0][0], 75)
								_GUICtrlListView_InsertColumn($g_hListView, 1, $aTableData[0][1], 75)
								_GUICtrlListView_InsertColumn($g_hListView, 2, $aTableData[0][2], 200)
								_GUICtrlListView_AddArray($g_hListView, $aTableData)
								_GUICtrlListView_DeleteItem($g_hListView, 0)
								GUISetState(@SW_SHOW, $hGUI)
								GUIDelete($searchForm)
							Else ;only one game is found
								$aItem[0] = 3
								For $i = 1 To 3 Step 1
									$aItem[$i] = $aTableData[1][$i - 1]
								Next
								$g_hListView = $aTableData
								_ArrayDelete($g_hListView, 0)
								$DLCUrl = 'https://steamdb.info/app/' & $aItem[1] & '/dlc/'
								__fnDLCGet($DLCUrl)
								GUIDelete($searchForm)
							EndIf
						EndIf
						_IEQuit($oIE)
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
					GUISetState(@SW_HIDE, $hGUI)
			EndSwitch
		Case $DLCGui
			If _IsChecked($DLCCheckLang) Then
				GUICtrlSetState($DLCComboLang, $GUI_ENABLE)
			Else
				GUICtrlSetState($DLCComboLang, $GUI_DISABLE)
			EndIf
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
					Next
					exportCreamApi()
			EndSwitch
	EndSwitch
WEnd

Func _StringBetween2($s, $from, $to)
	$x = StringInStr($s, $from) + StringLen($from)
	$y = StringInStr(StringTrimLeft($s, $x), $to)
	Return StringMid($s, $x, $y)
EndFunc   ;==>_StringBetween2

Func exportCreamApi()
	If $debug Then MsgBox(0, "", "Hey! You're in debug so don't expect it to save the cracked files kiddo")
	If Not $noGame Then
		If Not FileExists($gameDir & "\steam_api.dll") Or Not FileExists($gameDir & "\steam_api64.dll") Then
			MsgBox(0, "Error!", "Sorry, steam_api(64).dll can't be found... Will now open a file selection to know where to search for it.")
			$newGameDir = FileOpenDialog("Specify folder of steamapi(64).dll", $gameDir, "Steamapi DLL (steam_api.dll;steam_api64.dll)")
			$isOkFor86DLL = StringRegExp($newGameDir, "steam_api.dll")
			$isOkFor64DLL = StringRegExp($newGameDir, "steam_api64.dll")
			If $isOkFor86DLL Then
				$gameRepertory = _StringLikeMath($newGameDir, "-", "steam_api.dll")
			ElseIf $isOkFor64DLL Then
				$gameRepertory = _StringLikeMath($newGameDir, "-", "steam_api64.dll")
			EndIf
			$isOkFor86DLL = FileExists($gameRepertory & "steam_api.dll")
			$isOkFor64DLL = FileExists($gameRepertory & "steam_api64.dll")
			If $isOkFor86DLL Or $isOkFor64DLL Then $gameDir = $gameRepertory
		EndIf
		If Not $debug Then
			If FileExists($gameDir & "\steam_api_o.dll") == 0 Or FileExists($gameDir & "\steam_api64_o.dll") == 0 Then
				If FileExists($gameDir & "\steam_api.dll") Then
					FileMove($gameDir & "\steam_api.dll", $gameDir & "\steam_api_o.dll")
					FileCopy(@ScriptDir & "\steam_api.dll", $gameDir & "\steam_api.dll")
				EndIf
				If FileExists($gameDir & "\steam_api64.dll") Then
					FileMove($gameDir & "\steam_api64.dll", $gameDir & "\steam_api64_o.dll")
					FileCopy(@ScriptDir & "\steam_api64.dll", $gameDir & "\steam_api64.dll")
				EndIf
			EndIf
			FileCopy(@ScriptDir & "\cream_api.ini", $gameDir & "\cream_api.ini")
			$creamApiPoint = $gameDir & "\cream_api.ini"
		EndIf
	Else
		If Not $debug Then
			$folderSave = FileSelectFolder("Select a folder to save the cracking files", @ScriptDir, 0)
			$gameName = $aItem[3]
			DirCreate($folderSave & "/" & $gameName)
			$folderSave &= "/" & $gameName
			FileCopy(@ScriptDir & "\cream_api.ini", $folderSave & "\cream_api.ini")
			FileCopy(@ScriptDir & "\steam_api.dll", $folderSave & "\steam_api.dll")
			FileCopy(@ScriptDir & "\steam_api64.dll", $folderSave & "\steam_api64.dll")
			$creamApiPoint = $folderSave & "\cream_api.ini"
		EndIf
	EndIf
	If Not $debug Then
		IniWrite($creamApiPoint, "steam", "appid", " " + $aItem[1])
		IniWrite($creamApiPoint, "steam", "unlockall", " true")
		IniWrite($creamApiPoint, "steam", "log", " false") ;If this value is true, near to all game crash so we'll just turn it off :D
		$dlcnum = -1
		For $i = 1 To UBound($DLCData) Step 1
			If $DLCData[$i][0] <> "" Then
				$dlcnum = $dlcnum + 1
				IniWrite($creamApiPoint, "dlc", $DLCData[$i][0], $DLCData[$i][1])
				
				;/* To be removed */
				
				;IniWrite($creamApiPoint, "dlc_index", $dlcnum, $DLCData[$i][0])
				;IniWrite($creamApiPoint, "dlc_names", $dlcnum, $DLCData[$i][1])
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
	EndIf
	MsgBox(0, "Done!", "cream_api.ini is done." & @CR _
			 & "Made by ShiiroSan & Anomaly for cs.rin.ru communities. Thanks to deadmau5 for CreamAPI.")
EndFunc   ;==>exportCreamApi

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

Func _IsChecked(Const $iControlID)
	Return BitAND(GUICtrlRead($iControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func _ConfirmClose()
	$wannaClose = MsgBox(266532,"Are you sure?","Are you sure you want to leave?",0)
	switch $wannaClose

		case 6 ;YES
			Exit

		case 7 ;NO
			Return

	endswitch
EndFunc