/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : All Streams Video Settings                                            *
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
Displays all available streams
*/

option(4+1)
dimi timerCount				  'Used to animate Loading.... value    'TR-30
#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"

#define TOOLTIP_TXT_STYLE          8
#define TOOLTIP_TXT_FG             55038
#define TOOLTIP_TXT_FONT           7

#define TOOLTIP_WIDTH1           80 
#define TOOLTIP_WIDTH2           100
#define TOOLTIP_WIDTH3           120 
#define TOOLTIP_WIDTH4           80 
#define TOOLTIP_HEIGHT           20

#define GDO_X1			   260
#define GDO_X2			   750	
#define GDO_X3			   750

#define GDO_Y1			   255
#define GDO_Y2			   240
#define GDO_Y3			   397

#define GDO_W1			   480	
#define GDO_W2			   240	
#define GDO_W3             240
                           
#define GDO_H1			   270		   
#define GDO_H2			   135
#define GDO_H3			   135
   
#define GNOTIFY_HTTP_DNLD_FAILURE 40 
#define GNOTIFY_HTTP_DNLD_SUCCESS 41 
#define GNOTIFY_HTTP_DNLD_ABORTED 45 

option(4+1)

Dims stream$(3),rtspUrl$(3)
Dimi flagAudio=1									'set the flag to enable/disable the audio
dimi flagSnap=0										'set the flag to hide/show the frmSnap(Frame)
Dims alarmstatus$ = "0000"							'set the alarm status initially
dims oldAlarmStaus$									'to store the previous alarm status
settimer(1000)										'to enable timer for 1 second

dimi noofctrl										'Number of Form controls			
noofctrl = getfldcount()-LEFTMENUCTRLS                      
dims LabelName$(noofctrl)                           'Form controls name
dimi XPos(noofctrl)                                 'Form controls X position
dimi YPos(noofctrl)                                 'Form controls Y position
dimi Wdh(noofctrl)                                  'Form controls Width position
dimi height(noofctrl)                               'Form controls height position
dimi displayallstreams = 0							'Added by Rajan for testing
dimi sleeptime = 1000								'Added by Rajan for testing
dimi stream = 0										'Added by Rajan for testing
dimi rule

#include "allStreamsVideo.inc"
dimi democfg                  'Example drop down selected value     'TR-30
dimi audiomode					'audio mode									
call loadStreamValues()		
showcursor(3)
assignSelectedImage("imgmenu")
setfocus("imgmenu")
setfocus("chkdispallstreams")
#chkdispallstreams.disabled = 1
dimi totActiveGDO									'to store the value-(total no of streams active)
Dims prvscreen1$,prvscreen2$,prvscreen3$,prvscreen4$,prvScreen5$   'capture previous screen before showing tooltip
dimi toolTipPaintFlag = 0
dimi blnCanGetAlarmStatus
dimi selExampleVal
dimi saveSuccess = 0	 			' Value of 1 is success
dimi animateCount = 0 	 			' Stores the count for the animation done.
dims error$ = "" 					' Stores the error returned while saving.
dimi isAdvancedClicked = 0 			' Set to 1 when advanced button is clicked
dimi tempY,tempX 					' Loading label x and y
end

/***********************************************************
'** form_load
 *	Description: Fetch values for keyword from ini.htm.
 *				 Adjust all the controls based on screen resolution.
 *				 Fetch stream names and rtsp urls.
 *				 Create three video player to display all streams based on the aspect ratio
	
 *	Created by: Franklin  On 2009-05-15 05:54:01
 ***********************************************************/
