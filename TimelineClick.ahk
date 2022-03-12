#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0

FileCreateDir, %A_Temp%\wtc_images
FileInstall, images\EditPageTimelineSettings.png, %A_Temp%\wtc_images\EditPageTimelineSettings.png, true
FileInstall, images\FairlightClock.png, %A_Temp%\wtc_images\FairlightClock.png, true
FileInstall, images\CutPageSplitClip.png, %A_Temp%\wtc_images\CutPageSplitClip.png, true

lastWinPressTime = -9999999
;Example for Davinci Resolve
#IfWinActive ahk_exe Resolve.exe
{
LWin::
	if (A_TickCount < lastWinPressTime + 200) {
		Send {LWin}
		return
	}
	lastWinPressTime := A_TickCount
	timelineClick([A_Temp . "\wtc_images\EditPageTimelineSettings.png", A_Temp . "\wtc_images\FairlightClock.png",  A_Temp . "\wtc_images\CutPageSplitClip.png"], [[27,17],[14,15],[17,25]], [45,30,45])
	return
}


timelineClick(images,imageSizes, yOffsets)
{	
	static s_lastImage, s_TagX, s_TagY	
	;convert single properties to array just for funsies
	If !IsObject(images)
		images := [images]
	If !IsObject(imageSizes[1])
		imageSizes := [imageSizes]
	If !IsObject(yOffsets)
		yOffsets := [yOffsets]
		
	
	BlockInput, MouseMove
	MouseGetPos, MouseX, MouseY 
	prevMouseY := MouseY
	;Check for image in last position	
	Try
	{
		searchImage := images[s_lastImage]
		Imagesearch, , , s_TagX, s_TagY, (s_TagX+imageSizes[s_lastImage][1]), (s_TagY+imageSizes[s_lastImage][2]), %searchImage%		
		if ErrorLevel > 0
			{
			throw
			}
	}
	catch e 
	{
		;look everywhere for all the images        
		for image in images
			{
			searchImage := images[image]
			ImageSearch, s_TagX, s_TagY, 0, 15, %A_ScreenWidth%, %A_ScreenHeight%, %searchImage%
			if ErrorLevel > 0
				{
				continue
				}
			else
				{
				;Success
				s_lastImage := image
				break
				}
		If ErrorLevel > 0
			{
			msgbox, Couldn't find reference image.
			Return
			}
			}
	}
	MouseClick, Left, MouseX, s_TagY + yOffsets[s_lastImage], ,0, D
	MouseMove, MouseX, MouseY, 0
	BlockInput, MouseMoveOff
	while (true) {
		Sleep, 10
		GetKeyState, keystate, LWin, P
		if keystate = U
		   break
	}
	Click, up
	; MouseGetPos, newMouseX, newMouseY 
	; MouseClick, Left, newMouseX, newMouseY, , 0, D
	Return
}
