;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit




Procedure __Min(a.i,b.i)
  If b < a
    a = b
  EndIf
  ProcedureReturn a
EndProcedure



XIncludeFile "GFP_DRMHelpFunctions.pbi" ; 2012-08-03 <PSSWORD FIX>
XIncludeFile "GFP_MemoryStream.pbi"
XIncludeFile "GFP_Cryption4_Unicode.pbi"


#DRM_OK = 0
#DRM_ERROR_INVALIDFILE = -1
#DRM_ERROR_INVALDHEADER = -2
#DRM_ERROR_INVALIDPASSWORD = -3
#DRM_ERROR_FAIL = -4
#DRM_ERROR_INVALIDVERSION = -5
#DRM_ERROR_INVALIDPARAM = -6
#DRM_ERROR_INVALIDCRC = -7
#DRM_ERROR_OUTOFMEMORY = -8

#DRMV2_HEADER_MEDIA_ENCRYPTIONBUFFER = 1000
#DRMV2_HEADER_MEDIA_STANDARDDATA     = 1001
#DRMV2_HEADER_MEDIA_SECURITYDATA     = 1002

#DRMV2_HEADER_MEDIA_ORGINALNAME           = 2000
#DRMV2_HEADER_MEDIA_ALBUM                 = 2001
#DRMV2_HEADER_MEDIA_INTERPRETER           = 2002
#DRMV2_HEADER_MEDIA_COMMENT               = 2003
#DRMV2_HEADER_MEDIA_PASSWORDTIP           = 2004
#DRMV2_HEADER_MEDIA_TITLE                 = 2006
#DRMV2_HEADER_MEDIA_USERDATA              = 2007
#DRMV2_HEADER_MEDIA_CODECNAME             = 2008
#DRMV2_HEADER_MEDIA_CODECLINK             = 2009
#DRMV2_HEADER_MEDIA_PARTITION_ID          = 2010
#DRMV2_HEADER_MEDIA_PLAYERVERSION         = 2011
#DRMV2_HEADER_MEDIA_MACHINEID             = 2012
#DRMV2_HEADER_MEDIA_MACHINEID_VERSION     = 2013

#DRMV2_HEADER_MEDIA_COVER = 3000


#DRMV2_BLOCK_STRINGSIZE = 260
#DRMV2_BLOCK_COMMENTSIZE = 5000

#DRMV2_ALGORITHM_PBINTERNAL = 0
#DRMV2_ALGORITHM_RNDDATA = 1

#DRM_ENCRYPTION_SIZE = $FFFF*4

#DRM_COVER_FORMAT_PACKED32BIT_Y22_CB5_CR5 = 1497580114 ;'YCBR'

#DRM_COVER_SIZE = 512;512
#DRM_COVER_RESIZE = 512

#OEM_TEXT_BYTESIZE = 128

