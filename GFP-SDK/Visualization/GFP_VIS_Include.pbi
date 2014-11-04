;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2010 RocketRider *******
;***************************************
XIncludeFile "../GFP_D3D.pbi"
XIncludeFile "../GFP_Sprite3D.pbi"

Interface IVisualisationCanvas Extends IUnknown
  GetWidth()
  GetHeight()
  UpdateSample()
  GetSampleSize()
  GetSampleChannels()
  GetSampleBitsPerSample()
  GetSampleBitsSamplesPerSec()
  ReadSample.d(iPosition)
  GetMediaLength()
  GetMediaPosition()
  GetD3DDevice9()
  BeginScene()
  EndScene()
  GetHWND()
  CanRender()
  GetUserData()
  SetUserData(value.i)
  Clear(RGB.i)
EndInterface
; IDE Options = PureBasic 4.41 (Windows - x86)
; CursorPosition = 4
; EnableXP
; EnableUser
; EnableCompileCount = 1
; EnableBuildCount = 0
; EnableExeConstant