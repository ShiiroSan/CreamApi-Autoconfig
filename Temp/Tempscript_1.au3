;Tempscript_1.au3
#include <WinHttp.au3>

$username="ShiiroSan"
$password="157ok157"
$hNetwork = logToCSRINRU($username, $password)
If $hNetwork == -1 Then
	$errorLogin = MsgBox(262165,"Error!","Something went wrong with login, would you try again? ",0)
	switch $errorLogin
		case 5 ;RETRY
			updateCA()
		case 2 ;CANCEL
			MsgBox(0,"Leaving...", "As we cannot login and it's needed to download the file we'll exit. Please verify your login and try again.")
			Exit
	endswitch
EndIf
$hConnect = _WinHttpConnect($hNetwork, "http://cs.rin.ru/")	
; Specify the reguest
$hRequest = _WinHttpOpenRequest($hConnect, Default, "/forum/download/file.php?id=39093", Default, "", "*/*")
; Send request
_WinHttpSendRequest($hRequest)
; Wait for the response
_WinHttpReceiveResponse($hRequest)
$sQueryHeader = _WinHttpQueryHeaders($hRequest)
ConsoleWrite(_WinHttpQueryHeaders($hRequest) & @CRLF)
$sFileName = _StringBetween2($sQueryHeader, "filename*=UTF-8''", "Strict-Transport-Security")
MsgBox(0,"",StringLen($sFileName)&__StringToHex($sFileName))
$sFileName = _StringLikeMath($sFileName,"-",StringRight($sFileName, 2))
MsgBox(0,"",StringLen($sFileName)&__StringToHex($sFileName))
$FileSize = _WinHttpQueryHeaders($hRequest, $WINHTTP_QUERY_CONTENT_LENGTH) ;Get file size
MsgBox(0,"",$FileSize)
Local $sData
If _WinHttpQueryDataAvailable($hRequest) Then
	While 1
		$hFile = FileOpen("test.bin", BitOR(16, 1))
        $sChunk = _WinHttpReadData($hRequest, 2, Default, Default) ;ça marche lol
        If @error Then ExitLoop
		;ConsoleWrite(__StringToHex($sChunk))
        $sData &= $sChunk
		FileWrite($hFile, $sChunk)
		FileClose($hFile)
        Sleep(20)
    WEnd
Else
	;error management there
EndIf
;$sData=StringTrimLeft($sData, 2)
;$textArray=_byteStringToByteArray($sData, 400)
;fileWriteByteArray("test.bin",$textArray)


Func fileWriteByteArray($file, $byteArray)
	
	$nameThisVar=$byteArray[0]
	For $i = 1 To $nameThisVar Step 1
		$hFile = FileOpen($file, BitOR(16, 1))
		FileWrite($hFile, "0x"&$byteArray[$i])
		FileClose($hFile)
	Next
EndFunc

; Function _byteStringToByteArray()
; Input: 
; 	$byteString : A string of byte in the following format XXXXX 
; 	$splitNumber: Number of character to set in each element
; Output: 
;	An array following the next format.
; 		Element 0: Number of split done on the string. 
;		Element n: Split of the input string

Func _byteStringToByteArray($byteString, $splitNumber = 42)
	$stringLength=StringLen($byteString)
	$numberOfPart=Int($stringLength/$splitNumber)+1
	Local $byteArray[$numberOfPart+1]
	$byteArray[0]=$numberOfPart
	For $i = 1 To $numberOfPart Step 1
		$part=StringLeft($byteString,$splitNumber)
		$byteString = _StringLikeMath($byteString, "-", $part)
		$byteArray[$i]=$part
	Next
	Return $byteArray
EndFunc

Func logToCSRINRU($username, $password) ;return: If you logged correctly, return $hOpen handle, otherwise return -1
	; Initialize and get session handle
$hOpen = _WinHttpOpen()
; Get connection handle
$hConnect = _WinHttpConnect($hOpen, "https://cs.rin.ru/", $INTERNET_DEFAULT_HTTPS_PORT)	
MsgBox(0,"",$hConnect)
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
EndFunc

Func __StringToHex($strChar)
    Local $aryChar, $i, $iDec, $hChar, $strHex
    $aryChar = StringSplit($strChar, "")
    For $i = 1 To $aryChar[0]
        $iDec = Asc($aryChar[$i])
        $hChar = Hex($iDec, 2)
        $strHex &= $hChar & ' '
    Next
    Return $strHex
EndFunc  ;==>_StringToHex

Func _StringBetween2($s, $from, $to)
	$x = StringInStr($s, $from) + StringLen($from)
	$y = StringInStr(StringTrimLeft($s, $x), $to)
	Return StringMid($s, $x, $y)
EndFunc   ;==>_StringBetween2

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