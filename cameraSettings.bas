/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Mode Setting                                                *
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
Call this page to view and set camera setting
*/

option(4+1)
dimi timerCount

#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"

#define SELECTED_TXT_COLOR      1
#define SELECTED_BRD_COLOR	  	6439
#define SELECTED_BG_COLOR	    40180
#define SELECTED_SELBG_COLOR    10961

#define UNSELECTED_TXT_COLOR      17004
#define UNSELECTED_BRD_COLOR	  14826
#define UNSELECTED_BG_COLOR	      14826

#define GDO_X			   730	
#define GDO_Y			   85
#define GDO_W              270
#define GDO_H              160

dimi noofctrl
noofctrl = getfldcount()-LEFTMENUCTRLS
dims LabelName$(noofctrl)
dimi XPos(noofctrl)
dimi YPos(noofctrl)
dimi Wdh(noofctrl)
dimi height(noofctrl)

#include "cameraSettings.inc"

#define MINVAL 0
#define MAXVAL 255

dimi rule
showcursor(3)
settimer(1000)
dimi displayCount,isMessageDisplayed			'TR-35  
displayCount = 1								'TR-35

dims ctrlValues$(noofctrl)
dimi animateCount = 0 	 ' Stores the count for the animation done.
dimi saveSuccess = 0	 'Value of 1 is success
dims error$ = "" 		 'Stores the error returned while saving.
end

/***********************************************************
'** Form_Load
 *	Description: Call displayControls function to algin contorls
 *				 based on the screen resolution.
 *				 Call loadInitialValues function to fetch values 
 *				 from camera and assign the same to controls.
 *				 Calculate aspect ratio for the current stream and 
				 create GDO control to play Video.
 *				 Highlight the selected link in left menu.
 *	Created by: vimala On 2009-03-17 17:21:48
 *	History: 
 ***********************************************************/
Sub Form_Load	

	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	
	dimi gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight

	call displayControls(LabelName$,XPos,YPos,Wdh,height)

	Dimi xRatio,yRatio
	calVideoDisplayRatio(~previewVideoRes$,xRatio,yRatio)				' TR-04
	gdoCurX = GDO_X * ~factorX
	gdoCurY = GDO_Y * ~factorY
	gdoCurWidth  = GDO_W * ~factorX
	gdoCurHeight = GDO_H * ~factorY
	checkAspectRatio(gdoCurWidth, gdoCurHeight,xRatio,yRatio)
	#gdobg.x=gdoCurX-2
	#gdobg.y=gdoCurY-2
	#gdobg.w=gdoCurWidth+2
	#gdobg.h=gdoCurHeight+2
	
	createGDOControl("gdoVideo", gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight)
	#gdoVideo.Audio = 0
	call loadInitialValues()
	showSubMenu(0,1)
	setfocus("rosubmenu[3]")
	selectSubMenu()
	setfocus("rocamera")
	#lblloading.hidden = 1
	#lblsuccessmessage$ = ""									'TR-35 	
End Sub     

/***********************************************************
'** form_paint
 *	Description: Gray baclight drop down when Backlight drop down is disabled.
 
 *	Created by:  On 2009-09-23 15:41:35

 ***********************************************************/
