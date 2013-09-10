/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Motion Detection                                            *
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
This screen allows user to view and set motion detection.
*/

option(4+1)

#define DISABLE_FG_COL            50712  

dims motionBlock$
call loadMotionSettingsValues()


/***********************************************************
'** btnSelectAll_Click
 *	Description: 
 *		Set the properties for gdo video control(select all motionblocks)

 *	Created by: Partha Sarathi.K On 2009-03-03 16:02:27
 ***********************************************************/
Sub btnSelectAll_Click
	#gdovideo.motionBlock$="FFF"
End Sub


/***********************************************************
'** btnClearAll_Click
 *	Description: 
 *		Set the properties for gdo video control(deselect all motionblocks)

 *	Created by: Partha Sarathi.K On 2009-03-03 16:02:27

 ***********************************************************/
Sub btnClearAll_Click
	#gdovideo.motionBlock$="000"
End Sub


/***********************************************************
'** btnRestore_Click
 *	Description: 
 *		Set the properties for gdo video control(Restore motionblocks)

 *	Created by: Partha Sarathi.K On 2009-03-03 16:02:27

 ***********************************************************/
Sub btnRestore_Click
	#gdovideo.motionBlock$="000"
	#gdovideo.motionBlock$=motionBlock$
End Sub


/***********************************************************
'** optThreshold_Click
 *	Description: 
 *		Disable the customize threshold option based on selected option

 *	Created by: Partha Sarathi.K On 2009-03-05 09:59:37
 
 ***********************************************************/
Sub optThreshold_Click
	
	if #optThreshold$ = "0" then
		#ddthreshold.disabled  = FALSE
		#txtthreshold.disabled = TRUE	
	else 
		#txtthreshold.disabled = FALSE
		#ddthreshold.disabled  = TRUE
	endif
	
End Sub


/***********************************************************
'** loadMotionSettingsValues
 *	Description: 
 *		Get the motion settings value  and display the same in UI.

 *	Created by: Partha Sarathi.K  On 2009-03-05 10:54:11

 ***********************************************************/
sub loadMotionSettingsValues()
	dimi isCustomvalue, sensitivity, thresholdValue, minThreshold, maxThreshold
	dims motionSettingsName$(1)
	dimi ret
	
	ret = getMotionDetectSettings(isCustomvalue, sensitivity, thresholdValue, minThreshold, _
							maxThreshold, motionBlock$)						
	if ret = 0 then
		#txtthreshold$ = thresholdValue
	else
		isCustomvalue = 0
	endif
	pprint motionBlock$
	#gdoVideo.motionBlock$ = motionBlock$
	#optThreshold$ = isCustomvalue	
	ret = getMotionDetectOptions(motionSettingsName$)
	iff ret = 0 then addItemsToDropDown("ddthreshold", motionSettingsName$, sensitivity)	
	
End Sub

/***********************************************************
'** cmdMotionDetSave_Click
 *	Description: 
 *		Validate the thershold value.
 *		Save the motion settings to the ini files.

 *	Created by: Partha Sarathi.K On 2009-03-05 11:39:33

 ***********************************************************/
Sub cmdMotionDetSave_Click
	dimi a
	sleep(1000)
	dimi thresholdValue, isThresholdEnable
	dimi ret
	
	thresholdValue = #txtthreshold	
	motionBlock$ = #gdoVideo.motionBlock$

	if #optThreshold$ = "1" and (#txtthreshold$ < 1 or #txtthreshold$ > 99) then		
		msgbox "Customized Threshold \nmust be between 1 and 99"
		setfocus("txtthreshold")
		return
	endif
	
	if #ddthreshold.itemcount = 0 then 
		ret=-1
	else 		
		ret = setMotionDetectSettings(#optThreshold, #ddthreshold.selidx, thresholdValue, motionBlock$)
	end if
	
	if ret >= 0 then		
		msgbox ("Motion Detection setting \nsaved to camera "+~title$)
	else		
		if ~keywordDetFlag = 1 then		
			msgbox("Motion Detection setting for \n"+~errorKeywords$+"\nfailed for the camera "+~title$)
		else 
			msgbox ("Motion Detection setting \nfailed for the camera "+~title$)		
		endif
	endif	
	
	~changeFlag = 0	
	call Form_complete()
	cmdMotionDetCancel_Click
End Sub


/***********************************************************
'** cmdMotionDetCancel_Click
 *	Description:
		 Stop video player, hide motion detection frame 
		 Play main video of video analytic screen
 
 *	Created by: Vimala On 2009-03-13 11:32:27
 ***********************************************************/
Sub cmdMotionDetCancel_Click
	#gdovideo.motionBlock$="000"
	dimi a
	call loadMotionSettingsValues()	
	a=#gdoVideo.stop(1)	
	#gdovideo.hidden = 1
	#frmotionDetection.hidden = 1
	setfocus("rosubmenu[1]")
	setfocus("optfacedet")
	~changeFlag = 0
	call disp_streams("gdomainvideo")
	#gdobg.hidden=0
End Sub


/***********************************************************
'** frmotionDetection_Cancel
 *	Description: Hides GDO control and motion detection frame.
 
 *	Created by: vimala On 2009-04-03 14:45:55

 ***********************************************************/
sub frmotionDetection_Cancel 
	cmdMotionDetCancel_Click
End Sub

