;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

EnableExplicit
; Import "Kernel32.lib";Fred Hotfix
;   GetProcAddress_(hMod.i, Name.p-ascii) As "_GetProcAddress@8"
; EndImport



Prototype.i WinHttpDetectAutoProxyConfigUrl(dwAutoDetectFlags.i, *lpszAutoProxyUrl)
Prototype.i WinHttpOpen(*pwszUserAgent, dwAccessType.l, *pwszProxyName, *pwszProxyBypass, dwFlags.l)
Prototype.i WinHttpConnect(hSession, *pswzServerName, nServerPort.l, dwReserved.l)
Prototype.i WinHttpSetOption(hInternet, dwOption.l, *lpBuffer, dwBufferLength.l)
Prototype.i WinHttpSetCredentials(hInternet, AuthTargets.l, AuthScheme.l, *pwszUserName, *pwszPassword, *pAuthParams)
Prototype.i WinHttpOpenRequest(hConnect, *pwszVerb, *pwszObjectName, *pwszVersion, *pwszReferrer, *ppwszAcceptTypes, dwFlags.l)
Prototype.i WinHttpSendRequest(hRequest, *pwszHeaders, dwHeadersLength.l, *lpOptional, dwOptionalLength.l, dwTotalLength.l, dwContext.l)
Prototype.i WinHttpReceiveResponse(hRequest, *lpReserved)
Prototype.i WinHttpAddRequestHeaders(hRequest, *pwszHeaders, dwHeadersLength.l, dwModifiers.l)
Prototype.i WinHttpQueryHeaders(hRequest, dwInfoLevel.l, *pwszName, *lpBuffer, *lpdwBufferLength, *lpdwIndex)
Prototype.i WinHttpQueryDataAvailable(hRequest, *lpdwNumberOfBytesAvailable)
Prototype.i WinHttpReadData(hRequest, *lpBuffer, dwNumberOfBytesToRead.l, *lpdwNumberOfBytesRead)
Prototype.i WinHttpCrackUrl(*pwszUrl, dwUrlLength.l, dwFlags.l, *lpUrlComponents)
Prototype.i WinHttpCloseHandle(hInternet)
Prototype.i WinHttpQueryOption(hInternet, dwOption.i, *lpBuffer, *lpdwBufferLength)


#INTERNET_DEFAULT_PORT  =        0           ; use the protocol-specific Default
#WINHTTP_INTERNET_DEFAULT_HTTP_PORT =   80          ;    "     "  HTTP   "
#WINHTTP_INTERNET_DEFAULT_HTTPS_PORT = 443         ;    "     "  HTTPS  "

#WINHTTP_FLAG_ASYNC =             $10000000  ; this session is asynchronous (where supported)

; flags For WinHttpOpenRequest():
#WINHTTP_FLAG_SECURE =               $00800000  ; use SSL If applicable (HTTPS)
#WINHTTP_FLAG_ESCAPE_PERCENT =       $00000004  ; If escaping enabled, escape percent As well
#WINHTTP_FLAG_NULL_CODEPAGE =        $00000008  ; assume all symbols are ASCII, use fast convertion
#WINHTTP_FLAG_BYPASS_PROXY_CACHE =   $00000100 ; add "pragma: no-cache" request header
#WINHTTP_FLAG_REFRESH =              #WINHTTP_FLAG_BYPASS_PROXY_CACHE
#WINHTTP_FLAG_ESCAPE_DISABLE =       $00000040  ; disable escaping
#WINHTTP_FLAG_ESCAPE_DISABLE_QUERY = $00000080  ; If escaping enabled escape path part, but do Not escape query


#WINHTTP_AUTOPROXY_AUTO_DETECT =          $00000001
#WINHTTP_AUTOPROXY_CONFIG_URL =           $00000002
#WINHTTP_AUTOPROXY_RUN_INPROCESS =        $00010000
#WINHTTP_AUTOPROXY_RUN_OUTPROCESS_ONLY =  $00020000
;
; Flags For dwAutoDetectFlags 
;
#WINHTTP_AUTO_DETECT_TYPE_DHCP =          $00000001
#WINHTTP_AUTO_DETECT_TYPE_DNS_A =         $00000002

; WinHttpOpen dwAccessType values (also For WINHTTP_PROXY_INFO::dwAccessType)
#WINHTTP_ACCESS_TYPE_DEFAULT_PROXY =              0
#WINHTTP_ACCESS_TYPE_NO_PROXY =                   1
#WINHTTP_ACCESS_TYPE_NAMED_PROXY =                3

; WinHttpOpen prettifiers For optional parameters
#WINHTTP_NO_PROXY_NAME =    #Null
#WINHTTP_NO_PROXY_BYPASS =  #Null

; Structure WINHTTP_CONNECTION_INFO
;   cbSize.l
;   LocalAddress.SOCKADDR_STORAGE ;  // local ip, local port
;   RemoteAddress. SOCKADDR_STORAGE ; // remote ip, remote port
; EndStructure

#WINHTTP_QUERY_CONTENT_LENGTH = 5

#WINHTTP_OPTION_CALLBACK                      =  1
#WINHTTP_OPTION_RESOLVE_TIMEOUT               =  2
#WINHTTP_OPTION_CONNECT_TIMEOUT               =  3
#WINHTTP_OPTION_CONNECT_RETRIES               =  4
#WINHTTP_OPTION_SEND_TIMEOUT                  =  5
#WINHTTP_OPTION_RECEIVE_TIMEOUT               =  6
#WINHTTP_OPTION_RECEIVE_RESPONSE_TIMEOUT      =  7
#WINHTTP_OPTION_HANDLE_TYPE                   =  9
#WINHTTP_OPTION_READ_BUFFER_SIZE              = 12
#WINHTTP_OPTION_WRITE_BUFFER_SIZE             = 13
#WINHTTP_OPTION_PARENT_HANDLE                 = 21
#WINHTTP_OPTION_EXTENDED_ERROR                = 24
#WINHTTP_OPTION_SECURITY_FLAGS                = 31
#WINHTTP_OPTION_SECURITY_CERTIFICATE_STRUCT   = 32
#WINHTTP_OPTION_URL                           = 34
#WINHTTP_OPTION_SECURITY_KEY_BITNESS          = 36
#WINHTTP_OPTION_PROXY                         = 38  