sub form_load
	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	
	dimi gdoCurWidth, gdoCurHeight, gdoCurX, gdoCurY
	dimi drpCount
	dimi availableW
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	
	call loadStreamValues()						'to retrieve the stream values from the Live Video Options
	
	#frmSnap.w = (#btncancel.x+#btncancel.w) - #frmsnap.x + 10
	#frmSnap.h = (#btncancel.y +#btncancel.h)- #frmsnap.y + 10
	
	#lblheading$ = "Live Video > All Streams"
	
	dimi xRatio1,yRatio1,xRatio2,yRatio2,xRatio3,yRatio3
	
	loadStreamDetails(stream$,rtspUrl$)		' TR-04
	call addItemsToDropDown("ddstream", stream$, -1)		  'loads the stream to drop down       
	
	drpCount = #ddstream.itemcount
	
	if drpCount = 1 then
		settimer(0)
		loadurl("!liveVideo.frm&isINIValue=1")
	end if     
	
	calVideoDisplayRatio(#ddstream.itemlabel$(0),xRatio1,yRatio1)				' TR-04
		
	availableW = ~menuXRes - #imgleftmenu.w - 40
	
	gdoCurX = GDO_X1 
	gdoCurY = GDO_Y1 * ~factorY	
	availableW /= 2	
	
	gdoCurWidth = availableW 
	gdoCurHeight = (#imgmainbg.DESTH -25) - gdoCurY	
	checkAspectRatio(gdoCurWidth, gdoCurHeight,xRatio1,yRatio1)		
	createGDOControl("gdoVideo1", gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight)
	#lblcurstream1.x=gdoCurX
	#lblcurstream1.y=gdoCurY-(#lblcurstream1.h)-10	
	#gdobg1[0].x = gdoCurX-1
	#gdobg1[0].w = gdoCurWidth 
	#gdobg1[0].h = gdoCurHeight	                   
	gdoCurX = GDO_X2 * ~factorX
	gdoCurY = GDO_Y2 * ~factorY
	gdoCurWidth  = GDO_W2 * ~factorX
	gdoCurHeight = GDO_H2 * ~factorY
	iff drpCount>=2 then calVideoDisplayRatio(#ddstream.itemlabel$(1),xRatio2,yRatio2) 				' TR-04
	checkAspectRatio(gdoCurWidth,gdoCurHeight,xRatio2,yRatio2)
	createGDOControl("gdoVideo2", gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight)	
	#gdobg1[2].x = gdoCurX-1
	#gdobg1[2].w = gdoCurWidth 
	#gdobg1[2].h = gdoCurHeight	
	#lblcurstream2.x=gdoCurX
	#lblcurstream2.y=gdoCurY-(#lblcurstream2.h)-10
	
	gdoCurX = GDO_X3 * ~factorX
	gdoCurY = GDO_Y3 * ~factorY
	gdoCurWidth  = GDO_W3 * ~factorX
	gdoCurHeight = GDO_H3 * ~factorY
	iff drpCount=3 then calVideoDisplayRatio(#ddstream.itemlabel$(2),xRatio3,yRatio3)				' TR-04
	checkAspectRatio(gdoCurWidth, gdoCurHeight,xRatio3,yRatio3)
	gdoCurY=gdoCurY+10
	#gdobg1[1].y=gdoCurY-1
	createGDOControl("gdoVideo3", gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight)
	#gdobg1[1].x = gdoCurX-1
	#gdobg1[1].w = gdoCurWidth 
	#gdobg1[1].h = gdoCurHeight		
	#lblcurstream3.x=gdoCurX
	#lblcurstream3.y=gdoCurY-(#lblcurstream3.h)-10
	if ~loginAuthority = ADMIN or ~loginAuthority = OPERATOR then		
		showSubMenu(0,0)		
	endif
	
	if flagAudio=1 then 
		#imgaudio.src$="!audio_on.jpg"
	else
		#imgaudio.src$="!audio_off.jpg"
	endif
	
	'Display both the stream in same size for D1 streams
	if drpCount =  2 then		'TR-36
		dimi startPos,endPos
		dims streamRes1$,streamRes2$,streamVal$
		streamVal$ = #ddstream.itemlabel$(0)
		startPos = find(streamVal$,"(")
		endPos = find(streamVal$,")")
		streamRes1$ = mid$(streamVal$,startPos+1,endPos-startPos-1)
		streamVal$ = #ddstream.itemlabel$(1)
		startPos = find(streamVal$,"(")
		endPos = find(streamVal$,")")
		streamRes2$ = mid$(streamVal$,startPos+1,endPos-startPos-1)
		pprint streamRes1$;streamRes2$
		if streamRes1$ = streamRes2$ then			
			#gdoVideo2.w = #gdobg1[0].w
			#gdoVideo2.h = #gdobg1[0].h
			#gdoVideo2.y = #gdobg1[0].y
			#gdoVideo2.x = #gdobg1[0].x + #gdobg1[0].w + 20
			#gdobg1[2].w = #gdobg1[0].w
			#gdobg1[2].h = #gdobg1[0].h
			#gdobg1[2].y = #gdobg1[0].y
			#gdobg1[2].x =  #gdobg1[0].x + #gdobg1[0].w + 20
			#lblcurstream2.x=#gdobg1[2].x
			#lblcurstream2.y=#gdobg1[2].y -(#lblcurstream2.h)-10		
			#lblvideo1.x = #gdobg1[1].x	
			#lblvideo2.x = #gdobg1[2].x	
		end if 
	end if
	
	dims sdInsertVal$
	dimi findPos,sdInsert
	
	'Get SD card inserted value
	retVal =  getSDCardValue(sdInsertVal$)
		
	if retVal > 0  then
		findPos = find(sdInsertVal$,"sdinsert=")
		findPos += len("sdinsert=")
		sdInsert = atol(mid$(sdInsertVal$,findPos))		
	end if
		
	if sdInsert = 0 then
		#imgsdcard.hidden = 1
	end if
	
	blnCanGetAlarmStatus = 1	
End Sub

/***********************************************************
'** form_paint
 *	Description:  paint Gray image for storage options if click snap is selected.

 *	Created by: Franklin On 2009-05-14 11:43:56
 ***********************************************************/
sub form_paint()
	if #frmSnap.hidden=0	then
		putimage2(~optImage$,#optStorage[1].x,#optStorage[1].y,5,0,0)			'TR-28
		putimage2(~optImage$,#optStorage[2].x,#optStorage[2].y,5,0,0)			'TR-28
	end if
End Sub


/***********************************************************
'** Form_complete
 *	Description: Play all the rtsp urls in video player 
 
 *	Created by:Jacques Franklin  On 2009-03-13 13:02:28

 ***********************************************************/
Sub Form_complete
	~wait = 0	
	call disp_streams()
	call getPreviousScreen()
	toolTipPaintFlag = 1
	'update	   //commented by vimala
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
End Sub

/***********************************************************
'** getPreviousScreen
 *	Description: To store the previous screen and repaint the screen after showing 
        the tooltip

 *	Created by: Franklin Jacques.K  On 2009-09-23 12:59:03
 ***********************************************************/
sub getPreviousScreen
	getimage(prvScreen1$, #imgsnap.x+10, #imgsnap.y+TOOLTIP_HEIGHT+30, TOOLTIP_WIDTH1+10, TOOLTIP_HEIGHT+10)
	getimage(prvScreen2$, #imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH2+10,TOOLTIP_HEIGHT+10)
	getimage(prvScreen3$, #imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3+10,TOOLTIP_HEIGHT+10)
	getimage(prvScreen4$, #imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3+10,TOOLTIP_HEIGHT+10)
	getimage(prvScreen5$, #imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH4+10,TOOLTIP_HEIGHT+10)
End Sub


/***********************************************************
'** disp_streams
 *	Description: To set the URL for the video player GDO Control
				 rtspUrl$() - array : Hold all available rtsp stream values
				 
 *	Created by: Franklin Jacques  On 2009-07-31 19:01:44
 ***********************************************************/
sub disp_streams()
	~wait = 1
	dims value$
	dimi ret,a
	totActiveGDO = #ddstream.itemcount
	ret =  totActiveGDO
	
	if ret = 1 then
		
		if stream = 1 then
			displayallstreams = 1
			a = #gdovideo1.stop(1)
			value$ = rtspUrl$(0)      	  
			a = #gdovideo1.play(value$)
			call hideControl(0,1,1)                    'hide/show the required GDO control
			#lblcurstream1$=#ddstream.itemlabel$(0)				
		end if
		#lblcurstream1.hidden=0
		#lblcurstream2.hidden=1
		#lblcurstream3.hidden=1	
	elseif ret = 2 then
	
		if stream = 1 then
			value$ = rtspUrl$(0)   
			a = #gdovideo1.play(value$)
			call hideControl(0,1,1)    
		elseif stream = 2 then
			displayallstreams = 1
			value$ = rtspUrl$(1)   
			a = #gdovideo2.play(value$)
			call hideControl(0,0,1)
		end if
		#lblcurstream1$=#ddstream.itemlabel$(0)
		#lblcurstream2$=#ddstream.itemlabel$(1)
		#lblcurstream1.hidden=0
		#lblcurstream2.hidden=0
		#lblcurstream3.hidden=1
	elseif ret = 3 then
		
		if stream = 1 then
			value$ = rtspUrl$(0)   
			a = #gdovideo1.play(value$)
			call hideControl(0,1,1)  
		elseif stream = 2 then
			value$ = rtspUrl$(1)   
			a = #gdovideo2.play(value$)
			call hideControl(0,0,1)
		elseif stream = 3 then
			displayallstreams = 1
			value$ = rtspUrl$(2)   
			a = #gdovideo3.play(value$)
			call hideControl(0,0,0)
		end if	
		
		#lblcurstream1$=#ddstream.itemlabel$(0)
		#lblcurstream2$=#ddstream.itemlabel$(1)
		#lblcurstream3$=#ddstream.itemlabel$(2)
		#lblcurstream1.hidden=0
		#lblcurstream2.hidden=0
		#lblcurstream3.hidden=0
	endif
End Sub


/***********************************************************
'** hideControl
 *	Description: To hide the GDO controls 
		
 *	Params:
'*		dimi ctrl1: Numeric - value to be assigned to the 'hidden' property of the control(either 0 or 1)
'*		dimi ctrl2: Numeric - value to be assigned to the 'hidden' property of the control(either 0 or 1)
 *		dimi ctrl3 : Numeric - value to be assigned to the 'hidden' property of the control(either 0 or 1)
 *	Created by:  On 2009-07-30 17:34:52
 ***********************************************************/
sub hideControl(dimi ctrl1, dimi ctrl2, dimi ctrl3 )	
	#gdovideo1.hidden = ctrl1
	#gdovideo2.hidden = ctrl2
	#gdovideo3.hidden = ctrl3
	#gdobg1.hidden = ctrl1
	#gdobg1[1].hidden = ctrl3
	#gdobg1[2].hidden = ctrl2
	#lblvideo1.hidden = ctrl3
	#lblvideo2.hidden = ctrl2
	#lblvideo3.hidden = ctrl1	
End Sub

/***********************************************************
'** setAudioControl
 *	Description: Enable / Disable audio based on audio flag

 *	Created by: Franklin On 2009-04-09 15:28:30
 ***********************************************************/
sub setAudioControl()
	if flagAudio=1 then
		#gdoVideo1.Audio = 1
	elseif flagAudio=0 then
		#gdoVideo1.Audio = 0
	endif
End Sub


/***********************************************************
'** chkDispallstreams_Click
 *	Description: 
 *		     To load the liveVideo form when the check box is unchecked


 *	Created by: Franklin On 2009-03-17 20:05:08
 ***********************************************************/
Sub chkDispallstreams_Click	
	if canReload = 1 then
		iff ~wait <1 then return 
		loadurl("!liveVideo.frm&isINIValue=1")	
	else 
		#chkDispallstreams.checked = 1
	end if
End Sub


/***********************************************************
'** loadStreamValues
 *	Description: Load the stream name/Example into drop down box.
 *				 Load click snap user input values
 
 *	Created by: Partha Sarathi.K On 2009-03-17 18:43:53
 ***********************************************************/
sub loadStreamValues()
	
	dims clicksnapfilename$,democfgname$,ddValue$
	Dimi audioenable,clicksnapstorage,frecognition
	dimi ret	
	
        
    'Get stream names
    ret = getLiveVideoOptions(clicksnapfilename$,democfgname$,audioenable,_
							  clicksnapstorage,democfg,audiomode)
  
	if ret = -1 then
		msgbox("unable to fetch values")
		return
	endif
	
	flagAudio=audioenable
	iff flagAudio < 0 then flagAudio = 0
	
	'add stream name into drop down box	
	split(ddValue$,democfgname$,";")
	call addItemsToDropDown("ddExample", ddValue$, democfg)
	#txtSnapText$=clicksnapfilename$
	#optStorage$=clicksnapstorage
End Sub


/***********************************************************
'** form_Mouseclick
 *	Description:Call this function to return control window handle 
 *		
 *	Params:
'*		x: Numeric - X position
 *		y: Numeric - Y Position
 *	Created by:Jacques Franklin  On 2009-03-11 18:17:58
 *	History: 
 ***********************************************************/
sub form_Mouseclick(x,y)
	call getFocus()	
End Sub

/**************************************************************************
'** form_mousemove
 *	Description: Display Tool tip if click snap is not enabled
 *		
 *	Params:
'*		x: Numeric - X Position	
 *		y: Numeric - Y Position
 *	Created by:Jacques Franklin  On 2009-03-13 14:58:09

 ***************************************************************************/
sub form_mousemove(x,y)
	iff flagSnap=0 then call toolTip_mouseOver(x,y)
	MouseHandled(2)
End Sub


/***********************************************************
'** toolTip_mouseOver
 *	Description: Displays tool tip for the header icons
 *		
 *	Params:
'*		x: Numeric - Mouse move x value
 *		y: Numeric - Mouse move y value
 *	Created by:Jacques Franklin  On 2009-09-23 11:45:37
 ***********************************************************/
sub toolTip_mouseOver(x,y)
	if x>=#imgsnap.x and x<=(#imgsnap.x+#imgsnap.w) and y>=#imgsnap.y and y<=(#imgsnap.y+#imgsnap.h) then		
		DRAWRECT(#imgsnap.x+10,#imgsnap.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH1,TOOLTIP_HEIGHT,1,1,DISPLAY_REGION_BG,DISPLAY_REGION_BG)
		textout(#imgsnap.x+10,#imgsnap.y+TOOLTIP_HEIGHT+30,"Snapshot",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)		'TR-37
		paint(#imgsnap.x+10, #imgsnap.y+TOOLTIP_HEIGHT+30, TOOLTIP_WIDTH1, TOOLTIP_HEIGHT)
	elseif x>=#imgalarm.x and x<=(#imgalarm.x+#imgalarm.w) and y>=#imgalarm.y and y<=(#imgalarm.y+#imgalarm.h) then 
		DRAWRECT(#imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH2,TOOLTIP_HEIGHT,1,1,DISPLAY_REGION_BG,DISPLAY_REGION_BG)
		textout(#imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,"Alarm Status",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH2,TOOLTIP_HEIGHT)
	elseif x>=#imgrecord.x and x<=(#imgrecord.x+#imgrecord.w) and y>=#imgrecord.y and y<=(#imgrecord.y+#imgrecord.h) then
		DRAWRECT(#imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3,TOOLTIP_HEIGHT,1,1,DISPLAY_REGION_BG,DISPLAY_REGION_BG)
		textout(#imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,"Recording Status",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3,TOOLTIP_HEIGHT)
	elseif x>=#imgaudio.x and x<=(#imgaudio.x+#imgaudio.w) and y>=#imgaudio.y and y<=(#imgaudio.y+#imgaudio.h) then
		DRAWRECT(#imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3,TOOLTIP_HEIGHT,1,1,DISPLAY_REGION_BG,DISPLAY_REGION_BG)
		textout(#imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,"Toggle Audio",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3,TOOLTIP_HEIGHT)
	elseif #imgsdcard.hidden = 0 and x>=#imgsdcard.x and x<=(#imgsdcard.x+#imgsdcard.w) and y>=#imgsdcard.y and y<=(#imgsdcard.y+#imgsdcard.h) then		
		DRAWRECT(#imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH4,TOOLTIP_HEIGHT,1,1,DISPLAY_REGION_BG,DISPLAY_REGION_BG)
		textout(#imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,"SD Card",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH4,TOOLTIP_HEIGHT)
	else
		if toolTipPaintFlag = 1 then		
			putimage(prvScreen1$,#imgsnap.x+10,#imgsnap.y+TOOLTIP_HEIGHT+30,5,1)
			putimage(prvScreen2$,#imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,5,1)
			putimage(prvScreen3$,#imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,5,1)
			putimage(prvScreen4$,#imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,5,1)
			putimage(prvScreen5$,#imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,5,1)
			paint()
		end if
	endif 

End Sub

/***********************************************************
'** form_timer
 *	Description: To get the alarmstatus and display the 
				 alarm status
				 to set wait flag when switching between forms
				 
 *	Method: getAlarmStatus()
			displayAlarmStatus()

 *	Created by: Franklin  On 2009-03-13 17:03:05
 ***********************************************************/
Sub form_timer
	if displayallstreams = 0 then
		stream++
		call disp_streams()
		update()
	else
		~wait = 2
	end if
	
	if ~wait >= 2 then
		pprint ~wait
		#chkdispallstreams.disabled = 0 	'added by Franklin to set wait flag when switching between forms 
	endif
	
	if blnCanGetAlarmStatus = 1 then
		oldAlarmStaus$ = alarmstatus$
		getAlarmStatus(alarmstatus$)
		blnCanGetAlarmStatus = 0
	end if
	
	if canReload = 0 then
		if animateCount <= ~reLoadTime then
			animateCount ++
			animateLabel("lblvideo3","Loading")				'animate updating... value
		else
			call displaySaveStatus(saveSuccess)
		end if
	end if
End Sub

/***********************************************************
'** displayAlarmStatus
 *	Description: Based on the alarm status display the record and alarm status.

 *	Created by: Franklin On 2009-03-18 17:17:17
 *	History: Modified by Partha Sarathi.K
 ***********************************************************/
sub displayAlarmStatus()	
	dims Tempstatus$
	dimi AlarmData
	tempStatus$ = "0x" + alarmstatus$
	alarmData = StrToInt(tempStatus$)
	
	if ANDB(alarmData,0x0003) = 0 then
		#imgalarm.src$ = "!alarm_off.jpg"
	else
		#imgalarm.src$ = "!alarm_on.jpg"
	end if
	
	if ANDB(AlarmData,0x0004) = 0 then
		#imgrecord.src$ = "!record_2.jpg"
	else
		#imgrecord.src$ = "!record_1.jpg"
	end if
	
	#imgrecord.paint(1)
	#imgalarm.paint(1)
	
End Sub


/***********************************************************
'** Form_KeyPress
 *	Description: 
 *			To set wait flag before switching between forms	
			Checks entered key value based on the rule set to that user input control
 *		
 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by:  On 2009-07-16 14:13:53
 *	History: 
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )	
	if key = 26 or key = 25 then
		keyhandled(2)
	else
		keyhandled(0)
	endif
	
	if Key = 15 then
	iff ~wait<=1 then return
		~wait = 2
	endif
	
	scroll_keypressed(key) 	' Lock mouse scroll
	dims keypressed$
	keypressed$ = chr$(getkey())	
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)	
	setLeftMenuFocus(Key,0)	
End Sub



/***********************************************************
'** imgsnap_Click
 *	Description: 
 *				To set the snap image for the image control subsequent
				 to the snap flag
 *		
 *	Params:
 *	Created by: Franklin On 2009-07-16 14:15:31
 *	History: 
 ***********************************************************/
Sub imgsnap_Click	
	if canReload = 1 then
		if flagSnap=1 then
			flagSnap=0
			#frmSnap.hidden=1
			#imgsnap.src$ = "!snap_on.jpg"					'BFIX-07
			setfocus("imgalarm")
		elseif flagSnap=0 then
			flagSnap=1	
			#frmSnap.hidden=0	  
			#imgsnap.src$ = "!snap_off.jpg"					'BFIX-07
			#optStorage[1].disabled = 1						'TR-28
			#optStorage[2].disabled = 1						'TR-28
			#optStorage[1].fg=UNSELECTED_TXT_COLOR			'TR-28
			#optStorage[1].selfg=UNSELECTED_TXT_COLOR		'TR-28
			#optStorage[2].fg=UNSELECTED_TXT_COLOR			'TR-28
			#optStorage[2].selfg=UNSELECTED_TXT_COLOR		'TR-28	
			setfocus("txtsnaptext")
		endif
		showimages("imgsnap","!snap_on.jpg","!snap_off.jpg")
	end if
End Sub



/***********************************************************
'** imgaudio_Click
 *	Description: 
 *		To set the Audio image for the image control subsequent
		to the audio flag		

 *	Created by: Franklin Jacques On 2009-07-16 14:17:18

 ***********************************************************/
Sub imgaudio_Click
	if canReload = 1 then
		dimi a 	
		call stopPlaying
		sleep(1000)
		pprint audiomode
		if flagAudio=1 then
		  flagAudio=0
		  setAudioStatus(flagAudio,audiomode)
		  pprint flagAudio;
		elseif flagAudio=0 then
		  flagAudio=1	
		  setAudioStatus(flagAudio,audiomode)			  
		endif	
		displayallstreams = 0  
		stream = 0	      
		call disp_streams()	
		call setAudioControl
		
		showimages("imgaudio","!audio_on.jpg","!audio_off.jpg")
	end if
End Sub

/***********************************************************
'** stopPlaying
 *	Description: To stop all video in video player

 *	Created by:Franklin  On 2009-08-04 19:22:57
 ***********************************************************/
sub stopPlaying
	dimi a
	if totActiveGDO = 1 then
		a = #gdoVideo1.stop(1)
	elseif totActiveGDO = 2 then
		a = #gdoVideo1.stop(1)
		a = #gdoVideo2.stop(1)
	elseif totActiveGDO = 3 then
		a = #gdoVideo1.stop(1)
		a = #gdoVideo2.stop(1)
		a = #gdoVideo3.stop(1)
	endif

End Sub



' To set the showcursor property for the controls
Sub chkDispallstreams_Focus
	showcursor(1)
End Sub

Sub chkDispallstreams_Blur
	showcursor(3)
End Sub

Sub optStorage_Focus
	iff curfld$() = "optStorage" then showcursor(1)   'TR-28
End Sub

Sub optStorage_Blur
	showcursor(3)
End Sub


/***********************************************************
'** btnCancel_Click
 *	Description: 
 *				To hide the frame(frmsnap) and set the snap flag to zero
 *		
 *	Created by: Franklin Jacques.K  On 2009-07-16 14:19:37
 ***********************************************************/
Sub btnCancel_Click
	flagSnap=0
	#frmSnap.hidden=1
	setfocus("imgalarm")
	#imgsnap.src$ = "!snap_off.jpg"			'BFIX-07
End Sub



/***********************************************************
'** btnOk_Click
 *	Description: saves the values enter in snap frame controls.
 *	Created by:  On 2009-05-20 11:12:33
 *	History: 
 ***********************************************************/
Sub btnOk_Click
	dimi ret 
	ret = setLiveVideoOptions(#txtSnapText$, #optStorage)
	call imgsnap_Click	
End Sub


/***********************************************************
'** Form_Notify
 *	Description: Server Event Listeners are Notified here.
 *				 Continuously checks for Alarm and record status.

 *	Created by:  On 2010-04-30 16:07:59
 ***********************************************************/
Sub Form_Notify	
	dimi NotifySrc, NotifyData, ret
	dims Message$, MsgType$, optionValue$(2)
	NotifySrc=getmessage(NotifyData, MsgType$, Message$,"")	
	if NotifySrc = GNOTIFY_HTTP_DNLD_SUCCESS then		
		pprint "GNOTIFY_HTTP_DNLD_SUCCESS" + Message$
		ret = split(optionValue$, Message$ , "=")
		if ret > 1 then
			alarmStatus$ = trim$(optionValue$(1))
			if lcase$(oldAlarmStaus$) <> lcase$(alarmstatus$) then
				call displayAlarmStatus()
			endif
		endif
		blnCanGetAlarmStatus = 1
	elseif NotifySrc = GNOTIFY_HTTP_DNLD_FAILURE or NotifySrc = GNOTIFY_HTTP_DNLD_ABORTED then
		blnCanGetAlarmStatus = 1
	endif
End Sub


/***********************************************************
'** ddExample_Click
 *	Description: Get selected example value

 *	Created by: Vimala  On 2010-04-30 16:08:03

 ***********************************************************/
Sub ddExample_Click
	selExampleVal = #ddexample.selidx
End Sub




/***********************************************************
'** ddExample_Change
 *	Description: On changing the value selected, 
 *				 display a message and on confirmation should 
 *				 set the selected value  in the IPNC.
 
 *	Created by: Vimala  On 2009-12-15 00:30:25
 ***********************************************************/
Sub ddExample_Change						'TR-30	
	if canReload = 1 then
		iff selExampleVal = #ddexample.selidx then return
		dimi a
		call hideControl(1,1,1)	
		#lblcurstream1.hidden = 1
		#lblcurstream2.hidden = 1
		#lblcurstream3.hidden = 1		
		update
		msgbox("This will change the configuration to demo modes selected.\n Do you want to continue?",3)
		
		if confirm() = 1 then
			a = #gdovideo1.stop(1)
			a = #gdovideo2.stop(1)
			a = #gdovideo3.stop(1)
			#lblvideo3.hidden = 0 
			dimi retVal ,i
			retVal = setExampleValue(#ddexample)
			
			tempX = #lblvideo3.x
			tempY = #lblvideo3.y
			saveSuccess = retVal
			'Based on reload flag wait for the camera to restart
			if getReloadFlag() = 1 then									'TR-45
				
				#lblvideo3.x = #imgsnap.x
				#lblvideo3.y = #gdobg1.y 
				canReload = 0
				animateCount = 1
				call animateLabel("lblvideo3","Loading")
			else // If Reload animation is not required
				canReload = 1
			end if
		
			if canReload = 1 then	//Do the remaining actions after reload animation is done
				call displaySaveStatus(saveSuccess)		
			end if		
			
		else		
			#ddexample$ = democfg
			loadurl("!allStreamsVideo.frm&flagaudio="+flagaudio)
		end if	
	end if
	
End Sub


/***********************************************************
'** displaySaveStatus
 *	Description: Call this function to display save status message
 
 *	Params:
 *		saveStatus: Numeric - Greater then 1 for success ,0 for failure message 
 *	Created by: Vimala On 2010-06-25 12:00:34
 *	History: 
 ***********************************************************/
Sub displaySaveStatus(saveStatus)
	if saveStatus > 0 then
		msgbox("Modified Demo Mode for camera "+~title$)
	else		
		msgbox("Demo Mode failed for the camera "+~title$)		
	endif
	
	loadurl("!allStreamsVideo.frm&flagaudio="+flagaudio)
End Sub

/***********************************************************
'** txtsnaptext_focus
 *	Description: To set focus for the control
 
 *	Created by:Franklin On 2010-04-30 16:09:23

 ***********************************************************/
Sub txtsnaptext_focus		
	rule = 3
	showcursor(3)
End Sub


Sub savePage()
	'Please don't delete
End Sub

sub chkValueMismatch()	
	'Please don't delete
End Sub


/***********************************************************
'** imgsdCard_Click
 *	Description: Load SD Card explorer screen
 
 *	Created by:Vimala On 2010-05-13 10:46:04
 ***********************************************************/
Sub imgsdCard_Click
	if canReload = 1 then
		loadurl("!SDExplorer.frm")	
	end if
End Sub
