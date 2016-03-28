UseCRC32Fingerprint()
UseMD5Fingerprint()

Procedure.s MD5Fingerprint(*addr, length)
  ProcedureReturn Fingerprint(*addr, length, #PB_Cipher_MD5)
EndProcedure

Procedure.s MD5FileFingerprint(file.s)
  ProcedureReturn FileFingerprint(file.s, #PB_Cipher_MD5)
EndProcedure

Procedure.l CRC32Fingerprint(*addr, length)
  ProcedureReturn Val("$" + Fingerprint(*addr, length, #PB_Cipher_CRC32))
EndProcedure

; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 10
; Folding = -
; EnableUnicode
; EnableXP