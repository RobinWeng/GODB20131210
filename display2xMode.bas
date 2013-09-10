/****************************************************************************
 * gTI IPNC - display1xMode 
 * Copyright (c) 2008 - GoDB Tech Private Limited. All rights
 * reserved.
 *
 * THIS SOURCE CODE IS PROVIDED AS-IS WITHOUT ANY EXPRESSED OR IMPLIED
 * WARRANTY OF ANY KIND INCLUDING THOSE OF MERCHANTABILITY, NONINFRINGEMENT 
 * OF THIRD-PARTY INTELLECTUAL PROPERTY, OR FITNESS FOR A PARTICULAR PURPOSE.
 * NEITHER GoDB NOR ITS SUPPLIERS SHALL BE LIABLE FOR ANY DAMAGES WHATSOEVER 
 * (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS, 
 * BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER LOSS) 
 * ARISING OUT OF THE USE OF OR INABILITY TO USE THE SOFTWARE, EVEN IF GoDB 
 * HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 *
 * DO-NOT COPY,DISTRIBUTE,EMAIL,STORE THIS CODE WITHOUT PRIOR WRITTEN
 * PERMISSION FROM GoDBTech.
 ***************************************************************************/
option(4+1)
#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#define MINGAP_GDO   50
#define MINGAP_X     10
#define MINGAP_Y     5
#define HEADER_H     40
Dimi streamNo ,~playSliderPos,~ch,~playhour,~hour
streamNo = atol(request$("streamNo"))
~playSliderPos=atol(request$("playSliderPos"))
~ch=atol(request$("ch"))
~playhour=atol(request$("playhour"))
~hour=atol(request$("hour"))
~chStop=1
dims stream$(3),rtspUrl$(3)
dimi gdoCurWidth, gdoCurHeight
Dimi gdoCurX, gdoCurY
end

/***********************************************************
'** Form_Load
 *	Description: 
 *		
 *		
 *	Params:
 *	Created by:  On 2009-09-30 12:36:20
 *	History: 
 ***********************************************************/
Sub Form_Load
	Dimi MaxResX 
	Dimi MaxResY 
	MaxResX = getxres()
	MaxResY = getyres()
	Dimi xRes, yRes
	
	Dimi diffXres, diffYres
	Dimi btnX, btnY	
//wbb	loadStreamDetails(stream$,rtspUrl$) //call this function to get stream names and its rtsp urls
//	pprint streamNo;stream$(streamNo)
	if stream$(streamNo)<>"" then 
		'MaxResY=MaxResY-HEADER_H
		getCurStreamResolution(stream$(streamNo), xRes, yRes)
		
		// Code modified for displaying 1x with scroll buttons inbuilt - START
		#lblStreamName$ = stream$(streamNo) 
		gdoCurX = 0
		gdoCurY = HEADER_H
		gdoCurWidth=MaxResX
		gdoCurHeight=MaxResY
		/*   mend by wbb
		if xRes <= MaxResX then
			gdoCurWidth=xRes 
			diffXres = MaxResX-xRes
			diffXres = diffXres/2   
			gdoCurX = diffXres
		else
			gdoCurWidth=MaxResX
		endif 
	
		if yRes<=MaxResY then 
			gdoCurHeight=yRes
			diffYres = MaxResY-yRes
			diffYres = diffYres/2  
			gdoCurY = diffYres + 10

		else
			MaxResY=MaxResY-HEADER_H
			gdoCurHeight=MaxResY
		endif
		*/
		// Code modified for displaying 1x with scroll buttons inbuilt - END
	endif 
	gdoCurWidth = gdoCurWidth/16
	gdoCurWidth = gdoCurWidth*16
	btnX = MaxResX - #btnClose1x.w - MINGAP_X
	btnY = MINGAP_Y
	pprint btnX;btnY
	#btnClose1x.x = btnX
	#btnClose1x.y = btnY
	#lblStreamName.x = MINGAP_X
	#lblStreamName.y = MINGAP_Y
	createGDOControl("gdoVideo", gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight)
	#gdoVideo.UIMode = 3
	#gdoVideo.SetVideoRes(xres,yres)
	setFocus("btnClose1x")
End Sub

/***********************************************************
'** Form_Complete
 *	Description: 
 *		To set the URl for the GDO Control 
 *		
 *	Params:
 *	Created by:  On 2009-09-30 12:53:26
 *	History: 
 ***********************************************************/
sub Form_Complete
	dimi playSliderPos=~playSliderPos
	call playExec(playSliderPos)
	showcursor(3)
End Sub

