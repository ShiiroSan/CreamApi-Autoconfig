#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=CreamApiFileCreator_99.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Comment=Automatically create files for CreamAPI made by deadmau5. This program is made by Shiirosan & Anomaly, it is open-source and free for use. If you paid for this, well... you got fucked.
#AutoIt3Wrapper_Res_Description=Automatically make ini files for CreamAPI, as well as importing the .dll file.
#AutoIt3Wrapper_Res_Fileversion=3.0.0.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=deadmau5 for CreamAPI
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_File_Add=C:\Users\CVDB5085\Desktop\Prog\creamapi-autoconfig\7za.exe
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
#include <InetConstants.au3>
#include <WinAPIFiles.au3>
#include <WinHttp.au3>
#include <Console.au3>

#Region GUI Includes
#include "Forms/CreamApiConfigurator.isf"
#include "Forms/searchForm.isf"
#include "Forms\dlForm.isf"
#EndRegion GUI Includes

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

Global $CAInstalledVersion = checkVersion()
Global $CADir = @ScriptDir & "\CreamAPI " & $CAInstalledVersion

If FileExists("caconfig.ini") Then
	$language = IniRead("caconfig.ini", "default", "language", "English")
	$extraProtectionBypass = IniRead("caconfig.ini", "default", "extraProtectionBypass", False)
	$useOffline = IniRead("caconfig.ini", "default", "offlineMode", False)
	$userdataFolder = IniRead("caconfig.ini", "default", "userdataFolder", False)
	$lowviolence = IniRead("caconfig.ini", "default", "lowviolence", False)
	$wrapperMode = IniRead("caconfig.ini", "default", "$wrapperMode", False)
	$configuratorShow = 0
Else
	GUISetState(@SW_SHOW, $CreamApiConfigurator)
	$configuratorShow = 1
EndIf
While $configuratorShow
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_ConfirmClose()
		Case $cancelConfBtn
			_ConfirmClose()
		Case $setDefaultBtn
			$setDefault = MsgBox(266273, "Are you sure?", "By setting this as default you'll never see this windows again and the option above will be use each time you make a patch. " & @CRLF & "You can always remove the default options by deleting caconfig.ini on [working dir].", 0)
			Switch $setDefault
				Case 1 ;OK
					IniWrite("caconfig.ini", "default", "language", GUICtrlRead($languageCombo))
					IniWrite("caconfig.ini", "default", "extraProtectionBypass", _IsChecked($extraProtecBypassCheckbox))
					IniWrite("caconfig.ini", "default", "$offlineMode", _IsChecked($offlineCheckbox))
					IniWrite("caconfig.ini", "default", "userdataFolder", _IsChecked($userdataFolderCheckxox))
					IniWrite("caconfig.ini", "default", "lowviolence", _IsChecked($lowviolenceCheckbox))
					IniWrite("caconfig.ini", "default", "$wrapperMode", _IsChecked($wrapperCheckbox))
					$language = GUICtrlRead($languageCombo)
					$extraProtectionBypass = _IsChecked($extraProtecBypassCheckbox)
					$useOffline = _IsChecked($offlineCheckbox)
					$userdataFolder = _IsChecked($userdataFolderCheckxox)
					$lowviolence = _IsChecked($lowviolenceCheckbox)
					$wrapperMode = _IsChecked($wrapperCheckbox)
					GUISetState(@SW_HIDE, $CreamApiConfigurator)
					$configuratorShow = 0
					
				Case 2 ;CANCEL
					;nothing to do folk
			EndSwitch
		Case $validateBtn
			$language = GUICtrlRead($languageCombo)
			$extraProtectionBypass = _IsChecked($extraProtecBypassCheckbox)
			$useOffline = _IsChecked($offlineCheckbox)
			$userdataFolder = _IsChecked($userdataFolderCheckxox)
			$lowviolence = _IsChecked($lowviolenceCheckbox)
			$wrapperMode = _IsChecked($wrapperCheckbox)
			GUISetState(@SW_HIDE, $CreamApiConfigurator)
			$configuratorShow = 0
	EndSwitch
WEnd

Cout("Do you want to use an already installed game? [Y/n]" & @CRLF)
$answer = Getch()
If StringLower($answer) = "n" Then
	$gameDir = ""
	$noGame = True
