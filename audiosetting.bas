/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Audio Settings                                           *
 *                                                                                     *
 * Copyright (c) 2008 - GoDB Tech Private Limited. All rights reserved.                *
 * THIS SOURCE CODE IS PROVIDED AS-IS WITHOUT ANY EXPRESSED OR IMPLIED                 *
 * WARRANTY OF ANY KIND INCLUDING THOSE OF MERCHANTABILITY, NONINFRINGEMENT            *
 * OF THIRD-PARTY INTELLECTUAL PROPERTY, OR FITNESS FOR A PARTICULAR PURPOSE.          *
 * NEITHER GoDB NOR ITS SUPPLIERS SHALL BE LIABLE FOR ANY DAMAGES WHATSOEVER           *
 * (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS,               *
 * BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER LOSS)                 *
 * ARISING OUT OF THE USE OF OR INABILITY TO USE THE SOFTWARE, EVEN IF GoDB            *
 * HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.                                *
 *                                                                                     *
 * DO-NOT COPY,DISTRIBUTE,EMAIL,STORE THIS CODE WITHOUT PRIOR WRITTEN                  *
 * PERMISSION FROM GoDBTech.                                                           *
\***************************************************************************************/
/*
Call this page to view and set audio setting
*/
option(4+1)

dimi timerCount

#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"

dimi noofctrl
noofctrl = getfldcount()-LEFTMENUCTRLS
dims LabelName$(noofctrl)
dimi XPos(noofctrl)
dimi YPos(noofctrl)
dimi Wdh(noofctrl)
dimi height(noofctrl)

#include "audiosetting.inc"

dimi rule
showcursor(3)
~wait = 2 								'added by Franklin to set wait flag when switching between forms
dims sliderImage$						'TR-19 Holds slider button image
settimer(1000)
dimi displayCount,isMessageDisplayed			'TR-35  
displayCount = 1								'TR-35

dims ctrlValues$(noofctrl)
dimi animateCount = 0 	 ' Stores the count for the animation done.
dimi saveSuccess = 0	 'Value of 1 is success
dims error$ = "" 		 'Stores the error returned while saving.
dimi tempX				 ' Holds sucess message label
end

/***********************************************************
'** Form_Load
 *	Description: Call displayControls function to algin contorls
 *				 based on the screen resolution.
 *				 Call loadInitialValues function to fetch values 
 *				 from camera and assign the same to controls.
 *				 Highlight the selected link in left menu.
 *	Created by: vimala On 2009-04-03 18:04:29
 *	History: 
 ***********************************************************/
Sub Form_Load
	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	call loadInitialValues()	
	
	showSubMenu(0,1)
	setfocus("rosubmenu[4]")
	selectSubMenu()	
	setfocus("chkenableaudio")
	call chkenableAudio_Click									'TR-19
	
	getimagefile(sliderImage$,"!slider_but.jpg")
	#lblsuccessmessage$ = ""									'TR-35
		
End Sub

/***********************************************************
'** Form_Complete
 *	Description: Store all the control values in an array to validate changes in form.

 *	Created by: Vimala On 2010-05-03 12:04:49
 ***********************************************************/
Sub Form_Complete	
	dimi i
	for i = 0 to ubound(ctrlValues$)-1		
		ctrlValues$(i) = #{LabelName$(i)}$		
	next
	
	if canReload = 1 and ~UrlToLoad$ <> "" then		
		Dims ChangeUrl$
		ChangeUrl$ = ~UrlToLoad$
		~UrlToLoad$ = ""
		LoadUrl(ChangeUrl$)
	end If
End Sub


/***********************************************************
'** form_timer
 *	Description: To show and hide save success message 	
 
 *	Created by:Vimala  On 2009-12-21 02:53:01
 ***********************************************************/
Sub form_timer	
	'TR-35 
	if isMessageDisplayed = 1 then			
		displayCount++
		if displayCount = 5 then 			
			isMessageDisplayed = 0
			displayCount = 1	
			#lblsuccessmessage$ = ""
			update
		end if
	end if
	
	if canReload = 0 then
		if animateCount <= ~reLoadTime then
			animateCount ++
			animateLabel("lblsuccessmessage","Updating Camera")				'animate updating... value
		else
			call displaySaveStatus(saveSuccess)
		end if
	end if	
End Sub