Enumeration
  #WINHTTP_INTERNET_SCHEME_HTTP                   = 1
  #WINHTTP_INTERNET_SCHEME_HTTPS                  = 2
  #WINHTTP_INTERNET_DEFAULT_HTTP_PORT             = 80
  #WINHTTP_INTERNET_DEFAULT_HTTPS_PORT            = 443
  
  #WINHTTP_NO_PROXY_NAME                  = 0
  #WINHTTP_NO_PROXY_BYPASS                = 0
  #WINHTTP_NO_REFERER                     = 0
  #WINHTTP_NO_HEADER_INDEX                = 0
  #WINHTTP_DEFAULT_ACCEPT_TYPES           = 0
  #WINHTTP_ACCESS_TYPE_DEFAULT_PROXY      = 0
  #WINHTTP_HEADER_NAME_BY_INDEX           = 0
  
  #WINHTTP_AUTH_TARGET_SERVER             = 0
  #WINHTTP_AUTH_TARGET_PROXY              = 1
  
  #WINHTTP_AUTH_SCHEME_BASIC              = 1
  #WINHTTP_AUTH_SCHEME_NTLM               = 2
  #WINHTTP_AUTH_SCHEME_PASSPORT           = 4
  #WINHTTP_AUTH_SCHEME_DIGEST             = 8
  #WINHTTP_AUTH_SCHEME_NEGOTIATE          = 16
  
  #WINHTTP_OPTION_REDIRECT_POLICY                         = 88
  #WINHTTP_OPTION_REDIRECT_POLICY_NEVER                   = 0
  #WINHTTP_OPTION_REDIRECT_POLICY_DISALLOW_HTTPS_TO_HTTP  = 1
  #WINHTTP_OPTION_REDIRECT_POLICY_ALWAYS                  = 2
  
  
  #WINHTTP_QUERY_MIME_VERSION                = 0
  #WINHTTP_QUERY_CONTENT_TYPE                = 1
  #WINHTTP_QUERY_CONTENT_TRANSFER_ENCODING   = 2
  #WINHTTP_QUERY_CONTENT_ID                  = 3
  #WINHTTP_QUERY_CONTENT_DESCRIPTION         = 4
  #WINHTTP_QUERY_CONTENT_LENGTH              = 5
  #WINHTTP_QUERY_CONTENT_LANGUAGE            = 6
  #WINHTTP_QUERY_ALLOW                       = 7
  #WINHTTP_QUERY_PUBLIC                      = 8
  #WINHTTP_QUERY_DATE                        = 9
  #WINHTTP_QUERY_EXPIRES                     = 10
  #WINHTTP_QUERY_LAST_MODIFIED               = 11
  #WINHTTP_QUERY_MESSAGE_ID                  = 12
  #WINHTTP_QUERY_URI                         = 13
  #WINHTTP_QUERY_DERIVED_FROM                = 14
  #WINHTTP_QUERY_COST                        = 15
  #WINHTTP_QUERY_LINK                        = 16
  #WINHTTP_QUERY_PRAGMA                      = 17
  #WINHTTP_QUERY_VERSION                     = 18
  #WINHTTP_QUERY_STATUS_CODE                 = 19
  #WINHTTP_QUERY_STATUS_TEXT                 = 20
  #WINHTTP_QUERY_RAW_HEADERS                 = 21
  #WINHTTP_QUERY_RAW_HEADERS_CRLF            = 22
  #WINHTTP_QUERY_CONNECTION                  = 23
  #WINHTTP_QUERY_ACCEPT                      = 24
  #WINHTTP_QUERY_ACCEPT_CHARSET              = 25
  #WINHTTP_QUERY_ACCEPT_ENCODING             = 26
  #WINHTTP_QUERY_ACCEPT_LANGUAGE             = 27
  #WINHTTP_QUERY_AUTHORIZATION               = 28
  #WINHTTP_QUERY_CONTENT_ENCODING            = 29
  #WINHTTP_QUERY_FORWARDED                   = 30
  #WINHTTP_QUERY_FROM                        = 31
  #WINHTTP_QUERY_IF_MODIFIED_SINCE           = 32
  #WINHTTP_QUERY_LOCATION                    = 33
  #WINHTTP_QUERY_ORIG_URI                    = 34
  #WINHTTP_QUERY_REFERER                     = 35
  #WINHTTP_QUERY_RETRY_AFTER                 = 36
  #WINHTTP_QUERY_SERVER                      = 37
  #WINHTTP_QUERY_TITLE                       = 38
  #WINHTTP_QUERY_USER_AGENT                  = 39
  #WINHTTP_QUERY_WWW_AUTHENTICATE            = 40
  #WINHTTP_QUERY_PROXY_AUTHENTICATE          = 41
  #WINHTTP_QUERY_ACCEPT_RANGES               = 42
  #WINHTTP_QUERY_SET_COOKIE                  = 43
  #WINHTTP_QUERY_COOKIE                      = 44
  #WINHTTP_QUERY_REQUEST_METHOD              = 45
  #WINHTTP_QUERY_REFRESH                     = 46
  #WINHTTP_QUERY_CONTENT_DISPOSITION         = 47
  ;
  ; HTTP= 1.1 defined headers
  ;
  #WINHTTP_QUERY_AGE                         = 48
  #WINHTTP_QUERY_CACHE_CONTROL               = 49
  #WINHTTP_QUERY_CONTENT_BASE                = 50
  #WINHTTP_QUERY_CONTENT_LOCATION            = 51
  #WINHTTP_QUERY_CONTENT_MD5                 = 52
  #WINHTTP_QUERY_CONTENT_RANGE               = 53
  #WINHTTP_QUERY_ETAG                        = 54
  #WINHTTP_QUERY_HOST                        = 55
  #WINHTTP_QUERY_IF_MATCH                    = 56
  #WINHTTP_QUERY_IF_NONE_MATCH               = 57
  #WINHTTP_QUERY_IF_RANGE                    = 58
  #WINHTTP_QUERY_IF_UNMODIFIED_SINCE         = 59
  #WINHTTP_QUERY_MAX_FORWARDS                = 60
  #WINHTTP_QUERY_PROXY_AUTHORIZATION         = 61
  #WINHTTP_QUERY_RANGE                       = 62
  #WINHTTP_QUERY_TRANSFER_ENCODING           = 63
  #WINHTTP_QUERY_UPGRADE                     = 64
  #WINHTTP_QUERY_VARY                        = 65
  #WINHTTP_QUERY_VIA                         = 66
  #WINHTTP_QUERY_WARNING                     = 67
  #WINHTTP_QUERY_EXPECT                      = 68
  #WINHTTP_QUERY_PROXY_CONNECTION            = 69
  #WINHTTP_QUERY_UNLESS_MODIFIED_SINCE       = 70
  #WINHTTP_QUERY_PROXY_SUPPORT               = 75
  #WINHTTP_QUERY_AUTHENTICATION_INFO         = 76
  #WINHTTP_QUERY_PASSPORT_URLS               = 77
  #WINHTTP_QUERY_PASSPORT_CONFIG             = 78
  #WINHTTP_QUERY_MAX                         = 78
  #WINHTTP_QUERY_CUSTOM                      = 65535
  #WINHTTP_QUERY_FLAG_REQUEST_HEADERS        = $80000000
  #WINHTTP_QUERY_FLAG_SYSTEMTIME             = $40000000
  #WINHTTP_QUERY_FLAG_NUMBER                 = $20000000

  
  
  #WINHTTP_OPTION_USERNAME                = $1000
  #WINHTTP_OPTION_PASSWORD                = $1001
  
  #WINHTTP_FLAG_REFRESH                   = $00000100
  #WINHTTP_FLAG_SECURE                    = $00800000
  
  #WINHTTP_ADDREQ_FLAG_ADD                = $20000000
EndEnumeration

#WINHTTP_NO_ADDITIONAL_HEADERS  = #Null
#WINHTTP_NO_REQUEST_DATA        = #Null

#WINHTTP_ERROR_BASE                    = 12000
#ERROR_WINHTTP_OUT_OF_HANDLES           = (#WINHTTP_ERROR_BASE + 1)
#ERROR_WINHTTP_TIMEOUT                  = (#WINHTTP_ERROR_BASE + 2)
#ERROR_WINHTTP_INTERNAL_ERROR           = (#WINHTTP_ERROR_BASE + 4)
#ERROR_WINHTTP_INVALID_URL              = (#WINHTTP_ERROR_BASE + 5)
#ERROR_WINHTTP_UNRECOGNIZED_SCHEME      = (#WINHTTP_ERROR_BASE + 6)
#ERROR_WINHTTP_NAME_NOT_RESOLVED        = (#WINHTTP_ERROR_BASE + 7)
#ERROR_WINHTTP_INVALID_OPTION           = (#WINHTTP_ERROR_BASE + 9)
#ERROR_WINHTTP_OPTION_NOT_SETTABLE      = (#WINHTTP_ERROR_BASE + 11)
#ERROR_WINHTTP_SHUTDOWN                 = (#WINHTTP_ERROR_BASE + 12)

#ERROR_WINHTTP_LOGIN_FAILURE            = (#WINHTTP_ERROR_BASE + 15)
#ERROR_WINHTTP_OPERATION_CANCELLED      = (#WINHTTP_ERROR_BASE + 17)
#ERROR_WINHTTP_INCORRECT_HANDLE_TYPE    = (#WINHTTP_ERROR_BASE + 18)
#ERROR_WINHTTP_INCORRECT_HANDLE_STATE   = (#WINHTTP_ERROR_BASE + 19)
#ERROR_WINHTTP_CANNOT_CONNECT           = (#WINHTTP_ERROR_BASE + 29)
#ERROR_WINHTTP_CONNECTION_ERROR         = (#WINHTTP_ERROR_BASE + 30)
#ERROR_WINHTTP_RESEND_REQUEST           = (#WINHTTP_ERROR_BASE + 32)

#ERROR_WINHTTP_CLIENT_AUTH_CERT_NEEDED  = (#WINHTTP_ERROR_BASE + 44)

#ERROR_WINHTTP_CANNOT_CALL_BEFORE_OPEN	= (#WINHTTP_ERROR_BASE + 100)
#ERROR_WINHTTP_CANNOT_CALL_BEFORE_SEND	= (#WINHTTP_ERROR_BASE + 101)
#ERROR_WINHTTP_CANNOT_CALL_AFTER_SEND	= (#WINHTTP_ERROR_BASE + 102)
#ERROR_WINHTTP_CANNOT_CALL_AFTER_OPEN	= (#WINHTTP_ERROR_BASE + 103)

#ERROR_WINHTTP_HEADER_NOT_FOUND             = (#WINHTTP_ERROR_BASE + 150)
#ERROR_WINHTTP_INVALID_SERVER_RESPONSE      = (#WINHTTP_ERROR_BASE + 152)
#ERROR_WINHTTP_INVALID_QUERY_REQUEST        = (#WINHTTP_ERROR_BASE + 154)
#ERROR_WINHTTP_HEADER_ALREADY_EXISTS        = (#WINHTTP_ERROR_BASE + 155)
#ERROR_WINHTTP_REDIRECT_FAILED              = (#WINHTTP_ERROR_BASE + 156)

#ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR  = (#WINHTTP_ERROR_BASE + 178)
#ERROR_WINHTTP_BAD_AUTO_PROXY_SCRIPT     = (#WINHTTP_ERROR_BASE + 166)
#ERROR_WINHTTP_UNABLE_TO_DOWNLOAD_SCRIPT = (#WINHTTP_ERROR_BASE + 167)

