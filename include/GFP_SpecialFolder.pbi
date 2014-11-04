;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

Procedure.s GetSpecialFolder(ifolder.i)
  Protected *itemid.ITEMIDLIST, slocation.s
  *itemid.ITEMIDLIST = #Null
  If SHGetSpecialFolderLocation_(0, ifolder, @*itemid) = #NOERROR
    slocation.s = Space(#MAX_PATH)
    If SHGetPathFromIDList_(*itemid, @slocation)
        ProcedureReturn slocation
    EndIf
  EndIf
EndProcedure


;{ Example
;   Debug GetSpecialFolder(#CSIDL_MYPICTURES)
;   End
;}



; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = 0
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant