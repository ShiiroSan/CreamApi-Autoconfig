#include "WinHttp.au3"

; Download some gif
;~ http://33.media.tumblr.com/dd3ffab90cc338666f192fd86f6a4f8f/tumblr_n0pefhIpss1swyb6ao1_500.gif

; Initialize and get session handle
$hOpen = _WinHttpOpen()
; Get connection handle
$hConnect = _WinHttpConnect($hOpen, "http://33.media.tumblr.com")
; Specify the reguest
$hRequest = _WinHttpOpenRequest($hConnect, Default, "dd3ffab90cc338666f192fd86f6a4f8f/tumblr_n0pefhIpss1swyb6ao1_500.gif")

; Send request
_WinHttpSendRequest($hRequest)

; Wait for the response
_WinHttpReceiveResponse($hRequest)

;~ ConsoleWrite(_WinHttpQueryHeaders($hRequest) & @CRLF)

ProgressOn("Downloading", "In Progress...")
Progress(_WinHttpQueryHeaders($hRequest, $WINHTTP_QUERY_CONTENT_LENGTH))

Local $sData
; Check if there is data available...
If _WinHttpQueryDataAvailable($hRequest) Then
    While 1
        $sChunk = _WinHttpReadData_Ex($hRequest, Default, Default, Default, Progress)
        If @error Then ExitLoop
        $sData &= $sChunk
        Sleep(20)
    WEnd
Else
    MsgBox(48, "Error", "Site is experiencing problems (or you).")
EndIf

Sleep(1000)
ProgressOff()

; Close handles
_WinHttpCloseHandle($hRequest)
_WinHttpCloseHandle($hConnect)
_WinHttpCloseHandle($hOpen)

; Do whatever with data, write to some file or whatnot. I'll just print it to console here:
ConsoleWrite($sData & @CRLF)
Local $hFile = FileOpen(@DesktopDir & "\test.gif", 26)
FileWrite($hFile, $sData)
FileClose($hFile)




Func Progress($iSizeAll, $iSizeChunk = 0)
    Local Static $iMax, $iCurrentSize
    If $iSizeAll Then $iMax = $iSizeAll
    $iCurrentSize += $iSizeChunk
    Local $iPercent = Round($iCurrentSize / $iMax * 100, 0)
    ProgressSet($iPercent, $iPercent & " %")
EndFunc


Func _WinHttpReadData_Ex($hRequest, $iMode = Default, $iNumberOfBytesToRead = Default, $pBuffer = Default, $vFunc = Default)
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
EndFunc