#include <WinHttp.au3>

$hOpen = _WinHttpOpen()
; Get connection handle
$hConnect = _WinHttpConnect($hOpen, "https://cs.rin.ru/", $INTERNET_DEFAULT_HTTPS_PORT)
MsgBox(0,"",$hConnect)
$hRequest = _WinHttpOpenRequest($hConnect, Default, "/forum/download/file.php?id=39093", Default, "", "*/*")
MsgBox(0,"",$hRequest)
$sendRequest=_WinHttpSendRequest($hRequest)
_WinHttpReceiveResponse($hRequest)
$sQueryHeader = _WinHttpQueryHeaders($hRequest)
ConsoleWrite(_WinHttpQueryHeaders($hRequest) & @CRLF)