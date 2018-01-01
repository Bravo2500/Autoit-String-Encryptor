#include <Crypt.au3>
#include <File.au3>
#include <String.au3>
#include <Array.au3>

$CypherKey = _Randomstring(70)
$DecryptFuncName = _Randomstring(15)
$DecryptFunc = 'Func ' & $DecryptFuncName & '($string)' & @CRLF & '$string = _Crypt_DecryptData($string,  BinaryToString("' & StringToBinary($CypherKey) & '") , $CALG_AES_256)' & @CRLF & '$string = _HexToString($string)' & @CRLF & '$string = StringReverse($string)' & @CRLF & 'Return $string' & @CRLF & 'EndFunc' & @CRLF


Func Crypt($string, $key)
	$string = StringReverse($string)
	$string = _Crypt_EncryptData($string, $key, $CALG_AES_256)
	Return $string
EndFunc   ;==>Crypt

Func _Randomstring($length)
	$chars = StringSplit('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', "")
	$string = ""
	$i = 0
	Do
		If $length <= 0 Then ExitLoop
		$string &= $chars[Random(1, $chars[0])]
		$i += 1
	Until $i = $length
	Return $string
EndFunc   ;==>_Randomstring


Func AddIncludes($file)
	$content = FileRead($file)
	If Not StringInStr($content, '#include <Crypt.au3>') Then
		$content = '#include <Crypt.au3>' & @CRLF & $content
	EndIf
	If Not StringInStr($content, '#include <String.au3>') Then
		$content = '#include <String.au3>' & @CRLF & $content
	EndIf
	$content &= @CRLF & @CRLF & $DecryptFunc & @CRLF
	$open = FileOpen($file, $FO_OVERWRITE)
	FileWrite($open, $content)
EndFunc   ;==>AddIncludes

Func CryptDoubleQuote($file)

	$content = FileRead($file)
	$regex = StringRegExp($content, '"(.*?)"', $STR_REGEXPARRAYGLOBALMATCH)
	For $i = 0 To UBound($regex) - 1
		If $regex[$i] <> "" Then
			Local $newcontent
			$crypted = Crypt($regex[$i], $CypherKey)
			$newcontent = StringReplace($content, '"' & $regex[$i] & '"', $DecryptFuncName & '("' & $crypted & '")')
			$open = FileOpen($file, $FO_OVERWRITE)
			FileWrite($open, $newcontent)
			$content = FileRead($file)
		EndIf
	Next

EndFunc   ;==>CryptDoubleQuote

Func CryptSingleQuote($file)

	$content = FileRead($file)
	$regex = StringRegExp($content, "'(.*?)'", $STR_REGEXPARRAYGLOBALMATCH)
	For $i = 0 To UBound($regex) - 1

		Local $newcontent
		$crypted = Crypt($regex[$i], $CypherKey)
		$newcontent = StringReplace($content, "'" & $regex[$i] & "'", $DecryptFuncName & "('" & $crypted & "')")
		$open = FileOpen($file, $FO_OVERWRITE)
		FileWrite($open, $newcontent)
		$content = FileRead($file)

	Next

EndFunc   ;==>CryptSingleQuote

Func GetFileInfos($file, $infos)
	Local $a, $b, $c, $d
	_PathSplit($file, $a, $b, $c, $d)

	If $infos = "filename" Then
		Return $c
	ElseIf $infos = "extension" Then
		Return $d
	EndIf
EndFunc   ;==>GetFileInfos



Func Obfuscate($file)
	$save = FileRead($file)
	CryptDoubleQuote($file)
	CryptSingleQuote($file)
	AddIncludes($file)
	FileWrite(GetFileInfos($file, "filename") & "_Backup.au3", $save)
	FileMove($file, GetFileInfos($file, "filename") & "_Obfuscated.au3")
EndFunc   ;==>Obfuscate


Obfuscate($CmdLine[1])

