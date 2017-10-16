;Tempscript_4.au3
;Writing byte to text File
#include <Array.au3>
;0x377ABCAF271C0004C2DDD4804CF211000000000024000000000000000F4ACB38E05F0D16E95D002D9CCA8666D
$Text = "0x377ABCAF271C0004C2DDD4804CF211000000000024"
$Text2 = "0x000000000000000F4"

$hFile = FileOpen("test.bin", BitOR(16, 1)); Okay. What exactly is the BitOR for? I think I know, but not sure.
FileWrite($hFile, $Text);should write 4 bytes
FileWrite($hFile, $Text2);should write 4 bytes
FileClose($hFile)

;~ $textArray=_byteStringToByteArray($Text)
;~ fileWriteByteArray("test.bin",$textArray)

Func fileWriteByteArray($file, $byteArray)
	$hFile = FileOpen($file, 17)
	$nameThisVar=$byteArray[0]
	For $i = 1 To $nameThisVar Step 1
		FileWrite($hFile, "0x"&$byteArray[$i])
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

Func _byteStringToByteArray($byteString, $splitNumber = 21)
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