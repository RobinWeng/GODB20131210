/***************************************************************************************\
 * PROJECT NAME          : IPNC              							               *        
 * MODULE NAME           : Video Analytics Settings                                    *
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

option(4+1)

dimi timerCount


#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"

#define GDO_X1			   266	
#define GDO_Y1			   82	
#define GDO_W1             288
#define GDO_H1             200

#define GDO_X2			   1125
#define GDO_Y2			   165	
#define GDO_W2             288
#define GDO_H2             180
dimi gdoX,gdoY,gdoW,gdoH

dimi noofctrl													'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS                          
dims LabelName$(noofctrl)                                       'Form controls name
dimi XPos(noofctrl)                                             'Form controls X position
dimi YPos(noofctrl)                                             'Form controls Y position
dimi Wdh(noofctrl)                                              'Form controls Width position
dimi height(noofctrl)                                           'Form controls height position
                                                         
#include "videoAnalyticsSetting.inc"

dimi gdoWidth,gdoHeight 
call CreateControls												'To create the GDO control at run time

#include "motiondetection_bas.inc"

dimi rule														'To define the rule(index) for control's validation
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
'** CreateControls
 *	Description: To create GDO control And set the width & height for the 
				 GDO control as per aspect ratio
 *		
 *	Params:
 *	Created by:Franklin Jacques  On 2009-06-19 14:58:50
 *	History: 
 ***********************************************************/
sub CreateControls
	dimi gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	Dimi xRatio,yRatio
	calVideoDisplayRatio(~previewVideoRes$,xRatio,yRatio)				' TR-04
	gdoCurX = GDO_X1 * ~factorX
	gdoCurY = GDO_Y1 * ~factorY
	gdoCurWidth  = GDO_W1 * ~factorX
	gdoCurHeight = GDO_H1 * ~factorY
	checkAspectRatio(gdoCurWidth, gdoCurHeight,xRatio,yRatio)
	#gdobg.x=gdoCurX-2
	#gdobg.y=gdoCurY-2
	#gdobg.w=gdoCurWidth+2
	#gdobg.h=gdoCurHeight+2
	call getMainVideoPosition(gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight)
	createGDOControl("gdomainvideo", gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight)
	#gdomainvideo.Audio = 0
	gdoCurX = GDO_X2 * ~factorX
	gdoCurY = GDO_Y2 * ~factorY	
	gdoCurWidth  = GDO_W2 * ~factorX
	gdoCurHeight = GDO_H2 * ~factorY
	checkAspectRatio(gdoCurWidth, gdoCurHeight,xRatio,yRatio)
	#lblVideoborder.x=gdoCurX-2
	#lblVideoborder.y=gdoCurY-2
	#lblVideoborder.w=gdoCurWidth+2
	#lblVideoborder.h=gdoCurHeight+2	
	createGDOControl("gdoVideo", gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight)
	#lblVideoborder.w = gdoCurWidth+6
	#lblVideoborder.h = gdoCurHeight+6
	#gdoVideo.appmode = 1
	#gdoVideo.Audio = 0
	#gdoVideo.UIMode=1	
	gdoCurWidth  = GDO_W1 * ~factorX
	gdoCurHeight = GDO_H1 * ~factorY	
	createGDOControl("gdoVideoROI",GDO_X1, GDO_Y1, gdoCurWidth, gdoCurHeight)
	checkAspectRatio(gdoCurWidth, gdoCurHeight,xRatio,yRatio)		
	gdoWidth = gdoCurWidth
	gdoHeight = gdoCurHeight	
	#gdoVideoROI.UIMode=2
	#gdoVideoROI.hidden=1
	#gdoVideoROI.Audio=1
	#gdoVideoROI.totregion = 1
	#frmregofinterest.hidden=1
End Sub

