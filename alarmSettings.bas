/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Alarm Settings                                              *
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
call this page to view and set alarm setting.
*/

option(4+1)
dimi timerCount
showcursor(3)      
#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"

dimi noofctrl								'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS      
dims LabelName$(noofctrl)                   'Form controls name
dimi XPos(noofctrl)                         'Form controls X position
dimi YPos(noofctrl)                         'Form controls Y position
dimi Wdh(noofctrl)                          'Form controls Width position
dimi height(noofctrl)                       'Form controls height position
                                           
#include "alarmSettings.inc"

dimi smtpMinFiles							'Minimum number of files attached
dimi smtpMaxFiles							'MAximum number of files attached
dimi rule									'Rule for input key validation
~wait = 2                          			'To wait flag when switching between forms
dimi grayAllCtrls							'Holds 1- gray out all ctrls if enable alarm is not selected else 0 TR-21
settimer(1000)									'TR-35  
dimi displayCount,isMessageDisplayed			'TR-35  
displayCount = 1								'TR-35
dims ctrlValues$(noofctrl)
dimi sdCard   								'Stores Sd card inserted values
dimi animateCount = 0 	 ' Stores the count for the animation done.
dimi saveSuccess = 0	 'Value of 1 is success
dims error$ = "" 		 'Stores the error returned while saving.
dimi tempX				 ' Holds sucess message label
end

/***********************************************************
'** Form_load
 *	Description: Call displayControls function to algin contorls
 *				 based on the screen resolution.
 *				 Call loadInitialValues function to fetch values 
 *				 from camera and assign the same to controls.
 *				 Highlight the selected link in left menu.
 *	Created by: vimala On 2009-03-10 16:17:16
 ***********************************************************/
sub Form_load
	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	call loadInitialValues()
	pprint "loadInitialValues end"
	call chkEnableAlarm_Click
	pprint "chkEnableAlarm_Click end"						'TR-21
	
	showSubMenu(0,1)
	setfocus("rosubmenu[7]")
	selectSubMenu()
	setfocus("chkenablealarm")
	#lblsuccessmessage$ = ""   						'TR-35
	pprint "form_load end"
End Sub


/***********************************************************
'** Form_Complete
 *	Description: Store all the control values in an array to validate changes in form.

 *	Created by: Vimala  On 2010-05-03 15:08:15
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
'** loadInitialValues
 *	Description: Call this function to fetch values from camera and assign
 *				 the values to form controls.
 
 *	Created by: Vimala On 2009-03-11 15:11:32
 ***********************************************************/
Sub loadInitialValues	
	dimi retVal				
	dimi enableAlarm, storageDuration,motionEnabled, ethernetLost
	dimi darkImages, extTriggerEnabled, extTriggerInput, exttriggeroutput
	dimi ftpUpload, ftpFormat, smtpUpload, smtpFormat,noOfFiles
	dimi localStore, localFormat,storageLocation, playAudio, audioFiles	
	
	'Get user inout values from camera
	retVal = getAlarmSetting(enableAlarm, storageDuration, _
							 motionEnabled, ethernetLost, _
							 darkImages, extTriggerEnabled, _
							 extTriggerInput, exttriggeroutput, _
							 ftpUpload, ftpFormat, smtpUpload, smtpFormat, _
							 smtpMinFiles,smtpMaxFiles,noOfFiles, _
							 localStore, localFormat, _
							 storageLocation, playAudio, audioFiles,sdCard)						 

	if retVal = 0 then
		#rocamera$ = ~title$
		setCheckBox("chkEnableAlarm",enableAlarm)
		setCheckBox("chkmotiondet", motionEnabled)
		setCheckBox("chkEthernetHost", ethernetLost)
		setCheckBox("chkdarkblank", darkImages)
		setCheckBox("chkexternaltriggers", extTriggerEnabled)
		setCheckBox("chkftp", ftpUpload)
		setCheckBox("chklocalstorage", localStore)
		setCheckBox("chksmtp", smtpUpload)
		setCheckBox("chkplayAudio",playAudio)
		#optlocalstorage$ = storageLocation
		#txtattachfile$ = noOfFiles		
	endif
	
	
	dims arrExtInpTriger$(1),arrExtOutTriger$(1),arrFtpFormat$(1)
	dims arrSmtpFormat$(1),arrLocalFormat$(1),arrStorageDuration$(1) 
	dims arrPeriodicity$(1),audioFiles$(1)
	
	'Get drop down values from camera	
	retVal = getAlarmSettingOptions(arrExtInpTriger$,arrExtOutTriger$, _
								arrFtpFormat$, arrSmtpFormat$, arrLocalFormat$, _
								arrStorageDuration$, audioFiles$)
								
	if retVal = 0 then		
		call addItemsToDropDown("ddStorageDur",arrStorageDuration$,storageDuration)
		call addItemsToDropDown("ddinput",arrExtInpTriger$,exttriggerinput)	
		call addItemsToDropDown("ddoutput",arrExtOutTriger$,exttriggeroutput)
		call addItemsToDropDown("ddftp",arrFtpFormat$,ftpFormat)
		call addItemsToDropDown("ddsmtp",arrSmtpFormat$,smtpFormat)
		call addItemsToDropDown("ddlocstorage",arrLocalFormat$,localFormat)
		call addItemsToDropDown("ddSelectAlarm",audioFiles$,audioFiles)			
	endif
	
	#txtattachfile.disabled = 0	
	call checkOnAlarm()	