#ERROR_WINHTTP_NOT_INITIALIZED          = (#WINHTTP_ERROR_BASE + 172)
#ERROR_WINHTTP_SECURE_FAILURE           = (#WINHTTP_ERROR_BASE + 175)

#ERROR_WINHTTP_SECURE_CERT_DATE_INVALID    = (#WINHTTP_ERROR_BASE + 37)
#ERROR_WINHTTP_SECURE_CERT_CN_INVALID      = (#WINHTTP_ERROR_BASE + 38)
#ERROR_WINHTTP_SECURE_INVALID_CA           = (#WINHTTP_ERROR_BASE + 45)
#ERROR_WINHTTP_SECURE_CERT_REV_FAILED      = (#WINHTTP_ERROR_BASE + 57)
#ERROR_WINHTTP_SECURE_CHANNEL_ERROR        = (#WINHTTP_ERROR_BASE + 157)
#ERROR_WINHTTP_SECURE_INVALID_CERT         = (#WINHTTP_ERROR_BASE + 169)
#ERROR_WINHTTP_SECURE_CERT_REVOKED         = (#WINHTTP_ERROR_BASE + 170)
#ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE     = (#WINHTTP_ERROR_BASE + 179)

#ERROR_WINHTTP_AUTODETECTION_FAILED                  = (#WINHTTP_ERROR_BASE + 180)
#ERROR_WINHTTP_HEADER_COUNT_EXCEEDED                 = (#WINHTTP_ERROR_BASE + 181)
#ERROR_WINHTTP_HEADER_SIZE_OVERFLOW                  = (#WINHTTP_ERROR_BASE + 182)
#ERROR_WINHTTP_CHUNKED_ENCODING_HEADER_SIZE_OVERFLOW = (#WINHTTP_ERROR_BASE + 183)
#ERROR_WINHTTP_RESPONSE_DRAIN_OVERFLOW               = (#WINHTTP_ERROR_BASE + 184)
#WINHTTP_ERROR_LAST                                  = (#WINHTTP_ERROR_BASE + 184)

#HTTPCONTEXT_RELEASED_ID = 690325417

#HTTPCONTEXT_REQUEST_UNDEFINED = -1
#HTTPCONTEXT_REQUEST_GET = 0
#HTTPCONTEXT_REQUEST_POST = 1
#HTTPCONTEXT_REQUEST_HEAD = 2

Global g_HTTPCONTEXT_hWinHTTP
Global g_HTTPCONTEXT_IEProxy.s = ""

Global WinHttpOpen.WinHttpOpen
;WinHttpQueryOption.WinHttpQueryOption
Global WinHttpConnect.WinHttpConnect
Global WinHttpOpenRequest.WinHttpOpenRequest
Global WinHttpSendRequest.WinHttpSendRequest
Global WinHttpReceiveResponse.WinHttpReceiveResponse
Global WinHttpQueryOption.WinHttpQueryOption
Global WinHttpCloseHandle.WinHttpCloseHandle
Global WinHttpCrackUrl.WinHttpCrackUrl
Global WinHttpAddRequestHeaders.WinHttpAddRequestHeaders
Global WinHttpQueryHeaders.WinHttpQueryHeaders
Global WinHttpQueryDataAvailable.WinHttpQueryDataAvailable
Global WinHttpReadData.WinHttpReadData
Global WinHttpSetCredentials.WinHttpSetCredentials
Global WinHttpSetOption.WinHttpSetOption

