;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
;*****************************
;*** Database Commands v1.4***
;*****************************
;***  (c)2009 RocketRider  *** 
;***     RocketRider.eu    *** 
;*****************************
;***    PureBasic  4.60    *** 
;***      07.09.2011       ***
;*****************************



;DisableExplicit
EnableExplicit
;XIncludeFile "Packer.pbi"
;XIncludeFile "include\GFP_LogFile.pbi"

#FSCTL_SET_COMPRESSION = ((9)<<16) | ((3)<<14) | ((16)<<2) | (0)

#SQLITE_OK = #Null ;Successful result
#SQLITE_ERROR = 1 ;SQL error Or missing database
#SQLITE_INTERNAL = 2 ;Internal logic error in SQLite
#SQLITE_PERM = 3 ;Access permission denied
#SQLITE_ABORT = 4 ;Callback routine requested an abort
#SQLITE_BUSY = 5 ;The database file is locked
#SQLITE_LOCKED = 6 ;A table in the database is locked
#SQLITE_NOMEM = 7 ;A malloc() failed
#SQLITE_READONLY = 8 ;Attempt To write a readonly database
#SQLITE_INTERRUPT = 9 ;Operation terminated by sqlite3_interrupt()*/
#SQLITE_IOERR = 10 ;Some kind of disk I/O error occurred
#SQLITE_CORRUPT = 11 ;The database disk image is malformed
#SQLITE_NOTFOUND = 12 ;Not USED. Table Or record Not found
#SQLITE_FULL = 13 ;Insertion failed because database is full
#SQLITE_CANTOPEN = 14 ;Unable To open the database file
#SQLITE_PROTOCOL = 15 ;Not USED. Database lock protocol error
#SQLITE_EMPTY = 16 ;Database is empty
#SQLITE_SCHEMA = 17 ;The database schema changed
#SQLITE_TOOBIG = 18 ;String Or BLOB exceeds size limit
#SQLITE_CONSTRAINT = 19 ;Abort due To constraint violation
#SQLITE_MISMATCH = 20 ;Data type mismatch
#SQLITE_MISUSE = 21 ;Library used incorrectly
#SQLITE_NOLFS = 22 ;Uses OS features Not supported on host
#SQLITE_AUTH = 23 ;Authorization denied
#SQLITE_FORMAT = 24 ;Auxiliary database format error
#SQLITE_RANGE = 25 ;2nd parameter To sqlite3_bind out of range
#SQLITE_NOTADB = 26 ;File opened that is Not a database file
#SQLITE_ROW = 100 ;sqlite3_step() has another row ready
#SQLITE_DONE = 101 ;sqlite3_step() has finished executing

#SQLITE_INTEGER = 1
#SQLITE_FLOAT = 2
#SQLITE_TEXT = 3
#SQLITE_BLOB = 4
#SQLITE_NULL = 5

#SQLITE_STATIC = #Null
#SQLITE_TRANSIENT = -1

#DB_BLOB_DEFAULT = #Null
#DB_BLOB_COMPRESSED = 1
#DB_BLOB_ENCRYPTED = 2

ImportC "sqlite3.lib"
  sqlite3_prepare_v2(hDB, *sCommand, nBytes, *ppStmt, *pzTail)
  sqlite3_prepare16_v2(hDB, *sCommand, nBytes, *ppStmt, *pzTail)
  sqlite3_step(*pStmt)
  sqlite3_reset(*pStmt)
  sqlite3_finalize(*pStmt)
  sqlite3_column_bytes(*pStmt, iCol)
  
  sqlite3_column_blob.i(*pStmt, iCol)
  sqlite3_column_int64.q(*pStmt, iCol.i)
  sqlite3_column_double.d(*pStmt, iCol.i)
  sqlite3_column_int.i(*pStmt, iCol.i)
  sqlite3_column_text.i(*pStmt, iCol.i)
  sqlite3_column_text16.i(*pStmt, iCol.i)
  
  sqlite3_column_count.i(*pStmt)
  sqlite3_column_name.i(*pStmt, iCol.i)
  sqlite3_column_type.i(*pStmt, iCol.i)
  sqlite3_column_decltype.i(*pStmt, iCol.i)
  sqlite3_column_name16.i(*pStmt, iCol.i)
  sqlite3_column_decltype16.i(*pStmt, iCol.i)
  
  sqlite3_bind_blob(*pStmt, iCol.i, *ptr, iSize, *ptr2)
  sqlite3_bind_double(*pStmt, iCol.i, dValue.d)
  sqlite3_bind_int(*pStmt, iCol.i, iValue.i)
  sqlite3_bind_int64(*pStmt, iCol.i, qValue.q)
  sqlite3_bind_null(*pStmt, iCol.i)
  sqlite3_bind_text(*pStmt, iCol.i, *text, iSize, *ptr2)
  sqlite3_bind_text16(*pStmt, iCol.i, *text, iSize, *ptr2)
  
  sqlite3_errmsg(hDB)
  sqlite3_libversion()
EndImport

Structure DATABASE
  iDatabase.i
  bAsyncUpdate.i
  iCurrentRow.i
  bInQuery.i
  bInUpdateEx.i
  hDataBase.i
  *pStmt
  *pzTail
  qEncryptionKey.q
  
  lRandomHigh.l
  lRandomLow.l
  lRandomCount.l
  qRandomNext.q
  iCompressionLevel.i
EndStructure

Structure BLOBHEADER
  lFlags.l
  lSize.l
EndStructure

Global g_sDBError.s


UseLZMAPacker() ;2013-04-02

