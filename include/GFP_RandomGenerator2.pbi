;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

#RANDOM_DATA_SIZE = 256 * 1024

Global RAND_Buffer
Global RAND_Index1
Global RAND_Index2

Procedure RAND_SetSeed(*rndData, seed)
  RAND_Buffer = *rndData
  RAND_Index1 = seed & $FFFF
  RAND_Index2 = ( seed >> 16 ) &$FFFF
EndProcedure
  
Procedure RAND_GetNumber(max)
  Protected *ptr1.word, *ptr2.word, value1, value2
  If RAND_Buffer
    If max < 0: max = 0:EndIf
    max + 1
    
    *ptr1.word = RAND_Buffer
    *ptr2.word = RAND_Buffer  
    
    If RAND_Index1 < 0 
      RAND_Index1 % (#RANDOM_DATA_SIZE - SizeOf(Long))
      RAND_Index1 + #RANDOM_DATA_SIZE  
    EndIf
    
    If RAND_Index2 < 0 
      RAND_Index2 % (#RANDOM_DATA_SIZE - SizeOf(Long))
      RAND_Index2 + #RANDOM_DATA_SIZE  
    EndIf  
    
    RAND_Index1 % (#RANDOM_DATA_SIZE - SizeOf(Long)) 
    RAND_Index2 % (#RANDOM_DATA_SIZE - SizeOf(Long))
    
    ;Debug Str(RAND_Index1) + "   ,    " + Str(RAND_Index2)
    *ptr1 + RAND_Index1  
    *ptr2 + RAND_Index2
    value1 = *ptr1\w
    value2 = *ptr2\w
    
    *ptr1 + SizeOf(word)
    *ptr2 + SizeOf(word)  
    RAND_Index1 + ( (*ptr1\w) & $FFFF ) + SizeOf(long)
    RAND_Index2 + ( (*ptr2\w) & $FFFF ) + SizeOf(long)
    ProcedureReturn ((value1 ! value2) & $FFFF) % max
  EndIf
EndProcedure

Procedure RAND_GetNumberFAST256()
  !PUSH EBX
  !PUSH EDX
  !PUSH ESI
  !PUSH EDI
  !PUSH ECX
  
  !MOV ECX, [v_RAND_Buffer]
  !MOV EBX, 262140 ; (#RANDOM_DATA_SIZE - SizeOf(Long))  
  !MOV EAX,[v_RAND_Index1]
  !CDQ
  !IDIV EBX 
  !MOV ESI, EDX ; Rest -> ESI
  
  !MOV EAX,[v_RAND_Index2]
  !CDQ
  !IDIV EBX 
  !MOV EDI, EDX ; Rest -> EDI  
  
  !MOV ECX,[v_RAND_Buffer]
  
  !MOV EAX,[ECX+ESI] ; Value (first 16 Bit) + index Add (next 16 Bits)
  !MOV EDX,[ECX+EDI] ; Value (first 16 Bit) + index Add (next 16 Bits)
  
  !MOV EBX, EAX
  !SHR EBX, 16
  !ADD EBX, 4
  !ADD EBX,ESI
  !MOV [v_RAND_Index1], EBX
  
  !MOV EBX, EDX
  !SHR EBX, 16
  !ADD EBX, 4
  !ADD EBX, EDI
  !MOV [v_RAND_Index2], EBX
  
  !XOR EAX, EDX
  !AND EAX, 0FFh
  
  !POP ECX
  !POP EDI
  !POP ESI
  !POP EDX
  !POP EBX
  ProcedureReturn 
EndProcedure 

Procedure RAND_GenerateSeed()
  Protected *mem1.BYTE, *mem2.BYTE, *ptr1.BYTE, *ptr2.BYTE, t.i
  *mem1.BYTE = AllocateMemory(#RANDOM_DATA_SIZE) 
  *mem2.BYTE = AllocateMemory(#RANDOM_DATA_SIZE)  
  If *mem1 And *mem2
    OpenCryptRandom() 
   
    CryptRandomData(*mem1, #RANDOM_DATA_SIZE)
    CryptRandomData(*mem2, #RANDOM_DATA_SIZE)
    *ptr1.BYTE = *mem1
    *ptr2.BYTE = *mem2
    
    For t=0 To #RANDOM_DATA_SIZE - 1
      *ptr1\b = (*ptr1\b ! *ptr2\b) ! Random(255) 
      *ptr1 + SizeOf(BYTE)
      *ptr2 + SizeOf(BYTE)   
    Next 
    FreeMemory(*mem2)
    *mem2 = #Null
  Else
    If *mem1:FreeMemory(*mem1):*mem1=#Null:EndIf
    If *mem2:FreeMemory(*mem2):*mem2=#Null:EndIf     
  EndIf
  ProcedureReturn *mem1
EndProcedure



; *ptr = RAND_GenerateSeed()
; RAND_SetSeed(*ptr, 52312616126)
; 
; For T=0 To 1000
;   Debug RAND_GetNumber(255)
; Next  
; 
; End


; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = -
; EnableXP
; EnableCompileCount = 1
; EnableBuildCount = 0
; EnableExeConstant