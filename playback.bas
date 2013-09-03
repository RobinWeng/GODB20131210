option(4+1)
showcursor(3) 

#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"


dimi noofctrl  								 'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS
dims LabelName$(noofctrl)					 'Form controls name
dimi XPos(noofctrl)							 'Form controls X position
dimi YPos(noofctrl) 						 'Form controls Y position
dimi Wdh(noofctrl)							 'Form controls Width position
dimi height(noofctrl)		                                         'Form controls height position
                                                         
														
dims ctrlValues$(noofctrl)
dimi playhour

#include "playback.inc"

#define SCHEDULE_W             560 * ~factorX
#define SCHEDULE_H             90 * ~factorY
#define SCH_BG_COL             6602
#define SCH_BDR_COL            2245

#define HOUR_DISPLAY_Y_GAP     2
#define SCH_IDX_GAP			   3
#define SCH_IDX_W              3
#define DAY_X_GAP              10


#define MINUTE_DISPLAY_Y_GAP   10
#define DURATION_MINUTE        10

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

#define HOUR_TXT_STYLE         8
#define HOUR_TXT_FG            52793
'#define HOUR_TXT_FG            65535
#define HOUR_TXT_FONT          7


#define SCH_IDX_BG             52793
#define CHK_GREEN            1638
#define CHK_BLUE             6603


dimi ~chFlag,~ch0Stop,~ch1Stop,~ch2Stop,~ch3Stop,~playSlider0Pos,~playSlider1Pos,~playSlider2Pos,~playSlider3Pos,~pauseOrNot,lastchannel
dimi ~ch0playOrNot,~ch1playOrNot,~ch2playOrNot,~ch3playOrNot
~ch0playOrNot=0
~ch1playOrNot=0
~ch2playOrNot=0
~ch3playOrNot=0

~chFlag=0
~ch0Stop=1
~ch1Stop=1
~ch2Stop=1
~ch3Stop=1
~playSlider0Pos=0
~playSlider1Pos=0
~playSlider2Pos=0
~playSlider3Pos=0
lastchannel=0


dims ~currentPlayBackName$,~ch0PlayBackName$,~ch1PlayBackName$,~ch2PlayBackName$,~ch3PlayBackName$


dims streamOption$(4)   'add by hst

dimi hour(25),minute(61), timearr(24*60)

dimi i 
for i=0 to 24
	hour(i)=0
next

for i=0 to 60
	minute(i)=0
next

for i=0 to  24*60-1
	timearr(i)=0
next

end

Dimi xRatio,yRatio


/***********************************************************
'** Form_Load
 *	Description:Display controls based on the screen resolution 
 *				Call setGridSettings function to set egrid settings
 *				and call fetchUserDetails function to fetch and display 
 *				users avaiable in camera.		
 
 *	Created by: vimala On 2009-03-17 12:55:31

 ***********************************************************/
sub form_load	
	
		
	call displayControls(LabelName$,XPos,YPos,Wdh,height)

	assignSelectedImage("imgmenu[3]")		
	setfocus("imgmenu[3]")
	showSubMenu(0,0)

	'setfocus("txtusername")
	'showcursor(3)
		
		
	streamOption$(0)="1"
	streamOption$(1)="2"
	streamOption$(2)="3"
	streamOption$(3)="4"
	
	call addItemsToDropDown("streamChannel", streamOption$, -1)	'add by hst
	
	'Get stream name and rtsp url from camera
'	loadStreamDetails(stream$,rtspUrl$)			'TR-04
'	pprint rtspUrl$(0);rtspUrl$(1);rtspUrl$(2),rtspUrl$(3)
'	if stream$(0) = "" then
'		msgbox "Streams not available"
'		loadurl("!auth.frm")
'	end if	
	
	
	'create video player(GDO) to display video.	

	createGDOControl("gdoVideo1",#gdobg1.x,#gdobg1.y, #gdobg1.w,#gdobg1.h)
'	createGDOControl("gdoVideo2",#gdobg2.x,#gdobg2.y,#gdobg2.w,#gdobg2.h)
'	createGDOControl("gdoVideo3",#gdobg3.x,#gdobg3.y,#gdobg3.w,#gdobg3.h)
'	createGDOControl("gdoVideo4",#gdobg4.x,#gdobg4.y,#gdobg4.w,#gdobg4.h)
'	createGDOControl("gdoVideo5",#gdobg5.x,#gdobg5.y,#gdobg5.w,#gdobg5.h)

	dimi tempx,tempy,tempw,temph;
	
	calVideoDisplayRatio("(352x240)",xRatio,yRatio)				' TR-04
	
	tempx=#gdobg1.x
	tempy=#gdobg1.y
	tempw=#gdobg1.w
	temph=#gdobg1.h

	
	checkAspectRatio(tempw, temph,xRatio,yRatio)

	#gdobg1.x=tempx-1
	#gdobg1.y=tempy-1
	#gdobg1.w = tempw+1 
	#gdobg1.h = temph+1	

	#gdoVideo1.x = tempx
	#gdoVideo1.y = tempy
	#gdoVideo1.w = tempw
	#gdoVideo1.h = temph
	

	dimi a
	dims voidURL$
	a=#gdoVideo1.play(voidURL$)
'	a=#gdoVideo2.play(voidURL$)
'	a=#gdoVideo3.play(voidURL$)
'	a=#gdoVideo4.play(voidURL$)
'	#gdoVideo3.hidden=1
'	#gdobg5.hidden=1
'	#gdoVideo5.hidden=1
	
	/*
	dimi a 
	a=#gdoVideo1.play("rtsp://192.168.1.239:654/3.264")
	sleep(20000)
	msgbox("11111111111111111")
	a = #gdovideo1.stop(1)	
	msgbox("333333333333333333333333")
	sleep(5000)
	msgbox("222222222222222222222")
	a=#gdoVideo1.play("rtsp://192.168.1.239:654/3.264")
	*/
End Sub


/***********************************************************
'** getINIValus
 *	Description: 
 *		Load the keywordvalues from INI file.
 *		Get the camera name.

 *	Created by: Partha Sarathi.K On 2009-03-18 11:35:15
 ***********************************************************/
sub getINIValus()
	
	dimi retVal
		
	if request$("isINIValue") <> "1" then
	
		~maxPropIndex = 0

		retVal = loadIniValues()
	
		if ~maxPropIndex = 0 then 
			msgbox("Unable to load initial values.\n ini.htm unavailable")
			loadurl("!auth.frm")
		endif
		
		~title$ = getTitle$()
		
	endif
	
End Sub



sub savepage()
	
End Sub


sub form_paint
	call recordtime()
End Sub



sub form_complete
	
	dimi i
	for i = 0 to ubound(ctrlValues$)-1		
		ctrlValues$(i) = #{LabelName$(i)}
		pprint 		ctrlValues$(i)
	next
	
	
'	call disp_streams
	update							'Added by Vimala
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
	
'	update	
End Sub


sub chkValueMismatch()
'	checkForModification(ctrlValues$, LabelName$)	
End Sub


Sub recorddate_Click
	' Add Handler Code Here 
	
	dimi  retVal
	retVal = showdate(date(),(#lbltime.x-30),(#lbltime.y+#lbltime.h+5))
	
	if retVal = 1 then 		
		'#recorddate$=left$(format$("8",dateval()),4)+"/"+mid$(format$("8",dateval()),4,2)+"/"+right$(format$("8",dateval()),2)		
		dims temp$
		temp$=left$(format$("8",dateval()),4)+"/"+mid$(format$("8",dateval()),4,2)+"/"+right$(format$("8",dateval()),2)		
		#recorddate$=temp$
		#recorddate.tag = dateval()		
			
	endif


End Sub

sub recordtime()
 
	dimi selColor
	dimi txtY
	dimi yPos, xPos, i, maxDur, hourW, durHourW, timeVal
	dimi j, lineYPos
	
	xpos = 	#gdobg1.x
	'Draw the header
	'FILLRECT(xpos, scheduleY, SCHEDULE_W, SCH_TIT_H, SCH_TIT_BG)
	
	'Display the title
	'txtY = 	SCH_TIT_H - gettextheight("Schedule", SCH_TIT_STYLE, SCH_TIT_FONT)
	'textout(xPos+SCH_TIT_X_GAP, scheduleY+txtY-2, "Schedule", SCH_TIT_STYLE, SCH_TIT_FG, SCH_TIT_FONT)
	
	'yPos = scheduleY + SCH_TIT_H
	
	'Draw the schdule BG
	yPos=#gdobg1.y+#gdobg1.h+20
	
'	ROUNDRECT(xpos, yPos, SCHEDULE_W, SCHEDULE_H, SCH_BDR_COL, SCH_BG_COL, 0, 0)

'	xPos  = scheduleX
	yPos += HOUR_DISPLAY_Y_GAP
	
	maxDur   = TOT_HOUR/DURATION_HOUR
	durHourW = (SCHEDULE_W-50*~factorX)/maxDur
	
	'Display the hour 
	for i=0 to maxDur
		timeVal = i*DURATION_HOUR
		textout(xPos+5*~factorX, yPos, format$("2.2", timeVal), HOUR_TXT_STYLE, HOUR_TXT_FG, HOUR_TXT_FONT)
		xPos += durHourW
	next
	
	xpos = 	#gdobg1.x
	yPos += 30*~factorY
	
'	dimi temptemp
'	temptemp=#label1.y+#label1.h
	
'	msgbox(temptemp)//545    591(非网页)
'	msgbox(yPos)//562    589(非网页)	
'	pprint ypos,temptemp
	
	DRAWLINE(xPos+5*~factorX, YPos, xPos+SCHEDULE_W-5*~factorX, yPos, 1, SCH_IDX_BG)
	
	
	'DRAWLINE(xPos+5*~factorX+SCHEDULE_W-10*~factorX, YPos, xPos+5*~factorX+SCHEDULE_W-10*~factorX, yPos-10*~factorY, 5, SCH_IDX_BG)
	
	
	/*
	for i=0 to 24
		if i=0 then
			xPos+=5*~factorX
			DRAWLINE(float(xPos), YPos, float(xPos), yPos-10*~factorY, 2, SCH_IDX_BG)
		elseif i%DURATION_HOUR=0 then
			DRAWLINE(float(xPos), YPos,float(xPos), yPos-10*~factorY, 2, SCH_IDX_BG)
		else
			DRAWLINE(float(xPos), YPos, float(xPos), yPos-5*~factorY, 1, SCH_IDX_BG)
		endif
		
		xPos+=(SCHEDULE_W-10*~factorX)/24.0
	next
	*/
	
'	FILLRECT(xPos, yPos, SCH_IDX_W, CHK_GREEN, curColor,,,ALPHA_LEVEL)
	
	dimf hourpos ,lasthourpos

	for i=0 to 24
		if i=0 then
			hourpos=xPos+5*~factorX
			DRAWLINE(hourpos, YPos, hourpos, yPos-10*~factorY, 2, SCH_IDX_BG)
		elseif i%DURATION_HOUR=0 then
			DRAWLINE(hourpos, YPos,hourpos, yPos-10*~factorY, 2, SCH_IDX_BG)
		else
			DRAWLINE(hourpos, YPos, hourpos, yPos-5*~factorY, 1, SCH_IDX_BG)
		endif
		
		if hour(i)=1 then
			FILLRECT(lasthourpos+5, yPos-10, ((SCHEDULE_W-10*~factorX)/24.0)-10, 10, CHK_GREEN,,,0)
		endif
		
		lasthourpos=hourpos
		hourpos+=(SCHEDULE_W-10*~factorX)/24.0
	next
	
	
	 
'	FILLRECT(hourpos, yPos-10, 3, 10, CHK_GREEN,,,0)
'	DRAWLINE(hourpos, YPos, hourpos, yPos-10*~factorY, 2, CHK_GREEN)

	
	
	
	yPos += MINUTE_DISPLAY_Y_GAP
	
	maxDur   = 6
	durHourW = (SCHEDULE_W-50*~factorX)/maxDur
	
	'Display the hour(minute)
	for i=0 to maxDur
		timeVal = i*DURATION_MINUTE
		textout(xPos+5*~factorX, yPos, format$("2.2", timeVal), HOUR_TXT_STYLE, HOUR_TXT_FG, HOUR_TXT_FONT)
		xPos += durHourW
	next
	
	
	xpos = 	#gdobg1.x
	yPos += 30*~factorY
	
	DRAWLINE(xPos+5*~factorX, YPos, xPos+SCHEDULE_W-5*~factorX, yPos, 1, SCH_IDX_BG)
	
	
	
	
	dimf minpos ,lastminpos
	
	for i=0 to 60
		if i=0 then
			minpos=xPos+5*~factorX
		'	if minute(i)=0 then
				DRAWLINE(minpos, YPos, minpos, yPos-10*~factorY, 2, SCH_IDX_BG)
		'	else
		'		DRAWLINE(minpos, YPos, minpos, yPos-10*~factorY, 2, CHK_GREEN)
			'	FILLRECT(minpos-(SCHEDULE_W-10*~factorX)/60.0-5, yPos-10, (SCHEDULE_W-10*~factorX)/60.0-5, 10, CHK_GREEN,,,0)
		'	endif
		elseif i%(DURATION_MINUTE/2)=0 then
		'	if minute(i)=0 then
				DRAWLINE(minpos, YPos,minpos, yPos-10*~factorY, 2, SCH_IDX_BG)
		'	else
		'		DRAWLINE(minpos, YPos,minpos, yPos-10*~factorY, 2, CHK_GREEN)
			'	FILLRECT(minpos-(SCHEDULE_W-10*~factorX)/60.0-5, yPos-10, (SCHEDULE_W-10*~factorX)/60.0-5, 10, CHK_GREEN,,,0)
		'	endif
		else
		'	if minute(i)=0 then
				DRAWLINE(minpos, YPos, minpos, yPos-5*~factorY, 1, SCH_IDX_BG)
		'	else
		'		DRAWLINE(minpos, YPos, minpos, yPos-5*~factorY, 1, CHK_GREEN)
            '	FILLRECT(minpos-(SCHEDULE_W-10*~factorX)/60.0-5, yPos-10, (SCHEDULE_W-10*~factorX)/60.0-5, 10, CHK_GREEN,,,0)
		'	endif
		endif
		
		if minute(i)=1 then
			FILLRECT(lastminpos, yPos-3, ((SCHEDULE_W-10*~factorX)/60.0), 3, CHK_GREEN,,,0)
		endif
		
		lastminpos=minpos
		
		
		minpos+=(SCHEDULE_W-10*~factorX)/60.0
	next
	

end sub


dimi index


Sub Label1_Click
	' Add Handler Code Here
	index=1 
	call recordFlag(index)
End Sub


Sub Label2_Click
	' Add Handler Code Here
	index=2 
	call recordFlag(index)
End Sub


Sub Label3_Click
	' Add Handler Code Here
	index=3
	call recordFlag(index)
End Sub


Sub Label4_Click
	' Add Handler Code Here
	index=4 
	call recordFlag(index)
End Sub


Sub Label5_Click
	' Add Handler Code Here
	index=5 
	call recordFlag(index)
End Sub


Sub Label6_Click
	' Add Handler Code Here
	index=6 
	call recordFlag(index)
End Sub

Sub Label7_Click
	' Add Handler Code Here
	index=7 
	call recordFlag(index)
End Sub

Sub Label8_Click
	' Add Handler Code Here
	index=8 
	call recordFlag(index)
End Sub

Sub Label9_Click
	' Add Handler Code Here
	index=9 
	call recordFlag(index)
End Sub

Sub Label10_Click
	' Add Handler Code Here
	index=10 
	call recordFlag(index)
End Sub

Sub Label11_Click
	' Add Handler Code Here
	index=11 
	call recordFlag(index)
End Sub

Sub Label12_Click
	' Add Handler Code Here
	index=12 
	call recordFlag(index)
End Sub


Sub Label13_Click
	' Add Handler Code Here
	index=13 
	call recordFlag(index)
End Sub


Sub Label14_Click
	' Add Handler Code Here
	index=14 
	call recordFlag(index)
End Sub


Sub Label15_Click
	' Add Handler Code Here
	index=15 
	call recordFlag(index)
End Sub


Sub Label16_Click
	' Add Handler Code Here
	index=16 
	call recordFlag(index)
End Sub


Sub Label17_Click
	' Add Handler Code Here
	index=17 
	call recordFlag(index)
End Sub


Sub Label18_Click
	' Add Handler Code Here
	index=18 
	call recordFlag(index)
End Sub

Sub Label19_Click
	' Add Handler Code Here
	index=19 
	call recordFlag(index)
End Sub

Sub Label20_Click
	' Add Handler Code Here
	index=20 
	call recordFlag(index)
End Sub

Sub Label21_Click
	' Add Handler Code Here
	index=21 
	call recordFlag(index)
End Sub

Sub Label22_Click
	' Add Handler Code Here
	index=22 
	call recordFlag(index)
End Sub

Sub Label23_Click
	' Add Handler Code Here
	index=23 
	call recordFlag(index)
End Sub

Sub Label24_Click
	' Add Handler Code Here
	index=24 
	call recordFlag(index)
End Sub




Sub recordFlag(dimi index)
	dimi i,j
	j=0
	minute(0)=0
	for i=1 to 60
		minute(i)=timearr((index-1)*60+i-1)
		if minute(i)=1 and j=0 then
			#playslider = (i-1)*60
			j=1
		endif
	next	
	playhour=index-1
	'TEXTOUT(200,577,"播放时间："+playhour,0,1638,3)
End Sub



'rtsp://192.168.1.239:8557/PSIA/Streaming/channels/2?videoCodecType=H.264 
'http://192.168.1.239/

Sub imgplay_Click
	
	#imgplay.focussable = 0	
	#imgplay.src$="!play_on.jpg"
		
	#imgstop.focussable=1
	#imgstop.src$="!stop_on.jpg"
	
	#imgpause.focussable=1
	#imgpause.src$="!pause_on.jpg"
	
	#imgresume.focussable=0
	#imgresume.src$="!resume_off.jpg"
	
	#img1play.focussable=1
	#img1play.src$="!1play_on.jpg"
	
	#img2play.focussable=1
	#img2play.src$="!2play_on.jpg"
	
	#img4play.focussable=1
	#img4play.src$="!4play_on.jpg"
	
	#img8play.focussable=1
	#img8play.src$="!8play_on.jpg"
	
		
	dimi playSliderPos
	playSliderPos=#playslider
	call playExec(playSliderPos,1)


	
	
End Sub





Sub imgsearch_Click
	' Add Handler Code Here 
	
	dims year$,month$,day$,ch$;
	dimi ret 
	dims recdate$,responserecdate$
	recdate$=#recorddate.tag
	dimi temp
	
	for i=0 to 24
		hour(i)=0
	next
		
	ch$=#streamChannel.SelIDX
	if len(ch$) = 0 then
		msgbox("Please select channel!")
		return
	endif
	
	if recdate$="0" then
		 msgbox("Please select date")
		 return
	endif
'	year=left$(format$("8",dateval()),4)
'	month=mid$(format$("8",dateval()),4,2)
'	day=right$(format$("8",dateval()),2)
	year$=left$(recdate$,4)
	month$=mid$(recdate$,4,2)
	day$=right$(recdate$,2)
	recdate$=year$+"@"+month$+"@"+day$+"@"+ch$
	
	pprint recdate$

	dimi findPos,retVal,i,j
	dims recordFlag$
 	retVal =  getRecordDate(recdate$,responserecdate$)
 	
 	pprint "retval="+retVal
 	pprint "responserecadate="+responserecdate$
		
	if retVal > 0  then
		findPos = find(responserecdate$,"pbrechourdata=")
		findPos += len("pbrechourdata=")
		recordFlag$ = mid$(responserecdate$,findPos)	
		//msgbox(recordFlag$)
		'pprint "recordFlag="+recordFlag$
		
		for i=0 to 24*60-1
			timearr(i)=StrToInt(mid$(recordFlag$,i,1))
			'pprint "timearr"+i+":"+timearr(i)+" StrToInt(mid$(recordFlag$,i,1))"+mid$(recordFlag$,i,1)
			if timearr(i)=1 then
				hour(i/60+1)=1				
			endif
		next
	end if




	'ret=HTTPDNLD(~camAddPath$+"vb.htm?pbrechourdata="+recdate, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
	'ret=HTTPDNLD(~camAddPath$+"vb.htm?startplaybackch=1970@1@1@0@2@0@0", "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
End Sub



Sub imgpause_Click
	' Add Handler Code Here 
	' pauseplaybackch
	pprint "pause  "
	#imgplay.focussable = 0	
	#imgplay.src$="!play_off.jpg"
		
	
	#imgstop.focussable=1
	#imgstop.src$="!stop_on.jpg"
	
	#imgpause.focussable=0
	#imgpause.src$="!pause_off.jpg"
	
	#imgresume.focussable=1
	#imgresume.src$="!resume_on.jpg"
	
	#img1play.focussable=0
	#img1play.src$="!1play_off.jpg"
	
	#img2play.focussable=0
	#img2play.src$="!2play_off.jpg"
	
	#img4play.focussable=0
	#img4play.src$="!4play_off.jpg"
	
	#img8play.focussable=0
	#img8play.src$="!8play_off.jpg"
	
	
	dims responeDate$
	dimi ret
	dims param$
	param$=~chFlag+"@"+~currentPlayBackName$
	
	~pauseOrNot=1
'	msgbox(param$)
	pprint "param="+param$
	ret=HTTPDNLD(~camAddPath$+"vb.htm?pauseplaybackch="+param$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeDate$)
	pprint "ret"+ret
	pprint "pause responedate="+responeDate$
	call stopandpauseandresume(~pauseOrNot,~chFlag)
End Sub



Sub img1play_Click
	' Add Handler Code Here 
	
	#imgplay.focussable = 0	
	#imgplay.src$="!play_off.jpg"
		
	#imgstop.focussable=1
	#imgstop.src$="!stop_on.jpg"
	
	#imgpause.focussable=1
	#imgpause.src$="!pause_on.jpg"
	
	#imgresume.focussable=0
	#imgresume.src$="!resume_off.jpg"
	
	#img1play.focussable=0
	#img1play.src$="!1play_off.jpg"
	
	#img2play.focussable=1
	#img2play.src$="!2play_on.jpg"
	
	#img4play.focussable=1
	#img4play.src$="!4play_on.jpg"
	
	#img8play.focussable=1
	#img8play.src$="!8play_on.jpg"
	
	dimi playSliderPos
	playSliderPos=#playslider
	call playExec(playSliderPos,1)
	
End Sub



Sub img2play_Click
	
	#imgplay.focussable = 0	
	#imgplay.src$="!play_off.jpg"
		
	#imgstop.focussable=1
	#imgstop.src$="!stop_on.jpg"
	
	#imgpause.focussable=1
	#imgpause.src$="!pause_on.jpg"
	
	#imgresume.focussable=0
	#imgresume.src$="!resume_off.jpg"
	
	#img1play.focussable=1
	#img1play.src$="!1play_on.jpg"
	
	#img2play.focussable=0
	#img2play.src$="!2play_off.jpg"
	
	#img4play.focussable=1
	#img4play.src$="!4play_on.jpg"
	
	#img8play.focussable=1
	#img8play.src$="!8play_on.jpg"
	
	dimi playSliderPos
	playSliderPos=#playslider
	call playExec(playSliderPos,2)
	
End Sub



Sub img4play_Click
	
	#imgplay.focussable = 0	
	#imgplay.src$="!play_off.jpg"
		
	#imgstop.focussable=1
	#imgstop.src$="!stop_on.jpg"
	
	#imgpause.focussable=1
	#imgpause.src$="!pause_on.jpg"
	
	#imgresume.focussable=0
	#imgresume.src$="!resume_off.jpg"
	
	#img1play.focussable=1
	#img1play.src$="!1play_on.jpg"
	
	#img2play.focussable=1
	#img2play.src$="!2play_on.jpg"
	
	#img4play.focussable=0
	#img4play.src$="!4play_off.jpg"
	
	#img8play.focussable=1
	#img8play.src$="!8play_on.jpg"
	
	dimi playSliderPos
	playSliderPos=#playslider
	call playExec(playSliderPos,4)
	
End Sub



Sub img8play_Click
	
	#imgplay.focussable = 0	
	#imgplay.src$="!play_off.jpg"
		
	#imgstop.focussable=1
	#imgstop.src$="!stop_on.jpg"
	
	#imgpause.focussable=1
	#imgpause.src$="!pause_on.jpg"
	
	#imgresume.focussable=0
	#imgresume.src$="!resume_off.jpg"
	
	#img1play.focussable=1
	#img1play.src$="!1play_on.jpg"
	
	#img2play.focussable=1
	#img2play.src$="!2play_on.jpg"
	
	#img4play.focussable=1
	#img4play.src$="!4play_on.jpg"
	
	#img8play.focussable=0
	#img8play.src$="!8play_off.jpg"
	
	dimi playSliderPos
	playSliderPos=#playslider
	call playExec(playSliderPos,8)
	
End Sub



Sub imgstop_Click
	' Add Handler Code Here 
	' stopplaybackch
	
	
	if ~chFlag=0 then
		~ch0playOrNot=1
		#playslider.disabled=1
	elseif ~chFlag=1 then
		~ch1playOrNot=1
		#playslider.disabled=1
	elseif ~chFlag=1 then
		~ch2playOrNot=1
		#playslider.disabled=1
	else
		~ch3playOrNot=1
		#playslider.disabled=1
	endif
	
	#imgplay.focussable = 1			
	#imgplay.src$="!play_off.jpg"
	
	
	#imgstop.focussable=0
	#imgstop.src$="!stop_off.jpg"
	
	#imgpause.focussable=0
	#imgpause.src$="!pause_off.jpg"
	
	#imgresume.focussable=0
	#imgresume.src$="!resume_off.jpg"
	
	#img1play.focussable=0
	#img1play.src$="!1play_off.jpg"
	
	#img2play.focussable=0
	#img2play.src$="!2play_off.jpg"
	
	#img4play.focussable=0
	#img4play.src$="!4play_off.jpg"
	
	#img8play.focussable=0
	#img8play.src$="!8play_off.jpg"
	
	
	pprint "stop   "
	dims responeDate$,param$
	dimi ret
	param$=~chFlag+"@"+~currentPlayBackName$
	~pauseOrNot=1
	pprint "param="+param$
	ret=HTTPDNLD(~camAddPath$+"vb.htm?stopplaybackch="+param$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeDate$)
	pprint "ret="+ret
	call stopandpauseandresume(~pauseOrNot,~chFlag)
	
	
End Sub



Sub imgresume_Click
	' Add Handler Code Here 
	' resumeplaybackch
	
	#imgplay.focussable = 0
	#imgplay.src$="!play_off.jpg"
			
	
	#imgstop.focussable=1
	#imgstop.src$="!stop_on.jpg"
	
	#imgpause.focussable=1
	#imgpause.src$="!pause_on.jpg"
	
	#imgresume.focussable=0
	#imgresume.src$="!resume_off.jpg"
	
	#img1play.focussable=1
	#img1play.src$="!1play_on.jpg"
	
	#img2play.focussable=1
	#img2play.src$="!2play_on.jpg"
	
	#img4play.focussable=1
	#img4play.src$="!4play_on.jpg"
	
	#img8play.focussable=1
	#img8play.src$="!8play_on.jpg"
	
	
	dims responeDate$,param$
	dimi ret
	param$=~chFlag+"@"+~currentPlayBackName$
	pprint "param="+param$
	
	~pauseOrNot=0
	
	'msgbox(param$)  
	ret=HTTPDNLD(~camAddPath$+"vb.htm?resumeplaybackch="+param$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeDate$)
	call stopandpauseandresume(~pauseOrNot,~chFlag)
End Sub



Sub playslider_Change
'	iff ~playOrNot=0 then return	
	' Add Handler Code Here 
	

	dimi playSliderPos,a
	
	if ~chFlag=0 then
		a = #gdovideo1.stop(1)	
	elseif ~chFlag=1 then
		a = #gdovideo2.stop(1)	
	elseif ~chFlag=2 then
		a = #gdovideo3.stop(1)	
	else
		a = #gdovideo4.stop(1)	
	endif
	
	call imgstop_Click	
	sleep(1000)
	
	playSliderPos=#playslider
	
	if minute(playSliderPos/60)=0 then
		msgbox("The minute no Video!")
		return
	endif

	call playExec(playSliderPos,2)
	
	#imgplay.focussable = 0	
	#imgplay.src$="!play_on.jpg"
		
	#imgstop.focussable=1
	#imgstop.src$="!stop_on.jpg"
	
	#imgpause.focussable=1
	#imgpause.src$="!pause_on.jpg"
	
	#imgresume.focussable=0
	#imgresume.src$="!resume_off.jpg"
	
	#img1play.focussable=1
	#img1play.src$="!1play_on.jpg"
	
	#img2play.focussable=1
	#img2play.src$="!2play_on.jpg"
	
	#img4play.focussable=1
	#img4play.src$="!4play_on.jpg"
	
	#img8play.focussable=1
	#img8play.src$="!8play_on.jpg"
	
End Sub


Sub playExec(dimi sliderPos,dimi playspeed)
	
	dims playRecUrl$,playdate$,ch$,responeDate$
	dimi a,ret,minute,second
	dims playtime$
	
	playRecUrl$="rtsp"+mid(~camAddPath$,4,16)+":654/"
	playtime$=time()+".264"	
	pprint "playRecUrl$="+playRecUrl$
	pprint "playtime$="+playtime$
	
	if ~chFlag=0 then
		~ch0playOrNot=1
		#playslider.disabled=0
		~ch0PlayBackName$=playtime$
		~ch0Stop=0
		~playSlider0Pos=sliderPos
		
	elseif ~chFlag=1 then
		~ch1playOrNot=1
		#playslider.disabled=0
		~ch1PlayBackName$=playtime$
		~ch1Stop=0
		~playSlider1Pos=sliderPos
	elseif ~chFlag=2 then
		~ch2playOrNot=1
		#playslider.disabled=0
		~ch2PlayBackName$=playtime$
		~ch2Stop=0
		~playSlider2Pos=sliderPos
	else
		~ch3playOrNot=1
		#playslider.disabled=0
		~ch3PlayBackName$=playtime$
		~ch3Stop=0
		~playSlider3Pos=sliderPos
	endif
	
	~currentPlayBackName$=playtime$
	
'	~chFlag= #streamChannel.selidx
	
	
	ch$=#streamChannel.SelIDX
    minute=sliderPos/60
    second=sliderPos%60
	playdate$=left$(#recorddate.tag,4)+"@"+mid$(#recorddate.tag,4,2)+"@"+right$(#recorddate.tag,2)+"@"+playhour+"@"+minute+"@"+second+"@"+ch$+"@"+playtime$+"@"+1
	pprint "playdate$="+playdate$
	
	'msgbox(playdate$)	
	ret=HTTPDNLD(~camAddPath$+"vb.htm?startplaybackch="+playdate$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeDate$)
	sleep(1000)
	
	if ret > 0 then
		playRecUrl$+=playtime$
		pprint "playRecUrl$+=playtime$ ="+playRecUrl$

		if ch$="0" then
			pprint playRecUrl$
			a = #gdoVideo1.stop(1)
			a=#gdoVideo1.play(playRecUrl$)
		elseif ch$="1" then
			a = #gdoVideo2.stop(1)
			a=#gdoVideo2.play(playRecUrl$)
		elseif ch$="2" then
			a = #gdoVideo3.stop(1)
			a=#gdoVideo3.play(playRecUrl$)
		else
			a = #gdoVideo4.stop(1)
			a=#gdoVideo4.play(playRecUrl$)
		endif
	
	endif
	
	settimer(1000,"TestSub")
	
	call TestSub()

End Sub


Sub TestSub()
	
	

	if ~ch0stop=0 then
		~playSlider0Pos++
	endif
	
	if ~ch1stop=0 then
		~playSlider1Pos++
	endif
	
	if ~ch2stop=0 then
		~playSlider2Pos++
	endif
	
	if ~ch3stop=0 then
		~playSlider3Pos++
	endif
	
	if ~chFlag=0 and ~ch0stop=0 then
		#playslider = ~playSlider0Pos
		'~playSlider0Pos++
	elseif ~chFlag=1 and ~ch1stop=0 then
		#playslider = ~playSlider1Pos
		'~playSlider1Pos++
	elseif ~chFlag=2 and ~ch2stop=0 then
		#playslider = ~playSlider2Pos
		'~playSlider2Pos++
	elseif ~chFlag=3 and ~ch3stop=0 then
		#playslider = ~playSlider3Pos
		'~playSlider3Pos++
	endif
	
		
	update
	

End Sub


Sub streamChannel_Click
	' Add Handler Code Here 
		lastchannel= #streamChannel.selidx 
End Sub


Sub streamChannel_Change
	' Add Handler Code Here 
	
	~chFlag= #streamChannel.selidx
		
	if ~chFlag=0 then
		iff  ~ch0playOrNot=1 then #playslider.disabled=0
		~currentPlayBackName$=~ch0PlayBackName$
	elseif ~chFlag=1 then
		iff  ~ch1playOrNot=1 then #playslider.disabled=0
		~currentPlayBackName$=~ch1PlayBackName$
	elseif ~chFlag=2 then
		iff  ~ch2playOrNot=1 then #playslider.disabled=0
		~currentPlayBackName$=~ch2PlayBackName$
	else
		iff  ~ch3playOrNot=1 then #playslider.disabled=0
		~currentPlayBackName$=~ch3PlayBackName$
	endif
	
	/*
	iff lastchannel = ~chFlag then return
	
	#imgplay.focussable = 1			
	#imgplay.src$="!play_off.jpg"
	
	
	#imgstop.focussable=0
	#imgstop.src$="!stop_off.jpg"
	
	#imgpause.focussable=0
	#imgpause.src$="!pause_off.jpg"
	
	#imgresume.focussable=0
	#imgresume.src$="!resume_off.jpg"
	
	#img1play.focussable=0
	#img1play.src$="!1play_off.jpg"
	
	#img2play.focussable=0
	#img2play.src$="!2play_off.jpg"
	
	#img4play.focussable=0
	#img4play.src$="!4play_off.jpg"
	
	#img8play.focussable=0
	#img8play.src$="!8play_off.jpg"
	*/
'	msgbox(~currentPlayBackName$)
End Sub


Sub stopandpauseandresume(dimi flag,dimi ch)
	
	if flag=1  then
		if ch=0 then
			~ch0Stop=1
		elseif ch=1 then
			~ch1Stop=1
		elseif ch=2 then
			~ch2Stop=1	
		else 
			~ch3Stop=1
		endif
	endif
	
	if flag=0  then
		if ch=0 then
			~ch0Stop=0
		elseif ch=1 then
			~ch1Stop=0
		elseif ch=2 then
			~ch2Stop=0	
		else 
			~ch3Stop=0
		endif
	endif

End Sub


Sub imgdisplayfull_Click
	if canReload = 1 then
		Dimi streamNo,playslidepos,ch,playhour,hour
		playslidepos=#playslider
		ch=#streamChannel.selidx
		playhour=#recorddate.tag
		hour=playhour
	'	streamNo = atol(#ddstream$)
	'LoadUrl("!display2xMode.frm&streamNo=1&playslidepos="+playslidepos+"&ch=1&playhour="+playhour+"&hour="+hour)
	
		LoadUrl("!display2xMode.frm&streamNo="+streamNo+"&playslidepos="+playslidepos+"&ch="+ch+"&playhour="+playhour+"&hour="+hour)
	end if
End Sub





Sub playslider_Click
	' Add Handler Code Here 
End Sub

