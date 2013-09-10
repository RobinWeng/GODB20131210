/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Live Video                                                  *
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
Displays live video
*/

pprint "livevideo playing"
option(4+1)
dimi timerCount				  'Used to animate Loading.... value    'TR-30
#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"
#define TOOLTIP_TXT_STYLE        8
#define TOOLTIP_TXT_FG           55038
#define TOOLTIP_TXT_BG           6440
#define TOOLTIP_TXT_FONT         2

#define TOOLTIP_WIDTH1           80 
#define TOOLTIP_WIDTH2           100
#define TOOLTIP_WIDTH3           120 
#define TOOLTIP_WIDTH4           80 
#define TOOLTIP_HEIGHT           20

#define GDO_X1			   258	
#define GDO_Y1			   190

#define GDO_X2			   553	
#define GDO_Y2			   190		

#define GDO_X3			   258	
#define GDO_Y3			   420	

#define GDO_X4			   553	
#define GDO_Y4			   420	

#define GDO_W              270
#define GDO_H              220

#define GNOTIFY_HTTP_DNLD_FAILURE 40 
#define GNOTIFY_HTTP_DNLD_SUCCESS 41 
#define GNOTIFY_HTTP_DNLD_ABORTED 45 

option(4+1)
dimi previousIndex=-1										'store the dropdown's prevous selIDX
Dimi flagAudio=1                                        	'set the flag to enable/disable the audio
dimi flagAllstreams=0    									'set flag to display all streams                                   
dimi flagSnap=0            									'set the flag to hide/show the frmSnap(Frame)                                                            
Dims alarmstatus$ = "0000"                               	'set the alarm status initially
dims oldAlarmStaus$		                                    'to store the previous alarm status
Dimi imgsnapFlag											'to check the imgAudio Control Click event is called

dimi ~yutangoFlag=0

dimi noofctrl													'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS 
pprint  "noofctrl="+noofctrl
pprint "getfldcount()="+getfldcount()                     
dims LabelName$(noofctrl)                                       'Form controls name
dimi XPos(noofctrl)                                             'Form controls X position
dimi YPos(noofctrl)                                             'Form controls Y position
dimi Wdh(noofctrl)                                              'Form controls Width position
dimi height(noofctrl)                                           'Form controls height position
                                                         
#include "liveVideo.inc"

settimer(1000)												    'to enable timer for 1 second
showcursor(3)
dimi rule
'#chkdispallstreams.disabled = 1
Dimi xRatio,yRatio
dims ~previewVideoRes$
Dims prvscreen1$,prvscreen2$,prvscreen3$,prvscreen4$,prvScreen5$,prvScreen6$,prvScreen7$		'capture previous screen before showing tooltip
dimi toolTipPaintFlag = 0
Dims stream$(4),rtspUrl$(4)
dims yuntai$(4),streamOption$(5)   'add by hst
'dimi yuntaichannel
Dimi ddstreamNo
ddstreamNo = atol(request$("ddstreamNo"))
Dimi disp1xFlag
disp1xFlag = atol(request$("disp1xFlag"))
dimi democfg                 									 'Example drop down selected value     'TR-30
dims ~videoPlayerVersion$	 									 'Video Player Version					'TR-32
dimi blnCanGetAlarmStatus
dimi selExampleVal
dimi selChannelVal =0
dimi selStreamVal =0
dims responeData$
dims prop$
dimi ret
dimi audiomode													  'Holds audio mode
dimi saveSuccess = 0	 			'Value of 1 is success
dimi animateCount = 0 	 			' Stores the count for the animation done.
dims error$ = "" 					'Stores the error returned while saving.
dims presetOption$(21)     'add by wbb for yuzhiwei
dimi selPresetVal
dims yuntairesponData$
dims note$(21)
end

/***********************************************************
'** form_load
 *	Description: Align all the controls based on resolution
 *		         Fetch all keyword from ini.htm
 *				 Call the LoadStreamValue Function, to load the stream name into drop down box.
 *				 Create video player(GDO) to display video.
 *	Created by: Franklin Jacques On 2009-05-19 15:54:31
 ***********************************************************/
sub form_load	
	
	dimi retVal	
	dims sdInsertVal$
	dimi findPos,sdInsert
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)   'note by hst 
	
	#frmSnap.w = (#btncancel.x+#btncancel.w) - #frmsnap.x + 10
	#frmSnap.h = (#btncancel.y +#btncancel.h)- #frmsnap.y + 10
		
	call getINIValus()	
	call loadStreamValues()   //Load the stream name/Example into drop down box.
	
	getReloadTime()   'TR-40 Call this function to get the camera restart time 

	
	assignSelectedImage("imgmenu")
	setfocus("imgmenu")
	if ~loginAuthority = ADMIN or ~loginAuthority = OPERATOR then		
		showSubMenu(0,0)		
	endif
'	setfocus("ddstream")		
	
	'Get stream name and rtsp url from camera
	loadStreamDetails(stream$,rtspUrl$)			'TR-04
	pprint rtspUrl$(0);rtspUrl$(1);rtspUrl$(2),rtspUrl$(3)
	if stream$(0) = "" then
		msgbox "Streams not available"
		loadurl("!auth.frm")
	end if	
	
	'Loads the stream to drop down 
'	call addItemsToDropDown("ddstream", stream$, -1)	
	
'	for dimi i=0 to 3
	yuntai$=("1","2","3","4")
	yuntai$(0)="1"
	yuntai$(1)="2"
	yuntai$(2)="3"
	yuntai$(3)="4"
	
	selChannelVal=0;
	
	call addItemsToDropDown("channelNum", yuntai$, -1)	'add by hst
	
	streamOption$=("所有流","1","2","3","4")
	'call addItemsToDropDown("streamChannel", streamOption$, -1)	'add by hst
	
	presetOption$=("NULL","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19")                   'add by wbb for yuzhiwei
	call addItemsToDropDown("yuzhidian",presetOption$,-1) 'add by wbb
	
//	note$=("NULL","NULL","NULL","NULL","NULL","NULL")
	
	if disp1xFlag = 1 then 
		//#ddstream$=ddstreamNo   
		#RadstreamChannel[2].checked=1
		RadstreamChannel_Click
		
	endif