Structure DRM_COVER ; Old DRM Header
  bUseCover.l
  lFormat.l
  Packed.l[#DRM_COVER_SIZE/2*#DRM_COVER_SIZE/2]  
EndStructure

Structure DRM_HEADER ; Old DRM Header
  lMagic.l
  lSize.l
  lVersion.l
  qUniqueID.q
  sOrginalName.w[260]
  sTitle.w[32]
  sAlbum.w[32]
  sInterpreter.w[32]
  sComments.w[6000]
  sPasswordTip.w[32]
  fAspect.f
  qLength.q
  lCreationDate.l
  bCanRemoveDRM.l
  lSnapshotProtection.l
  sUserData.w[50]
  unknown.b[7900] ; Not used at the moment
  cover.DRM_COVER
  lHeaderCheckSum.l
EndStructure


Structure DRM_HEADER_GENERIC
  lMagic.l
  lSize.l   ; SizeOf(DRM_HEADER_V2)
  lVersion.l 
  qCompleteHeadSize.q ; Not really the same for both headers -> only use for V2!  
EndStructure  

Structure DRM_HEADER_V2 ; New DRM Header
  lMagic.l
  lSize.l  ; SizeOf(DRM_HEADER_V2)
  lVersion.l  ;200
  qCompleteHeadSize.q ; Offset zum Medium  
  lPasswordCheckSum.l
  lEncryptionAlgorithm.l
  lNumBlocks.l 
  lNumMedia.l ; Not used
  OEMData.b[#OEM_TEXT_BYTESIZE]
  unknown.l[500 * SizeOf(Long)]  
  lHeaderCheckSum.l  
EndStructure

Structure DRM_HEADER_BLOCK ; New DRM Header
  lMagic.l  
  lID.l
  lMediaID.l ; Not used
  qSize.q
  lEncryption.l ; Not used  
  unknown.l[12 * SizeOf(Long)]
  lDataCheckSum.l  
  lHeadCheckSum.l  
EndStructure

Structure DRM_STANDARD_DATA ; New DRM Header
  qUniqueID.q  
  fAspect.f
  qLength.q
  lCreationDate.l
  unknown.l[128] ; Not used at the moment  
EndStructure

Structure DRM_SECURITY_DATA ; New DRM Header
  bCanRemoveDRM.l
  lSnapshotProtection.l
  qExpireDate.q
  unknown.l[128] ; Not used at the moment  
EndStructure


#MAX_DRM_PASSWORD = 2048

Structure DRMV2_HEADER_READ_OBJECT
  *header.DRM_HEADER_V2
  readResult.i
  *cryptionBuffer
  *cryptionBufferHeader
  password.s{#MAX_DRM_PASSWORD}
EndStructure  

Structure DRMV2_HEADER_WRITE_OBJECT
  *header.DRM_HEADER_V2
  *stream
  *cryptionBufferHeader  
  password.s{#MAX_DRM_PASSWORD}
EndStructure  


Prototype cryptionCB(position.q, size.q)

Procedure __DRMDebug(sText.s)
  ;- ! uncomment ME !
  WriteLog(sText, #LOGLEVEL_DEBUG)
  ;Debug sText
EndProcedure

Procedure __DRMError(sText.s)
  ;- ! uncomment ME !
  WriteLog(sText, #LOGLEVEL_ERROR)
  ;Debug sText
EndProcedure

Procedure.s __DRMErrorString(iResult)
  Select iResult
    Case #DRM_OK
      ProcedureReturn "DRM_OK"
    Case #DRM_ERROR_INVALIDFILE 
      ProcedureReturn "DRM_ERROR_INVALIDFILE"
    Case #DRM_ERROR_INVALDHEADER
      ProcedureReturn "DRM_ERROR_INVALDHEADER"
    Case #DRM_ERROR_INVALIDPASSWORD
      ProcedureReturn "DRM_ERROR_INVALIDPASSWORD"
    Case #DRM_ERROR_FAIL
      ProcedureReturn "DRM_ERROR_FAIL"
    Case #DRM_ERROR_INVALIDVERSION
      ProcedureReturn "DRM_ERROR_INVALIDVERSION"
    Case #DRM_ERROR_INVALIDPARAM
      ProcedureReturn "DRM_ERROR_INVALIDPARAM"
    Case #DRM_ERROR_INVALIDCRC
      ProcedureReturn "DRM_ERROR_INVALIDCRC"
    Case #DRM_ERROR_OUTOFMEMORY
      ProcedureReturn "DRM_ERROR_OUTOFMEMORY"
  EndSelect
  ProcedureReturn "UNKNOWN!"
EndProcedure



; Procedure.l __CRC32Of1xMD5Password(sPassword.s)
;   Protected sMD5Password.s, ptrsPassword, ptrsMD5Password, Result.i = 0
;   
;   ptrsPassword =__AnsiString(sPassword)
;   If ptrsPassword
;     sMD5Password.s = MD5Fingerprint(ptrsPassword, Len(sPassword))
;     ptrsMD5Password =__AnsiString(sMD5Password)  
;     If ptrsMD5Password
;       Result = CRC32Fingerprint(ptrsMD5Password, Len(sMD5Password))
;       FreeMemory(ptrsMD5Password)  
;     EndIf  
;     FreeMemory(ptrsPassword)
;   EndIf
;   ProcedureReturn Result
; EndProcedure
; 
; Procedure.l __CRC32Of2xMD5Password(sPassword.s)
;   Protected sMD5Password.s, sMD5MD5Password.s, ptrsPassword, ptrsMD5Password, ptrsMD5MD5Password, Result.i = 0
;   
;   ptrsPassword =__AnsiString(sPassword)
;   If ptrsPassword
;     sMD5Password.s = MD5Fingerprint(ptrsPassword,Len(sPassword))
;     ptrsMD5Password =__AnsiString(sMD5Password)  
;     If ptrsMD5Password
;       sMD5MD5Password.s = MD5Fingerprint(ptrsMD5Password,Len(sMD5Password))
;       ptrsMD5MD5Password =__AnsiString(sMD5MD5Password)    
;       If ptrsMD5MD5Password
;       
;         Result = CRC32Fingerprint(ptrsMD5MD5Password, Len(sMD5MD5Password))
;         FreeMemory(ptrsMD5MD5Password)
;       EndIf
;       FreeMemory(ptrsMD5Password)
;     EndIf
;     FreeMemory(ptrsPassword)
;   EndIf
;   ProcedureReturn Result
;   ;sMD5Password.s = MD5Fingerprint(@sPassword,StringByteLength(sPassword))
;   ;sMD5MD5Password.s = MD5Fingerprint(@sMD5Password,StringByteLength(sMD5Password))
;   ;ProcedureReturn CRC32Fingerprint(@sMD5MD5Password, StringByteLength(sMD5MD5Password))
; EndProcedure


; Procedure.l __CRC32Of3xMD5Password(sPassword.s)
;   Protected str.s, ptrs, crc32
;   
;   str = __MD5OfString(__MD5OfString(__MD5OfString(sPassword)))
;   ptrs = __AnsiString(str)
;   If ptrs
;     crc32 = CRC32Fingerprint(ptrs, Len(str))
;     FreeMemory(ptrs)
;   EndIf  
;   ProcedureReturn crc32
; EndProcedure  

; Procedure.l __CRC32Of2xMD5MemoryPointer(*ptr, length) 
;   Protected sMD5Password.s, sMD5MD5Password.s, ptrsMD5Password, ptrsMD5MD5Password, Result.i = 0
;   
;   If *ptr
;     sMD5Password.s = MD5Fingerprint(*ptr, length)
;     ptrsMD5Password =__AnsiString(sMD5Password)  
;     If ptrsMD5Password
;       sMD5MD5Password.s = MD5Fingerprint(ptrsMD5Password,Len(sMD5Password))
;       ptrsMD5MD5Password =__AnsiString(sMD5MD5Password)    
;       If ptrsMD5MD5Password
;       
;         Result = CRC32Fingerprint(ptrsMD5MD5Password, Len(sMD5MD5Password))
;         FreeMemory(ptrsMD5MD5Password)
;       EndIf
;       FreeMemory(ptrsMD5Password)
;     EndIf
;   EndIf
;   ProcedureReturn Result
; EndProcedure

; 
Procedure InitDRMHeader(*header.DRM_HEADER, sOrginalFileName.s)
ZeroMemory_(*header, SizeOf(DRM_HEADER))  ;2010-08-09
*header\lMagic = 1145392472;'DEMX'
*header\lSize = SizeOf(DRM_HEADER)
*header\lCreationDate = Date()
RandomSeed(GetTickCount_() & $FFFFFF)
*header\qUniqueID = Random($FFFF) << 48 + Random($FFFF) << 32 + Random($FFFF) << 16 + Random($FFFF)
*header\qUniqueID ! Date()
*header\lVersion = 100

PokeS(@*header\sOrginalName, GetFilePart(sOrginalFileName), 260, #PB_Unicode)
EndProcedure
; 
; Procedure InitDRMHeader_V2()
; *header.DRM_HEADER_V2 = AllocateMemory(DRM_HEADER_V2)  
; ZeroMemory_(*header, SizeOf(DRM_HEADER_V2))  ;2010-08-09
; *header\lMagic = 1145392472;'DEMX'
; *header\lSize = SizeOf(DRM_HEADER_V2)
; *header\lVersion = 200
; *header\qCompleteSize = SizeOf(DRM_HEADER_V2)
; *header\lNumMedia = 0
; *header\lNumBlocks = 0
; ProcedureReturn *header
; EndProcedure


; Procedure DeleteDRMHeaderV2_Attribute(*header.DRM_HEADER_V2, lID, lMediaID)
;   Protected deleted.i = 0, completeSize.q = 0,  deletedSize.q = 0
;   If *header
;     completeSize = *header\qCompleteSize
;     count = *header\lNumBlocks 
;     *ptr.DRM_HEADER_BLOCK = *header + SizeOf(DRM_HEADER_V2)
;     For idx = 0 To count - 1
;       If *ptr\lID = lID And *ptr\lMediaID = lMediaID
;         *ptr\lID = #DRMV2_HEADER_DELETED
;         deleted + 1
;         deletedSize + SizeOf(DRM_HEADER_BLOCK) + *ptr\qSize
;       EndIf  
;     Next     
;     
;     
;     *dst_Header.DRM_HEADER_V2 = AllocateMemory(SizeOf(DRM_HEADER_V2))  
;     
;     *src_Block.DRM_HEADER_BLOCK = *src_Header + SizeOf(DRM_HEADER_V2)    
;     *dst_Block.DRM_HEADER_BLOCK = *dst_Header + SizeOf(DRM_HEADER_V2)    
;     
;     For idx = 0 To count - 1
;       If *src_Block\lID <> lID Or *src_Block\lMediaID <> lMediaID
;           
;       EndIf
;       *src_Block + *src_Block\qSize + SizeOf(DRM_HEADER_BLOCK)
;     Next          
;   EndIf   
; EndProcedure  
; 

; Procedure SetDRMHeaderV2_Attribute(*header.DRM_HEADER_V2, lID, lMediaID, *data.BYTE, size.q)
;   If *header
;     count = *header\lNumBlocks 
;     *ptr.DRM_HEADER_BLOCK = *header + SizeOf(DRM_HEADER_V2)
;     For idx = 0 To count -1
;       If *ptr\lID = lID And *ptr\lMediaID = lMediaID
;       EndIf  
;     Next  
;   EndIf  
; EndProcedure  
; 


Procedure SetDRMHeaderTitle(*header.DRM_HEADER, sTitle.s)
If *header
  PokeS(@*header\sTitle, sTitle, __Min(Len(sTitle),31), #PB_Unicode)
EndIf
EndProcedure

Procedure SetDRMHeaderAlbum(*header.DRM_HEADER, sAlbum.s)
If *header
  PokeS(@*header\sAlbum, sAlbum, __Min(Len(sAlbum),31), #PB_Unicode)
EndIf
EndProcedure

Procedure SetDRMHeaderInterpreter(*header.DRM_HEADER, sInterpreter.s)
If *header
  PokeS(@*header\sInterpreter, sInterpreter, __Min(Len(sInterpreter),31), #PB_Unicode)
EndIf
EndProcedure

Procedure SetDRMHeaderMediaLength(*header.DRM_HEADER, qLen.q)
If *header
  *header\qLength = qLen
EndIf
EndProcedure

Procedure SetDRMHeaderCanRemoveDRM(*header.DRM_HEADER, bCanRemoveDRM.l)
If *header
  *header\bCanRemoveDRM = bCanRemoveDRM
EndIf
EndProcedure

Procedure SetDRMHeaderCreationDate(*header.DRM_HEADER, lCreationDate.l)
If *header
  *header\lCreationDate = lCreationDate
EndIf
EndProcedure

Procedure SetDRMHeaderSnapshotProtection(*header.DRM_HEADER, lSnapshotProtection.l)
If *header
  *header\lSnapshotProtection = lSnapshotProtection
EndIf
EndProcedure



Procedure SetDRMHeaderAspect(*header.DRM_HEADER, fAspect.f)
If *header
  *header\fAspect = fAspect
EndIf
EndProcedure


Procedure SetDRMHeaderComment(*header.DRM_HEADER, sComment.s)
If *header
  PokeS(@*header\sComments, sComment, __Min(Len(sComment),5999), #PB_Unicode)
EndIf
EndProcedure

Procedure SetDRMHeaderUserData(*header.DRM_HEADER, sUserData.s)
If *header
  PokeS(@*header\sUserData, sUserData, __Min(Len(sUserData),49), #PB_Unicode)
EndIf
EndProcedure


Procedure SetDRMHeaderPasswordTip(*header.DRM_HEADER, sPasswordTip.s)
If *header
  PokeS(@*header\sPasswordTip, sPasswordTip, __Min(Len(sPasswordTip),31), #PB_Unicode)
EndIf
EndProcedure

Procedure FinalizeDRMHeader(*header.DRM_HEADER, sPassword.s)
If *header
  *header\lHeaderCheckSum = CRC32Fingerprint(*header, SizeOf(DRM_HEADER) - SizeOf(Long)) ! __CRC32Of2xMD5Password(sPassword.s)
EndIf
EndProcedure

Procedure ReadDRMHeader(sFile.s, *header.DRM_HEADER, sPassword.s, qOffset.q = 0)
  Protected iResult.i, iFile.i, lCheckSum.l
  iResult = #DRM_ERROR_FAIL
  If *header
    iFile.i = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
    If iFile
      FileSeek(iFile, qOffset)
      ReadData(iFile, *header, SizeOf(DRM_HEADER))   
      If *header\lMagic = 1145392472;'DEMX'
        lCheckSum.l = CRC32Fingerprint(*header, SizeOf(DRM_HEADER) - SizeOf(Long)) ! __CRC32Of2xMD5Password(sPassword.s)
        ;Debug lCheckSum
        ;Debug *header\lHeaderCheckSum
        If lCheckSum = *header\lHeaderCheckSum
          iResult = #DRM_OK
        Else
          iResult = #DRM_ERROR_INVALIDPASSWORD
        EndIf
      Else
        iResult = #DRM_ERROR_INVALDHEADER    
      EndIf
      
      CloseFile(iFile)
    Else
      iResult = #DRM_ERROR_INVALIDFILE
    EndIf
  Else
    iResult = #DRM_ERROR_FAIL
  EndIf
  
  If iResult <> #DRM_OK
    __DRMDebug("WARN: ReadDRMHeader for file '"+ sFile + "' failed with error " + __DRMErrorString(iResult))  
  EndIf
  
ProcedureReturn iResult
EndProcedure

Procedure CheckDRMHeader(*header.DRM_HEADER, sPassword.s)
  Protected iResult.i, lCheckSum.l
  iResult = #DRM_ERROR_FAIL
  If *header
    If *header\lMagic = 1145392472;'DEMX'
      lCheckSum.l = CRC32Fingerprint(*header, SizeOf(DRM_HEADER) - SizeOf(Long)) ! __CRC32Of2xMD5Password(sPassword.s)
      If lCheckSum = *header\lHeaderCheckSum
        iResult = #DRM_OK
      Else
        iResult = #DRM_ERROR_INVALIDPASSWORD
      EndIf
    Else
      iResult = #DRM_ERROR_INVALDHEADER    
    EndIf
  Else
    iResult = #DRM_ERROR_FAIL
  EndIf
ProcedureReturn iResult
EndProcedure



Procedure.s GetDRMOrgFileName(*header.DRM_HEADER)
If *header
  ProcedureReturn PeekS(@*header\sOrginalName, -1, #PB_Unicode)
EndIf
EndProcedure

Procedure.s GetDRMPasswordTip(*header.DRM_HEADER)
If *header
  ProcedureReturn PeekS(@*header\sPasswordTip, -1, #PB_Unicode)
EndIf
EndProcedure

Procedure.s GetDRMHeaderTitle(*header.DRM_HEADER)
If *header
  ProcedureReturn PeekS(@*header\sTitle, -1, #PB_Unicode)
EndIf
EndProcedure

Procedure.s GetDRMHeaderAlbum(*header.DRM_HEADER)
If *header
  ProcedureReturn PeekS(@*header\sAlbum, -1, #PB_Unicode)
EndIf
EndProcedure

Procedure.s GetDRMHeaderInterpreter(*header.DRM_HEADER)
If *header
  ProcedureReturn PeekS(@*header\sInterpreter, -1, #PB_Unicode)
EndIf
EndProcedure

Procedure.s GetDRMHeaderComments(*header.DRM_HEADER)
If *header
  ProcedureReturn PeekS(@*header\sComments, -1, #PB_Unicode)
EndIf
EndProcedure

Procedure.s GetDRMHeaderUserData(*header.DRM_HEADER)
If *header
  ProcedureReturn PeekS(@*header\sUserData, -1, #PB_Unicode)
EndIf
EndProcedure

Procedure.q GetDRMHeaderMediaLength(*header.DRM_HEADER)
If *header
  ProcedureReturn *header\qLength
EndIf
EndProcedure

Procedure.q GetDRMHeaderSnapshotProtection(*header.DRM_HEADER)
If *header
  ProcedureReturn *header\lSnapshotProtection
EndIf
EndProcedure

Procedure.l GetDRMHeaderCreationDate(*header.DRM_HEADER)
If *header
  ProcedureReturn *header\lCreationDate
EndIf
EndProcedure

Procedure SetDRMHeaderCover(*header.DRM_HEADER, image)
  Protected y,cb,cr,fy.f,fcb.f,fcr.f,r.f,g.f,b.f, offsetX, offsetY, imgcopy, px,py, rgb
  Protected Dim _valuesY(1,1)
  imgcopy = CopyImage(image, #PB_Any)  
  If imgcopy
    ResizeImage(imgcopy, #DRM_COVER_SIZE, #DRM_COVER_SIZE, #PB_Image_Smooth)
    
    StartDrawing(ImageOutput(imgcopy))
    For py=0 To #DRM_COVER_SIZE-1 Step 2
      For px=0 To #DRM_COVER_SIZE-1 Step 2
        
        cb = 0
        cr = 0
        For offsetY = 0 To 1
          For offsetX = 0 To 1  
            rgb =Point(px + offsetX,py + offsetY)
            r = Red(rgb)
            g = Green(rgb)
            b = Blue(rgb)
            fy  = ( 0.2990 * r + 0.5870 * g + 0.1140 * b + 0.5)    
            fcb =(-0.1687 * r - 0.3313 * g + 0.5000 * b + 127.5 + 0.5)
            fcr =( 0.5000 * r - 0.4187 * g - 0.0813 * b + 127.5 + 0.5)
            y = fy
            cb + fcb
            cr + fcr
            
            If y < 0 : y = 0:EndIf
            If y > 255: y = 255:EndIf   
            If offsetX XOr offsetY
              _valuesY(offsetX, offsetY) = y >> 3
            Else
              _valuesY(offsetX, offsetY) = y >> 2              
            EndIf
          Next
        Next       
        cb >> 2
        cr >> 2
        
        If cb < 0 : cb = 0:EndIf
        If cb > 255: cb = 255:EndIf
        If cr < 0 : cr = 0:EndIf
        If cr > 255: cr = 255:EndIf 
        *header\cover\Packed[(px/2)*#DRM_COVER_SIZE/2+(py/2)] = _valuesY(0, 0) + (_valuesY(1, 0) << 6) + (_valuesY(0, 1)<<11) + (_valuesY(1, 1)<< 16) + ((cr >> 3) << 22) + ((cb >> 3) << 27)         
      Next
    Next
    StopDrawing()
    *header\cover\bUseCover = #True
    *header\cover\lFormat = #DRM_COVER_FORMAT_PACKED32BIT_Y22_CB5_CR5
  EndIf
EndProcedure

Procedure __ConvertPackedColorToRGB(y,cr,cb, bDitherAdd)
  Protected r,g,b, fr.f,fg.f,fb.f
 
  cr << 3
  cb << 3
  If bDitherAdd
    y << 3
    y + 3
    cr + 3;15  ; Zu starkes dithering verhindern
    cb + 3;15
  Else
    y << 2
    y - 1
    cr - 3;15
    cb - 3;15
  EndIf
  
  cb - 127
  cr - 127
  
  fr = (y + 1.40200 * cr + 0.5);
  fg = (y - 0.34414 * cb - 0.71417 * cr + 0.5);
  fb = (y + 1.77200 * cb + 0.5);
  r = fr
  g = fg
  b = fb
  If r < 0: r = 0:EndIf
  If r > 255: r = 255:EndIf
  If g < 0: g = 0:EndIf
  If g > 255: g = 255:EndIf
  If b < 0: b = 0:EndIf
  If b > 255: b = 255:EndIf
  ProcedureReturn RGB(r,g,b)
EndProcedure

Procedure GetDRMHeaderCover(*header.DRM_HEADER)
  Protected y,cb,cr,r,g,b, offsetX, offsetY, image ,px,py,packed
  Protected Dim _valuesY(1,1)
  If *header
    If *header\cover\bUseCover
      image = CreateImage(#PB_Any, #DRM_COVER_SIZE, #DRM_COVER_SIZE)  
      If image
        StartDrawing(ImageOutput(image))
        For py=0 To #DRM_COVER_SIZE-1 Step 2
          For px=0 To #DRM_COVER_SIZE-1 Step 2
            
            packed.i = *header\cover\Packed[(px/2)*#DRM_COVER_SIZE/2+(py/2)]
            cb = (packed >> 27) & %11111
            cr = (packed >> 22) & %11111              
            Plot(px,py, __ConvertPackedColorToRGB((packed & %111111),cr,cb, #False))
            Plot(px+1,py, __ConvertPackedColorToRGB(((packed >> 6) & %11111),cr,cb, #True))       
            Plot(px,py+1, __ConvertPackedColorToRGB(((packed >> 11) & %11111),cr,cb, #True))
            Plot(px+1,py+1, __ConvertPackedColorToRGB(((packed >> 16) & %111111),cr,cb, #False))     
           ; = _valuesY(0, 0) + _valuesY(1, 0)<<6 + _valuesY(0, 1)<<12 + _valuesY(1, 1)<< 18 + (cr >> 6) << 24 + (cb >> 6) << 28         
         Next
        Next
        StopDrawing()
        If #DRM_COVER_SIZE <> #DRM_COVER_RESIZE
          ResizeImage(image,#DRM_COVER_RESIZE,#DRM_COVER_RESIZE,#PB_Image_Smooth)      
        EndIf      
      EndIf
    EndIf
  EndIf
  ProcedureReturn image
EndProcedure

Procedure DecryptDRMFileToMemory(sFile.s, sPassword.s)
  Protected header.DRM_HEADER, iResult.i, iFile.i, iSize.i, *cryptBuffer, *memory, iDRMResult
  
  header.DRM_HEADER
  iResult = #E_FAIL 
  iDRMResult = ReadDRMHeader(sFile, @header, sPassword) 
  If iDRMResult = #DRM_OK
    iFile.i = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
    If iFile  
      iSize = Lof(iFile) - SizeOf(DRM_HEADER)
      *cryptBuffer = GenerateCryptionBuffer(sPassword)
      If *cryptBuffer
        *memory = AllocateMemory(iSize)
        If *memory
          FileSeek(iFile, SizeOf(DRM_HEADER))
          ReadData(iFile, *memory, iSize)
          CryptBuffer(*memory, 0, *cryptBuffer, iSize)       
          iResult = #S_OK
        Else
          __DRMError("DecryptDRMFileToMemory: out of memory")        
        EndIf
        FreeMemory(*cryptBuffer)
      Else
        __DRMError("DecryptDRMFileToMemory: generating cryption buffer failed, out of memory")
      EndIf
      CloseFile(iFile)
    Else
      __DRMError("DecryptDRMFileToMemory: open file '" + sFile + "' for read access failed (" + Str(GetLastError_()) + ")")       
    EndIf
  Else
    __DRMError("DecryptDRMFileToMemory: ReadDRMHeader failed with HRESULT "+ __DRMErrorString(iDRMResult))
  EndIf
  If iResult = #S_OK
    ProcedureReturn *memory
  Else
    ProcedureReturn #Null
  EndIf
EndProcedure

;Use only with correct header
Procedure EncryptFile(sFile.s, sEncFile.s, sPassword.s, *header.DRM_HEADER, cb.cryptionCB)
  Protected iResult.i, *tmp, *cryptBuffer, iReadFile.i, iCreateFile.i, size.q, rest.q, pos.q, abort
  iResult = #E_FAIL
  *tmp = AllocateMemory(#DRM_ENCRYPTION_SIZE)
  If *tmp
    *cryptBuffer = GenerateCryptionBuffer(sPassword)
    If *cryptBuffer
      iReadFile.i = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
      If iReadFile
        iCreateFile.i = CreateFile(#PB_Any, sEncFile)
        If iCreateFile
          WriteData(iCreateFile, *header, SizeOf(DRM_HEADER))
          
          size.q = Lof(iReadFile)
          rest.q = Lof(iReadFile)
          pos.q = 0
          Repeat 
            If rest >= #DRM_ENCRYPTION_SIZE
              ReadData(iReadFile,*tmp, #DRM_ENCRYPTION_SIZE)
              CryptBuffer(*tmp, pos,  *cryptBuffer, #DRM_ENCRYPTION_SIZE)
              WriteData(iCreateFile, *tmp, #DRM_ENCRYPTION_SIZE)
              pos + #DRM_ENCRYPTION_SIZE
              rest - #DRM_ENCRYPTION_SIZE
            Else
              ReadData(iReadFile, *tmp, rest)
              CryptBuffer(*tmp, pos,  *cryptBuffer, rest)
              WriteData(iCreateFile, *tmp, rest)    
              pos + rest
              rest = 0
            EndIf
            If cb
              abort = cb(pos, size)
            EndIf
          Until rest = 0 Or abort
          If abort
            iResult = #E_ABORT
            __DRMDebug("EncryptFile: user aborted encryption")
          Else
            iResult = #S_OK
          EndIf  
          CloseFile(iCreateFile)
        Else
          __DRMError("EncryptFile: open file '" + sEncFile + "' for write access failed (" + Str(GetLastError_()) + ")")         
        EndIf
        CloseFile(iReadFile)  ; 2010-04-11 verschoben
      Else
        __DRMError("EncryptFile: open file '" + sFile + "' for read access failed (" + Str(GetLastError_()) + ")") 
      EndIf
      FreeMemory(*cryptBuffer)
    Else
      __DRMError("EncryptFile: generating cryption buffer failed, out of memory")
    EndIf
    FreeMemory(*tmp)
  EndIf
  ProcedureReturn iResult
EndProcedure

;Use only with correct password
Procedure DecryptFile(sEncFile.s, sFile.s, sPassword.s, cb.cryptionCB)
  Protected iResult.i, *tmp, *cryptBuffer, iReadFile.i, iCreateFile.i, size.q, rest.q, pos.q, abort
  Protected header.DRM_HEADER
  iResult = #E_FAIL
  *tmp = AllocateMemory(#DRM_ENCRYPTION_SIZE)
  If *tmp
    *cryptBuffer = GenerateCryptionBuffer(sPassword)
    If *cryptBuffer
      iReadFile.i = ReadFile(#PB_Any, sEncFile, #PB_File_SharedRead )
      If iReadFile
        iCreateFile.i = CreateFile(#PB_Any, sFile)
        If iCreateFile
          ;WriteData(iCreateFile, *header, SizeOf(DRM_HEADER))
          ReadData(iReadFile, header, SizeOf(DRM_HEADER))
          size.q = Lof(iReadFile) - SizeOf(DRM_HEADER)
          rest.q = Lof(iReadFile) - SizeOf(DRM_HEADER)
          pos.q = 0
          Repeat 
            If rest >= #DRM_ENCRYPTION_SIZE
              ReadData(iReadFile,*tmp, #DRM_ENCRYPTION_SIZE)
              CryptBuffer(*tmp, pos,  *cryptBuffer, #DRM_ENCRYPTION_SIZE)
              WriteData(iCreateFile, *tmp, #DRM_ENCRYPTION_SIZE)
              pos + #DRM_ENCRYPTION_SIZE
              rest - #DRM_ENCRYPTION_SIZE
            Else
              ReadData(iReadFile, *tmp, rest)
              CryptBuffer(*tmp, pos,  *cryptBuffer, rest)
              WriteData(iCreateFile, *tmp, rest)    
              pos + rest
              rest = 0
            EndIf
            If cb
              abort = cb(pos, size)
            EndIf
          Until rest = 0 Or abort
          If abort
            __DRMDebug("DecryptFile: user aborted encryption")
            iResult = #E_ABORT
          Else
            iResult = #S_OK
          EndIf  
          CloseFile(iCreateFile)
        Else
          __DRMError("DecryptFile: open file '" + sFile + "' for write access failed (" + Str(GetLastError_()) + ")")                   
        EndIf
        CloseFile(iReadFile) ; 2010-04-11 verschoben
      Else
        __DRMError("DecryptFile: open file '" + sEncFile + "' for read access failed (" + Str(GetLastError_()) + ")")         
      EndIf
      FreeMemory(*cryptBuffer)
    Else
      __DRMError("DecryptFile: generating cryption buffer failed, out of memory")      
    EndIf
    FreeMemory(*tmp)
  EndIf
  ProcedureReturn iResult
EndProcedure

















;-======================== Header V2 Ergänzung ========================
;-================================================================================


;Returns a pointer to the data. FreeMemory() must be called after the memory is not needed anymore.
Procedure __SaveJPEGInMem(iImage.i, iQuality.i)
  Protected ImageFile, iSize, *mem = #Null, iNumBytes, iResult.i
  ImageFile = CreateNamedPipe_("\\.\pipe\ImageFileJPEG",#PIPE_ACCESS_INBOUND,#PIPE_TYPE_BYTE|#PIPE_READMODE_BYTE|#PIPE_NOWAIT,1,0,-1,#NMPWAIT_USE_DEFAULT_WAIT,#Null) 
  If ImageFile
    SaveImage(iImage,"\\.\pipe\ImageFileJPEG",#PB_ImagePlugin_JPEG, iQuality) 
    iSize = GetFileSize_(ImageFile, 0)
    If iSize > 0     
      *mem = AllocateMemory(iSize)
      If *mem
        iResult = ReadFile_(ImageFile, *mem, iSize ,@iNumBytes, #Null)
        If iResult = #False
          FreeMemory(*mem)
          *mem = #Null
        EndIf 
      EndIf
    EndIf 
    CloseHandle_(ImageFile)  
  EndIf
  ProcedureReturn *mem
EndProcedure

Procedure __DRMV2_AnalyzeGenericHeader(*genHeader.DRM_HEADER_GENERIC, *headerSize.integer = #Null)
  Protected iResult = #DRM_ERROR_FAIL 
  If *headerSize
    *headerSize\i = 0
  EndIf
  
  If *genHeader\lMagic = 1145392472 ; 'DEMX'
    If (*genHeader\lVersion = 100 And *genHeader\lSize = SizeOf(DRM_HEADER))
      If *headerSize
        *headerSize\i = SizeOf(DRM_HEADER)
      EndIf      
      iResult = #DRM_OK
    ElseIf (*genHeader\lVersion = 200 And *genHeader\lSize = SizeOf(DRM_HEADER_V2))
      If *headerSize
        *headerSize\i = *genHeader\qCompleteHeadSize
      EndIf  
      iResult = #DRM_OK
      
    Else
      ;__DRMError( Chr(34) + file + Chr(34)+ " has invalid header!")        
      iResult = #DRM_ERROR_INVALDHEADER       
    EndIf   
  Else
    ;__DRMError( Chr(34) + file + Chr(34)+ " has invalid header!")        
    iResult = #DRM_ERROR_INVALDHEADER    
  EndIf       
  ProcedureReturn iResult
EndProcedure  

Procedure __DRMV2_AnalyzeHeaderV1(*header.DRM_HEADER, sPassword.s)
  Protected iResult.i, iFile.i, lCheckSum.l
  iResult = #DRM_ERROR_FAIL
  If *header  
    If *header\lVersion = 100
      iResult = __DRMV2_AnalyzeGenericHeader(*header)
      If iResult = #DRM_OK
        lCheckSum.l = CRC32Fingerprint(*header, SizeOf(DRM_HEADER) - SizeOf(Long)) ! __CRC32Of2xMD5Password(sPassword.s)
  
        If lCheckSum = *header\lHeaderCheckSum
          iResult = #DRM_OK
        Else
          iResult = #DRM_ERROR_INVALIDPASSWORD
        EndIf
      EndIf  
    Else
      iResult = #DRM_ERROR_INVALIDVERSION
    EndIf
  Else
    iResult = #DRM_ERROR_INVALIDPARAM    
  EndIf
ProcedureReturn iResult
EndProcedure  


Procedure __DRMV2_AnalyzeHeaderV2(*header.DRM_HEADER_V2, sPassword.s)
  Protected iResult.i, iFile.i, lCheckSum.l
  iResult = #DRM_ERROR_FAIL
  If *header  

    If *header\lVersion = 200
      iResult = __DRMV2_AnalyzeGenericHeader(*header)       
      If iResult = #DRM_OK
        lCheckSum.l = __CRC32Of2xMD5Password(sPassword.s)
        
        
        If lCheckSum = *header\lPasswordCheckSum
          If *header\lHeaderCheckSum = CRC32Fingerprint(*header, SizeOf(DRM_HEADER_V2) - SizeOf(Long))
            iResult = #DRM_OK
          Else
            iResult = #DRM_ERROR_INVALIDCRC
          EndIf              
        Else
          iResult = #DRM_ERROR_INVALIDPASSWORD
        EndIf
      EndIf  
    Else
      iResult = #DRM_ERROR_INVALIDVERSION
    EndIf
  Else
    iResult = #DRM_ERROR_INVALIDPARAM    
  EndIf
ProcedureReturn iResult
EndProcedure  

Procedure __DRMV2_FindBlockOffset(*buffer.DRM_HEADER_V2, lMediaID.l, lID.l)
  Protected iOffset = -1, *head.DRM_HEADER_V2, x, *block.DRM_HEADER_BLOCK
  If *buffer
    ;*ptr = MEMORYSTREAM_LockBuffer(*strm)
    *head.DRM_HEADER_V2 = *buffer
    
    *block.DRM_HEADER_BLOCK = *buffer + SizeOf(DRM_HEADER_V2)
    
    For x=0 To *head\lNumBlocks - 1
      
      If (*block < *buffer + *buffer\qCompleteHeadSize) And (*block >= (*buffer + SizeOf(DRM_HEADER_V2)))
        If *block\lID = lID And *block\lMediaID = lMediaID
          
          ;Debug Str(__CRC32Of2xMD5MemoryPointer(*block, SizeOf(DRM_HEADER_BLOCK) - SizeOf(Long))) + " vs "+Str(*block\lHeadCheckSum        )           
          ;Debug Str(__CRC32Of2xMD5MemoryPointer(*block + SizeOf(DRM_HEADER_BLOCK), *block\qSize)) + " vs "+Str(*block\lDataCheckSum       )
          
          If CRC32Fingerprint(*block, SizeOf(DRM_HEADER_BLOCK) - SizeOf(Long)) = *block\lHeadCheckSum        
            If CRC32Fingerprint(*block + SizeOf(DRM_HEADER_BLOCK), *block\qSize) = *block\lDataCheckSum
              iOffset = *block - *buffer       
              Break
            Else
              ;IGNORE CRC Check:
              ;iOffset = *block - *buffer     
              __DRMError("FindBlockOffset: block data checksum error") 
              Break
            EndIf
          Else
            __DRMError("FindBlockOffset: block head checksum error")
            Break
          EndIf
        EndIf
      Else
        __DRMError("FindBlockOffset: block offset is invalid")
        Break
      EndIf
      *block + SizeOf(DRM_HEADER_BLOCK) + *block\qSize
    Next
      ;MEMORYSTREAM_UnLockBuffer(*strm)
  EndIf
  ProcedureReturn iOffset
EndProcedure  

Procedure __DRMV2Creation_Init(password.s, NewEncAlgorithm.i, crc32, OemData.s)
  Protected  *header.DRM_HEADER_V2, *strm
  *header.DRM_HEADER_V2 = AllocateMemory(SizeOf(DRM_HEADER_V2))
  If *header
    ;ZeroMemory_(*header, SizeOf(DRM_HEADER))  ;2010-08-09 
    *header\lMagic = 1145392472;'DEMX'
    *header\lSize = SizeOf(DRM_HEADER_V2)
    *header\lVersion = 200
    
    ;2011-09-03
    ZeroMemory_(@*header\OEMData[0], #OEM_TEXT_BYTESIZE)
    PokeS(@*header\OEMData[0], OemData, #OEM_TEXT_BYTESIZE/SizeOf(Unicode) - 1, #PB_Unicode)
    
    ;PokeS(@*header\sOrginalName, GetFilePart(sOrginalFileName), 260, #PB_Unicode)
    *header\qCompleteHeadSize = SizeOf(DRM_HEADER_V2)
    *header\lNumBlocks = 0
    *header\lNumMedia = 0
    If NewEncAlgorithm
      *header\lEncryptionAlgorithm = #DRMV2_ALGORITHM_RNDDATA 
      *header\lPasswordCheckSum =  __CRC32Of2xMD5Password(password)
    Else
      *header\lEncryptionAlgorithm = #DRMV2_ALGORITHM_PBINTERNAL  
      *header\lPasswordCheckSum = crc32
    EndIf  
    
    *header\lHeaderCheckSum = CRC32Fingerprint(*header, SizeOf(DRM_HEADER_V2) - SizeOf(Long))    
    
    *strm = MEMORYSTREAM_CreateFromPointer(*header, SizeOf(DRM_HEADER_V2))
    FreeMemory(*header)
  Else
    __DRMError("init of DRMV2 header failed")
  EndIf
  ProcedureReturn *strm
EndProcedure

Procedure _DRMV2Creation_Init(password.s, sOemText.s = "")
  Protected *strm
   *strm = __DRMV2Creation_Init(password.s, #True, 0, sOemText)
  ProcedureReturn *strm
EndProcedure

Procedure _DRMV2Creation_Free(*strm)
  MEMORYSTREAM_Free(*strm)  
EndProcedure

Procedure _DRMV2Creation_CopyToMemory(*strm)
  Protected *mem = #Null, *ptr = #Null, size.i = 0
  If *strm
    size = MEMORYSTREAM_GetBufferSize(*strm)
    If size > 0
      *ptr = MEMORYSTREAM_LockBuffer(*strm)
      If *ptr
        *mem = AllocateMemory(size)
        If *mem
          CopyMemory(*ptr, *mem, size)
        EndIf
        MEMORYSTREAM_UnLockBuffer(*strm)
      EndIf  
    EndIf 
  EndIf
  ProcedureReturn *mem
EndProcedure  

Procedure _DRMV2Creation_AttachBlock(*strm, lMediaID.l, lID.l, *buffer, size.i, bEncrypt = #False, *cryptBuffer = #Null)
  Protected iResult = #DRM_ERROR_FAIL, block.DRM_HEADER_BLOCK, *header.DRM_HEADER_V2, *tmpBuffer = #Null
  If *buffer And size > 0 And *strm
    block.DRM_HEADER_BLOCK
    block\lMagic = 1161972803 ; 'EBLC'
    block\lID = lID
    block\lMediaID = lMediaID
    block\qSize = size
    block\lEncryption = bEncrypt
    
    If bEncrypt
      *tmpBuffer = AllocateMemory(size)
      If *tmpBuffer
        CopyMemory(*buffer, *tmpBuffer, size)
        CryptBuffer(*tmpBuffer, 0, *cryptBuffer, size)
        *buffer = *tmpBuffer
      EndIf
    EndIf      
    
    block\lDataCheckSum = CRC32Fingerprint(*buffer, size) 
    block\lHeadCheckSum = CRC32Fingerprint(@block, SizeOf(DRM_HEADER_BLOCK) - SizeOf(Long))
      
    If MEMORYSTREAM_Write(*strm, @block, SizeOf(DRM_HEADER_BLOCK))
       
      If MEMORYSTREAM_Write(*strm, *buffer, size)
        *header.DRM_HEADER_V2 = MEMORYSTREAM_LockBuffer(*strm)
        If *header
          *header\lNumBlocks + 1
          *header\qCompleteHeadSize + size + SizeOf(DRM_HEADER_BLOCK)
          *header\lHeaderCheckSum =  CRC32Fingerprint(*header, SizeOf(DRM_HEADER_V2) - SizeOf(Long))
          MEMORYSTREAM_UnLockBuffer(*strm)
          iResult = #DRM_OK
        Else
          iResult = #DRM_ERROR_OUTOFMEMORY
        EndIf
        
      Else
        iResult = #DRM_ERROR_OUTOFMEMORY 
      EndIf
      
    Else
      iResult = #DRM_ERROR_OUTOFMEMORY       
    EndIf    
        
  Else
    iResult = #DRM_ERROR_INVALIDPARAM
  EndIf
  
  If iResult <> #DRM_OK    
    __DRMError("DRMV2Creation_AttachBlock fails with error " + __DRMErrorString(iResult))
  EndIf  
  
  If *tmpBuffer
    FreeMemory(*tmpBuffer)
  EndIf  
  
  ProcedureReturn iResult
EndProcedure

Procedure _DRMV2Creation_AttachString(*strm,  lMediaID.l, lID.l, text.s, maxLength.i, bEncrypt = #False, *cryptBuffer = #Null)
  Protected byteLength, *temp, iResult = #DRM_ERROR_FAIL
  If Len(text)> maxLength:text = Left(text, maxLength):EndIf
  byteLength = SizeOf(Unicode) * (maxLength + 1)
  
  *temp = AllocateMemory(byteLength)
  If *temp
    PokeS(*temp, text, maxLength, #PB_Unicode)
    iResult = _DRMV2Creation_AttachBlock(*strm, lMediaID, lID, *temp, byteLength, bEncrypt, *cryptBuffer)
    FreeMemory(*temp)
  Else 
    iResult = #DRM_ERROR_OUTOFMEMORY
    __DRMError("DRMV2Creation_AttachString fails with " + __DRMErrorString(iResult) )
  EndIf  
  
  ProcedureReturn iResult
EndProcedure  

Procedure _DRMV2Creation_AttachEncryptionBuffer(*strm, *seed)
  Protected iResult = #DRM_ERROR_FAIL 
  
  If *strm
    ;*seed = RAND_GenerateSeed()
    If *seed
      iResult = _DRMV2Creation_AttachBlock(*strm, 0, #DRMV2_HEADER_MEDIA_ENCRYPTIONBUFFER, *seed, #RANDOM_DATA_SIZE, #False, #Null) ; Do not use any encryption here!
      ;FreeMemory(*seed)
    Else
      iResult = #DRM_ERROR_OUTOFMEMORY
    EndIf
  Else
    iResult = #DRM_ERROR_INVALIDPARAM   
  EndIf
  
  If iResult <> #DRM_OK
    __DRMError("DRMV2Creation_AttachEncryptionBuffer fails with error " + __DRMErrorString(iResult))
  EndIf  
  ProcedureReturn iResult
EndProcedure  

Procedure _DRMV2Creation_AttachStandardData(*strm, *stdData.DRM_STANDARD_DATA, setIDAndDate.i = #True, bEncrypt = #False, *cryptBuffer = #Null)
  Protected iResult = #DRM_ERROR_FAIL 
  
  If *strm
    If *stdData
      
      If setIDAndDate
        RandomSeed(GetTickCount_() & $FFFFFF)
        *stdData\qUniqueID = (Random($FFFF) << 48 + Random($FFFF) << 32 + Random($FFFF) << 16 + Random($FFFF)) ! Date()
        *stdData\lCreationDate = Date()
      EndIf
      
      iResult = _DRMV2Creation_AttachBlock(*strm, 0, #DRMV2_HEADER_MEDIA_STANDARDDATA, *stdData, SizeOf(DRM_STANDARD_DATA), bEncrypt, *cryptBuffer)
    Else
      iResult = #DRM_ERROR_INVALIDPARAM
    EndIf 
  Else
    iResult = #DRM_ERROR_INVALIDPARAM    
  EndIf

  If iResult <> #DRM_OK
    __DRMError("DRMV2Creation_AttachStandardData fails with error " + __DRMErrorString(iResult))
  EndIf   
  ProcedureReturn iResult
EndProcedure  


Procedure _DRMV2Creation_AttachCoverImage(*strm, image, bEncrypt = #False, *cryptBuffer = #Null)
  Protected iResult = #DRM_ERROR_FAIL, *mem
  If *strm And IsImage(image)
      *mem = __SaveJPEGInMem(image, 9)
      If *mem
        iResult = _DRMV2Creation_AttachBlock(*strm, 0, #DRMV2_HEADER_MEDIA_COVER, *mem, MemorySize(*mem), bEncrypt, *cryptBuffer)
        FreeMemory(*mem)
      EndIf    
  Else
    iResult = #DRM_ERROR_INVALIDPARAM    
  EndIf

  If iResult <> #DRM_OK
    __DRMError("DRMV2Creation_AttachCoverImage fails with error " + __DRMErrorString(iResult))
  EndIf   
  ProcedureReturn iResult
EndProcedure  

Procedure _DRMV2Creation_WriteAll(*strm, file)
  Protected iResult = 0 ; Number of Bytes...
  If *strm And IsFile(file)
    FlushFileBuffers(file)
    FileSeek(file, 0)
    iResult = MEMORYSTREAM_CopyToFile(*strm, FileID(file))
  EndIf
  ProcedureReturn iResult
EndProcedure  

Procedure _DRMV2_ConvertHeaderToV2(*header.DRM_HEADER)
  Protected crc32, std.DRM_STANDARD_DATA, sec.DRM_SECURITY_DATA, *newHeader.DRM_HEADER_V2, *strm, image,*imagePtr, iResult
  
  If *header
    crc32 = *header\lHeaderCheckSum ! CRC32Fingerprint(*header, SizeOf(DRM_HEADER) - SizeOf(Long)) 
    *strm = __DRMV2Creation_Init("", #False, crc32, "")
    
    If *strm
      sec\bCanRemoveDRM = *header\bCanRemoveDRM
      sec\lSnapshotProtection = *header\lSnapshotProtection      
      std\fAspect = *header\fAspect     
      std\lCreationDate = *header\lCreationDate
      std\qLength = *header\qLength
      std\qUniqueID = *header\qUniqueID
      If _DRMV2Creation_AttachStandardData(*strm, @std, #False, #False, #Null) = #DRM_OK
        If _DRMV2Creation_AttachBlock(*strm, 0, #DRMV2_HEADER_MEDIA_SECURITYDATA, @sec, SizeOf(DRM_SECURITY_DATA), #False, #Null) = #DRM_OK ; Hier nicht verschlüsseln
          _DRMV2Creation_AttachString(*strm, 0, #DRMV2_HEADER_MEDIA_TITLE, GetDRMHeaderTitle(*header),#DRMV2_BLOCK_STRINGSIZE)    
          _DRMV2Creation_AttachString(*strm, 0, #DRMV2_HEADER_MEDIA_ALBUM, GetDRMHeaderAlbum(*header),#DRMV2_BLOCK_STRINGSIZE)
          _DRMV2Creation_AttachString(*strm, 0, #DRMV2_HEADER_MEDIA_ORGINALNAME, GetDRMOrgFileName(*header),#DRMV2_BLOCK_STRINGSIZE)
          _DRMV2Creation_AttachString(*strm, 0, #DRMV2_HEADER_MEDIA_PASSWORDTIP, GetDRMPasswordTip(*header),#DRMV2_BLOCK_STRINGSIZE)
          _DRMV2Creation_AttachString(*strm, 0, #DRMV2_HEADER_MEDIA_INTERPRETER, GetDRMHeaderInterpreter(*header),#DRMV2_BLOCK_STRINGSIZE)
          _DRMV2Creation_AttachString(*strm, 0, #DRMV2_HEADER_MEDIA_COMMENT, GetDRMHeaderComments(*header),#DRMV2_BLOCK_COMMENTSIZE)
          
          image = GetDRMHeaderCover(*header)
          If image
            *imagePtr = __SaveJPEGInMem(image,7)
            If *imagePtr
              _DRMV2Creation_AttachBlock(*strm, 0, #DRMV2_HEADER_MEDIA_COVER, *imagePtr, MemorySize(*imagePtr))
              FreeMemory(*imagePtr)
            EndIf
            FreeImage(image)
          EndIf
         
          *newHeader = _DRMV2Creation_CopyToMemory(*strm)  
        Else
          iResult = #DRM_ERROR_FAIL        
        EndIf
      Else
        iResult = #DRM_ERROR_FAIL
      EndIf
      _DRMV2Creation_Free(*strm)
      
    Else
      iResult = #DRM_ERROR_FAIL
    EndIf
    
  Else
    iResult = #DRM_ERROR_INVALIDPARAM
  EndIf
  
  If iResult <> #DRM_OK
    __DRMError("error " + __DRMErrorString(iResult) + " in DRMV2_ConvertHeaderToV2")       
  EndIf  
  
  ProcedureReturn *newHeader
EndProcedure 


; Procedure _DRMV2_UpdateBlock(*buffer, lMediaID.l, lID.l, *databuffer, size)
;   Protected bResult = #False, *block.DRM_HEADER_BLOCK = #Null, offset = 0 
;   If *buffer
;     offset = __DRMV2_FindBlockOffset(*buffer, lMediaID.l, lID.l)
;     If offset <> -1
;       *block.DRM_HEADER_BLOCK = *buffer + offset
;       CopyMemory(*databuffer, *block + SizeOf(DRM_HEADER_BLOCK), __Min(*block\qSize, size))
;       bResult = #True
;     EndIf
;   EndIf
;   ProcedureReturn bResult
; EndProcedure  


Procedure _DRMV2_GetHeaderSize(*header.DRM_HEADER_V2)
  If *header
    ProcedureReturn *header\qCompleteHeadSize
  EndIf
  ProcedureReturn 0
EndProcedure  

Procedure _DRMV2_GetOrginalHeaderSize(*header.DRM_HEADER_V2) ; Header Size in the file
  If *header
    If *header\lEncryptionAlgorithm = #DRMV2_ALGORITHM_PBINTERNAL
      ProcedureReturn SizeOf(DRM_HEADER)
    Else
      ProcedureReturn *header\qCompleteHeadSize      
    EndIf  
  EndIf
  ProcedureReturn 0
EndProcedure  


Procedure _DRMV2_GetBlockSize(*buffer, lMediaID.l, lID.l)
  Protected iSize.i = 0, *block.DRM_HEADER_BLOCK = #Null, offset = 0  
  If *buffer
    offset = __DRMV2_FindBlockOffset(*buffer, lMediaID.l, lID.l)
    If offset <> -1
      *block.DRM_HEADER_BLOCK = *buffer + offset
      iSize = *block\qSize
    EndIf
  EndIf
  ProcedureReturn iSize
EndProcedure  

; Procedure _DRMV2_CopyBlock(*buffer, lMediaID.l, lID.l, *dstBuffer)
;   Protected bResult = #False, *block.DRM_HEADER_BLOCK = #Null, offset = 0   
;   If *buffer
;     offset = __DRMV2_FindBlockOffset(*buffer, lMediaID.l, lID.l)
;     If offset <> -1
;       *block.DRM_HEADER_BLOCK = *buffer + offset
;       CopyMemory(*block + SizeOf(DRM_HEADER_BLOCK), *dstBuffer, *block\qSize)
;       bResult = #True   
;     EndIf
;   EndIf
;   ProcedureReturn bResult
; EndProcedure  

Procedure _DRMV2_GetBlockPointer(*buffer, lMediaID.l, lID.l)
  Protected *block.DRM_HEADER_BLOCK = #Null, offset = 0  
  If *buffer
    offset = __DRMV2_FindBlockOffset(*buffer, lMediaID.l, lID.l)
    If offset <> -1
      *block.DRM_HEADER_BLOCK = *buffer + offset
    EndIf
  EndIf
  ProcedureReturn *block
EndProcedure


Procedure _DRMV2_GetBlockDataPointer(*buffer, lMediaID.l, lID.l)
  Protected *block.DRM_HEADER_BLOCK = #Null, offset = 0  
  If *buffer
    offset = __DRMV2_FindBlockOffset(*buffer, lMediaID.l, lID.l)
    If offset <> -1
      *block.DRM_HEADER_BLOCK = *buffer + offset + SizeOf(DRM_HEADER_BLOCK)
    EndIf
  EndIf
  ProcedureReturn *block
EndProcedure  
; 
; Procedure.s _DRMV2_GetBlockString(*buffer, lMediaID.l, lID.l)
;   Protected *block.DRM_HEADER_BLOCK = #Null, offset = 0, result.s = ""
;   If *buffer
;     offset = __DRMV2_FindBlockOffset(*buffer, lMediaID.l, lID.l)
;     If offset <> -1
;       *block.DRM_HEADER_BLOCK = *buffer + offset
;       result.s = PeekS(*block + SizeOf(DRM_HEADER_BLOCK), *block\qSize, #PB_Unicode)
;     EndIf
;   EndIf
;   ProcedureReturn result.s
; EndProcedure  

Procedure _DRMV2_GetCoverImage(*buffer)
  Protected *imagePtr = #Null, image = #Null
  *imagePtr = _DRMV2_GetBlockDataPointer(*buffer, 0, #DRMV2_HEADER_MEDIA_COVER)
  If *imagePtr
    image = CatchImage(#PB_Any, *imagePtr)
  EndIf  
  ProcedureReturn image
EndProcedure  

Procedure __DRMV2_CreateHeaderCryptionBuffer(password.s, *seed)
  ProcedureReturn GenerateCryptionBufferV2(Hex(__CRC32Of3xMD5Password(password)), #True, *seed) 
EndProcedure  

Procedure _DRMV2_AllocateCryptionBuffer(*header.DRM_HEADER_V2, password.s, bUseCRC32Of2xMD5.i = #False)
  Protected *RndData = #Null, offset = 0, *crypt
  If *header
    If *header\lEncryptionAlgorithm = #DRMV2_ALGORITHM_PBINTERNAL
      *crypt = GenerateCryptionBufferV2(password.s, #False, #Null)       
    Else      
      
      offset = __DRMV2_FindBlockOffset(*header, 0, #DRMV2_HEADER_MEDIA_ENCRYPTIONBUFFER)
      If offset <> -1
        *RndData = *header + offset + SizeOf(DRM_HEADER_BLOCK)   
        If bUseCRC32Of2xMD5
          *crypt = __DRMV2_CreateHeaderCryptionBuffer(password, *RndData)                  
        Else
          *crypt = GenerateCryptionBufferV2(password.s, #True, *RndData)         
        EndIf  
      EndIf   
    EndIf
  EndIf
  ProcedureReturn *crypt
EndProcedure  

Procedure _DRMV2_AnalyzeGenericHeader(*memory.DRM_HEADER_GENERIC, *headerSize)
  Protected iResult = #DRM_ERROR_FAIL
  iResult =  __DRMV2_AnalyzeGenericHeader(*memory, *headerSize)
  If iResult <> #DRM_OK    
    __DRMError("DRMV2_AnalyzeGenericHeader fails with error " + __DRMErrorString(iResult))
  EndIf  
  ProcedureReturn iResult
EndProcedure  


;ACHTUNG! *memory muss pointer zum ganzen Header sein!
Procedure _DRMV2_ReadHeader(*memory.DRM_HEADER_GENERIC, password.s, *result.integer = #Null)
  Protected iResult.i
  Protected headerSize.i
  Protected *header, genHeader.DRM_HEADER_GENERIC
     
  iResult = __DRMV2_AnalyzeGenericHeader(*memory, @headerSize)  
  If iResult = #DRM_OK
    
    If *memory\lVersion = 100
      iResult = __DRMV2_AnalyzeHeaderV1(*memory, password)  
      
      *header = _DRMV2_ConvertHeaderToV2(*memory)

    ElseIf *memory\lVersion = 200
      iResult = __DRMV2_AnalyzeHeaderV2(*memory, password)                    
      
      *header = AllocateMemory(headerSize)
      If *header
        CopyMemory(*memory, *header, headerSize) 
        ;iResult = #DRM_OK
      Else
        iResult = #DRM_ERROR_OUTOFMEMORY
      EndIf  
    
    Else
      iResult = #DRM_ERROR_FAIL
    EndIf  
  
  Else
    ; __DRMV2_AnalyzeGenericHeader failed...
  EndIf  
     
  If iResult <> #DRM_OK
    __DRMDebug("WARN: ReadDRMHeader V2 failed with error " + __DRMErrorString(iResult))  
  EndIf
  
  If *result
    *result\i = iResult
  EndIf  
ProcedureReturn *header
EndProcedure


;Returns a memory pointer (no stream). The errorcode can be received with  *result
Procedure _DRMV2_ReadHeaderFromFile(fileName.s, password.s, qOffset.q = 0, *result.integer = #Null)
  Protected iResult.i = #DRM_ERROR_FAIL  
  Protected headerSize.i = 0
  Protected *header = #Null
  Protected genHeader.DRM_HEADER_GENERIC, file, *memory
  
  file = ReadFile(#PB_Any, fileName, #PB_File_SharedRead)
  If file
    FileSeek(file, qOffset)
    If ReadData(file, @genHeader, SizeOf(DRM_HEADER_GENERIC)) = SizeOf(DRM_HEADER_GENERIC)
      iResult = __DRMV2_AnalyzeGenericHeader(@genHeader, @headerSize)    
      
      If iResult = #DRM_OK
        *memory = AllocateMemory(headerSize)
        If *memory
          FileSeek(file, qOffset)   
          If ReadData(file, *memory, headerSize) = headerSize;SizeOf(DRM_HEADER_GENERIC)           
            *header =  _DRMV2_ReadHeader(*memory, password.s, @iResult)
          Else
            __DRMError(Chr(34) + fileName + Chr(34) + " cannot be read!")
            iResult = #DRM_ERROR_FAIL              
          EndIf  
          FreeMemory(*memory)
        Else
          iResult = #DRM_ERROR_OUTOFMEMORY
          __DRMError("out of memory while reading " + Chr(34) + fileName + Chr(34) + "!")          
        EndIf
      Else
        __DRMError(Chr(34) + fileName + Chr(34) + " cannot be analyzed (" + __DRMErrorString(iResult)+")")        
      EndIf 
      
    Else
      __DRMError(Chr(34) + fileName + Chr(34) + " cannot be read!")
      iResult = #DRM_ERROR_FAIL      
    EndIf
    
    CloseFile(file)
  Else
    __DRMError(Chr(34) + fileName + Chr(34) + " cannot be opened!")
    iResult = #DRM_ERROR_FAIL
  EndIf
  
  If *result
    *result\i = iResult
  EndIf  
ProcedureReturn *header
EndProcedure

Procedure _DecryptDRMV2FileToMemory(sFile.s, sPassword.s)
  Protected *header.DRM_HEADER_V2, iResult.i, iFile.i, iSize.i, *cryptBuffer, *memory, iDRMResult  
  iResult = #E_FAIL  
  *header = _DRMV2_ReadHeaderFromFile(sFile, sPassword, 0, @iDRMResult)
  
  If iDRMResult = #DRM_OK And *header
    iFile.i = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
    If iFile  
      iSize = Lof(iFile) - _DRMV2_GetOrginalHeaderSize(*header)
      
      *cryptBuffer = _DRMV2_AllocateCryptionBuffer(*header, sPassword)
      If *cryptBuffer
        *memory = AllocateMemory(iSize)
        If *memory
          FileSeek(iFile, _DRMV2_GetOrginalHeaderSize(*header))
          ReadData(iFile, *memory, iSize)
          CryptBuffer(*memory, 0, *cryptBuffer, iSize)       
          iResult = #S_OK
        Else
          __DRMError("DecryptDRMV2FileToMemory: out of memory")        
        EndIf
        FreeMemory(*cryptBuffer)
      Else
        __DRMError("DecryptDRMV2FileToMemory: generating cryption buffer failed, out of memory")
      EndIf
      CloseFile(iFile)
    Else
      __DRMError("DecryptDRMV2FileToMemory: open file '" + sFile + "' for read access failed (" + Str(GetLastError_()) + ")")       
    EndIf
  Else
    __DRMError("DecryptDRMV2FileToMemory: DRMV2_ReadHeaderFromFile failed with HRESULT "+ __DRMErrorString(iDRMResult))
  EndIf
  
  If *header
    FreeMemory(*header)
  EndIf  
  
  If iResult = #S_OK
    ProcedureReturn *memory
  Else
    ProcedureReturn #Null
  EndIf
EndProcedure

;Use only with correct header
Procedure _EncryptFileV2(sFile.s, sEncFile.s, sPassword.s, *header.DRM_HEADER_V2, cb.cryptionCB)
  Protected iResult.i, *tmp, *cryptBuffer, iReadFile.i, iCreateFile.i, size.q, rest.q, pos.q, abort
  iResult = #E_FAIL
  *tmp = AllocateMemory(#DRM_ENCRYPTION_SIZE)
  If *tmp
    *cryptBuffer = _DRMV2_AllocateCryptionBuffer(*header, sPassword)
    If *cryptBuffer
      iReadFile.i = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
      If iReadFile
        iCreateFile.i = CreateFile(#PB_Any, sEncFile)
        If iCreateFile
          WriteData(iCreateFile, *header, _DRMV2_GetHeaderSize(*header))
          
          size.q = Lof(iReadFile)
          rest.q = Lof(iReadFile)
          pos.q = 0
          Repeat 
            If rest >= #DRM_ENCRYPTION_SIZE
              ReadData(iReadFile,*tmp, #DRM_ENCRYPTION_SIZE)
              CryptBuffer(*tmp, pos,  *cryptBuffer, #DRM_ENCRYPTION_SIZE)
              WriteData(iCreateFile, *tmp, #DRM_ENCRYPTION_SIZE)
              pos + #DRM_ENCRYPTION_SIZE
              rest - #DRM_ENCRYPTION_SIZE
            Else
              ReadData(iReadFile, *tmp, rest)
              CryptBuffer(*tmp, pos,  *cryptBuffer, rest)
              WriteData(iCreateFile, *tmp, rest)    
              pos + rest
              rest = 0
            EndIf
            If cb
              abort = cb(pos, size)
            EndIf
          Until rest = 0 Or abort
          If abort
            iResult = #E_ABORT
            __DRMDebug("EncryptFileV2: user aborted encryption")
          Else
            iResult = #S_OK
          EndIf  
          CloseFile(iCreateFile)
        Else
          __DRMError("EncryptFileV2: open file '" + sEncFile + "' for write access failed (" + Str(GetLastError_()) + ")")         
        EndIf
        CloseFile(iReadFile)  ; 2010-04-11 verschoben
      Else
        __DRMError("EncryptFileV2: open file '" + sFile + "' for read access failed (" + Str(GetLastError_()) + ")") 
      EndIf
      FreeMemory(*cryptBuffer)
    Else
      __DRMError("EncryptFileV2: generating cryption buffer failed, out of memory")
    EndIf
    FreeMemory(*tmp)
  EndIf
  ProcedureReturn iResult
EndProcedure

;Use only with correct password
Procedure _DecryptFileV2(sEncFile.s, sFile.s, sPassword.s, cb.cryptionCB)
  Protected iResult.i, *tmp, *cryptBuffer, iReadFile.i, iCreateFile.i, size.q, rest.q, pos.q, abort
  Protected *header.DRM_HEADER_V2, iDRMResult, iHeaderSize.i = 0
  iResult = #E_FAIL
  *tmp = AllocateMemory(#DRM_ENCRYPTION_SIZE)
  If *tmp
    
      *header = _DRMV2_ReadHeaderFromFile(sEncFile, sPassword, 0, @iDRMResult)
      
      ;Debug "iDRMResult "+Str(iDRMResult)
      
      If *header
        iHeaderSize = _DRMV2_GetOrginalHeaderSize(*header)
        iReadFile.i = ReadFile(#PB_Any, sEncFile, #PB_File_SharedRead )
        If iReadFile
          iCreateFile.i = CreateFile(#PB_Any, sFile)
          If iCreateFile
            ;WriteData(iCreateFile, *header, SizeOf(DRM_HEADER))
            FileSeek(iReadFile, iHeaderSize)
            size.q = Lof(iReadFile) - iHeaderSize
            rest.q = size
            pos.q = 0
            
            *cryptBuffer = _DRMV2_AllocateCryptionBuffer(*header, sPassword)
            If *cryptBuffer
            
              Repeat 
                If rest >= #DRM_ENCRYPTION_SIZE
                  ReadData(iReadFile, *tmp, #DRM_ENCRYPTION_SIZE)
                  CryptBuffer(*tmp, pos,  *cryptBuffer, #DRM_ENCRYPTION_SIZE)
                  WriteData(iCreateFile, *tmp, #DRM_ENCRYPTION_SIZE)
                  pos + #DRM_ENCRYPTION_SIZE
                  rest - #DRM_ENCRYPTION_SIZE
                Else
                  ReadData(iReadFile, *tmp, rest)
                  CryptBuffer(*tmp, pos,  *cryptBuffer, rest)
                  WriteData(iCreateFile, *tmp, rest)    
                  pos + rest
                  rest = 0
                EndIf
                If cb
                  abort = cb(pos, size)
                EndIf
              Until rest = 0 Or abort
          
            FreeMemory(*cryptBuffer)
            Else
              __DRMError("DecryptFileV2: generating cryption buffer failed, out of memory")      
            EndIf          
            
          If abort
            __DRMDebug("DecryptFileV2: user aborted encryption")
            iResult = #E_ABORT
          Else
            iResult = #S_OK
          EndIf  
          CloseFile(iCreateFile)
        Else
          __DRMError("DecryptFileV2: open file '" + sFile + "' for write access failed (" + Str(GetLastError_()) + ")")                   
        EndIf
        CloseFile(iReadFile) ; 2010-04-11 verschoben
      Else
        __DRMError("DecryptFileV2: open file '" + sEncFile + "' for read access failed (" + Str(GetLastError_()) + ")")         
      EndIf
      
      FreeMemory(*header)
    Else
      __DRMError("DRMV2_ReadHeaderFromFile failed in DecryptFileV2 with error " + __DRMErrorString(iDRMResult))  
    EndIf
    
    FreeMemory(*tmp)
  EndIf
  ProcedureReturn iResult
EndProcedure


Procedure __DRMV2Read_CreateHeaderObject()  
  Protected *headerObj.DRMV2_HEADER_READ_OBJECT = AllocateMemory(SizeOf(DRMV2_HEADER_READ_OBJECT))
  If *headerObj
    *headerObj\header = #Null
    *headerObj\password = ""
    *headerObj\cryptionBuffer = #Null
  EndIf
  ProcedureReturn *headerObj
EndProcedure  

Procedure __DRMV2Write_CreateHeaderObject()
  Protected *headerObj.DRMV2_HEADER_WRITE_OBJECT = AllocateMemory(SizeOf(DRMV2_HEADER_WRITE_OBJECT))
  If *headerObj
    *headerObj\cryptionBufferHeader = #Null
    *headerObj\header = #Null
    *headerObj\password = ""
    *headerObj\stream = #Null
  EndIf
  ProcedureReturn *headerObj
EndProcedure  


;-================================================================================



Procedure DRMV2Read_ReadFromFile(sFile.s, sPassword.s, qOffset.q = 0)
  Protected bFail = #False, *headerObj.DRMV2_HEADER_READ_OBJECT = __DRMV2Read_CreateHeaderObject()
  ;Debug sFile+"--"+sPassword+"--"+Str(qOffset)
  
  If *headerObj
    *headerObj\header = _DRMV2_ReadHeaderFromFile(sFile, sPassword, qOffset, @*headerObj\readResult)
    If *headerObj\header
      *headerObj\password = sPassword
      If *headerObj\readResult = #DRM_OK And *headerObj\header
        *headerObj\cryptionBuffer = _DRMV2_AllocateCryptionBuffer(*headerObj\header, sPassword, #False)
        *headerObj\cryptionBufferHeader = _DRMV2_AllocateCryptionBuffer(*headerObj\header, sPassword, #True) 
        If *headerObj\cryptionBuffer = #Null Or *headerObj\cryptionBufferHeader = #Null
          bFail = #True
        EndIf  
      EndIf 
    Else
      bFail = #True      
    EndIf
  Else
    __DRMError("DRMV2Read_ReadFromFile out of memory")
  EndIf
  
  If bFail
    If *headerObj      
      If *headerObj\header
        FreeMemory(*headerObj\header)
      EndIf  
      If *headerObj\cryptionBuffer
        FreeMemory(*headerObj\cryptionBuffer)
      EndIf
      If *headerObj\cryptionBufferHeader
        FreeMemory(*headerObj\cryptionBufferHeader)
      EndIf        
      FreeMemory(*headerObj)
      *headerObj = #Null
    EndIf  
    __DRMError("DRMV2Read_ReadFromFile failed")    
  EndIf  

  ProcedureReturn *headerObj
EndProcedure  

Procedure DRMV2Read_Free(*headerObj.DRMV2_HEADER_READ_OBJECT)
  If *headerObj
    If *headerObj\header
      FreeMemory(*headerObj\header)
      *headerObj\header =#Null
    EndIf
    If *headerObj\cryptionBuffer
      FreeMemory(*headerObj\cryptionBuffer)
      *headerObj\cryptionBuffer =#Null
    EndIf    
    If *headerObj\cryptionBufferHeader
      FreeMemory(*headerObj\cryptionBufferHeader)
      *headerObj\cryptionBufferHeader =#Null
    EndIf 
    FreeMemory(*headerObj)
  EndIf
EndProcedure  

Procedure DRMV2Read_GetLastReadResult(*headerObj.DRMV2_HEADER_READ_OBJECT)
  If *headerObj
    If *headerObj\header
      ProcedureReturn *headerObj\readResult
    EndIf
  EndIf
  ProcedureReturn #DRM_ERROR_INVALIDPARAM
EndProcedure  


Procedure DRMV2Read_GetHeaderSize(*headerObj.DRMV2_HEADER_READ_OBJECT)
  If *headerObj
    If *headerObj\header
      ProcedureReturn *headerObj\header\qCompleteHeadSize
    EndIf
  EndIf
  ProcedureReturn 0
EndProcedure  

Procedure DRMV2Read_GetOrginalHeaderSize(*headerObj.DRMV2_HEADER_READ_OBJECT) ; Header Size in the file
  If *headerObj
    If *headerObj\header
      If *headerObj\header\lEncryptionAlgorithm = #DRMV2_ALGORITHM_PBINTERNAL
        ProcedureReturn SizeOf(DRM_HEADER)
      Else
        ProcedureReturn *headerObj\header\qCompleteHeadSize      
      EndIf  
    EndIf
  EndIf
  ProcedureReturn 0
EndProcedure  

Procedure DRMV2Read_GetBlockSize(*headerObj.DRMV2_HEADER_READ_OBJECT, lID.l)
  Protected iResult.i = 0
  If *headerObj
    iResult = _DRMV2_GetBlockSize(*headerObj\header, 0,  lID)
  EndIf
  ProcedureReturn iResult
EndProcedure  

Procedure DRMV2Read_IsBlockAvailable(*headerObj.DRMV2_HEADER_READ_OBJECT, lID.l)
  Protected iResult.i = 0
  If *headerObj
    iResult = _DRMV2_GetBlockDataPointer(*headerObj\header, 0, lID.l)
  EndIf
  ProcedureReturn iResult
EndProcedure  

Procedure DRMV2Read_GetBlockData(*headerObj.DRMV2_HEADER_READ_OBJECT, lID.l, *destPointer, size = -1)
  Protected bResult.i = #False, *srcPointer,*block.DRM_HEADER_BLOCK
  If *headerObj
    If *headerObj\header
      *block.DRM_HEADER_BLOCK = _DRMV2_GetBlockPointer(*headerObj\header, 0, lID.l)
      If *block
        
        If size = -1
          size = *block\qSize
        Else
          size = __Min(*block\qSize, size)
        EndIf
        
        CopyMemory(*block + SizeOf(DRM_HEADER_BLOCK), *destPointer, size)  
        
        If *block\lEncryption = 1
          If *headerObj\cryptionBufferHeader
            CryptBuffer(*destPointer, 0, *headerObj\cryptionBufferHeader, size)
            bResult = #True 
          EndIf  
        Else
          bResult = #True          
        EndIf 
        
      EndIf   
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure  

Procedure.s DRMV2Read_GetBlockString(*headerObj.DRMV2_HEADER_READ_OBJECT, lID.l)
  Protected *block.DRM_HEADER_BLOCK = #Null, size = 0, result.s = "", bOk = #False, *tmpBuffer = #Null
  If *headerObj
    *block.DRM_HEADER_BLOCK = _DRMV2_GetBlockPointer(*headerObj\header, 0, lID)
    If *block 
      size = *block\qSize
      *tmpBuffer = AllocateMemory(size)
      If *tmpBuffer
        
        CopyMemory(*block + SizeOf(DRM_HEADER_BLOCK), *tmpBuffer, size)  
        
        If *block\lEncryption = 1
          If *headerObj\cryptionBufferHeader
            CryptBuffer(*tmpBuffer, 0, *headerObj\cryptionBufferHeader, size)
            bOk = #True 
          EndIf  
        Else
          bOk = #True          
        EndIf         
        
        If bOk
          result.s = PeekS(*tmpBuffer, size/SizeOf(UNICODE) - 1, #PB_Unicode)
        EndIf 
        FreeMemory(*tmpBuffer)
      EndIf  
    EndIf
  EndIf
  ProcedureReturn result.s
EndProcedure  

Procedure DRMV2Read_GetCoverImage(*headerObj.DRMV2_HEADER_READ_OBJECT)
  Protected image = #Null
  If *headerObj
    image = _DRMV2_GetCoverImage(*headerObj\header)
  EndIf
  ProcedureReturn image
EndProcedure

Procedure DRMV2Read_CheckPassword(*headerObj.DRMV2_HEADER_READ_OBJECT, password.s)
  Protected iResult = #DRM_ERROR_FAIL
  If *headerObj
    If *headerObj\header
      ;Testing required: should work for both headers
      If *headerObj\header\lPasswordCheckSum =  __CRC32Of2xMD5Password(password)
        iResult = #DRM_OK
      Else
        iResult = #DRM_ERROR_INVALIDPASSWORD
      EndIf
;       If *headerObj\header\lEncryptionAlgorithm = #DRMV2_ALGORITHM_PBINTERNAL
;         ProcedureReturn *headerObj\header\lPasswordCheckSum
;       Else
;         ProcedureReturn *headerObj\header\lPasswordCheckSum    __CRC32Of2xMD5Password(password)
;       EndIf  
    EndIf
  EndIf
  ProcedureReturn iResult
EndProcedure 

Procedure DRMV2Read_CreateCryptionBufferCopy(*headerObj.DRMV2_HEADER_READ_OBJECT)
  Protected *result = #Null, size
  If *headerObj
    If *headerObj\cryptionBuffer
      size = MemorySize(*headerObj\cryptionBuffer)
      *result = AllocateMemory(size)
      If *result
        CopyMemory(*headerObj\cryptionBuffer, *result, size)
      EndIf  
    EndIf
  EndIf
  ProcedureReturn *result
EndProcedure 
;-================================================================================


Procedure DecryptDRMV2FileToMemory(sFile.s, sPassword.s)
  ProcedureReturn _DecryptDRMV2FileToMemory(sFile.s, sPassword.s)
EndProcedure

Procedure EncryptFileV2(sFile.s, sEncFile.s, sPassword.s, *headerObj.DRMV2_HEADER_WRITE_OBJECT, cb.cryptionCB)
  Protected iResult.i = #E_FAIL, *header.DRM_HEADER_V2 = #Null
  If *headerObj
    *header = _DRMV2Creation_CopyToMemory(*headerObj\stream)
    If *header
      iResult = _EncryptFileV2(sFile, sEncFile, sPassword, *header, cb)
      FreeMemory(*header)  
    EndIf 
  EndIf
  ProcedureReturn iResult
EndProcedure

Procedure DecryptFileV2(sEncFile.s, sFile.s, sPassword.s, cb.cryptionCB) ;Use only with correct password
  ProcedureReturn _DecryptFileV2(sEncFile, sFile, sPassword, cb)
EndProcedure 


;-================================================================================


Procedure DRMV2Write_Create(password.s, sOemText.s = "")
  Protected iResult = #DRM_ERROR_FAIL, *seed = #Null, *headerObj.DRMV2_HEADER_WRITE_OBJECT
  *headerObj.DRMV2_HEADER_WRITE_OBJECT = __DRMV2Write_CreateHeaderObject()
  If *headerObj
    *headerObj\stream = _DRMV2Creation_Init(password, sOemText.s)
    *headerObj\password = password
    If *headerObj\stream
      
      *seed = RAND_GenerateSeed()
      If *seed
        iResult = _DRMV2Creation_AttachEncryptionBuffer(*headerObj\stream, *seed)
        If iResult = #DRM_OK
          *headerObj\cryptionBufferHeader = __DRMV2_CreateHeaderCryptionBuffer(password, *seed)
          If *headerObj\cryptionBufferHeader 
            iResult = #DRM_OK 
          Else
            iResult = #DRM_ERROR_OUTOFMEMORY
          EndIf
        EndIf
        FreeMemory(*seed)  
        *seed = #Null
      EndIf
    Else
      iResult = #DRM_ERROR_OUTOFMEMORY      
    EndIf  
  Else
    iResult = #DRM_ERROR_OUTOFMEMORY
  EndIf  
  
  If iResult = #DRM_OK
    ProcedureReturn *headerObj
  Else
    
    If *headerObj
      If *headerObj\stream
        _DRMV2Creation_Free(*headerObj\stream)
        *headerObj\stream = #Null  
      EndIf
      If *headerObj\cryptionBufferHeader
        FreeMemory(*headerObj\cryptionBufferHeader)
        *headerObj\cryptionBufferHeader = #Null
      EndIf 
      *headerObj\password = ""
      FreeMemory(*headerObj)  
    EndIf  
    
    __DRMError("DRMV2Write_Create failed with error " + __DRMErrorString(iResult))
    ProcedureReturn #Null
  EndIf  
EndProcedure  

Procedure DRMV2Write_Free(*headerObj.DRMV2_HEADER_WRITE_OBJECT)
  If *headerObj
    If *headerObj\stream
      _DRMV2Creation_Free(*headerObj\stream)
      *headerObj\stream = #Null
    EndIf  
    If *headerObj\cryptionBufferHeader
      FreeMemory(*headerObj\cryptionBufferHeader)
      *headerObj\cryptionBufferHeader = #Null
    EndIf
    If *headerObj\header
      FreeMemory(*headerObj\header)  
      *headerObj\header = #Null
    EndIf
    *headerObj\stream = #Null
    *headerObj\password = ""
    FreeMemory(*headerObj) 
  EndIf
EndProcedure  

Procedure DRMV2Write_AttachBlock(*headerObj.DRMV2_HEADER_WRITE_OBJECT, lID.l, *buffer, size.i, bEncrypt = #False)
  Protected iResult = #DRM_ERROR_INVALIDPARAM    
  If *headerObj
    If *headerObj\stream  
      iResult = _DRMV2Creation_AttachBlock(*headerObj\stream, 0, lID, *buffer, size, bEncrypt, *headerObj\cryptionBufferHeader)
    Else
      __DRMError("DRMV2Write_AttachBlock stream is null!")
    EndIf
  Else
    __DRMError("DRMV2Write_AttachBlock headerObj is null!")    
  EndIf
  ProcedureReturn iResult    
EndProcedure

Procedure DRMV2Write_AttachString(*headerObj.DRMV2_HEADER_WRITE_OBJECT, lID.l, text.s, maxLength.i, bEncrypt = #False)
  Protected iResult = #DRM_ERROR_INVALIDPARAM  
  If *headerObj
    If *headerObj\stream  
      iResult = _DRMV2Creation_AttachString(*headerObj\stream,  0, lID.l, text, maxLength, bEncrypt, *headerObj\cryptionBufferHeader)
    Else
      __DRMError("_DRMV2Creation_AttachString stream is null!")
    EndIf
  Else
    __DRMError("_DRMV2Creation_AttachString headerObj is null!")    
  EndIf
  ProcedureReturn iResult    
EndProcedure

Procedure DRMV2Write_AttachStandardData(*headerObj.DRMV2_HEADER_WRITE_OBJECT, *stdData.DRM_STANDARD_DATA, setIDAndDate.i = #True)
  Protected iResult = #DRM_ERROR_INVALIDPARAM  
  If *headerObj
    If *headerObj\stream  
      iResult = _DRMV2Creation_AttachStandardData(*headerObj\stream, *stdData, setIDAndDate.i, #False, #Null); Standard data cannot be encrypted (length needed!) #True, *headerObj\cryptionBufferHeader)
    Else
      __DRMError("DRMV2Write_AttachStandardData stream is null!")
    EndIf
  Else
    __DRMError("DRMV2Write_AttachStandardData headerObj is null!")    
  EndIf
  ProcedureReturn iResult  
EndProcedure

Procedure DRMV2Write_AttachCoverImage(*headerObj.DRMV2_HEADER_WRITE_OBJECT, image)
  Protected iResult = #DRM_ERROR_INVALIDPARAM
  If *headerObj
    If *headerObj\stream
      iResult = _DRMV2Creation_AttachCoverImage(*headerObj\stream, image, #False, #Null) ; At the moment encrypted images are not supported...
    Else
      __DRMError("DRMV2Write_AttachCoverImage stream is null!")
    EndIf
  Else
    __DRMError("DRMV2Write_AttachCoverImage headerObj is null!")    
  EndIf
  ProcedureReturn iResult
EndProcedure

Procedure DRMV2Write_CreateMemoryCopy(*headerObj.DRMV2_HEADER_WRITE_OBJECT)
  Protected *mem = #Null
  If *headerObj
    If *headerObj\stream
      *mem = _DRMV2Creation_CopyToMemory(*headerObj\stream)
    Else
      __DRMError("DRMV2Write_CopyToMemory stream is null!")
    EndIf
  Else
    __DRMError("DRMV2Write_CopyToMemory headerObj is null!")    
  EndIf
  ProcedureReturn *mem
EndProcedure

Procedure DRMV2Write_WriteAllToFile(*headerObj.DRMV2_HEADER_WRITE_OBJECT, file)
  Protected iResult = #DRM_ERROR_INVALIDPARAM
  If *headerObj
    If *headerObj\stream
      iResult = _DRMV2Creation_WriteAll(*headerObj\stream, file)
    Else
      __DRMError("DRMV2Write_WriteAllToFile stream is null!")
    EndIf
  Else
    __DRMError("DRMV2Write_WriteAllToFile headerObj is null!")    
  EndIf
  ProcedureReturn iResult
EndProcedure





;{ Sample

;
; ; 
;   DisableExplicit
;  *obj = DRMV2Write_Create("mypass")
;  DRMV2Write_AttachString(*obj, 20, "TEST1", 2000, #True)
;  CreateFile(1,"D:\test\out.dat")
;  DRMV2Write_WriteAllToFile(*obj,1)
;  DRMV2Write_Free(*obj)
;  CloseFile(1)
; 
; ; 
; *obj = DRMV2Read_ReadFromFile("D:\test\out.dat", "mypass",0)
; 
;  DRMV2Read_GetLastReadResult(*obj)
;  DRMV2Read_GetBlockString(*obj, 20)
;  DRMV2Read_Free(*obj)
; 
; Define header.DRM_HEADER
; 
;   InitDRMHeader(@header, "test.avi")
;   SetDRMHeaderTitle(@header, "sTitle")
;   SetDRMHeaderAlbum(@header, "sAlbum")
;   SetDRMHeaderInterpreter(@header, "sInterpreter")
;   SetDRMHeaderMediaLength(@header, 34727)
;   FinalizeDRMHeader(@header, "abc")

; ; 
; Procedure CB(p.q,s.q)
;  Debug StrD(p*100/s)
; EndProcedure
; EncryptFile("Wildlife.wmv", "test1.drm", "abc", @header, @CB())
;  
; DecryptFile("test1.drm", "Wildlife2.wmv", "abc", @CB())
;  

;}
;{ Example
; Define header.DRM_HEADER
; UsePNGImageDecoder()
; UseJPEGImageDecoder()
; LoadImage(1,"test2.bmp")
; Debug IsImage(1)
; SetDRMHeaderCover(@header, 1)
; 
; SaveImage(GetDRMHeaderCover(@header.DRM_HEADER), "D:\test.bmp")
; CreateFile(1,"D:\o.txt")
; WriteData(1,header,SizeOf(DRM_HEADER))
; CloseFile(1)
;}

; 
;  DisableExplicit
; 
; UseJPEGImageDecoder()
; UseJPEGImageEncoder()
; 
; test.DRM_HEADER
; 
; InitDRMHeader(@test, "orgname.avi")
; SetDRMHeaderAlbum(test, "Album")
; SetDRMHeaderAspect(test, 16.0 / 9.0)
; SetDRMHeaderCanRemoveDRM(test, #True)
; SetDRMHeaderComment(test, "comment")
; 
; CreateImage(1,512,512,32)
; SetDRMHeaderCover(test, 1)
; SetDRMHeaderInterpreter(test, "interpreter")
; SetDRMHeaderMediaLength(test, 500001)
; SetDRMHeaderSnapshotProtection(test, 2)
; SetDRMHeaderTitle(test, "my title")
; SetDRMHeaderPasswordTip(test, "tipp")
; FinalizeDRMHeader(@test, "psw")
; 
; 
; CreateFile(1,"D:\test.head")
; WriteData(1,@test,SizeOf(DRM_HEADER))
; CloseFile(1)
; 
; ;*new = DRMV2_ConvertHeaderToV2(@test)
; 
; Debug "----"
; *head = DRMV2_ReadHeaderFromFile("D:\test.head", "psw",0, @ret)
; Debug ret
; 
; ;Debug DRMV2_GetBlockString(*new, 0, #DRMV2_HEADER_MEDIA_ALBUM)
; ;Debug DRMV2_GetCoverImage(*new)
; 
; ;EncryptFileV2("D:\test-video.mp4", "D:\test-video.gpf", "psw", *head, #Null)
; 
; ;DecryptFileV2("D:\test-video.gpf", "D:\test-video.mp4", "psw", #Null)
; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 1444
; FirstLine = 1381
; Folding = fw4Dw----------0
; EnableXP
; DisableDebugger
; EnableCompileCount = 164
; EnableBuildCount = 0
; EnableExeConstant