Structure HTTPCONTEXT
  idAlreadyReleased.i
  hMutex.i
  hSession.i
  hConnect.i
  sAgent.s{#MAX_PATH}
  sURL.s{2048}
  sSever.s{#MAX_PATH}
  sPath.s{2048}
  sFullPath.s{2048}  
  sUsername.s{#MAX_PATH}
  sPassword.s{#MAX_PATH}
  sExtraInfo.s{2048}
  
  ;Proxy
  sOwnProxy.s{#MAX_PATH}
  bByPassLocal.i
  ;bForceProxy.i
  bUseIEProxy.i
  
  lPort.i
  lScheme.i
  lFlags.i
  bKeepAlive.i
  
  ;Request
  *resultBuffer
  resultSize.i
  hRequest.i
  requestType.i
  
  ;Header
  HeaderDataString.s{#MAX_PATH} ;2011-03-10
  KeepAliveString.s{#MAX_PATH} ;2011-03-10
  TmpString.s{#MAX_PATH} ;2011-03-10
EndStructure

; 
Structure INTERNET_PROXY_INFO
  dwAccessType.l
  *lpszProxy
  *lpszProxyBypass
EndStructure
; 
#INTERNET_OPTION_PROXY = 38
; #INTERNET_OPTION_PROXY_PASSWORD = 44
; #INTERNET_OPTION_PROXY_USERNAME = 43
; 
; #PROXY_AUTO_DETECT_TYPE_DHCP =    1
; #PROXY_AUTO_DETECT_TYPE_DNS_A =   2
; 
; Prototype DetectAutoProxyUrl(*lpszAutoProxyUrl, dwAutoProxyUrlLength.i, dwDetectFlags.i)
; 
; ;WinHTTP:
; 
; #WINHTTP_AUTOPROXY_AUTO_DETECT          = $00000001
; #WINHTTP_AUTOPROXY_CONFIG_URL           = $00000002
; #WINHTTP_AUTOPROXY_RUN_INPROCESS        = $00010000
; #WINHTTP_AUTOPROXY_RUN_OUTPROCESS_ONLY  = $00020000
; 
; #WINHTTP_AUTO_DETECT_TYPE_DHCP          = $00000001
; #WINHTTP_AUTO_DETECT_TYPE_DNS_A         = $00000002
; 
; 
; Structure PROXY_GLOBALS
;   *hWininet.i
;   *hWinHTTP.i
;   WinHttpDetectAutoProxyConfigUrl.WinHttpDetectAutoProxyConfigUrl
;   DetectAutoProxyUrl.DetectAutoProxyUrl 
;   ;timestamp.i
;   lastProxy.s
; EndStructure
; 
; Global g_PROXY.PROXY_GLOBALS
; 
Procedure.s __PROXY_GetProxy()
  Protected proxy.s = "", result.i, len.i, *ppi.INTERNET_PROXY_INFO
  result = InternetQueryOption_(#Null, #INTERNET_OPTION_PROXY, #Null ,@len)
  If result = #False And GetLastError_() = #ERROR_INSUFFICIENT_BUFFER And len > 0
    *ppi.INTERNET_PROXY_INFO = AllocateMemory(len)
    If *ppi
      If InternetQueryOption_(#Null, #INTERNET_OPTION_PROXY, *ppi ,@len)
        If *ppi\lpszProxy
          proxy = Trim(PeekS(*ppi\lpszProxy, -1, #PB_Ascii))  
        EndIf  
      EndIf
      FreeMemory(*ppi)
    EndIf
  EndIf
  ProcedureReturn proxy
EndProcedure 

; Procedure.s __PROXY_GetProxyBypass()
;   proxy.s = ""
;   result = InternetQueryOption_(#Null, #INTERNET_OPTION_PROXY, #Null ,@len)
;   If result = #False And GetLastError_() = #ERROR_INSUFFICIENT_BUFFER And len > 0
;     *ppi.INTERNET_PROXY_INFO = AllocateMemory(len)
;     If *ppi
;       If InternetQueryOption_(#Null, #INTERNET_OPTION_PROXY, *ppi ,@len)
;         proxy = Trim(PeekS(*ppi\lpszProxyBypass, -1, #PB_Ascii))  
;       EndIf
;       FreeMemory(*ppi)
;     EndIf
;   EndIf
;   ProcedureReturn proxy
; EndProcedure 
; 
; Procedure.s __PROXY_GetAutoProxyDHCP() ; ONLY ADDRESS OF PAC FILE!!!!
;   proxy.s = ""
;   ;WinHTTPP bevorzugen
;   If g_PROXY\WinHttpDetectAutoProxyConfigUrl 
;     If g_PROXY\WinHttpDetectAutoProxyConfigUrl(#WINHTTP_AUTO_DETECT_TYPE_DHCP, @*autoProxy)
;       If *autoProxy
;         proxy = Trim(PeekS(*autoProxy, -1, #PB_Unicode))
;         GlobalFree_(*autoProxy)  
;       EndIf
;     EndIf
;   EndIf
;   ;Ansosnten Wininet
;   If proxy.s = ""
;     If g_PROXY\DetectAutoProxyUrl
;       *autoProxy = AllocateMemory(4096)
;       If *autoProxy
;         If g_PROXY\DetectAutoProxyUrl(*autoProxy, 4095, #PROXY_AUTO_DETECT_TYPE_DHCP)
;           proxy = Trim(PeekS(*autoProxy, -1, #PB_Ascii))
;         EndIf  
;         FreeMemory(*autoProxy)  
;       EndIf
;     EndIf
;   EndIf  
;   ProcedureReturn proxy
; EndProcedure 
; 
; Procedure.s __PROXY_GetAutoProxyDNS_A() ; ONLY ADDRESS OF PAC FILE!!!!
;   proxy.s = ""
;   ;WinHTTPP bevorzugen
;   If g_PROXY\WinHttpDetectAutoProxyConfigUrl 
;     If g_PROXY\WinHttpDetectAutoProxyConfigUrl(#WINHTTP_AUTO_DETECT_TYPE_DNS_A, @*autoProxy)
;       If *autoProxy
;         proxy = Trim(PeekS(*autoProxy, -1, #PB_Unicode))
;         GlobalFree_(*autoProxy)  
;       EndIf
;     EndIf
;   EndIf
;   ;Ansosnten Wininet
;   If proxy.s = ""
;     If g_PROXY\DetectAutoProxyUrl
;       *autoProxy = AllocateMemory(4096)
;       If *autoProxy
;         If g_PROXY\DetectAutoProxyUrl(*autoProxy, 4095, #PROXY_AUTO_DETECT_TYPE_DNS_A)
;           proxy = Trim(PeekS(*autoProxy, -1, #PB_Ascii))
;         EndIf  
;         FreeMemory(*autoProxy)  
;       EndIf
;     EndIf
;   EndIf  
;   ProcedureReturn proxy
; EndProcedure 
; 
; Procedure.s PROXY_GetServerFromString(ProxyURL.s)
;   If FindString(proxyURL, ":", 1)
;     ProcedureReturn Trim(StringField(proxyURL, 1, ":"))
;   Else
;     ProcedureReturn Trim(proxyURL)
;   EndIf  
; EndProcedure  
; 
; Procedure.i PROXY_GetPortFromString(ProxyURL.s)
;   If FindString(proxyURL, ":", 1)
;     ProcedureReturn Val(Trim(StringField(proxyURL, 2, ":")))
;   Else
;     ProcedureReturn -1
;   EndIf  
; EndProcedure  
; 
; Procedure.s __PROXY_TestConnecting(ProxyURL.s)
;   ProxyURL = ReplaceString(ProxyURL, "<local>", "")
;   Server.s = PROXY_GetServerFromString(ProxyURL)
;   Port = PROXY_GetPortFromString(ProxyURL)
;   If Port = -1
;     Port = 8080 ; Könnte auch jeder andere Port sein...    
;   EndIf  
;   
;   connectionID = OpenNetworkConnection(Server.s, Port)
;   If connectionID
;     CloseNetworkConnection(connectionID)
;   EndIf
;   If ConnectionID
;     ProcedureReturn Server + ":"  +Str(Port)
;   Else
;     ProcedureReturn ""     
;   EndIf
; EndProcedure  
; 
; Procedure PROXY_Init()
;   g_PROXY\hWininet = LoadLibrary_("Wininet.dll")
;   g_PROXY\hWinHTTP = LoadLibrary_("winhttp.dll") 
;   If g_PROXY\hWininet
;     g_PROXY\WinHttpDetectAutoProxyConfigUrl = GetProcAddress_(g_PROXY\hWininet, "WinHttpDetectAutoProxyConfigUrl")
;   EndIf
;   If g_PROXY\hWinHTTP
;     g_PROXY\DetectAutoProxyUrl = GetProcAddress_(hWininet,"DetectAutoProxyUrl")
;   EndIf  
;   g_PROXY\lastProxy = ""
;   ProcedureReturn #True
; EndProcedure  
; 
; Procedure PROXY_Free()
;   If g_PROXY\hWininet
;     FreeLibrary_(g_PROXY\hWininet)
;     g_PROXY\hWininet = #Null
;   EndIf
;   If g_PROXY\hWinHTTP
;     FreeLibrary_(g_PROXY\hWinHTTP)
;     g_PROXY\hWinHTTP = #Null
;   EndIf 
;   g_PROXY\DetectAutoProxyUrl = #Null
;   g_PROXY\WinHttpDetectAutoProxyConfigUrl = #Null
; EndProcedure
; 
; 
; Procedure.s PROXY_GetAvailable()
;   proxyURL.s = __PROXY_TestConnecting(__PROXY_GetProxy())
;   If proxyURL.s <> ""
;     ProcedureReturn proxyURL.s 
;   EndIf  
;   proxyURL.s = __PROXY_TestConnecting(__PROXY_GetAutoProxyDHCP())
;   If proxyURL.s <> ""
;     ProcedureReturn proxyURL.s 
;   EndIf   
;   proxyURL.s = __PROXY_TestConnecting(__PROXY_GetAutoProxyDNS_A())
;   If proxyURL.s <> ""
;     ProcedureReturn proxyURL.s 
;   EndIf  
;   g_PROXY\lastProxy = proxyURL
;   ;EndIf
;   ProcedureReturn g_PROXY\lastProxy
; EndProcedure    
; 
; Procedure PROXY_BypassLocalAddresses()
;   proxyURL.s = LCase(__PROXY_GetProxyBypass())
;   If FindString(proxyURL, "<local>", 1)
;     ProcedureReturn #True
;   Else
;     ProcedureReturn #False
;   EndIf  
; EndProcedure
; 


Macro __DANGEROUS_HTTPCONTEXT_Error(sText)
  CompilerIf #USE_BUGGY_VIRTUALFILE_LOGGING
   ; Debug sText
    WriteLog(sText, #LOGLEVEL_ERROR)
  CompilerEndIf
EndMacro

Macro __DANGEROUS_HTTPCONTEXT_Debug(sText)
  CompilerIf #USE_BUGGY_VIRTUALFILE_LOGGING
 ;   Debug sText
    WriteLog(sText, #LOGLEVEL_DEBUG)
  CompilerEndIf
EndMacro

Procedure __HTTPCONTEXT_Error(sText.s)
  WriteLog(sText, #LOGLEVEL_ERROR)
EndProcedure  

Procedure __HTTPCONTEXT_Debug(sText.s)
  WriteLog(sText, #LOGLEVEL_DEBUG)
EndProcedure  


Procedure __Int64ToStr(*ptr.Character, value.q) ; slower than Str()....
  Protected negative.i = #False, num.q = 0, val.i, count.i = 0
  If value < 0
    value = -value
    negative = #True
    *ptr\c = '-'
    *ptr + SizeOf(Character)
  EndIf
  num.q = value
  Repeat
    num / 10
    count + 1
  Until num = 0
  *ptr + count * SizeOf(Character)
  num.q = value  
  Repeat
    *ptr - SizeOf(Character)
    *ptr\c = (num % 10) + '0'
    num / 10
  Until num = 0
  If negative
    count + 1
  EndIf  
  ProcedureReturn count
EndProcedure  

Procedure __HTTPCONTEXT_OpenConnection(*ctx.HTTPCONTEXT)
  Protected bResult = #False, sUseProxy.s = ""
  If *ctx
    ;First close open connections
    If *ctx\hRequest
      WinHttpCloseHandle(*ctx\hRequest)
      *ctx\hRequest = #Null
    EndIf
    If *ctx\hConnect
      WinHttpCloseHandle(*ctx\hConnect)
      *ctx\hConnect = #Null
    EndIf
    If *ctx\hSession
      WinHttpCloseHandle(*ctx\hSession)
      *ctx\hSession = #Null
    EndIf  
    
    
      
    sUseProxy = ""
    If *ctx\bUseIEProxy
      sUseProxy.s = Trim(g_HTTPCONTEXT_IEProxy)
    EndIf
    If Trim(*ctx\sOwnProxy) <> ""
      sUseProxy = *ctx\sOwnProxy
    EndIf
    __HTTPCONTEXT_Debug("IE proxy: " + g_HTTPCONTEXT_IEProxy)
    __HTTPCONTEXT_Debug("use proxy: " + sUseProxy)
    If *ctx\bByPassLocal
      __HTTPCONTEXT_Debug("bypass local addresses")       
    EndIf  
    
    If sUseProxy <> ""
      If *ctx\bByPassLocal       
        *ctx\hSession = WinHttpOpen(@*ctx\sAgent, #WINHTTP_ACCESS_TYPE_NAMED_PROXY, @sUseProxy, @"<local>", 0) 
      Else
        *ctx\hSession = WinHttpOpen(@*ctx\sAgent, #WINHTTP_ACCESS_TYPE_NAMED_PROXY, @sUseProxy, #WINHTTP_NO_PROXY_BYPASS, 0)           
      EndIf 
      If *ctx\hSession = #Null
         __HTTPCONTEXT_Debug("create named proxy connection failed!")       
      EndIf  
    EndIf   
    
    If *ctx\hSession = #Null  
      If *ctx\bByPassLocal       
        *ctx\hSession = WinHttpOpen(@*ctx\sAgent, #WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, @sUseProxy, @"<local>", 0) 
      Else
        *ctx\hSession = WinHttpOpen(@*ctx\sAgent, #WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, @sUseProxy, #WINHTTP_NO_PROXY_BYPASS, 0)           
      EndIf 
      If *ctx\hSession = #Null
         __HTTPCONTEXT_Debug("create default connection failed!")       
      EndIf        
    EndIf    
    
    If *ctx\hSession = #Null  
      *ctx\hSession = WinHttpOpen(@*ctx\sAgent, #WINHTTP_ACCESS_TYPE_NO_PROXY, #WINHTTP_NO_PROXY_NAME, #WINHTTP_NO_PROXY_BYPASS, 0)      
      If *ctx\hSession = #Null
        __HTTPCONTEXT_Error("create direct connection failed! opening connection failed completly!")
      EndIf        
    EndIf      
    
    
;     Old way (no really ideal)    
;     If *ctx\bForceProxy = #False
;       ;First try without proxy
;       *ctx\hSession = WinHttpOpen(@*ctx\sAgent, #WINHTTP_ACCESS_TYPE_NO_PROXY, #WINHTTP_NO_PROXY_NAME, #WINHTTP_NO_PROXY_BYPASS, 0)      
;       If *ctx\hSession = #Null
;         __HTTPCONTEXT_Debug("create direct connection failed!")
;       EndIf  
;       
;       ;Try proxy settings of winhttp in registry
;       If *ctx\hSession = #Null
;         *ctx\hSession = WinHttpOpen(@*ctx\sAgent, #WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, #WINHTTP_NO_PROXY_NAME, #WINHTTP_NO_PROXY_BYPASS, 0)
;         If *ctx\hSession = #Null
;           __HTTPCONTEXT_Debug("create connection with default proxy failed!")
;         EndIf         
;       EndIf  
;       
;     Else
;       __HTTPCONTEXT_Debug("force proxy")      
;     EndIf   
;     
;     If *ctx\hSession = #Null  
;       sUseProxy.s = g_HTTPCONTEXT_IEProxy
;       __HTTPCONTEXT_Debug("IE proxy " + sUseProxy)
;       If *ctx\sOwnProxy
;         sUseProxy = *ctx\sOwnProxy
;       EndIf  
;       __HTTPCONTEXT_Debug("use proxy " + sUseProxy)
;       
;       If *ctx\bByPassLocal
;       __HTTPCONTEXT_Debug("bypass local")        
;         *ctx\hSession = WinHttpOpen(@*ctx\sAgent, #WINHTTP_ACCESS_TYPE_NAMED_PROXY, @sUseProxy, @"<local>", 0) 
;       Else
;         *ctx\hSession = WinHttpOpen(@*ctx\sAgent, #WINHTTP_ACCESS_TYPE_NAMED_PROXY, @sUseProxy, #WINHTTP_NO_PROXY_BYPASS, 0)           
;       EndIf  
;     EndIf
    
    
    If *ctx\hSession     
      *ctx\hConnect = WinHttpConnect(*ctx\hSession, @*ctx\sSever, *ctx\lPort, 0)     
      If *ctx\hConnect  
        bResult = #True
      EndIf   
    EndIf
    
    If bResult = #False
      ; Close all handles
      If *ctx\hRequest
        WinHttpCloseHandle(*ctx\hRequest)
        *ctx\hRequest = #Null
      EndIf
      If *ctx\hConnect
        WinHttpCloseHandle(*ctx\hConnect)
        *ctx\hConnect = #Null
      EndIf
      If *ctx\hSession
        WinHttpCloseHandle(*ctx\hSession)
        *ctx\hSession = #Null
      EndIf     
    EndIf  
  EndIf
  ProcedureReturn bResult
EndProcedure  

Procedure __HTTPCONTEXT_CreateRequest(*ctx.HTTPCONTEXT, requestType.i)
  Protected bResult = #False
  If *ctx    
    If *ctx\hRequest
      WinHttpCloseHandle(*ctx\hRequest)
      *ctx\hRequest = #Null      
    EndIf  
    If *ctx\hConnect
      
      Select requestType
      Case #HTTPCONTEXT_REQUEST_HEAD    
        *ctx\hRequest = WinHttpOpenRequest( *ctx\hConnect, @"HEAD", @*ctx\sFullPath, #Null, #WINHTTP_NO_REFERER, #WINHTTP_DEFAULT_ACCEPT_TYPES, *ctx\lFlags)    
        *ctx\requestType = #HTTPCONTEXT_REQUEST_HEAD  
      Case  #HTTPCONTEXT_REQUEST_POST
        *ctx\hRequest = WinHttpOpenRequest( *ctx\hConnect, @"POST", @*ctx\sFullPath, #Null, #WINHTTP_NO_REFERER, #WINHTTP_DEFAULT_ACCEPT_TYPES, *ctx\lFlags)    
        *ctx\requestType = #HTTPCONTEXT_REQUEST_POST
      Default
        *ctx\hRequest = WinHttpOpenRequest( *ctx\hConnect, @"GET", @*ctx\sFullPath, #Null, #WINHTTP_NO_REFERER, #WINHTTP_DEFAULT_ACCEPT_TYPES, *ctx\lFlags)    
        *ctx\requestType = #HTTPCONTEXT_REQUEST_GET
      EndSelect
    
      If *ctx\hRequest   
        
        If lstrlen_(@*ctx\sUsername) ;Trim(*ctx\sUsername)<> ""
          WinHttpSetCredentials(*ctx\hRequest, #WINHTTP_AUTH_TARGET_SERVER, #WINHTTP_AUTH_SCHEME_BASIC, @*ctx\sUsername, @*ctx\sPassword, #Null) ;Uses a base64 encoded string that contains the user name and password
        EndIf
        
          bResult = WinHttpAddRequestHeaders(*ctx\hRequest, @*ctx\KeepAliveString, -1, #WINHTTP_ADDREQ_FLAG_ADD)  
        
        ;If *ctx\bKeepAlive
        ;  bResult = WinHttpAddRequestHeaders(*ctx\hRequest, @"Connection: keep-alive" + #CRLF$, -1, #WINHTTP_ADDREQ_FLAG_ADD)  
        ;Else
        ;  bResult = WinHttpAddRequestHeaders(*ctx\hRequest, @"Connection: close" + #CRLF$, -1, #WINHTTP_ADDREQ_FLAG_ADD)            
        ;EndIf
      EndIf    
    EndIf
  EndIf  
  ProcedureReturn bResult
EndProcedure  

Procedure __HTTPCONTEXT_DeleteRequest(*ctx.HTTPCONTEXT)
  Protected bResult = #False
  If *ctx    
    If *ctx\hRequest
      WinHttpCloseHandle(*ctx\hRequest)
      *ctx\hRequest = #Null 
      *ctx\requestType = #HTTPCONTEXT_REQUEST_UNDEFINED
      bResult = #True
    EndIf  
  EndIf  
  ProcedureReturn bResult
EndProcedure  


Procedure HTTPCONTEXT_Initialize()
  Protected bResult = #False
  g_HTTPCONTEXT_hWinHTTP = LoadLibrary_("winhttp.dll")
  If g_HTTPCONTEXT_hWinHTTP  
    WinHttpOpen.WinHttpOpen                             = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpOpen")
    ;WinHttpQueryOption.WinHttpQueryOption = GetProcAddress_(hWinHTTP, "WinHttpQueryOption")
    WinHttpConnect.WinHttpConnect                       = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpConnect")
    WinHttpOpenRequest.WinHttpOpenRequest               = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpOpenRequest")
    WinHttpSendRequest.WinHttpSendRequest               = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpSendRequest")
    WinHttpReceiveResponse.WinHttpReceiveResponse       = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpReceiveResponse")
    WinHttpQueryOption.WinHttpQueryOption               = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpQueryOption")
    WinHttpCloseHandle.WinHttpCloseHandle               = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpCloseHandle")
    WinHttpCrackUrl.WinHttpCrackUrl                     = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpCrackUrl")
    WinHttpAddRequestHeaders.WinHttpAddRequestHeaders   = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpAddRequestHeaders")
    WinHttpQueryHeaders.WinHttpQueryHeaders             = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpQueryHeaders")
    WinHttpQueryDataAvailable.WinHttpQueryDataAvailable = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpQueryDataAvailable")
    WinHttpReadData.WinHttpReadData                     = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpReadData")
    WinHttpSetCredentials.WinHttpSetCredentials         = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpSetCredentials")
    WinHttpSetOption.WinHttpSetOption                   = GetProcAddress_(g_HTTPCONTEXT_hWinHTTP, "WinHttpSetOption")    
    g_HTTPCONTEXT_IEProxy = __PROXY_GetProxy()  
    
    If WinHttpOpen And WinHttpConnect And WinHttpOpenRequest And WinHttpSendRequest And WinHttpReceiveResponse And WinHttpQueryOption
      If WinHttpCloseHandle And WinHttpCrackUrl And WinHttpAddRequestHeaders And WinHttpQueryHeaders And WinHttpQueryDataAvailable And WinHttpReadData And WinHttpSetCredentials And WinHttpSetOption
        bResult = #True
      EndIf
    EndIf  
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure HTTPCONTEXT_UnInitialize()
  WinHttpOpen.WinHttpOpen                             = #Null
  ;WinHttpQueryOption.WinHttpQueryOption = GetProcAddress_(hWinHTTP, "WinHttpQueryOption")
  WinHttpConnect.WinHttpConnect                       = #Null
  WinHttpOpenRequest.WinHttpOpenRequest               = #Null
  WinHttpSendRequest.WinHttpSendRequest               = #Null
  WinHttpReceiveResponse.WinHttpReceiveResponse       = #Null
  WinHttpQueryOption.WinHttpQueryOption               = #Null
  WinHttpCloseHandle.WinHttpCloseHandle               = #Null
  WinHttpCrackUrl.WinHttpCrackUrl                     = #Null
  WinHttpAddRequestHeaders.WinHttpAddRequestHeaders   = #Null
  WinHttpQueryHeaders.WinHttpQueryHeaders             = #Null
  WinHttpQueryDataAvailable.WinHttpQueryDataAvailable = #Null
  WinHttpReadData.WinHttpReadData                     = #Null
  WinHttpSetCredentials.WinHttpSetCredentials         = #Null
  If g_HTTPCONTEXT_hWinHTTP
    FreeLibrary_(g_HTTPCONTEXT_hWinHTTP)
    g_HTTPCONTEXT_hWinHTTP = #Null
  EndIf  
EndProcedure

Procedure HTTPCONTEXT_Close(*ctx.HTTPCONTEXT)
  If g_HTTPCONTEXT_hWinHTTP
    If *ctx
      If *ctx\hMutex
        LockMutex(*ctx\hMutex)
      EndIf  
      If *ctx\idAlreadyReleased = #HTTPCONTEXT_RELEASED_ID
        __HTTPCONTEXT_Error("Pointer " + Hex(*ctx) + " was already released before!")
      EndIf  
      *ctx\idAlreadyReleased = #HTTPCONTEXT_RELEASED_ID
      If *ctx\hRequest
        WinHttpCloseHandle(*ctx\hRequest)
        *ctx\hRequest = #Null
      EndIf
      If *ctx\hConnect
        WinHttpCloseHandle(*ctx\hConnect)
        *ctx\hConnect = #Null
      EndIf
      If *ctx\hSession
        WinHttpCloseHandle(*ctx\hSession)
        *ctx\hSession = #Null
      EndIf 
      If *ctx\resultBuffer
        FreeMemory(*ctx\resultBuffer)
        *ctx\resultBuffer = #Null
      EndIf
      If *ctx\hMutex
        UnlockMutex(*ctx\hMutex)
        FreeMutex(*ctx\hMutex)
        *ctx\hMutex = #Null
      EndIf
      FreeMemory(*ctx)
    EndIf 
  Else
    __HTTPCONTEXT_Error("HTTPCONTEXT_Close was called before HTTPCONTEXT_Initialize")
  EndIf
EndProcedure

Procedure HTTPCONTEXT_OpenURL(URL.s, Agent.s = "", keepAlive.i = #True, proxy.s = "", bypassLocal.i = #True, noCache.i = #False, useIEProxy.i = #True, noRedirect.i = #True)
  Protected UrlComponents.URL_COMPONENTS, bResult = #False, *ctx.HTTPCONTEXT = #Null, sEncURL.s, redirectPolicy.l
  If g_HTTPCONTEXT_hWinHTTP 
    *ctx = AllocateMemory(SizeOf(HTTPCONTEXT))
    If *ctx
      *ctx\hMutex = CreateMutex()
      If *ctx\hMutex
        *ctx\idAlreadyReleased = 0
        
        UrlComponents\dwStructSize      = SizeOf(URL_COMPONENTS)
        UrlComponents\dwSchemeLength    = -1
        UrlComponents\dwHostNameLength  = -1
        UrlComponents\dwUrlPathLength   = -1
        UrlComponents\dwExtraInfoLength = -1
        UrlComponents\dwUserNameLength  = -1
        UrlComponents\dwPasswordLength  = -1
        
        *ctx\sURL   = URL
        *ctx\sAgent = Agent
        
        *ctx\sOwnProxy = proxy
        ;*ctx\bForceProxy = forceProxy
        *ctx\bUseIEProxy = useIEProxy
        *ctx\bByPassLocal = bypassLocal
        *ctx\bKeepAlive = keepAlive
        
        sEncURL.s = URLEncoder(URL)
        
        ;Prepare Strings...
        *ctx\HeaderDataString = "Range: bytes="
        
        If keepAlive
          *ctx\KeepAliveString = "Connection: keep-alive" + #CRLF$
        Else
          *ctx\KeepAliveString = "Connection: close" + #CRLF$        
        EndIf      
        
        WinHttpCrackUrl(@sEncURL, #Null, #Null, @UrlComponents)  ; fields like "UrlComponents\dwUrlPathLength" will now contain a pointer to the correct place in the address of sEncURL  
        
        *ctx\sPath      = ""
        *ctx\sSever     = ""
        *ctx\sUsername  = ""
        *ctx\sPassword  = ""
        *ctx\sExtraInfo = ""
        If UrlComponents\lpszUrlPath <> #Null
          *ctx\sPath = PeekS(UrlComponents\lpszUrlPath, UrlComponents\dwUrlPathLength)
        EndIf
        If UrlComponents\lpszHostName <> #Null
          *ctx\sSever = PeekS(UrlComponents\lpszHostName, UrlComponents\dwHostNameLength)
        EndIf     
        If UrlComponents\lpszUserName <> #Null
          *ctx\sUsername = PeekS(UrlComponents\lpszUserName, UrlComponents\dwUserNameLength)
        EndIf       
        If UrlComponents\lpszPassword <> #Null
          *ctx\sPassword = PeekS(UrlComponents\lpszPassword, UrlComponents\dwPasswordLength)
        EndIf       
        If UrlComponents\lpszExtraInfo <> #Null
          *ctx\sExtraInfo = PeekS(UrlComponents\lpszExtraInfo, UrlComponents\dwExtraInfoLength)
        EndIf      
        
        *ctx\sFullPath = *ctx\sPath + *ctx\sExtraInfo         
        
        *ctx\lPort = UrlComponents\nPort
        Select UrlComponents\nScheme
          Case #WINHTTP_INTERNET_SCHEME_HTTP
            If *ctx\lPort = 0
              *ctx\lPort = #WINHTTP_INTERNET_DEFAULT_HTTP_PORT
            EndIf  
            *ctx\lFlags = 0
          Case #WINHTTP_INTERNET_SCHEME_HTTPS
            If *ctx\lPort = 0
              *ctx\lPort = #WINHTTP_INTERNET_DEFAULT_HTTPS_PORT
            EndIf  
            *ctx\lFlags = #WINHTTP_FLAG_SECURE
        EndSelect   
        If noCache ; no cached data (for proxy)
          *ctx\lFlags | #WINHTTP_FLAG_REFRESH
        EndIf 
        If *ctx\lPort = 0
          *ctx\lPort = #WINHTTP_INTERNET_DEFAULT_HTTP_PORT ; Use port 80 as default...
        EndIf   
        
        *ctx\lScheme = UrlComponents\nScheme
        
        If __HTTPCONTEXT_OpenConnection(*ctx)   
      
          If noRedirect
            redirectPolicy = #WINHTTP_OPTION_REDIRECT_POLICY_NEVER 
          Else
            redirectPolicy = #WINHTTP_OPTION_REDIRECT_POLICY_DISALLOW_HTTPS_TO_HTTP ;This is the default setting.   //   or WINHTTP_OPTION_REDIRECT_POLICY_ALWAYS     
          EndIf  
          ; Set for whole session....
          If WinHttpSetOption(*ctx\hSession, #WINHTTP_OPTION_REDIRECT_POLICY, @redirectPolicy, SizeOf(Long))
            bResult = #True
          Else
            __HTTPCONTEXT_Error("WinHttpSetOption failed for WINHTTP_OPTION_REDIRECT_POLICY with error code " + Str(GetLastError_()))            
          EndIf  
        EndIf  
      EndIf
    EndIf   
    
    If bResult = #False
      __HTTPCONTEXT_Error("failed to initalize connection to URL " + Chr(34) + URL + Chr(34))
      HTTPCONTEXT_Close(*ctx)
      *ctx = #Null
    EndIf  
  Else
    __HTTPCONTEXT_Error("HTTPCONTEXT_OpenURL was called before HTTPCONTEXT_Initialize")
  EndIf      
  ProcedureReturn *ctx
EndProcedure  


Procedure.q HTTPCONTEXT_QuerySize(*ctx.HTTPCONTEXT, *retStatusCode.integer = #Null)             
  Protected qResult.q = -1, bResult = #False, lSize.l = SizeOf(Long), sizeStringLen.i, lStatusCode.l
  Protected bDeleteRequest.i
  If g_HTTPCONTEXT_hWinHTTP
    If *ctx    
      If *ctx\hMutex
        LockMutex(*ctx\hMutex)
      EndIf  
      
      bResult = #False     
      ;Always generate new request   
      If *ctx\hRequest
        __HTTPCONTEXT_DeleteRequest(*ctx)
      EndIf  
      
      If __HTTPCONTEXT_CreateRequest(*ctx, #HTTPCONTEXT_REQUEST_HEAD)  
        If *ctx\hRequest  
          bResult = WinHttpSendRequest( *ctx\hRequest, #WINHTTP_NO_ADDITIONAL_HEADERS, 0, #WINHTTP_NO_REQUEST_DATA, 0, 0, 0)
        EndIf
      EndIf
      
      ;If failed, then we try to reconnect...
      If bResult = #False
        __DANGEROUS_HTTPCONTEXT_Debug("WinHttpSendRequest failed for URL " + Chr(34) + *ctx\sFullPath + Chr(34)+ " with error code " + Str(GetLastError_()) + " try To reconnect...")
        If __HTTPCONTEXT_OpenConnection(*ctx)
          ;If successful, then try again
          If __HTTPCONTEXT_CreateRequest(*ctx, #HTTPCONTEXT_REQUEST_HEAD)
            If *ctx\hRequest  
              bResult = WinHttpSendRequest( *ctx\hRequest, #WINHTTP_NO_ADDITIONAL_HEADERS, 0, #WINHTTP_NO_REQUEST_DATA, 0, 0, 0)  
            EndIf  
          EndIf    
        Else
          __DANGEROUS_HTTPCONTEXT_Error("Failed to reconnect!")
        EndIf  
      EndIf  
      
      If bResult         
        If WinHttpReceiveResponse(*ctx\hRequest, #Null)     
          If WinHttpQueryHeaders(*ctx\hRequest, #WINHTTP_QUERY_FLAG_NUMBER | #WINHTTP_QUERY_STATUS_CODE, #WINHTTP_HEADER_NAME_BY_INDEX, @lStatusCode, @lSize, #WINHTTP_NO_HEADER_INDEX) 
            ;HTTP Status codes
            ; 200 OK
            ; 201 Created
            ; 202 Accepted
            ; 203 Non-Authoritative Information
            ; 204 No Content
            ; 205 Reset Content
            ; 206 Partial Content             

            If *retStatusCode
              *retStatusCode\i = lStatusCode  
            EndIf
            
            If lStatusCode = 200 Or lStatusCode = 206  Or lStatusCode = 204 ;(204 = No Content) ; 206 seems to be returned for Range downloads...            
              sizeStringLen = #MAX_PATH - 1 ; StringByteLength(sizeString)
              If WinHttpQueryHeaders(*ctx\hRequest, #WINHTTP_QUERY_CONTENT_LENGTH, #WINHTTP_HEADER_NAME_BY_INDEX, @*ctx\TmpString, @sizeStringLen, #WINHTTP_NO_HEADER_INDEX)            
                qResult = Val(*ctx\TmpString) ; WARNING: STILL PUREBASIC FUNCTION (But should be no problem, because Val should not call hooked Kernel API)
              EndIf   
            Else
              ;Delete because request can be reused only if all bytes are read...
              bDeleteRequest = #True
              __DANGEROUS_HTTPCONTEXT_Error("query size status code " + Str(lStatusCode))
            EndIf           
          Else
            __DANGEROUS_HTTPCONTEXT_Error("WinHttpQueryHeaders failed with error code " + Str(GetLastError_()) + "!")        
          EndIf
        Else
          __DANGEROUS_HTTPCONTEXT_Error("WinHttpReceiveResponse failed with error code " + Str(GetLastError_()) + "!")
        EndIf    
      Else
        __DANGEROUS_HTTPCONTEXT_Error("WinHttpSendRequest finally failed for URL " + Chr(34) + *ctx\sFullPath + Chr(34)+ " with error code " + Str(GetLastError_()) + "!")      
      EndIf
      ;Always delete request
      __HTTPCONTEXT_DeleteRequest(*ctx)      
      If *ctx\hMutex
        UnlockMutex(*ctx\hMutex)
      EndIf
    EndIf
  Else
    __DANGEROUS_HTTPCONTEXT_Error("HTTPCONTEXT_QuerySize was called before HTTPCONTEXT_Initialize")
  EndIf
  ProcedureReturn qResult
EndProcedure  





Procedure.i HTTPCONTEXT_QueryDateTime(*ctx.HTTPCONTEXT, *retStatusCode.integer = #Null)             
  Protected iDateResult.i = 0, bResult = #False, lSize.l = SizeOf(Long), sizeSysemTimeLen.i, lStatusCode.l
  Protected systemTime.SYSTEMTIME
  
  If g_HTTPCONTEXT_hWinHTTP
    If *ctx    
      If *ctx\hMutex
        LockMutex(*ctx\hMutex)
      EndIf  
      
      bResult = #False     
      ;Always generate new request   
      If *ctx\hRequest
        __HTTPCONTEXT_DeleteRequest(*ctx)
      EndIf  
      
      If __HTTPCONTEXT_CreateRequest(*ctx, #HTTPCONTEXT_REQUEST_HEAD)  
        If *ctx\hRequest  
          bResult = WinHttpSendRequest( *ctx\hRequest, #WINHTTP_NO_ADDITIONAL_HEADERS, 0, #WINHTTP_NO_REQUEST_DATA, 0, 0, 0)
        EndIf
      EndIf
      
      ;If failed, then we try to reconnect...
      If bResult = #False
        __DANGEROUS_HTTPCONTEXT_Debug("WinHttpSendRequest failed for URL " + Chr(34) + *ctx\sFullPath + Chr(34)+ " with error code " + Str(GetLastError_()) + " try To reconnect...")
        If __HTTPCONTEXT_OpenConnection(*ctx)
          ;If successful, then try again
          If __HTTPCONTEXT_CreateRequest(*ctx, #HTTPCONTEXT_REQUEST_HEAD)
            If *ctx\hRequest  
              bResult = WinHttpSendRequest( *ctx\hRequest, #WINHTTP_NO_ADDITIONAL_HEADERS, 0, #WINHTTP_NO_REQUEST_DATA, 0, 0, 0)  
            EndIf  
          EndIf    
        Else
          __DANGEROUS_HTTPCONTEXT_Error("Failed to reconnect!")
        EndIf  
      EndIf  
      
      If bResult         
        If WinHttpReceiveResponse(*ctx\hRequest, #Null)   
                    
          If *retStatusCode
            If WinHttpQueryHeaders(*ctx\hRequest, #WINHTTP_QUERY_FLAG_NUMBER | #WINHTTP_QUERY_STATUS_CODE, #WINHTTP_HEADER_NAME_BY_INDEX, @lStatusCode, @lSize, #WINHTTP_NO_HEADER_INDEX) 
                ;HTTP Status codes
                ; 200 OK
                ; 201 Created
                ; 202 Accepted
                ; 203 Non-Authoritative Information
                ; 204 No Content
                ; 205 Reset Content
                ; 206 Partial Content                         
                *retStatusCode\i = lStatusCode            
            Else
              __DANGEROUS_HTTPCONTEXT_Error("WinHttpQueryHeaders failed with error code " + Str(GetLastError_()) + "!")        
            EndIf           
          EndIf
          
          ;If lStatusCode = 200 Or lStatusCode = 206  Or lStatusCode = 204 ;(204 = No Content) ; 206 seems to be returned for Range downloads...            
          sizeSysemTimeLen = SizeOf(SYSTEMTIME) ; StringByteLength(sizeString)
          If WinHttpQueryHeaders(*ctx\hRequest, #WINHTTP_QUERY_DATE|#WINHTTP_QUERY_FLAG_SYSTEMTIME , #WINHTTP_HEADER_NAME_BY_INDEX, @systemTime, @sizeSysemTimeLen, #WINHTTP_NO_HEADER_INDEX)            
            iDateResult = Date(systemTime\wYear, systemTime\wMonth, systemTime\wDay, systemTime\wHour, systemTime\wMinute, systemTime\wSecond)   
          Else
            __DANGEROUS_HTTPCONTEXT_Error("query date status code " + Str(lStatusCode))
          EndIf                     
          
        Else
          __DANGEROUS_HTTPCONTEXT_Error("WinHttpReceiveResponse failed with error code " + Str(GetLastError_()) + "!")
        EndIf    
      Else
        __DANGEROUS_HTTPCONTEXT_Error("WinHttpSendRequest finally failed for URL " + Chr(34) + *ctx\sFullPath + Chr(34)+ " with error code " + Str(GetLastError_()) + "!")      
      EndIf
      ;Always delete request
      __HTTPCONTEXT_DeleteRequest(*ctx)      
      If *ctx\hMutex
        UnlockMutex(*ctx\hMutex)
      EndIf
    EndIf
  Else
    __DANGEROUS_HTTPCONTEXT_Error("HTTPCONTEXT_QueryDateTime was called before HTTPCONTEXT_Initialize")
  EndIf
  ProcedureReturn iDateResult
EndProcedure  


Procedure HTTPCONTEXT_Download(*ctx.HTTPCONTEXT, useRange.i, startPos.q, endPos.q, *retPtr.integer, *retSize.integer, *retStatusCode.integer = #Null)
  Protected bDeleteRequest = #False, bSuccess.i = #False, lCompleteSize.i = 0,lCurrentSize.i = 0, lSize.l = SizeOf(Long), lBytesRead.i = 0 
  Protected sHeader.s, bResult.i, lStatusCode.i, *headerPtr.Character, *tmpHeaderPtr.Character
  If g_HTTPCONTEXT_hWinHTTP
    If *ctx    
      If *ctx\hMutex
        LockMutex(*ctx\hMutex)
      EndIf  
      
      ;If useRange
      ;  sHeader.s = "Range: bytes=" + Str(startPos) + "-" + Str(endPos) + #CRLF$    
      ;Else
      ;  sHeader.s = ""
      ;EndIf  
      
      If useRange
        *headerPtr = @*ctx\HeaderDataString     
        *tmpHeaderPtr = *headerPtr + lstrlen_(@"Range: bytes=") * SizeOf(Character)
        *tmpHeaderPtr + __Int64ToStr(*tmpHeaderPtr, startPos) * SizeOf(Character)
        PokeC(*tmpHeaderPtr, '-')
        *tmpHeaderPtr + SizeOf(Character)
        *tmpHeaderPtr + __Int64ToStr(*tmpHeaderPtr, endPos) * SizeOf(Character)   
        PokeC(*tmpHeaderPtr, #CR)
        *tmpHeaderPtr + SizeOf(Character)        
        PokeC(*tmpHeaderPtr, #LF)      
        *tmpHeaderPtr + SizeOf(Character)        
        PokeC(*tmpHeaderPtr, 0)         
      Else
        *headerPtr = @""
      EndIf  
      
      ;Debug PeekS(*headerPtr)
        
      bResult = #False   
      
      If *ctx\requestType <> #HTTPCONTEXT_REQUEST_GET And *ctx\hRequest
        ;Header must be regenerated...
        __HTTPCONTEXT_DeleteRequest(*ctx)
      EndIf       
      
      If *ctx\hRequest = #Null
        __HTTPCONTEXT_CreateRequest(*ctx, #HTTPCONTEXT_REQUEST_GET)
      EndIf  
      If *ctx\hRequest  
        bResult = WinHttpSendRequest( *ctx\hRequest, *headerPtr, -1, #WINHTTP_NO_REQUEST_DATA, 0, 0, 0)
        ;bResult = WinHttpSendRequest( *ctx\hRequest,  #WINHTTP_NO_ADDITIONAL_HEADERS, 0, #WINHTTP_NO_REQUEST_DATA, 0, 0, 0) 
      EndIf
      
      ;If failed, then we try to reconnect...
      If bResult = #False
        __HTTPCONTEXT_Debug("WinHttpSendRequest failed for URL " + Chr(34) + *ctx\sFullPath + Chr(34)+ " with error code " + Str(GetLastError_()) + " try To reconnect...")
        If __HTTPCONTEXT_OpenConnection(*ctx)
          ;If successful, then try again
          If __HTTPCONTEXT_CreateRequest(*ctx, #HTTPCONTEXT_REQUEST_GET)
            bResult = WinHttpSendRequest( *ctx\hRequest, *headerPtr, -1, #WINHTTP_NO_REQUEST_DATA, 0, 0, 0)  
          EndIf    
        Else
          __DANGEROUS_HTTPCONTEXT_Error("Failed to reconnect!")
        EndIf  
      EndIf  
      
      If bResult 
        If WinHttpReceiveResponse(*ctx\hRequest, #Null) 
          If WinHttpQueryHeaders(*ctx\hRequest, #WINHTTP_QUERY_FLAG_NUMBER | #WINHTTP_QUERY_STATUS_CODE, #WINHTTP_HEADER_NAME_BY_INDEX, @lStatusCode, @lSize, #WINHTTP_NO_HEADER_INDEX) 
            ;HTTP Status codes
            ; 200 OK
            ; 201 Created
            ; 202 Accepted
            ; 203 Non-Authoritative Information
            ; 204 No Content
            ; 205 Reset Content
            ; 206 Partial Content             

            If *retStatusCode
              *retStatusCode\i = lStatusCode  
            EndIf
            
            
            If lStatusCode = 200 Or lStatusCode = 206  Or lStatusCode = 204 ;(204 = No Content) ; 206 seems to be returned for Range downloads...            
              ;
              ;bResult = WinHttpSendRequest( *ctx\hRequest, @sHeader, -1, #WINHTTP_NO_REQUEST_DATA, 0, 0, 0)
              
              While (WinHttpQueryDataAvailable(*ctx\hRequest, @lCurrentSize))
                
                If lCurrentSize = 0
                  Break
                EndIf  
                
                If *ctx\resultBuffer = #Null
                  *ctx\resultBuffer = AllocateMemory(lCurrentSize)
                  If *ctx\resultBuffer
                    *ctx\resultSize = lCurrentSize
                  EndIf 
                EndIf  
                
                If *ctx\resultBuffer
                  If (lCompleteSize + lCurrentSize > *ctx\resultSize) And *ctx\resultBuffer
                    *ctx\resultBuffer = ReAllocateMemory(*ctx\resultBuffer, lCompleteSize + lCurrentSize)
                    *ctx\resultSize = lCompleteSize + lCurrentSize
                  EndIf
                EndIf
                
                If *ctx\resultBuffer = #Null  
                  bDeleteRequest = #True
                  Break
                EndIf
                
                lBytesRead = 0
                If *ctx\hRequest
                  WinHttpReadData(*ctx\hRequest, *ctx\resultBuffer + lCompleteSize, lCurrentSize, @lBytesRead)
                EndIf
                lCompleteSize + lBytesRead
                lCurrentSize = 0
              Wend
              
              If *ctx\resultBuffer And lCompleteSize > 0 And *retPtr
                *retPtr\i = GlobalAlloc_(#GMEM_FIXED, lCompleteSize) 
                If *retPtr\i
                  CopyMemory(*ctx\resultBuffer, *retPtr\i, lCompleteSize)
                  bSuccess = #True
                EndIf  
                If *retSize
                  *retSize\i = lCompleteSize
                EndIf    
              EndIf              
              
            Else
              ;Delete because request can be reused only if all bytes are read...
              bDeleteRequest = #True
              __DANGEROUS_HTTPCONTEXT_Error("Download failed with status code "+Str(lStatusCode))
            EndIf
            
          Else
            __DANGEROUS_HTTPCONTEXT_Error("WinHttpQueryHeaders failed with error code " + Str(GetLastError_()) + "!")        
          EndIf
        Else
          __DANGEROUS_HTTPCONTEXT_Error("WinHttpReceiveResponse failed with error code " + Str(GetLastError_()) + "!")
        EndIf    
      Else
        __DANGEROUS_HTTPCONTEXT_Error("WinHttpSendRequest finally failed for URL " + Chr(34) + *ctx\sFullPath + Chr(34)+ " with error code " + Str(GetLastError_()) + "!")      
      EndIf
      If bDeleteRequest
        __HTTPCONTEXT_DeleteRequest(*ctx)    
      EndIf  
      If *ctx\hMutex
        UnlockMutex(*ctx\hMutex)
      EndIf
    EndIf
  Else
    __DANGEROUS_HTTPCONTEXT_Error("HTTPCONTEXT_Download was called before HTTPCONTEXT_Initialize")
  EndIf
  ProcedureReturn bSuccess
EndProcedure


;{ Sample
;DisableExplicit
; Debug __PROXY_GetProxy()
; HTTPCONTEXT_Initialize()
;  ctx = HTTPCONTEXT_OpenURL("http://wikimedia.de/images/7/7c/WIKIMEDIUM-04-2010.pdf","Test",#True,"67.159.44.24:80", #True, #False, #False)
;  Debug HTTPCONTEXT_QuerySize(ctx)
;  Debug HTTPCONTEXT_Download(ctx, 1, 0,HTTPCONTEXT_QuerySize(ctx)-1,@addr,@sz)
;  Debug addr
;  Debug sz
;  
;  CreateFile(1,"D:\test\test.pdf")
;  WriteData(1,addr,sz)
;  CloseFile(1)
; ; 
; ; 
; HTTPCONTEXT_Close(ctx)
; HTTPCONTEXT_UnInitialize()
;}

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 551
; FirstLine = 549
; Folding = ---
; EnableUnicode
; EnableXP
; EnableCompileCount = 6
; EnableBuildCount = 0
; EnableExeConstant