/***********************************************************
'** getMainVideoPosition
 *	Description: 
 *		store the Main Video (GDO control position)
 *		
 *	Params:
'*		gdoCurX: Numeric - GDO control's X position
'*		gdoCurY: Numeric - GDO control's Y position
'*		gdoCurWidth: Numeric - GDO control's Width position
 *		gdoCurHeight: Numeric - GDO control's Height position 
 *	Created by: Franklin Jacques.K On 2009-09-28 11:27:26

 ***********************************************************/
sub getMainVideoPosition(gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight)
	gdoX = gdoCurX
	gdoY = gdoCurY
	gdoW = gdoCurWidth
	gdoH = gdoCurHeight
End Sub

/***********************************************************
'** Form_Load
 *	Description: Call displayControls function to resize control 
 *				 based on the screen resolution
 *				 Call loadAdvanceSettingsValue function to fetch 
 *				 values from camera and load the same in form controls. 
 *				 Highlight the selected link in left menu.
 *	Created by: vimala On 2009-04-03 11:22:42
 ***********************************************************/
Sub Form_Load
	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
		
	call loadVideoAnalyticsValue()
	showSubMenu(0,1)
	setfocus("rosubmenu[1]")
	selectSubMenu()
	setfocus("cmdconfigure")
	#lblloading.hidden = 1
	#lblsuccessmessage$ = ""									'TR-35
End Sub

/***********************************************************
'** form_timer
 *	Description: To set wait flag before switching between forms	
				 Display save success message for 5 secs
 *		
 *	Params:
 *	Created by: Franklin Jacques  On 2009-06-30 16:14:12
 *	History: 
 ***********************************************************/
Sub form_timer	
	~wait = ~wait +1				'added by Franklin to set wait flag when switching between forms
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
'** loadAdvanceSettingsValue
 *	Description: Call this function to fetch values from camera 
 *				 and load the same in screen controls
 
 *	Created by: vimala On 2009-04-03 11:24:28

 ***********************************************************/
sub loadVideoAnalyticsValue()
	
	#rocameraname$ = ~title$	
	
	dimi retVal
	dimi facedetect,regionX,regionY,regionW,regionH
	dimi confLevel,direction
	dimi faceRecog,frLevel,database
	dimi privacyMask,maskOptions
	
	'Get the advanced settings values
	retVal = getVideoAnalyticsSettings(facedetect,regionX,regionY,_
									   regionW,regionH, _
									   confLevel,direction,_
									   faceRecog,frLevel,database,_
									   privacyMask,maskOptions)
	
	if retVal = -1 then
		msgbox("Unable to get values")
		return
	endif
	
	'Face Detect Setting
	#optFaceDet$ = facedetect
	#txtX$ = regionX
	#txtY$ = regionY
	#txtW$ = regionW
	#txtH$ = regionH
	#txtFDConfidence$ = confLevel
	
	'Privacy Mask
	#optPrivacyMask$ = privacyMask
	
	'Face Recognition Setting
	#txtFRConfidence$ = frLevel 
	#optdatabase$ = database
		
	dims directionName$(1), maskOptionsName$(1),frecognitionName$(1)
	
	'Get and set the dropdown box values
	retVal = getVideoAnalyticsOptions(directionName$,maskOptionsName$,frecognitionName$)   'TR-25 
	
	if retVal = 0 then	
		call addItemsToDropDown("dddirection",directionName$,direction)
		call addItemsToDropDown("ddmaskoption",maskOptionsName$,maskOptions)
		call addItemsToDropDown("ddFaceRec",frecognitionName$,faceRecog)					 'TR-25 
	endif
	
End Sub


/***********************************************************
'** cmdconfigure_Click
 *	Description:Shows motion detection modal window. 
 *				Assgin x,Y,W value for the modal window.
 *				Loads the video.
 *	Created by: vimala On 2009-04-03 11:45:08
 *	History: 
 ***********************************************************/
