;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************


Procedure GETBIT(*ptr,offset.q)
  bResult = #False
  If *ptr
    byteOffset.i = (offset >> 3)
    bitOffset = 1 << (offset & %111) 
    
    *bytePtr.BYTE = *ptr + byteOffset
    If *bytePtr\b & (bitOffset)
      bResult = #True
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure SETBIT(*ptr,offset.q, value)
  bResult = #False
  If *ptr
    byteOffset.i = (offset >> 3)
    bitOffset = 1 << (offset & %111)
    
    *bytePtr.BYTE = *ptr + byteOffset 
    
    newValue = *bytePtr\b & (~bitOffset)
    If value
      newValue + value
    EndIf  
    *bytePtr\b = newValue
    bResult = #True
  EndIf
  ProcedureReturn bResult
EndProcedure

; *addr=AllocateMemory(10000)
; 
; 
; SETBIT(*addr,64, 1)
; 
; Debug GETBIT(*addr,65)
; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = -
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant