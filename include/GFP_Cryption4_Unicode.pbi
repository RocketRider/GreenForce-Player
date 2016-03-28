;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

XIncludeFile "GFP_RandomGenerator2.pbi"
XIncludeFile "GFP_DRMHelpFunctions.pbi" ; 2012-08-03 <PSSWORD FIX>

EnableExplicit
#DECRYPTION_BLOCK_SIZEA = 67231
#DECRYPTION_BLOCK_SIZEB = 47753

Structure POINTER
StructureUnion
  i.i
  l.l
  w.w
  b.b
EndStructureUnion
EndStructure

Procedure GenerateCryptionBuffer(sPassword.s)
  Protected sMD5Password.s, x.i, *addr.POINTER, *tmp.POINTER, k.i
  Protected BLOCKSIZEA.i, BLOCKSIZEB.i, BLOCKSIZE.i, PtrsMD5Password
  
  Dim md5.b(15)
  
  ;PtrsMD5Password = __AnsiString(sPassword)
  ;If PtrsMD5Password
  ;  sMD5Password.s = MD5Fingerprint(PtrsMD5Password, Len(sPassword))
  ;  FreeMemory(PtrsMD5Password)  
  ;EndIf
  sMD5Password.s = __MD5OfString(sPassword)
  

  ;sMD5Password.s = MD5Fingerprint(@sPassword, StringByteLength(sPassword))
  
  For x=0 To 15
    md5(x) = Val("$"+Mid(sMD5Password, x*2 + 1, 2))
  Next
  
  RandomSeed(md5(2) + md5(3) << 8 + md5(4) << 16)
  BLOCKSIZEA = Random($FFFF) + #DECRYPTION_BLOCK_SIZEA
  BLOCKSIZEB = Random($FFFF) + #DECRYPTION_BLOCK_SIZEB
  BLOCKSIZE = BLOCKSIZEA + BLOCKSIZEB
  
  *addr.POINTER = AllocateMemory(8 + BLOCKSIZE)
  If *addr
    *tmp.POINTER = *addr
    *tmp\l = BLOCKSIZEA
    *tmp + 4
    *tmp\l = BLOCKSIZEB 
    
    For k=0 To 7
      RandomSeed(md5(2*k) & 255+ (md5(2*k+1) & 255)<< 8) ; PeekW(*addr+ k * 2) & $FFFF)
      *tmp.POINTER = *addr + 8
        For x = 0 To BLOCKSIZE -1
          *tmp\b ! Random(255)
          *tmp + 1
        Next
    Next
  EndIf
ProcedureReturn *addr
EndProcedure

Procedure GenerateCryptionBufferV2(sPassword.s, NewAlgorithm, *RndData = #Null)
  Protected sMD5Password.s, x.i, *addr.POINTER, *tmp.POINTER, k.i
  Protected BLOCKSIZEA.i, BLOCKSIZEB.i, BLOCKSIZE.i, PtrsMD5Password
  
  Dim md5.b(15)
  
  
  ;2012-08-03 <PASSWORD FIX>
  ;PtrsMD5Password = __AnsiString(sPassword)
  ;If PtrsMD5Password
  ;  sMD5Password.s = MD5Fingerprint(PtrsMD5Password, Len(sPassword))
  ;  FreeMemory(PtrsMD5Password)  
  ;EndIf
  sMD5Password.s = __MD5OfString(sPassword)

  ;sMD5Password.s = MD5Fingerprint(@sPassword, StringByteLength(sPassword))
  
  For x=0 To 15
    md5(x) = Val("$"+Mid(sMD5Password, x*2 + 1, 2))
  Next
  
  
  If NewAlgorithm
    RAND_SetSeed(*RndData, md5(2) + md5(3) << 8 + md5(4) << 16)
    BLOCKSIZEA = RAND_GetNumber($FFFF) + #DECRYPTION_BLOCK_SIZEA
    BLOCKSIZEB = RAND_GetNumber($FFFF) + #DECRYPTION_BLOCK_SIZEB
  
  Else  
    RandomSeed(md5(2) + md5(3) << 8 + md5(4) << 16)
    BLOCKSIZEA = Random($FFFF) + #DECRYPTION_BLOCK_SIZEA
    BLOCKSIZEB = Random($FFFF) + #DECRYPTION_BLOCK_SIZEB    
  EndIf
   
  BLOCKSIZE = BLOCKSIZEA + BLOCKSIZEB
  
  *addr.POINTER = AllocateMemory(8 + BLOCKSIZE)
  If *addr
    *tmp.POINTER = *addr
    *tmp\l = BLOCKSIZEA
    *tmp + 4
    *tmp\l = BLOCKSIZEB 
    
    For k=0 To 7     
      
      If NewAlgorithm
        RAND_SetSeed(*RndData, md5(2*k) & 255+ (md5(2*k+1) & 255)<< 8) ; PeekW(*addr+ k * 2) & $FFFF)
        *tmp.POINTER = *addr + 8
        For x = 0 To BLOCKSIZE -1
          *tmp\b ! RAND_GetNumberFAST256() ;RAND_GetNumber(255)
          *tmp + 1
        Next
      Else
        RandomSeed(md5(2*k) & 255+ (md5(2*k+1) & 255)<< 8) ; PeekW(*addr+ k * 2) & $FFFF)
        *tmp.POINTER = *addr + 8
        For x = 0 To BLOCKSIZE -1
          *tmp\b ! Random(255)
          *tmp + 1
        Next     
      EndIf
          
    Next          
      
  EndIf
ProcedureReturn *addr
EndProcedure



Procedure CryptBuffer(*buffer.POINTER, position.q, *cryptBuffer.POINTER, length.i)
  Protected BLOCKSIZEA.i, BLOCKSIZEB.i, BLOCKSIZE.i, rest.i, pos1.i, pos2.i, maxlen.i
  Protected *d1.POINTER, *d2.POINTER, len4.i, i.i
  BLOCKSIZEA = *cryptBuffer\l
  *cryptBuffer + 4
  BLOCKSIZEB = *cryptBuffer\l
  BLOCKSIZE = BLOCKSIZEA + BLOCKSIZEB
  *cryptBuffer + 4
  
  rest = length
  Repeat
    pos1 = position % BLOCKSIZEA
    pos2 = position % BLOCKSIZEB
    
    maxlen.i = rest
    
    If BLOCKSIZEA - pos1 < maxlen
      maxlen = BLOCKSIZEA - pos1 
    EndIf
    
    If BLOCKSIZEB - pos2 < maxlen
      maxlen = BLOCKSIZEB - pos2 
    EndIf
    
    ;Debug maxlen
    *d1.POINTER = *cryptBuffer + pos1
    *d2.POINTER = *cryptBuffer + pos2 + BLOCKSIZEA
    
    len4 = maxlen / 4 - 1
    
    For i = 0 To len4
      ;a = *d1\l
      ;b = *d2\l
      *buffer\l = *buffer\l ! *d1\l ! *d2\l
      *d1+4
      *d2+4
      *buffer+4
    Next
    
    For i = 0 To maxlen % 4 - 1
      *buffer\b = *buffer\b ! *d1\b ! *d2\b
      *d1+1
      *d2+1
      *buffer+1
    Next
    position + maxlen
    rest - maxlen
  Until rest <= 0
EndProcedure

;{ Example
; 
; addr = __GenerateCryptionBuffer("test")
; 
; ;addr2 = AllocateMemory($FFFFFF)
;  Dim a($FFFFFF)
;  For k=0 To $FFFFFF-1
;  a(k)=k
;  Next
;  a = GetTickCount_()
;  CryptBuffer(@a(0),27632727,addr,16)
;  ;cryptBuffer(@a(0),27632727,addr,16)
;  MessageRequester("",Str(GetTickCount_()-a))
; ; 
;  For k=0 To $FF-1
;  Debug a(k)
;  Next
;}

; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 7
; FirstLine = 2
; Folding = 4
; EnableXP
; EnableCompileCount = 1
; EnableBuildCount = 0
; EnableExeConstant