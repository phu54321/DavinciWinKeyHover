#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force

SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0
CoordMode, Mouse, Pixel

FileCreateDir, %A_Temp%\wtc_images
FileInstall, images\timeline_edit_marker.png, %A_Temp%\wtc_images\timeline_edit_marker.png, true
FileInstall, images\timeline_fairlight_marker.png, %A_Temp%\wtc_images\timeline_fairlight_marker.png, true
FileInstall, images\timeline_edit_tabs_marker.png, %A_Temp%\wtc_images\timeline_edit_tabs_marker.png, true

FileInstall, images\zoom_inactive.png, %A_Temp%\wtc_images\zoom_inactive.png, true
FileInstall, images\zoom_active.png, %A_Temp%\wtc_images\zoom_active.png, true

FileInstall, images\position_inactive.png, %A_Temp%\wtc_images\position_inactive.png, true
FileInstall, images\position_active.png, %A_Temp%\wtc_images\position_active.png, true

lastWinPressTime = -9999999
;Example for Davinci Resolve

#IfWinActive ahk_exe Resolve.exe
	LWin::
		if (A_TickCount < lastWinPressTime + 200) {
			Send {LWin}
			return
		}
		lastWinPressTime := A_TickCount
		timelineClick([A_Temp . "\wtc_images\timeline_fairlight_marker.png"
			, A_Temp . "\wtc_images\timeline_edit_tabs_marker.png"
			, A_Temp . "\wtc_images\timeline_edit_marker.png"]
			, [[51,29],[27,27],[27,17]], [50,50,40])
	return

	; Zoom X
	F1::
		SliderClick("F1"
			, [A_Temp . "\wtc_images\zoom_inactive.png"
			, A_Temp . "\wtc_images\zoom_active.png"]
			, [150, 30], [176, 15])
	return

	; Zoom Y
	F2::
		SliderClick("F2"
			, [A_Temp . "\wtc_images\zoom_inactive.png"
			, A_Temp . "\wtc_images\zoom_active.png"]
			, [150, 30], [295, 15])
	return

	; Position X
	F3::
		SliderClick("F3"
			, [A_Temp . "\wtc_images\position_inactive.png"
			, A_Temp . "\wtc_images\position_active.png"]
			, [150, 30], [176, 15])
	return

	; Position Y
	F4::
		SliderClick("F4"
			, [A_Temp . "\wtc_images\position_inactive.png"
			, A_Temp . "\wtc_images\position_active.png"]
			, [150, 30], [295, 15])
	return

	; -------------------------------------

	timelineClick(images,imageSizes, yOffsets)
	{
		static s_lastImage, s_TagX, s_TagY

		;convert single properties to array just for fuzziness
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
				ImageSearch, s_TagX, s_TagY, 0, 0, A_ScreenWidth, A_ScreenHeight, %searchImage%
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
			}
			If ErrorLevel > 0
			{
				; msgbox, Couldn't find reference image.
				BlockInput, MouseMoveOff
				Return
			}
		}

		yOffset := yOffsets[s_lastImage]
		MouseClick, Left, MouseX, s_TagY + yOffset, ,0, D
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

	SliderPosCache := Object()

	sliderClick(Key, images, imageSize, sliderFieldOffset)
	{
		static posCache
		if !posCache
			posCache := Object()

		if posCache[%Key%]
		{
			pc := posCache[%Key%]
			s_lastImage := pc[1]
			s_TagX := pc[2]
			s_TagY := pc[3]
		}

		If !IsObject(images)
			images := [images]

		BlockInput, MouseMove
		MouseGetPos, MouseX, MouseY
		prevMouseX := MouseX
		prevMouseY := MouseY

		Try
		{
			searchImage := images[s_lastImage]
			Imagesearch, , , s_TagX, s_TagY, (s_TagX+imageSize[1]), (s_TagY+imageSize[2]), %searchImage%
			if ErrorLevel > 0
			{
				throw
			}
		}
		catch e
		{
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
			}
			if ErrorLevel > 0
			{
				; msgbox, Couldn't find reference image.
				BlockInput, MouseMoveOff
				Return
			}

			obj := [ s_lastImage, s_TagX, s_TagY ]
			posCache[%Key%] := obj
		}

		MouseClick, Left, s_TagX + sliderFieldOffset[1], s_TagY + sliderFieldOffset[2], , 0, D
		BlockInput, MouseMoveOff
		while (true)
		{
			Sleep, 10
			GetKeyState, keystate, %Key%, P
			if keystate = U
				break
		}
		Click, up
		Sleep, 50
		MouseMove, prevMouseX, prevMouseY
		Return
	}
