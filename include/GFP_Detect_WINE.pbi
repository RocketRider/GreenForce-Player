;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit




Procedure WINE_Detect()
  Protected hNtDll, hKernel32, hGdi32, hUser32, hWined3d, bFound = #False
  hNtDll = LoadLibrary_("NtDll.dll") 
  If hNtDll
    If GetProcAddress_(hNtDll, "__wine_enter_vm86") Or GetProcAddress_(hNtDll, "wine_server_call") Or GetProcAddress_(hNtDll, "wine_server_fd_to_handle")  
      bFound = #True  
    EndIf
    If GetProcAddress_(hNtDll, "wine_server_handle_to_fd") Or GetProcAddress_(hNtDll, "__wine_make_process_system") Or GetProcAddress_(hNtDll, "wine_get_version")  
      bFound = #True  
    EndIf   
    If GetProcAddress_(hNtDll, "wine_get_host_version") Or GetProcAddress_(hNtDll, "__wine_set_signal_handler") Or GetProcAddress_(hNtDll, "__wine_init_windows_dir")  
      bFound = #True  
    EndIf     
    FreeLibrary_(hNtDll)
  EndIf
  
  If bFound = #False    
    hWined3d = LoadLibrary_("wined3d.dll") 
    If hWined3d
      If GetProcAddress_(hWined3d, "wined3d_create") Or GetProcAddress_(hWined3d, "wined3d_mutex_lock") Or GetProcAddress_(hWined3d, "wined3d_incref")  
        bFound = #True  
      EndIf
      FreeLibrary_(hWined3d)
    EndIf
  EndIf  
  
  If bFound = #False    
    hKernel32 = LoadLibrary_("Kernel32.dll") 
    If hKernel32
      If GetProcAddress_(hKernel32, "wine_get_unix_file_name") Or GetProcAddress_(hKernel32, "wine_get_dos_file_name") Or GetProcAddress_(hKernel32, "__wine_kernel_init")  
        bFound = #True  
      EndIf
      FreeLibrary_(hKernel32)
    EndIf
  EndIf
  
  If bFound = #False   
    hGdi32 = LoadLibrary_("Gdi32.dll") 
    If hGdi32
      If GetProcAddress_(hGdi32, "__wine_make_gdi_object_system") Or GetProcAddress_(hGdi32, "__wine_set_visible_region") 
        bFound = #True  
      EndIf
      FreeLibrary_(hGdi32)
    EndIf     
  EndIf  
  
   If bFound = #False   
    hUser32 = LoadLibrary_("User32.dll") 
    If hUser32
      If GetProcAddress_(hUser32, "__wine_send_input") 
        bFound = #True  
      EndIf
      FreeLibrary_(hUser32)
    EndIf     
  EndIf   
  ProcedureReturn bFound
EndProcedure 


;Debug WINE_Detect()

; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = -
; EnableXP
; EnableCompileCount = 1
; EnableBuildCount = 0
; EnableExeConstant