End Sub



/***********************************************************
'** checkOnAlarm
 *	Description: call this Sub to disable/enable check box and drop down 
				 based on the drop down values

 *	Created by: Vimala On 2009-11-06 13:11:55
 ***********************************************************/
Sub checkOnAlarm()
	if #ddftp.itemcount>0 then
		if #ddftp.itemlabel$(0) = "N/A" then 	
			setCtrlProperty(1,"chkftp",UNSELECTED_BG_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_BRD_COLOR,"lblftbfileforamt","ddftp","lblattachfile","txtattachfile")		
		end if
	end if

	if #ddsmtp.itemcount>0 then
		if #ddsmtp.itemlabel$(0) = "N/A" then 	
			setCtrlProperty(1,"chksmtp",UNSELECTED_BG_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_BRD_COLOR,"lblsmtpfileforamt","ddsmtp","lblattachfile","txtattachfile")	
		end if	
	end if

	if #ddLocStorage.itemcount>0 then
		if #ddLocStorage.itemlabel$(0) = "N/A" then 	
			setCtrlProperty(1,"chkLocalStorage",UNSELECTED_BG_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_BRD_COLOR,"lblLocStorageFileFormat","ddLocStorage","lblLocalStorage","optLocalStorage")	
		end if	
	end if
	
	'Gray save into local storage option if SD card is not inserted in camera
	if sdCard = 0 then
		setCtrlProperty(1,"chkLocalStorage",UNSELECTED_BG_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_BRD_COLOR,"lblLocStorageFileFormat","ddLocStorage","lblLocalStorage","optLocalStorage")	
	end if
	
	call setDisableColor
End Sub


/***********************************************************
'** setCtrlProperty
 *	Description: Call this Sub to set FG,BG,BRDR color
 
 *	Params:
'*		dimi disableFlag: Numeric - disable value (0 - enable / 1 - disable)
'*		dims chkName$: String -  Check box control name
'*		dimi bgCol: Numeric - Background color
'*		dimi fgCol: Numeric - Foreground color
'*		dimi brdCol: Numeric - Border color for the control
'*		dims lblName$: String - Label control name
'*		dims drpName$: String - Drop down control name
'*		dims lblattachfile$: String -  Number of files attached label name
 *		dims txtName$: String - Text box control name
 *	Created by: Vimala On 2009-11-06 13:16:11
 ***********************************************************/