/***********************************************************
'** loadInitialValues
 *	Description: Call this function to fetch values from camera 
 *				 and assign the same to screen controls.
 
 *	Created by: Vimala  On 2009-04-03 18:05:08
 ***********************************************************/
Sub loadInitialValues()
	
	dimi retVal
	dimi enableAudio,audioMode,inputVolume	
	dimi encoding,sampleRate,bitRate,alarmLevel,outputVolume
	
	' TR-26	
	retVal = getAudioSetting(enableAudio,audioMode,inputVolume,_
							 encoding,sampleRate,bitRate, _
							 alarmLevel,outputVolume)

	if retVal = -1 then
		msgbox("Unable to fetch  values")
		return
	endif
	
	#rocameraname$ = ~title$
	#chkenableaudio$ = enableAudio
	#sldaudioinput = inputVolume							    ' TR-26
	#txtAudioInput$ = inputVolume							    ' TR-26
	#sldAlarmLevel = alarmLevel
	#txtAlarmLevel$ = alarmLevel
	#sldAudioOutput = outputVolume
	#txtAudioOutput$= outputVolume
	
	'Get and Load drop down values
	dims audioMode$(1),encoding$(1),sampleRate$(1),bitRate$(1)		
	retVal = getAudioOptions(audioMode$,encoding$,sampleRate$,bitRate$)
	
	if retVal = 0 then	
		call addItemsToDropDown("drpaudiomode",audioMode$,audioMode)	
		call addItemsToDropDown("drpencoding",encoding$,encoding)		
		call addItemsToDropDown("drpsamplerate",sampleRate$,sampleRate)		
		call addItemsToDropDown("drpbitrate",bitRate$,bitRate)		
	endif
	
	'TR-19  Disable and gray alarm level label,slider and corresponding text box
	#sldalarmlevel.disabled = 1
	#sldalarmlevel = 0
	#txtalarmlevel.disabled = 1
	#sldalarmlevel.fg = UNSELECTED_TXT_COLOR	
	#sldalarmlevel.selfg = UNSELECTED_TXT_COLOR	
	#sldalarmlevel.bg = UNSELECTED_BG_COLOR	
	#sldalarmlevel.selbg = UNSELECTED_BG_COLOR
	#sldalarmlevel.brdr = UNSELECTED_BG_COLOR
	#sldalarmlevel.selbrdr = UNSELECTED_BG_COLOR	
	#lblalarmLevel.fg = UNSELECTED_TXT_COLOR
	#lblalarmLevel.selfg = UNSELECTED_TXT_COLOR
	#txtalarmlevel.fg = UNSELECTED_TXT_COLOR
	#txtalarmlevel.selfg = UNSELECTED_TXT_COLOR		
	#txtalarmlevel.bg = UNSELECTED_BG_COLOR	
	#txtalarmlevel.selbg = UNSELECTED_BG_COLOR
	#txtalarmlevel.brdr = UNSELECTED_BG_COLOR
	#txtalarmlevel.selbrdr = UNSELECTED_BG_COLOR	
End Sub


/***********************************************************
'** Form_Paint
 *	Description: Paint gray slider image for alarm level and 
				 gray audio mode drop down image when enable audio is disabled
				 
 *	Created by: Vimala  On 2009-11-05 15:51:11
 ***********************************************************/
