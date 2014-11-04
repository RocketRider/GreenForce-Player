;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
;http://www.codeproject.com/Articles/11578/Encryption-using-the-Win32-Crypto-API
;http://www.niris.co.uk/crypt.html
;http://blogs.msdn.com/b/alejacma/archive/2007/12/13/key-containers-basics.aspx

#PROV_RSA_FULL = 1
#CRYPT_NEWKEYSET = 8
#MS_DEF_PROV = "Microsoft Base Cryptographic Provider v1.0"
#MS_ENHANCED_PROV = "Microsoft Enhanced Cryptographic Provider v1.0"
#MS_STRONG_PROV = "Microsoft Strong Cryptographic Provider"
#CALG_RSA_KEYX = $a400
#CALG_RSA_SIGN =	$2400
#CALG_RC4 = $6801	
#CRYPT_VERIFYCONTEXT = -268435456
#SIMPLEBLOB		= 	$01
#PUBLICKEYBLOB	= 	$06
#PRIVATEKEYBLOB	=	$07
#PLANTEXTKEYBLOB	=	$08
#OPAQUEKEYBLOB	=	$09
#PUBLICKEYBLOBEX	=	$0A
#SYMMETRICWRAPKEYBLOB	=	$0B
#CRYPT_EXPORTABLE = 1
#CRYPT_CREATE_SALT = 4
#CRYPT_NO_SALT     = $10
#AT_SIGNATURE = 2

Global RSA_publicKey
Global RSA_publicKeyLen
Global RSA_TransferdData
Global RSA_TransferdDataLen
Procedure RSA_Thread(Hpipe.l)
  Protected endthread, fConnected, written, numCons
  Repeat
    ;GetNamedPipeHandleState_(Hpipe,#Null,@numCons,#Null,#Null,#Null,#Null)
    fConnected = ConnectNamedPipe_(Hpipe, #False)
    ;If fConnected
      ;Debug "Connected!!!"
      WriteFile_(Hpipe, RSA_publicKey, RSA_publicKeyLen, @written, 0)
      ;Debug "Write"
      
      FlushFileBuffers_(Hpipe)
      
      ;Debug "Read"
      RSA_TransferdDataLen=1024*1024
      If RSA_TransferdDataLen>0
        RSA_TransferdData=AllocateMemory(RSA_TransferdDataLen)
        If RSA_TransferdData
          ReadFile_(Hpipe, RSA_TransferdData, RSA_TransferdDataLen, @RSA_TransferdDataLen, 0)
        EndIf
      EndIf  
  ;     Debug RSA_TransferdData
  ;     Debug RSA_TransferdDataLen
  ;     Debug PeekS(RSA_TransferdData,RSA_TransferdDataLen)
      
      If DisconnectNamedPipe_(Hpipe)
        endthread=#True
      Else
        ;CloseHandle_(Hpipe)
        endthread=#True
      EndIf
    ;EndIf
    Delay(10)
  Until endthread
EndProcedure


Procedure.s RSA_GetPipeString(pipe.s)
  Protected Hpipe, hProv, hSessionKey,Thread, starttimer, OutputString.s
  If CryptAcquireContext_(@hProv, #Null, #MS_STRONG_PROV, #PROV_RSA_FULL, #CRYPT_VERIFYCONTEXT) = 0
    CryptAcquireContext_(@hProv, #Null, #MS_STRONG_PROV, #PROV_RSA_FULL, #CRYPT_NEWKEYSET|#CRYPT_VERIFYCONTEXT)
  EndIf
  If hProv
    CryptGenKey_(hProv, #CALG_RSA_KEYX , #CRYPT_EXPORTABLE , @hSessionKey)
    If hSessionKey
      CryptExportKey_(hSessionKey, 0, #PUBLICKEYBLOB, 0, 0, @RSA_publicKeyLen)
      If RSA_publicKeyLen
        RSA_publicKey=AllocateMemory(RSA_publicKeyLen)
        If RSA_publicKey
          CryptExportKey_(hSessionKey, 0, #PUBLICKEYBLOB, 0, RSA_publicKey, @RSA_publicKeyLen)
        EndIf
      EndIf
    EndIf
    If RSA_publicKey
      Hpipe=CreateNamedPipe_("\\.\pipe\"+pipe, #PIPE_ACCESS_DUPLEX, #PIPE_TYPE_MESSAGE | #PIPE_READMODE_MESSAGE, 1, 1024*1024, 1024*1024, 3000, #Null)
      ;MessageRequester(Str(Hpipe),"")
      If Hpipe
        Thread=CreateThread(@RSA_Thread(), Hpipe)
        If Thread
          starttimer=GetTickCount_()
          
          Repeat
            ProcessAllEvents()
            Delay(10)
            If GetTickCount_()-starttimer>5000:KillThread(Thread):EndIf
            
          Until IsThread(Thread)=0
          If RSA_TransferdData 
            If RSA_TransferdDataLen
              CryptDecrypt_(hSessionKey, 0, 1, $40, RSA_TransferdData, @RSA_TransferdDataLen)
              If RSA_TransferdData And RSA_TransferdDataLen
                OutputString=PeekS(RSA_TransferdData, RSA_TransferdDataLen/2)
              EndIf  
            EndIf
            FreeMemory(RSA_TransferdData)
            CryptDestroyKey_(hSessionKey)
          EndIf
        EndIf 
        CloseHandle_(Hpipe)
      EndIf
      FreeMemory(RSA_publicKey)
    EndIf    
    
    CryptReleaseContext_(hProv,0)
  EndIf  
ProcedureReturn OutputString
EndProcedure  






; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 69
; FirstLine = 65
; Folding = -
; EnableXP