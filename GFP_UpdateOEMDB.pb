;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************

#PLAYER_VERSION="1.00"
#USE_OEM_VERSION=0
#PB_Editor_BuildCount=0
#WINDOW_MAIN=0
#PB_Editor_CreateExecutable=0

Procedure.s GetGraphicCardName()
EndProcedure
Procedure.s GetCPUName()
EndProcedure
Procedure.s GetWindows()
EndProcedure
Structure MediaFile
  sFile.s
  Memory.i
  sRealFile.s
  iPlaying.i
  qOffset.q
  *StreamingFile
EndStructure
Global MediaFile.MediaFile

XIncludeFile "include\GFP_Settings.pbi"
XIncludeFile "include\GFP_LogFile.pbi"
XIncludeFile "include\GFP_Database.pbi"
;XIncludeFile "include\GFP_StringCommands_3.pbi"
;XIncludeFile "include\GFP_Cryption_Unicode.pbi"
;XIncludeFile "include\GFP_DRMHeader_unicode.pbi"

Procedure GetDPI()  
EndProcedure   

Procedure Requester_Error(sText.s)
EndProcedure   
Procedure __AnsiString(str.s)
  Protected *ptr
  *ptr = AllocateMemory(Len(str)+1)
  If *ptr
    PokeS(*ptr, str, -1,#PB_Ascii)
  EndIf
  ProcedureReturn *ptr
EndProcedure


Procedure ReplaceLanguageTable(*DB, *TempDB)
  Protected iDBFile.i, sTempDBFile.s, iRow.i, iColumns.i, iColumn.i, sCoumns.s, sCoumns2.s, sCoumns3.s, iMaxRow.i
  DB_UpdateSync(*DB, "DROP TABLE LANGUAGE")
  
  DB_Query(*TempDB, "SELECT * FROM LANGUAGE ORDER BY ID")
  DB_SelectRow(*TempDB, 0)
  iColumns.i = DB_GetNumColumns(*TempDB)
  sCoumns.s="CREATE TABLE LANGUAGE (id INT UNIQUE,"
  sCoumns2.s="INSERT INTO LANGUAGE ( "
  For iColumn=0 To iColumns-1
    If iColumn>0
      sCoumns.s + " "+DB_GetColumnName(*TempDB, iColumn)+" VARCHAR(500),"
    EndIf
    
    sCoumns2.s + " "+DB_GetColumnName(*TempDB, iColumn)+","
    sCoumns3.s + "?,"
  Next
  sCoumns.s=Left(sCoumns.s, Len(sCoumns.s)-1)+")"
  sCoumns2.s=Left(sCoumns2.s, Len(sCoumns2.s)-1)+")"+" VALUES ("+Left(sCoumns3.s, Len(sCoumns3.s)-1)+")"
  DB_Update(*DB, sCoumns)
  
  iMaxRow = 0
  While DB_SelectRow(*TempDB, iMaxRow)
    iMaxRow + 1
  Wend
    
  iRow = 0
  While DB_SelectRow(*TempDB, iRow)
    If DB_Query(*DB, sCoumns2)
      For iColumn=0 To iColumns-1
        DB_StoreAsString(*DB, iColumn, DB_GetAsString(*TempDB, iColumn))
      Next
      DB_StoreRow(*DB)
    EndIf
    DB_EndQuery(*DB)
    iRow + 1
  Wend
  DB_EndQuery(*TempDB)
  
EndProcedure  

DisableExplicit

*OrgDB=DB_Open("data.sqlite")
If *OrgDB=0
  MessageRequester("Error","Can't open data.sqlite!")
  End
EndIf
*DB=DB_Open("..\OEM-data\data.sqlite")
If *OrgDB=0
  MessageRequester("Error","Can't open ..\OEM-data\data.sqlite!")
  End
EndIf  
ReplaceLanguageTable(*DB, *OrgDB)
DB_Close(*OrgDB)
DB_Close(*DB)
MessageRequester("Finish","Finsih!")


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 99
; FirstLine = 40
; Folding = --
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; UseIcon = data\Icons\Icons-All-In-One\Download.ico
; Executable = data\UpdateOEMDB.exe