sub form_paint
	if #drpBackLight.disabled=1 then 
		putimage2(~drpImage$,#drpBackLight.x+#drpBackLight.w,#drpBackLight.y-2,5,0,0)
	endif
End Sub

/***********************************************************
'** form_timer
 *	Description: To set wait flag before switching between forms	
 *				 Display save success message for 5 secs
 
 *	Created by:Franklin  On 2009-06-30 16:14:12
 ***********************************************************/
Sub form_timer
	~wait = ~wait +1
	
	'TR-35 'To show and hide save success message 	
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
			animateLabel("lblLoading","Updating")				'animate updating... value
		else
			call displaySaveStatus(saveSuccess)
		end if
	end if
	
End Sub

/***********************************************************
'** Form_complete
 *	Description: Set the properties for gdo video player to play the rtsp stream.
 
 *	Created by: Partha Sarathi.K On 2009-03-03 16:02:27
 ***********************************************************/
Sub Form_complete
	~wait=0
	call disp_streams()	
	dimi i
	
	'Store all the control values in an array to validate changes in form.
	for i = 0 to ubound(ctrlValues$)-1			
		ctrlValues$(i) = #{LabelName$(i)}$		
	next	
	
	if canReload = 1 and ~UrlToLoad$ <> "" then		
		Dims ChangeUrl$
		ChangeUrl$ = ~UrlToLoad$
		~UrlToLoad$ = ""
		LoadUrl(ChangeUrl$)
	end If
	
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
End Sub

/***********************************************************
'** disp_streams
 *	Description: Get and Play the first rtsp stream in gdo control
 
 *	Created by:  On 2009-07-31 19:01:44
 ***********************************************************/
sub disp_streams()
	dims url$,value$
	dimi ret,a
	dims stream$(3),rtspUrl$(3)
	loadStreamDetails(stream$,rtspUrl$)
	value$ = rtspUrl$(0) 
	/*a = #gdovideo.play(value$)
	#gdovideo.hidden = 0*/
	a = #gdovideo.stop(1)	
	#gdovideo.hidden = 1
	
	'check whether video stream can to displayed by ActiveX or not
	dimi playVideoFlag,fontNo,styleNo
	dims dispStr$
	
	playVideoFlag = checkForStreamRes(stream$(0))
	
	if playVideoFlag = 1 then
		dispStr$ = ~Unable_To_Display_Msg$
		#lblloading.hidden = 0		
		#gdovideo.hidden = 1			
		styleNo = 0
		#lblloading.h = 160
	else
		dispStr$ = "Updating . . . .    "
		'Play stream
		#gdovideo.hidden = 0
		a =  #gdovideo.play(value$)		
		styleNo = 8
		#gdovideo.hidden = 0
		#lblloading.h = 80
	end if
	
	#lblloading.style = styleNo	
	#lblloading$ = dispStr$
	#lblloading.w = #gdobg.w - (#gdobg.w/4)	
	#lblloading.x =  ((#gdobg.w/2) - (#lblloading.w/2)) +  #gdobg.x	
	#lblloading.y = ((#gdobg.h/2) - (#lblloading.h/2)) +  #gdobg.y
	#lblloading.paint(1)	
End Sub

/***********************************************************
'** loadInitialValues
 *	Description: call this function to fetch values from camera
 *				 and load the same in GUI controls
 *	Params:
 *	Created by: Vimala On 2009-03-11 15:10:00
 *	History: 
 ***********************************************************/
Sub loadInitialValues		
	
	dimi brightness,contrast,saturation,sharpness, backlight, ret 
	dimi blc,lbce,whiteBal,mode,expCtrl
	dimi maxExpTime,maxGain
	dimi spatialfilter,temporalfilter,videostable,lensDistCorr
	dimi imageSensor,TwoAType,histogram,TwoAMode
	dimi priority
	dimi retVal
	dims tempValue$
	
	retVal = getCameraSettings(brightness, contrast, saturation, sharpness, _
							   blc, lbce, whiteBal, mode, expCtrl, _
							   maxExpTime, maxGain, _
							   spatialfilter, temporalfilter, _
							   videostable, lensDistCorr,imageSensor, _
							   TwoAType, backlight, histogram, TwoAMode,priority)     'TR-12 ,TR-18 , TR-34
	
	if retVal = -1 then
		msgbox("Unable to fetch  values")
		return
	endif
	
	#roCamera$ = ~title$
	
	'Lighting Condition
	#slBright = brightness         
	#slContrast = contrast           
	#slSaturation = saturation       
	#slSharpness = sharpness   
	#txtBrightness$ = brightness           
	#txtContrast$ = contrast 
	#txtSaturation$ = saturation    
	#txtSharpness$ = sharpness
	#optblc$ = blc
	#optlbce$ = lbce	
	#optdaynight$ = mode  	
	#opttnf$ = temporalfilter
	#optvideostab$ = videostable
	#optlens$ = lensDistCorr
	#radhistogram$ = histogram      'TR-12 
	
	'Load drop down values	
	dims whiteBalance$(1),exposureCtrl$(1),maxExpTime$(1),maxGain$(1)
	dims spatialFilter$(1),imgSensor$(1),twoAType$(1)
	dims backlightname$(1),twoAMode$(1),priorityName$(1)
	
	retVal = getcameraSettingOptions(whiteBalance$, exposureCtrl$, maxExpTime$, maxGain$, _
								     spatialFilter$, imgSensor$,twoAType$, backlightname$,twoAMode$,priorityName$)			'TR-18, TR-34
	
	if retVal = 0 then		
		call addItemsToDropDown("drpwhitebal",whiteBalance$,whiteBal)	
		call addItemsToDropDown("drpexpcontrol",exposureCtrl$,expCtrl)		
		call addItemsToDropDown("drpexposuretime",maxExpTime$,maxExpTime)	
		call addItemsToDropDown("drpgain",maxGain$,maxGain)	
		call addItemsToDropDown("drpNFS",spatialFilter$,spatialfilter)		
		call addItemsToDropDown("drpsensor",imgSensor$,imageSensor)
		call addItemsToDropDown("drp2AEngine",twoAType$,TwoAType)			
		call addItemsToDropDown("drpBackLight",backlightname$,backlight)	
		call addItemsToDropDown("drp2amode",twoAMode$,TwoAMode)					'TR-18			
		call addItemsToDropDown("drpPriority",priorityName$,priority)			'TR-34		
	endif
	
	optBLC_Click()
		
End Sub



/***********************************************************
'** slbacklight_Change
 *	Description: Assign slider value to text box
 
 *	Created by: vimala On 2009-05-19 11:23:06
 ***********************************************************/
Sub slbacklight_Change	
	 #txtbacklight$ = trim$(#slbacklight)
End Sub


/***********************************************************
'** txtbacklight_Change
 *	Description: Assign text value to slider
 
  *	Created by: vimala On 2009-05-19 11:23:41

 ***********************************************************/
Sub txtbacklight_Change			
	 #slbacklight = #txtbacklight
End Sub

/***********************************************************
'** slbright_Change
 *	Description: Assign slider value to text box 
 
 *	Created by: vimala On 2009-05-19 11:23:44
 ***********************************************************/
Sub slbright_Change	
	 #txtbrightness$ = trim$(#slbright)
End Sub

/***********************************************************
'** txtbrightness_Change
 *	Description: Assign text value to slider
 
 *	Created by: vimala On 2009-05-19 11:25:38

 ***********************************************************/
Sub txtbrightness_Change	
	 #slbright = #txtbrightness	
End Sub


/***********************************************************
'** txtcontrast_Change
 *	Description: Assign text value to slider
 
 *	Created by: vimala On 2009-05-19 11:25:28
 ***********************************************************/
Sub txtcontrast_Change	
	 #slcontrast = #txtcontrast
End Sub

/***********************************************************
'** slcontrast_Change
 *	Description: Assign slider value to text box
 
 *	Created by: vimala On 2009-05-19 11:24:05
 ***********************************************************/
Sub slcontrast_Change	
	 #txtcontrast$ = trim$(#slcontrast)
End Sub

/***********************************************************
'** txtsharpness_Change
 *	Description: Assign text value to slider
 
 *	Created by: vimala On 2009-05-19 11:25:16 
 ***********************************************************/
Sub txtsharpness_Change	
	 #slsharpness = #txtsharpness
End Sub


/***********************************************************
'** slsharpness_Change
 *	Description: Assign slider value to text box
 
 *	Created by: vimala On 2009-05-19 11:24:18
 
 ***********************************************************/
Sub slsharpness_Change		
	#txtsharpness$ = trim$(#slsharpness)
End Sub


/***********************************************************
'** txtsaturation_Change
 *	Description: Assign text value to slider
 
 *	Created by: vimala On 2009-05-19 11:24:53
 ***********************************************************/
Sub txtsaturation_Change	
	 #slsaturation = #txtsaturation
End Sub

/***********************************************************
'** slsaturation_Change
 *	Description:  Assign slider value to text box
 
 *	Created by: vimala On 2009-05-19 11:24:41

 ***********************************************************/
Sub slsaturation_Change	
	 #txtsaturation$ = trim$(#slsaturation)
End Sub


/***********************************************************
'** cmdSave_Click
 *	Description: call savePage to save values to the camera.
 
 *	Created by: vimala On 2009-03-17 17:02:40
 ***********************************************************/
Sub cmdSave_Click	
	if canReload = 1 then
		savePage()		
		showcursor(3)
	end if
End Sub 


/***********************************************************
'** savepage
 *	Description: validatemodecontrols() function checks for valid data.
 *				 Saves the control values to camera.
 
 *	Created by:Vimala  On 2009-05-28 16:23:50
 *	History: 
 ***********************************************************/
sub savePage()
	'Validate control values
	msgbox("camerasettings.bas")
	iff validatemodecontrols() = 0 then return
	dimi a
	a = #gdoVideo.stop(1)	
	#gdoVideo.hidden = 1	
	#gdobg.paint(1)
	#lblloading$= "Updating..."
	#lblloading.paint(1)
	
	#lblloading.hidden = 0
	#lblLoading.x = #gdobg.x + (#gdobg.w-#lblLoading.w)/2
	dimi retVal,i
	
	'Set values to camera's keywords
	retVal = setCameraSettings(atol(#slBright$),atol(#slContrast$),atol(#slSaturation$),atol(#slSharpness$),_
							   #optblc,#optlbce,#drpwhitebal,#optdaynight,#drpexpcontrol,_
							   #drpexposuretime,#drpgain,#drpNFS,#opttnf,_
							   #optvideostab,#optlens,#drpsensor,#drp2AEngine,_
							   #drpbacklight,#radhistogram,#drp2amode,#drppriority)	
	saveSuccess = retVal
	'Based on reload flag wait for the camera to restart
	if getReloadFlag() = 1 then									'TR-45
		canReload = 0
		animateCount = 1
		call animateLabel("lblLoading","Updating")
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
		#lblsuccessmessage$ = "Camera setting saved to camera "+~title$		'TR-35	
		isMessageDisplayed = 1												'TR-35	
		#lblsuccessmessage.paint(1)										
	else	
		if ~keywordDetFlag = 1 then
			msgbox("Camera settings for \n"+~errorKeywords$+"\nfailed for the camera "+~title$)
		else 
			msgbox("Camera settings failed for the camera "+~title$)
		endif	
	endif
	
	call loadInitialValues()	
	#lblloading.hidden = 1		
	setfocus("slbright")
	call Form_complete()
	~changeFlag = 0	
	canReload = 1	
End Sub



/***********************************************************
'** validatemodecontrols
 *	Description: Call this function to validate control values.
 *  Returns : 1 - All the values are valid
 *			  0 - for invalid control values 
 *	Created by: vimala On 2009-03-17 17:05:05
 *	History: 
 ***********************************************************/
Function validatemodecontrols()	
	
	validatemodecontrols = 1
	if #txtbrightness$ = "" then
		msgbox("Enter Brightness value")		
		setfocus("txtbrightness")
		validatemodecontrols = 0
		return
	elseif #txtbrightness > 255 or  #txtbrightness < 0 then
		msgbox("Range should be between "+MINVAL+" and "+MAXVAL+".")		
		setfocus("txtbrightness")
		validatemodecontrols = 0
		return
	elseif #txtcontrast$ = "" then
		msgbox("Enter Contrast value")		
		setfocus("txtcontrast")
		validatemodecontrols = 0
		return
	elseif #txtcontrast > 255 or  #txtcontrast < 0 then
		msgbox("Range should be between "+MINVAL+" and "+MAXVAL+".")		
		setfocus("txtcontrast")
		validatemodecontrols = 0
		return	
	elseif #txtsaturation$ = "" then
		msgbox("Enter Saturation value")		
		setfocus("txtsaturation")
		validatemodecontrols = 0
		return
	elseif #txtsaturation > 255 or  #txtsaturation < 0 then
		msgbox("Range should be between "+MINVAL+" and "+MAXVAL+".")		
		setfocus("txtsaturation")
		validatemodecontrols = 0
		return	
	elseif #txtsharpness$ = "" then
		msgbox("Enter Sharpness value")		
		setfocus("txtsharpness")
		validatemodecontrols = 0
		return
	elseif #txtsharpness > 255 or  #txtsharpness < 0 then
		msgbox("Range should be between "+MINVAL+" and "+MAXVAL+".")	
		setfocus("txtsharpness")
		validatemodecontrols = 0
		return
	endif	
	
End Function

/***********************************************************
'** cmdCancel_Click
 *	Description: Call loadInitialValues to fetch and 
 *				 load values from camera
 
 *	Created by: vimala On 2009-03-16 10:09:47
 *	History: Modified by Partha Sarathi.K
 ***********************************************************/
Sub cmdCancel_Click	
	if canReload = 1 then
		~changeFlag = 0	
		call loadInitialValues()
		call optBLC_Click()
	end if
End Sub

/***********************************************************
'** Form_KeyPress
 *	Description: To set wait flag before switching between forms	
 *				 Checks entered key value based on the rule set to
				 that user input control

 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by :Vimala On 2009-03-04 14:04:47
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )	
	if Key = 15 then
	iff ~wait<=1 then return
		~wait = 2
	endif
	scroll_keypressed(key)
	
	dims keypressed$		
	keypressed$ = chr$(Key)
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)		
	setSubMenuFocus(Key,2)		
End Sub


'set key press rule for user input controls
Sub txtBrightness_Focus
	rule = 7 
End Sub

Sub txtContrast_Focus
	rule = 7 
End Sub

Sub txtSaturation_Focus
	rule = 7 
End Sub

Sub txtSharpness_Focus
	rule = 7 
End Sub

'Display cursor in control focus event else hide cursor
Sub optBLC_Focus
	showcursor(1)
End Sub

Sub optLBCE_Focus
	showcursor(1)
End Sub

Sub optLBCE_Blur
	showcursor(3)
End Sub

Sub optDayNight_Focus
	showcursor(1)
End Sub

Sub optDayNight_Blur
	showcursor(3)
End Sub

Sub optVideoStab_Focus
	showcursor(1)
End Sub

Sub optlens_Focus
	showcursor(1)
End Sub

Sub optlens_Blur
	showcursor(3)
End Sub

Sub optTNF_Focus
	showcursor(1)
End Sub

Sub optTNF_Blur
	showcursor(3)
End Sub


Sub radhistogram_Focus
	showcursor(1)
End Sub

Sub radhistogram_Blur
	showcursor(3)
End Sub

Sub Form_MouseMove( x, y )
	'Please don't delete
End Sub


/***********************************************************
'** form_Mouseclick
 *	Description: To get the focus on user input control
 
 *	Params:
'*		x: Numeric - Mouse X Position
 *		y: Numeric - Mouse Y Position
 *	Created by:  On 2010-05-03 11:57:06
 ***********************************************************/
sub form_Mouseclick(x,y)	
	call getFocus()		
End Sub



/***********************************************************
'** optBLC_Click
 *	Description: Disable and gray backlight drop down 
				 when baclight compensation is OFF.
				 If baclight compensation is ON enable backlight drop down
				 	
 *	Created by:  On 2009-09-23 14:30:30
 ***********************************************************/
Sub optBLC_Click
	if #optBLC$ = 0 then
		#drpBackLight.disabled = 1
		#drpBackLight.fg=UNSELECTED_TXT_COLOR
		#drpBackLight.selfg=UNSELECTED_TXT_COLOR
		#drpBackLight.bg=UNSELECTED_BG_COLOR
		#drpBackLight.brdr=UNSELECTED_BG_COLOR
		#drpBackLight.selbg=UNSELECTED_BG_COLOR
	else
		#drpBackLight.disabled = 0
		#drpBackLight.fg=SELECTED_TXT_COLOR
		#drpBackLight.selfg=SELECTED_TXT_COLOR
		#drpBackLight.bg=SELECTED_BG_COLOR
		#drpBackLight.brdr=1
		#drpBackLight.selbg=SELECTED_BG_COLOR
	endif
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




Sub roCamera_Click
	' Add Handler Code Here 
End Sub

