#include "WinHttp.au3"

; http://www.w3schools.com/php/demo_form_validation_escapechar.php

$sUserName = "SomeUserName"
$sEmail = "some.email@something.com"

$sDomain = "duckduckgo.com"
$sPage = "/php/demo_form_validation_escapechar.php"

; Data to send
$sAdditionalData = "?q=Avion&atb=v76-2"

; Initialize and get session handle
$hOpen = _WinHttpOpen("Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0")

; Get connection handle
$hConnect = _WinHttpConnect($hOpen, $sDomain)

; Make a request
$hRequest = _WinHttpOpenRequest($hConnect, "GET")

; Send it. Specify additional data to send too. This is required by the Google API:
_WinHttpSendRequest($hRequest, "", $sAdditionalData)

; Wait for the response
_WinHttpReceiveResponse($hRequest)

Local $sHeader = _WinHttpQueryHeaders($hRequest) ; ...get full header

; See what's returned
Dim $sReturned
If _WinHttpQueryDataAvailable($hRequest) Then ; if there is data
    Do
        $sReturned &= _WinHttpReadData($hRequest)
    Until @error
EndIf


; Close handles
_WinHttpCloseHandle($hRequest)
_WinHttpCloseHandle($hConnect)
_WinHttpCloseHandle($hOpen)

; See what's returned
ConsoleWrite($sHeader & @CRLF)
MsgBox(4096, "Returned", $sReturned)
ConsoleWrite($sReturned & @CRLF)