Else
	#Region ### Get Steam Path ###
	$baseDirSteam = RegRead("HKCU\Software\Valve\Steam\", "SteamPath")
	$confSteamFile = FileOpen($baseDirSteam & "\config\config.vdf")
	$confFileRead = FileRead($confSteamFile)
	$line9clear = _StringBetween2($confFileRead, '"BaseInstallFolder_1"		', '				"SentryFile"')
	$line9clear = StringRegExpReplace($line9clear, "\\\\", "\\")
	$line9clear = StringRegExpReplace($line9clear, "\""", "")
	$line9clear = StringLeft($line9clear, StringLen($line9clear) - 1)
	$defaultGameFolder = $line9clear & "\SteamApps\common\"
	$gameDir = FileSelectFolder("Directory of the game", $defaultGameFolder, 0)
	#EndRegion ### Get Steam Path ###
	$ARRfullDirWGameName = StringSplit($gameDir, "\")
	$guessGameName = $ARRfullDirWGameName[$ARRfullDirWGameName[0]]
	GUICtrlSetData($gameNameInput, $guessGameName)
	$noGame = False
EndIf

#Region ### START Koda GUI section ### Form=$searchForm
GUISetState(@SW_SHOW, $searchForm)
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=gameList
Local $hGUI, $hImage
$hGUI = GUICreate("Game list", 400, 400)
$hButtonSelect = GUICtrlCreateButton("Get DLC for selected AppID", 4, 275, 150, 75)
$g_hListView = _GUICtrlListView_Create($hGUI, "", 2, 2, 394, 268)
_GUICtrlListView_SetExtendedListViewStyle($g_hListView, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
GUISetState(@SW_HIDE)
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=DLCList
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
#EndRegion ### END Koda GUI section ###

$DLC = ""
$oIE = 0

Func __fnDLCGet($DLCUrl) ;**** INTERNAL ONLY ****
	$qTest = _IECreate($DLCUrl, 0, 0)
	$qText = _IEBodyReadText($qTest)
	If Not StringInStr($qText, "DLCs") Then
		FileWrite("out.out", $qText)
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
								Local $posToDelete
								Local $iToDel = 0
								For $i = 1 To UBound($aTableData, 1) - 1 Step 1 ;this whole part is needed to get only game on multi-game search
									If $aTableData[$i][1] <> "Game" Then
										$iToDel += 1
										If $iToDel > 1 And $iToDel < UBound($aTableData, 1) - 1 Then
											$posToDelete = $posToDelete & ";"
										EndIf
										$posToDelete = $posToDelete & $i
									EndIf
								Next
								_ArrayDelete($aTableData, $posToDelete)
								_ArrayDisplay($aTableData)
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
	Cout("Do you want to use the log build? [y/N]" & @CRLF)
	Cout("If the game crash, try with nonlog build." & @CRLF)
	$logbuild = Getch()
	MsgBox(0, "", $logbuild)
	If StringLower($logbuild) == "y" Then
		$CADir &= "\log_build"
	Else
		$CADir &= "\nonlog_build"
	EndIf
	If $debug Then MsgBox(0, "", "Hey! You're in debug so don't expect it to save the cracked files kiddo")
	If Not $noGame Then
		MsgBox(0, "", FileExists($gameDir & "\steam_api.dll"))
		Local $isAnySteamAPI = 0
		If FileExists($gameDir & "\steam_api.dll") Then
			$isAnySteamAPI += 1
		EndIf
		If FileExists($gameDir & "\steam_api64.dll") Then
			$isAnySteamAPI += 2
		EndIf
		If Not $isAnySteamAPI Then
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
					FileCopy($CADir & "\steam_api.dll", $gameDir & "\steam_api.dll")
				EndIf
				If FileExists($gameDir & "\steam_api64.dll") Then
					FileMove($gameDir & "\steam_api64.dll", $gameDir & "\steam_api64_o.dll")
					FileCopy($CADir & "\steam_api64.dll", $gameDir & "\steam_api64.dll")
				EndIf
			EndIf
			FileCopy($CADir & "\cream_api.ini", $gameDir & "\cream_api.ini")
			$creamApiPoint = $gameDir & "\cream_api.ini"
		EndIf
	Else
		If Not $debug Then
			$folderSave = FileSelectFolder("Select a folder to save the cracking files", @ScriptDir, 0)
			$gameName = $aItem[3]
			DirCreate($folderSave & "/" & $gameName)
			$folderSave &= "/" & $gameName
			FileCopy($CADir & "\cream_api.ini", $folderSave & "\cream_api.ini")
			FileCopy($CADir & "\steam_api.dll", $folderSave & "\steam_api.dll")
			FileCopy($CADir & "\steam_api64.dll", $folderSave & "\steam_api64.dll")
			$creamApiPoint = $folderSave & "\cream_api.ini"
		EndIf
	EndIf
	
	;;;; Writing boolean and language if defined
	;;;; Tbh will write only if value is different than default. Otherwise we'll let it like that
	If $language <> "Use default" Then
		_ReplaceStringInFile($creamApiPoint, ";language", "language")
		IniWrite($creamApiPoint, "steam", "language", $language)
	EndIf
	If $extraProtectionBypass <> False Then
		IniWrite($creamApiPoint, "steam", "extraprotection", StringLower($extraProtectionBypass))
	EndIf
	If $userdataFolder <> True Then
		_ReplaceStringInFile($creamApiPoint, ";forceuserdatafolder", "forceuserdatafolder")
		IniWrite($creamApiPoint, "steam", "forceuserdatafolder", StringLower($userdataFolder))
	EndIf
	If $lowviolence <> False Then
		_ReplaceStringInFile($creamApiPoint, ";lowviolence", "lowviolence")
		IniWrite($creamApiPoint, "steam", "lowviolence", StringLower($lowviolence))
	EndIf
	If $useOffline <> False Then
		IniWrite($creamApiPoint, "steam", "forceoffline", StringLower($useOffline))
	EndIf
	If $wrapperMode <> False Then
		IniWrite($creamApiPoint, "steam", "wrappermode", StringLower($wrapperMode))
	EndIf
	
	If Not $debug Then
		IniWrite($creamApiPoint, "steam", "appid", " " + $aItem[1])
		IniWrite($creamApiPoint, "steam", "unlockall", " true")
		If StringLower($logbuild) == "y" Then
			IniWrite($creamApiPoint, "steam", "log", " true") ;If this value is true, near to all game crash
		Else
			IniWrite($creamApiPoint, "steam", "log", " false") ;If this value is true, near to all game crash
		EndIf
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

Func getPage($URLToRead)
	Local $hOpen = _WinHttpOpen()
	
	Local $hConnect = _WinHttpConnect($hOpen, "http://cs.rin.ru/")
	Local $hRequest = _WinHttpOpenRequest($hConnect, Default, "/forum/viewtopic.php?p=1180852", Default, "", "*/*")
	; Send request
	_WinHttpSendRequest($hRequest)
	; Wait for the response
	_WinHttpReceiveResponse($hRequest)
	
	;See if there is data to read
	Local $sChunk, $sData
	If _WinHttpQueryDataAvailable($hRequest) Then
		; Read
		While 1
			$sChunk = _WinHttpReadData($hRequest)
			If @error Then ExitLoop
			$sData &= $sChunk
		WEnd
	Else
		MsgBox(48, "Error", "Site is experiencing problems.")
	EndIf
	; /* IM CODING HERE
	; 	 MUSTARD OUTPUT OF THE FUNCTION
	; */
	_WinHttpCloseHandle($hRequest)
	_WinHttpCloseHandle($hConnect)
	_WinHttpCloseHandle($hOpen)
EndFunc   ;==>getPage

;RETURN: vX.X.X.X/[space]XXXX		Everything after '/' is optional. Depending if hotfix
Func getCreamApiVersion()
	;;; Download cs.rin.ru page and read if version is the same.
	$csrinruPage = _IECreate("https://cs.rin.ru/forum/viewtopic.php?f=29&t=70576", 0, 0, 1)
	$csrinruText = _IEBodyReadHTML($csrinruPage)
	_IEQuit($csrinruPage)
	$versionOnRinRu = _StringBetween2($csrinruText, '"> <div style="display: none;">', ':<br><br>')
	Return $versionOnRinRu
EndFunc   ;==>getCreamApiVersion

Func checkVersion()
	Local $supportedVersion = FileRead(@AppDataDir & "/supportedVersionCA")
	FileDelete(@AppDataDir & "/supportedVersionCA")
	Local $creamApiVersion = getCreamApiVersion()
	;MsgBox(0,"","$supportedVersion: "&$supportedVersion)
	;MsgBox(0,"","$creamApiVersion: "&$creamApiVersion)
	If $creamApiVersion = "" Then
		MsgBox(48, "Error", "It seems the application cannot connect to cs.rin.ru. Please verify your firewall and network connection. " & @CRLF & "If both are OK, you should try again later.", 0)
		Exit
	Else
		Local $caFolderEx = _FileListToArray(@ScriptDir, "CreamAPI *", 2)
		If @error == 1 Or @error == 4 Then
			ConsoleWrite("No version found!" & @CRLF)
			updateCA()
			Return $creamApiVersion
		Else
			If $caFolderEx[0] > 1 Then
				Local $verFolder = $caFolderEx[$caFolderEx[0]]
			Else
				Local $verFolder = $caFolderEx[1]
			EndIf
		EndIf
		Local $installedVersion = StringRegExp($verFolder, "CreamAPI (.*)", 1)[0]
		If FileExists(@ScriptDir & "\CreamAPI " & $creamApiVersion) Then
			Return $creamApiVersion
		Else
			$shiiroNetStatus = InetGet("https://www.shiirosan.com/caversion", @AppDataDir & "/supportedVersionCA")
			If Not $shiiroNetStatus Then
				;Here we are in the case were there is no connection to shiirosan.com
				If Not FileExists(@AppDataDir & "/supportedVersionCA") Then
					MsgBox(48, "Error", "It seems the application cannot connect to www.shiirosan.com. Please verify your firewall and network connection. " & @CRLF & "If both are OK, you should try again later.", 0)
					Exit
				EndIf
			EndIf
			If $installedVersion <> $creamApiVersion Then
				If $creamApiVersion > $supportedVersion Then
					;ask the user if he wants to take to risk to fucked up his game o/
				Else ;The version supported == forum one so we might update
					Local $needToUp = MsgBox(36, "Need to update", "A new version might be available, would you like to update it? " & @CRLF & "Actual version found: " & $installedVersion & @CRLF & "New version found: " & $creamApiVersion, 0)
					Switch $needToUp
						Case 6 ;YES
							updateCA()
							Return $creamApiVersion
						Case 7 ;User is perfectly stupid
							Return -1
					EndSwitch
				EndIf
			Else ;No need to update
				Return $creamApiVersion
			EndIf
		EndIf
	EndIf
EndFunc   ;==>checkVersion

Func updateCA() ;Thanks to user2530266 on StackOverflow who provided an awesome way to do this
	;$username = InputBox("Enter cs.rin.ru username","Please enter your username of cs.rin.ru here")
	;$password = InputBox("Enter cs.rin.ru password","Please enter your password of cs.rin.ru here","","*")
	$username = "ShiiroSan"
	$password = "157ok157"
	$hNetwork = logToCSRINRU($username, $password)
	If $hNetwork == -1 Then
		$errorLogin = MsgBox(262165, "Error!", "Something went wrong with login, would you try again? ", 0)
		Switch $errorLogin
			Case 5 ;RETRY
				updateCA()
			Case 2 ;CANCEL
				MsgBox(0, "Leaving...", "As we cannot login and it's needed to download the file we'll exit. Please verify your login and try again.")
		EndSwitch
	Else
		$hConnect = _WinHttpConnect($hNetwork, "http://cs.rin.ru/")
		$hRequest = _WinHttpOpenRequest($hConnect, Default, "/forum/viewtopic.php?p=1180852", Default, "", "*/*")
		; Send request
		_WinHttpSendRequest($hRequest)
		; Wait for the response
		_WinHttpReceiveResponse($hRequest)
		
		;See if there is data to read
		Local $sChunk, $sData
		If _WinHttpQueryDataAvailable($hRequest) Then
			; Read
			While 1
				$sChunk = _WinHttpReadData($hRequest)
				If @error Then ExitLoop
				$sData &= $sChunk
			WEnd
		Else
			MsgBox(48, "Error", "Site is experiencing problems.")
		EndIf
		$dlId = StringRegExp($sData, '<a href="\.\/download\/file\.php\?id=([0-9]*)">', 1)[0]
		If Not @error Then
			$hRequest = _WinHttpOpenRequest($hConnect, Default, "/forum/download/file.php?id=" & $dlId, Default, "", "*/*")
		Else
			Exit
		EndIf
		; Send request
		_WinHttpSendRequest($hRequest)
		; Wait for the response
		_WinHttpReceiveResponse($hRequest)
		$sQueryHeader = _WinHttpQueryHeaders($hRequest)
		;ConsoleWrite(_WinHttpQueryHeaders($hRequest) & @CRLF)
		$sFileName = _StringBetween2($sQueryHeader, "filename*=UTF-8''", "Strict-Transport-Security")
		$sFileName = _StringLikeMath($sFileName, "-", StringRight($sFileName, 2))
		GUISetState(@SW_SHOW, $dlForm)
		$FileSize = _WinHttpQueryHeaders($hRequest, $WINHTTP_QUERY_CONTENT_LENGTH) ;Get file size
		Progress($FileSize)
		Local $sData
		If _WinHttpQueryDataAvailable($hRequest) Then
			$hFile = FileOpen($sFileName, BitOR(16, 2))
			While 1
				$sChunk = _WinHttpReadData_Ex($hRequest, 2, Default, Default, Progress)
				If @error Then ExitLoop
				FileWrite($hFile, $sChunk)
				Sleep(20)
			WEnd
			FileClose($hFile)
		Else
			;error o/
		EndIf
		$fExtract = StringRegExp(StringTrimRight($sFileName, 3), "(.*)_Release_v(.*)", 1)
		If StringInStr($fExtract[1], "_") Then
			$fExtract[1] = StringReplace($fExtract[1], "_", " ")
		EndIf
		$fExtract[1] = "v" & $fExtract[1]
		$zipExtractDir = @ScriptDir & "\" & $fExtract[0] & " " & $fExtract[1]
		;MsgBox(0,"",$zipExtractDir)
		_Extract($sFileName, $zipExtractDir)
		;MsgBox(0, "", "End")
	EndIf
EndFunc   ;==>updateCA

Func _Extract($fileName, $outPutDir)
	FileInstall(@ScriptDir & "\7za.exe", @TempDir & "\7za.exe", 1)
	;MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @LF & 'FileInstall("C:\Users\CVDB5085\Desktop\Prog\creamapi-autoconfig\7za.exe", @TempDir & "\7za.exe", 1)' & @LF & @LF & 'Return:' & @LF & FileInstall("C:\Users\CVDB5085\Desktop\Prog\creamapi-autoconfig\7za.exe", @TempDir & "\7za.exe", 1)) ;### Debug MSGBOX
	If Not FileExists(@TempDir & "\7za.exe") Then
		MsgBox(16, "Error!", "Cannot proceed to extraction. Aborting...", 0)
		Exit
	EndIf
	$unzipOut = RunWait(@TempDir & "\7za.exe x " & $fileName & ' -o"' & $outPutDir & '" -y')
	If $unzipOut == 0 Then
		FileDelete(@TempDir & "\7za.exe")
	Else
		MsgBox(0, "Error!", "An error happened during the extraction. Please try again or contact me via forum")
		Exit
	EndIf
EndFunc   ;==>_Extract

Func __StringToHex($strChar)
	Local $aryChar, $i, $iDec, $hChar, $strHex
	$aryChar = StringSplit($strChar, "")
	For $i = 1 To $aryChar[0]
		$iDec = Asc($aryChar[$i])
		$hChar = Hex($iDec, 2)
		$strHex &= $hChar & ' '
	Next
	Return $strHex
EndFunc   ;==>__StringToHex

Func Progress($iSizeAll, $iSizeChunk = 0)
	Local Static $iMax, $iCurrentSize
	If $iSizeAll Then $iMax = $iSizeAll
	$iCurrentSize += $iSizeChunk
	GUICtrlSetData($labelSize, $iCurrentSize & " / " & $iMax)
	$Pct = Int($iCurrentSize / $iMax * 100) ;Calculate percentage
	GUICtrlSetData($labelPercent, $Pct & "%")
	GUICtrlSetData($dlProgress, $Pct) ;Set progress bar
EndFunc   ;==>Progress

Func logToCSRINRU($username, $password) ;return: If you logged correctly, return $hOpen handle, otherwise return -1
	; Initialize and get session handle
	$hOpen = _WinHttpOpen()
	; Get connection handle
	$hConnect = _WinHttpConnect($hOpen, "https://cs.rin.ru/", $INTERNET_DEFAULT_HTTPS_PORT)
	;MsgBox(0, "", $hConnect)
	; Fill login form:
	$sRead = _WinHttpSimpleFormFill($hConnect, _
			"/forum/ucp.php?mode=login", _ ; location of the form
			"index:0", _ ; id of the form
			"name:username", $username, _
			"name:password", $password, _
			"type:submit", 0)
	; Close connection handle
	_WinHttpCloseHandle($hConnect)
	If _StringBetween2($sRead, '<td class="row1" align="center"><br /><p class="gen">', '<br /><br /><a href=') == "You have been successfully logged in." Then
		Return $hOpen
	Else
		Return -1
	EndIf
EndFunc   ;==>logToCSRINRU
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
	$wannaClose = MsgBox(266532, "Are you sure?", "Are you sure you want to leave?", 0)
	Switch $wannaClose

		Case 6 ;YES
			Exit

		Case 7 ;NO
			Return

	EndSwitch
EndFunc   ;==>_ConfirmClose

Func _WinHttpReadData_Ex($hRequest, $iMode = Default, $iNumberOfBytesToRead = Default, $pBuffer = Default, $vFunc = Default) ;
	__WinHttpDefault($iMode, 0)
	__WinHttpDefault($iNumberOfBytesToRead, 8192)
	__WinHttpDefault($vFunc, 0)
	Local $tBuffer, $vOutOnError = ""
	If $iMode = 2 Then $vOutOnError = Binary($vOutOnError)
	Switch $iMode
		Case 1, 2
			If $pBuffer And $pBuffer <> Default Then
				$tBuffer = DllStructCreate("byte[" & $iNumberOfBytesToRead & "]", $pBuffer)
			Else
				$tBuffer = DllStructCreate("byte[" & $iNumberOfBytesToRead & "]")
			EndIf
		Case Else
			$iMode = 0
			If $pBuffer And $pBuffer <> Default Then
				$tBuffer = DllStructCreate("char[" & $iNumberOfBytesToRead & "]", $pBuffer)
			Else
				$tBuffer = DllStructCreate("char[" & $iNumberOfBytesToRead & "]")
			EndIf
	EndSwitch
	Local $sReadType = "dword*"
	If BitAND(_WinHttpQueryOption(_WinHttpQueryOption(_WinHttpQueryOption($hRequest, $WINHTTP_OPTION_PARENT_HANDLE), $WINHTTP_OPTION_PARENT_HANDLE), $WINHTTP_OPTION_CONTEXT_VALUE), $WINHTTP_FLAG_ASYNC) Then $sReadType = "ptr"
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpReadData", _
			"handle", $hRequest, _
			"struct*", $tBuffer, _
			"dword", $iNumberOfBytesToRead, _
			$sReadType, 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, "")
	If Not $aCall[4] Then Return SetError(-1, 0, $vOutOnError)
	If IsFunc($vFunc) Then $vFunc(0, $aCall[4])
	If $aCall[4] < $iNumberOfBytesToRead Then
		Switch $iMode
			Case 0
				Return SetExtended($aCall[4], StringLeft(DllStructGetData($tBuffer, 1), $aCall[4]))
			Case 1
				Return SetExtended($aCall[4], BinaryToString(BinaryMid(DllStructGetData($tBuffer, 1), 1, $aCall[4]), 4))
			Case 2
				Return SetExtended($aCall[4], BinaryMid(DllStructGetData($tBuffer, 1), 1, $aCall[4]))
		EndSwitch
	Else
		Switch $iMode
			Case 0, 2
				Return SetExtended($aCall[4], DllStructGetData($tBuffer, 1))
			Case 1
				Return SetExtended($aCall[4], BinaryToString(DllStructGetData($tBuffer, 1), 4))
		EndSwitch
	EndIf
EndFunc   ;==>_WinHttpReadData_Ex