Sub playExec(dimi sliderPos)	
	dims playRecUrl$,playdate$,ch$,responeDate$
	dimi a,ret,minute,second
	dims playtime$
	
	playRecUrl$="rtsp"+mid(~camAddPath$,4,16)+":654/"
	playtime$=time()+".264"	

	~chStop=0	
	ch$=~ch
    minute=sliderPos/60
    second=sliderPos%60
	playdate$=left$(~playhour,4)+"@"+mid$(~playhour,4,2)+"@"+right$(~playhour,2)+"@"+~hour+"@"+minute+"@"+second+"@"+ch$+"@"+playtime$
	pprint "playdate$="+playdate$

	ret=HTTPDNLD(~camAddPath$+"vb.htm?startplaybackch="+playdate$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeDate$)
	sleep(1000)
	
	if ret > 0 then
		playRecUrl$+=playtime$
		pprint "playRecUrl$+=playtime$ ="+playRecUrl$
			pprint playRecUrl$
			a = #gdoVideo.stop(1)
			#gdovideo.hidden = 1

			'check whether video stream can to displayed by ActiveX or not
			dimi playVideoFlag,fontNo,styleNo
			dims dispStr$
			
			playVideoFlag = checkForStreamRes(stream$(streamNo))
			
			if playVideoFlag = 1 then
				dispStr$ = ~Unable_To_Display_Msg$
				#lblloading.hidden = 0		
				#gdovideo.hidden = 1			
				styleNo = 0
			else
				dispStr$ = "Updating . . . .    "
				'Play stream
				#gdovideo.hidden = 0
				a=#gdoVideo.play(playRecUrl$)
			end if
			#lblloading.style = styleNo	
			#lblloading$ = dispStr$
			#lblloading.w = gdoCurWidth - (gdoCurWidth/4)
			#lblloading.h = 120
			#lblloading.x =  ((gdoCurWidth/2) - (#lblloading.w/2)) +  gdoCurX	
			#lblloading.y = ((gdoCurHeight/2) - (#lblloading.h/2)) + gdoCurY
			#lblloading.paint(1)				
	endif

	
	settimer(1000,"TestSub")
	
	call TestSub()

End Sub

Sub TestSub()
	if ~chstop=0 then
		~playSliderPos++
	endif
	update
End Sub

/***********************************************************
'** disp_streams
 *	Description: 
 *		
 *		
 *	Params:
 *	Created by:  On 2009-07-31 19:01:44
 *	History: 
 ***********************************************************/
/* wbb
sub disp_streams()
	dims url$,value$
	dimi ret,a
	value$ = rtspUrl$(streamNo) 	
	/*a = #gdovideo.play(value$)
	#gdovideo.hidden = 0***9/
	
	a = #gdovideo.stop(1)	
	#gdovideo.hidden = 1
	
	'check whether video stream can to displayed by ActiveX or not
	dimi playVideoFlag,fontNo,styleNo
	dims dispStr$
	
	playVideoFlag = checkForStreamRes(stream$(streamNo))
	
	if playVideoFlag = 1 then
		dispStr$ = ~Unable_To_Display_Msg$
		#lblloading.hidden = 0		
		#gdovideo.hidden = 1			
		styleNo = 0
	else
		dispStr$ = "Updating . . . .    "
		'Play stream
		#gdovideo.hidden = 0
		a =  #gdovideo.play(value$)		
		styleNo = 8
		#gdovideo.hidden = 0
	end if
	
	#lblloading.style = styleNo	
	#lblloading$ = dispStr$
	#lblloading.w = gdoCurWidth - (gdoCurWidth/4)
	#lblloading.h = 120
	#lblloading.x =  ((gdoCurWidth/2) - (#lblloading.w/2)) +  gdoCurX	
	#lblloading.y = ((gdoCurHeight/2) - (#lblloading.h/2)) + gdoCurY
	#lblloading.paint(1)	

End Sub
*/

/***********************************************************
'** btnClose1x_Click
 *	Description: 
 *		To close the 1x Mode and return back to Live Video frm
 *		
 *	Params:
 *	Created by:  On 2009-09-30 13:12:53
 *	History: 
 ***********************************************************/
Sub btnClose1x_Click
LoadUrl("!playback.frm")
End Sub


/***********************************************************
'** form_keypress
 *	Description: 
 *		To return to the liveVideo frm	when Esc key is pressed
 *		
 *	Params:
'*		key : Numeric - 
 *		FromMouse: Numeric - 
 *	Created by:  On 2009-09-30 14:32:38
 *	History: 
 ***********************************************************/
sub form_keypress(key , FromMouse)
	Dimi disp1xFlag
	disp1xFlag = 1
	if key = 15 then
		LoadUrl("!LiveVideo.frm&ddstreamNo="+streamNo+"&disp1xFlag="+disp1xFlag)
	endif
	
	scroll_keypressed(key) 
	
End Sub

/***********************************************************
'** scroll_keypressed
 *	Description: Lock mouse scroll
  *	Created by: Franklin On 2009-05-15 15:21:15
 *	History: 
 ***********************************************************/
sub scroll_Keypressed(key)
	dimi k1=26 ' SCROLL LOCK KEY
	dimi k2=25
	
	if k1=key or k2=key then
	   keyhandled(2)
	endif	
		
End Sub