/*

msgbox(~menuXRes)//1364
	msgbox(~menuYRes)//712

	dimi gvideoX,gvideoY
	dimi availablew,availableH

	gvideoX=#imgmainbg.x+15 * ~factorX
	gvideoY=#gdobg1.y
	
	availableW = #imgjjd.x - #imgleftmenu.w - 40
	availableH = ~menuYRes-#frmSnap.y-#frmSnap.h-40
	
	msgbox(availableW)
	msgbox(availableH)

	dimi gvideoX1,gvideoY1,gvideoX2,gvideoY2,gvideoX3,gvideoY3,gvideoX4,gvideoY4
	
	gvideoX1=gvideoX
	gvideoY1=gvideoY

	gvideoX2=gvideoX1+availablew/2+2
	gvideoY2=gvideoy1

	gvideoX3=gvideoX
	gvideoY3=gvideoY1+availableH/2+2

	gvideoX4=gvideoX1+availablew/2+2
	gvideoY4=gvideoY1+availableH/2+2


	createGDOControl("gdoVideo1",gvideoX1,gvideoY1,availableW/2,availableH/2)
	createGDOControl("gdoVideo2",gvideoX2,gvideoY2,availableW/2,availableH/2)
	createGDOControl("gdoVideo3",gvideoX3,gvideoY3,availableW/2,availableH/2)
	createGDOControl("gdoVideo4",gvideoX4,gvideoY4,availableW/2,availableH/2)

	msgbox("1233321")
		msgbox("1233321")
	'create video player(GDO) to display video.	

'	createGDOControl("gdoVideo1",#gdobg1.x,#gdobg1.y,#gdobg1.w,#gdobg1.h)
'	createGDOControl("gdoVideo2",#gdobg2.x,#gdobg2.y,#gdobg2.w,#gdobg2.h)
'	createGDOControl("gdoVideo3",#gdobg3.x,#gdobg3.y,#gdobg3.w,#gdobg3.h)
'	createGDOControl("gdoVideo4",#gdobg4.x,#gdobg4.y,#gdobg4.w,#gdobg4.h)
	createGDOControl("gdoVideo5",#gdobg5.x,#gdobg5.y,#gdobg5.w,#gdobg5.h)

	
	#gdobg5.hidden=1
	#gdoVideo5.hidden=1

	//hst



	
	dimi tempx,tempy,tempw,temph;
	
	calVideoDisplayRatio("(352x240)",xRatio,yRatio)				' TR-04
	

	
	tempx=gvideoX1
	tempy=gvideoY1
	tempw=availableW/2
	temph=availableH/2
	
	checkAspectRatio(tempw, temph,xRatio,yRatio)
	
	#gdobg1.x=tempx-1
	#gdobg1.y=tempy-1
	#gdobg1.w = tempw+1 
	#gdobg1.h = temph+1	

	#gdoVideo1.x = tempx
	#gdoVideo1.y = tempy
	#gdoVideo1.w = tempw
	#gdoVideo1.h = temph



	tempx=gvideoX2
	tempy=gvideoY2
	tempw=availableW/2
	temph=availableH/2
	
	checkAspectRatio(tempw, temph,xRatio,yRatio)
	
	#gdobg2.x=tempx-1
	#gdobg2.y=tempy-1
	#gdobg2.w = tempw+1 
	#gdobg2.h = temph+1	

	#gdoVideo2.x = tempx
	#gdoVideo2.y = tempy
	#gdoVideo2.w = tempw
	#gdoVideo2.h = temph



	tempx=gvideoX3
	tempy=gvideoY3
	tempw=availableW/2
	temph=availableH/2
	
	checkAspectRatio(tempw, temph,xRatio,yRatio)
	
	#gdobg3.x=tempx-1
	#gdobg3.y=tempy-1
	#gdobg3.w = tempw+1 
	#gdobg3.h = temph+1	

	#gdoVideo3.x = tempx
	#gdoVideo3.y = tempy
	#gdoVideo3.w = tempw
	#gdoVideo3.h = temph
	




	tempx=gvideoX4
	tempy=gvideoY4
	tempw=availableW/2
	temph=availableH/2
	
	checkAspectRatio(tempw, temph,xRatio,yRatio)
	
	#gdobg4.x=tempx-1
	#gdobg4.y=tempy-1
	#gdobg4.w = tempw+1 
	#gdobg4.h = temph+1	

	#gdoVideo4.x = tempx
	#gdoVideo4.y = tempy
	#gdoVideo4.w = tempw
	#gdoVideo4.h = temph

	*/


'	msgbox(~menuXRes)
'	msgbox(~menuYRes)
	
	dimi availablew,availableH

	availableW = ~menuXRes - #imgleftmenu.w - 40-#imgjjd.x
	availableH = ~menuYRes-#frmSnap.y-#frmSnap.h-40
'	msgbox(availableW)
'	msgbox(availableH)