Sub setCtrlProperty(dimi disableFlag,dims chkName$,dimi bgCol, dimi fgCol, dimi brdCol,dims lblName$,dims drpName$,dims lblattachfile$,dims txtName$)	
	#{chkName$}.checked = 0
	#{chkName$}.disabled = disableFlag
	#{chkName$}.fg = fgCol
	#{chkName$}.selfg = fgCol
	#{lblName$}.fg = fgCol
	#{lblName$}.selfg = fgCol
	#{drpName$}.disabled = disableFlag
	#{drpName$}.fg = fgCol
	#{drpName$}.selfg = fgCol	
	#{drpName$}.bg = bgCol	
	#{drpName$}.brdr = bgCol	
	#{drpName$}.selbrdr = bgCol	
	#{drpName$}.selbg = bgCol
	if chkName$="chksmtp" or chkName$="chkLocalStorage" then
		#{lblattachfile$}.fg = fgCol
		#{lblattachfile$}.selfg = fgCol	
		#{txtName$}.fg = fgCol
		#{txtName$}.selfg = fgCol	
		 if chkName$="chksmtp" then 
			#{txtName$}.bg = bgCol	
			#{txtName$}.selbg = bgCol
			#{txtName$}.brdr = bgCol
			#{txtName$}.selbrdr = bgCol
			#{txtName$}.disabled = 1			
		 endif
	endif
End Sub

/***********************************************************
'** setDisableColor
 *	Description: 
 *		set disable color to the option buttons
 *		
 *	Params:
 *	Created by:jakques Franklin  On 2009-09-22 17:15:50
 *	History: 
 ***********************************************************/
sub setDisableColor
	#optlocalStorage[1].fg=UNSELECTED_TXT_COLOR
	#optlocalStorage[1].selfg=UNSELECTED_TXT_COLOR
	#optlocalStorage[2].fg=UNSELECTED_TXT_COLOR
	#optlocalStorage[2].selfg=UNSELECTED_TXT_COLOR
End Sub

/***********************************************************
'** Form_Paint
 *	Description: Paint gray image based on the condition

 *	Created by: Vimala On 2009-11-06 12:44:39
 ***********************************************************/
