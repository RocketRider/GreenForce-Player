;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

#EXE_ATTACHMENT_BLOCK_MAGIC = 1480868418  ;'XDBB'

Structure EXE_ATTACHMENT_FILEENTRY
  ;magic.l
  filename.s{#MAX_PATH}
  absoluteOffset.q
  size.q
  compressedSize.l
  isCompressed.l
EndStructure

Structure EXE_ATTACHMENT_FOOTER
  magic.l
  blockSize.q
  numFiles.l
EndStructure


Structure EXE_ATTACHMENT_GLOBALS
  footer.EXE_ATTACHMENT_FOOTER  
  initialized.i
  size.q
  offset.q
  filename.s
  
  write_EXEName.s{#MAX_PATH}
  write_numFiles.i
  write_completeSize.q
  write_iFile.i
EndStructure

  
Global g_EXEAttachments.EXE_ATTACHMENT_GLOBALS
  
Procedure __EXEA_Debug(text.s)
  ;Debug text
  WriteLog(text, #LOGLEVEL_DEBUG)
EndProcedure

Procedure __EXEA_Error(text.s)
  ;Debug text  
  WriteLog(text, #LOGLEVEL_ERROR)
EndProcedure

Procedure OpenEXEAttachements(sFile.s = "")
  Protected iResult = #False, iFile.i, qSize.q
    
  If sFile = ""
    sFile.s = ProgramFilename()
  EndIf
  
  ZeroMemory_(@g_EXEAttachments,SizeOf(EXE_ATTACHMENT_GLOBALS))
  iFile = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
  If iFile  
    qSize = Lof(iFile)
    If qSize > SizeOf(EXE_ATTACHMENT_FOOTER)
      g_EXEAttachments\size = qSize
      FileSeek(iFile, qSize - SizeOf(EXE_ATTACHMENT_FOOTER))
      ReadData(iFile, @g_EXEAttachments\footer, SizeOf(EXE_ATTACHMENT_FOOTER))
      g_EXEAttachments\offset = qSize - g_EXEAttachments\footer\blockSize
      
      ;Sanity checks
      If g_EXEAttachments\footer\numFiles > 0
        If g_EXEAttachments\footer\blockSize > 0 And g_EXEAttachments\footer\blockSize < qSize 
          
          If g_EXEAttachments\footer\magic = #EXE_ATTACHMENT_BLOCK_MAGIC
            g_EXEAttachments\initialized = #True
            g_EXEAttachments\filename = sFile
          Else
            __EXEA_Error("no identification string found!")
          EndIf
          
        Else
          __EXEA_Error("illegal block size")
        EndIf  
      Else
        ;__EXEA_Debug("illegal number of files "+Str(g_EXEAttachments\footer\numFiles))
      EndIf
      
    Else
      __EXEA_Error("illegal EXE size "+Str(qSize))
    EndIf
    CloseFile(iFile)
  Else
    __EXEA_Error("cannot open EXE file "+ sFile)
  EndIf
  ProcedureReturn g_EXEAttachments\initialized
EndProcedure

Procedure GetNumEXEAttachments()
  ProcedureReturn g_EXEAttachments\footer\numFiles
EndProcedure

Procedure ReadEXEAttachment(index, *fileentry.EXE_ATTACHMENT_FILEENTRY)
  Protected tmp.EXE_ATTACHMENT_FILEENTRY
  Protected bResult = #False, iFile.i, position.q, idx.i
  
  If *fileentry And index >= 0 And index < g_EXEAttachments\footer\numFiles
    iFile = ReadFile(#PB_Any, g_EXEAttachments\filename, #PB_File_SharedRead )
    If iFile     
      position.q = g_EXEAttachments\offset
      For idx = 0 To index
        FileSeek(iFile, position)
        ReadData(iFile, tmp, SizeOf(EXE_ATTACHMENT_FILEENTRY))
        tmp\absoluteOffset = position + SizeOf(EXE_ATTACHMENT_FILEENTRY) ;tmp\size
        position + tmp\size + SizeOf(EXE_ATTACHMENT_FILEENTRY)      
      Next
      CopyMemory(tmp, *fileentry, SizeOf(EXE_ATTACHMENT_FILEENTRY))
      bResult = #True
      CloseFile(iFile)
    Else
      __EXEA_Error("cannot open file " +  g_EXEAttachments\filename + " in ReadEXEAttachment")
    EndIf
  Else
    __EXEA_Error("illegal parameter in ReadEXEAttachment")
  EndIf
  ProcedureReturn bResult  
EndProcedure

Procedure ReadEXEAttachmentByName(name.s, *fileentry.EXE_ATTACHMENT_FILEENTRY)
  Protected tmp.EXE_ATTACHMENT_FILEENTRY
  Protected bResult = #False, iFile.i, position.q, idx.i
  name = UCase(name)
  If *fileentry And g_EXEAttachments\footer\numFiles > 0 
    iFile = ReadFile(#PB_Any, g_EXEAttachments\filename, #PB_File_SharedRead )
    If iFile     
      position.q = g_EXEAttachments\offset
      For idx = 0 To g_EXEAttachments\footer\numFiles - 1
      
        FileSeek(iFile, position)
        ReadData(iFile, tmp, SizeOf(EXE_ATTACHMENT_FILEENTRY))
        tmp\absoluteOffset = position + SizeOf(EXE_ATTACHMENT_FILEENTRY) ;tmp\size
        
        If UCase(tmp\filename) = name
          CopyMemory(tmp, *fileentry, SizeOf(EXE_ATTACHMENT_FILEENTRY))
          bResult = #True          
          Break
        EndIf       
        
        position + tmp\size + SizeOf(EXE_ATTACHMENT_FILEENTRY)      
      Next
      CloseFile(iFile)
    Else
      __EXEA_Error("cannot open file " +  g_EXEAttachments\filename + " in ReadEXEAttachmentByName")
    EndIf
  Else
    __EXEA_Error("illegal parameter in ReadEXEAttachmentByName")
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure ExtractEXEAttachmentToMem(name.s)
  Protected tmp.EXE_ATTACHMENT_FILEENTRY
  Protected bOk = #False, iFile.i, *CompressedMem, *DecompressedMem, *Mem
  If ReadEXEAttachmentByName(name, tmp)
    iFile = ReadFile(#PB_Any, g_EXEAttachments\filename, #PB_File_SharedRead )
    If iFile      
      
      FileSeek(iFile, tmp\absoluteOffset)      
      If tmp\isCompressed
          *CompressedMem = AllocateMemory(tmp\compressedSize)
          *DecompressedMem = AllocateMemory(tmp\size + 32000) ; 32000 is for security
          *Mem = AllocateMemory(tmp\size)
          If *Mem And *CompressedMem And *DecompressedMem
            If ReadData(iFile, *CompressedMem, tmp\compressedSize)
              
              
              ;If UnpackMemory(*CompressedMem, *DecompressedMem) = tmp\size
              ;2013-04-02
              If UncompressMemory(*CompressedMem, tmp\compressedSize, *DecompressedMem, tmp\size, #PB_PackerPlugin_Lzma ) = tmp\size
                CopyMemory(*DecompressedMem, *Mem, tmp\size)
                bOk = #True
              Else
                __EXEA_Error("uncompressed size does not match")
              EndIf
            Else
              __EXEA_Error("ReadData failed")
            EndIf
          Else
            __EXEA_Error("Out of memory")
          EndIf
        Else
          *Mem = AllocateMemory(tmp\size)
          If *Mem
            If ReadData(iFile, *Mem, tmp\size)
              bOk = #True
            Else
              __EXEA_Error("ReadData failed")
            EndIf
          Else
            __EXEA_Error("Out of memory")
          EndIf
        EndIf  
        CloseFile(iFile)
      Else
        __EXEA_Error("cannot open file " + g_EXEAttachments\filename)
    EndIf  
  Else
    __EXEA_Error("Cannot find file name "+name+" in EXE file")
  EndIf
  If *CompressedMem
    FreeMemory(*CompressedMem)  
  EndIf
  If *DecompressedMem
    FreeMemory(*DecompressedMem)  
  EndIf
  
  If bOk = #False
    If *Mem
      FreeMemory(*Mem)
      *Mem = #Null
    EndIf  
  EndIf
  
  ProcedureReturn *Mem
EndProcedure

Procedure BeginWriteEXEAttachments(EXEFile.s)
  Protected iFile.i, iCount.i=0
  g_EXEAttachments\write_completeSize = 0
  g_EXEAttachments\write_numFiles = 0
  g_EXEAttachments\write_EXEName = EXEFile
  iFile = OpenFile(#PB_Any, EXEFile)
  
  Repeat
    If iFile=#Null
      Delay(200)
      __EXEA_Error("Try again open EXE file: " + EXEFile)
      iFile = OpenFile(#PB_Any, EXEFile)
    EndIf  
    iCount+1
  Until iCount>10 Or iFile<>#Null
  
  If iFile
    FileSeek(iFile, Lof(iFile))    
    g_EXEAttachments\write_iFile = iFile
  Else
    __EXEA_Error("Cannot open EXE file: " + EXEFile)
  EndIf
  ProcedureReturn iFile
EndProcedure

Procedure EndWriteEXEAttachments()
  Protected bResult = #False, footer.EXE_ATTACHMENT_FOOTER
  
  If g_EXEAttachments\write_iFile 
    footer.EXE_ATTACHMENT_FOOTER
    footer\magic = #EXE_ATTACHMENT_BLOCK_MAGIC
    footer\numFiles = g_EXEAttachments\write_numFiles
    footer\blockSize = g_EXEAttachments\write_completeSize +  SizeOf(EXE_ATTACHMENT_FOOTER)
    
    WriteData(g_EXEAttachments\write_iFile, footer, SizeOf(EXE_ATTACHMENT_FOOTER)) 
    CloseFile(g_EXEAttachments\write_iFile)
    bResult = #True
  Else
    __EXEA_Error("No EXE file was opened before")
  EndIf  
  ProcedureReturn bResult
EndProcedure


Procedure AttachMemoryToEXEFile(sFile.s, *Mem, iSize.i, bCompress = #True)
  Protected bResult = #False, *TempMem, iPackedSize, tmp.EXE_ATTACHMENT_FILEENTRY
  If iSize > 0
    If *Mem
      If g_EXEAttachments\write_iFile 
        
        *TempMem = AllocateMemory(iSize + 32000)
        If *TempMem
          If bCompress
            
            ;iPackedSize = PackMemory(*Mem, *TempMem, iSize, 9)
            ;2013-04-02
            iPackedSize = CompressMemory(*Mem, iSize, *TempMem, iSize + 32000,  #PB_PackerPlugin_Lzma )
    
            If iPackedSize = 0
              __EXEA_Debug("Warn: Compressing buffer failed!")
            EndIf 
          EndIf
          
          tmp.EXE_ATTACHMENT_FILEENTRY
          tmp\filename = GetFilePart(sFile)
          tmp\compressedSize = iPackedSize
          tmp\size = iSize
          
          If iPackedSize
            tmp\isCompressed = #True     
            WriteData(g_EXEAttachments\write_iFile, tmp, SizeOf(EXE_ATTACHMENT_FILEENTRY))
            WriteData(g_EXEAttachments\write_iFile, *TempMem, iPackedSize)
          Else
            iPackedSize = iSize
            tmp\compressedSize = iSize
            tmp\isCompressed = #False
            WriteData(g_EXEAttachments\write_iFile, tmp, SizeOf(EXE_ATTACHMENT_FILEENTRY))
            WriteData(g_EXEAttachments\write_iFile, *Mem, iSize)     
          EndIf
      
          FreeMemory(*TempMem)
          g_EXEAttachments\write_completeSize + iPackedSize + SizeOf(EXE_ATTACHMENT_FILEENTRY)   
          g_EXEAttachments\write_numFiles + 1
          bResult = #True
        Else
          __EXEA_Error("Out of memory")
        EndIf
        
      Else
        __EXEA_Error("No EXE file was opened before")
      EndIf
    Else
      __EXEA_Error("Invalid parameter: Nullpointer")
    EndIf
  Else
    __EXEA_Error("Invalid parameter: Size must be bigger than 0")
  EndIf
EndProcedure

Procedure AttachSmallFileToEXEFile(sFile.s, bCompress = #True)
  Protected bResult = #False, iFile.i, iSize.i, *Mem
  iFile = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
  If iFile
    iSize = Lof(iFile)
    If iSize > 0
      *Mem = AllocateMemory(iSize)
      If *Mem
        ReadData(iFile, *Mem, iSize)
        bResult = AttachMemoryToEXEFile(sFile, *Mem, iSize, bCompress)
        FreeMemory(*Mem)
      Else
        __EXEA_Error("Out of memory")
      EndIf
    Else
      __EXEA_Error("File size of " + sFile + " must be bigger than 0")      
    EndIf
    CloseFile(iFile)
  Else
    __EXEA_Error("Cannot open file " + sFile)
  EndIf
  ProcedureReturn bResult
EndProcedure


Procedure __WriteFileContent(iDestFile, sSrcFile.s, *header.EXE_ATTACHMENT_FILEENTRY)
  Protected bResult = #False, *Mem, iSrcFile, qRemaining.q
  
  *Mem = AllocateMemory($FFFF)
  If *Mem
    iSrcFile = ReadFile(#PB_Any, sSrcFile, #PB_File_SharedRead )
    If iSrcFile
      WriteData(iDestFile, *header, SizeOf(EXE_ATTACHMENT_FILEENTRY))
      qRemaining.q = Lof(iSrcFile)
      Repeat    
        If qRemaining > $FFFF
          ReadData(iSrcFile, *Mem, $FFFF)
          WriteData(iDestFile, *Mem, $FFFF)
          qRemaining = qRemaining - $FFFF
        Else
          ReadData(iSrcFile, *Mem, qRemaining)
          WriteData(iDestFile, *Mem, qRemaining)  
          qRemaining = 0
        EndIf   
      Until qRemaining = 0
      CloseFile(iSrcFile)
      bResult = #True
    Else
      __EXEA_Error("cannot open file " + sSrcFile)
    EndIf
    FreeMemory(*Mem)
  Else
    __EXEA_Error("Out of memory")
  EndIf
  ProcedureReturn bResult
EndProcedure



Procedure AttachBigFileToEXEFile(sFile.s)
  Protected bResult = #False, qSize.q
  Protected tmp.EXE_ATTACHMENT_FILEENTRY
  
  If g_EXEAttachments\write_iFile 
         
    qSize = FileSize(sFile)
    tmp.EXE_ATTACHMENT_FILEENTRY
    tmp\filename = GetFilePart(sFile)
    tmp\isCompressed = #False
    tmp\compressedSize = qSize
    tmp\size = qSize         
    
    If qSize > 0 
      If __WriteFileContent(g_EXEAttachments\write_iFile, sFile, tmp)
        g_EXEAttachments\write_completeSize + qSize + SizeOf(EXE_ATTACHMENT_FILEENTRY)   
        g_EXEAttachments\write_numFiles + 1
        bResult = #True
      EndIf
    Else
      __EXEA_Error("Size of file " + sFile + " is not bigger than 0")
    EndIf
    
  Else
    __EXEA_Error("No EXE file was opened before")
  EndIf
  ProcedureReturn bResult
EndProcedure


;{ Sample
; DisableExplicit
; 
; 
; CopyFile("D:\TEST\player.exe", "D:\TEST\stub.exe")
; 
; 
; If BeginWriteEXEAttachments("D:\TEST\stub.exe")
;   AttachSmallFileToEXEFile("D:\TEST\movie1.mp4") 
;   AttachBigFileToEXEFile("D:\TEST\movie2.mp4")
;   AttachSmallFileToEXEFile("D:\TEST\test.pb") 
;   EndWriteEXEAttachments()
; Else
;   MessageRequester("","ERROR!!!")
; EndIf
; 
; 
; 
; OpenEXEAttachements("D:\TEST\stub.exe")
; 
; Debug GetNumEXEAttachments()
; fe.EXE_ATTACHMENT_FILEENTRY
; Debug ReadEXEAttachmentByName("movie1.mp4", fe)
; 
; CreateFile(1,"D:\TEST\out.mp4")
; *PTR = ExtractEXEAttachmentToMem("movie2.mp4")
; WriteData(1,*PTR, MemorySize(*PTR))
; CloseFile(1)
; 
; Debug 0
;}


; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 353
; FirstLine = 352
; Folding = ---
; EnableXP
; EnableOnError
; Executable = Extract.exe
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant