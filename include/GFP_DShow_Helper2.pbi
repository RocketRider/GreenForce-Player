;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit



Structure FilterInfo
   achName.w[128]
  *pGraph.IUnknown                 ;
  EndStructure

;-=================== Detection of Renderer =====================================

; Does not free *pmt self!
Procedure DeleteMediaType(*pmt.MEDIATYPE)
  ; check for NULL pointer
  If (*pmt <> #Null)
    ; Free format data
    If (*pmt\cbFormat <> 0) 
      CoTaskMemFree_(*pmt\pbFormat)
      *pmt\cbFormat = 0
      *pmt\pbFormat = #Null
    EndIf

    ; Release Interface if available
    If (*pmt\pUnk <> #Null) 
      *pmt\pUnk\Release()
      *pmt\pUnk = #Null
    EndIf

    ProcedureReturn #S_OK
  Else
    ProcedureReturn #E_FAIL
  EndIf 
EndProcedure

Procedure CountPinsOnFilter(*pFilter.IBaseFilter, *ptrInPins.integer, *ptrOutPins.integer)
    Protected hr = #S_OK
    Protected *pEnum.IEnumPins = #Null
    Protected iFound.i = 0
    Protected *pPin.IPin = #Null
    Protected iNumOut.i = 0, iNumIn.i = 0
    Protected iDir.i  = 0
    
    If *pFilter And *ptrInPins And *ptrOutPins 
      ; Get the enumerator
      hr = *pFilter\EnumPins(@*pEnum)
      
      If *pEnum
        *pEnum\Reset()
        
        ; Count all pins on the filter
        While(*pEnum\Next(1, @*pPin, @iFound) = #S_OK)      
          iDir = 3
  
          hr = *pPin\QueryDirection(@iDir)
  
          If(iDir = #PINDIR_INPUT)
            iNumIn + 1
          Else
            iNumOut + 1
          EndIf  
  
          *pPin\Release()
        Wend
    
        *pEnum\Release()
      EndIf
        
    Else
      hr = #E_POINTER
    EndIf
    
    If *ptrInPins
      *ptrInPins\i = iNumIn
    EndIf  
    If *ptrOutPins
      *ptrOutPins\i = iNumOut
    EndIf  
    ProcedureReturn hr
EndProcedure

Procedure GetPin(*pFilter.IBaseFilter, iDirRequired.i, iNum.i, *ppPin.integer)
    Protected *pEnum.IEnumPins
    Protected iFound.i = #False
    Protected *pPin.IPin = #Null
    Protected hr.i = #E_FAIL  
    Protected iDir.i = 0
    
    If *ppPin And *pFilter
      *ppPin\i = #Null

      hr = *pFilter\EnumPins(@*pEnum)
      If hr = #S_OK
    
        While(*pEnum\Next(1, @*pPin, @iFound) = #S_OK)
          iDir = 3
  
          *pPin\QueryDirection(@iDir)
          If(iDir = iDirRequired)
          
            If(iNum = 0)
              ;In this case the interface is not released! (correct this way!)
              *ppPin\i = *pPin
               hr = #S_OK ; return success
              Break
            EndIf
            iNum = iNum-1
          EndIf 
  
          *pPin\Release()
          *pPin = #Null
        Wend
        *pEnum\Release()
        *pEnum = #Null
      EndIf
   
    Else
      hr = #E_POINTER 
    EndIf
   
    ProcedureReturn hr
EndProcedure

Procedure GetInPin(*pFilter.IBaseFilter, iPin.i )
  Protected *pInPin.IPin = #Null
  GetPin(*pFilter, #PINDIR_INPUT, iPin, @*pInPin)
  ProcedureReturn *pInPin ; mut be released later
EndProcedure

Procedure FindRenderer(*pGB.IGraphBuilder, *mediaTypeToFind.GUID, *ppFilter.integer); *pIsOverlay.integer = #Null)
    Protected *pEnum.IEnumFilters = #Null
    Protected *pFilter.IBaseFilter = #Null
    Protected iInPins = 0, iOutPins = 0
    Protected type.MediaType
    Protected hr, bFound, ulFetched
    Protected *pPin.IPin = #Null
    
    hr = #S_OK  
    If *ppFilter:*ppFilter\i = #Null:EndIf ; First set to null   
    ;If *pIsOverlay:*pIsOverlay\i = #False:EndIf
    
    If *pGB = #Null Or *mediaTypeToFind = #Null Or *ppFilter = #Null 
      hr = #E_POINTER
    EndIf 
     
    If hr = #S_OK
         
      If *pGB\EnumFilters(@*pEnum) = #S_OK  
        *pEnum\Reset()
        
        ; Enumerate all filters in the graph-builder object
        While ((Not bFound) And (*pEnum\Next(1, @*pFilter, @ulFetched) = #S_OK))
          
          ; search for filter with one input and no output pin
          hr = CountPinsOnFilter(*pFilter, @iInPins, @iOutPins)
          If hr <> #S_OK  
            Break
          EndIf  
  
          If iInPins = 1 And iOutPins = 0
            ; Get first pin
            *pPin = GetInPin(*pFilter, 0)
                         
            If *pPin
              ; Read major media type
              hr = *pPin\ConnectionMediaType(@type)
                   
              If hr = #S_OK
                ;Check for requested type
                If CompareMemory(@type\majortype, *mediaTypeToFind, SizeOf(GUID))
                  ; Found our filter
                  
;                   If *pIsOverlay
;                     If CompareMemory(@type\subtype, @MEDIASUBTYPE_Overlay, SizeOf(GUID))
;                       *pIsOverlay\i = #True
;                     EndIf  
;                   EndIf
                  
                  *ppFilter\i = *pFilter
                  bFound = #True
                  hr = #S_OK
                EndIf                   
                DeleteMediaType(@type)                                
              EndIf
              *pPin\Release() ; Don't forget to release pin interface!
              
            Else
              hr = #E_FAIL
            EndIf
          Else
            hr = #E_FAIL
          EndIf  
          
          ;release interface if not found!
          If bFound = #False
            If *pFilter
              *pFilter\Release()
            EndIf  
          EndIf          

        Wend
        
        *pEnum\Release()
      EndIf
    EndIf  
    ProcedureReturn hr
EndProcedure    

Procedure FindVideoRenderer(*pGB.IGraphBuilder);, *pIsOverlay.integer = #Null)
  Protected *pFilter.IBaseFilter
  FindRenderer(*pGB, @MEDIATYPE_Audio, @*pFilter);, *pIsOverlay)
  ProcedureReturn *pFilter
EndProcedure  

Procedure.s FindRendererName(*pFilter.IBaseFilter);, *pIsOverlay.integer = #Null)
  Protected fi.FilterInfo
  *pFilter\QueryFilterInfo(@fi)
  ProcedureReturn PeekS(@fi\achName)
EndProcedure 

;================================================================================
