;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit





Structure ICONIMAGEHEADER
  bWidth.b
  bHeight.b
  bColorCount.b
  bReserved.b
  wPlanes.w
  wBitCount.w
  dwBytesInRes.l
  Offset.l
EndStructure

Structure ICONIMAGEHEADER_GROUP
  bWidth.b
  bHeight.b
  bColorCount.b
  bReserved.b
  wPlanes.w
  wBitCount.w
  dwBytesInRes.l
  nID.w
EndStructure

Structure ICONFILEHEADER
  idReserved.w
  idType.w  
  idCount.w
EndStructure

Structure ICONFILE
  header.ICONFILEHEADER
  image.ICONIMAGEHEADER
EndStructure


Global g_ResLanguages.s = ""
Global g_ResNames.s = ""

Procedure __ResOutput(sText.s)
  ;Debug sText
  WriteLog(sText)
EndProcedure

Procedure __LoadFileToMemory(sFile.s)
  Protected iFile.i, iFileSize.i, *addr
  iFile = ReadFile(#PB_Any, sFile)
  If iFile
    iFileSize = Lof(iFile)
    *addr = AllocateMemory(iFileSize)
    If *addr
      ReadData(iFile, *addr, iFileSize)
    EndIf
    CloseFile(iFile)
  EndIf
  ProcedureReturn *addr
EndProcedure


Procedure __CountIconsInICOFilePtr(*addr.ICONFILE)
  If *addr
    If *addr\header\idType = 1 ; 1= ICO
      ProcedureReturn *addr\header\idCount
    Else
      __ResOutput("No ICO type")
    EndIf  
  Else
    __ResOutput("Null pointer in CountIconsInICOFilePtr")
  EndIf
  ProcedureReturn 0
EndProcedure

Procedure __GetIconPtr(*addr.ICONFILE, iIconIndex.i)
  Protected iNum, *Icon.ICONIMAGEHEADER
  iNum.i = __CountIconsInICOFilePtr(*addr)
  If iNum > 0 And iIconIndex < iNum
    *Icon.ICONIMAGEHEADER = *addr + SizeOf(ICONFILEHEADER)  
    *Icon = *Icon + SizeOf(ICONIMAGEHEADER) * iIconIndex
  Else
    __ResOutput("Icon index out of bounds")    
  EndIf
  ProcedureReturn *Icon
EndProcedure

Procedure __BuildIconGroup(*addr.ICONFILE, iOffset.i)
  Protected iNum, *Group.ICONIMAGEHEADER_GROUP, *Icon.ICONIMAGEHEADER
  Protected *OrgGroup, i.i
  If *addr
    iNum.i = __CountIconsInICOFilePtr(*addr)
    If iNum > 0
      *Group.ICONIMAGEHEADER_GROUP = AllocateMemory(SizeOf(ICONIMAGEHEADER_GROUP) * iNum + SizeOf(ICONFILEHEADER))
      If *Group <> #Null
      
        *OrgGroup = *Group
        CopyMemory(*addr, *Group, SizeOf(ICONFILEHEADER))
        *Group + SizeOf(ICONFILEHEADER)
        
        *Icon.ICONIMAGEHEADER = *addr + SizeOf(ICONFILEHEADER)  
        For i = 0 To iNum - 1  
          CopyMemory(*Icon, *Group, SizeOf(ICONIMAGEHEADER_GROUP))
          *Group\nID = i + iOffset + 1
          *Icon + SizeOf(ICONIMAGEHEADER) 
          *Group + SizeOf(ICONIMAGEHEADER_GROUP)
        Next
      Else
        __ResOutput("out of memory in BuildIconGroup")
      EndIf
    Else
      __ResOutput("no icons found")     
    EndIf
  Else
    __ResOutput("Null pointer in BuildIconGroup")  
  EndIf
  ProcedureReturn *OrgGroup
EndProcedure

Procedure __AddIconToRessource(handle, *addr.ICONIMAGEHEADER, *pICOFile, iIconIndex.i, iLanguageCode.i = #LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10)
  Protected iResult.i = #False
  If *pICOFile
    If *addr
      If *addr\Offset > 0
        
        If *Addr\dwBytesInRes > 0
          iResult = UpdateResource_(handle, #RT_ICON, iIconIndex, iLanguageCode, *pICOFile+*addr\Offset,*Addr\dwBytesInRes)
        Else
          __ResOutput("Size is wrong in AddIconToRessource!")           
        EndIf
      Else
       __ResOutput("wrong offset " + Str(*addr\Offset) + " in AddIconToRessource!")         
      EndIf     
    Else
      __ResOutput("address pointer is null in AddIconToRessource!")      
    EndIf
  Else
    __ResOutput("ICON file pointer is null in AddIconToRessource!")  
  EndIf
  ProcedureReturn iResult
EndProcedure


Procedure __Val(sNum.s)
  If Str(Val(sNum)) = sNum
    ProcedureReturn Val(sNum)  
  Else
    ProcedureReturn -1
  EndIf
EndProcedure


Procedure __GetIconGroupData(ExeFile.s, sGroupName.s = "MAINICON", iLanguageCode.i = #LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10, *bIsResNumber.integer = #Null)
Protected *mem = #Null, hModule,hResInfo,iSize, hRes, *pointer, iGroupNr.i
hModule = LoadLibraryEx_(ExeFile, 0, #LOAD_LIBRARY_AS_DATAFILE)

If hModule
  hResInfo = FindResourceEx_(hModule, #RT_GROUP_ICON, sGroupName, iLanguageCode)
  
  If *bIsResNumber
    *bIsResNumber\i = #False 
  EndIf  
  
  If hResInfo = #Null
    ;Possibly it is a number
    iGroupNr = __Val(sGroupName)
    If iGroupNr <> -1
      hResInfo = FindResourceEx_(hModule, #RT_GROUP_ICON, iGroupNr, iLanguageCode)     
      If *bIsResNumber
        *bIsResNumber\i = #True  
      EndIf     
    EndIf 
  EndIf
  
  If hResInfo
    iSize = SizeofResource_(hModule, hResInfo)
    If iSize > 0
      hRes = LoadResource_(hModule, hResInfo)  
      *pointer = LockResource_(hRes)
      If *pointer
        *mem = AllocateMemory(iSize)
        If *mem
          CopyMemory(*pointer, *mem, iSize)
        Else
          __ResOutput("out of memory in __GetIconGroupData")
        EndIf
      Else
        __ResOutput("ressource pointer is null in __GetIconGroupData")
      EndIf 
    Else
      __ResOutput("incorrect ressource size in __GetIconGroupData")
    EndIf
  Else
    __ResOutput("Cannot find ressource icon group "+ sGroupName + " in __GetIconGroupData")    
  EndIf
  FreeLibrary_(hModule)
Else
  __ResOutput("Cannot load module "+ ExeFile + " in __GetIconGroupData")
EndIf
ProcedureReturn *mem
EndProcedure

Procedure __AddRessource(ExeFile.s, sResFile.s,*mem, iType.i, bUseNumber, iNumber, sName.s, iLanguageCode.i = #LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10)
  Protected handle, iResult = #False
  Protected bRes
  handle = BeginUpdateResource_(ExeFile, #False)
  If handle
    If *mem = #Null
      *mem = __LoadFileToMemory(sResFile.s)
    Else
      ; file already loaded...
    EndIf
  
    If *mem
      If bUseNumber
        bRes = UpdateResource_(handle, iType, iNumber, iLanguageCode, *mem, MemorySize(*mem))    
      Else
        bRes = UpdateResource_(handle, iType, sName, iLanguageCode, *mem, MemorySize(*mem))           
      EndIf
      
      If bRes
        iResult = EndUpdateResource_(handle, #False)
      Else
        EndUpdateResource_(handle, #True)
        __ResOutput("update ressource failed in __AddRessource")
      EndIf
    Else
      __ResOutput("Cannot load file " + sResFile + " in __AddRessource")
    EndIf
    
  Else
    __ResOutput("BeginUpdateResource failed for " +  ExeFile + " in __AddRessource")
  EndIf   
  If *mem
    FreeMemory(*mem)
  EndIf
  ProcedureReturn iResult  
EndProcedure


Procedure __RemoveRessource(ExeFile.s, iType.i, bUseNumber, iNumber, sName.s, iLanguageCode.i = #LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10)
  Protected handle, iResult = #False, *mem
  Protected bRes
  handle = BeginUpdateResource_(ExeFile, #False)
  If handle

    If bUseNumber
      bRes = UpdateResource_(handle, iType, iNumber, iLanguageCode, #Null, 0)    
    Else
      bRes = UpdateResource_(handle, iType, sName, iLanguageCode, #Null, 0)           
    EndIf
    
    If bRes
      iResult = EndUpdateResource_(handle, #False)
    Else
      EndUpdateResource_(handle, #True)
      __ResOutput("update ressource failed in __RemoveRessource")
    EndIf

  Else
    __ResOutput("BeginUpdateResource failed for " +  ExeFile + " in __RemoveRessource")
  EndIf   
  ProcedureReturn iResult  
EndProcedure


Procedure.s __MakeLine(sLine.s, bLast = #False)
  If bLast
    ProcedureReturn ReplaceString(sLine, "%QUOTE%", Chr(34))
  Else
    ProcedureReturn ReplaceString(sLine, "%QUOTE%", Chr(34))+ #CRLF$    
  EndIf
EndProcedure


Procedure __CreateManifest(bXPControls, bAdministrator)
  Protected Lines.s, sTmp.s, *mem
  Lines.s = ""
  Lines + __MakeLine("<?xml version=%QUOTE%1.0%QUOTE% encoding=%QUOTE%UTF-8%QUOTE% standalone=%QUOTE%yes%QUOTE%?>")
  Lines + __MakeLine("<assembly xmlns=%QUOTE%urn:schemas-microsoft-com:asm.v1%QUOTE% manifestVersion=%QUOTE%1.0%QUOTE%>")
  Lines + __MakeLine("  <assemblyIdentity")
  Lines + __MakeLine("    version=%QUOTE%1.0.0.0%QUOTE%")
  Lines + __MakeLine("    processorArchitecture=%QUOTE%X86%QUOTE%")
  Lines + __MakeLine("    name=%QUOTE%CompanyName.ProductName.YourApp%QUOTE%")
  Lines + __MakeLine("    type=%QUOTE%win32%QUOTE% />")
  Lines + __MakeLine("  <description></description>")
  
  If bXPControls
    Lines + __MakeLine("  <dependency>")
    Lines + __MakeLine("    <dependentAssembly>")
    Lines + __MakeLine("      <assemblyIdentity")
    Lines + __MakeLine("        type=%QUOTE%win32%QUOTE%")
    Lines + __MakeLine("        name=%QUOTE%Microsoft.Windows.Common-Controls%QUOTE%")
    Lines + __MakeLine("        version=%QUOTE%6.0.0.0%QUOTE%")
    Lines + __MakeLine("        processorArchitecture=%QUOTE%X86%QUOTE%")
    Lines + __MakeLine("        publicKeyToken=%QUOTE%6595b64144ccf1df%QUOTE%")
    Lines + __MakeLine("        language=%QUOTE%*%QUOTE% />")
    Lines + __MakeLine("    </dependentAssembly>")
    Lines + __MakeLine("  </dependency>")
  EndIf
  
  If bAdministrator
    Lines + __MakeLine("  <trustInfo xmlns=%QUOTE%urn:schemas-microsoft-com:asm.v2%QUOTE%>")
    Lines + __MakeLine("   <security>")
    Lines + __MakeLine("      <requestedPrivileges>")
    Lines + __MakeLine("        <requestedExecutionLevel")
    Lines + __MakeLine("          level=%QUOTE%requireAdministrator%QUOTE%")
    Lines + __MakeLine("          uiAccess=%QUOTE%false%QUOTE%/>")
    Lines + __MakeLine("        </requestedPrivileges>")
    Lines + __MakeLine("       </security>")
    Lines + __MakeLine("  </trustInfo>")
  EndIf
  
  Lines + __MakeLine("</assembly>",#True)
  
  sTmp.s =Space(Len(Lines)) ;PokeS schriebt immer ein 0 byte
  *mem = AllocateMemory(Len(Lines)) ; Da immer ascii!
  If *mem
    PokeS(@sTmp, Lines,-1, #PB_Ascii)
    CopyMemory(@sTmp, *mem, Len(Lines))
  EndIf
  ProcedureReturn *mem
EndProcedure


; 
; Procedure __CreateVersion()
; Lines.s = ""
; 
;   Lines + __MakeLine("1 VERSIONINFO")
;   Lines + __MakeLine("FILEVERSION 1,0,3,0")
;   Lines + __MakeLine("PRODUCTVERSION 1,0,3,0")
;   Lines + __MakeLine("FILEOS 0x0")
;   Lines + __MakeLine("FILETYPE 0x1")
;   Lines + __MakeLine("{")
;   Lines + __MakeLine("BLOCK %QUOTE%StringFileInfo%QUOTE%")
;   Lines + __MakeLine("{")
;   Lines + __MakeLine("	BLOCK %QUOTE%000004b0%QUOTE%")
;   Lines + __MakeLine("	{")
;   Lines + __MakeLine("		VALUE %QUOTE%CompanyName%QUOTE%, %QUOTE%RRSoftware%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%ProductName%QUOTE%, %QUOTE%GreenForce Player%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%ProductVersion%QUOTE%, %QUOTE%1.03%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%FileVersion%QUOTE%, %QUOTE%1.03%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%FileDescription%QUOTE%, %QUOTE%GreenForce media player%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%InternalName%QUOTE%, %QUOTE%GreenForce Player%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%OriginalFilename%QUOTE%, %QUOTE%GreenForce-Player.exe%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%LegalCopyright%QUOTE%, %QUOTE%(c) 2009 - 2010 RocketRider%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%Email%QUOTE%, %QUOTE%support@gfp.rrsoftware.de%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%Website%QUOTE%, %QUOTE%http://www.GFP.RRSoftware.de%QUOTE%")
;   Lines + __MakeLine("		VALUE %QUOTE%Author%QUOTE%, %QUOTE%RocketRider%QUOTE%")
;   Lines + __MakeLine("	}")
;   Lines + __MakeLine("}")
;   Lines + __MakeLine("")
;   Lines + __MakeLine("BLOCK %QUOTE%VarFileInfo%QUOTE%")
;   Lines + __MakeLine("{")
;   Lines + __MakeLine("	VALUE %QUOTE%Translation%QUOTE%, 0x0000 0x04B0")
;   Lines + __MakeLine("}")
;   Lines + __MakeLine("}")
; 
; 
; Lines + MakeManifestLine("</assembly>")
; sTmp.s =Space(Len(Lines)) ;PokeS schriebt immer ein 0 byte
; *mem = AllocateMemory(Len(Lines)) ; Da immer ascii!
; If *mem
;   PokeS(@sTmp, Lines,-1, #PB_Ascii)
;   CopyMemory(@sTmp, *mem, Len(Lines))
; EndIf
; ProcedureReturn *mem
; EndProcedure
; 


Procedure __SearchNextFreeIconEntry(ExeFile.s, iNum)
  Protected hModule, idx, iResult = 0, iFirst, iFreeCount = 0
  hModule = LoadLibraryEx_(ExeFile, 0, #LOAD_LIBRARY_AS_DATAFILE)
  If hModule
    For idx = 0 To $FFFF-1-iNum
      If FindResource_(hModule, "#"+Str(idx+1), #RT_ICON) = #Null And FindResource_(hModule, Str(idx+1), #RT_ICON) = #Null
        If iFirst = -1
          iFirst = idx
        EndIf  
        iFreeCount + 1
      Else
        iFreeCount = 0
        iFirst = -1
      EndIf
      
      If iFreeCount >= iNum And iFirst <> -1
        iResult = iFirst
        Break
      EndIf
      
    Next
    FreeLibrary_(hModule)
  EndIf
ProcedureReturn iResult
EndProcedure

Procedure __CDEnumLanguages(hModule, pName, iType, iLanguage,iDummy)
  g_ResLanguages + Str(iLanguage) + ","
  ProcedureReturn #True
EndProcedure

Procedure __EnumLanguages(EXEFile.s, sName.s, iType.i)
Protected hModule
hModule = LoadLibraryEx_(EXEFile, 0, #LOAD_LIBRARY_AS_DATAFILE)
If hModule
  g_ResLanguages = ""
  EnumResourceLanguages_(hModule, iType, sName,@__CDEnumLanguages(),0)
  FreeLibrary_(hModule)  
  If Len(g_ResLanguages)> 0
    g_ResLanguages = Left(g_ResLanguages, Len(g_ResLanguages)-1)  
  EndIf
EndIf
EndProcedure

Procedure __EnumNames(hModule, pType, pName,iDummy)
  If pName
    g_ResNames + PeekS(pName) + "[%DIV%]"
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure.s __GetNames(EXEFile.s, iType.i)
Protected  hModule 
hModule = LoadLibraryEx_(EXEFile, 0, #LOAD_LIBRARY_AS_DATAFILE)
If hModule
  g_ResNames = ""
  EnumResourceNames_(hModule,iType, @__EnumNames(), 0)
  FreeLibrary_(hModule)  
  If Len(g_ResNames)> 0
    g_ResNames = Left(g_ResNames, Len(g_ResNames)-Len("[%DIV%]"))  
  EndIf
EndIf
ProcedureReturn g_ResNames
EndProcedure


Procedure __ResMod_RemoveManifest(ExeFile.s, sName.s = "1", iLanguageCode.i = #LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10)
  Protected iResult, iNr
  iResult = __RemoveRessource(ExeFile, #RT_MANIFEST, #False,  0, sName, iLanguageCode)
  If iResult = #False
    iNr = __Val(sName)
    If iNr <> -1
      iResult = __RemoveRessource(ExeFile, #RT_MANIFEST, #True, iNr, sName, iLanguageCode)
    EndIf 
  EndIf
  ProcedureReturn iResult
EndProcedure

Procedure __ResMod_RemoveIconGrp(ExeFile.s, sGroupName.s = "MAINICON", iLanguageCode.i = #LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10)
  Protected handle, *header.ICONFILEHEADER,*orgResPtr, *resPtr.ICONIMAGEHEADER_GROUP, iNum.i,bRes = #True, iResult.i = #False, iGroupNr.i, bIsResNumber
  Protected idx
  
  *resPtr = __GetIconGroupData(ExeFile.s, sGroupName.s, iLanguageCode.i, @bIsResNumber)
  *header = *resPtr
  If *resPtr
    iNum = *header\idCount
    If iNum > 0
      *resPtr + SizeOf(ICONFILEHEADER)
      
      handle = BeginUpdateResource_(ExeFile, #False)
      If handle      
                
        For idx = 0 To iNum - 1        
          If bRes
            bRes = UpdateResource_(handle, #RT_ICON, *resPtr\nID, iLanguageCode, #Null, 0)
          EndIf
          *resPtr + SizeOf(ICONIMAGEHEADER_GROUP)
        Next
             
        If bRes
          ; Wird an anderer Stelle gemacht, Zugriff mit #Nummer
          If bIsResNumber
            iGroupNr = __Val(sGroupName)
            bRes = UpdateResource_(handle, #RT_GROUP_ICON, iGroupNr, iLanguageCode, #Null, 0)             
          Else
            bRes = UpdateResource_(handle, #RT_GROUP_ICON, sGroupName, iLanguageCode, #Null, 0)            
          EndIf                  
        EndIf        
        
        If bRes
          If EndUpdateResource_(handle, #False)
            iResult = #True  
          EndIf
        Else
          EndUpdateResource_(handle, #True)   
         __ResOutput("updating failed")         
        EndIf
        
      Else
        __ResOutput("BeginUpdateResource failed")
      EndIf     
    
    Else
      __ResOutput("illegal icon count in group ("+Str(iNum)+") in ResMod_RemoveIconGrp")  
    EndIf
    
  Else
      __ResOutput("ressource pointer is null in ResMod_RemoveIconGrp")     
  EndIf
  
  If *header
    FreeMemory(*header)
  EndIf
  ProcedureReturn iResult
EndProcedure


ProcedureDLL ResMod_RemoveIconGrp(ExeFile.s, sGroupName.s = "MAINICON", iLanguageCode.i = -1)
  Protected k, bRes, iResult = #False  
  If iLanguageCode = -1  
    __EnumLanguages(ExeFile, sGroupName, #RT_GROUP_ICON)
    If g_ResLanguages = ""
      g_ResLanguages = Str(#LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10)    
    EndIf
  Else
    g_ResLanguages = Str(iLanguageCode)   
  EndIf
  
  For k=1 To CountString(g_ResLanguages, ",") + 1
    bRes = __ResMod_RemoveIconGrp(ExeFile.s, sGroupName.s, Val(StringField(g_ResLanguages, k, ",")))
    If bRes
      iResult = #True  
    EndIf
  Next
  ProcedureReturn iResult
EndProcedure


ProcedureDLL ResMod_AddIconGrp(ExeFile.s,sIcoFile.s, sGroupName.s = "MAINICON", iIndexOffset.i = -1, iLanguageCode.i = #LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10)
  Protected *ICOFileData.ICONFILE, handle.i, *ICONData.ICONIMAGEHEADER, *GroupData, iNum.i, bRes, iResult = #False
  Protected t.i
  
  *ICOFileData.ICONFILE = __LoadFileToMemory(sIcoFile)
  If *ICOFileData
  
    iNum = __CountIconsInICOFilePtr(*ICOFileData)
    
    If iIndexOffset = -1
      iIndexOffset = __SearchNextFreeIconEntry(ExeFile.s, iNum)
    EndIf
   
    If iNum > 0
    
      handle = BeginUpdateResource_(ExeFile, #False)
      If handle
        bRes = #True
        For t=0 To iNum-1
          *ICONData.ICONIMAGEHEADER = __GetIconPtr(*ICOFileData, t) 
          If bRes
            bRes =__AddIconToRessource(handle, *ICONData, *ICOFileData, t + iIndexOffset + 1, iLanguageCode)
          EndIf
        Next
        
        If bRes
          *GroupData = __BuildIconGroup(*ICOFileData, iIndexOffset)
          If *GroupData
            bRes = UpdateResource_(handle,#RT_GROUP_ICON, sGroupName, iLanguageCode, *GroupData, MemorySize(*GroupData))
            
            ;FIX RR 07-22-2012
            FreeMemory(*GroupData)
            ;*********************
          Else
            bRes = #False
            __ResOutput("Group data pointer is null!")
          EndIf  

          
        EndIf  
        
        If bRes
          If EndUpdateResource_(handle, #False)
            iResult = #True  
          EndIf
        Else
          EndUpdateResource_(handle, #True)            
        EndIf
      Else
        __ResOutput("BeginUpdateResource error")
      EndIf
    Else
      __ResOutput("File " + sIcoFile + " contains no icons")
    EndIf
    FreeMemory(*ICOFileData)  
    
  Else
    __ResOutput("Cannot load file " + sIcoFile)
  EndIf
  ProcedureReturn iResult
EndProcedure

ProcedureDLL ResMod_DeleteAll(ExeFile.s)
  Protected handle, iResult = #False
  handle = BeginUpdateResource_(ExeFile, #True)
  If handle
    iResult = EndUpdateResource_(handle, #False)
  EndIf   
  ProcedureReturn iResult
EndProcedure


ProcedureDLL ResMod_AddManifest(ExeFile.s, sManifestFile.s, sName.s = "1", iLanguageCode.i = #LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10)
  Protected *mem, bXP, bAdmin  
  If FindString(Trim(UCase(sManifestFile)),"[XP]", 1)
    bXP = #True  
  EndIf
  If FindString(Trim(UCase(sManifestFile)),"[XPMANIFEST]", 1)
    bXP = #True  
  EndIf
  If FindString(Trim(UCase(sManifestFile)),"[ADMIN]", 1)
    bAdmin = #True
  EndIf    
  If FindString(Trim(UCase(sManifestFile)),"[ADMINMANIFEST]", 1)
    bAdmin = #True
  EndIf 
  
  If bXP Or bAdmin
    *mem = __CreateManifest(bXP, bAdmin)  
  EndIf
  ProcedureReturn __AddRessource(ExeFile, sManifestFile, *mem, #RT_MANIFEST, #False, 0, sName, iLanguageCode)
EndProcedure


ProcedureDLL ResMod_RemoveManifest(ExeFile.s, sName.s = "1", iLanguageCode.i = -1)
  Protected k, bRes, iResult = #False  
  If iLanguageCode = -1  
    __EnumLanguages(ExeFile, sName, #RT_MANIFEST)
    If g_ResLanguages = ""
      g_ResLanguages = Str(#LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10)    
    EndIf
  Else
    g_ResLanguages = Str(iLanguageCode)   
  EndIf
  
  For k=1 To CountString(g_ResLanguages, ",")+1
    bRes = __ResMod_RemoveManifest(ExeFile.s, sName.s, Val(StringField(g_ResLanguages, k, ","))) 
    If bRes
      iResult = #True  
    EndIf
  Next
  ProcedureReturn iResult
EndProcedure

ProcedureDLL.s ResMod_GetIconGroups(EXEFile.s)
  ProcedureReturn __GetNames(EXEFile.s, #RT_GROUP_ICON)
EndProcedure

ProcedureDLL.s ResMod_GetManifests(EXEFile.s)
  ProcedureReturn __GetNames(EXEFile.s, #RT_MANIFEST)
EndProcedure


;{ Sample

; DisableExplicit
; 
; 
; Debug ModRes_GetIconGroups("D:\test\mpplayer.exe")
; Debug ModRes_GetManifests("D:\test\checkupdmp.exe")
; 
; 
; Debug  ResMod_RemoveIconGrp("D:\test\mpplayer.exe")
; Debug ResMod_AddIconGrp("D:\test\mpplayer.exe", "D:\test\Laptop.ico")
; 
;}
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 670
; FirstLine = 614
; Folding = -----
; EnableXP
; EnableCompileCount = 16
; EnableBuildCount = 0
; EnableExeConstant