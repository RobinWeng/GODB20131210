/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Storage Settings                                            *
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

dimi timerCount

#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"
option(4+1)

dimi noofctrl												'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS                      
dims LabelName$(noofctrl)                                   'Form controls name
dimi XPos(noofctrl)                                         'Form controls X position
dimi YPos(noofctrl)                                         'Form controls Y position
dimi Wdh(noofctrl)                                          'Form controls Width position
dimi height(noofctrl)                                       'Form controls height position
                                                      
#include "storageSetting.inc"

#define UNSELECTED_TXT_COLOR      17004
#define UNSELECTED_BRD_COLOR	  14826
#define UNSELECTED_BG_COLOR	      14826
#define TOOLTIP_MAXINDEX    	  80                   

#define CHK_BLUE             25
#define CHK_GREEN            1638
#define CHK_PURPLE			 38937	
#define CHK_RED				 63878
#define CHK_AQUA			 1657
#define CHK_THICKGREEN		 800 	
#define CHK_ORANGE			 52000
        

#define SCHEDULE_W             750 
#define SCHEDULE_H             250 * ~factorY
#define SCH_BG_COL             6602
#define SCH_BDR_COL            2245

#define SCH_TIT_H              24
#define SCH_TIT_BG             2245
#define SCH_TIT_FG             55038
#define SCH_TIT_STYLE          0
#define SCH_TIT_FONT           10
#define SCH_TIT_X_GAP          10

#define TOT_HOUR               24
#define DURATION_HOUR          6
#define MAX_MIN                15
#define MAX_DAYS               7

#define DAY_DISPLAY_W          150
#define DAY_X_GAP              10
#define DAY_TXT_STYLE          8
#define DAY_TXT_FG             55038
#define DAY_TXT_FONT           7

#define HOUR_DISPLAY_Y_GAP     2
#define HOUR_TXT_STYLE         8
#define HOUR_TXT_FG            65535
#define HOUR_TXT_FONT          7

#define SCH_IDX_W              3

#define SCH_IDX_H              10 * ~factorY

#define SCH_IDX_GAP			   3

#define SCH_IDX_Y_GAP          20 * ~factorY
#define SCH_IDX_BG             52793
#define SCH_IDX_SEL_BG         7355
#define SCH_IDX_LINE_H         20 * ~factorY
#define SCH_IDX_CUR_SEL_BG     64520

#define MAX_SCHEDULE           7
#define DAY_HEIGHT             7

#define TOOLTIP_WIDTH          185
#define TOOLTIP_HEIGHT          17
#define TOOLTIP_COLOR          65535

#define POPUP_WIDTH            285
#define POPUP_HEIGHT           17
#define ALPHA_LEVEL            0

dimi paintFlag=1
dimi startval(7), endval(7)   
dims frmMin$(7), frmHrs$(7), toMin$(7), toHrs$(7)
dimi cur_color
dims day$(MAX_DAYS) = ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
dimi totSchedule									'to calculate the total number of schedules
totSchedule = (60/MAX_MIN)*DURATION_HOUR*(TOT_HOUR/DURATION_HOUR)

dims stringSchedule$    							'to get the schedule time as string              
dimi scheduleIdx(MAX_DAYS, totSchedule) 			'to pass the schedule index            
dims schedule$(MAX_DAYS) 							'to store each schedule individually 
dims recordSchedule$(MAX_DAYS) 						'to concat all the individual schedules

dimi selIdxRow = -1									'to store the selected inedx of the row info when the mouse click event is raised
dimi selectedRow									'to store the selected row info when the mouse click event is raised
dimi selectIdx										'to keep track of the selected index during mouse move 
dimi oldEndIdx										'to keep track of the end index during mouse move 
dimi curx,cury,prvX,prvY					        'to store the current(x,y) and previous(x,y) position
dims prvScreen$ 									'to keep track of the previous screen before & after mouse move event
dimi rule=0;										
dimi scheduleX, scheduleY
dimi removeSHDLFlag=0								'to set the flag when schedule is removed
Dimi httpFlag=0										
Dimi mouseClickflag=1								'to set the flag when the mouse click event is fired
call findXYPos()									'to find the XY position of the scheduler with respect to the current resolution	

showcursor(3)
dimi ~mousemoveflag=0
~wait = 2 										'added by Franklin to set wait flag when switching between forms
dims drpName$(5) = ("drpday","drpfromhrs","drptohrs","drpfrommin","drptomin")
settimer(1000)
dimi displayCount,isMessageDisplayed			'TR-35  
displayCount = 1								'TR-35
dims ctrlValues$(noofctrl)
dimi animateCount = 0 	 ' Stores the count for the animation done.
dimi saveSuccess = 0	 'Value of 1 is success
dims error$ = "" 		 'Stores the error returned while saving.
dimi tempX				 ' Holds X value of success message label
End

/***********************************************************
'** form_load
 *	Description: 
 *		To set the X,Y positions for all the Controls with respect to the Resolution
 *		Align Schedule frame based on screen resolution.

 *	Created by: Franklin Jacques  On 2009-06-09 10:51:24
 ***********************************************************/
Sub form_load
	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	
	showSubMenu(0,1)
	setfocus("rosubmenu[8]")
	selectSubMenu()
	setfocus("chkuploadviaftp")
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	'Disable all the schedule drop downs
	call disableScheduleDrp()						'TR-01
	'Load schedule drop down values
	call loadDropDownValues()						'TR-01
		
	if #optrepeatschedule = 1 then
		#txtweeks.disabled = 0
	else 
		#txtweeks.disabled = 1
	end if 
	
	'Align Schedule frame to fit in screen	
	call alignFramectrls()							'TR-01
	
	'Set the initial settings for the scheduler and other controls  
	call setInitialScheduler()     					'TR-01 
	
	'set disable color to the option buttons
	call setDisableColor                                   
	#lblsuccessmessage$ = ""						'TR-35
End Sub


/***********************************************************
'** setDisableColor
 *	Description: 
 *		set disable color to the option buttons

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
'** disableScheduleDrp
 *	Description: Call this function to disable drop downs if check  
 *				 box is unchecked.

 *	Created by:S.Vimala On 2009-08-31 17:29:36
 ***********************************************************/
sub disableScheduleDrp()							   'TR-01
	dimi i,j,xval,yval
	dims ctrlName$,tmpName$
	
	for i = 1 to 7
		ctrlName$ = "chkschedule"+i
		enableDrpCtrls(ctrlName$,i)			
	next
	
End Sub

/***********************************************************
'** alignFramectrls
 *	Description: Align Schedule model frame width and height based 
				 on the screen resolution. 
				 
 *	Created by: S.Vimala On 2009-08-31 17:52:15
 ***********************************************************/
sub alignFramectrls()								   'TR-01
	#frschedule.w = (#drptomin7.x + #drpday2.w) - #frschedule.x +10
	#lblSchedule.w = #frschedule.w - 20
	#frschedule.h = (#btnframeok.y + #btnframeok.h) - #frschedule.y +10
End Sub


/***********************************************************
'** loadDropDownValues
 *	Description: Call this function to load schedule drop down values
 
 *	Created by: S.Vimala On 2009-08-31 17:53:16
 ***********************************************************/
Sub loadDropDownValues()				'TR-01
	dimi loopcnt,i
	dims ctrlName$	
	for i = 1 to 7
		ctrlName$ = "drpday"+i
		for loopcnt = 0 to ubound(day$)	
			#{ctrlName$}.additem(loopcnt,day$(loopcnt))
		next
	next
	
	for loopcnt = 1 to 7
		loadTimeValues("drpfromhrs"+loopcnt,23)
		loadTimeValues("drptohrs"+loopcnt,23)
		loadTimeValues("drpfrommin"+loopcnt,59)
		loadTimeValues("drptomin"+loopcnt,59)
	next
	
End Sub


