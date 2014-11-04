;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
;PASSWORD STRING MUST BE UNICODE!



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

Procedure RSA_SendData(Pipename.s, SendData.s)
Protected File, result, size, mem, written, hSessionKey, hProv, length, orglength, cipherBlock


result=WaitNamedPipe_("\\.\pipe\"+Pipename, #Null)
If result
    File = CreateFile_("\\.\pipe\"+Pipename, #GENERIC_READ |#GENERIC_WRITE, 0, #Null, #OPEN_EXISTING,0, #Null)
   
    If File

      FlushFileBuffers_(File )
      

      size=1024*1024
      mem=AllocateMemory(size)
      If mem
        ReadFile_(File , mem,  size, @size, 0)
      EndIf  

      
      FlushFileBuffers_(File )
      
  
      If mem
         
         
        If CryptAcquireContext_(@hProv, #Null, #MS_STRONG_PROV, #PROV_RSA_FULL, #CRYPT_VERIFYCONTEXT) = 0
          CryptAcquireContext_(@hProv, #Null, #MS_STRONG_PROV, #PROV_RSA_FULL, #CRYPT_NEWKEYSET|#CRYPT_VERIFYCONTEXT)
        EndIf
        If hProv 
          length=StringByteLength(SendData)
          orglength=length
          CryptImportKey_(hProv, mem, size,0,0, @hSessionKey) 
          FreeMemory(mem)
          CryptEncrypt_(hSessionKey, 0, 1, $40, #Null, @length, 0)
          If length
            If orglength>length:length=orglength:EndIf
            cipherBlock=AllocateMemory(length)
            If cipherBlock
              CopyMemory(@SendData, cipherBlock, orglength)  
              CryptEncrypt_(hSessionKey, 0, 1, $40, cipherBlock, @orglength, length)
              CryptDestroyKey_(hSessionKey)
            EndIf
          EndIf
          CryptReleaseContext_(hProv,0)
        EndIf 
         
        If cipherBlock
          WriteFile_(File , cipherBlock, orglength, @written, 0)
          FlushFileBuffers_(File)
          FreeMemory(cipherBlock)
        EndIf  
        
       EndIf  
       
      CloseHandle_(File)
    EndIf
     
EndIf
ProcedureReturn result
EndProcedure


Define Player.s="D:\\Projekte\\PureBasic\\GreenForce-Player\\GreenForce-Player.exe"
Define PipeName.s="test123"
Define File.s="C:\Users\Admin\Videos\Test.gfp"
Define Password.s="test"

RunProgram(Player, File+" /passwordpipe "+PipeName, "")
Repeat
  Debug "Retry"
  Delay(10)
Until RSA_SendData(Pipename, Password)
; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 87
; FirstLine = 34
; Folding = -
; EnableUnicode
; EnableXP