'	createGDOControl("gdoVideo1",#gdobg1.x,#gdobg1.y,availableW,availableH)


	'create video player(GDO) to display video.	

	createGDOControl("gdoVideo1",#gdobg1.x,#gdobg1.y,#gdobg1.w,#gdobg1.h)
	createGDOControl("gdoVideo2",#gdobg2.x,#gdobg2.y,#gdobg2.w,#gdobg2.h)
	createGDOControl("gdoVideo3",#gdobg3.x,#gdobg3.y,#gdobg3.w,#gdobg3.h)
	createGDOControl("gdoVideo4",#gdobg4.x,#gdobg4.y,#gdobg4.w,#gdobg4.h)
	createGDOControl("gdoVideo5",#gdobg5.x,#gdobg5.y,#gdobg5.w,#gdobg5.h)

	
	#gdobg5.hidden=1
	#gdoVideo5.hidden=1

	//hst



	
	dimi tempx,tempy,tempw,temph;
	
	calVideoDisplayRatio("(352x240)",xRatio,yRatio)				' TR-04
	

	
	tempx=#gdobg1.x
	tempy=#gdobg1.y
//	tempw=#gdobg1.w
//	temph=#gdobg1.h

	tempw=(getxres()-260)/2
	temph=(getyres()-200 * ~factorY )/2
	
	
	
	checkAspectRatio(tempw, temph,xRatio,yRatio)
	pprint "tempx==============="+tempx,tempy,tempw,temph
	tempx=250
	tempy=#gdobg1.y	


	#gdoVideo1.x = tempx
	#gdoVideo1.y = tempy
	#gdoVideo1.w = tempw
	#gdoVideo1.h = temph
	
	#gdobg1.x=tempx-1
	#gdobg1.y=tempy-1
	#gdobg1.w = tempw+1 
	#gdobg1.h = temph+1	


	tempx=#gdobg2.x
	tempy=#gdobg2.y
//	tempw=#gdobg2.w
//	temph=#gdobg2.h

	tempw=(getxres()-260)/2
	temph=(getyres()-202 * ~factorY )/2
	
	checkAspectRatio(tempw, temph,xRatio,yRatio)

//	tempx=getxres()-tempw-10
	tempx=#gdobg1.x+10+tempw
	tempy=#gdobg1.y	
	#gdobg2.x=tempx-1
	#gdobg2.y=tempy-1
	#gdobg2.w = tempw+1 
	#gdobg2.h = temph+1	

	#gdoVideo2.x = tempx
	#gdoVideo2.y = tempy
	#gdoVideo2.w = tempw
	#gdoVideo2.h = temph



	tempx=#gdobg3.x
	tempy=#gdobg3.y
//	tempw=#gdobg3.w
//	temph=#gdobg3.h

	tempw=(getxres()-260)/2
	temph=(getyres()-202 * ~factorY )/2
	
	checkAspectRatio(tempw, temph,xRatio,yRatio)

	tempx=250
	tempy=#gdobg1.y+temph+10
	#gdobg3.x=tempx-1
	#gdobg3.y=tempy-1
	#gdobg3.w = tempw+1 
	#gdobg3.h = temph+1	

	#gdoVideo3.x = tempx
	#gdoVideo3.y = tempy
	#gdoVideo3.w = tempw
	#gdoVideo3.h = temph
	




	tempx=#gdobg4.x
	tempy=#gdobg4.y
//	tempw=#gdobg4.w
//	temph=#gdobg4.h
	
	tempw=(getxres()-260)/2
	temph=(getyres()-202 * ~factorY )/2	
	
	checkAspectRatio(tempw, temph,xRatio,yRatio)
//	tempx=getxres()-tempw-10

	tempx=#gdobg3.x+10+tempw
	tempy=#gdobg1.y+temph+10	
	#gdobg4.x=tempx-1
	#gdobg4.y=tempy-1
	#gdobg4.w = tempw+1 
	#gdobg4.h = temph+1	

	#gdoVideo4.x = tempx
	#gdoVideo4.y = tempy
	#gdoVideo4.w = tempw
	#gdoVideo4.h = temph

	
	/* 2013.3.14 by mayue */
	tempx=#gdobg5.x
	tempy=#gdobg5.y
//	tempw=#gdobg5.w
//	temph=#gdobg5.h
	tempw=(getxres()-250)
	temph=(getyres()-300)
	
	checkAspectRatio(tempw, temph,xRatio,yRatio)
	tempx=280
	tempy=#gdobg1.y	
	#gdobg5.x=tempx-1
	#gdobg5.y=tempy-1
	#gdobg5.w = tempw+1 
	#gdobg5.h = temph+1 
	#gdoVideo5.x = tempx
	#gdoVideo5.y = tempy
	#gdoVideo5.w = tempw
	#gdoVideo5.h = temph
	/* 2013.3.14 by mayue end */

'	#gdoVideo1.paint(1)
'	#gdobg1.paint(1)

	
'	createGDOControl("gdoVideo1",#gdobg1.x,#gdobg1.y,0,0)
'	createGDOControl("gdoVideo2",#gdobg2.x,#gdobg2.y,0,0)
'	createGDOControl("gdoVideo3",#gdobg3.x,#gdobg3.y,0,0)
'	createGDOControl("gdoVideo4",#gdobg4.x,#gdobg4.y,0,0)
	
	'Get aspect ratio for the selected stream
'	calVideoDisplayRatio(#ddstream.itemlabel$(#ddstream.selidx),xRatio,yRatio)		'TR-04 
'	calVideoDisplayRatio("(352*240)",xRatio,yRatio)		'TR-04 
'	~previewVideoRes$ = #ddstream.itemlabel$(0)
	
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
	
	'Get video player version 
	~videoPlayerVersion$ = #gdovideo1.version$
	blnCanGetAlarmStatus = 1
	
'	#chkDispallstreams.hidden = 1

	LoadDownNotes(selChannelVal)
	
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


/***********************************************************
'** Form_paint
 *	Description: paint Gray image for storage options if click snap is selected.
 
 *	Created by: Franklin Jacques.K On 2009-03-11 16:00:49
 ***********************************************************/
sub Form_paint()
	if #frmSnap.hidden=0	then
		putimage2(~optImage$,#optStorage[1].x,#optStorage[1].y,5,0,0)			'TR-28
		putimage2(~optImage$,#optStorage[2].x,#optStorage[2].y,5,0,0)			'TR-28
	end if
End Sub



/***********************************************************
'** setAudioControl
 *	Description: Enable/Disable audio for video player
 
 *	Created by:Franklin  On 2009-03-23 17:40:14
 ***********************************************************/
sub setAudioControl
		
	if flagAudio=1 then
		#gdovideo1.Audio=1
	elseif flagAudio=0 then
		#gdovideo1.Audio=0
	endif
	
	'#gdoVideo.hidden=0		
	'#lblLoad.hidden=1	
End Sub

/***********************************************************
'** loadStreamValues
 *	Description: Load the stream name/Example into drop down box.
 *				 Load click snap user input values

 *	Created by: Partha Sarathi.K On 2009-03-17 18:43:53
 ***********************************************************/
sub loadStreamValues()
	
	Dims clicksnapfilename$,democfgname$,ddValue$
	Dimi audioenable,clicksnapstorage,frecognition
	dimi ret
        
    'Get values keyword values
	ret = getLiveVideoOptions(clicksnapfilename$,democfgname$,audioenable,_
							  clicksnapstorage,democfg,audiomode)
	
	if ret = -1 then
		msgbox("unable to fetch values")
		return
	endif
	
	flagAudio=audioenable
	iff flagAudio < 0 then flagAudio = 0
	
	'display audio on image if audio is on, if not off image.
	if flagAudio=1 then 
		#imgaudio.src$="!audio_on.jpg"
	else
		#imgaudio.src$="!audio_off.jpg"
	endif
	
	split(ddValue$,democfgname$,";")
'	call addItemsToDropDown("ddExample", ddValue$, democfg)
	#txtSnapText$=clicksnapfilename$
	#optStorage$=clicksnapstorage
End Sub


/***********************************************************
'** form_Mouseclick
 *	Description:  Call this function to return control window handle 
 	
 *	Params:
'*		x: Numeric - X Position
 *		y: Numeric - Y Position 
 *	Created by:Jacques Franklin  On 2009-03-11 18:17:58
 *	History: 
 ***********************************************************/
sub form_Mouseclick(x,y)
	call getFocus()	
	
	dimi Tempx,Tempy,spaceX,spaceY;
	
	spaceX=INT(#imgyuntai.w/3)
	spaceY=INT(#imgyuntai.h/3)
	
	Tempx=#imgyuntai.x
	Tempy=#imgyuntai.y
	
	if  x > Tempx And y > Tempy And x < Tempx+spaceX And y < Tempy+spaceY then
		'msgbox("111111111111")
		'leftabove
		
		prop$="leftup@"+selChannelVal
'		msgbox(prop$)
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
		
		~yutangoFlag=1
	elseif  x > Tempx+spaceX And y > Tempy And x < Tempx+2*spaceX And y < Tempy+spaceY then
		'msgbox("2222222222222")
		'above
		
		prop$="up@"+selChannelVal
'		msgbox(prop$)
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
		~yutangoFlag=1
	elseif  x > Tempx+2*spaceX And y > Tempy And x < Tempx+3*spaceX And y < Tempy+spaceY then
		'msgbox("33333333333333")
		'rightabove
		prop$="rightup@"+selChannelVal
'		msgbox(prop$)
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
		~yutangoFlag=1
	elseif x > Tempx And y > Tempy+spaceY And x < Tempx+spaceX And y < Tempy+2*spaceY then
		prop$="left@"+selChannelVal
'		msgbox(prop$)
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
		~yutangoFlag=1
		'msgbox("44444444")
		'left
	elseif x > Tempx+spaceX And y > Tempy+spaceY And x < Tempx+2*spaceX And y < Tempy+2*spaceY then
		prop$="rotate@"+selChannelVal
'		msgbox(prop$)
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
		~yutangoFlag=1
		'msgbox("5555555555")
		'rotate
	elseif x > Tempx+2*spaceX And y > Tempy+spaceY And x < Tempx+3*spaceX And y < Tempy+2*spaceY then	
		prop$="right@"+selChannelVal
'		msgbox(prop$)
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
		~yutangoFlag=1
		'msgbox("6666666666")
		'right
	elseif x > Tempx And y > Tempy+2*spaceY And x < Tempx+spaceX And y < Tempy+3*spaceY then
		prop$="leftdown@"+selChannelVal
'		msgbox(prop$)
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
		~yutangoFlag=1
		'msgbox("777777777777")
		'leftbelow
	elseif x > Tempx+spaceX And y > Tempy+2*spaceY And x < Tempx+2*spaceX And y < Tempy+3*spaceY then
		prop$="down@"+selChannelVal
'		msgbox(prop$)
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
		~yutangoFlag=1
		'msgbox("88888888888")
		'below	
	elseif x > Tempx+2*spaceX And y > Tempy+2*spaceY And x < Tempx+3*spaceX And y < Tempy+3*spaceY then
		'msgbox("99999999")
		'leftbelow
		prop$="rightdown@"+selChannelVal
'		msgbox(prop$)
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
		~yutangoFlag=1
	endif
	
//	MOUSEHANDLED(1)
End Sub


/**************************************************************************
'** form_mousemove
 *	Description: Display Tool tip if click snap is not enabled
 
 *	Params:
'*		x: Numeric - X Position
 *		y: Numeric - Y Position
 *	Created by:Jacques Franklin  On 2009-03-13 14:58:09
 ***************************************************************************/

/******delete by wbb ,this function will be use in the future
sub form_mousemove(x,y)
	iff flagSnap=0 then call toolTip_mouseOver(x,y)
	MouseHandled(2)	
End Sub

********/
/***********************************************************
'** toolTip_mouseOver
 *	Description: Displays tool tip for the header icons
 		
 *	Params:
'*		x: Numeric - Mouse move x value
 *		y: Numeric - Mouse move y value
 *	Created by:Jacques Franklin  On 2009-09-23 11:45:37
 *	History: 
 ***********************************************************/
sub toolTip_mouseOver(x,y)
	if x>=#imgplayrecord.x and x<=(#imgplayrecord.x+#imgplayrecord.w) and y>=#imgplayrecord.y and y<=(#imgplayrecord.y+#imgplayrecord.h) then					'TR-13
		DRAWRECT(#imgplayrecord.x,#imgplayrecord.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH1+60,TOOLTIP_HEIGHT,1,1,TOOLTIP_TXT_BG,TOOLTIP_TXT_BG)
		textout(#imgplayrecord.x,#imgplayrecord.y+TOOLTIP_HEIGHT+30,"视频录制",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgplayrecord.x, #imgplayrecord.y+TOOLTIP_HEIGHT+30, TOOLTIP_WIDTH1+60, TOOLTIP_HEIGHT)
/*  delete by wbb
	elseif x>=#imgDisplay1x.x and x<=(#imgDisplay1x.x+#imgDisplay1x.w) and y>=#imgDisplay1x.y and y<=(#imgDisplay1x.y+#imgDisplay1x.h) then					'TR-13
		DRAWRECT(#imgDisplay1x.x,#imgDisplay1x.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH1+60,TOOLTIP_HEIGHT,1,1,TOOLTIP_TXT_BG,TOOLTIP_TXT_BG)
		textout(#imgDisplay1x.x,#imgDisplay1x.y+TOOLTIP_HEIGHT+30,"全屏播放",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgDisplay1x.x, #imgDisplay1x.y+TOOLTIP_HEIGHT+30, TOOLTIP_WIDTH1+60, TOOLTIP_HEIGHT)
*/
	elseif x>=#imgsnap.x and x<=(#imgsnap.x+#imgsnap.w) and y>=#imgsnap.y and y<=(#imgsnap.y+#imgsnap.h) then		
		DRAWRECT(#imgsnap.x+10,#imgsnap.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH1,TOOLTIP_HEIGHT,1,1,TOOLTIP_TXT_BG,TOOLTIP_TXT_BG)
		textout(#imgsnap.x+10,#imgsnap.y+TOOLTIP_HEIGHT+30,"快照",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)					'TR-37
		paint(#imgsnap.x+10, #imgsnap.y+TOOLTIP_HEIGHT+30, TOOLTIP_WIDTH1, TOOLTIP_HEIGHT)
	elseif x>=#imgalarm.x and x<=(#imgalarm.x+#imgalarm.w) and y>=#imgalarm.y and y<=(#imgalarm.y+#imgalarm.h) then 		
		DRAWRECT(#imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH2,TOOLTIP_HEIGHT,1,1,TOOLTIP_TXT_BG,TOOLTIP_TXT_BG)
		textout(#imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,"报警",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH2,TOOLTIP_HEIGHT)
	elseif x>=#imgrecord.x and x<=(#imgrecord.x+#imgrecord.w) and y>=#imgrecord.y and y<=(#imgrecord.y+#imgrecord.h) then		
		DRAWRECT(#imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3,TOOLTIP_HEIGHT,1,1,TOOLTIP_TXT_BG,TOOLTIP_TXT_BG)
		textout(#imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,"录制",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3,TOOLTIP_HEIGHT)
	elseif x>=#imgaudio.x and x<=(#imgaudio.x+#imgaudio.w) and y>=#imgaudio.y and y<=(#imgaudio.y+#imgaudio.h) then		
		DRAWRECT(#imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3,TOOLTIP_HEIGHT,1,1,TOOLTIP_TXT_BG,TOOLTIP_TXT_BG)
		textout(#imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,"音频",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3,TOOLTIP_HEIGHT)
	elseif #imgsdcard.hidden = 0 and x>=#imgsdcard.x and x<=(#imgsdcard.x+#imgsdcard.w) and y>=#imgsdcard.y and y<=(#imgsdcard.y+#imgsdcard.h) then		
		DRAWRECT(#imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH4,TOOLTIP_HEIGHT,1,1,TOOLTIP_TXT_BG,TOOLTIP_TXT_BG)
		textout(#imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,"SD�",TOOLTIP_TXT_STYLE,TOOLTIP_TXT_FG,TOOLTIP_TXT_FONT)
		paint(#imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH4,TOOLTIP_HEIGHT)
	else
		if toolTipPaintFlag = 1 then	
			putimage(prvScreen1$,#imgplayrecord.x,#imgplayrecord.y+TOOLTIP_HEIGHT+30,5,1)		
			putimage(prvScreen2$,#imgsnap.x+10,#imgsnap.y+TOOLTIP_HEIGHT+30,5,1)
			putimage(prvScreen3$,#imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,5,1)
			putimage(prvScreen4$,#imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,5,1)
			putimage(prvScreen5$,#imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,5,1)
			putimage(prvScreen6$,#imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,5,1)
//			putimage(prvScreen7$,#imgDisplay1x.x,#imgDisplay1x.y+TOOLTIP_HEIGHT+30,5,1)			'TR-13  delete by wbb
			paint()
		end if
	endif 
	
End Sub


/***********************************************************
'** chkDispallstreams_Click
 *	Description: 
 *		check box click event to load allStreamsVideo.frm

 *	Created by: Franklin On 2009-03-12 15:04:26
 ***********************************************************/
Sub chkDispallstreams_Click
	if canReload = 1 then
		#chkDispallstreams.checked = 1
		if flagAllstreams=0 then
			flagAllstreams=1
		elseif flagAllstreams=1 then
			flagAllstreams=0
		endif
		iff ~wait <1 then return 
		loadurl("!allStreamsVideo.frm&flagaudio="+flagaudio)
	else 
		#chkDispallstreams.checked = 0
	end if	
End Sub

/***********************************************************
'** form_timer
 *	Description: To get the alarmstatus and display the 
				 alarm status
				 to set wait flag when switching between forms
 *	Method: getAlarmStatus()
			displayAlarmStatus()

 *	Created by: Franklin  On 2009-03-13 17:03:05
 *	History: 
 ***********************************************************/
Sub form_timer
	~wait = ~wait +1									'added by Franklin to set wait flag when switching between forms
'	iff ~wait > 1 then #chkdispallstreams.disabled = 0  'added by Franklin to set wait flag when switching between forms
	if blnCanGetAlarmStatus = 1 then
		oldAlarmStaus$ = alarmstatus$
		getAlarmStatus(alarmstatus$)
		blnCanGetAlarmStatus = 0		
	end if
	
	if canReload = 0 then
		if animateCount <= ~reLoadTime then
			animateCount ++
			animateLabel("lblload","Loading")				'animate updating... value
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
'** imgsnap_Click
 *	Description: Hide snap frame if flagSnap is set.
 *				 show snap frame if flagSnap is not set.
 *	Created by: Franklin  On 2009-06-09 18:44:25
 *	History: 
 ***********************************************************/
Sub imgsnap_Click
	pprint "imgsnap_Click begin"
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
	pprint "imgsnap_Click end"
End Sub


/***********************************************************
'** imgaudio_Click
 *	Description: To set the audio flag and toggle the image 
				 subsequent to the audio flag
 *		
 *		
 *	Params:
 *	Created by: Franklin On 2009-07-16 12:59:37
 *	History: 
 ***********************************************************/
Sub imgaudio_Click
	if canReload = 1 then
		dimi a	
		'Stop video before enable/disable audio
		a = #gdovideo.stop(1)
		sleep(1000)
		imgsnapFlag=1
		if flagAudio=1 then
		  flagAudio=0
		  pprint audiomode
		  setAudioStatus(flagAudio,audiomode)
		elseif flagAudio=0 then
		  flagAudio=1
		  setAudioStatus(flagAudio,audiomode)	
		endif		
				
		call setAudioControl
		call disp_streams
		showimages("imgaudio","!audio_on.jpg","!audio_off.jpg")
	end if
End Sub


' To set the showcursor for the controls
Sub chkDispallstreams_Blur
	showcursor(3)
End Sub

Sub chkDispallstreams_Focus
	showcursor(1)
End Sub

Sub optStorage_Blur
	showcursor(3)
End Sub


Sub optStorage_Focus	
	iff curfld$() = "optStorage" then showcursor(1)   'TR-28
End Sub

/***********************************************************
'** btnCancel_Click
 *	Description: Hide the snap frame
 *	Created by:  On 2009-05-20 11:36:38
 *	History: 
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
	pprint "btnOk-click"
	call imgsnap_Click	
End Sub


/***********************************************************
'** Form_KeyPress
 *	Description: 
			To set wait flag before switching between forms	
			Checks entered key value based on the rule set to that user input control
 *		
 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by : Partha Sarathi.K On 2009-03-04 14:04:47
	Modified by: Jacques Franklin On 2009-03-25 11:53:50

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
	
	scroll_keypressed(key) 		' Lock mouse scroll
	dims keypressed$
	keypressed$ = chr$(getkey())	
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)	
	setLeftMenuFocus(Key,0)
End Sub


/***********************************************************
'** form_complete
 *	Description: Resize video as per the aspect ratio of the stream
 *		    	 and set the video player properties
 
 *	Created by: Franklin Jacques On 2009-03-19 10:40:02
 ***********************************************************/
sub form_complete
	~wait = 0
	dimi availableW,availableH
	dimi gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight
	availableW = ~menuXRes - #imgleftmenu.w - 50
	availableH = (#imgmainbg.DESTH-30) - (GDO_Y1 * ~factorY) 
	pprint xRatio,yRatio
'	gdoCurX = GDO_X1	
'	gdoCurY=GDO_Y1 *~factorY
'	gdoCurWidth=availableW
'	gdoCurHeight=availableH
/*	
	dimi tempw,temph
	tempw=#gdobg3.w
	temph=#gdobg3.h
	checkAspectRatio(tempw, temph,xRatio,yRatio)  
	
	#gdobg3.w=tempw
	#gdobg3.h=temph
'	#gdoVideo.x = gdoCurX
'	#gdoVideo.y = gdoCurY
	#gdoVideo3.w = tempw
	#gdoVideo3.h = temph
*/	
	call setAudioControl	
	call getPreviousScreen
	toolTipPaintFlag = 1
	call disp_streams
	update							'Added by Vimala
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
End Sub

/***********************************************************
'** getPreviousScreen
 *	Description: 
 *		To store the previous screen and repaint the screen after showing 
        the tooltip

 *	Created by: Franklin Jacques.K  On 2009-09-23 12:59:03

 ***********************************************************/
sub getPreviousScreen
	getimage(prvScreen1$, #imgplayrecord.x+10, #imgplayrecord.y+TOOLTIP_HEIGHT+30, TOOLTIP_WIDTH1+10, TOOLTIP_HEIGHT+10)
	getimage(prvScreen2$, #imgsnap.x+10, #imgsnap.y+TOOLTIP_HEIGHT+30, TOOLTIP_WIDTH1+10, TOOLTIP_HEIGHT+10)
	getimage(prvScreen3$, #imgalarm.x+10,#imgalarm.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH2+10,TOOLTIP_HEIGHT+10)
	getimage(prvScreen4$, #imgrecord.x+10,#imgrecord.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3+10,TOOLTIP_HEIGHT+10)
	getimage(prvScreen5$, #imgaudio.x+10,#imgaudio.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH3+10,TOOLTIP_HEIGHT+10)
	getimage(prvScreen6$, #imgsdcard.x+10,#imgsdcard.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH4+10,TOOLTIP_HEIGHT+10)
	getimage(prvScreen7$, #imgDisplay1x.x+10,#imgDisplay1x.y+TOOLTIP_HEIGHT+30,TOOLTIP_WIDTH4+10,TOOLTIP_HEIGHT+10)			'TR-13
End Sub


/***********************************************************
'** txtsnaptext_focus
 *	Description: 
 *		To set focus for the control

 *	Created by: Franklin  On 2009-07-16 14:01:12
 ***********************************************************/
Sub txtsnaptext_focus	
	rule = 17 //rule set for alphanumeric and undercore
	showcursor(3)
End Sub


/***********************************************************
'** ddStream_Change
 *	Description: 
 *		To set the URL(required stream) during the change event
 *		
 *	Params:
 *	Created by:Franklin Jacques  On 2009-06-10 15:13:36
 *	History: 
 ***********************************************************/
/*
Sub ddStream_Change
	if canReload = 1 then
		calVideoDisplayRatio(#ddstream.itemlabel$(#ddstream.selidx),xRatio,yRatio)				' TR-04
		call  form_complete	
	end if
End Sub
*/

/***********************************************************
'** disp_streams
 *	Description: 
 *		To set the URL for the video player(GDO) Control
 *		 
 *		rtspUrl$()- Array holds avaliable rtsp stream values *	
 *	Created by: Franklin Jacques  On 2009-07-31 19:01:44
 ***********************************************************/
sub disp_streams()
	
	dims url$,value$
	dimi ret,a
'	iff previousIndex=#ddstream.selidx and imgsnapFlag=0 then return
		
'	value$ = rtspUrl$(#ddstream.selidx)	
	
	'Video must be stoped before playing a stream
	a = #gdovideo1.stop(1)	
	
	dimi playVideoFlag
	dims dispStr$
	
'	playVideoFlag = checkForStreamRes(stream$(#ddstream.selidx))
	
	if playVideoFlag = 1 then
		dispStr$ = ~Unable_To_Display_Msg$
		#lblload.hidden = 0		
		#gdovideo1.hidden = 1	
	else
		dispStr$ = "Loading . . . . "
		'Play stream
		#gdovideo1.hidden = 0
		a = #gdovideo1.play(rtspUrl$(0))		
		pprint rtspUrl$(0)
		#gdovideo2.hidden = 0
		a = #gdovideo2.play( rtspUrl$(1))		
		
		#gdovideo3.hidden = 0
		a = #gdovideo3.play(rtspUrl$(2))		
		'a = #gdovideo3.play("rtsp://192.168.1.239:654/vlChannel0.264")
		#gdovideo4.hidden = 0
		a = #gdovideo4.play(rtspUrl$(3))		
	end if
	
	#lblload$ = dispStr$
	pprint gettextwidth(dispStr$,8,9)
	#lblload.w = #gdobg1.w - (#gdobg1.w/3)
	#lblload.h = 75
	#lblload.x =  ((#gdobg1.w/2) - (#lblload.w/2)) +  #gdobg1.x			
	
'	previousIndex=#ddstream.selidx
	
'	if #ddstream.itemcount <= 1 then     'note by hst
'		#chkDispallstreams.hidden = 1
'	else
'		#chkDispallstreams.hidden = 0
'	endif
	
	imgsnapFlag=0
'	#chkDispallstreams.paint(1)	
	#lblload.paint(1)	
End Sub

/***********************************************************
'** imgDisplay1x_Click
 *	Description: To load the Display1x From

 *	Created by:  On 2009-10-01 19:00:24

 ***********************************************************/
Sub imgDisplay1x_Click	
	if canReload = 1 then
		Dimi streamNo
//		pprint "streamNo="+streamNo
		streamNo = atol(#RadstreamChannel$)
		LoadUrl("!display1xMode.frm&streamNo="+streamNo)
	end if
End Sub



/***********************************************************
'** imgsdCard_Click
 *	Description: Load SD Card explorer screen

 *	Created by:Vimala  On 2010-04-30 15:23:55
 ***********************************************************/
Sub imgsdCard_Click	
	if canReload = 1 then
		loadurl("!SDExplorer.frm")	
	end if
End Sub



/***********************************************************
'** ddExample_Click
 *	Description: Get selected example value

 *	Created by:Vimala  On 2010-04-30 15:24:26
 ***********************************************************/
 /*
Sub ddExample_Click	
	selExampleVal = #ddexample.selidx
End Sub
*/


/***********************************************************
'** ddExample_Change
 *	Description: On changing the value selected, 
 *				 display a message and on confirmation should 
 *				 set the selected value  in the IPNC.
 
 *	Created by: Vimala  On 2009-12-15 00:30:25
 ***********************************************************/
 
 
/*
Sub ddExample_Change						'TR-30

	if canReload = 1 then
		iff selExampleVal = #ddexample.selidx then return
		dimi a
		#gdobg1.hidden = 1
		#gdovideo1.hidden = 1	
		update
		msgbox("This will change the configuration to demo modes selected.\n Do you want to continue?",3)
		
		if confirm() = 1 then
			a = #gdoVideo1.stop(1)	
			#lblload.hidden = 0 
			#lblload.x = #imgsnap.x
			#lblload.y = #gdobg1.y + (#gdobg1.y/2)
			
					
			dimi retVal ,i
			retVal = setExampleValue(#ddexample)
					
			saveSuccess = retVal
			'Based on reload flag wait for the camera to restart
			if getReloadFlag() = 1 then									'TR-45
				canReload = 0
				animateCount = 1
				call animateLabel("lblload","Loading")
			else // If Reload animation is not required
				canReload = 1
			end if
		
			if canReload = 1 then	//Do the remaining actions after reload animation is done
				call displaySaveStatus(saveSuccess)		
			end if
			
		else		
			#ddexample$ = democfg
			#gdobg1.hidden = 0
			#gdovideo1.hidden = 0
		end if
	end if
End Sub
*/

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
		loadurl("!livevideo.frm")
	else		
		msgbox("Demo Mode failed for the camera "+~title$)	
		#gdobg1.hidden = 0
		#gdovideo1.hidden = 0
		previousIndex = -1
		call disp_streams
	endif
End Sub


/***********************************************************
'** Form_Notify
 *	Description: Server Event Listeners are Notified here.
 *				 Continuously checks for Alarm and record status.
 
 *	Created by:  On 2010-04-30 15:25:10
 ***********************************************************/
Sub Form_Notify	
	dimi NotifySrc, NotifyData, ret
	dims Message$, MsgType$, optionValue$(2)
	NotifySrc=getmessage(NotifyData, MsgType$, Message$,"")	
	if NotifySrc = GNOTIFY_HTTP_DNLD_SUCCESS then		
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
'** getReloadTime  
 *	Description: Call this function to get the camera restart time 

 *	Created by: Vimala  On 2010-01-05 06:19:02
 ***********************************************************/
Sub getReloadTime()   'TR-40
	dimi retVal,reloadTime
	retVal = getLoadingTime(reloadTime)  //Call this function to get the reload time from IPNC
	
	if retVal >= 0 then
		~reLoadTime = reloadTime
	end if	
	
	pprint "reLoadTime = " + ~reLoadTime
End Sub



Sub savePage()
	'Please don't delete
End Sub


sub chkValueMismatch()	
	'Please don't delete
End Sub


Sub Form_MouseUp(x,y)
	dimi ret
	dims yuntairesponData$
    If ~yutangoFlag=1 Then
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz=stop@"+selChannelVal, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)	 
        ~yutangoFlag=0
    End If
End Sub

//receive date(notes) from boa ,then pass to note$(20)
sub RadchannelNum_Click
	iff selChannelVal = strtoint(#RadchannelNum$) then return
	selChannelVal= strtoint(#RadchannelNum$)
	call addItemsToDropDown("yuzhidian",presetOption$,-1)
	#note$=""
	pprint "selChannelVal="+selChannelVal
	LoadDownNotes(selChannelVal)
End Sub


Sub channelNum_Click
	' Add Handler Code Here 
'	msgbox("1111111111111111111111111")
	selChannelVal= #channelNum.selidx
	
	
End Sub


Sub channelNum_Change	
	
	iff selChannelVal = #channelNum.selidx then return
	selChannelVal= #channelNum.selidx
	//yuntaichannel=#channelNum.selidx
	
'	msgbox(selExampleVal)
	
	
End Sub

sub RadstreamChannel_Click
	iff selStreamVal = strtoint(#RadstreamChannel$) then return
	pprint "selStreamVal="+selStreamVal ;"#RadstreamChannel$=" + #RadstreamChannel$
	playStreamChannel(selStreamVal,strtoint(#RadstreamChannel$))
	selStreamVal= strtoint(#RadstreamChannel$)
	call addItemsToDropDown("yuzhidian",presetOption$,-1)
	#note$=""
	if selStreamVal==0 then
		selChannelVal=0
		#yuntaichannel.hidden=0
		#RadchannelNum.hidden=0
		#RadchannelNum[1].hidden=0
		#RadchannelNum[2].hidden=0
		#RadchannelNum[3].hidden=0
		//#channelNum.hidden=0
	else 
		selChannelVal=selStreamVal-1
		
		#yuntaichannel.hidden=1
		#RadchannelNum.hidden=1
		#RadchannelNum[1].hidden=1
		#RadchannelNum[2].hidden=1
		#RadchannelNum[3].hidden=1
		//#channelNum.hidden=1
	endif
	LoadDownNotes(selChannelVal)
End Sub
/*
sub RadstreamChannel_Change
	iff selStreamVal = strtoint(#RadstreamChannel$) then return
	playStreamChannel(selStreamVal,strtoint(#RadstreamChannel$))
	selStreamVal= strtoint(#RadstreamChannel$)
	if selStreamVal==0 then
		#yuntaichannel.hidden=0
		#channelNum.hidden=0
	else 
		#yuntaichannel.hidden=1
		#channelNum.hidden=1
	endif
End Sub
*/

Sub streamChannel_Click
	' Add Handler Code Here
	selStreamVal= #streamChannel.selidx 

End Sub

Sub streamChannel_Change
	' Add Handler Code Here 
	iff selStreamVal = #streamChannel.selidx then return
	playStreamChannel(selStreamVal,#streamChannel.selidx)
	selStreamVal= #streamChannel.selidx
/*  add by wbb
	if selStreamVal==0 then
		#imgyuntai.hidden=0
	else 
		#imgyuntai.hidden=1
	endif		
*/
//add by wbb
	if selStreamVal==0 then
		#yuntaichannel.hidden=0
		#channelNum.hidden=0
	else 
		#yuntaichannel.hidden=1
		#channelNum.hidden=1
	endif

End Sub


sub playStreamChannel(dimi preindex, dimi newindex )
	dimi a
	if preindex=0 then
		a=#gdoVideo1.stop(1)
		#gdobg1.hidden=1
		#gdoVideo1.hidden=1
		
	    a=#gdoVideo2.stop(1)
		#gdobg2.hidden=1
		#gdoVideo2.hidden=1
		
		a=#gdoVideo3.stop(1)
		#gdobg3.hidden=1
		#gdoVideo3.hidden=1
		
		a=#gdoVideo4.stop(1)
		#gdobg4.hidden=1
		#gdoVideo4.hidden=1
	
		
		#gdobg5.hidden=0
		#gdoVideo5.hidden=0
		a=#gdoVideo5.play( rtspUrl$(newindex-1))
	else
		if newindex=0 then
			a=#gdoVideo5.stop(1)
			#gdobg5.hidden=1
			#gdoVideo5.hidden=1
			
			
			
		
			#gdobg1.hidden=0
			#gdoVideo1.hidden=0
			a=#gdoVideo1.play(rtspUrl$(0))
			
				
			#gdobg2.hidden=0
			#gdoVideo2.hidden=0
			a=#gdoVideo2.play(rtspUrl$(1))
			
			#gdobg3.hidden=0
			#gdoVideo3.hidden=0
			a=#gdoVideo3.play(rtspUrl$(2))
			
			#gdobg4.hidden=0
			#gdoVideo4.hidden=0
			a=#gdoVideo4.play(rtspUrl$(3))
		
		
			
		else
			a=#gdoVideo5.stop( 1)
			a=#gdoVideo5.play( rtspUrl$(newindex-1))
		endif
		
	endif
	
	
End Sub


Sub imgplayrecord_Click
	' Add Handler Code Here 
	' This event will be fired only if the focusable property is set
/*
	if  #Channel1.checked || #Channel2.checked || #Channel3.checked || #Channel4.checked  then
		msgbox("1111111111111")
	else
		msgbox("00000000000000000")
	endif
	
*/	
End Sub



Sub imgjjd_Click
	' Add Handler Code Here 
	' This event will be fired only if the focusable property is set
	
	prop$="zoomin@"+selChannelVal
	pprint "prop$="+prop$
	ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
	pprint "ret="+ret
	~yutangoFlag=1
End Sub




Sub imgjjx_Click
	' Add Handler Code Here 
	' This event will be fired only if the focusable property is set
	prop$="zoomout@"+selChannelVal
	ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
	~yutangoFlag=1
End Sub



Sub imgjdy_Click
	' Add Handler Code Here 
	' This event will be fired only if the focusable property is set
	prop$="focusout@"+selChannelVal
	ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
	~yutangoFlag=1
End Sub



Sub imgjdj_Click
	' Add Handler Code Here 
	' This event will be fired only if the focusable property is set
	prop$="focusin@"+selChannelVal
	ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
	~yutangoFlag=1
End Sub



Sub imggqd_Click
	' Add Handler Code Here 
	' This event will be fired only if the focusable property is set
	prop$="aperturein@"+selChannelVal
	pprint 
	ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
	~yutangoFlag=1
End Sub



Sub imggqx_Click
	' Add Handler Code Here 
	' This event will be fired only if the focusable property is set
	prop$="apertureout@"+selChannelVal
	ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,yuntairesponData$)
	~yutangoFlag=1
End Sub


Sub recordOk_Click
	' Add Handler Code Here 
	dims recordSet$,responseData$
	dimi ret,recordOption,recordOption1,recordOption2,recordOption3,recordOption4
	
	if #Channel1.checked then
		recordOption1=1
	else
		recordOption1=0
	endif
	
	if #Channel2.checked then
		recordOption2=2
	else
		recordOption2=0
	endif
	
	if #Channel3.checked then
		recordOption3=4
	else
		recordOption3=0
	endif
	
	if #Channel4.checked then
		recordOption4=8
	else
		recordOption4=0
	endif
	
	recordOption=orb(orb((recordOption1 , recordOption2), recordOption3) , recordOption4)
	
	msgbox(recordOption)
		
	recordSet$="enablerecordch="+recordOption
	
	msgbox(recordSet$)
	ret = setProperties(recordSet$, responseData$)	
	
End Sub

																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																														
Sub yuzhidian_Click
	' Add Handler Code Here 
	selPresetVal= #yuzhidian.selidx

End Sub

Sub yuzhidian_Change		
	iff selPresetVal = #yuzhidian.selidx then return
	selPresetVal= #yuzhidian.selidx
	#note$ = note$(selPresetVal)
	setfocus("note")
	showcursor(3)
End Sub

Sub setbtn_Click
	' Add Handler Code Here 
	if selPresetVal != 0 then
		note$(selPresetVal)=#note$
		prop$="preset|"+selPresetVal+"@"+selChannelVal
		pprint "prop$="+prop$
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeData$)
		~yutangoFlag=1
		pprint "selpresetret="+ret
		prop$=selChannelVal+"@"+selPresetVal+"@"+note$(selPresetVal)		
		ret=HTTPDNLD(~camAddPath$+"vb.htm?setpresetnote="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeData$)
		~yutangoFlag=1
		pprint "prop$="+prop$
	endif
End Sub



Sub usebtn_Click
	' Add Handler Code Here 
		if selPresetVal != 0 then
		prop$="turntopreset|"+selPresetVal+"@"+selChannelVal
		~yutangoFlag=1
//		prop$="turntopreset@"+selChannelVal
		pprint "prop$="+prop$
		ret=HTTPDNLD(~camAddPath$+"vb.htm?ipncptz="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeData$)
		~yutangoFlag=1
		pprint "usebtnret="+ret
	endif
End Sub

Sub note_Focus
	showcursor(3)		
End Sub

function LoadDownNotes(dimi channel)
	dimi i,findPos
	dimi findPosArray(21)
	ret=HTTPDNLD(~camAddPath$+"vb.htm?getpresetnotes="+channel, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeData$)
	~yutangoFlag=1
//	pprint "ret11111111111111="+ret
	pprint "respone="+responeData$
	if ret > 0 then  
	findPosArray(0)=find(responeData$,"=")
	pprint "respone begin"
	for i=1 to 19
		findPos=findPosArray(i-1) +1
		findPosArray(i)=find(responeData$,"@",findPos)
		note$(i)=mid$(responeData$,findPos,(findPosArray(i)-findPos))
		pprint "note$("+i+"-1)="+note$(i)
	next
	note$(20)=mid$(responeData$,findPosArray(20)+1)
	ret=0
	end if
End Function


Sub note_Change
	' Add Handler Code Here 
End Sub

