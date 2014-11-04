

$DRM_ENCRYPTION_VERSION_2_0 = 1
Local $result = DllCall("GPFCrypt.dll", "int", "EncryptMediaFile", "str", "testvideo.avi", "str", "testvideo.gfp", "str", "mypassword", "int", $DRM_ENCRYPTION_VERSION_2_0, "int", -1)  ; Or use 0 as last parameter for no progress bar

MsgBox(4096, "Encryption", StringFormat ("result of DllCall: %d", $result), 10)	
