/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Date \ Time Setting                                                *
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
Call this page to view and set Date and Time setting
*/

settimer(1000)
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

#include "setDateTime.inc"

dims dateFormat$
dims dateInCamera$,timeInCamera$
dimi currdate,hours,minutes,seconds 
showcursor(3)
~wait = 2 										'added by Franklin to set wait flag when switching between forms
dimi displayCount,isMessageDisplayed			'TR-35  
displayCount = 1								'TR-35
dims ctrlValues$(noofctrl),tempLabelName$(noofctrl)
dimi stopTimerFlag=1
dimi animateCount = 0 	 ' Stores the count for the animation done.
dimi saveSuccess = 0	 'Value of 1 is success
dims error$ = "" 		 'Stores the error returned while saving.
dimi tempX				 ' Holds sucess message label
end


/***********************************************************
'** Form_Load
 *	Description: Call displayControls function to algin contorls
 *				 based on the screen resolution.
 *				 Fetch date and time values from camera and
 *				 assign values to controls.
 *			     Highlight the selected link in left menu.

 *	Created by: vimala On 2009-03-17 17:37:02
 ***********************************************************/
Sub Form_Load
	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	call loadDateTimeValues()
	call fetchDateTime()	
	call loadDefaultValues()
	
	showSubMenu(0,1)
	setfocus("rosubmenu[5]")
	selectSubMenu()
	setfocus("optsettime")
	call drpFormat_Change()		 								'BFIX-01
	#lblsuccessmessage$ = ""									'TR-35
End Sub


/***********************************************************
'** Form_Complete
 *	Description: Store all the control values in an array to validate changes in form.

 *	Created by:  On 2010-05-03 12:31:27
 ***********************************************************/
Sub Form_Complete	
	dimi i
	for i = 0 to ubound(ctrlValues$)-1		
		iff LabelName$(i) = "roTime" or LabelName$(i) = "roTimeComputer" then continue
		tempLabelName$(i) = LabelName$(i)
		ctrlValues$(i) = #{LabelName$(i)}$	
		pprint tempLabelName$(i);ctrlValues$(i)	
	next
	
	if canReload = 1 and ~UrlToLoad$ <> "" then		
		Dims ChangeUrl$
		ChangeUrl$ = ~UrlToLoad$
		~UrlToLoad$ = ""
		LoadUrl(ChangeUrl$)
	end If
End Sub

/***********************************************************
'** loadDateTimeValues
 *	Description: Call this function to fetch values from camera
 *				 and load the same to screen controls
 
 *	Created by: Vimala On 2009-03-19 10:12:52
 ***********************************************************/
sub loadDateTimeValues()
	#rocameraname$ = ~title$
	
	dims dateformat$(1),timeFormat$(1),datePosition$(1),timePosition$(1)
	dimi retVal
	
	'Get and Load drop down values	
	retVal =  getDateFormatOptions(dateformat$,timeFormat$,datePosition$,timePosition$)
	
	if retVal = 0 then
		call addItemsToDropDown("drpformat",dateformat$,-1)
		call addItemsToDropDown("drptimeFormat",timeFormat$,-1)
		call addItemsToDropDown("drpDatePosition",datePosition$,-1)
		call addItemsToDropDown("drpTimePostion",timePosition$,-1)
	endif	
	
	'Load hours,minutes and seconds in drop downs
	call loadTimeValues("drphour",23)
	call loadTimeValues("drpminute",59)
	call loadTimeValues("drpsecond",59)	
	
End Sub


/***********************************************************
'** loadDefaultValues
 *	Description: call this function to assign system date and time.
 
 *	Created by: vimala On 2009-03-17 17:45:05
 ***********************************************************/
Sub loadDefaultValues		
	dims sysTime$,temp$
	dimi splitCount
	sysTime$ = format$("Time",time())
	splitCount = split(temp$,sysTime$,":")
	
	if splitCount = 3 then
		#drphour$ = temp$(0)
		#drpminute$ = temp$(1)
		#drpsecond$ = temp$(2)
	end if	
	
	#rotimecomputer$ = format$("time",time())	
	call disableCtrls(1)	
End Sub




/***********************************************************
'** fetchDateTime
 *	Description: call this function to fetch values from the camera and 
 *				 assign the same to controls.
 
 *	Created by: vimala On 2009-03-17 17:52:52
 ***********************************************************/