Sub cmdconfigure_Click	
	if canReload = 1 then
		dimi a
		a = #gdomainvideo.stop(1)
		#gdomainvideo.hidden=1
		#gdobg.hidden=1
		pprint motionBlock$
		call disp_streams("gdoVideo")
		call optThreshold_Click	
			
		#frmotionDetection.hidden = 0		
		#frmotionDetection.x = gdoX-10   
		#frmotionDetection.y = gdoY+10   
		#frmotionDetection.bg = 4358
		
		#frmotionDetection.w = (#txtthreshold.x + #txtthreshold.w) - #frmotionDetection.x +10
		#frmotionDetection.h = (#cmdMotionDetSave.y + #cmdMotionDetSave.h) - #frmotionDetection.y +10
		#frmotionDetection.y = #rocameraname.y
		#lblmotiondetect.w	= (#txtthreshold.x + #txtthreshold.w) - #frmotionDetection.x -17
		
		#gdoVideo.x = #lblVideoborder.x + 4
		#gdoVideo.y = #lblVideoborder.y + 4
		
		setfocus("optthreshold")
	end if
End Sub



/***********************************************************
'** cmdSave_Click
 *	Description:  call savePage to save values to the camera.

 *	Created by: vimala On 2009-04-03 11:45:12
 *	History: 
 ***********************************************************/
Sub cmdSave_Click
	if canReload = 1 then
		savePage()		
	end if
End Sub


/***********************************************************
'** savePage
 *	Description: validateCtrlValues() function checks for valid data.
 *				 Saves the control values to camera.
 *		
 *		
 *	Created by:Franklin Jacques  On 2009-05-28 16:34:07
 ***********************************************************/
Sub savePage()
	msgbox("videoanalytics.bas")
	dimi retVal,i
	iff validateCtrlValues() = 0 then return

	dimi a
	a = #gdomainvideo.stop(1)	
	#gdomainvideo.hidden = 1	
	#gdobg.paint(1)
	#lblloading$= "Updating..."
	#lblloading.paint(1)
	
	#lblloading.hidden = 0
	retVal = setVideoAnalyticsSettings(#optFaceDet,#txtX,#txtY,_
									   #txtW,#txtH, _
									   #txtFDConfidence,#ddDirection,_
									   #ddFaceRec,#txtFRConfidence,#optdatabase, _
									   #optPrivacyMask,#ddMaskOption)
	
	saveSuccess = retVal
	'Based on reload flag wait for the camera to restart
	if getReloadFlag() = 1 then									'TR-45
		canReload = 0
		animateCount = 1
		call animateLabel("lblLoading","Updating")
	else // If Reload animation is not required
		canReload = 1
	end if

	If canReload = 1 Then	//Do the remaining actions after reload animation is done
		call displaySaveStatus(saveSuccess)		
	End If	

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
		#lblsuccessmessage$ = "Advanced Features setting saved to camera "+~title$		'TR-35	
		isMessageDisplayed = 1															'TR-35
		#lblsuccessmessage.Paint(1)
	else 		
		if ~keywordDetFlag = 1 then		
			msgbox("Advanced Features setting for\n "+~errorKeywords$+"\nfailed for the camera "+~title$)
		else
			msgbox("Advanced Features setting failed for the camera "+~title$)
		endif
	endif
	
	call loadVideoAnalyticsValue()
	~changeFlag = 0	
	#lblloading.hidden = 1
	setfocus("cmdconfigure")
	canReload = 1
	call Form_complete()
End Sub


/***********************************************************
'** validateCtrlValues
 *	Description: Call this function to validate control values.
 *  Returns : 1 - All the values are valid
 *			  0 - for invalid control values 
 *	Created by: vimala On 2009-04-03 12:10:14
 ***********************************************************/
Function validateCtrlValues()
	validateCtrlValues = 1
	if #txtx$ = "" then
		msgbox("Enter Region of Interest X")
		setfocus("txtx")
		validateCtrlValues = 0
		return
	elseif #txty$ = "" then
		msgbox("Enter Region of Interest Y")
		setfocus("txty")
		validateCtrlValues = 0
		return
	elseif #txtw$ = "" then
		msgbox("Enter Region of Interest W")
		setfocus("txtw")
		validateCtrlValues = 0
		return
	elseif #txth$ = "" then
		msgbox("Enter Region of Interest H")
		setfocus("txth")
		validateCtrlValues = 0
		return
	elseif #txtfdconfidence$="" then
		msgbox("Enter Face Detection Confidence level")
		setfocus("txtfdconfidence")
		validateCtrlValues = 0
		return
	elseif #txtfdconfidence$<>"" and (#txtfdconfidence<1 or #txtfdconfidence>100) then			'TR-17
		msgbox("Face Detect Confidence level should range between 1 - 100 ")
		setfocus("txtfdconfidence")
		validateCtrlValues = 0
		return		
	elseif #txtfrconfidence$ = "" then 	
		msgbox("Enter Face Recognition Confidence level")
		setfocus("txtfrconfidence")
		validateCtrlValues = 0
		return
	elseif #txtfrconfidence$<>"" and (#txtfrconfidence<1 or #txtfrconfidence>100) then
		msgbox("Face Recognition Confidence level should range between 1 - 100 ")
		setfocus("txtfrconfidence")
		validateCtrlValues = 0
		return
	endif
	
End Function


/***********************************************************
'** cmdCancel_Click
 *	Description: Reload the Video Analytics settings values.
 *	Created by: vimala On 2009-04-03 11:46:05
 *	History: 
 ***********************************************************/
Sub cmdCancel_Click
	if canReload = 1 then
		~changeFlag = 0		
		call loadVideoAnalyticsValue()
	end if	
End Sub

/***********************************************************
'** Form_KeyPress
 *	Description: 	
			 To set wait flag before switching between forms	
			Checks entered key value based on the rule set to that user input control
 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by : vimala On 2009-03-17 14:13:58	
 *	History: 
 ***********************************************************/
Sub Form_KeyPress(Key, FromMouse)	
	if Key = 15 then
	iff ~wait<=1 then return
		~wait = 2
	endif
	scroll_keypressed(key)	
	
	dims keypressed$
	keypressed$ = chr$(Key)
		
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)	
	
	setSubMenuFocus(Key,1)
	