/***********************************************************
'** form_paint
 *	Description: Paint scheduler.
				 Gray controls based on the control disable property
				
 *	Created by: Franklin Jacques On 2009-03-12 17:21:45
 ***********************************************************/
sub form_paint
	iff #frSchedule.hidden=1 and paintFlag=1 then call drawScheduler()					'TR-01	
	
	if #ChkUploadViaFtp.disabled = 1 then 
		putimage2(~chkImage$,#ChkUploadViaFtp.x,#ChkUploadViaFtp.y,5,0,0)
		putimage2(~drpImage$,#ddstorageformat.x+#ddstorageformat.w,#ddstorageformat.y-2,5,0,0)
	end if
	
	if #chkLocalStorage.disabled = 1 then 
		putimage2(~chkImage$,#chkLocalStorage.x,#chkLocalStorage.y,5,0,0)
		putimage2(~drpImage$,#ddstorageformat1.x+#ddstorageformat1.w,#ddstorageformat1.y-2,5,0,0)
		putimage2(~optImage$,#optlocalStorage[0].x,#optlocalStorage[0].y,5,0,0)
	end if
	
	putimage2(~optImage$,#optlocalStorage[1].x,#optlocalStorage[1].y,5,0,0)
	putimage2(~optImage$,#optlocalStorage[2].x,#optlocalStorage[2].y,5,0,0)

	iff #frschedule.hidden = 0 then  call grayDropdown()		'TR-01	
	
End Sub



/***********************************************************
'** grayDropdown
 *	Description: Call this function to gray the drop down boxes if unchecked
 *	
 *	Created by: S.Vimala On 2009-08-31 17:56:23
 ***********************************************************/
Sub grayDropdown()									  'TR-01 
	dimi i,xval,yval,j
	dims ctrlName$,tmpName$
	
	for i = 1 to 7
		ctrlName$ = "chkschedule"+i
		
		if #{ctrlName$}.checked = 0 then 
			
			for j = 0 to ubound(drpName$)		
				tmpName$ = drpName$(j)+ i					
				xval = #{tmpName$}.x+#{tmpName$}.w
				yval = #{tmpName$}.y-2
				putimage2(~drpImage$,xval,yval,5,0,0)
				#{tmpName$}.disabled = 1
			next				
					
		end if
		
	next
	
End Sub
	


/***********************************************************
'** findXYPos
 *	Description: 
 *		Find the X and Y pos for draw the scheduler window.

 *	Created by: Franklin Jacques On 2009-03-12 17:24:03
 ***********************************************************/
sub findXYPos()
	if ~menuXRes = 1024 then 
		scheduleX = #imgmainbg.x + 15
	else
		scheduleX = #lbldummy.x *~factorX
	end if
	
	scheduleY = #lbldummy.y *~factorY
End Sub


/***********************************************************
'** form_complete
 *	Description: 
 *		To set the value for the Check box ctrl-chkUploadViaFtp,
		 chkLocalStorage 
		 Store all the control values in an array to validate changes in form.

 *	Created by:  On 2009-05-19 15:29:32
 ***********************************************************/
sub form_complete
	call chkUploadViaFtp_Click
	call chkLocalStorage_Click
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
'** setInitialScheduler
 *	Description: To set the initial values for the controls and schedule time 
 *		using the method : getStorageSetting
 *		
 *	Params:
 *	Created by:Jacques Franklin On 2009-03-12 20:15:40
 *	History: 
 ***********************************************************/
sub setInitialScheduler()	
	dimi row, col
	dims ddValue$
	
	'Initialize scheduleIdx array to 0
	For row = 0 To MAX_DAYS-1
		For col=0 to totSchedule-1
			scheduleIdx(row, col) = 0
		Next
	Next	
	
	dimi ret
	dimi uploadbyFTP,storeLocally,localStorage,repeatSchedule,noOfWeeks,scheduleInfinity,ftpfileformat,sdfileformat
	dims ftpfileformatname$, sdfileformatname$
	dimi sdCard
	
	'Get storage setting values from camera
	ret=getStorageSetting(uploadbyFTP, ftpfileformat, ftpfileformatname$, storeLocally, _
						  sdfileformat, sdfileformatname$, localStorage, repeatSchedule, noOfWeeks, _
						  recordSchedule$,scheduleInfinity,sdCard)
	if ret = 0 then
		call setValuesToDropDown(recordSchedule$)
		#rocamera$ = ~title$
		split(ddValue$,ftpfileformatname$,";")
		call addItemsToDropDown("ddstorageformat", ddValue$, ftpfileformat)
		split(ddValue$,sdfileformatname$,";")
		call addItemsToDropDown("ddstorageformat1", ddValue$, sdfileformat)
		iff uploadbyFTP = 0 or uploadbyFTP = 1 then #ChkUploadViaFtp$=uploadbyFTP
		iff storeLocally = 0 or storeLocally = 1 then #ChkLocalStorage$=storeLocally
		iff localStorage = 0 or localStorage = 1 or localStorage = 2 then #optlocalstorage$=localStorage
		iff repeatSchedule = 0 or repeatSchedule = 1 then #optRepeatSchedule$=repeatSchedule
		iff scheduleInfinity = 0 or scheduleInfinity = 1 then #optruntimeinfinite$=scheduleInfinity
		#txtweeks$=noOfWeeks

		'Based on drop down value gray out controls
		if #ddstorageformat.itemcount>0  then
			if #ddstorageformat.itemlabel$(#ddstorageformat.selidx)="N/A" then 
				#chkUploadViaFtp.disabled=1
				#lblfileformat.fg = UNSELECTED_TXT_COLOR
				#lblfileformat.selfg = UNSELECTED_TXT_COLOR
				#chkUploadViaFtp.fg = UNSELECTED_TXT_COLOR
				#chkUploadViaFtp.selfg = UNSELECTED_TXT_COLOR
				#ddstorageformat.fg = UNSELECTED_TXT_COLOR
				#ddstorageformat.selfg = UNSELECTED_TXT_COLOR
				#ddstorageformat.bg = UNSELECTED_BG_COLOR
				#ddstorageformat.brdr = UNSELECTED_BG_COLOR
				#ddstorageformat.selbrdr = UNSELECTED_BG_COLOR
				#ddstorageformat.selbg = UNSELECTED_BG_COLOR
				setfocus("chklocalstorage")		
			end if
		end if
		
		'Based on drop down value and SD card is inserted value ,gray out controls 
		if #ddstorageformat1.itemcount>0 then
			if  #ddstorageformat1.itemlabel$(#ddstorageformat1.selidx)="N/A" or sdCard = 0 then 
				#chkLocalStorage.disabled=1
				#lblFileFormat1.fg = UNSELECTED_TXT_COLOR
				#lblFileFormat1.selfg = UNSELECTED_TXT_COLOR
				#chkLocalStorage.fg = UNSELECTED_TXT_COLOR
				#chkLocalStorage.selfg = UNSELECTED_TXT_COLOR
				#ddstorageformat1.fg = UNSELECTED_TXT_COLOR
				#ddstorageformat1.selfg = UNSELECTED_TXT_COLOR
				#ddstorageformat1.bg = UNSELECTED_BG_COLOR
				#ddstorageformat1.selbrdr = UNSELECTED_BG_COLOR
				#ddstorageformat1.brdr = UNSELECTED_BG_COLOR
				#ddstorageformat1.selbg = UNSELECTED_BG_COLOR
				#lblStorageFormat.fg = UNSELECTED_TXT_COLOR
				#lblStorageFormat.selfg = UNSELECTED_TXT_COLOR
				#optlocalStorage.fg=UNSELECTED_TXT_COLOR
				#optlocalStorage.selfg=UNSELECTED_TXT_COLOR
				setfocus("optrepeatschedule")		
			end if
		end if
		
		call btnFrameOK_Click()
	endif	
	
End Sub

/***********************************************************
'** setValuesToDropDown
 *	Description: 
 *		To set the schedule details to the dropdown boxes of schedule frame
 *		
 *	Params:
 *		dims recordSchedule$: String - detail of the selected schedule
 *	Created by:  On 2009-09-01 17:04:10
 ***********************************************************/
 sub setValuesToDropDown(dims recordSchedule$()) 	
 	dimi i,idx, tempVal, totalMin, totTohr,  diffMin
 	dims TempString$,tempVal$,diffTim$
 	dims ctrlName$,ctrlName1$,ctrlName2$,ctrlName3$
 	dimf diffTim
 	For idx=1 to MAX_DAYS
 		TempString$ = recordSchedule$(idx-1)
 		i=strtoint(tempString$(1))
 		i=i+1
 		if TempString$(2)=1 or TempString$(2)=0 then
 			ctrlName$ = "chkschedule"+i
			#{ctrlName$}.checked=strtoint(TempString$(2))
			ctrlName$ = "drpday"+i
			tempVal = strtoint(TempString$(4))-1
			#{ctrlName$}$=tempVal
			ctrlName$ = "drpFromHrs"+i
			#{ctrlName$}$=TempString$(5)+TempString$(6)
			ctrlName$ = "drpFromMin"+i
			#{ctrlName$}$=TempString$(7)+TempString$(8)
			ctrlName$ = "drpToHrs"+i
			#{ctrlName$}$=TempString$(11)+TempString$(12)
			ctrlName1$ = "drpFromHrs"+i
			ctrlName$ = "drpToHrs"+i
			totTohr = strToint(#{ctrlName1$}$)+strToint(#{ctrlName$}$)
			if totTohr<10 then
				#{ctrlName$}$="0"+totTohr
			else
				#{ctrlName$}$=totTohr
			endif
			ctrlName$ = "drpToMin"+i
			#{ctrlName$}$=TempString$(13)+TempString$(14) 
			ctrlName$ = "drpToMin"+i
			ctrlName1$ = "drpFromMin"+i	
			totalMin =strtoint(#{ctrlName1$}$)+strtoint(#{ctrlName$}$)
			if totalMin>=60 then
				diffTim=totalMin/60
			    diffTim$=format$("2.2",diffTim)
			    split(tempVal$,diffTim$, ".")
			    ctrlName$ = "drpToHrs"+i
				totTohr = strToint(#{ctrlName$}$)+strToint(tempVal$(0))
				if totTohr<10 then
					#{ctrlName$}$="0"+totTohr
				else
					#{ctrlName$}$=totTohr
				endif
				ctrlName$ = "drpToMin"+i
				diffMin=totalMin-60
				if diffMin<10 then
					#{ctrlName$}$="0"+diffMin
				else
					#{ctrlName$}$=diffMin
				endif
			else
				if totalMin<10 then
					#{ctrlName$}$="0"+totalMin
				else
					#{ctrlName$}$=totalMin
				endif
			Endif
		    ctrlName$="drpFromHrs"+i
		    ctrlName1$="drpFromMin"+i
		    ctrlName2$="drpToHrs"+i
		    ctrlName3$="drpToMin"+i
		    if strtoint(#{ctrlName$}$)="00" and strtoint(#{ctrlName1$}$)="00" and strtoint(#{ctrlName2$}$)="23" and strtoint(#{ctrlName3$}$)="59" and strtoint(TempString$(15))=5 and strtoint(TempString$(16))=9 then
		    	#{ctrlName2$}$="00"
		    	#{ctrlName3$}$="00"
			endif
 		endif
 	Next
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
'** btnSave_Click
 *	Description: To the save the changed values for the
				 controls and the scheduler
 *
 *		
 *	Methods: SavePage- To the save the changed values for the
				       controls and the scheduler
 *	Created by:Jacques Franklin.K On 2009-03-10 09:56:11
 *	History: 
 ***********************************************************/
Sub btnSave_Click
	if canReload = 1 then
		savePage()		
	end if
End Sub

/***********************************************************
'** savePage
 *	Description: 
 *		Validate  and Save schedule values to camera

 *	Created by:Franklin Jacques.K On 2009-05-28 16:34:07
 ***********************************************************/
Sub savePage()
	msgbox("storagesetting.bas")
	dimi ret
	dimi idx,i
	dims tempstr$,ctrlName$
    
    'validate number weeks value
	dimi noOfWeeks
	noOfWeeks = strToint(trim$(#txtweeks))	
	if (noOfWeeks<1 or noOfWeeks>52) and #optrepeatschedule=1 then
		~mousemoveflag=1
		msgbox("Number of weeks should be between 1 to 52")
		setfocus("txtweeks")
		~mousemoveflag=0
		return
	endif
	
	'Assign zeros if recordSchedule array value is empty
	For idx=0 to 6
		if recordSchedule$(idx)="" then
			recordSchedule$(idx)="0"+idx+"007000000000000"
			pprint "recordSchedule$("+idx+")"+recordSchedule$(idx)
		endif
	Next
	
	'Build schedule string
	stringSchedule$= "schedule="+recordSchedule$(0)+"&schedule="+recordSchedule$(1)+"&schedule="+recordSchedule$(2)+"&schedule="+recordSchedule$(3)_
		+"&schedule="+recordSchedule$(4)+"&schedule="+recordSchedule$(5)+"&schedule="+recordSchedule$(6)
		
	'Reset all schedule drop downs
	call ClearDropDownValues()	
	
	'Save values to camera
	ret=setStorageSetting(#ChkUploadViaFtp,#ddstorageformat.selidx, _
							  #ChkLocalStorage,#ddstorageformat1.selidx,strtoint(#optlocalstorage$), _
							  #optRepeatSchedule,_
							  #txtweeks,_
							  #optruntimeinfinite,_
							  stringSchedule$)
	
	if removeSHDLFlag = 0 then
		if ret > 0 then 
			saveSuccess = 1
		else
			saveSuccess = 0
		endif
	endif	
	
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
		#lblsuccessmessage.style = 64
		#lblsuccessmessage.x = tempX
		~mousemoveflag=1
		#lblsuccessmessage$ = "Storage setting saved to camera "+~title$		'TR-35	
		isMessageDisplayed = 1												'TR-35	
		~mousemoveflag=0
		call setInitialScheduler()
		#lblsuccessmessage.paint(1)		
	else 
		~mousemoveflag=1
		if ~keywordDetFlag = 1 then
			msgbox("Storage setting for \n"+~errorKeywords$+"\nfailed for the camera "+~title$)
		else 
			msgbox("Storage setting failed for the camera "+~title$)
		endif
		~mousemoveflag=0
		call setInitialScheduler()
	endif
	~changeFlag = 0	
	canReload = 1	
	call Form_complete()
End Sub


/***********************************************************
'** ClearDropDownValues
 *	Description: 
 *		To clear the values of the dropdown boxes and set the 
        default values for it

 *	Created by: Vimala On 2009-09-02 16:12:55
 ***********************************************************/
sub ClearDropDownValues()
	dims ctrlName1$
	dims ctrlName2$
	dims ctrlName3$
	dims ctrlName4$
	dims ctrlName5$
	dims ctrlName6$
	dimi i 
	For i=1 to 7
		ctrlName1$ = "drpFromHrs"+i
		ctrlName2$ = "drpFromMin"+i
		ctrlName3$ = "drpToHrs"+i
		ctrlName4$ = "drpToMin"+i
		ctrlName5$ = "drpday"+i
		ctrlName6$ = "chkSchedule"+i
		#{ctrlName1$}$="00"
		#{ctrlName2$}$="00"
		#{ctrlName3$}$="00"
		#{ctrlName4$}$="00"
		#{ctrlName5$}$="sunday"
		#{ctrlName6$}.checked=0
	Next
End Sub


/***********************************************************
'** optionRepeatSchedule_Click
 *	Description: 
 *		 select the option button-RunTimeInfinite
 *		
 *	Created by:Franklin Jacques.K  On 2009-03-10 09:56:13
 *	History: 
 ***********************************************************/
Sub optionRepeatSchedule_Click
	#optionRunTimeInfinite.checked=0
End Sub



/***********************************************************
'** optionRunTimeInfinite_Click
 *	Description: 
 *		select the option button-RepeatSchedule
 *		
 *	Created by:Franklin Jacques  On 2009-03-10 09:56:14
 *	History: 
 ***********************************************************/
Sub optionRunTimeInfinite_Click
	#optionRepeatSchedule.checked=0
End Sub


/***********************************************************
'** btnCancel_Click
 *	Description: To load the default values set initially for 
                 the controls and scheduler when cancelled
                 
 *	Created by:Jacques Franklin  On 2009-03-19 12:16:26
 ***********************************************************/
Sub btnCancel_Click
	if canReload = 1 then
		call setInitialScheduler()
		~changeFlag = 0	
	end if
End Sub

/***********************************************************
'** drawScheduler
 *	Description: 
 *		Draw the scheduler window with selcted/unselected schedule.
 *
 *	Created by: Partha Sarathi.K On 2009-03-20 14:25:43
 *  Modified By Franklin Jacques On 2009-08-31 16:54:00
 ***********************************************************/
sub drawScheduler()
	dimi selColor
	dimi txtY
	dimi yPos, xPos, i, maxDur, hourW, durHourW, timeVal
	dimi j, lineYPos
	
	xpos = 	scheduleX
	'Draw the header
	FILLRECT(xpos, scheduleY, SCHEDULE_W, SCH_TIT_H, SCH_TIT_BG)
	
	'Display the title
	txtY = 	SCH_TIT_H - gettextheight("Schedule", SCH_TIT_STYLE, SCH_TIT_FONT)
	textout(xPos+SCH_TIT_X_GAP, scheduleY+txtY-2, "Schedule", SCH_TIT_STYLE, SCH_TIT_FG, SCH_TIT_FONT)
	
	yPos = scheduleY + SCH_TIT_H
	
	'Draw the schdule BG
	ROUNDRECT(xpos, yPos, SCHEDULE_W, SCHEDULE_H, SCH_BDR_COL, SCH_BG_COL, 0, 0)
	
	xPos  = scheduleX
	yPos += HOUR_DISPLAY_Y_GAP
	
	maxDur   = TOT_HOUR/DURATION_HOUR
	hourW    = (60/MAX_MIN)*(SCH_IDX_GAP+SCH_IDX_W)
	durHourW = DURATION_HOUR*hourW
	
	'Display the hour 
	for i=0 to maxDur
		timeVal = i*DURATION_HOUR
		textout((xPos+DAY_DISPLAY_W-DAY_X_GAP)-DAY_X_GAP, yPos, format$("2.2", timeVal), HOUR_TXT_STYLE, HOUR_TXT_FG, HOUR_TXT_FONT)
		xPos += durHourW
	next
	
	yPos     += 2*SCH_IDX_Y_GAP
	lineYPos = yPos - (SCH_IDX_LINE_H - SCH_IDX_H)-1
		
	for i=0 to MAX_DAYS-1
		xPos = scheduleX '+ DAY_DISPLAY_W
			
		'Display the day
		textout(xPos+DAY_X_GAP, yPos-DAY_HEIGHT, day$(i), DAY_TXT_STYLE, DAY_TXT_FG, DAY_TXT_FONT, DAY_DISPLAY_W-DAY_X_GAP)
		
		xPos += DAY_DISPLAY_W

		for j=0 to totSchedule-1
			'Draw the line between each one hour
			if j%(maxDur) = 0 and j <> 0 then
				DRAWLINE(xPos+1, lineYPos, xPos+1, lineYPos+SCH_IDX_LINE_H, 1, SCH_IDX_BG)
			endif
			
			iff j <> 0 then xPos += SCH_IDX_W
			
			if scheduleIdx(i,j) = 0 then
				'Draw the unselected schedule
				FILLRECT(xPos, yPos, SCH_IDX_W, SCH_IDX_H, SCH_IDX_BG)
			elseif scheduleIdx(i,j) = 1 then
				SelectedSchedule(xPos, yPos, CHK_BLUE, 1, j)	
			elseif scheduleIdx(i,j) = 2 then	
				SelectedSchedule(xPos, yPos, CHK_GREEN, 2, j)	
			elseif scheduleIdx(i,j) = 3 then	
				SelectedSchedule(xPos, yPos, CHK_PURPLE, 3, j)	
			elseif scheduleIdx(i,j) = 4 then
				SelectedSchedule(xPos, yPos, CHK_RED, 4, j)	
			elseif scheduleIdx(i,j) = 5 then
				SelectedSchedule(xPos, yPos, CHK_AQUA, 5, j)
			elseif scheduleIdx(i,j) = 6 then
				SelectedSchedule(xPos, yPos, CHK_THICKGREEN, 6, j)
			elseif scheduleIdx(i,j) = 7 then
				SelectedSchedule(xPos, yPos, CHK_ORANGE, 7, j)
			elseif scheduleIdx(i,j) = -1 then
				FILLRECT(xPos, yPos, SCH_IDX_W, SCH_IDX_H, DISABLE_COLOR,,,ALPHA_LEVEL)	
			endif
			
			xPos += SCH_IDX_GAP	
			
		next
				
		'Draw the line at end of day
		DRAWLINE(xPos+1, lineYPos, xPos+1, lineYPos+SCH_IDX_LINE_H, 1, SCH_IDX_BG)
				
		yPos += SCH_IDX_H + SCH_IDX_Y_GAP 
		lineYPos = yPos - (SCH_IDX_LINE_H - SCH_IDX_H)-1
	next
		
			
End Sub


/***********************************************************
'** SelectedSchedule
 *	Description: 
 *		To set the color, x position, Y position and Alpha level
        to highlight the selected schedule with the subsequent color
        
 *	Params:
'*		dimi xPos: Numeric - X Position of the selected schedule
'*		dimi yPos: Numeric - Y Position of the selected schedule
'*		dimi curColor: Numeric - color of the selected schedule
 *		dimi index: Numeric - current row of the scheduler

 *	Created by:  On 2009-09-08 10:58:48
 *	History: 
 ***********************************************************/
sub SelectedSchedule(dimi xPos, dimi yPos, dimi curColor, dimi index, dimi j)
	index=index-1
	dimi frmTime
	dimi toTime
	dimi  selFlag=0
	frmTime=strtoint(frmMin$(index))
	toTime=strtoint(toMin$(index))
	FILLRECT(xPos, yPos, SCH_IDX_W, SCH_IDX_H, curColor,,,ALPHA_LEVEL)
End Sub


/***********************************************************
'** fillScheduleData
 *	Description: 
 *		Fill the selected/unselected scheduler regions.
 *		
 *	Params:
'*		dimi startIdx: Numeric - start index of the selected rectangle
 *		dimi endIdx: Numeric - end index of the selected rectangle
 *	Created by: Partha Sarathi.K On 2009-03-20 18:38:14
 ***********************************************************/
sub fillScheduleData(dimi startIdx, dimi endIdx, dimi srcIdx)
	
	dimi fillData, i
	dimi scheduleCount,j
	
	if scheduleIdx(selIdxRow, srcIdx) = 0 then 	'Is unselceted,change to selected
		fillData = 1
	else
		fillData = 0								'set unselected
	endif
			
	for i = startIdx to endIdx
		scheduleIdx(selIdxRow, i) = fillData
	next
	
	scheduleCount = 0
	
	for i=0 to MAX_DAYS-1
		
		for j=0 to totSchedule-1
			if scheduleIdx(i,j) = 1 then
				
				scheduleCount++
				
				if scheduleCount > MAX_SCHEDULE then			'is max schedule reach
					fillData = 0
					
					'If already selected, set selected, otherwise reselected
					if endIdx < totSchedule-1 then
						iff  scheduleIdx(selIdxRow, endIdx+1) = 1 then fillData = 1
					endif
					
					for i = startIdx to endIdx
						scheduleIdx(selIdxRow, i) = fillData
					next
					
					'Display the err msg
					selIdxRow = -1
					msgbox("You have already created maximum number of schedules")
					return
				endif
								
				while(scheduleIdx(i,j) = 1) 
					j++
					iff j >= totSchedule then break
				wend
				
			endif

		next
		
	next
			
End Sub

/***********************************************************
'** ToolTip_MouseOver
 *	Description: procedure to display the tool tip(selected schedule's From & To time) 
				 during the mouse-over on the selected schedule.

 *	Created by: Jacques Franklin On 2009-04-25 15:16:04
 ***********************************************************/
sub ToolTip_MouseOver(dimi x,dimi y)
	Dims txtcnt$,st$,st1$,stpopup$,endtPopup$,tempString$
	dimi endIdx,i,j,ypos,selectedrow1,schDFlag, curId 
	schDFlag=0
	curId=-1
	if mouseClickflag=1 then
	for i=0 to 6 
		if x >= scheduleX+DAY_DISPLAY_W  and x <= (scheduleX+DAY_DISPLAY_W +((SCHEDULE_W)-DAY_DISPLAY_W)) and y >= scheduleY+((i+2)*SCH_IDX_H)+((i+2)*SCH_IDX_Y_GAP) and y <= scheduleY+SCH_IDX_H+((i+2)*10*~factorY)+((i+2)*20*~factorY) then
			schDFlag=1
			break
		endif
	Next	 
	
	if schDFlag=1 then
		schDFlag=0
			iff x < scheduleX+DAY_DISPLAY_W  then x = scheduleX+DAY_DISPLAY_W 
			paint(1)
			endIdx = abs(x-(scheduleX+DAY_DISPLAY_W))/DURATION_HOUR 		'Get end index
			yPos = scheduleY + SCH_TIT_H + 2*SCH_IDX_Y_GAP + HOUR_DISPLAY_Y_GAP
			
			for i=0 to MAX_DAYS-1
				'Select the clicked row
				if y >= yPos and y <= yPos+SCH_IDX_H and x >= scheduleX+DAY_DISPLAY_W  and x <= scheduleX+DAY_DISPLAY_W +(SCHEDULE_W-DAY_DISPLAY_W) then				
					selectedrow1 = i								'specify the selected row
					break
				else
					selectedrow1=-1 
				endif
				
				yPos += SCH_IDX_H + SCH_IDX_Y_GAP
							
			next
			if endidx<=95 and selectedrow1<>-1 then
				curId = scheduleIdx(selectedrow1,endIdx)
				curId=curId-1
			endif
			iff curId<0 then return
				if selectedrow1<>-1 and endIdx<=95 then
						if scheduleIdx(selectedrow1,endIdx)<>0 and endIdx<=95 then
							if endIdx>0 then
								for i=endIdx to 0 step -1
									if scheduleIdx(selectedrow1,i)= 0 then
										break
									endif
								Next
							endif
							if endIdx<95 then
								for j=endIdx to 95
									if scheduleIdx(selectedrow1,j) = 0 then
										break
									endif
								Next
							endif
					
						call form_paint()
						Dimi absX
						absX=(i*DURATION_HOUR)+(scheduleX+DAY_DISPLAY_W)
						paint(prvx,prvy,(TOOLTIP_WIDTH)/2,TOOLTIP_HEIGHT)
						if endIdx>=TOOLTIP_MAXINDEX then
							getimage(prvScreen$,x-(TOOLTIP_WIDTH)/2,y,(TOOLTIP_WIDTH)/2,TOOLTIP_HEIGHT)
						else
							getimage(prvScreen$,x+10,y,(TOOLTIP_WIDTH)/2,TOOLTIP_HEIGHT)
					    endif
						putimage(prvScreen$,prvX,prvY,5,1)
						if curId>=0 then
							//tool tip-time (From:To) 
							txtcnt$ = frmHrs$(curId)+":"+frmMin$(curId)+" : "+toHrs$(curId)+":"+toMin$(curId)
						endif
						if endIdx>=TOOLTIP_MAXINDEX then
							DRAWRECT(x-(TOOLTIP_WIDTH)/2,y,(TOOLTIP_WIDTH)/2,TOOLTIP_HEIGHT,1,1,DISPLAY_REGION_BG,DISPLAY_REGION_BG)
							textout(x-(TOOLTIP_WIDTH)/2,y,txtcnt$,DAY_TXT_STYLE, TOOLTIP_COLOR, DAY_TXT_FONT)
							paint(x-(TOOLTIP_WIDTH)/2,y,(TOOLTIP_WIDTH)/2,TOOLTIP_HEIGHT)
						else
							DRAWRECT(x+10,y,(TOOLTIP_WIDTH)/2,TOOLTIP_HEIGHT,1,1,DISPLAY_REGION_BG,DISPLAY_REGION_BG)
							textout(x+10,y,txtcnt$,DAY_TXT_STYLE, TOOLTIP_COLOR, DAY_TXT_FONT)
							paint(x+10,y,(TOOLTIP_WIDTH)/2,TOOLTIP_HEIGHT)
						endif
						if endIdx>=TOOLTIP_MAXINDEX then
							prvX=x-(TOOLTIP_WIDTH)/2
						else
							prvX=x+10 
						endif
						prvY=y
					else
						prvX=-100
						prvY=-100
						call form_paint
						paint(prvX,prvY,(TOOLTIP_WIDTH)/2,TOOLTIP_HEIGHT+1)
					endif
			   endif
		else
			prvX=-100
			prvY=-100
			call form_paint
			paint(prvX,prvY,(TOOLTIP_WIDTH)/2,TOOLTIP_HEIGHT+1)
			
		endif
	 mousehandled(2)
	else
		call form_paint()
	endif
End Sub



/***********************************************************
'** Form_MouseMove
 *	Description: 
 *		Select the schduler for selected/unselected.
 *		
 *	Params:
'*		x: Numeric - X Position
 *		y : Numeric - Y Position
 *	Created by: Partha Sarathi.K On 2009-03-20 17:08:51
 *	Modified By Jacques Franklin On 2009-04-22 16:48:15
 ***********************************************************/
Sub Form_MouseMove( x, y )
   if ~mousemoveflag=0 then
		iff #frSchedule.hidden=1 and paintFlag=1 then call ToolTip_MouseOver(x,y)		
   endif 
   mousehandled(0)		
End Sub

/***********************************************************
'** displayCurSchedule
 *	Description: 
 *		Draw the current selected/unselected schduler regions
 *		
 *	Params:
'*		dimi startIdx: Numeric - start index of the selected schedule
'*		dimi endIdx: Numeric - end index of the selected schedule
 *	Created by: Partha Sarathi.K On 2009-03-20 17:36:06
 *	History: 
 ***********************************************************/
/*sub displayCurSchedule(dimi startIdx, dimi endIdx, dimi isBGCol)
	
	dimi xPos, yPos
	dimi startX, i, bgCol
	
	'Find the X pos for draw the scheduler
	xPos   = scheduleX+DAY_DISPLAY_W+(startIdx*(SCH_IDX_W+SCH_IDX_GAP))
	'Find the Y pos for draw the scheduler
	yPos   = scheduleY + SCH_TIT_H + 2*SCH_IDX_Y_GAP + HOUR_DISPLAY_Y_GAP + selIdxRow*(SCH_IDX_H+SCH_IDX_Y_GAP)
	'Draw the scheduler regions
	for i = startIdx to endIdx 
		if isBGCol = 1 then
			bgCol = SCH_IDX_CUR_SEL_BG
		else
			if selIdxRow >=0 and selIdxRow < MAX_SCHEDULE then
				if scheduleIdx(selIdxRow, i) = 1 then
					bgCol = SCH_IDX_SEL_BG
				else
					bgCol = SCH_IDX_BG
				endif
			endif
		endif
					
		FILLRECT(xPos, yPos, SCH_IDX_W, SCH_IDX_H, bgCol)
		xPos += SCH_IDX_W + SCH_IDX_GAP
	next
	
	paint(1)
End Sub*/

/***********************************************************
'** deCalculation
 *	Description: 
          Procedure to decalculate the scheduled timings from the 
          data rerieved using the array variable (recordSchedule$)
 *		
 *	Created by: Franklin  On 2009-03-10 09:56:07
 *	History: 
 ***********************************************************/
sub deCalculation()
	dimf floatValue
	dims Val$, Val1$
	Dims totMin$,str$,diffMin$,scheduleStr$,ctrlName$,tempMin$
	Dimi starTime, totTime,diffMin,diffTime,totDiffTime,scheduleTime,day,recordSchedule,totStartTime,totDiffMin,tempValue	
	Dimi chkidx, cntNo, Index, selFlag, count, endHrs, endMin, endTime, startHrs, startMin
	Dims startTime$,endTime$
	for recordSchedule = 0 to MAX_DAYS-1
		   ClearSchedule(recordSchedule+1)                  
		   scheduleStr$=recordSchedule$(recordSchedule)
		   Index = strtoint(scheduleStr$(1))
		   storeToolTipInfo(Index,scheduleStr$)
		for day=1 to MAX_DAYS
			selFlag=0
		
			cntNo=0 'set back to zero again
			if strtoint(scheduleStr$(4)) = day then
			  if strtoint(scheduleStr$(2))=1 or strtoint(scheduleStr$(2))=0 then
				if (scheduleStr$(2))=0 then
					For chkidx=5 to 16 
						if scheduleStr$(chkidx)="0" then
							cntNo++
						endif
					Next
				endif
				
				iff cntNo=12 then continue
				
				startHrs=strtoint(frmHrs$(index))
				startMin=strtoint(frmMin$(index))
				endHrs=strtoint(toHrs$(index))
				endMin=strtoint(toMin$(index))
				if (startHrs+startMin+endHrs+endMin)=0 then
					starTime = 0
					endTime = 95
				else			
					iff startMin>0 then startMin-=1			
					starTime = (startHrs*60 + (startMin))/MAX_MIN
					endTime = (endHrs*60 + (endMin-1))/MAX_MIN
				endif		
						
				for scheduleTime = starTime to endTime
					if scheduleTime < totSchedule then 
					  if recordSchedule=0 then
						iff #chkschedule1=1 then scheduleIdx(day-1,scheduleTime)=1
						iff #chkschedule1=0 then scheduleIdx(day-1,scheduleTime)=-1
					  elseif recordSchedule=1 then
						iff #chkschedule2=1 then scheduleIdx(day-1,scheduleTime)=2
						iff #chkschedule2=0 then scheduleIdx(day-1,scheduleTime)=-1
					  elseif recordSchedule=2 then
						iff #chkschedule3=1 then scheduleIdx(day-1,scheduleTime)=3
						iff #chkschedule3=0 then scheduleIdx(day-1,scheduleTime)=-1
					  elseif recordSchedule=3 then
						iff #chkschedule4=1 then scheduleIdx(day-1,scheduleTime)=4
						iff #chkschedule4=0 then scheduleIdx(day-1,scheduleTime)=-1
					  elseif recordSchedule=4 then
						iff #chkschedule5=1 then scheduleIdx(day-1,scheduleTime)=5
						iff #chkschedule5=0 then scheduleIdx(day-1,scheduleTime)=-1
					  elseif recordSchedule=5 then
						iff #chkschedule6=1 then scheduleIdx(day-1,scheduleTime)=6
						iff #chkschedule6=0 then scheduleIdx(day-1,scheduleTime)=-1
					  elseif recordSchedule=6 then
						iff #chkschedule7=1 then scheduleIdx(day-1,scheduleTime)=7
						iff #chkschedule7=0 then scheduleIdx(day-1,scheduleTime)=-1
					  endif
					endif
					
				Next
			endif
		Endif
			
    Next
		
Next	
	
	
End Sub

/***********************************************************
'*  storeToolTipInfo
 *	Description: 
 *		To store the tooltip information for the selected
        schedule
 *		
 *	Params:
'*		Index: Numeric - Index of the selected schedule
 *		scheduleStr$: String - detail of the selected schedule
 *	Created by: Franklin Jacques.K On 2009-09-03 11:32:26
 *	History: 
 ***********************************************************/
sub storeToolTipInfo(dimi Index,dims scheduleStr$)
   Dimi tempNo
   Dims ctrlNameToHrs$
   Dims ctrlNameToMin$
   frmHrs$(Index)=scheduleStr$(5)+scheduleStr$(6)
   frmMin$(Index)=scheduleStr$(7)+scheduleStr$(8)
   ctrlNameToHrs$="drpToHrs"+(Index+1)
   ctrlNameToMin$="drpToMin"+(Index+1)

   if strtoint(#{ctrlNameToHrs$})<10 then 
	   toHrs$(Index)="0"+#{ctrlNameToHrs$}
   else
	   toHrs$(Index)=#{ctrlNameToHrs$}
   endif
   
   if strtoint(#{ctrlNameToMin$})<10 then 
	   toMin$(Index)="0"+#{ctrlNameToMin$}
   else
   	   toMin$(Index)=#{ctrlNameToMin$}
   endif
   
   
End Sub


/***********************************************************
'** ClearSchedule
 *	Description: 
 *		To clear all the selected schedules from the scheduler
 *		
 *	Params:
 *	Created by: Franklin Jacques.K On 2009-09-01 12:40:37
 *	History: 
 ***********************************************************/
sub ClearSchedule(dimi curVal)
	dimi row, col
		
	For row = 0 To MAX_DAYS-1
		For col=0 to totSchedule-1
			if scheduleIdx(row, col) = curVal then
				scheduleIdx(row, col) = 0
			Endif
		Next
	Next
	 
End Sub

/******************************************************************
'** btnRemove_Click
 *	Description: To remove all the schedules of the storage settings 

 *	Created by:Jacques Franklin  On 2009-03-24 15:56:24
 *****************************************************************/
Sub btnRemove_Click
	iff canReload = 0 then return
	paintFlag=0
	msgbox("Do you want to remove all selected schedules",3) 
	mousehandled(2)
	keyhandled(2)
	if confirm()=1 then	
		paintFlag=1
		Dimi row, col, scheduleIndex
		dimi retVal
		
		For row = 0 To MAX_DAYS-1               
			For col=0 to totSchedule-1
				scheduleIdx(row, col) = 0
			Next
		Next
		
		For scheduleIndex=0 to MAX_SCHEDULE-1								'To set the default values for the scheduler
			schedule$(scheduleIndex)="0"+scheduleIndex+"007000000000000"
		next
		
		removeSHDLFlag=1
		
		For scheduleIndex=0 to 6			
			if recordschedule$(scheduleIndex)<>"0"+scheduleIndex+"007000000000000" then
				httpFlag=1
				break
			endif
		Next
		
		if httpFlag=1 then
			httpFlag=0
		endif
		
		dimi idx
		For idx=0 to 6
			recordSchedule$(idx)="0"+idx+"007000000000000"
		Next
		
		removeSHDLFlag=0
		call ClearDropDownValues()	
		setDeleteSchedule$()
	else
		paintFlag=1
	endif
	
End Sub


/***********************************************************
'** optrepeatschedule_Click
 *	Description:To set the option button value 

 *	Created by:Franklin  On 2009-07-16 12:47:57
 ***********************************************************/
Sub optrepeatschedule_Click	
	#optruntimeinfinite.checked=0
	#txtweeks.disabled=0
End Sub


/***********************************************************
'** optruntimeinfinite_Click
 *	Description:To set the option button value  

 *	Created by:Franklin  On 2009-07-16 12:47:59
 ***********************************************************/
Sub optruntimeinfinite_Click	
	#optrepeatschedule.checked=0
	#txtweeks.disabled=1
	#txtweeks$ = "0"
End Sub


/***********************************************************
'** Form_KeyPress
 *	Description: 
 *		To check the keypress event for scroll & textbox validation
 *		
 *	Params:
'*		Key: Numeric - To get the key value during keypress
 *		FromMouse : Numeric - mouse value
 *	Created by:  On 2009-05-16 03:32:22
 *	History: 
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )		
	scroll_keypressed(key)
	
	dims keypressed$
	keypressed$ = chr$(getkey())
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)
	setSubMenuFocus(Key,7)	
End Sub

' validation for all the text box ctrl while keypress event
Sub txtweeks_focus
	rule=2
End Sub

Sub txtweeks_blur
	rule=0
End Sub

' set showcursor property for all the controls
Sub chkUploadViaFtp_Blur
	showcursor(3)
End Sub

Sub chkLocalStorage_Focus
	iff #chkLocalStorage.disabled = 0 then showcursor(1)
End Sub

Sub chkLocalStorage_Blur
	showcursor(3)
End Sub

Sub optlocalStorage_Blur
	showcursor(3)
End Sub

Sub optlocalStorage_Focus
	if #optlocalStorage.disabled = 0 then  
		showcursor(1)
	end if
End Sub

Sub optrepeatschedule_Focus
	showcursor(1)
End Sub

Sub optrepeatschedule_Blur
	showcursor(3)
End Sub

Sub optruntimeinfinite_Focus
	showcursor(1)
End Sub



Sub optruntimeinfinite_Blur
	showcursor(3)
End Sub

Sub chkUploadViaFtp_Focus
	iff #chkUploadViaFtp.disabled = 0 then showcursor(1)
End Sub

/***********************************************************
'** chkUploadViaFtp_Click
 *	Description: 
 *		 To check the checked property of chkUploadViaFtp(check box ctrl)
		 and set the disable property for ddstorageformat(drop down ctrl)

 *	Created by:Franklin  On 2009-07-16 11:15:51
 ***********************************************************/
Sub chkUploadViaFtp_Click
	
	if #chkUploadViaFtp.checked=0 then
		#ddstorageformat.disabled=1
	else
		#ddstorageformat.disabled=0
	endif 
	
End Sub

/***********************************************************
'** chkLocalStorage_Click
 *	Description: 
 *		To check the checked property of chkLocalStorage(check box ctrl)
		 and set the disable property for ddstorageformat(drop down ctrl) & 
		 optlocalStorage (radio button) control
 *		
 *	Params:
 *	Created by:Franklin  On 2009-07-16 11:15:54
 *	History: 
 ***********************************************************/
Sub chkLocalStorage_Click
	
	if #chkLocalStorage.checked=0 then
		#ddstorageformat1.disabled=1
		#optlocalStorage[0].disabled=1		
	else
		#ddstorageformat1.disabled=0
		#optlocalStorage[0].disabled=0
	endif 
	
	#optlocalStorage[1].disabled=1
	#optlocalStorage[2].disabled=1
End Sub


/***********************************************************
'** btnAdd_Click
 *	Description: Displays modal window to select schedule details
 *				 Hide save,cancel and remove all button.
 
 *	Created by: S.Vimala On 2009-08-31 14:14:53
 *	History: 
 ***********************************************************/
Sub btnAdd_Click									  'TR-01 
	iff canReload = 0 then return
	#frSchedule.hidden=0
	#frschedule.x = #imgmainbg.x + 74
	#frschedule.y = #optrepeatschedule.y + 50
	#frschedule.bg = 6439
	#btnadd.hidden = 1
	#btnsave.hidden = 1
	#btncancel.hidden = 1
	#btnremove.hidden = 1
	call disableScheduleDrp()
End Sub

/***********************************************************
'** frSchedule_Cancel
 *	Description: Hide modal window to select schedule details
 *				 display save,cancel and remove all button.
 
 *	Created by: S.Vimala On 2009-08-31 18:04:46
 *	History: 
 ***********************************************************/
sub frSchedule_Cancel 				'TR-01	
	#frSchedule.hidden=1
	#btnadd.hidden = 0
	#btnsave.hidden = 0
	#btncancel.hidden = 0
	#btnremove.hidden = 0
	if #optrepeatschedule = 1 then
		#txtweeks.disabled = 0
	else 
		#txtweeks.disabled = 1
	end if 
	
	setfocus("rosubmenu[8]")	
	setfocus("chkuploadviaftp")
End Sub


/***********************************************************
'** btnFrameCancel_Click
 *	Description: call frSchedule_Cancel function to hide modal window 
 *				 to select schedule details.
 *				 Hide save,cancel and remove all button.
 *
 *	Created by: S.Vimala On 2009-08-31 18:06:17
 *	History: 
 ***********************************************************/
Sub btnFrameCancel_Click 				'TR-01	
	call setValuesToDropDown(recordSchedule$)   
	call frSchedule_Cancel
End Sub

/***********************************************************
'** enableDrpCtrls
 *	Description: Call this function enable/disable drop down control based on 
 *				 check box checked value		
 *		
 *	Params:
'*		dims ctrlName$: String - Check box control name
 *		dimi ctrlIndex: Numeric - Drop down control name
 *	Created by: S.Vimala On 2009-08-31 18:07:21
 *	History: 
 ***********************************************************/
Sub enableDrpCtrls(dims ctrlName$,dimi ctrlIndex)				'TR-01	
	dimi j
	dims tmpName$,lblName$
	
	if #{ctrlName$}.checked = 0 then 
		
		for j = 0 to ubound(drpName$)		
			tmpName$ = drpName$(j)+ ctrlIndex	
			#{tmpName$}.disabled = 1						
			#{tmpName$}.bg = DISABLE_COLOR	
			#{tmpName$}.selbg = DISABLE_COLOR
			#{tmpName$}.selfg = 2113
			lblName$ = "lblFrom" + ctrlIndex		
			#{lblName$}.fg = DISABLE_COLOR
			lblName$ = "lblTo" + ctrlIndex		
			#{lblName$}.fg = DISABLE_COLOR	
		next

	else 
				
		for j = 0 to ubound(drpName$)
			tmpName$ = drpName$(j)+ ctrlIndex	
			#{tmpName$}.disabled = 0
			#{tmpName$}.bg = 40180	
			#{tmpName$}.selbg = 40180
			lblName$ = "lblFrom" + ctrlIndex		
			#{lblName$}.fg = 38166
			lblName$ = "lblTo" + ctrlIndex		
			#{lblName$}.fg = 38166
		next
		
	end if
	
End Sub

/***********************************************************
'** btnFrameOK_Click
 *	Description: 
 *		save the schedules selected using the dropdown boxes and set to the 
        camera and the scheduler
 *		
 *	Params:
 *	Created by: Franklin Jacques On 2009-08-31 11:12:58
 *	History: 
 ***********************************************************/
Sub btnFrameOK_Click
	Dimi count = 0, scheduleNo, diffValue, day, i, totalMin, minDiff, hrsDiff
	Dims diffValue$, ctrlName$="chkschedule",ctrlName1$="drpToHrs",ctrlName2$="drpFromHrs"
	dims ctrlName3$="drpday",ctrlName4$="drpFromMin",ctrlName5$="drpToMin"
	dims minDiff$, hrsDiff$
	for i=1 to 7
		minDiff=0
		hrsDiff=0
		ctrlName$="chkschedule"+i
		count++
		scheduleNo = count-1
		ctrlName1$="drpToHrs"+i
		ctrlName2$="drpFromHrs"+i
		diffValue = strtoint(#{ctrlName1$})-strtoint(#{ctrlName2$})
		if diffValue<=9 then 
			diffValue$ = "0"+diffValue
		else
			 diffValue$ = diffValue
		endif
		ctrlName3$="drpday"+i
		day = strtoint(#{ctrlName3$}) + 1
		ctrlName4$="drpFromMin"+i
		ctrlName5$="drpToMin"+i
		
		if  #{ctrlName1$}$="00" and #{ctrlName2$}$="00" and #{ctrlName5$}$="00" and #{ctrlName4$}$="00" and diffValue$="00" and #{ctrlName$}.checked=1 then
			recordSchedule$(i-1) = "0"+scheduleNo+#{ctrlName$}+"0"+day+#{ctrlName2$}$+#{ctrlName4$}$+"00"+"23"+"59"+"59"  
			pprint "recordSchedule$("+(i-1)+")="+recordSchedule$(i-1)
		else
			if strtoint(#{ctrlName4$}$)>strtoint(#{ctrlName5$}$) then
				minDiff=strtoint(#{ctrlName5$}$)+60
				minDiff=minDiff-strtoint(#{ctrlName4$}$)
				hrsDiff=strtoint(#{ctrlName1$}$)-1
				hrsDiff=hrsDiff-strtoint(#{ctrlName2$}$)				
			else
				minDiff=strtoint(#{ctrlName5$}$)-strtoint(#{ctrlName4$}$)
				hrsDiff=strtoint(#{ctrlName1$}$)-strtoint(#{ctrlName2$}$)
			endif
			if minDiff<10 then
				minDiff$="0"+minDiff
			else
				minDiff$=minDiff
			endif
			
			if hrsDiff<10 then
				hrsDiff$="0"+hrsDiff
			else
				hrsDiff$=hrsDiff
			endif			
		
			recordSchedule$(i-1) = "0"+scheduleNo+#{ctrlName$}+"0"+day+#{ctrlName2$}$+#{ctrlName4$}$+"00"+hrsDiff$+minDiff$+"00"  
'			msgbox(recordSchedule$(i-1))                  add by hst
			pprint "recordSchedule$("+(i-1)+")="+recordSchedule$(i-1)
		   
		endif
	Next
	
	call deCalculation()
	call frSchedule_Cancel
End Sub


'Since Control array not working properly
/*Enable/Disable controls based on check box checked value*/
Sub chkSchedule1_Click
	enableDrpCtrls("chkSchedule1",1)
End Sub

Sub chkSchedule2_Click
	enableDrpCtrls("chkSchedule2",2)
End Sub

Sub chkSchedule3_Click
	enableDrpCtrls("chkSchedule3",3)
End Sub

Sub chkSchedule4_Click
	enableDrpCtrls("chkSchedule4",4)
End Sub

Sub chkSchedule5_Click
	enableDrpCtrls("chkSchedule5",5)
End Sub

Sub chkSchedule6_Click
	enableDrpCtrls("chkSchedule6",6)
End Sub

Sub chkSchedule7_Click
	enableDrpCtrls("chkSchedule7",7)
End Sub

/***********************************************************
'** assginDrpVal
 *	Description: Call this function to assign ToHours,ToMins to FromHours,FromMins. 
 *
 *	Params:
'*		dimi ctrlIndex: Numeric - Control index
 *	Created by: S.Vimala On 2009-09-01 15:05:08
 *	History: 
 ***********************************************************/
sub assginDrpVal(dimi ctrlIndex)
	dims tempToHrs$,tempFromHrs$,tempToMin$,tempFromMin$
	tempToHrs$ = "drptohrs"+ctrlIndex
	tempFromHrs$ = "drpfromhrs"+ctrlIndex
	if #{tempToHrs$}$ < #{tempFromHrs$}$ then	
		#{tempToHrs$}$ = #{tempFromHrs$}$
	end if
	
	tempToMin$ = "drptomin"+ctrlIndex
	tempFromMin$ = "drpfrommin"+ctrlIndex
	#{tempToMin$}$ = #{tempFromMin$}$
End Sub


/*Call assginDrpVal function to assign ToHours,ToMins to FromHours,FromMins */
Sub drpFromHrs1_Change
	assginDrpVal(1)
End Sub

Sub drpToHrs1_Change
	assginDrpVal(1)	
End Sub

Sub drptomin1_Change
	if #drptomin1$<#drpfrommin1$ and #drptohrs1$= #drpfromhrs1$ then
		assginDrpVal(1)
	end if
End Sub


Sub drpfrommin1_change
	if #drptohrs1$= #drpfromhrs1$  and #drptomin1$<#drpfrommin1$ then
		#drptomin1$ = #drpfrommin1$ 
	end if 
End Sub

Sub drpFromHrs2_Change
	assginDrpVal(2)
End Sub

Sub drpToHrs2_Change
	assginDrpVal(2)	
End Sub

Sub drptomin2_Change
	if #drptomin2$<#drpfrommin2$ and #drptohrs2$= #drpfromhrs2$ then
		assginDrpVal(2)
	end if
End Sub


Sub drpfrommin2_change
	if #drptohrs2$= #drpfromhrs2$  and #drptomin2$<#drpfrommin2$ then
		#drptomin2$ = #drpfrommin2$ 
	end if 
End Sub


Sub drpFromHrs3_Change
	assginDrpVal(3)
End Sub

Sub drpToHrs3_Change
	assginDrpVal(3)	
End Sub

Sub drptomin3_Change
	if #drptomin3$<#drpfrommin3$ and #drptohrs3$= #drpfromhrs3$ then
		assginDrpVal(3)
	end if
End Sub


Sub drpfrommin3_change
	if #drptohrs3$= #drpfromhrs3$  and #drptomin3$<#drpfrommin3$ then
		#drptomin3$ = #drpfrommin3$ 
	end if 
End Sub

Sub drpFromHrs4_Change
	assginDrpVal(4)
End Sub

Sub drpToHrs4_Change
	assginDrpVal(4)	
End Sub

Sub drptomin4_Change
	if #drptomin4$<#drpfrommin4$ and #drptohrs4$= #drpfromhrs4$ then
		assginDrpVal(4)
	end if
End Sub


Sub drpfrommin4_change
	if #drptohrs4$= #drpfromhrs4$  and #drptomin4$<#drpfrommin4$ then
		#drptomin4$ = #drpfrommin4$ 
	end if 
End Sub

Sub drpFromHrs5_Change
	assginDrpVal(5)
End Sub

Sub drpToHrs5_Change
	assginDrpVal(5)	
End Sub

Sub drptomin5_Change
	if #drptomin5$<#drpfrommin5$ and #drptohrs5$= #drpfromhrs5$ then
		assginDrpVal(5)
	end if
End Sub


Sub drpfrommin5_change
	if #drptohrs5$= #drpfromhrs5$  and #drptomin5$<#drpfrommin5$ then
		#drptomin5$ = #drpfrommin5$ 
	end if 
End Sub

Sub drpFromHrs6_Change
	assginDrpVal(6)
End Sub

Sub drpToHrs6_Change
	assginDrpVal(6)	
End Sub

Sub drptomin6_Change
	if #drptomin6$<#drpfrommin6$ and #drptohrs6$= #drpfromhrs6$ then
		assginDrpVal(6)
	end if
End Sub


Sub drpfrommin6_change
	if #drptohrs6$= #drpfromhrs6$  and #drptomin6$<#drpfrommin6$ then
		#drptomin6$ = #drpfrommin6$ 
	end if 
End Sub

Sub drpFromHrs7_Change
	assginDrpVal(7)
End Sub

Sub drpToHrs7_Change
	assginDrpVal(7)	
End Sub

Sub drptomin7_Change
	if #drptomin7$<#drpfrommin7$ and #drptohrs7$= #drpfromhrs7$ then
		assginDrpVal(7)
	end if
End Sub

Sub drpfrommin7_change
	if #drptohrs7$= #drpfromhrs7$  and #drptomin7$<#drpfrommin7$ then
		#drptomin7$ = #drpfrommin7$ 
	end if 
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




Sub ddstorageformat1_Click
	' Add Handler Code Here 
End Sub



Sub drpday1_Click
	' Add Handler Code Here 
End Sub



Sub txtweeks_Change
	' Add Handler Code Here 
End Sub





Sub lbldummy_Click
	' Add Handler Code Here 
End Sub




