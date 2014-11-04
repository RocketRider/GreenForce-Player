;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

Procedure __AnsiString(str.s)
  Protected *ptr
  *ptr = AllocateMemory(Len(str)+1)
  If *ptr
    PokeS(*ptr, str, -1,#PB_Ascii)
  EndIf
  ProcedureReturn *ptr
EndProcedure


Procedure.s __GeneratePrintablePassword(sPassword.s)
  CompilerIf #PB_Compiler_Unicode
  Protected result.s = "", i.i, ch.s, code.i
  For i = 1 To Len(sPassword)
    
    ch.s = Mid(sPassword, i, 1)
    code = PeekW(@ch)
    
    If code >= 32 And code < 126 ; Note ~ is used as escape character! 
      result + ch
    Else
      result + "~" + RSet(Hex(code & $FFFF, #PB_Long), 4, "0")
    EndIf    
  Next  
  ProcedureReturn result
  CompilerElse
    ProcedureReturn sPassword
  CompilerEndIf
EndProcedure  


Procedure.s __PrintablePasswordToUnicode(sPassword.s)
  CompilerIf #PB_Compiler_Unicode
    Protected result.s = "", i.i, ch.s,coded_unicode_char.s, unicodechar.s = Space(1)
    
    i = 1
    While (i <= Len(sPassword))
    ch.s = Mid(sPassword, i, 1)
    If ch = "~"
      coded_unicode_char.s = Mid(sPassword, i + 1, 4)
      If Len(coded_unicode_char.s) = 4
        unicodechar = Space(1)
        PokeW(@unicodechar, Val("$" + coded_unicode_char))
        result + unicodechar
      EndIf  
      i + 5
    Else
      result + ch
      i + 1
    EndIf  
    
  Wend  
  ProcedureReturn result
  CompilerElse
    ProcedureReturn sPassword
  CompilerEndIf
EndProcedure  


Procedure.s __MD5OfString(string.s)
  Protected result.s, ptrs
  ptrs =__AnsiString(__GeneratePrintablePassword(string))   ;2012-08-03 <PASSWORD FIX>
  If ptrs
    result.s = MD5Fingerprint(ptrs,Len(string))
    FreeMemory(ptrs)
  EndIf  
  ProcedureReturn result
EndProcedure  

Procedure.l __CRC32Of2xMD5Password(sPassword.s)
  Protected str.s, ptrs, crc32
  
  str = __MD5OfString(__MD5OfString(sPassword))
  ptrs = __AnsiString(str)
  If ptrs
    crc32 = CRC32Fingerprint(ptrs, Len(str))
    FreeMemory(ptrs)
  EndIf  
  ProcedureReturn crc32
EndProcedure


Procedure.l __CRC32Of3xMD5Password(sPassword.s)
  Protected crc32
  crc32 = __CRC32Of2xMD5Password(__MD5OfString(sPassword))
  ProcedureReturn crc32
EndProcedure
; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 63
; FirstLine = 1
; Folding = --
; EnableXP