End Sub

/***********************************************************
'** Form_complete
 *	Description: Set the properties for gdo video control to play rtsp stream
 
 *	Created by: Partha Sarathi.K On 2009-03-03 16:02:27

 ***********************************************************/
Sub Form_complete
	~wait = 0			
	call disp_streams("gdomainvideo")	
	'Store all the control values in an array to validate changes in form.	
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
	
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
End Sub

/***********************************************************
'** disp_streams
 *	Description: Get Stream and load the rtsp url to video player

 *	Created by: Franklin Jacques  On 2009-07-31 19:01:44
 ***********************************************************/
sub disp_streams(dims CtrlName$)
	dims url$,value$
	dimi ret,a	
	dims stream$(3),rtspUrl$(3)
	loadStreamDetails(stream$,rtspUrl$)
	value$ = rtspUrl$(0) 	
	/*a = #{CtrlName$}.play(value$)
	#{CtrlName$}.hidden = 0*/
	a = #{CtrlName$}.stop(1)	
	#{CtrlName$}.hidden = 1
	
	'check whether video stream can to displayed by ActiveX or not
	dimi playVideoFlag,fontNo,styleNo
	dims dispStr$
	
	playVideoFlag = checkForStreamRes(stream$(0))
	
	if playVideoFlag = 1 then
		dispStr$ = ~Unable_To_Display_Msg$
		#lblloading.hidden = 0		
		#{CtrlName$}.hidden = 1			
		styleNo = 0		
		disableConfigureBut(1,"cmdconfigure")
		disableConfigureBut(1,"cmdroiconfigure")
		setfocus("optfacedet")
	else
		dispStr$ = "Updating . . . .    "
		'Play stream
		#{CtrlName$}.hidden = 0
		a =  #{CtrlName$}.play(value$)		
		styleNo = 8
		disableConfigureBut(0,"cmdconfigure")
		disableConfigureBut(0,"cmdroiconfigure")
	end if
	
	#lblloading.style = styleNo	
	#lblloading$ = dispStr$
	#lblloading.w = #gdobg.w - (#gdobg.w/3)
	#lblloading.h = 120
	#lblloading.x =  ((#gdobg.w/2) - (#lblloading.w/2)) +  #gdobg.x
	#lblloading.paint(1)
