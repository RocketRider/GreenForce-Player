;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
Global ____Debug_Start = GetTickCount_()
Global Dim ____DEBUG_mem(10000)
Global Dim ____DEBUG_size(10000)
Global Dim ____DEBUG_time(10000)
Global Dim ____DEBUG_date(10000)
Global Dim ____DEBUG_Id.s(10000)

Procedure ____DEBUG_Add(mem,size,id.s)
  Protected i.i
  If mem
    For i=0 To 10000
      If ____DEBUG_mem(i) = 0
        ____DEBUG_mem(i)= mem
        ____DEBUG_size(i) = size
        ____DEBUG_time(i) = GetTickCount_(); - ____Debug_Start
        ____DEBUG_date(i) = Date()
        ____DEBUG_id(i) = id 
        Break  
      EndIf
    Next  
  EndIf
EndProcedure

Procedure ____DEBUG_Remove(mem)
  Protected i.i
  If mem
    For i=0 To 10000
      If ____DEBUG_mem(i) = mem
        ____DEBUG_mem(i)= #Null
        ____DEBUG_size(i) = 0
        ____DEBUG_time(i) = 0
        ____DEBUG_date(i) = 0

        Break  
      EndIf
    Next  
  EndIf
EndProcedure

Procedure __DEBUG_AllocateMemory(size, id.s)
  Protected *addr
  *addr = AllocateMemory(size)
  ____DEBUG_Add(*addr, size , id)    
  ProcedureReturn *addr
EndProcedure

Procedure __DEBUG_ReAllocateMemory(*addr, size, id.s)
  If *addr
    ____DEBUG_Remove(*addr)  
    *addr = ReAllocateMemory(*addr, size)
    ____DEBUG_Add(*addr, size , id)
  EndIf
  ProcedureReturn *addr
EndProcedure

Macro DEBUG_AllocateMemory(size)
__DEBUG_AllocateMemory(size, GetFilePart(#PB_Compiler_File) +" / "  + #PB_Compiler_Procedure +" Line: " + Str(#PB_Compiler_Line)  )
EndMacro

Macro DEBUG_ReAllocateMemory(mem, size)
__DEBUG_ReAllocateMemory(mem,size,  GetFilePart(#PB_Compiler_File) +" / "  + #PB_Compiler_Procedure +" Line: " + Str(#PB_Compiler_Line)  )
EndMacro

Procedure DEBUG_FreeMemory(*addr)
  If *addr
    ____DEBUG_Remove(*addr)
    ZeroMemory_(*Addr, MemorySize(*addr))
    FreeMemory(*addr)
  EndIf
EndProcedure

Procedure DEBUG_ShowLeaks()
    Protected i.i, LeakSize.i, Found.i
    For i=0 To 10000
      If ____DEBUG_mem(i)
        LeakSize +  ____DEBUG_size(i) 
      EndIf
    Next 
  
  If LeakSize>0
    Debug "--------------------------------------------------------"
    Debug "LEAKS:"
    For i=0 To 10000
      If ____DEBUG_mem(i)
        Found + 1
        Debug Str(Found)+":   " +____Debug_Id(i)+ "  ptr: " +Hex(____DEBUG_mem(i)) + " , size: "+Str(____DEBUG_size(i)) +" , time: "+Str(____DEBUG_time(i)- ____Debug_Start)+" date: "+FormatDate("%hh:%ii:%ss", ____DEBUG_date(i))+":"+Str(____DEBUG_time(i)%1000)
        ;LeakSize +  ____DEBUG_size(i) 
      EndIf
    Next  
    Debug "--------------------------------------------------------"  
    Debug "LEAK SIZE: "+StrF(LeakSize / 1024,2) + " KB"
    Debug "--------------------------------------------------------"  
  EndIf
EndProcedure  

; 
; For t = 0 To 999
; Debug DEBUG_AllocateMemory(10000)
; Next
; 
; 
; DEBUG_ShowLeaks()

Macro AllocateMemory(Size)
  DEBUG_AllocateMemory(size)
EndMacro

Macro FreeMemory(add)
  DEBUG_FreeMemory(add)
EndMacro

Macro ReAllocateMemory(addr, size)
  DEBUG_ReAllocateMemory(addr, size)
EndMacro




; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 89
; FirstLine = 36
; Folding = --
; EnableXP
; EnablePurifier
; EnableCompileCount = 4
; EnableBuildCount = 0
; EnableExeConstant