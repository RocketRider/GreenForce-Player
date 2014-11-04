;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************
EnableExplicit

;CREATE TABLE DESIGN (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Name VARCHAR(500), Buttons INTEGER, Buttonstates INTEGER, BK_Color INTEGER, Trackbar INTEGER, Volume INTEGER, Container_Border INTEGER, Container_Size INTEGER, Unique_ID VARCHAR(500) UNIQUE, Image BLOB)
;CREATE TABLE DESIGN_DATA (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Design_id INTEGER, Name VARCHAR(500), Image INTEGER, Data BLOB)
;CREATE TABLE DESIGN_CONTROLS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Design_id INTEGER, Control INTEGER, x INTEGER, y INTEGER, Width INTEGER, Height INTEGER, Aligment INTEGER)
;Aligment=0 => Linksbündig
;Aligment=1 => Rechtsbündig
;Aligment=2 => Zentriert

Global Design_ID.i, Design_Name.s, Design_Buttons.i, Design_Buttonstates.i, Design_BK_Color.i, Design_Trackbar.i, Design_Volume.i, Design_Container_Border.i, Design_Container_Size.i, Design_Unique_ID.s


Structure Design_Position
  X.i
  Y.i
  W.i
  H.i
  Aligment.i
EndStructure  
Global Dim Design_Positions.Design_Position(#GADGET_LAST)
; Procedure LoadPlayerSkin()
;   If Val(Settings(#SETTINGS_ICONSET)\sValue)=0
;     CatchImage(#SPRITE_BACKWARD, ?DS_GREEN_Backward)
;     CatchImage(#SPRITE_FORWARD, ?DS_GREEN_Forward)
;     CatchImage(#SPRITE_PLAY, ?DS_GREEN_Play)
;     CatchImage(#SPRITE_PREVIOUS, ?DS_GREEN_Previous)
;     CatchImage(#SPRITE_STOP, ?DS_GREEN_Stop)
;     CatchImage(#SPRITE_NEXT, ?DS_GREEN_Next)
;     CatchImage(#SPRITE_SNAPSHOT, ?DS_GREEN_Snapshot)
;     CatchImage(#SPRITE_SNAPSHOT_DISABLED, ?DS_GREEN_snapshot_disabled)
;     CatchImage(#SPRITE_REPEAT, ?DS_GREEN_repeat)
;     CatchImage(#SPRITE_RANDOM, ?DS_GREEN_random)
;     CatchImage(#SPRITE_BREAK, ?DS_GREEN_Break)
;     CatchImage(#SPRITE_EJECT, ?DS_GREEN_eject)
;     CatchImage(#SPRITE_CDDRIVE_BLUE, ?DS_GREEN_cddrive_blue)  
;     
;     CatchImage(#SPRITE_BACKWARD_HOVER, ?DS_GREEN_Backward_hover)
;     CatchImage(#SPRITE_FORWARD_HOVER, ?DS_GREEN_Forward_hover)
;     CatchImage(#SPRITE_PLAY_HOVER, ?DS_GREEN_Play_hover)
;     CatchImage(#SPRITE_PREVIOUS_HOVER, ?DS_GREEN_Previous_hover)
;     CatchImage(#SPRITE_STOP_HOVER, ?DS_GREEN_Stop_hover)
;     CatchImage(#SPRITE_NEXT_HOVER, ?DS_GREEN_Next_hover)
;     CatchImage(#SPRITE_SNAPSHOT_HOVER, ?DS_GREEN_Snapshot_hover)
;     CatchImage(#SPRITE_REPEAT_HOVER, ?DS_GREEN_repeat_hover)
;     CatchImage(#SPRITE_RANDOM_HOVER, ?DS_GREEN_random_hover)
;     CatchImage(#SPRITE_BREAK_HOVER, ?DS_GREEN_Break_hover)
;     CatchImage(#SPRITE_EJECT_HOVER, ?DS_GREEN_eject_hover)
;     CatchImage(#SPRITE_CDDRIVE_BLUE_HOVER, ?DS_GREEN_cddrive_blue_hover)  
;     
;     CatchImage(#SPRITE_BACKWARD_CLICK, ?DS_GREEN_backward_clicked)
;     CatchImage(#SPRITE_FORWARD_CLICK, ?DS_GREEN_Forward_clicked)
;     CatchImage(#SPRITE_PLAY_CLICK, ?DS_GREEN_Play_clicked)
;     CatchImage(#SPRITE_PREVIOUS_CLICK, ?DS_GREEN_Previous_clicked)
;     CatchImage(#SPRITE_STOP_CLICK, ?DS_GREEN_Stop_clicked)
;     CatchImage(#SPRITE_NEXT_CLICK, ?DS_GREEN_Next_clicked)
;     CatchImage(#SPRITE_SNAPSHOT_CLICK, ?DS_GREEN_Snapshot_clicked)
;     CatchImage(#SPRITE_REPEAT_CLICK, ?DS_GREEN_repeat_clicked)
;     CatchImage(#SPRITE_RANDOM_CLICK, ?DS_GREEN_random_clicked)
;     CatchImage(#SPRITE_BREAK_CLICK, ?DS_GREEN_Break_clicked)
;     CatchImage(#SPRITE_EJECT_CLICK, ?DS_GREEN_eject_clicked)
;     CatchImage(#SPRITE_CDDRIVE_BLUE_CLICK, ?DS_GREEN_cddrive_blue_clicked)  
;   EndIf
;   
;   If Val(Settings(#SETTINGS_ICONSET)\sValue)=1
;     CatchImage(#SPRITE_BACKWARD, ?DS_Backward)
;     CatchImage(#SPRITE_FORWARD, ?DS_Forward)
;     CatchImage(#SPRITE_PLAY, ?DS_Play)
;     CatchImage(#SPRITE_PREVIOUS, ?DS_Previous)
;     CatchImage(#SPRITE_STOP, ?DS_Stop)
;     CatchImage(#SPRITE_NEXT, ?DS_Next)
;     CatchImage(#SPRITE_SNAPSHOT, ?DS_Snapshot)
;     CatchImage(#SPRITE_REPEAT, ?DS_repeat)
;     CatchImage(#SPRITE_RANDOM, ?DS_random)
;     CatchImage(#SPRITE_BREAK, ?DS_Break)
;     CatchImage(#SPRITE_EJECT, ?DS_eject)
;     CatchImage(#SPRITE_CDDRIVE_BLUE, ?DS_cddrive_blue)  
;   EndIf
;   
;   If Val(Settings(#SETTINGS_ICONSET)\sValue)=2
;     CatchImage(#SPRITE_BACKWARD, ?DS_BLACK_Backward)
;     CatchImage(#SPRITE_FORWARD, ?DS_BLACK_Forward)
;     CatchImage(#SPRITE_PLAY, ?DS_BLACK_Play)
;     CatchImage(#SPRITE_PREVIOUS, ?DS_BLACK_Previous)
;     CatchImage(#SPRITE_STOP, ?DS_BLACK_Stop)
;     CatchImage(#SPRITE_NEXT, ?DS_BLACK_Next)
;     CatchImage(#SPRITE_SNAPSHOT, ?DS_BLACK_Snapshot)
;     CatchImage(#SPRITE_SNAPSHOT_DISABLED, ?DS_BLACK_snapshot_disabled)
;     CatchImage(#SPRITE_REPEAT, ?DS_BLACK_repeat)
;     CatchImage(#SPRITE_RANDOM, ?DS_BLACK_random)
;     CatchImage(#SPRITE_BREAK, ?DS_BLACK_Break)
;     CatchImage(#SPRITE_EJECT, ?DS_BLACK_eject)
;     CatchImage(#SPRITE_CDDRIVE_BLUE, ?DS_BLACK_cddrive_blue)  
;     
;     CatchImage(#SPRITE_BACKWARD_HOVER, ?DS_BLACK_Backward_hover)
;     CatchImage(#SPRITE_FORWARD_HOVER, ?DS_BLACK_Forward_hover)
;     CatchImage(#SPRITE_PLAY_HOVER, ?DS_BLACK_Play_hover)
;     CatchImage(#SPRITE_PREVIOUS_HOVER, ?DS_BLACK_Previous_hover)
;     CatchImage(#SPRITE_STOP_HOVER, ?DS_BLACK_Stop_hover)
;     CatchImage(#SPRITE_NEXT_HOVER, ?DS_BLACK_Next_hover)
;     CatchImage(#SPRITE_SNAPSHOT_HOVER, ?DS_BLACK_Snapshot_hover)
;     CatchImage(#SPRITE_REPEAT_HOVER, ?DS_BLACK_repeat_hover)
;     CatchImage(#SPRITE_RANDOM_HOVER, ?DS_BLACK_random_hover)
;     CatchImage(#SPRITE_BREAK_HOVER, ?DS_BLACK_Break_hover)
;     CatchImage(#SPRITE_EJECT_HOVER, ?DS_BLACK_eject_hover)
;     CatchImage(#SPRITE_CDDRIVE_BLUE_HOVER, ?DS_BLACK_cddrive_blue_hover)  
;     
;     CatchImage(#SPRITE_BACKWARD_CLICK, ?DS_BLACK_backward_clicked)
;     CatchImage(#SPRITE_FORWARD_CLICK, ?DS_BLACK_Forward_clicked)
;     CatchImage(#SPRITE_PLAY_CLICK, ?DS_BLACK_Play_clicked)
;     CatchImage(#SPRITE_PREVIOUS_CLICK, ?DS_BLACK_Previous_clicked)
;     CatchImage(#SPRITE_STOP_CLICK, ?DS_BLACK_Stop_clicked)
;     CatchImage(#SPRITE_NEXT_CLICK, ?DS_BLACK_Next_clicked)
;     CatchImage(#SPRITE_SNAPSHOT_CLICK, ?DS_BLACK_Snapshot_clicked)
;     CatchImage(#SPRITE_REPEAT_CLICK, ?DS_BLACK_repeat_clicked)
;     CatchImage(#SPRITE_RANDOM_CLICK, ?DS_BLACK_random_clicked)
;     CatchImage(#SPRITE_BREAK_CLICK, ?DS_BLACK_Break_clicked)
;     CatchImage(#SPRITE_EJECT_CLICK, ?DS_BLACK_eject_clicked)
;     CatchImage(#SPRITE_CDDRIVE_BLUE_CLICK, ?DS_BLACK_cddrive_blue_clicked)  
;     
;     CatchImage(#SPRITE_REPEAT_CLICK_HOVER, ?DS_BLACK_repeat_clicked_hover)
;     CatchImage(#SPRITE_RANDOM_CLICK_HOVER, ?DS_BLACK_random_clicked_hover)
;   EndIf
;   
;   If Val(Settings(#SETTINGS_ICONSET)\sValue)=3
;     
;     CatchImage(#SPRITE_BACKWARD, ?DS_GRAY_Backward)
;     CatchImage(#SPRITE_FORWARD, ?DS_GRAY_Forward)
;     CatchImage(#SPRITE_PLAY, ?DS_GRAY_Play)
;     CatchImage(#SPRITE_PREVIOUS, ?DS_GRAY_Previous)
;     CatchImage(#SPRITE_STOP, ?DS_GRAY_Stop)
;     CatchImage(#SPRITE_NEXT, ?DS_GRAY_Next)
;     CatchImage(#SPRITE_SNAPSHOT, ?DS_GRAY_Snapshot)
;     CatchImage(#SPRITE_SNAPSHOT_DISABLED, ?DS_GRAY_snapshot_disabled)
;     CatchImage(#SPRITE_REPEAT, ?DS_GRAY_repeat)
;     CatchImage(#SPRITE_RANDOM, ?DS_GRAY_random)
;     CatchImage(#SPRITE_BREAK, ?DS_GRAY_Break)
;     CatchImage(#SPRITE_EJECT, ?DS_GRAY_eject)
;     CatchImage(#SPRITE_CDDRIVE_BLUE, ?DS_GRAY_cddrive_blue)  
;     
;     CatchImage(#SPRITE_BACKWARD_HOVER, ?DS_GRAY_Backward_hover)
;     CatchImage(#SPRITE_FORWARD_HOVER, ?DS_GRAY_Forward_hover)
;     CatchImage(#SPRITE_PLAY_HOVER, ?DS_GRAY_Play_hover)
;     CatchImage(#SPRITE_PREVIOUS_HOVER, ?DS_GRAY_Previous_hover)
;     CatchImage(#SPRITE_STOP_HOVER, ?DS_GRAY_Stop_hover)
;     CatchImage(#SPRITE_NEXT_HOVER, ?DS_GRAY_Next_hover)
;     CatchImage(#SPRITE_SNAPSHOT_HOVER, ?DS_GRAY_Snapshot_hover)
;     CatchImage(#SPRITE_REPEAT_HOVER, ?DS_GRAY_repeat_hover)
;     CatchImage(#SPRITE_RANDOM_HOVER, ?DS_GRAY_random_hover)
;     CatchImage(#SPRITE_BREAK_HOVER, ?DS_GRAY_Break_hover)
;     CatchImage(#SPRITE_EJECT_HOVER, ?DS_GRAY_eject_hover)
;     CatchImage(#SPRITE_CDDRIVE_BLUE_HOVER, ?DS_GRAY_cddrive_blue_hover)  
;     
;     CatchImage(#SPRITE_BACKWARD_CLICK, ?DS_GRAY_backward_clicked)
;     CatchImage(#SPRITE_FORWARD_CLICK, ?DS_GRAY_Forward_clicked)
;     CatchImage(#SPRITE_PLAY_CLICK, ?DS_GRAY_Play_clicked)
;     CatchImage(#SPRITE_PREVIOUS_CLICK, ?DS_GRAY_Previous_clicked)
;     CatchImage(#SPRITE_STOP_CLICK, ?DS_GRAY_Stop_clicked)
;     CatchImage(#SPRITE_NEXT_CLICK, ?DS_GRAY_Next_clicked)
;     CatchImage(#SPRITE_SNAPSHOT_CLICK, ?DS_GRAY_Snapshot_clicked)
;     CatchImage(#SPRITE_REPEAT_CLICK, ?DS_GRAY_repeat_clicked)
;     CatchImage(#SPRITE_RANDOM_CLICK, ?DS_GRAY_random_clicked)
;     CatchImage(#SPRITE_BREAK_CLICK, ?DS_GRAY_Break_clicked)
;     CatchImage(#SPRITE_EJECT_CLICK, ?DS_GRAY_eject_clicked)
;     CatchImage(#SPRITE_CDDRIVE_BLUE_CLICK, ?DS_GRAY_cddrive_blue_clicked)  
;     
;     CatchImage(#SPRITE_REPEAT_CLICK_HOVER, ?DS_GRAY_repeat_clicked_hover)
;     CatchImage(#SPRITE_RANDOM_CLICK_HOVER, ?DS_GRAY_random_clicked_hover)
;   EndIf
;   
;   If Val(Settings(#SETTINGS_ICONSET)\sValue)=2
;     CatchImage(#SPRITE_TRACKBAR_LEFT, ?DS_trackbar_black_left)
;     CatchImage(#SPRITE_TRACKBAR_RIGHT, ?DS_trackbar_black_right)
;     CatchImage(#SPRITE_TRACKBAR_MIDDLE, ?DS_trackbar_black_middle)
;     CatchImage(#SPRITE_TRACKBAR_THUMB, ?DS_trackbar_black_thumb) 
;     CatchImage(#SPRITE_TRACKBAR_THUMB_DISABLED, ?DS_trackbar_black_disabled) 
;     CatchImage(#SPRITE_TRACKBAR_THUMB_SELECTED, ?DS_trackbar_black_selected) 
;   Else
;     CatchImage(#SPRITE_TRACKBAR_LEFT, ?DS_trackbar_gray_left)
;     CatchImage(#SPRITE_TRACKBAR_RIGHT, ?DS_trackbar_gray_right)
;     CatchImage(#SPRITE_TRACKBAR_MIDDLE, ?DS_trackbar_gray_middle)
;     CatchImage(#SPRITE_TRACKBAR_THUMB, ?DS_trackbar_gray_thumb) 
;     CatchImage(#SPRITE_TRACKBAR_THUMB_DISABLED, ?DS_trackbar_gray_disabled) 
;     CatchImage(#SPRITE_TRACKBAR_THUMB_SELECTED, ?DS_trackbar_gray_selected) 
;   EndIf
;   
; EndProcedure



Procedure LoadPlayerDesign(sDBFile.s)
  Protected *DesignDB, iRow.i, Image.i, *ImgPtr, Control.i, i.i
  *DesignDB = DB_Open(sDBFile)

  
  For i=0 To #GADGET_LAST-1
    Design_Positions(i)\X=-1
    Design_Positions(i)\Y=-1
    Design_Positions(i)\W=-1
    Design_Positions(i)\H=-1
  Next  
  
  If *DesignDB
    Design_ID=Val(Settings(#SETTINGS_ICONSET)\sValue)
    If DB_Query(*DesignDB, "SELECT * FROM DESIGN WHERE id='"+Str(Design_ID)+"'")
      DB_SelectRow(*DesignDB, 0)
      Design_Name = DB_GetAsString(*DesignDB, 1)
      Design_Buttons = DB_GetAsLong(*DesignDB, 2)
      Design_Buttonstates = DB_GetAsLong(*DesignDB, 3)
      Design_BK_Color = DB_GetAsLong(*DesignDB, 4)
      Design_Trackbar = DB_GetAsLong(*DesignDB, 5)
      Design_Volume = DB_GetAsLong(*DesignDB, 6)
      Design_Container_Border = DB_GetAsLong(*DesignDB, 7)
      Design_Container_Size = DB_GetAsLong(*DesignDB, 8)
      Design_Unique_ID = DB_GetAsString(*DesignDB, 9)
    EndIf  
    DB_EndQuery(*DesignDB)
    
    If DB_Query(*DesignDB, "SELECT * FROM DESIGN_DATA WHERE Design_id='"+Str(Design_ID)+"'")
      iRow = 0
      While DB_SelectRow(*DesignDB, iRow)
        Image = DB_GetAsLong(*DesignDB, 3)
        If Image>0
          *ImgPtr = DB_GetAsBlobPointer(*DesignDB, 4)
          If *ImgPtr
            If CatchImage(Image, *ImgPtr)=0
              WriteLog("Corrupt Image "+Str(Image))
            EndIf  
            
            FreeMemory(*ImgPtr)
          Else
            WriteLog("No Image "+Str(Image))
          EndIf
        EndIf  
        iRow=iRow+1
      Wend
    EndIf  
    DB_EndQuery(*DesignDB)    
      
      
    If DB_Query(*DesignDB, "SELECT * FROM DESIGN_CONTROLS WHERE Design_id='"+Str(Design_ID)+"'")
      iRow = 0
      While DB_SelectRow(*DesignDB, iRow)
        Control = DB_GetAsLong(*DesignDB, 2)
        Design_Positions(Control)\X = DB_GetAsLong(*DesignDB, 3)
        Design_Positions(Control)\Y = DB_GetAsLong(*DesignDB, 4)
        Design_Positions(Control)\W = DB_GetAsLong(*DesignDB, 5)
        Design_Positions(Control)\H = DB_GetAsLong(*DesignDB, 6)
        Design_Positions(Control)\Aligment = DB_GetAsLong(*DesignDB, 7)
        iRow=iRow+1
      Wend
    EndIf  
    DB_EndQuery(*DesignDB) 
      
    DB_Close(*DesignDB)
  Else
    WriteLog("Can't load Database!")
  EndIf
  
  
  If IsImage(#SPRITE_FULLSCREEN)=0:CatchImage(#SPRITE_FULLSCREEN, ?DS_error):EndIf
  If IsImage(#SPRITE_BACKWARD)=0:CatchImage(#SPRITE_BACKWARD, ?DS_error):EndIf
  If IsImage(#SPRITE_FORWARD)=0:CatchImage(#SPRITE_FORWARD, ?DS_error):EndIf
  If IsImage(#SPRITE_PLAY)=0:CatchImage(#SPRITE_PLAY, ?DS_error):EndIf
  If IsImage(#SPRITE_PREVIOUS)=0:CatchImage(#SPRITE_PREVIOUS, ?DS_error):EndIf
  If IsImage(#SPRITE_STOP)=0:CatchImage(#SPRITE_STOP, ?DS_error):EndIf
  If IsImage(#SPRITE_NEXT)=0:CatchImage(#SPRITE_NEXT, ?DS_error):EndIf
  If IsImage(#SPRITE_SNAPSHOT)=0:CatchImage(#SPRITE_SNAPSHOT, ?DS_error):EndIf
  If IsImage(#SPRITE_REPEAT)=0:CatchImage(#SPRITE_REPEAT, ?DS_error):EndIf
  If IsImage(#SPRITE_RANDOM)=0:CatchImage(#SPRITE_RANDOM, ?DS_error):EndIf
  If IsImage(#SPRITE_MENU_SOUND)=0:CatchImage(#SPRITE_MENU_SOUND, ?DS_error):EndIf
  If IsImage(#SPRITE_EJECT)=0:CatchImage(#SPRITE_EJECT, ?DS_error):EndIf
  If IsImage(#SPRITE_CDDRIVE_BLUE)=0:CatchImage(#SPRITE_CDDRIVE_BLUE, ?DS_error):EndIf
  
EndProcedure  

Procedure.s GetPlayerDesigns(sDBFile.s)
  Protected *DesignDB, iRow.i, Out.s
  *DesignDB = DB_Open(sDBFile)
  
  If *DesignDB
    If DB_Query(*DesignDB, "SELECT * FROM DESIGN")
      iRow = 0
      While DB_SelectRow(*DesignDB, iRow)
        Out = Out + DB_GetAsString(*DesignDB, 1)+Chr(10)
        iRow=iRow+1
      Wend
    EndIf  
    DB_EndQuery(*DesignDB)
    
      
    DB_Close(*DesignDB)
  Else
    WriteLog("Can't load Database!")
  EndIf
  ProcedureReturn Out
EndProcedure  


Procedure DControlX(Control.i)
  If Design_Positions(Control)\X<0
    ProcedureReturn 0
  EndIf  
  If Design_Positions(Control)\Aligment=0
    ProcedureReturn Design_Positions(Control)\X
  EndIf
  If Design_Positions(Control)\Aligment=1
    ProcedureReturn GadgetWidth(#GADGET_CONTAINER)-Design_Positions(Control)\X
  EndIf
  If Design_Positions(Control)\Aligment=2
    ProcedureReturn Design_Positions(Control)\X
  EndIf
  ProcedureReturn Design_Positions(Control)\X
EndProcedure  
Procedure DControlY(Control.i)
  If Design_Positions(Control)\Y<0
    ProcedureReturn 0
  EndIf  
  ProcedureReturn Design_Positions(Control)\Y
EndProcedure  
Procedure DControlW(Control.i)
  If Design_Positions(Control)\W<0
    ProcedureReturn 0
  EndIf  
  If Design_Positions(Control)\Aligment=2
    ProcedureReturn GadgetWidth(#GADGET_CONTAINER)-Design_Positions(Control)\W
  EndIf
  ProcedureReturn Design_Positions(Control)\W  
EndProcedure  
Procedure DControlH(Control.i)
  If Design_Positions(Control)\H<0
    ProcedureReturn 0
  EndIf  
  ProcedureReturn Design_Positions(Control)\H
EndProcedure  
Procedure DControlHide(Control.i)
  If Design_Positions(Control)\X=-1
    ProcedureReturn 1
  EndIf  
  ProcedureReturn 0
EndProcedure


Procedure.s GenerateDesignID()
  Protected i.i, s.s=""
  For i=0 To 19
    If Random(100)>50  
      s=s+Str(Random(9))
    Else
      s=s+Chr(65+Random(25))
    EndIf  
  Next
  ProcedureReturn s
EndProcedure  


Procedure InstallDesign(*DB, *NewDesignDB, UID.s)
  Protected ID.i, *Img, iRow.i, NewID.i
  ProcessAllEvents()
  WriteLog("Install Design: "+UID)
  If DB_Query(*NewDesignDB, "SELECT * FROM DESIGN WHERE Unique_ID='"+UID+"'")
    DB_SelectRow(*NewDesignDB, 0)
    ID.i=DB_GetAsLong(*NewDesignDB, 0)
    If ID>0
      
      If DB_Query(*DB,"INSERT INTO DESIGN (Name, Buttons, Buttonstates, BK_Color, Trackbar, Volume, Container_Border, Container_Size, Unique_ID, Image) VALUES (?,?,?,?,?,?,?,?,?,?)")
        DB_StoreAsString(*DB,0, DB_GetAsString(*NewDesignDB, 1))
        DB_StoreAsLong(*DB,1, DB_GetAsLong(*NewDesignDB, 2))
        DB_StoreAsLong(*DB,2, DB_GetAsLong(*NewDesignDB, 3))
        DB_StoreAsLong(*DB,3, DB_GetAsLong(*NewDesignDB, 4))
        DB_StoreAsLong(*DB,4, DB_GetAsLong(*NewDesignDB, 5))
        DB_StoreAsLong(*DB,5, DB_GetAsLong(*NewDesignDB, 6))
        DB_StoreAsLong(*DB,6, DB_GetAsLong(*NewDesignDB, 7))
        DB_StoreAsLong(*DB,7, DB_GetAsLong(*NewDesignDB, 8))
        DB_StoreAsString(*DB,8, DB_GetAsString(*NewDesignDB, 9))
        *Img=DB_GetAsBlobPointer(*NewDesignDB, 10)
        DB_StoreAsBlob(*DB, 9, *Img, DB_GetAsBlobSize(*NewDesignDB, 10), #DB_BLOB_DEFAULT)
        FreeMemory(*Img)
        DB_StoreRow(*DB)
      EndIf
      DB_EndQuery(*DB)
      
      If DB_Query(*DB, "SELECT * FROM DESIGN WHERE Unique_ID='"+UID+"'")
        DB_SelectRow(*DB, 0)
        NewID.i=DB_GetAsLong(*DB, 0)
        WriteLog("ID:"+Str(ID)+", new ID:"+Str(NewID))
      EndIf
      DB_EndQuery(*DB)
      
    EndIf  
  EndIf  
  DB_EndQuery(*NewDesignDB)
  If ID>0 And NewID>0
    If DB_Query(*NewDesignDB, "SELECT * FROM DESIGN_CONTROLS WHERE Design_id='"+Str(ID)+"'")
      iRow = 0
      While DB_SelectRow(*NewDesignDB, iRow)
        DB_GetAsLong(*NewDesignDB, 1)
        DB_Update(*DB, "INSERT INTO DESIGN_CONTROLS (Design_id, Control, x, y, Width, Height, Aligment) VALUES ('"+Str(NewID)+"', '"+Str(DB_GetAsLong(*NewDesignDB, 2))+"', '"+Str(DB_GetAsLong(*NewDesignDB, 3))+"', '"+Str(DB_GetAsLong(*NewDesignDB, 4))+"', '"+Str(DB_GetAsLong(*NewDesignDB, 5))+"', '"+Str(DB_GetAsLong(*NewDesignDB, 6))+"', '"+Str(DB_GetAsLong(*NewDesignDB, 7))+"')") 
        iRow=iRow+1
      Wend
    EndIf  
    DB_EndQuery(*NewDesignDB)
    
    If DB_Query(*NewDesignDB, "SELECT * FROM DESIGN_DATA WHERE Design_id='"+Str(ID)+"'")
      iRow = 0
      While DB_SelectRow(*NewDesignDB, iRow)
        ProcessAllEvents()
        
        If DB_Query(*DB,"INSERT INTO DESIGN_DATA (Design_id, Name, Image, Data) VALUES (?,?,?,?)")
          DB_StoreAsLong(*DB,0, NewID)
          DB_StoreAsString(*DB,1, DB_GetAsString(*NewDesignDB, 2))
          DB_StoreAsLong(*DB,2, DB_GetAsLong(*NewDesignDB, 3))
          *Img=DB_GetAsBlobPointer(*NewDesignDB, 4)
          DB_StoreAsBlob(*DB, 3, *Img, DB_GetAsBlobSize(*NewDesignDB, 4), #DB_BLOB_DEFAULT)
          FreeMemory(*Img)
          DB_StoreRow(*DB)
        EndIf
        DB_EndQuery(*DB)        
        
        
        iRow=iRow+1
      Wend
    EndIf
    DB_EndQuery(*NewDesignDB)
    
    
  Else
    WriteLog("Can't find ID to UID("+UID+")!")
  EndIf  
  
EndProcedure  

Procedure InstallDesigns(*DB, *NewDesignDB)
  Protected iRow.i, NewList InstallDesignList.s(),DesignID.i,DesignUID.s
  If *DB And *NewDesignDB
    
    If DB_Query(*NewDesignDB, "SELECT * FROM DESIGN")
      iRow = 0
      While DB_SelectRow(*NewDesignDB, iRow)
        AddElement(InstallDesignList())
        InstallDesignList()=DB_GetAsString(*NewDesignDB, 9)
        iRow=iRow+1
      Wend
    EndIf  
    DB_EndQuery(*NewDesignDB)
    
    If DB_Query(*DB, "SELECT * FROM DESIGN")
      iRow = 0
      While DB_SelectRow(*DB, iRow)
        DesignUID.s=DB_GetAsString(*DB, 9)
        ForEach InstallDesignList()
          If InstallDesignList()=DesignUID
            DeleteElement(InstallDesignList())
            Break
          EndIf  
        Next
        iRow=iRow+1
      Wend
    EndIf  
    DB_EndQuery(*DB)    
    
    ForEach InstallDesignList()
      InstallDesign(*DB, *NewDesignDB, InstallDesignList())
    Next
    
  EndIf
EndProcedure  


; IDE Options = PureBasic 5.21 LTS Beta 1 (Windows - x86)
; CursorPosition = 340
; FirstLine = 289
; Folding = --
; EnableXP