End Sub


Sub disableConfigureBut(dimi disableFlag,dims ctrlName$)
	if disableFlag = 1 then
		#{ctrlName$}.disabled = 1
		#{ctrlName$}.fg = 17004
		#{ctrlName$}.bg = 14826
		#{ctrlName$}.brdr = 14826
		#{ctrlName$}.selfg = 17004
		#{ctrlName$}.selbg = 14826
		#{ctrlName$}.selbrdr = 14826
		#{ctrlName$}.grad = 14826
		#{ctrlName$}.selgrad = 14826
	else 
		#{ctrlName$}.disabled = 0
		#{ctrlName$}.fg = 10565
		#{ctrlName$}.bg = 33808
		#{ctrlName$}.brdr = 4359
		#{ctrlName$}.selfg = 65535
		#{ctrlName$}.selbg = 41092
		#{ctrlName$}.selbrdr = 4359
		#{ctrlName$}.grad = 50712
		#{ctrlName$}.selgrad = 64906		
		#{ctrlName$}.selgraddir = 2
	end if
	#{ctrlName$}.paint(1)
End Sub


' validation for all the text box ctrl while keypress event 
Sub txtFDConfidence_Focus	
	rule = 7 
End Sub

Sub txtFRConfidence_Focus
	rule = 7
End Sub

Sub txtX_Focus
	rule = 7
End Sub

Sub txtY_Focus
	rule = 7
End Sub

Sub txtW_Focus
	rule = 7
End Sub

Sub txtthreshold_Focus
	rule = 7
End Sub

'Display cursor in control focus event else hide cursor
Sub optFaceDet_Focus
	showcursor(1)
End Sub

Sub optPrivacyMask_Focus
	showcursor(1)
End Sub

Sub optdatabase_Focus
	showcursor(1)
End Sub

Sub optFaceDet_blur
	showcursor(1)
End Sub

Sub optPrivacyMask_blur
	showcursor(1)
End Sub

Sub optdatabase_blur
	showcursor(1)
End Sub

sub optthreshold_focus
	showcursor(1)
End Sub

sub optcusthreshold_focus
	showcursor(1)
End Sub

sub optcusthreshold_blur
	showcursor(3)
End Sub

sub btnselectall_focus
	showcursor(3)
End Sub

Sub btnclearall_focus
	showcursor(3)
End Sub


Sub btnrestore_focus
	showcursor(3)
End Sub

sub cmdconfigure_focus
	showcursor(3)
End Sub

Sub cmdsave_focus
	showcursor(3)
End Sub

Sub cmdcancel_focus
	showcursor(3)
End Sub

Sub cmdmotiondetsave_focus
	showcursor(3)
End Sub


Sub cmdmotiondetcancel_focus
	showcursor(3)
End Sub


/***********************************************************
'** form_Mouseclick
 *	Description: 
 *		To set the focus for the controls

 *	Params:
'*		x: Numeric - X Position
 *		y: Numeric - Y Position
 *	Created by: Vimala On 2009-07-16 12:37:35
 ***********************************************************/
sub form_Mouseclick(x,y)	
	call getFocus()	
End Sub



/***********************************************************
'** optFaceDet_Click
 *	Description: Clciking on face detection ON should 
 *               enable Configure button else disable.
 *	Created by:Vimala  On 2009-12-15 22:03:31
 ***********************************************************/