Sub Form_Paint						'TR-19 
	
	putimage2(sliderImage$,#sldalarmlevel.x,#sldalarmlevel.y,5,0,0)
	
	if #chkenableAudio.checked = 0 then 		
		putimage2(~drpImage$,#drpaudioMode.x+#drpaudioMode.w,#drpaudioMode.y-2,5,0,0)
	end if
	
End Sub




/***********************************************************
'** sldAudioInput_Change
 *	Description: Assign slider value to text box
 
 *	Created by: vimala On 2009-05-19 11:01:46
 ***********************************************************/
Sub sldAudioInput_Change		
	 #txtAudioInput$ = trim$(#sldAudioInput)
End Sub


/***********************************************************
'** txtAudioInput_Change
 *	Description:  Assign text value to slider
 
 *	Created by: vimala On 2009-05-19 11:02:05
 ***********************************************************/
Sub txtAudioInput_Change	
	 #sldAudioInput = #txtAudioInput
End Sub

/***********************************************************
'** sldAlarmLevel_Change
 *	Description:Assign slider value to text box 
 
 *	Created by: vimala On 2009-05-19 11:02:07

 ***********************************************************/
Sub sldAlarmLevel_Change	
	 #txtAlarmLevel$ = trim$(#sldAlarmLevel)
End Sub


/***********************************************************
'** txtAlarmLevel_Change
 *	Description:Assign text value to slider
 
 *	Created by: vimala On 2009-05-19 11:03:01
 ***********************************************************/
Sub txtAlarmLevel_Change	
	 #sldAlarmLevel = #txtAlarmLevel
End Sub

/***********************************************************
'** sldAudioOutput_Change
 *	Description: Assign slider value to text box
 
 *	Created by: vimala On 2009-05-19 11:02:15
 ***********************************************************/
Sub sldAudioOutput_Change	
	 #txtAudioOutput$ = trim$(#sldAudioOutput)
End Sub


/***********************************************************
'** txtAudioOutput_Change
 *	Description: Assign text value to slider
 
 *	Created by: vimala On 2009-05-19 11:02:30
 ***********************************************************/
Sub txtAudioOutput_Change
	 #sldAudioOutput = #txtAudioOutput
End Sub


/***********************************************************
'** Form_KeyPress
 *	Description: Checks entered key value based on the rule 
				 set to that user input control	 
 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by: Vimala On 2009-05-11 06:09:54
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )	
	scroll_keypressed(key)
	
	dims keypressed$		
	keypressed$ = chr$(Key)

	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)	
	
	setSubMenuFocus(Key,3)
	
End Sub

/***********************************************************
'** cmdsave_Click
 *	Description: call savePage to save values to the camera.
 
 *	Created by: Vimala On 2009-05-20 23:29:04
 ***********************************************************/
Sub cmdsave_Click	
	if canReload = 1 then
		savePage()		
	end if
End Sub


/***********************************************************
'** savePage
 *	Description:  validatemodecontrols() function checks for valid data.
 *				 Saves the control values to camera.
 
 *	Created by: Vimala  On 2009-05-28 16:34:07
 ***********************************************************/
Sub savePage()
	'Validate user input controls values
	pprint "audiosetting.bas"
	iff validatemodecontrols() = 0 then return	
		
	dimi retVal,i
	' TR-26 set values to camera
	retVal = setAudioSetting(#chkenableaudio,#drpaudiomode,atol(#sldaudioinput$),_
							 #drpencoding,#drpsamplerate,#drpbitrate,_
							 #sldalarmlevel,atol(#sldaudiooutput$))
	

	saveSuccess = retVal
	tempX = #lblsuccessmessage.x
	'Based on reload flag wait for the camera to restart
	if getReloadFlag() = 1 then								'TR-45				
		#lblsuccessmessage.style = 128
		#lblsuccessmessage.x = #lblsuccessmessage.x + #lblsuccessmessage.w/3
		canReload = 0
		animateCount = 1
		call animateLabel("lblsuccessmessage","Updating Camera")
	else // If Reload animation is not required
		canReload = 1
	end if
	
	if canReload = 1 Then	//Do the remaining actions after reload animation is done
		call displaySaveStatus(saveSuccess)		
	end if	
End Sub


/***********************************************************
'** displaySaveStatus
 *	Description: Call this function to display saved message 
 *		
 *	Created by: Vimala On 2010-06-24 14:39:10
 *	History: 
 ***********************************************************/
Sub displaySaveStatus(dimi saveStatus)
	if saveStatus > 0 then 		
//		#lblsuccessmessage.style = 64
//		#lblsuccessmessage.x = tempX  
//		#lblsuccessmessage$ = "音频设置已保存到系统 "+~title$		'TR-35	
//		isMessageDisplayed = 1												'TR-35	
//		#lblsuccessmessage.paint(1)
	else 		
		if ~keywordDetFlag = 1 then	
			msgbox("Audio setting for \n "+~errorKeywords$+"\nfailed for the camera "+~title$)
		else
			msgbox("Audio setting failed for the camera "+~title$)
		endif	
	end if
	
	call loadInitialValues()	
	setfocus("chkenableaudio")
	~changeFlag = 0	
	canReload = 1	
	call Form_complete()
End Sub



/***********************************************************
'** validatemodecontrols
 *	Description: Call this function to validate control values.
 *  Returns : 1 - All the values are valid
 *			  0 - for invalid control values 
 
 *	Created by:Vimala On 2009-05-17 22:34:46
 ***********************************************************/
Function validatemodecontrols()	
	validatemodecontrols = 1
	
	if #txtaudioinput$ = "" then
		msgbox("Enter Gain Value")
		setfocus("txtaudioinput")	
		validatemodecontrols = 0
		return
	elseif #txtaudioinput > 100 then
		msgbox("Gain Value should range from 0 - 100")
		setfocus("txtaudioinput")	
		validatemodecontrols = 0
		return
	elseif #txtalarmlevel$ ="" then
		msgbox("Enter Alarm Level")
		setfocus("txtalarmlevel")	
		validatemodecontrols = 0
		return	
	elseif #txtalarmlevel > 100 then
		msgbox("Alarm Level should range between 0 - 100 ")
		setfocus("txtalarmlevel")	
		validatemodecontrols = 0
		return
	elseif #txtaudiooutput$ ="" then
		msgbox("Enter Output Volume")
		setfocus("txtaudiooutput")	
		validatemodecontrols = 0
		return	
	elseif #txtaudiooutput >100  then
		msgbox("Output Volume should range from 0 - 100")
		setfocus("txtaudiooutput")	
		validatemodecontrols = 0
		return	
	endif	

End Function	


/***********************************************************
'** cmdcancel_Click
 *	Description: Call loadInitialValues values to 
 *				 load values from camera.
 
 *	Created by: vimala On 2009-05-19 11:11:35
 ***********************************************************/
Sub cmdcancel_Click	
	if canReload = 1 then
		~changeFlag = 0	
		call loadInitialValues()
	end if
End Sub



Sub Form_MouseMove( x, y )
	'Please don't delete for slider control
End Sub


'set key press rule for user input controls
Sub txtAudioInput_Focus
	rule = 7 
End Sub

Sub txtAlarmLevel_Focus
	rule = 7 
End Sub

Sub txtAudioOutput_Focus
	rule = 7 
End Sub

'Display cursor in control focus event else hide cursor
Sub chkenableAudio_Blur
	showcursor(3)
End Sub

Sub chkenableAudio_Focus
	showcursor(1)
End Sub


/***********************************************************
'** chkenableAudio_Click
 *	Description: if enable audio check box is uncheck ,gray out audio mode control
 
 *	Created by:vimala  On 2009-11-05 19:22:13
 ***********************************************************/
Sub chkenableAudio_Click					'TR-19	
	if #chkenableAudio.checked = 0 then 
		grayOutCtrls(1,UNSELECTED_TXT_COLOR,UNSELECTED_BG_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_BG_COLOR)				
	else 
		grayOutCtrls(0,38166,40180,1,10961)	
	end if
End Sub


/***********************************************************
'** grayOutCtrls
 *	Description: Call this function to set control fg,bg and border color .
 *				
 *	Params:
'*		disableFlag: Numeric - Holds disable value (0-enable/1 - disable)
'*		fgColor: Numeric - Display Foreground color
'*		bgColor: Numeric - Control Background color
'*		brdrColor: Numeric - Control border color
 *		selBgColor: Numeric -  control selected back ground color
 *	Created by: Vimala On 2009-11-05 19:19:12
 *	History: 
 ***********************************************************/
Sub grayOutCtrls(disableFlag,fgColor,bgColor,brdrColor,selBgColor)				'TR-19	
	#lblaudiomode.fg = fgColor
	#lblaudiomode.selfg = fgColor
	#drpaudiomode.disabled = disableFlag
	#drpaudiomode.fg = brdrColor
	#drpaudiomode.selfg = brdrColor	
	#drpaudiomode.bg = bgColor	
	#drpaudiomode.brdr = bgColor	
	iff disableFlag = 0 then #drpaudiomode.brdr = brdrColor	
	#drpaudiomode.selbrdr = brdrColor	
	#drpaudiomode.selbg = selBgColor	
End Sub



/***********************************************************
'** chkValueMismatch
 *	Description: Call this function to check whether the control values are modified or not.
 *				 set ~changeFlag = 1 if control value modified.

 *	Created by: Vimala On 2010-04-30 18:01:13
 ***********************************************************/
sub chkValueMismatch()	
	checkForModification(ctrlValues$, LabelName$)
End Sub


