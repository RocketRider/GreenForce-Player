;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

; 
; Global NewMap DebugList.s()
; 
; Procedure AddToDebugList(ptr.i)
;   If FindMapElement(DebugList(), Str(ptr))<>0
;     Debug "ERROR: "+Str(ptr)
;   EndIf  
;   
;   AddMapElement(DebugList(), Str(ptr), #PB_Map_ElementCheck)
;   DebugList() = Str(ptr)
; 
;   
; EndProcedure
; 
; Procedure DelteToDebugList(ptr.i)
;   If FindMapElement(DebugList(), Str(ptr))=0
;     Debug "ERROR NOT EXISTS: "+Str(ptr)
;   Else
;     DeleteMapElement(DebugList(), Str(ptr)) 
;   EndIf  
; 
; EndProcedure
; 
; Procedure CheckMemoryLeak()
;   ;Debug "------"
;   ;WriteLog("------")
;   ForEach DebugList()
;     ;Debug DebugList()
;     If DebugList()
;       ;WriteLog("test")
;     EndIf  
;   Next
;   
; EndProcedure  



EnableExplicit


 Import "Kernel32.lib"
   lstrlenW_(*pointer) As "_lstrlenW@4"
   lstrlenA_(*pointer) As "_lstrlenA@4" 
 EndImport
 
 
 
 
Procedure Str_Alloc(*pointer = #Null)
  
   
  Protected *strpointer, size.i
  *strpointer = #Null
  If *pointer
    size.i = lstrlen_(*pointer) * SizeOf(Character) + SizeOf(Character)
  Else
    size.i =   SizeOf(Character)
  EndIf
  *strpointer = AllocateMemory(size)
  ;AddToDebugList(*strpointer)
  If *strpointer And *pointer
    CopyMemory(*pointer, *strpointer, size)
  EndIf
  ProcedureReturn *strpointer
EndProcedure  

;Achtung Sehr langsam!
Procedure Str_Space(len)
  Protected *strpointer, size.i, *ptr.character, i
  *strpointer = #Null
  
  If len < 0
    len = 0
  EndIf  
  
  If len > 0
    size.i = len * SizeOf(Character) + SizeOf(Character)
  Else
    size.i = SizeOf(Character)
  EndIf
  *strpointer = AllocateMemory(size)
  ;AddToDebugList(*strpointer)
  If *strpointer
    *ptr.character = *strpointer
    For i=0 To len-1
      *ptr\c = ' '
      *ptr + SizeOf(Character)
    Next
  EndIf
  ProcedureReturn *strpointer
EndProcedure  

Procedure Str_AllocSize(len)
  Protected *strpointer, size.i, *ptr.character, i
  *strpointer = #Null
  
  If len < 0
    len = 0
  EndIf  
  
  If len > 0
    size.i = len * SizeOf(Character) + SizeOf(Character)
  Else
    size.i = SizeOf(Character)
  EndIf
  *strpointer = AllocateMemory(size)
  ProcedureReturn *strpointer
EndProcedure  

Procedure Str_Free(*strpointer)
  ;DelteToDebugList(*strpointer)
  If *strpointer
    FreeMemory(*strpointer)
  EndIf
EndProcedure

Procedure Str_Len(*strpointer)
  Protected len
  len = 0
  If *strpointer
    len = lstrlen_(*strpointer) ;returns the length in bytes for ANSI!
  EndIf
  ProcedureReturn len
EndProcedure  

Procedure Str_Compare(*strpointer1.Character, *strpointer2.Character)
  Protected result, len1.i, len2.i, i
  result = #False
  
  If *strpointer1 And *strpointer2
    len1.i = Str_Len(*strpointer1)
    len2.i = Str_Len(*strpointer2)
    
    If len1 = len2
      
      If len1 > 0
        
        result = CompareMemory(*strpointer1,*strpointer2, len1 * SizeOf(Character))
        ;result = #True
        ;For i = 0 To len1 -1
        ;  If *strpointer1\c <> *strpointer2\c
        ;    result = #False
        ;     Break
        ;  EndIf  
        ;  *strpointer1 + SizeOf(Character)
        ;  *strpointer2 + SizeOf(Character)
        ;Next  
        
      Else
        result = #True ; String ohne Zeichen...
      EndIf
      
    Else
      result = #False
    EndIf
  EndIf
  ProcedureReturn result
EndProcedure  

;Achtung Reallokiert den ersten Pointer!
Procedure Str_Combine(*strpointer1.Character, *strpointer2.Character)
  Protected *pointer, len1.i, len2.i, newByteSize.i
  
  *pointer = *strpointer1
  If *strpointer1 And *strpointer2
    len1.i = Str_Len(*strpointer1)
    len2.i = Str_Len(*strpointer2)
    
    newByteSize.i = (len1+len2)*SizeOf(Character) + SizeOf(Character)
        
    *pointer = ReAllocateMemory(*strpointer1, newByteSize)
    If *pointer
      CopyMemory(*strpointer2, *pointer + len1 * SizeOf(Character), len2 * SizeOf(Character))
    Else
      *pointer = *strpointer1 ; Failed, return old pointer
    EndIf
  
  EndIf
  ProcedureReturn *pointer  
EndProcedure  

Procedure Str_CombineNew(*strpointer1.Character, *strpointer2.Character)
  Protected *pointer, len1.i, len2.i, newByteSize.i
  
  *pointer = #Null
  If *strpointer1 And *strpointer2
    len1.i = Str_Len(*strpointer1)
    len2.i = Str_Len(*strpointer2)
    
    newByteSize.i = (len1+len2)*SizeOf(Character) + SizeOf(Character)
        
    *pointer = AllocateMemory(newByteSize)
    ;AddToDebugList(*pointer)
    If *pointer   
      CopyMemory(*strpointer1, *pointer + 0, len1 * SizeOf(Character)) 
      CopyMemory(*strpointer2, *pointer + len1 * SizeOf(Character), len2 * SizeOf(Character))  
    EndIf
  
  EndIf
  ProcedureReturn *pointer  
EndProcedure  


Procedure Str_Asc(*pointer.Character)
  If *pointer
    ProcedureReturn *pointer\c
  EndIf  
EndProcedure  

Procedure Str_Peek(*pointer, maxLength.i = -1)
  Protected  *newpointer, len
  
  *newpointer = #Null
  If *pointer
    len = lstrlen_(*pointer)
    
    If maxLength >= 0 And maxLength < len 
      len = maxLength
    EndIf  
    *newpointer = AllocateMemory(len * SizeOf(Character) + SizeOf(Character)) 
    ;AddToDebugList(*newpointer)
    If *newpointer
      CopyMemory(*pointer, *newpointer, len * SizeOf(Character))
    EndIf  
  EndIf
  ProcedureReturn *newpointer
EndProcedure


Procedure Str_PokeAnsi(*pointer, *srcpointer, maxLength.i = -1)
  Protected len
  
  If *pointer And *srcpointer
    len = lstrlen_(*srcpointer)
    If maxLength >= 0 And maxLength < len 
      len = maxLength
    EndIf  
    If SizeOf(Character) = 2
      WideCharToMultiByte_(#CP_ACP, 0, *srcpointer, len, *pointer, maxLength, #Null, #Null) ; TODO: Achtung Multi Bytes könnten hier verloren gehen
    Else
      CopyMemory(*srcpointer, *pointer, (len + 1) * SizeOf(Character))
    EndIf  
  EndIf
EndProcedure  

Procedure Str_PokeUnicode(*pointer, *srcpointer, maxLength.i = -1)
  Protected len, *newpointer
  
  If *pointer And *srcpointer
    len = lstrlen_(*srcpointer)
    If maxLength >= 0 And maxLength < len 
      len = maxLength
    EndIf  
    If SizeOf(Character) = 2
      CopyMemory(*srcpointer, *pointer, (len + 1)* SizeOf(Character))
    Else
      MultiByteToWideChar_(#CP_ACP,0, *pointer, len, *newpointer, len) 
    EndIf  
  EndIf
EndProcedure  

Procedure Str_PeekAnsi(*pointer)
  Protected len, *newpointer
  
  *newpointer = #Null
  If *pointer
    len = lstrlenA_(*pointer) ;Muss immer die Ansi version sein!
    *newpointer = AllocateMemory(len * SizeOf(Character) + SizeOf(Character)) ; ist evtl. zu viel für Unicode, aber besser zuvel als zu wenig ;-)
    ;AddToDebugList(*newpointer)
    If *newpointer
      If SizeOf(Character) = 2
        MultiByteToWideChar_(#CP_ACP,0, *pointer, -1, *newpointer, len) 
      Else
        CopyMemory(*pointer, *newpointer, len)
      EndIf  
    EndIf
  EndIf
  ProcedureReturn *newpointer
EndProcedure

Procedure Str_PeekUnicode(*pointer)
  Protected len, *newpointer, byteSize
  
  *newpointer = #Null
  If *pointer
    len = lstrlenW_(*pointer) ; immer Unicode!
    
    If SizeOf(Character) = 1
      byteSize = (len * 5) * SizeOf(Character) + SizeOf(Character)
      *newpointer = AllocateMemory(byteSize) ; von maximal 5 mult byte pro zeichen ausgehen...
      ;AddToDebugList(*newpointer)
    Else
      *newpointer = AllocateMemory(len * SizeOf(Character) + SizeOf(Character))     
      ;AddToDebugList(*newpointer)
    EndIf
      
    If *newpointer
      If SizeOf(Character) = 1
        WideCharToMultiByte_(#CP_ACP, 0, *pointer, len, *newpointer, byteSize, #Null, #Null)
      Else
        CopyMemory(*pointer, *newpointer, len * SizeOf(Character))
      EndIf  
    EndIf
  EndIf
  ProcedureReturn *newpointer
EndProcedure

Procedure Str_Mid(*pointer, position, length)
  Protected *newpointer, len
  
  *newpointer = #Null
  
  If position < 1
    position = 1
  EndIf  
  
  If *pointer
    len = lstrlen_(*pointer)
    position - 1
    
    If position + length > len
      length = len - position
    EndIf
    
    If length > 0
      *newpointer = Str_Peek(*pointer + position * SizeOf(Character) , length)
    Else
      *newPointer = Str_Alloc(#Null)
    EndIf  
    
  EndIf
  ProcedureReturn *newpointer
EndProcedure

Procedure Str_Left(*pointer, length)
  ProcedureReturn Str_Mid(*pointer, 1, length)
EndProcedure  

Procedure Str_Right(*pointer, length)
  Protected *newpointer
  
  *newpointer = #Null
  If *pointer
   *newpointer = Str_Mid(*pointer,1 + Str_Len(*pointer) - length, length)
 EndIf
 ProcedureReturn *newpointer
EndProcedure  

Procedure Str_Str(number)
  Protected *strpointer, ch, *strpointernew
  
  *strpointer = Str_Alloc(#Null)
  If *strpointer
  Repeat
    ch = number % 10
    number / 10
    
    *strpointernew = #Null
    Select ch
    Case 0
      *strpointernew = Str_CombineNew(@"0", *strpointer)
    Case 1
      *strpointernew = Str_CombineNew(@"1", *strpointer)  
    Case 2
      *strpointernew = Str_CombineNew(@"2", *strpointer)    
    Case 3
      *strpointernew = Str_CombineNew(@"3", *strpointer)
    Case 4
      *strpointernew = Str_CombineNew(@"4", *strpointer)
    Case 5
      *strpointernew = Str_CombineNew(@"5", *strpointer)
    Case 6
      *strpointernew = Str_CombineNew(@"6", *strpointer)
    Case 7
      *strpointernew = Str_CombineNew(@"7", *strpointer)  
    Case 8
      *strpointernew = Str_CombineNew(@"8", *strpointer)
    Case 9
      *strpointernew = Str_CombineNew(@"9", *strpointer)
    EndSelect
    If *strpointernew
      Str_Free(*strpointer)
      *strpointer = *strpointernew
    EndIf  
  Until number = 0
EndIf
ProcedureReturn *strpointer
EndProcedure

Procedure Str_UCase(*pointer.Character)
  Protected i, len, ch, *newpointer_.Character,  *newpointer.Character
  
  *newpointer = Str_Alloc(*pointer)
  If *newpointer
    len=Str_Len(*newpointer)
    *newpointer_ = *newpointer
    For i = 0 To len - 1
      ch = *newpointer_\c
      
      Select ch
        Case 'a'
          *newpointer_\c = 'A'
        Case 'b'
          *newpointer_\c = 'B'
        Case 'c'
          *newpointer_\c = 'C'
        Case 'd'
          *newpointer_\c = 'D'
        Case 'e'
          *newpointer_\c = 'E'
        Case 'f'
          *newpointer_\c = 'F'
        Case 'g'
          *newpointer_\c = 'G'
        Case 'h'
          *newpointer_\c = 'H'
        Case 'i'
          *newpointer_\c = 'I'
        Case 'j'
          *newpointer_\c = 'J'
        Case 'k'
          *newpointer_\c = 'K'
        Case 'l'
          *newpointer_\c = 'L'
        Case 'm'
          *newpointer_\c = 'M'
        Case 'n'
          *newpointer_\c = 'N'
        Case 'o'
          *newpointer_\c = 'O'
        Case 'p'
          *newpointer_\c = 'P'
        Case 'q'
          *newpointer_\c = 'Q'
        Case 'r'
          *newpointer_\c = 'R'
        Case 's'
          *newpointer_\c = 'S'
        Case 't'
          *newpointer_\c = 'T'
        Case 'u'
          *newpointer_\c = 'U'
        Case 'v'
          *newpointer_\c = 'V'
        Case 'w'
          *newpointer_\c = 'W'
        Case 'x'
          *newpointer_\c = 'X'
        Case 'y'
          *newpointer_\c = 'Y'
        Case 'z'
          *newpointer_\c = 'Z'
        Case 'ä'
          *newpointer_\c = 'Ä'
        Case 'ö'
          *newpointer_\c = 'Ö'
        Case 'ü'
          *newpointer_\c = 'Ü'
        
      EndSelect
         
      *newpointer_ + SizeOf(Character)
    Next  
  EndIf  
  
  ProcedureReturn *newpointer
EndProcedure  

Procedure Str_LCase(*pointer.Character)
  Protected i, len, ch, *newpointer.Character, *newpointer_.Character
  
  *newpointer = Str_Alloc(*pointer)
  If *newpointer
    len=Str_Len(*newpointer)
    *newpointer_ = *newpointer
    For i = 0 To len - 1
      ch = *newpointer_\c
      
      Select ch
        Case 'A'
          *newpointer_\c = 'a'
        Case 'B'
          *newpointer_\c = 'b'
        Case 'C'
          *newpointer_\c = 'c'
        Case 'D'
          *newpointer_\c = 'd'
        Case 'E'
          *newpointer_\c = 'e'
        Case 'F'
          *newpointer_\c = 'f'
        Case 'G'
          *newpointer_\c = 'g'
        Case 'H'
          *newpointer_\c = 'h'
        Case 'I'
          *newpointer_\c = 'i'
        Case 'J'
          *newpointer_\c = 'j'
        Case 'K'
          *newpointer_\c = 'k'
        Case 'L'
          *newpointer_\c = 'l'
        Case 'M'
          *newpointer_\c = 'm'
        Case 'N'
          *newpointer_\c = 'n'
        Case 'O'
          *newpointer_\c = 'o'
        Case 'P'
          *newpointer_\c = 'p'
        Case 'Q'
          *newpointer_\c = 'q'
        Case 'R'
          *newpointer_\c = 'r'
        Case 'S'
          *newpointer_\c = 's'
        Case 'T'
          *newpointer_\c = 't'
        Case 'U'
          *newpointer_\c = 'u'
        Case 'V'
          *newpointer_\c = 'v'
        Case 'W'
          *newpointer_\c = 'w'
        Case 'X'
          *newpointer_\c = 'x'
        Case 'Y'
          *newpointer_\c = 'y'
        Case 'Z'
          *newpointer_\c = 'z'
        Case 'Ä'
          *newpointer_\c = 'ä'
        Case 'Ö'
          *newpointer_\c = 'ö'
        Case 'Ü'
          *newpointer_\c = 'ü'
      EndSelect
         
      *newpointer_ + SizeOf(Character)
    Next  
  EndIf  
  ProcedureReturn *newpointer
EndProcedure  

Procedure StrEx_GetPathPart(*pointer.Character)
  Protected i, len, ch, *newpointer.Character, *pointer_.Character, lastpos=0
  If *pointer
    *pointer_ = *pointer
    lastpos = Str_Len(*pointer)
    len=Str_Len(*pointer)
    For i = 0 To len - 1
      ch = *pointer_\c
      If ch='\' Or ch='/'
        lastpos=i
      EndIf  
      *pointer_ + SizeOf(Character)
    Next  
    
    *newpointer = Str_Mid(*pointer, 1, lastpos+1)
  EndIf
  ProcedureReturn *newpointer
EndProcedure

Procedure StrEx_CommandLine()
  ProcedureReturn Str_Alloc(GetCommandLine_())
EndProcedure  

Procedure StrEx_ProgramName()
  Protected *pointer
  *pointer = Str_Space(#MAX_PATH + 1)
  If *pointer
    GetModuleFileName_(#Null,*pointer, #MAX_PATH)
  EndIf  
  ProcedureReturn *pointer
EndProcedure  




Macro STRING_INIT
  Protected __STRING_old_Variable
EndMacro  

Macro STRING_NEW(variable, pointer)
  Str_Free(variable)
  variable = Str_Alloc(pointer)
EndMacro  
 

Macro STRING_FREE(pointer)
  Str_Free(pointer)
  pointer = #Null
EndMacro

Macro STRING_SPACE(variable, len)
  Str_Free(variable)
  variable = Str_Space(len)
EndMacro

Macro STRING_ALLOCSIZE(variable, len)
  Str_Free(variable)
  variable = Str_AllocSize(len)
EndMacro

Macro STRING_MID(variable, string, pos, len)
  If variable = string
    __STRING_old_Variable = variable
    variable = Str_Mid(string, pos, len)
    Str_Free(__STRING_old_Variable)
  Else
    Str_Free(variable)
    variable = Str_Mid(string, pos, len)
  EndIf
EndMacro


Macro STRING_LEFT(variable, string, len)
  If variable = string
    __STRING_old_Variable = variable 
    variable = Str_Left(string, len)
    Str_Free(__STRING_old_Variable)
  Else
    Str_Free(variable)
    variable = Str_Left(string, len)
  EndIf
EndMacro

Macro STRING_RIGHT(variable, string, len)
  If variable = string
    __STRING_old_Variable = variable
    variable = Str_Right(string, len)
    Str_Free(__STRING_old_Variable)
  Else
    Str_Free(variable)
    variable = Str_Right(string, len)
  EndIf
EndMacro

Macro STRING_UCASE(variable, string)
  If variable = string
    __STRING_old_Variable = variable
    variable = Str_UCase(string)
    Str_Free(__STRING_old_Variable)
  Else
    Str_Free(variable)
    variable = Str_UCase(string)
  EndIf
EndMacro


Macro STRING_COMBINE(variable, string1, string2)
  If variable = string1
    __STRING_old_Variable = variable
    variable = Str_CombineNew(string1, string2)
    Str_Free(__STRING_old_Variable)
  ElseIf variable = string2
    __STRING_old_Variable = variable
    variable = Str_CombineNew(string1, string2)
    Str_Free(__STRING_old_Variable)
  Else
    Str_Free(variable)
    variable = Str_CombineNew(string1, string2)
  EndIf
EndMacro


Macro STRINGEX_GETPATHPART(variable, string)
  If variable = string
    __STRING_old_Variable = variable
    variable = StrEx_GetPathPart(string)
    Str_Free(__STRING_old_Variable)
  Else
    Str_Free(variable)
    variable = StrEx_GetPathPart(string)
  EndIf
EndMacro

Macro STRINGEX_PROGRAMNAME(variable)
  Str_Free(variable)
  variable = StrEx_ProgramName()
EndMacro  





; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 35
; Folding = ------
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; EnablePurifier
; EnableCompileCount = 25
; EnableBuildCount = 0
; EnableExeConstant