Sub optFaceDet_Click	'TR-33 
	if #optfacedet$ = "0" then
		#cmdROIConfigure.disabled = 1	
	elseif #optfacedet$ = "1" then
		#cmdROIConfigure.disabled = 0
	end if
End Sub



/***********************************************************
'** cmdROIConfigure_Click
 *	Description: Adjust the GDO, border label ,buttons and frame display position.
 *				 Display current stream in GDO with ROI enabled.
 *	Created by: Vimala  On 2009-12-15 07:42:53
 ***********************************************************/
Sub cmdROIConfigure_Click		'TR-33 
	if canReload = 1 then
		showcursor(3)
		iff #lblloading$ = ~Unable_To_Display_Msg$ then return
		
		if #optfacedet$ = "1"  and ValidateRegionValues() = 0 then		
			'ROI controls alignment
			#frmRegOfInterest.hidden = 0		
			#frmRegOfInterest.x = gdoX-10   
			#frmRegOfInterest.y = gdoY+10 
			#gdoVideoROI.w = gdoWidth
			#gdoVideoROI.h = gdoHeight 
			#frmRegOfInterest.bg = 4358		
			#gdoVideoROI.x = #lblROIBorder.x + 4
			#gdoVideoROI.y =  #lblROIBorder.y + 4		
			#lblroiborder.w = gdoWidth + 6
			#lblroiborder.h = gdoHeight + 6	
					
			#frmRegOfInterest.h = (#cmdroiok.y + #cmdroiok.h) - #frmRegOfInterest.y +20
			#frmRegOfInterest.w = (#lblroiborder.x + #lblroiborder.w) - #frmRegOfInterest.x + 75
			
			#cmdroiok.x = #frmRegOfInterest.x + (#frmRegOfInterest.w  - (85*3))/2
			#cmdroiok.y = #lblROIBorder.y + #lblroiborder.h  + 30
			#cmdroiok.w = 85
			
			#cmdroicancel.x = #cmdroiok.x + #cmdroiok.w + 10 
			#cmdroicancel.y = #cmdroiok.y
			#cmdroicancel.w = #cmdroiok.w
			
			#cmdroiclear.x = #cmdroicancel.x + #cmdroicancel.w + 10 
			#cmdroiclear.y = #cmdroiok.y
			#cmdroiclear.w = #cmdroiok.w
			
			#lblregInt.w = #frmRegOfInterest.w  - 25
			#lblregInt.x = #frmRegOfInterest.x + 1
			#lblregInt.y = #frmRegOfInterest.y + 1
			
			'display  Stream		
			dimi a,ret
			dims url$,value$
			a=#gdomainvideo.stop(1)
			#gdomainvideo.hidden=1
			#gdobg.hidden=1
			disp_streams("gdoVideoROI")
			#gdoVideoROI.hidden=0
			
			'calculate the ROI coordinates to display in GDO
			dimi xRes,yRes,regX,regY,regW,regH
			getCurStreamResolution(~previewVideoRes$,xRes,yRes)
			regX = round((atol(#txtx$)*gdoWidth)/xRes)
			regY = round((atol(#txty$)*gdoHeight)/yRes)
			regW = round((atol(#txtw$)*gdoWidth)/xRes)
			regH = round((atol(#txth$)*gdoHeight)/yRes)		
			#gdoVideoROI.RegionOfInterest("1&"+regX+"&"+regY+"&"+regW+"&"+regH+"")
			setfocus("cmdroiok")
		elseif #optfacedet$ = "1" then 
			msgbox("Please enter valid X,Y,Widht,Height")		
		end if
	end if
End Sub



/***********************************************************
'** cmdROIOk_Click
 *	Description: calcuate the ROI coordinates for the actual
 *				  stream resolution  and load the same in  controls
 
 *	Created by: Vimala  On 2009-12-15 23:24:08
 *	History:USed in Video Advanced ROI 
 ***********************************************************/
Sub cmdROIOk_Click		'TR-33 
	dims region$(4)
	RoiCalculation(region$)
	#txtx$ =  region$(0)
	#txty$ =  region$(1)
	#txtw$ =  region$(2)
	#txth$ =  region$(3)
	call cmdROICancel_Click
End Sub


/***********************************************************
'** RoiCalculation
 *	Description: Calculate ROI coordinates for the 
 *				 stream actual resolution
 *		
 *		byref dims regionArray$(): String - 
 *	Created by: Vimala On 2009-12-15 23:25:31
 *	History:Used in  Video Advanced ROI 
 ***********************************************************/
sub RoiCalculation(byref dims regionArray$())	'TR-33 
	
	dims strVal$, tempVal$, region$
	dimi ret, xRes, yRes, regX, regY, res
	tempVal$=#gdoVideoROI.RegionOfInterest$
	pprint tempVal$
	ret=split(strVal$,tempVal$,"|")
	
	if ret>0 then
		split(region$,strVal$(0), "&")
		
		dimi width, height
		if atol(region$(3))>atol(region$(1)) then 
			width=atol(region$(3))-atol(region$(1))
		else
			width=atol(region$(1))-atol(region$(3))
		endif
		if atol(region$(4))>atol(region$(2)) then 
			height=atol(region$(4))-atol(region$(2))
		else
			height=atol(region$(2))-atol(region$(4))
		endif
		
		getCurStreamResolution(~previewVideoRes$,xRes,yRes)
		regX = atol(region$(1))
		regY = atol(region$(2))
		
		res = round((regX*xRes)/gdoWidth)
		regionArray$(0)=res 
		res = round((regY*yRes)/gdoHeight)
		regionArray$(1)=res  
		res = round((width*xRes)/gdoWidth)
		regionArray$(2)=res  
		res = round((height*yRes)/gdoHeight)
		regionArray$(3)=res 
	endif
End Sub




/***********************************************************
'** cmdROICancel_Click
 *	Description: Hide the frame , stop and hide GDO
 *
 *	Created by:vimala  On 2009-12-15 08:20:33
 ***********************************************************/
Sub cmdROICancel_Click
	dimi a
	a=#gdoVideoROI.stop(1)
	#gdoVideoROI.hidden = 1
	#frmRegOfInterest.hidden = 1
	~changeFlag = 0
	call disp_streams("gdomainvideo")
	#gdobg.hidden=0
	setfocus("rosubmenu[1]")
	setfocus("optfacedet")
	setfocus("txtFDConfidence")
End Sub



/***********************************************************
'** frmRegOfInterest_Cancel
 *	Description: Hide the frame , stop and hide GDO
 *	Params:
 *	Created by:  On 2009-12-15 08:36:13
***********************************************************/
sub frmRegOfInterest_Cancel 
	call cmdROICancel_Click
End Sub



/***********************************************************
'** ValidateRegionValues
 *	Description: 
 *		To Validate the Region values with respect to the current stream
 *		
 *	Methods: getCurStreamResolution- to get the current stream Resolution
 *	Created by: Franklin Jacques.K On 2009-09-25 11:43:02
 *	History: 
 ***********************************************************/
function ValidateRegionValues()
	ValidateRegionValues = 0
	
	dimi xRes,yRes,errorFlag = 0		
	getCurStreamResolution(~previewVideoRes$,xRes,yRes)
	
	if (#txtw+ #txtx) > xRes then 
		ValidateRegionValues = 1
		setfocus("txtw")
		errorFlag = 1		
	end if

	if (#txth+ #txty) > yRes then 
		ValidateRegionValues = 1
		setfocus("txth")
		errorFlag = 1	
	end if
	
	ValidateRegionValues = errorFlag	

End Function


/***********************************************************
'** cmdROIClear_Click
 *	Description: Will clear the selected ROI
 * 
 *	Created by: Vimala On 2009-12-23 22:57:36
 *	History: 
 ***********************************************************/
Sub cmdROIClear_Click				'TR-38	
	#gdoVideoROI.RegionOfInterest("1&0&0&0&0")
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


