;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit



Structure MYLIST
  *entries
  size.i
  invalidvalue.i
EndStructure


Procedure MYLIST_Add(*list.MYLIST, *objPtr)
  Protected iIndex.i, *ptr.integer
  If *list  
    
    If *list\entries = #Null
      *list\entries = AllocateMemory(SizeOf(Integer))
      *list\size = 1
    EndIf
    *ptr.integer = *list\entries   
    
    If *ptr = #Null
      ProcedureReturn #False
    EndIf
    
    For iIndex = 0 To *list\size - 1
      If *ptr\i =*list\invalidvalue
        *ptr\i = *objPtr
        ProcedureReturn #True
      EndIf
      *ptr + SizeOf(Integer)
    Next
       
    *ptr.integer = ReAllocateMemory(*list\entries, (*list\size + 1) * SizeOf(Integer))
    If *ptr
      *list\entries  = *ptr
      *ptr + (*list\size) * SizeOf(Integer)
      *ptr\i = *objPtr
      *list\size + 1
      ProcedureReturn #True
    EndIf
    
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure MYLIST_Remove(*list.MYLIST, *objPtr)
  Protected iIndex.i, *ptr.integer  
  If *list  
    *ptr.integer = *list\entries
    If *ptr
      For iIndex = 0 To *list\size - 1
        If *ptr\i = *objPtr
          *ptr\i = *list\invalidvalue
          ProcedureReturn #True
        EndIf
        *ptr + SizeOf(Integer)
      Next
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure MYLIST_Delete(*list.MYLIST)
  Protected *ptr.integer
  If *list  
    *ptr.integer = *list\entries
    *list\size = 0
    *list\invalidvalue = #Null
    If *ptr
      FreeMemory(*List\entries)
      *list\entries = #Null
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure



; L.MYLIST
; 
; MYLIST_Add(@L, 1)
; MYLIST_Add(@L, 2)
; MYLIST_Add(@L, 3)
; MYLIST_Add(@L, 4)
; 
; MYLIST_Remove(@L,4)
; 
; Debug L\size
; 
; For I=0 To L\size-1
;   Debug PeekL(L\entries+I*4)
; Next
; 
; 



; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 10
; FirstLine = 8
; Folding = -
; EnableXP