Procedure.s __iDB_GetErrMsg(*Database.DATABASE)
  Protected *Pointer, sResult.s
  If *Database
    *Pointer = sqlite3_errmsg(*Database\hDatabase)
    If *Pointer
      sResult = PeekS(*Pointer, -1, #PB_UTF8)
    EndIf
  EndIf
  ProcedureReturn sResult
EndProcedure
Procedure __iDB_RandomSeed(*Database.DATABASE, lValue.l)
  *Database\lRandomHigh = (lValue>>16) & $FFFF
  *Database\lRandomLow = lValue & $FFFF
  If *Database\lRandomLow = #Null : *Database\lRandomLow = 48767 : EndIf
  If *Database\lRandomLow = 1 : *Database\lRandomLow = 29147 : EndIf
  *Database\qRandomNext = *Database\lRandomLow
  *Database\lRandomCount = 13926287
EndProcedure
Procedure.l __iDB_Random(*Database.DATABASE, lMax.l)
  Protected lRandomLow.l, lResult.l
  If *Database\qRandomNext = #Null Or *Database\qRandomNext = 1
    *Database\qRandomNext = lRandomLow
  EndIf
  *Database\qRandomNext.q = (*Database\qRandomNext**Database\qRandomNext)%(41543*67807)
  lResult = *Database\qRandomNext ! (*Database\lRandomHigh + *Database\lRandomCount)
  *Database\lRandomCount + 36781
  If lResult<0 : lResult = -lResult : EndIf
  ProcedureReturn lResult%lMax
EndProcedure
Procedure.i __iDB_DecryptBuffer(*Database.DATABASE, *pBytes.BYTE, iSize.i)
  Protected qKey.q = *Database\qEncryptionKey
  Protected lKeyHigh.l, lKeyLow.l
  Protected iCount.i, i.i, iValue1.i, iValue2.i
  Protected *pPtr.BYTE, *pPtr1.BYTE, *pPtr2.BYTE
  
  If *pBytes And iSize>0
    
    lKeyHigh = (qKey>>32) & $FFFFFFFF
    lKeyLow = (qKey) & $FFFFFFFF
    __iDB_RandomSeed(*Database, lKeyHigh)
    
    *pPtr = *pBytes
    For i = #Null To iSize-1
      *pPtr\b ! __iDB_Random(*Database, $FF)
      *pPtr + 1
    Next
    
    __iDB_RandomSeed(*Database, lKeyLow)
    
    iCount = iSize + (lKeyHigh + (lKeyHigh>>16) + lKeyLow + (lKeyLow>>16)) & 128
    
    For i = #Null To iCount-1
      *pPtr1 = *pBytes + __iDB_Random(*Database, iSize)
      *pPtr2 = *pBytes + __iDB_Random(*Database, iSize)
      iValue1 = *pPtr1\b
      iValue2 = *pPtr2\b
      *pPtr1\b = iValue2
      *pPtr2\b = iValue1
    Next
    
    ProcedureReturn #True
  Else
    
    ProcedureReturn #False
  EndIf
  
EndProcedure
Procedure __iDB_EncryptBuffer(*Database.DATABASE, *pBytes.BYTE, iSize.i)
  Protected qKey.q = *Database\qEncryptionKey, *Rnd.LONG
  Protected lKeyHigh.l, lKeyLow.l, iRandomCount.i
  Protected iCount.i, i.i, iValue1.i, iValue2.i, *pLongPtr.LONG
  Protected *pPtr.BYTE, *pPtr1.BYTE, *pPtr2.BYTE
  
  If *pBytes And iSize>0
    
    lKeyHigh.l = (qKey>>32) & $FFFFFFFF
    lKeyLow.l = (qKey) & $FFFFFFFF
    
    __iDB_RandomSeed(*Database, lKeyLow)
    
    iCount.i = iSize + (lKeyHigh + (lKeyHigh>>16) + lKeyLow + (lKeyLow>>16)) & 128
    
    iRandomCount.i = iCount*2
    *Rnd.LONG = AllocateMemory(iRandomCount*SizeOf(LONG))
    
    If *Rnd
      *pLongPtr.LONG = *Rnd + (iRandomCount-1)*SizeOf(LONG)
      For i.i = #Null To iRandomCount-1
        *pLongPtr\l = __iDB_Random(*Database, iSize)
        *pLongPtr-SizeOf(LONG)
      Next
      
      *pLongPtr = *Rnd
      For i = #Null To iCount-1
        
        *pPtr2.BYTE = *pBytes + *pLongPtr\l
        *pLongPtr + SizeOf(LONG)
        *pPtr1.BYTE = *pBytes + *pLongPtr\l
        *pLongPtr + SizeOf(LONG)
        iValue1.i = *pPtr1\b
        iValue2.i = *pPtr2\b
        *pPtr1\b = iValue2
        *pPtr2\b = iValue1
      Next
      
      __iDB_RandomSeed(*Database, lKeyHigh)
      
      *pPtr.BYTE = *pBytes
      For i = #Null To iSize-1
        *pPtr\b ! __iDB_Random(*Database, $FF)
        *pPtr + 1
      Next
      
      FreeMemory(*Rnd)
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
    
  Else
    ProcedureReturn #False
  EndIf
  
EndProcedure
Procedure.i __iDB_CompressBuffer(*pPtr, iLength.i, *pNewPtr.Long, *pSize.Long, iCompressionLevel.i)
  If *pNewPtr And *pSize And *pPtr
    *pNewPtr\l = AllocateMemory(iLength + 512)
    If *pNewPtr\l
      ;*pSize\l = PackMemory(*pPtr, *pNewPtr\l, iLength, iCompressionLevel)
      *pSize\l = CompressMemory(*pPtr, iLength, *pNewPtr\l, iLength + 512, #PB_PackerPlugin_LZMA) ;2013-04-02
      
      If *pSize\l
        ProcedureReturn #True  
      Else        
        FreeMemory(*pNewPtr\l)
        *pNewPtr\l = #Null    
      EndIf
      
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure
Procedure.i __iDB_DecompressBuffer(*pPtr, iSourceLenght.i, iDestLength.i)
  Protected *pNewPtr
  *pNewPtr = AllocateMemory(iDestLength)
  If *pNewPtr
    
    If UncompressMemory(*pPtr, iSourceLenght, *pNewPtr, iDestLength, #PB_PackerPlugin_LZMA) ; 2013-04-02
      ProcedureReturn *pNewPtr
    Else
      FreeMemory(*pNewPtr)
    EndIf
  EndIf
  ProcedureReturn #Null
EndProcedure
Procedure.i __iDB_CopyMem(*pPtr, iSize.i)
  Protected *pNewPtr
  If *pPtr
    *pNewPtr = AllocateMemory(iSize)
    If *pNewPtr
      CopyMemory(*pPtr, *pNewPtr, iSize)
    EndIf
  EndIf
  ProcedureReturn *pNewPtr
EndProcedure
Procedure.i __iDB_CopyMemAddHeader(*pPtr, iSize.i, lFlags.l, lHeaderSize.l)
  Protected *pNewPtr.BLOBHEADER
  If *pPtr
    *pNewPtr.BLOBHEADER = AllocateMemory(iSize + SizeOf(BLOBHEADER))
    If *pNewPtr
      CopyMemory(*pPtr, *pNewPtr + SizeOf(BLOBHEADER), iSize)
      *pNewPtr\lFlags = lFlags
      *pNewPtr\lSize = lHeaderSize
      ProcedureReturn *pNewPtr
    EndIf
  EndIf
  ProcedureReturn #Null
EndProcedure



;Creates a new database file. The file is compressed by windows (note the file size is limited to 30  GB in this case) by default..
;The function returns true for success.
Procedure.i DB_Create(sFile.s, bCompressed = #True)
  Protected *Database.DATABASE = #Null, File, val.w, iDataBase
  Protected size, overlapped.OVERLAPPED
  g_sDBError = "failed"
  UseSQLiteDatabase()
  File = CreateFile(#PB_Any, sFile.s)
  If File
    If bCompressed
      val.w = 1 ;COMPRESSION_FORMAT_DEFAULT
      DeviceIoControl_(FileID(File), #FSCTL_SET_COMPRESSION, @val, 2, 0, 0, @size, @overlapped.OVERLAPPED)
    EndIf
    CloseFile(File)
    iDatabase = OpenDatabase(#PB_Any, sFile.s, "", "", #PB_Database_SQLite)
    If iDatabase
      *Database.DATABASE = AllocateMemory(SizeOf(DATABASE))
      If *Database
        *Database\iDatabase = iDatabase
        *Database\bAsyncUpdate = #False
        *Database\iCurrentRow = -1
        *Database\bInQuery = #False
        *Database\bInUpdateEx = #False
        *Database\hDatabase = DatabaseID(iDatabase)
        *Database\pStmt = #Null
        *Database\pzTail = #Null
        *Database\qEncryptionKey = #Null
        *Database\iCompressionLevel = 9
        g_sDBError = ""
      Else
        g_sDBError = "can not allocate memory"
        WriteLog("DB: " + g_sDBError)
        CloseDatabase(iDatabase)
      EndIf
    Else
      g_sDBError = "can not open database '" + sFile + "'"
      WriteLog("DB: " + g_sDBError)
    EndIf
    
  Else
    g_sDBError = "can not create file '" + sFile + "'"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn *Database
EndProcedure


;Opens an already existing database file.
;The function returns true for success..
Procedure.i DB_Open(sFile.s)
  g_sDBError = "failed"
  Protected *Database.DATABASE = #Null, iDatabase
  UseSQLiteDatabase()
  iDatabase = OpenDatabase(#PB_Any, sFile.s, "", "", #PB_Database_SQLite)
  
  If iDatabase
    *Database.DATABASE = AllocateMemory(SizeOf(DATABASE))
    If *Database
      *Database\iDatabase = iDatabase
      *Database\bAsyncUpdate = #False
      *Database\iCurrentRow = -1
      *Database\bInQuery = #False
      *Database\bInUpdateEx = #False
      *Database\hDatabase = DatabaseID(iDatabase)
      *Database\pStmt = #Null
      *Database\pzTail = #Null
      *Database\qEncryptionKey = #Null
      *Database\iCompressionLevel = 9
      g_sDBError = ""
    Else
      g_sDBError = "can not allocate memory"
      WriteLog("DB: " + g_sDBError)
      CloseDatabase(iDatabase)
    EndIf
  Else
    g_sDBError = "can not open database '" + sFile + "'"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn *Database
EndProcedure


;Creates a new database in the memory.
;A database on the memory is faster than a database on the harddisk.
;You can't save this database to the harddisk.
;The function returns true for success.
Procedure.i DB_CreateMemoryDB()
  ProcedureReturn DB_Open(":memory:")
EndProcedure


;Closes the database.
;The function returns true for success.
Procedure.i DB_Close(*Database.DATABASE)
  g_sDBError = "failed"
  Protected iResult.i = #False, iDatabase.i
  If *Database
    
    If *Database\bAsyncUpdate = #True
      DatabaseUpdate(*Database\iDatabase, "COMMIT")
      *Database\bAsyncUpdate = #False
    EndIf
    
    iDatabase.i = *Database\iDatabase
    FreeMemory(*Database)
    
    ;PB beachtet den Rückgabe wert von CloseDatabase() nicht, fürt zu probleme mit threadsafe.
    ;Debug iDatabase
    ;If CloseDatabase(iDatabase)
    ;  iResult = #True
    ;  g_sDBError = ""
    ;Else
    ;  g_sDBError = "closing database failed"
    ;  WriteLog("DB: " + g_sDBError)
    ;EndIf
    
    CloseDatabase(iDatabase)
    iResult = #True
    g_sDBError = ""
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Executes a statement, like DB_UpdateSync() but all calls to DB_Update() are in one transaction. So the command is much faster as DB_UpdateSync().
;The transaction is commited if DB_UpdateSync(). DB_Query(), DB_Close() or DB_Flush() is called.
;The function returns true for success.
Procedure.i DB_Update(*Database.DATABASE, sStatement.s)
  g_sDBError = "failed"
  Protected iResult.i = #False
  If *Database
    
    If *Database\bAsyncUpdate = #False
      DatabaseUpdate(*Database\iDatabase, "BEGIN")
      *Database\bAsyncUpdate = #True
    EndIf
    
    If DatabaseUpdate(*Database\iDatabase, sStatement)
      iResult = #True
      g_sDBError = ""
    Else
      g_sDBError = DatabaseError()
      WriteLog("DB: " + g_sDBError)
    EndIf
    
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure



;WORKS BUT MAKES IO ERRORS!!!
;SEE THE PB HELP
;SetDatabaseBlob(0, 0, ?Picture, PictureLength)
;SetDatabaseBlob(0, 1, ?SmallPicture, SmallPictureLength)
;DatabaseUpdate(0, "INSERT INTO PHOTOS (picture, name, small_picture) values (?, 'my description', ?);")
Procedure.i DB_UpdateBlob(*Database.DATABASE, sStatement.s, *ptr, iSize.i)
  g_sDBError = "failed"
  Protected iResult.i = #False, iBlobSize.i, *Mem
  If *Database
    *Mem = __iDB_CopyMemAddHeader(*ptr, iSize, #DB_BLOB_DEFAULT, iSize)
    If *Mem
      iBlobSize = iSize + SizeOf(BLOBHEADER)
      
;       If *Database\bAsyncUpdate = #True
;         DatabaseUpdate(*Database\iDatabase, "COMMIT")
;         *Database\bAsyncUpdate = #False
;       EndIf
      If *Database\bAsyncUpdate = #False
        DatabaseUpdate(*Database\iDatabase, "BEGIN")
        *Database\bAsyncUpdate = #True
      EndIf
    
      

      If SetDatabaseBlob(*Database\iDatabase, 0, *Mem, iBlobSize)
        iResult = #True
        g_sDBError = ""
      Else
        g_sDBError = DatabaseError()
        WriteLog("DB: " + g_sDBError)
      EndIf
      
      If DatabaseUpdate(*Database\iDatabase, sStatement)
        iResult = #True
        g_sDBError = ""
      Else
        g_sDBError = DatabaseError()
        WriteLog("DB: " + g_sDBError)
      EndIf
      
      FreeMemory(*Mem)
    Else
      g_sDBError = "copy buffer failed"
      WriteLog("DB: " + g_sDBError)
    EndIf
    
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure




;Executes a statement.
;The function returns true for success.
Procedure.i DB_UpdateSync(*Database.DATABASE, sStatement.s)
  g_sDBError = "failed"
  Protected iResult.i = #False
  If *Database
    
    ;If DB_UpdateSync() was called before...
    If *Database\bAsyncUpdate = #True
      DatabaseUpdate(*Database\iDatabase, "COMMIT")
      *Database\bAsyncUpdate = #False
    EndIf
    
    If DatabaseUpdate(*Database\iDatabase, sStatement)
      iResult = #True
      g_sDBError = ""
    Else
      g_sDBError = DatabaseError()
      WriteLog("DB: " + g_sDBError)
    EndIf
    
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Begins a query. DB_EndQuery() must be called to end the query.
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
;The function returns true for success.
Procedure.i DB_Query(*Database.DATABASE, sStatement.s)
  Protected iResult.i = #False, sTmp.s
  g_sDBError = "failed"
  If *Database
    
    ;If DB_Update() was called before...
    If *Database\bAsyncUpdate = #True
      DatabaseUpdate(*Database\iDatabase, "COMMIT")
      *Database\bAsyncUpdate = #False
    EndIf
    
    If *Database\bInQuery = #False
      *Database\iCurrentRow = -1
      
      sTmp.s = Space(Len(sStatement)*3)
      PokeS(@sTmp, sStatement, -1, #PB_UTF8)
      
      iResult.i = sqlite3_prepare_v2(*Database\hDatabase, @sTmp, -1, @*Database\pStmt, @*Database\pzTail)
      If iResult = #SQLITE_OK
        *Database\bInQuery = #True
        g_sDBError = ""
        iResult = #True
      Else
        g_sDBError = __iDB_GetErrMsg(*Database)
        WriteLog("DB: " + g_sDBError)
      EndIf
      
    Else
      g_sDBError = "DB_Query already called; DB_EndQuery must be called first."
      WriteLog("DB: " + g_sDBError)
    EndIf
    
  Else
    g_sDBError = "no valid database declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Ends a query started with DB_Query().
;The function returns true for success.
Procedure.i DB_EndQuery(*Database.DATABASE)
  Protected iResult.i = #False
  Protected *pStmt
  g_sDBError = "failed"
  If *Database
    If *Database\bInQuery
      If *Database\pStmt
        *Database\bInQuery = #False
        *pStmt = *Database\pStmt
        *Database\pStmt = #Null
        If *pStmt
          If SQLite3_Finalize(*pStmt) = #SQLITE_OK
            iResult = #True
            g_sDBError = ""
          EndIf
        EndIf
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Selects a row. The command is neccessary for DB_GetAsString(), DB_GetAsLong(), DB_GetAsQuad(), DB_GetAsDouble(), DB_GetAsBlobPointer(), DB_GetAsBlobSize(), DB_GetAsBlobFlags(), GetNumColumns(), DB_GetColumnTypeAsString() and DB_GetColumnName().
;For the first row the parameter iRow must be 0.
;Note: DB_SelectRow() must be called in a DB_Query()...DB_EndQuery() block.
;The function returns true for success.
Procedure.i DB_SelectRow(*Database.DATABASE, iRow.i)
  Protected iResult.i = #False
  Protected bFailed.i = #False, iNum, iSteps
  g_sDBError = "failed" 
  
  If iRow >= 0
    If *Database
      If *Database\bInQuery
        If *Database\pStmt
        
          If *Database\iCurrentRow <> iRow
    
            If iRow = 0
            
              If sqlite3_reset(*Database\pStmt) = #SQLITE_OK;<> #SQLITE_DONE
                If SQLite3_Step(*Database\pStmt) = #SQLITE_ROW         ;100;#SQLITE_DONE;FirstDatabaseRow(*Database\iDatabase)
                  *Database\iCurrentRow = 0
                  iResult = #True
                  g_sDBError = ""
                  
                Else        
                  *Database\iCurrentRow = -1
                  g_sDBError = "Can not reset to first line"  
                  WriteLog("DB: " + g_sDBError, #LOGLEVEL_DEBUG)
                EndIf
              
              Else
                *Database\iCurrentRow = -1
                g_sDBError = "Can not reset to first line" 
                WriteLog("DB: " + g_sDBError, #LOGLEVEL_DEBUG)          
              EndIf
                        
            Else
            
              If *Database\iCurrentRow = -1 Or *Database\iCurrentRow > iRow
              
                If sqlite3_reset(*Database\pStmt) = #SQLITE_OK ; Achtung: War ohne = #SQLITE_OK
                  If SQLite3_Step(*Database\pStmt) = #SQLITE_ROW;<> #SQLITE_DONE
                  ;If FirstDatabaseRow(*Database\iDatabase)
                    For iNum = 0 To iRow - 1
                      
                      If bFailed = #False
                        If SQLite3_Step(*Database\pStmt) <> #SQLITE_ROW ;= #SQLITE_DONE;NextDatabaseRow(*Database\iDatabase) = 0
                          *Database\iCurrentRow = -1
                          g_sDBError = "Can not set next line"  
                          ;WriteLog("DB: " + g_sDBError)
                          bFailed = #True
                        EndIf
                      EndIf
                      
                    Next
                    If bFailed = #False 
                      *Database\iCurrentRow = iRow
                      iResult = #True
                      g_sDBError = ""
                    EndIf
                  Else
                    *Database\iCurrentRow = -1
                    g_sDBError = "Can not reset to first line"    
                    WriteLog("DB: " + g_sDBError, #LOGLEVEL_DEBUG)
                  EndIf
                  
                Else
                  *Database\iCurrentRow = -1
                  g_sDBError = "Can not reset to first line"    
                  WriteLog("DB: " + g_sDBError, #LOGLEVEL_DEBUG)
                EndIf   
                                 
              EndIf
          
              ;Not supported by sqlite
              ;If *Database\iCurrentRow > iRow
              ;
              ;  iSteps.i = *Database\iCurrentRow - iRow
              ;  For iNum = 1 To iSteps
              ;    If PreviousDatabaseRow(*Database\iDatabase) = 0
              ;      *Database\iCurrentRow = -1
              ;      ProcedureReturn -1
              ;    EndIf
              ;  Next        
              ;  *Database\iCurrentRow = iRow
              ;  ProcedureReturn iRow
              ;EndIf      
              If bFailed = #False
              
                If *Database\iCurrentRow < iRow
                  iSteps.i = iRow - *Database\iCurrentRow
                  For iNum = 1 To iSteps
                    
                    If bFailed = #False
                      If SQLite3_Step(*Database\pStmt) <> #SQLITE_ROW;= #SQLITE_DONE ;NextDatabaseRow(*Database\iDatabase) = 0
                        *Database\iCurrentRow = -1
                        bFailed = #True
                        g_sDBError = "Can not set next line"  
                        ;WriteLog("DB: " + g_sDBError)
                      EndIf
                    EndIf
                  Next        
                    If bFailed = #False 
                      *Database\iCurrentRow = iRow
                      iResult = #True
                      g_sDBError = ""
                    EndIf
                EndIf                    
              EndIf
                  
            EndIf
        
          Else
            iResult = #True
            g_sDBError = ""
          EndIf
        EndIf
        
      Else
        g_sDBError = "DB_Query was not called before" 
        WriteLog("DB: " + g_sDBError)  
      EndIf
     
    Else
      g_sDBError = "no valid database handle declared" 
      WriteLog("DB: " + g_sDBError)      
    EndIf      
  Else
    g_sDBError = "Parameter iRow is less than 0"  
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Returns the value of the column as string. For the first column the parameter iColumn must be 0.
;Note: DB_SelectRow() must be called before this command.
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
Procedure.s DB_GetAsString(*Database.DATABASE, iColumn.i)
  Protected sResult.s = "", *Pointer
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt And *Database\iCurrentRow<> -1
        *Pointer = SQLite3_Column_Text(*Database\pStmt, iColumn)
        If *Pointer
          sResult.s = PeekS(*Pointer, -1, #PB_UTF8)
          g_sDBError = ""
        Else
          g_sDBError = "Null pointer"
          WriteLog("DB: " + g_sDBError)
        EndIf
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn sResult
EndProcedure


;Returns the value of the column As long (32-bit integer). For the first column the parameter iColumn must be 0.
;Note: DB_SelectRow() must be called before this command.
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
Procedure.l DB_GetAsLong(*Database.DATABASE, iColumn.i)
  Protected lResult.l = #Null
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt And *Database\iCurrentRow<> -1
        lResult = SQLite3_Column_Int(*Database\pStmt, iColumn)
        g_sDBError = ""
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn lResult
EndProcedure


;Returns the value of the column as quad (64-bit integer). For the first column the parameter iColumn must be 0.
;Note: DB_SelectRow() must be called before this command.
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
Procedure.q DB_GetAsQuad(*Database.DATABASE, iColumn.i)
  Protected qResult.q = #Null
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt And *Database\iCurrentRow<> -1
        qResult = SQLite3_Column_Int64(*Database\pStmt, iColumn)
        g_sDBError = ""
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn qResult
EndProcedure


;Returns the value of the column as double. For the first column the parameter iColumn must be 0.
;Note: DB_SelectRow() must be called before this command.
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
Procedure.d DB_GetAsDouble(*Database.DATABASE, iColumn.i)
  Protected dResult.d = #Null
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt And *Database\iCurrentRow<> -1
        dResult = sqlite3_column_double(*Database\pStmt, iColumn)
        g_sDBError = ""
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn dResult
EndProcedure


;Returns a pointer to the blob. FreeMemory() must be called after the memory is not needed anymore. For the first column the parameter iColumn must be 0.
;Note: DB_SelectRow() must be called before this command.
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
Procedure.i DB_GetAsBlobPointer(*Database.DATABASE, iColumn.i)
  Protected *pBlob.BLOBHEADER = #Null
  Protected *pResult = #Null
  Protected iSize.i, *Mem, *OldMem
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt And *Database\iCurrentRow<> -1
        *pBlob = SQLite3_Column_Blob(*Database\pStmt, iColumn)
        
        If *pBlob
          iSize.i = SQLite3_Column_Bytes(*Database\pStmt, iColumn)
          If iSize>SizeOf(BLOBHEADER)
            
            *Mem = __iDB_CopyMem(*pBlob + SizeOf(BLOBHEADER), iSize-SizeOf(BLOBHEADER))
            
            If *Mem
              If *pBlob\lFlags & #DB_BLOB_ENCRYPTED
                __iDB_DecryptBuffer(*Database, *Mem, iSize-SizeOf(BLOBHEADER))
              EndIf
              
              If *pBlob\lFlags & #DB_BLOB_COMPRESSED
                *OldMem = *Mem
                ; iSize = Größe des gepackten Speichers+SizeOf(BLOBHEADER)?
                *Mem = __iDB_DecompressBuffer(*Mem, iSize-SizeOf(BLOBHEADER), *pBlob\lSize)
                If *Mem = #Null
                  g_sDBError = "can not decompress buffer"
                  WriteLog("DB: " + g_sDBError)
                EndIf
                FreeMemory(*OldMem)
              EndIf
              
              If *Mem
                *pResult = *Mem
                g_sDBError = ""
              EndIf
              
            Else
              g_sDBError = "can not allocate memory"
              WriteLog("DB: " + g_sDBError)
            EndIf
            
          Else
            g_sDBError = "incorrect size"
            WriteLog("DB: " + g_sDBError)
          EndIf
          
        Else
          g_sDBError = "Blob null pointer"
          WriteLog("DB: " + g_sDBError)
        EndIf
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn *pResult
EndProcedure


;Returns the size of a blob in bytes. For the first column the parameter iColumn must be 0. It is faster to use MemorySize() instead of this function.
;Note: DB_SelectRow() must be called before this command.
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
Procedure.i DB_GetAsBlobSize(*Database.DATABASE, iColumn.i)
  Protected *pBlob.BLOBHEADER = #Null
  Protected iResult.i = #Null, iSize.i
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt ;And *Database\iCurrentRow <> -1
        
        *pBlob = SQLite3_Column_Blob(*Database\pStmt, iColumn)
        If *pBlob
          iSize.i = SQLite3_Column_Bytes(*Database\pStmt, iColumn)
          If iSize>8
            g_sDBError = ""
            iResult = *pBlob\lSize
          Else
            g_sDBError = "incorrect size"
            WriteLog("DB: "+g_sDBError)
          EndIf
          
        Else
          g_sDBError = "Blob null pointer"
          WriteLog("DB: " + g_sDBError)
        EndIf
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Returns the flags of a blob. For the first column the parameter iColumn must be 0.
;Note: DB_SelectRow() must be called before this command.
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
Procedure.i DB_GetAsBlobFlags(*Database.DATABASE, iColumn.i)
  Protected *pBlob.BLOBHEADER = #Null
  Protected iResult.i = #Null, iSize.i
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt ;And *Database\iCurrentRow <> -1
        
        *pBlob = SQLite3_Column_Blob(*Database\pStmt, iColumn)
        If *pBlob
          iSize.i = SQLite3_Column_Bytes(*Database\pStmt, iColumn)
          If iSize>8
            g_sDBError = ""
            iResult = *pBlob\lFlags
          Else
            g_sDBError = "incorrect size"
            WriteLog("DB: " + g_sDBError)
          EndIf
          
        Else
          g_sDBError = "null pointer"
          WriteLog("DB: " + g_sDBError)
        EndIf
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Returns the number of the column. DB_SelectRow() must be called before this command.
Procedure.i DB_GetNumColumns(*Database.DATABASE)
  Protected iResult.i = #Null
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt And *Database\iCurrentRow<> -1
        iResult.i = SQLite3_Column_Count(*Database\pStmt)
        g_sDBError = ""
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Returns the type of the column as string. For the first column the parameter iColumn must be 0. DB_SelectRow() must be called before this command.
Procedure.s DB_GetColumnTypeAsString(*Database.DATABASE, iColumn.i)
  Protected sResult.s = "", *Pointer
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt And *Database\iCurrentRow<> -1
        
        *Pointer = sqlite3_column_decltype(*Database\pStmt, iColumn)
        If *Pointer
          sResult.s = PeekS(*Pointer, -1, #PB_UTF8)
          g_sDBError = ""
        Else
          g_sDBError = "Null pointer"
          WriteLog("DB: " + g_sDBError)
        EndIf
        
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn sResult
EndProcedure


;Returns the name of the column as string. For the first column the parameter iColumn must be 0. DB_SelectRow() must be called before this command.
Procedure.s DB_GetColumnName(*Database.DATABASE, iColumn.i)
  Protected sResult.s = "", *Pointer
  g_sDBError = "failed"
  
  If *Database
    If *Database\bInQuery
      If *Database\pStmt And *Database\iCurrentRow<> -1
        
        *Pointer = SQLite3_Column_Name(*Database\pStmt, iColumn)
        If *Pointer
          sResult.s = PeekS(*Pointer, -1, #PB_UTF8)
          g_sDBError = ""
        Else
          g_sDBError = "DB_GetColumnName error: Null pointer"
          WriteLog("DB: " + g_sDBError)
        EndIf
        
      EndIf
    Else
      g_sDBError = "DB_Query was not called before"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn sResult
EndProcedure


;Stores a row in the database. This is neccessary aafter setting the values of a row with DB_StoreAsLong(), DB_StoreAsQuad(), DB_StoreAsDouble(), DB_StoreAsString() and DB_StoreAsBlob().
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
;The function returns true for success.
Procedure.i DB_StoreRow(*Database.DATABASE)
  Protected iResult.i = #False
  g_sDBError = "failed"
  If *Database
    If *Database\bInQuery = #True
      
      If SQLite3_Step(*Database\pStmt) = #SQLITE_DONE
        If sqlite3_reset(*Database\pStmt) = #SQLITE_OK
          iResult = #True
          g_sDBError = ""
        EndIf
      EndIf
      
    Else
      g_sDBError = "DB_Query must be called before calling DB_StoreRow"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Stores an integer as long (32-bit). For the first column the parameter iColumn must be 0.
;Note: After setting all values of a row, DB_StoreRow() must be called to store it in the database
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
;The function returns true for success.
Procedure.i DB_StoreAsLong(*Database.DATABASE, iColumn.i, lValue.l)
  Protected iResult.i = #False
  g_sDBError = "failed"
  If *Database
    If *Database\bInQuery = #True
      
      If SQLite3_Bind_Int(*Database\pStmt, iColumn + 1, lValue) = #SQLITE_OK
        iResult = #True
        g_sDBError = ""
      EndIf
      
    Else
      g_sDBError = "DB_Query must be called before calling DB_StoreAsLong"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Stores an integer as quad (64-bit). For the first column the parameter iColumn must be 0.
;Note: After setting all values of a row, DB_StoreRow() must be called to store it in the database
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
;The function returns true for success.
Procedure.i DB_StoreAsQuad(*Database.DATABASE, iColumn.i, qValue.q)
  Protected iResult.i = #False
  g_sDBError = "failed"
  If *Database
    If *Database\bInQuery = #True
      
      If SQLite3_Bind_Int64(*Database\pStmt, iColumn + 1, qValue) = #SQLITE_OK
        iResult = #True
        g_sDBError = ""
      EndIf
      
    Else
      g_sDBError = "DB_Query must be called before calling DB_StoreAsQuad"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Stores a float point value as double. For the first column the parameter iColumn must be 0.
;Note: After setting all values of a row, DB_StoreRow() must be called to store it in the database
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
;The function returns true for success.
Procedure.i DB_StoreAsDouble(*Database.DATABASE, iColumn.i, dValue.d)
  Protected iResult.i = #False
  g_sDBError = "failed"
  If *Database
    If *Database\bInQuery = #True
      
      If SQLite3_Bind_Double(*Database\pStmt, iColumn + 1, dValue) = #SQLITE_OK
        iResult = #True
        g_sDBError = ""
      EndIf
      
    Else
      g_sDBError = "DB_Query must be called before calling DB_StoreAsDouble"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
  
EndProcedure


;Stores a string. For the first column the parameter iColumn must be 0.
;Note: After setting all values of a row, DB_StoreRow() must be called to store it in the database
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
;The function returns true for success.
Procedure.i DB_StoreAsString(*Database.DATABASE, iColumn.i, sText.s)
  Protected iResult.i = #False, *addr, iLen.i
  g_sDBError = "failed"
  If *Database
    If *Database\bInQuery = #True
      
      *addr = AllocateMemory(Len(sText)*3 + 4) ; *3 should be more than enought
      If *addr
        
        PokeS(*addr, sText, -1, #PB_UTF8)
        iLen.i = MemoryStringLength(*addr, #PB_UTF8)
        If SQLite3_Bind_Text(*Database\pStmt, iColumn + 1, *addr, iLen, #SQLITE_TRANSIENT) = #SQLITE_OK
          iResult = #True
          g_sDBError = ""
        Else
         g_sDBError = "Bind failed" 
        EndIf
        FreeMemory(*addr)
      Else
        g_sDBError = "can not allocate memory"
        WriteLog("DB: " + g_sDBError)
      EndIf
    Else
      g_sDBError = "DB_Query must be called before calling DB_StoreAsString"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
  
EndProcedure


;Stores a blob. For the first column the parameter iColumn must be 0. The parameter iFlags can be any combination of #DB_BLOB_COMPRESSED and DB_BLOB_ENCRYPTED Or just #DB_BLOB_DEFAULT for no compression And encryption.
;Please note if a blob is compressed and encrypted and later decrypted with the wrong key, the application will probably crash, as there is no check whether decrypted data is correct.
;Note: After setting all values of a row, DB_StoreRow() must be called to store it in the database
;Important: You cannot use DB_Store... commands and DB_GetAs... commands in the same DB_Query()... DB_EndQuery() block.
;The function returns true for success.
Procedure.i DB_StoreAsBlob(*Database.DATABASE, iColumn.i, *Pointer, iSize.i, iFlags.i = #DB_BLOB_DEFAULT)
  Protected iResult.i = #False, *Mem, *OldMem, iCompressedSize, iBlobSize
  g_sDBError = "failed"
  If *Database
    If *Database\bInQuery = #True
      
      If iFlags & #DB_BLOB_COMPRESSED And iFlags & #DB_BLOB_ENCRYPTED = #Null
        If __iDB_CompressBuffer(*Pointer, iSize, @*Mem, @iCompressedSize, *Database\iCompressionLevel)
          *OldMem = *Mem
          *Mem = __iDB_CopyMemAddHeader(*Mem, iCompressedSize, iFlags, iSize)
          If *Mem
            iBlobSize = iCompressedSize + SizeOf(BLOBHEADER)
          Else
            g_sDBError = "copy buffer failed"
            WriteLog("DB: " + g_sDBError)
          EndIf
          FreeMemory(*OldMem)
        Else
          ;try uncompressed
          iFlags = #Null
          ;g_sDBError = "DB_StoreAsBlob error: compressing buffer failed"
        EndIf
      EndIf
      
      If iFlags & #DB_BLOB_COMPRESSED And iFlags & #DB_BLOB_ENCRYPTED
        If __iDB_CompressBuffer(*Pointer, iSize, @*Mem, @iCompressedSize, *Database\iCompressionLevel)
          *OldMem = *Mem
          __iDB_EncryptBuffer(*Database, *Mem, iCompressedSize)
          *Mem = __iDB_CopyMemAddHeader(*Mem, iCompressedSize, iFlags, iSize)
          If *Mem
            iBlobSize = iCompressedSize + SizeOf(BLOBHEADER)
          Else
            g_sDBError = "copy buffer failed"
            WriteLog("DB: " + g_sDBError)
          EndIf
          FreeMemory(*OldMem)
        Else
          ;try uncompressed
          iFlags = #DB_BLOB_ENCRYPTED
          ;g_sDBError = "DB_StoreAsBlob error: compressing buffer failed"
        EndIf
      EndIf
      
      If iFlags & #DB_BLOB_COMPRESSED = #Null And iFlags & #DB_BLOB_ENCRYPTED
        *Mem = __iDB_CopyMemAddHeader(*Pointer, iSize, iFlags, iSize)
        If *Mem
          iBlobSize = iSize + SizeOf(BLOBHEADER)
          __iDB_EncryptBuffer(*Database, *Mem + SizeOf(BLOBHEADER), iSize)
        EndIf
      EndIf
      
      If iFlags & #DB_BLOB_COMPRESSED = #Null And iFlags & #DB_BLOB_ENCRYPTED = #Null
        *Mem = __iDB_CopyMemAddHeader(*Pointer, iSize, iFlags, iSize)
        If *Mem
          iBlobSize = iSize + SizeOf(BLOBHEADER)
        EndIf
      EndIf
      
      If *Mem And iBlobSize
        If SQLite3_Bind_Blob(*Database\pStmt, iColumn + 1, *Mem, iBlobSize, #SQLITE_TRANSIENT) = #SQLITE_OK
          iResult = #True
          g_sDBError = ""
        EndIf
        FreeMemory(*Mem)
      Else
        ;g_sDBError = "DB_StoreAsBlob error: allocating memory failed"
      EndIf
      
    Else
      g_sDBError = "DB_Query must be called before calling DB_StoreAsBlob"
      WriteLog("DB: " + g_sDBError)
    EndIf
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
  
EndProcedure


;Returns an error string for the last executed command.
Procedure.s DB_GetLastErrorString()
  ProcedureReturn g_sDBError
EndProcedure


;shows the result of the query in a window.
;The function returns true for success.
Procedure.i DB_ShowQuery(*Database.DATABASE, sStatement.s, iWidth.i = -1, iHeight = -1, sTitle.s = "")
Protected iResult.i = #False, iWindow.i, i, sType.s, iSize.i, iGadget.i, iRow.i, sLine.s
g_sDBError = "failed"
If iWidth <= 0:iWidth = 640:EndIf
If iHeight <= 0:iHeight = 240:EndIf
If sTitle = "":sTitle = sStatement:EndIf

If DB_Query(*Database.DATABASE, sStatement.s)

  iWindow = OpenWindow(#PB_Any, 0, 0, iWidth, iHeight, sTitle, #PB_Window_SystemMenu | #PB_Window_MinimizeGadget| #PB_Window_ScreenCentered)
  If iWindow
    DB_SelectRow(*Database, 0)
    
    If DB_GetNumColumns(*Database) > 0
    
      Dim ShowQuery_ColumnSize(DB_GetNumColumns(*Database) - 1)
      For i = 0 To DB_GetNumColumns(*Database) - 1
        sType.s = UCase(DB_GetColumnTypeAsString(*Database, i))
        
        iSize = 50
        If FindString(sType, "FLOAT",1)
          iSize = 75
        EndIf
        If FindString(sType, "VARCHAR",1)
          iSize = 100
        EndIf
        If FindString(sType, "BLOB",1)
          iSize = 55
        EndIf
        ShowQuery_ColumnSize(i) = iSize
      Next  
      iGadget = ListIconGadget(#PB_Any,  0,  0, iWidth, iHeight, DB_GetColumnName(*Database, 0), ShowQuery_ColumnSize(0), #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_GridLines)
      For i = 1 To DB_GetNumColumns(*Database) - 1
        AddGadgetColumn(iGadget, i, DB_GetColumnName(*Database, i), ShowQuery_ColumnSize(i))
      Next
        
      iRow = 0
      While DB_SelectRow(*Database, iRow)
        sLine.s = ""
        For i = 0 To DB_GetNumColumns(*Database) - 1
          If ShowQuery_ColumnSize(i) <> 55
            sLine + RemoveString(DB_GetAsString(*Database, i), Chr(10)) + Chr(10)
          Else
            sLine + "[BLOB]" + Chr(10)
          EndIf
        Next
        sLine = Left(sLine, Len(sLine)-1)
          
        AddGadgetItem(iGadget, -1, sLine)
        iRow + 1
      Wend
        
    Else
      iGadget = ListIconGadget(#PB_Any,  0,  0, iWidth, iHeight, "", 50, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_GridLines)
    EndIf
    
    Repeat
    Until WaitWindowEvent() = #PB_Event_CloseWindow And EventWindow() = iWindow
    CloseWindow(iWindow)
    g_sDBError = ""
    iResult = #True
  Else
    g_sDBError = "Cannot open window"
    WriteLog("DB: " + g_sDBError)
  EndIf
  DB_EndQuery(*Database)
EndIf
ProcedureReturn iResult
EndProcedure


;Sets the key to decrypt/encrypt blobs
;The function returns true for success.
Procedure.i DB_SetCryptionKey(*Database.DATABASE, sKey.s)
  Protected iResult = #False, sMD5.s
  g_sDBError = ""
  If *Database
    sMD5.s = MD5Fingerprint(@sKey, Len(sKey))
    *Database\qEncryptionKey = Val("$" + sMD5)
    g_sDBError = ""
    iResult = #True
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Sets the compression level for compressed blobs. The value can be between 0 and 9
;The function returns true for success.
Procedure.i DB_SetCompressionLevel(*Database.DATABASE, iCompressionLevel.i = 9)
  Protected iResult = #False
  g_sDBError = ""
  If *Database
    *Database\iCompressionLevel = iCompressionLevel
    g_sDBError = ""
    iResult = #True
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
EndProcedure


;Makes sure that all changes are committed, if DB_Update() is used.
;The function returns true for success.
Procedure.i DB_Flush(*Database.DATABASE)
  g_sDBError = "failed"
  Protected iResult.i = #False
  If *Database
    
    ;If DB_Flush() was called before...
    If *Database\bAsyncUpdate = #True
      DatabaseUpdate(*Database\iDatabase, "COMMIT")
      *Database\bAsyncUpdate = #False
    EndIf
    
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Cleans the database.
;When an object is dropped from the database, it leaves behind empty space. This empty space will be reused the next time new information is added to the database. But in the meantime, the database file might be larger than strictly necessary.
;The function returns true for success.
Procedure.i DB_Clear(*Database.DATABASE)
  g_sDBError = "failed"
  Protected iResult.i = #False
  If *Database
    DatabaseUpdate(*Database\iDatabase, "VACUUM")
    g_sDBError = ""
    iResult.i = #True
  Else
    g_sDBError = "no valid database handle declared"
    WriteLog("DB: " + g_sDBError)
  EndIf
  ProcedureReturn iResult
EndProcedure


;Returns the SQlite verion as string.
Procedure.s DB_GetSQLiteVersion()
  Protected *ptr = sqlite3_libversion(), sResult.s
  If *ptr
    sResult.s = PeekS(*ptr, -1, #PB_UTF8)
  Else
    sResult.s = "unknown"
  EndIf
  ProcedureReturn sResult
EndProcedure










; IDE Options = PureBasic 5.21 LTS Beta 1 (Windows - x86)
; CursorPosition = 276
; FirstLine = 136
; Folding = gffAAQI-
; EnableThread
; EnableXP
; EnableUser
; EnableOnError
; Executable = ..\test.exe
; EnableCompileCount = 34
; EnableBuildCount = 0
; EnableExeConstant