Sub fetchDateTime	
	
	dimi retVal	
	dimi retTimezone
	dims sntpServer$
	dimi timezone,daylight,dateformat,timeFormat,datePosition,timePosition
	
	'Get and Load control values
	retVal = getDateTime(dateInCamera$,timeInCamera$,sntpServer$,timezone,daylight, _
					     dateformat,timeFormat,datePosition,timePosition)
		
	if retVal = -1 then
		msgbox("Unable to fetch  values")
		return
	endif
	
	dimi convertDate	
	convertDate = convertDateToGoDBFormat(dateInCamera$,"YYYY/MM/DD")
	displayDate("rocameradate",#drpFormat.ITEMLABEL$(#drpformat),convertDate)
	currdate = 	convertDate				
	hours = atol(left$(timeInCamera$,2))
	minutes = atol(mid$(timeInCamera$,3,2))
	seconds = atol(right$(timeInCamera$,2))		
	#rotime$ = timeInCamera$
	#rosntp$ = sntpServer$
	dateFormat$ = #drpFormat.ITEMLABEL$(#drpformat)
	#chkdaylight$ = daylight
	if daylight = 1 then
		#lbldayligth$ = "Daylight Saving Time Is Acitve."
	else 
		#lbldayligth$ = ""
	endif	
	
	'fetch time zone values	
	dims timezone$(1)
	retTimezone=getTimezones(timezone$,"timezoneinfo.txt")
	
	if retTimezone >= 0 then		
		call addItemsToDropDown("drpTimeZone", timezone$, timezone)		
	end if

	'Assign selected value to drop down
	#drpformat$ = dateformat
	#drptimeFormat$ = timeFormat
	#drpDatePosition$ = datePosition
	#drpTimePostion$ = timePosition	
	
End Sub


/***********************************************************
'** optsettime_click
 *	Description: Disable date and time control if other than
 *				 manually option is selected
 
 *	Created by: vimala On 2009-03-17 17:55:14
 ***********************************************************/
Sub optsettime_click	
		
	if #optsettime$ = "1" then
		call disableCtrls(0)		
	elseif #optsettime$ = "2" then
		call disableCtrls(1)		
	elseif #optsettime$ = "3" then
		call disableCtrls(1)
		#drpTimeZone.disabled = 0
		#chkdayLight.disabled = 0
	endif
		
End Sub


/***********************************************************
'** disableCtrls
 *	Description: Call this function to enable and disable controls.
 
 *	Params:
 *		dimi disablevalue: Numeric - 0 - to enable controls
 *									 1 - to disable control
 *	Created by: vimala On 2009-03-17 17:55:20
 *	History: 
 ***********************************************************/
Sub disableCtrls(dimi disablevalue)	
	#rodatemanually.disabled = disablevalue
	#drphour.disabled = disablevalue
	#drpminute.disabled = disablevalue
	#drpsecond.disabled = disablevalue	
	#drpTimeZone.disabled = 1
	#chkdayLight.disabled = 1
End Sub



/***********************************************************
'** cmdSubmit_Click
 *	Description:  call savePage to save values to the camera.
 
 *	Created by: vimala On 2009-03-17 18:11:50
 ***********************************************************/
Sub cmdSubmit_Click
	if canReload = 1 then
		savePage()		
	end if	
End Sub



/***********************************************************
'** savePage
 *	Description: Saves date and time setting values to camera 
 *				 based on selected options.
 
 *	Created by: Vimala On 2009-05-28 16:34:07
 ***********************************************************/
Sub savePage()
	pprint "setdatetime.bas"
	~debugInfo$ += "Date time Settings \n"
	dimi retVal,retTimeZone,i
	dims manualTime$
	dims dateManually$
	
	if #optsettime$ = "1" then
		manualTime$ = #drphour$+":"+#drpminute$+":"+#drpsecond$	
		dateManually$ = convertDateFormat$(format$("8",#rodatemanually.tag))	
	elseif  #optsettime$ = "2" then
		manualTime$ = #rotimecomputer$
		dateManually$ = convertDateFormat$(format$("8",date()))
	elseif #optsettime$ = "3" then
		dateManually$ = dateInCamera$
		manualTime$ = timeInCamera$
	else
		dateManually$ = dateInCamera$
		manualTime$ = timeInCamera$
	endif		
	
	retVal = setDatetime(#optsettime,dateManually$,manualTime$,_
						 #drpformat,#drptimeformat,#drpdateposition,#drptimepostion,_
						 #drptimezone,#chkdaylight)
	
	settimer(1000) 
	
	saveSuccess = retVal
	tempX = #lblsuccessmessage.x
	'Based on reload flag wait for the camera to restart
	if getReloadFlag() = 1 then									'TR-45		
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
//	#lblsuccessmessage.style = 64
//		#lblsuccessmessage.x = tempX
//		#lblsuccessmessage$ = "日期/时间设置已保存到系统 "+~title$		'TR-35	
//		isMessageDisplayed = 1													'TR-35	
//		#lblsuccessmessage.paint(1)		
	elseif saveStatus = -11 then 
		return
	else
		if ~keywordDetFlag = 1 then
			msgbox("Date/Time setting for \n"+~errorKeywords$+"\nfailed for the camera "+~title$)
		else
			msgbox("Date/Time setting failed for the camera "+~title$)
		endif
	endif
	
	call loadDateTimeValues()	
	call fetchDateTime()	
	call optsettime_click
	call drpFormat_Change()		 						'BFIX-01
	settimer(1000,"DisplayDigitalClock")
	setfocus("optsettime")
	~changeFlag = 0	
	canReload = 1	
	call Form_complete()
End Sub


/***********************************************************
'** rodateManually_Click
 *	Description: Popup calender and allow user to select date.
 
 *	Created by: vimala On 2009-03-17 18:03:06
 ***********************************************************/
Sub rodateManually_Click	
	dimi  retVal
	retVal = showdate(date(),(#lblSetTime.x+10),(#rodatemanually.y+#rodatemanually.h+5))
	
	if retVal = 1 then 		
		displayDate("rodateManually",#drpFormat.ITEMLABEL$(#drpformat),dateval())		
		#rodatemanually.tag = dateval()		
	endif
End Sub



/***********************************************************
'** displayDate
 *	Description: call this function to display date in selected format.
 
 *	Params:
'*		dims ctrlName$: String - control name
'*		dims dateFormat$: String - Date format
 *		dimi setVal: Numeric - selected value
 *	Created by: vimala On 2009-03-17 18:03:06

 ***********************************************************/
Sub displayDate(dims ctrlName$,dims dateFormat$,dimi setVal)		
		
	if dateFormat$ = "YYYY/MM/DD" then
		#{ctrlName$}$ = convertDateFormat$(format$("8",setVal))				
	elseif dateFormat$ = "MM/DD/YYYY" then	
		#{ctrlName$}$ = format$("DATE0",setVal)			
	elseif dateFormat$ = "DD/MM/YYYY" then		
		#{ctrlName$}$ = format$("DATE1",setVal)			
	endif	
	
End Sub

/***********************************************************
'** drpFormat_Change
 *	Description: Displays date in selected date format.
 
 *	Created by: vimala On 2009-03-17 18:18:17
 
 ***********************************************************/
Sub drpFormat_Change	
	dimi convertDate	
	convertDate = convertDateToGoDBFormat(#rocameradate$,dateFormat$)
	pprint convertDate
	
	if #drpFormat.ITEMLABEL$(#drpformat) = "YYYY/MM/DD" then
		#rocameradate$ = convertDateFormat$(format$("8",convertDate))		
		#rodatemanually$ = convertDateFormat$(format$("8",date()))
		#rodatemanually.tag = date()
		#rodatecomputer$ = convertDateFormat$(format$("8",date()))		
	elseif #drpFormat.ITEMLABEL$(#drpformat) = "MM/DD/YYYY" then	
		#rocameradate$ = format$("DATE0",convertDate)	
		#rodatemanually$ = format$("DATE0",date())
		#rodatemanually.tag = date()
		#rodatecomputer$ = format$("DATE0",date())
	elseif #drpFormat.ITEMLABEL$(#drpformat) = "DD/MM/YYYY" then		
		#rocameradate$ = format$("DATE1",convertDate)	
		#rodatemanually$ = format$("DATE1",date())
		#rodatemanually.tag = date()
		#rodatecomputer$ = format$("DATE1",date())
	endif
	
	dateFormat$ = #drpFormat.ITEMLABEL$(#drpformat)	 	
	
End Sub

/***********************************************************
'** convertDateToGoDBFormat
 *	Description: Converts the date to GoDB format - YYYYMMDD.
 
 *	Params:
'*		dims dateInCamera$: String - date  
 *		dims formatType$: String - format type of the date
 *	Created by: vimala On 2009-03-17 18:20:09
 ***********************************************************/
Function convertDateToGoDBFormat(dims dateInCamera$,dims formatType$)	
	
	convertDateToGoDBFormat = 0
	
	dims sptVal$(3)
	dimi retVal,sptIDx
	dims convertedDate$
	retVal = split(sptVal$,dateInCamera$,"/")
	
	if retVal = 3 then
				
		if formatType$ = "YYYY/MM/DD" then     
			convertedDate$ = sptVal$(0)+sptVal$(1)+sptVal$(2)			
		elseif formatType$ = "MM/DD/YYYY" then     		
			convertedDate$ = sptVal$(2)+sptVal$(1)+sptVal$(0)												   
		elseif formatType$ = "DD/MM/YYYY" then	  
			convertedDate$ = sptVal$(2)+sptVal$(1)+sptVal$(1)						
		endif
		
		convertDateToGoDBFormat = strtoint(convertedDate$)
	endif	
	
End Function

/***********************************************************
'** convertDateFormat$
 *	Description: Convert GoDB date to YYYY/MM/DD format.
 
 *	Params:
 *		dims dateInCamera$: String - Date in GoDB format YYYYMMDD
 *	Created by: vimala On 2009-03-17 18:20:50

 ***********************************************************/
Function convertDateFormat$(dims dateInCamera$)	
	
	convertDateFormat$ = left$(dateInCamera$,4)+"/"+mid$(dateInCamera$,4,2)+"/"+right$(dateInCamera$,2)
	
End Function


/***********************************************************
'** DisplayDigitalClock
 *	Description: Call this function to increment time by one second.
 
 *	Created by: vimala On 2009-03-17 18:21:49
 ***********************************************************/
Sub DisplayDigitalClock()
		
	dims hour$,min$,sec$ 	
	
	if seconds < 59 then
		seconds++
	else
		seconds = 0
		if minutes < 59 then
			minutes++
		else 
			minutes = 0
			if hours < 23 then
				hours++
			else 
				hours = 0
				currdate = dateadd(currdate,1,0)				
			endif
		endif
	endif
	
	hour$ = format$("2",hours)
	min$ = format$("2",minutes)
	sec$ = format$("2",seconds)
		
	iff atol(hour$)< 10 then hour$ = "0"+trim$(hour$)
	iff atol(min$)< 10 then min$ = "0"+trim$(min$)
	iff atol(sec$)< 10 then sec$ = "0"+trim$(sec$)	
		
	displayDate("rocameradate",#drpFormat.ITEMLABEL$(#drpformat),currdate)		
	#rotime$ = hour$+":"+min$+":"+sec$		
	#rocameradate.paint(1)
	#rotime.paint(1)
	displayDate("roDateComputer",#drpFormat.ITEMLABEL$(#drpformat),date())		
	'#roDateComputer.paint(1)
	#rotimecomputer$ =  format$("time",time())
	iff stopTimerFlag = 1 then #rotimecomputer.paint(1)	
	
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
	pprint "displayCount = " + displayCount
	
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
'** form_timer
 *	Description:  Every second DisplayDigitalClock function 
 *				  is called to increment time value to display in UI.

 *	Created by:  On 2009-03-19 17:06:09
 ***********************************************************/
Sub form_timer	
	call DisplayDigitalClock()
End Sub


/***********************************************************
'** Form_KeyPress
 *	Description: Lock mouse scroll 	
				 call setSubMenuFocus to set focus in left menu
 *		
 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by:  On 2009-05-16 03:47:17
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )
	scroll_keypressed(key)    'Lock mouse scroll
	setSubMenuFocus(Key,4)
End Sub


/***********************************************************
'** cmdCancel_Click
 *	Description: Fetch value from the camera(Reload the page)

 *	Created by: vimala On 2009-05-19 11:39:43
 ***********************************************************/
Sub cmdCancel_Click	
	if canReload = 1 then
		call loadDateTimeValues()
		call fetchDateTime()	
		call loadDefaultValues()
		#optsettime$ = ""
		~changeFlag = 0	
		call drpFormat_Change()		 					'BFIX-01
	end if
End Sub



/***********************************************************
'** drphour_Click
 *	Description: Stop paint of computer time
 
 *	Created by: Vimala On 2010-05-03 13:07:41
 ***********************************************************/
Sub drphour_Click	
	stopTimerFlag = 0
End Sub

/***********************************************************
'** drphour_Blur
 *	Description: Paint computer time 

 *	Created by:Vimala  On 2010-05-03 13:09:51
 ***********************************************************/
Sub drphour_Blur	
	stopTimerFlag = 1
End Sub


/***********************************************************
'** drphour_Change
 *	Description: Paint computer time 

 *	Created by:Vimala  On 2010-05-03 13:10:07
 ***********************************************************/
Sub drphour_Change	
	stopTimerFlag = 1
End Sub

/*
Sub Form_MouseMove( x, y )
	mousehandled(0)
End Sub*/



'Display cursor in control focus event else hide cursor
Sub optSetTime_Focus
	showcursor(1)
End Sub

Sub optSetTime_Blur
	showcursor(3)
End Sub

Sub chkdayLight_Focus
	showcursor(1)
End Sub

Sub chkdayLight_Blur
	showcursor(3)
End Sub


/***********************************************************
'** chkValueMismatch
 *	Description: Call this function to check whether the control values are modified or not.
 *				 set ~changeFlag = 1 if control value modified.

 *	Created by: Vimala On 2010-04-30 18:01:13
 ***********************************************************/
sub chkValueMismatch()	
	checkForModification(ctrlValues$, tempLabelName$)
End Sub