Sub Form_Paint
	
	if grayAllCtrls = 1 then		
		putimage2(~drpImage$,#ddstoragedur.x+#ddstoragedur.w,#ddstoragedur.y-2,5,0,0)	
		putimage2(~chkImage$,#chkmotiondet.x,#chkmotiondet.y,5,0,0)
		putimage2(~chkImage$,#chkethernethost.x,#chkethernethost.y,5,0,0)
		putimage2(~chkImage$,#chkexternaltriggers.x,#chkexternaltriggers.y,5,0,0)
		putimage2(~drpImage$,#ddinput.x+#ddinput.w,#ddinput.y-2,5,0,0)	
		putimage2(~drpImage$,#ddoutput.x+#ddoutput.w,#ddoutput.y-2,5,0,0)	
		putimage2(~chkImage$,#chkplayaudio.x,#chkplayaudio.y,5,0,0)
		putimage2(~drpImage$,#ddSelectAlarm.x+#ddSelectAlarm.w,#ddSelectAlarm.y-2,5,0,0)	
	end if
	
	
	' change the Image 
	if #chkftp.disabled = 1 then 
		putimage2(~chkImage$,#chkftp.x,#chkftp.y,5,0,0)
		putimage2(~drpImage$,#ddftp.x+#ddftp.w,#ddftp.y-2,5,0,0)
	end if
	
	if #chksmtp.disabled = 1 then 	
		putimage2(~chkImage$,#chksmtp.x,#chksmtp.y,5,0,0)
		putimage2(~drpImage$,#ddsmtp.x+#ddsmtp.w,#ddsmtp.y-2,5,0,0)	
	end if
	
	if #chkLocalStorage.disabled = 1 then 	
		putimage2(~chkImage$,#chkLocalStorage.x,#chkLocalStorage.y,5,0,0)
		putimage2(~drpImage$,#ddLocStorage.x+#ddLocStorage.w,#ddLocStorage.y-2,5,0,0)
		putimage2(~optImage$,#optlocalStorage[0].x,#optlocalStorage[0].y,5,0,0)	
	end if
	
	putimage2(~optImage$,#optlocalStorage[1].x,#optlocalStorage[1].y,5,0,0)
	putimage2(~optImage$,#optlocalStorage[2].x,#optlocalStorage[2].y,5,0,0)
	putimage2(~chkImage$,#chkdarkblank.x,#chkdarkblank.y,5,0,0)					'TR-21
	
End Sub

/***********************************************************
'** setCheckBox
 *	Description: 
 *		Set the alarm setings check box property.
 *		If proprty is invalid set unchecked
 *	Params:
'*		dimi ctrlName$: String - control name
 *		dimi propValue: Numeric - property value
 *	Created by: Partha Sarathi.K On 2009-03-18 19:39:38
 *	History: 
 ***********************************************************/
sub setCheckBox(dims ctrlName$, dimi propValue)	
	iff propValue <> 0 and propValue <> 1 then propValue = 0
	#{ctrlName$}.checked = propValue	
End Sub

/***********************************************************
'** cmdSave_Click
 *	Description: call savePage to save values to the camera.
 
 *	Created by: Vimala On 2009-03-11 15:53:19
***********************************************************/
Sub cmdSave_Click
	if canReload = 1 then
		savePage()		
	end if
End Sub

/***********************************************************
'** savePage
 *	Description: Checks for minimum and maximum number of files
 *				 attached.
 *				 Set user input control values to the camera.	
 
 *	Created by: Vimala  On 2009-05-28 16:34:07
 *	History: 
 ***********************************************************/
Sub savePage()	
	pprint "alarmsettings.bas"
	dimi retVal,i
	
	if  #txtattachfile < smtpMinFiles or #txtattachfile > smtpMaxFiles then
		msgbox("The attached file numbers must be between(include) "+smtpMinFiles+" and "+smtpMaxFiles)
		setfocus("txtattachfile")
		return
	endif	
	
	retVal = setAlarmSetting(#chkenablealarm,#ddstoragedur, _
							 #chkmotiondet,#chkEthernetHost, _
							 #chkexternaltriggers,#ddinput,#ddoutput, _
							 #chkftp,#ddftp, #chksmtp,#ddsmtp,#txtattachfile,#chklocalstorage,#ddlocstorage, _
							 #optlocalstorage,#chkplayaudio, #ddSelectAlarm)
	
	saveSuccess = retVal
	tempX = #lblsuccessmessage.x
	'Based on reload flag wait for the camera to restart
	if getReloadFlag() = 1 then									'TR-45		
		#lblsuccessmessage.style = 128
		#lblsuccessmessage.x = #lblsuccessmessage.x + #lblsuccessmessage.w/3
		canReload = 0
		animateCount = 1
		animateLabel("lblsuccessmessage","Updating Camera")
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
//		#lblsuccessmessage$ = "报警设置已保存到系统 "+~title$		'TR-35	
//		isMessageDisplayed = 1												'TR-35
//		#lblsuccessmessage.paint(1)		
	else		
		if ~keywordDetFlag = 1 then
			msgbox("Alarm setting for \n"+~errorKeywords$+"\nfailed for the camera "+~title$)
		else 
			msgbox("Alarm setting failed for the camera "+~title$)
		endif
	endif
	
	call loadInitialValues() 
	call chkEnableAlarm_Click						'TR-21
	~changeFlag = 0
	setfocus("chkenablealarm")
	~changeFlag = 0	
	canReload = 1	
	call Form_complete()
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
'** cmdCancel_Click
 *	Description: Reload the alarm setting page.
 
 *	Created by: vimala On 2009-03-17 15:47:46
 ***********************************************************/
Sub cmdCancel_Click	
	if canReload = 1 then
		~changeFlag = 0	
		call loadInitialValues()
		call chkEnableAlarm_Click						'TR-21
	end if
End Sub


/***********************************************************
'** chkExternalTriggers_Click
 *	Description: call CheckExternalTriggers function to 
 *				 enable or disable controls
 
 *	Created by:vimala  On 2009-04-07 12:53:58
 ***********************************************************/
Sub chkExternalTriggers_Click
	call CheckExternalTriggers()
End Sub

/***********************************************************
'** CheckExternalTriggers
 *	Description: Call this function to enable or disable 
 *				 corresponding controls
 
 *	Created by: vimala On 2009-04-07 12:57:39
 ***********************************************************/
Sub checkExternalTriggers()
	
	if #chkExternalTriggers.checked = 1 then
		#ddInput.disabled = 0
		#ddOutput.disabled = 0
	else 
		#ddInput.disabled = 1
		#ddOutput.disabled = 1
	endif
	
End Sub


/***********************************************************
'** chkFTP_Click
 *	Description: Call checkFTP function to  
 *				 enable or disable controls
 
 *	Created by: vimala On 2009-04-07 12:54:38
 ***********************************************************/
Sub chkFTP_Click
	call checkFTP()	
End Sub

/***********************************************************
'** checkFTP
 *	Description: Call this function to enable or disable 
 *				 corresponding controls
 
 *	Created by: vimala On 2009-04-07 12:58:27
 ***********************************************************/
sub checkFTP()
	
	if #chkFTP.checked = 1 then
		#ddFTP.disabled = 0
	else 
		#ddFTP.disabled = 1
	endif
	
End Sub



/***********************************************************
'** chkSMTP_Click
 *	Description: Call checkSMTP function to  
 *				 enable or disable controls
 
 *	Created by: vimala On 2009-04-07 12:56:06
 ***********************************************************/
Sub chkSMTP_Click
	call checkSMTP()
End Sub

/***********************************************************
'** checkSMTP
 *	Description: Call this function to enable or disable 
 *				 corresponding controls
 
 *	Created by: vimala On 2009-04-07 14:12:44
 ***********************************************************/
sub checkSMTP()
	
	if #chkSMTP.checked = 1 then
		#ddSMTP.disabled = 0
	else 
		#ddSMTP.disabled = 1
	endif
	
End Sub



/***********************************************************
'** chkLocalStorage_Click
 *	Description: Call checkLocalStorage function to  
 *				 enable or disable controls

 *	Created by: vimala On 2009-04-07 12:56:08
 ***********************************************************/
Sub chkLocalStorage_Click	
	call checkLocalStorage()		
End Sub


/***********************************************************
'** checkLocalStorage
 *	Description: Call this function to enable or disable 
 *				 corresponding controls
 
 *	Created by: vimala On 2009-04-07 14:14:55

 ***********************************************************/
sub checkLocalStorage()
	
	if #chkLocalStorage.checked = 1 then
		#ddLocStorage.disabled = 0
		#optLocalStorage[0].disabled = 0
	else 
		#ddLocStorage.disabled = 1
		#optLocalStorage[0].disabled = 1		
	endif
	
	#optLocalStorage[1].disabled = 1
	#optLocalStorage[2].disabled = 1
End Sub



/***********************************************************
'** chkplayAudio_Click
 *	Description: Call checkplayAudio function to  
 *				 enable or disable controls
 
 *	Created by: vimala On 2009-04-07 14:18:27

 ***********************************************************/
Sub chkplayAudio_Click	
	call checkplayAudio()	
End Sub

/***********************************************************
'** checkplayAudio
 *	Description: Call this function to enable or disable 
 *				 corresponding controls
 *	Created by: vimala On 2009-04-07 14:18:44
 *	History: 
 ***********************************************************/
sub checkplayAudio()
	
	if #chkplayAudio.checked = 1 then
		#ddSelectAlarm.disabled = 0
	else 
		#ddSelectAlarm.disabled = 1
	endif
	
End Sub



/***********************************************************
'** Form_KeyPress
 *	Description: Checks entered key value based on the rule set to that user input control		 
 *		
 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by: vimala On 2009-05-11 06:11:45
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )	
	scroll_keypressed(key)				'Lock mouse scroll	
	dims keypressed$		
	keypressed$ = chr$(Key)
	
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)
	
	setSubMenuFocus(Key,6)	
End Sub


'Display cursor in control focus event else hide cursor

Sub txtAttachFile_Focus
	rule = 7 
	iff #txtattachfile.disabled = 1 then showcursor(0)
End Sub

Sub txtAttachFile_blur
	showcursor(3)
End Sub

Sub chkEnableAlarm_Focus
	iff #chkEnableAlarm.disabled = 0 then showcursor(1)
End Sub


Sub chkdarkblank_Focus
	showcursor(3)
End Sub


Sub chkEnableAlarm_Blur
	showcursor(3)
End Sub

Sub chkMotionDet_Focus
	iff #chkMotionDet.disabled = 0 then  showcursor(1)
End Sub

Sub chkexternaltriggers_Focus
	iff #chkexternaltriggers.disabled = 0 then  showcursor(1)
End Sub

Sub chkExternalTriggers_Blur
	showcursor(3)
End Sub

Sub chkFTP_Focus
	iff #chkftp.disabled = 0 then  showcursor(1)
End Sub

Sub chkFTP_Blur
	showcursor(3)
End Sub

Sub chkSMTP_Focus
	iff #chkSMTP.disabled = 0 then showcursor(1)
End Sub

Sub chkSMTP_Blur
	showcursor(3)
End Sub

Sub chkLocalStorage_Focus
	iff #chkLocalStorage.disabled = 0 then showcursor(1)
End Sub

Sub chkLocalStorage_Blur
	showcursor(3)
End Sub

Sub chkplayAudio_Focus
	iff #chkplayAudio.disabled = 0 then  showcursor(1)
End Sub

Sub chkplayAudio_Blur
	showcursor(3)
End Sub

Sub optLocalStorage_Focus	
	iff #optlocalStorage.disabled = 0 then showcursor(1)
End Sub

Sub optLocalStorage_Blur
	showcursor(3)
End Sub


/***********************************************************
'** chkEnableAlarm_Click
 *	Description: Gray out all the controls if enable alarm is disabled
 *
 *	Created by:Vimala On 2009-11-06 12:17:59
 ***********************************************************/
Sub chkEnableAlarm_Click							'TR-21
	
	pprint "chkEnableAlarm_Click begin"
	if #chkenablealarm.checked = 0 then		
		grayOutCtrls(1,UNSELECTED_BG_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_BG_COLOR)		
	else 
		grayOutCtrls(0,40180,40180,1,10961)
	end if
	pprint "checkOnAlarm begin"
	call checkOnAlarm()
	pprint "ccheckOnAlarm end"
	#chkdarkblank.disabled = 1						'TR-21
	#chkdarkblank.fg=UNSELECTED_TXT_COLOR			'TR-21
	#chkdarkblank.selfg=UNSELECTED_TXT_COLOR		'TR-21
	call CheckExternalTriggers()
	pprint "CheckExternalTriggers end"
	call checkFTP()
	pprint "checkFTP end"
	call checkSMTP()
	call checkLocalStorage()
	call checkplayAudio()
End Sub


/***********************************************************
'** grayOutCtrls
 *	Description: call this function to gray out controls
 
 *	Params:
'*		dimi disableFlag: Numeric - disable value (0 - enable / 1 - disable)
'*		dimi bgColor: Numeric - Background color
'*		dimi fgColor: Numeric - Foreground color
'*		dimi brdrColor: Numeric - Border color for the control
 *		dimi selBGColor: Numeric - Selected Background color
 *	Created by:  On 2009-11-06 12:28:25
 *	History: 
 ***********************************************************/
sub grayOutCtrls(dimi disableFlag,dimi bgColor,dimi fgColor,dimi brdrColor,dimi selBGColor)			'TR-21
	dimi i
	pprint "noofcrtl="+noofctrl
	for i = 0 to noofctrl-2
		pprint "LabelName$("+i+")="+LabelName$(i)
		iff LabelName$(i) = "lblCamera" then continue		
		iff LabelName$(i) = "roCamera" then continue		
		iff find(LabelName$(i),"cmd")>=0 then continue		
		#{LabelName$(i)}.disabled = disableFlag
		#{LabelName$(i)}.fg = fgColor
		#{LabelName$(i)}.selfg = fgColor

		if find(LabelName$(i),"dd")>=0 or find(LabelName$(i),"txt")>=0  then
			#{LabelName$(i)}.fg = brdrColor
			#{LabelName$(i)}.selfg = brdrColor	
			#{LabelName$(i)}.bg = bgColor	
			#{LabelName$(i)}.brdr = bgColor	
			iff disableFlag = 0 then #{LabelName$(i)}.brdr = brdrColor	
			#{LabelName$(i)}.selbrdr = brdrColor	
			#{LabelName$(i)}.selbg = selBGColor						
		end if
						
	next
	
	grayAllCtrls = disableFlag
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


Sub ddStorageDur_Click
	' Add Handler Code Here 
End Sub

