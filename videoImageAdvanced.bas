/***************************************************************************************\
 * PROJECT NAME          : IPNC              							               *        
 * MODULE NAME           : Video Advanced Settings                                    *
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

#define GDO_X			   729	
#define GDO_Y			   168	
#define GDO_W              256
#define GDO_H              200

dims TabsImagesA$,TabsImagesB$,TabsImagesC$

dimi noofctrl														'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS                              
dims LabelName$(noofctrl)                                           'Form controls name
dimi XPos(noofctrl)                                                 'Form controls X position
dimi YPos(noofctrl)                                                 'Form controls Y position
dimi Wdh(noofctrl)                                                  'Form controls Width position
dimi height(noofctrl)                                               'Form controls height position
                                                             
#include "videoImageAdvanced.inc"
dimi gdoWidth
dimi gdoHeight
dimi rule															'to define the rule(index) for control's validation
dimi noOfTabs														'to define the no of tabs at run time
dimi MsgColorFlag=-1
dimi ErrorROIFlag=0													'set to check Validation of Width and height of region 
dimi FocusFlag=0													'Flag to set the focus for the textBoxes(Width or Height)
dims stream$(3),rtspUrl$(3)

settimer(1000)														'set the timer for 1 second
dimi validateFlag													'sets 1 if all the data is valid else 0.TR-15
validateFlag =1														'TR-15
dimi jpegStream
dimi displayCount,isMessageDisplayed			'TR-35  
displayCount = 1								'TR-35

dims ctrlValues$(noofctrl),tempLabelName$(noofctrl)
dimi animateCount = 0 	 ' Stores the count for the animation done.
dimi saveSuccess = 0	 'Value of 1 is success
dims error$ = "" 		 'Stores the error returned while saving.
end


/***********************************************************
'** alignCtrls
 *	Description:To align the control's X,Y position with 
			    respect to the Resolution in all tabs

 *	Created by: Vimala On 2009-05-12 05:55:42
 ***********************************************************/
Sub alignCtrls(dimi tabno)
	dims ctrlname$(45) = ("lblForceIFrame","lblMin","lblMax","lblInit","txtInit","lblQPValue","chkForceIFrame","txtMin", _
						"txtMax","txtIPRatio","lblIPRatio","lblMEConfig","lblPacketSize","txtPacketSize", _
						"drpMEConfig","lblFrameData","chkFaceDetect","txtreg1hgt","lblRegion1", _
						"txtreg2hgt","lblreg1x","txtreg1X","txtreg3wdt","lblreg1Y","txtreg1Y","lblRegion3","lblreg1wdt", _
						"txtreg1wdt","lblreg3x","lblreg1hgt","txtreg3Y","lblreg3Y","txtreg3X","lblreg3wdt","lblreg3hgt", _
						"lblRegion2","txtreg3hgt","lblreg2x","txtreg2X","lblreg2Y","txtreg2Y","lblreg2wdt","txtreg2wdt", _
						"lblreg2hgt","btnConfigure")
						
	dimi i,ctrlLen
	dims controlName$,tempctrl$,tempctrl1$,temp$
	for i = 0 to ubound(ctrlname$)		
		controlName$ = ctrlname$(i)+tabno		
		tempctrl$ = ctrlname$(i)+"1"	
		
		if find(ctrlname$(i),"opt")>=0 then
			temp$ = right$(ctrlname$(i),3)
			ctrlLen = len(ctrlname$(i))
			tempctrl$ = left$(ctrlname$(i),ctrlLen-3)+tabno+temp$
			tempctrl1$ = left$(ctrlname$(i),ctrlLen-3)+1+temp$
			controlName$ = tempctrl$ 
			tempctrl$ = tempctrl1$
		end if
				
		#{controlName$}.x = #{tempctrl$}.x
		#{controlName$}.y = #{tempctrl$}.y
		#{controlName$}.w = #{tempctrl$}.w 
		
	next
	
End Sub



/***********************************************************
'** form_timer
 *	Description:To set wait flag when switching between forms
 *				 Display save success message for 5 secs
					
 *	Created by: Franklin On 2009-06-30 16:14:12

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
'** setInitialValues
 *	Description: 
 *			To set the Initial values for all the controls
 *		
 *	Functions/Methods: getVideoImageAdvanced1()- To set the values for the stream1 
					   getVideoImageAdvanced2()- To set the values for the stream2
					   getVideoImageAdvanced3()- To set the values for the stream3
 
 *	Created by: Franklin Jacques  On 2009-05-11 16:27:17
 ***********************************************************/
sub setInitialValues()
	dimi ret1,ret2,ret3,ret4
	dims ddValue$
	
	'stream1
	dims ipratio1$,qpmin1$,qpmax1$,meconfigname$,packetsize1$
	dimi forceIframe1,regionofinterestenable1,meconfig1,str1x1,str1y1,str1w1,str1h1,str1x2,str1y2,str1w2,str1h2,str1x3,str1y3,str1w3,str1h3
	dimi qpinit1								'TR-41
	'stream2
	dims ipratio2$,qpmin2$,qpmax2$,packetsize2$
	dimi forceIframe2,regionofinterestenable2,meconfig2
	dimi str2x1,str2y1,str2w1,str2h1,str2x2,str2y2,str2w2,str2h2,str2x3,str2y3,str2w3,str2h3         
	dimi qpinit2									'TR-41
	'stream3
	dims ipratio3$,qpmin3$,qpmax3$,packetsize3$               
	dimi forceIframe3,regionofinterestenable3,meconfig3
	dimi str3x1,str3y1,str3w1,str3h1,str3x2,str3y2,str3w2,str3h2,str3x3,str3y3,str3w3,str3h3         
	dimi qpinit3									'TR-41
	'fetch stream values
	'stream1
	ret1=getVideoImageAdvanced1(ipratio1$,forceIframe1,qpmin1$,qpmax1$,meconfig1,meconfigname$,_
								packetsize1$,regionofinterestenable1,str1x1,str1y1,str1w1,str1h1,_
								str1x2,str1y2,str1w2,str1h2,str1x3,str1y3,str1w3,str1h3,qpinit1)	'TR-41
	'stream2
	ret2=getVideoImageAdvanced2(ipratio2$,forceIframe2,qpmin2$,qpmax2$,meconfig2,_
								packetsize2$,regionofinterestenable2,str2x1,str2y1,_
								str2w1,str2h1,str2x2,str2y2,str2w2,str2h2,str2x3,_
								str2y3,str2w3,str2h3,qpinit2)										'TR-41
	'stream3
	ret3=getVideoImageAdvanced3(ipratio3$,forceIframe3,qpmin3$,qpmax3$,meconfig3,_
								packetsize3$,regionofinterestenable3,str3x1,str3y1,_
								str3w1,str3h1,str3x2,str3y2,str3w2,str3h2,str3x3,_
								str3y3,str3w3,str3h3,qpinit3)										'TR-41
		
	'stream1
	#rocamera$ = ~title$
	#txtIPRatio1$=ipratio1$               
	#chkForceIFrame1$= forceIframe1       
	#txtinit1$ = qpinit1
	#txtMin1$=qpmin1$                     
	#txtMax1$=qpmax1$  
	split(ddValue$,meconfigname$,";")
	call addItemsToDropDown("drpMEConfig1", ddValue$, meconfig1)                   
	#txtPacketSize1$= packetsize1$                
	#chkFaceDetect1$=regionofinterestenable1     
	#txtreg1X1$=str1x1                      
	#txtreg1Y1$=str1y1                      
	#txtreg1wdt1$=str1w1                      
	#txtreg1hgt1$=str1h1                      
	#txtreg2X1$=str1x2                      
	#txtreg2Y1$=str1y2                      
	#txtreg2wdt1$=str1w2                      
	#txtreg2hgt1$=str1h2                      
	#txtreg3X1$=str1x3                      
	#txtreg3Y1$=str1y3                      
	#txtreg3wdt1$=str1w3                      
	#txtreg3hgt1$=str1h3
	'stream2
	#txtIPRatio2$=ipratio2$       
	#chkForceIFrame2$= forceIframe2 
	#txtinit2$ = qpinit2      
	#txtMin2$=qpmin2$               
	#txtMax2$=qpmax2$  	
	split(ddValue$,meconfigname$,";")
	call addItemsToDropDown("drpMEConfig2", ddValue$, meconfig2)                   
	#txtpacketsize2$= packetsize2$                	
	#chkFaceDetect2$=regionofinterestenable2     
	#txtreg1X2$=str2x1                      
	#txtreg1Y2$=str2y1                      
	#txtreg1wdt2$=str2w1                      
	#txtreg1hgt2$=str2h1                      
	#txtreg2X2$=str2x2                      
	#txtreg2Y2$=str2y2                      
	#txtreg2wdt2$=str2w2                      
	#txtreg2hgt2$=str2h2                      
	#txtreg3X2$=str2x3                      
	#txtreg3Y2$=str2y3                      
	#txtreg3wdt2$=str2w3                      
	#txtreg3hgt2$=str2h3  	
	'stream3
	#txtIPRatio3$=ipratio3$    	
	#chkForceIFrame3$= forceIframe3       
	#txtinit3$ = qpinit3
	#txtMin3$=qpmin3$                     
	#txtMax3$=qpmax3$  
	split(ddValue$,meconfigname$,";")
	call addItemsToDropDown("drpMEConfig3", ddValue$, meconfig3)                   
	#txtpacketsize3$= packetsize3$                
	#chkFaceDetect3$=regionofinterestenable3     
	#txtreg1X3$=str3x1                      
	#txtreg1Y3$=str3y1                      
	#txtreg1wdt3$=str3w1                      
	#txtreg1hgt3$=str3h1                      
	#txtreg2X3$=str3x2                      
	#txtreg2Y3$=str3y2                      
	#txtreg2wdt3$=str3w2                      
	#txtreg2hgt3$=str3h2                      
	#txtreg3X3$=str3x3                      
	#txtreg3Y3$=str3y3                      
	#txtreg3wdt3$=str3w3                      
	#txtreg3hgt3$=str3h3   
	                        
End Sub


/***********************************************************
'** Form_Load
 *	Description: 
		loadIniValues() - Fetch values for keyword from ini.htm.		
		setInitialValues() - Get values for all screen controls
		displayControls - Display controls based on the screen resolution .
		loadStreamDetails - Get stream names and rtsp url values
		createGDOControl - Create video player based on the stream resolution aspect ratio
		alignGDOCtrl - align gdo control
		addTabImage - display tab image
		showSubMenu - To display setting menu
		selectSubMenu - Highlight selected setting screen		

 *	Created by: Franklin Jacques.k On 2009-04-10 15:08:03
 ***********************************************************/
Sub Form_Load	
	dimi ret	
	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif	

	call setInitialValues			    
	loadStreamDetails(stream$,rtspUrl$)         							 'TR-04
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	createGDOControl("gdoVideo", GDO_X, GDO_Y, GDO_W, GDO_H)
	createGDOControl("gdoVideoROI",GDO_X, GDO_Y, GDO_W, GDO_H)
	call alignGDOCtrl(0)
	
	noOfTabs = atol(request$("noOfTabs"))
	
	ret = #fradvanced.addtab("frAdvStream1","Stream 1")
	
	if noOfTabs = 2 then
		ret = #fradvanced.addtab("frAdvStream2","Stream 2")
	elseif noOfTabs = 3 then
		ret = #fradvanced.addtab("frAdvStream2","Stream 2")
		ret = #fradvanced.addtab("frAdvStream3","Stream 3")	
	endif		
	
	call addTabImage()
	showSubMenu(0,1)
	setfocus("rosubmenu[0]")
	selectSubMenu()
	#lblheading$ = "Video > Advanced"
	setfocus("txtipratio1")
	chkFaceDetect1_click
	#lblloading.hidden = 1
	#lblErrMsg.hidden = 1	
	
	#lblsuccessmessage$ = ""																'TR-35
	isMessageDisplayed = atol(request$("isMessageDisplayed"))
	if isMessageDisplayed = 1 then
		#lblsuccessmessage$ = "Video - Advanced setting saved to camera "+~title$			'TR-35	
	end if	
End Sub


/***********************************************************
'** alignGDOCtrl
 *	Description: 
 *		To align the GDO control with respect to the current stream aspect ratio.

 *	Created by: Franklin Jacques.k On 2009-09-30 09:59:52

 ***********************************************************/
Sub alignGDOCtrl(dimi streamNo)
	dimi gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight
	Dimi xRatio,yRatio	
	~previewVideoRes$ = stream$(streamNo)
	
	#fradvstream1.w = #lbldummy.x - #fradvanced.x - 16
	#fradvstream2.w = #lbldummy.x - #fradvanced.x - 16
	#fradvstream3.w = #lbldummy.x - #fradvanced.x - 16
	#fradvanced.w = #lbldummy.x - #fradvanced.x - 14
	#fradvstream1.h = #lbldummy.y - #fradvanced.y -20
	#fradvstream2.h = #lbldummy.y - #fradvanced.y -20
	#fradvstream3.h = #lbldummy.y - #fradvanced.y -20
	#fradvanced.h = #fradvstream1.h + 40
	
	pprint "~previewVideoRes$ = " + ~previewVideoRes$
	calVideoDisplayRatio(~previewVideoRes$,xRatio,yRatio)				' CR-04
	gdoCurX = GDO_X * ~factorX
	gdoCurY = GDO_Y * ~factorY
	gdoCurWidth  = GDO_W * ~factorX
	gdoCurHeight = GDO_H * ~factorY	
	checkAspectRatio(gdoCurWidth, gdoCurHeight,xRatio,yRatio)
	#gdobg.x=gdoCurX-1
	#gdobg.y=gdoCurY-1
	#gdobg.w = gdoCurWidth+1 
	#gdobg.h = gdoCurHeight+1	
	#gdoVideo.x = gdoCurX
	#gdoVideo.y = gdoCurY
	#gdoVideo.w = gdoCurWidth
	#gdoVideo.h = gdoCurHeight	
	#frmregofinterest.x = #fradvanced.x
	#frmregofinterest.y = #fradvanced.y 
	#frmregofinterest.h = (#btnrefresh.y  - #frmregofinterest.y) + #btnrefresh.h + 10
	#lblregInt.y = #fradvanced.y + 2
	#lblregInt.w = #frmregofinterest.w  - 20
	#lblInterest.y = #lblregInt.y+2
	#frmregofinterest.bg = 4358
	gdoCurWidth  =  #frmregofinterest.w 
	gdoCurHeight  = #drpregion1.y - (#lblregInt.y + #lblregInt.h + #drpregion1.h+10)
	checkAspectRatio(gdoCurWidth, gdoCurHeight,xRatio,yRatio)
	#gdoVideoROI.x = #frmregofinterest.x+(#frmregofinterest.w-gdoCurWidth)/2
	#gdoVideoROI.y =   #lblregint.y+#lblregint.h+15
	#gdoVideoROI.w = gdoCurWidth
	#gdoVideoROI.h = gdoCurHeight	
	#lblbg.x = (#frmregofinterest.x+(#frmregofinterest.w-gdoCurWidth)/2) -4
	#lblbg.y = #lblregint.y+#lblregint.h+11
	#lblbg.w = gdoCurWidth+7
	#lblbg.h = gdoCurHeight+7
	gdoWidth = gdoCurWidth
	gdoHeight = gdoCurHeight
	#gdoVideo.Audio = 0	
	#gdoVideoROI.totregion = 3   '25 MAR 2010
	#gdoVideoROI.UIMode=2
	#gdoVideoROI.hidden=1
	#gdoVideoROI.Audio=1
	#frmregofinterest.hidden=1
	
	#gdoVideo.paint(1) 
End Sub



/***********************************************************
'** fradvanced_change
 *	Description: 
 *		To align the controls during the frame change event 
 *		
 *	Methods : alignCtrls- to align the controls of the current frame
 
 *	Created by:Franklin Jacques On 2009-05-12 06:14:35
 *	History: 
 ***********************************************************/
sub fradvanced_change
	Dimi a, ret 
	Dims url$, value$

	call alignGDOCtrl(#fradvanced.curtab)
	if #fradvanced.curtab = 0 then
		alignCtrls(1)
		chkFaceDetect1_click
		iff validateFlag = 1 then setfocus("txtipratio1")  'TR-15
	elseif #fradvanced.curtab = 1 then
		alignCtrls(2)
		chkFaceDetect2_click
		iff validateFlag = 1 then setfocus("txtipratio2") 'TR-15
	elseif #fradvanced.curtab = 2 then
		alignCtrls(3)
		chkFaceDetect3_click
		iff validateFlag = 1 then setfocus("txtipratio3") 'TR-15
	endif
	a = #gdoVideo.stop(1)
	Sleep(2)
	value$ = rtspUrl$(#fradvanced.curtab)  
	a=#gdoVideo.Play(value$)								//godVideoROI-gdo control for region of interest
	#gdoVideo.hidden=0
	showcursor(3)
	checkForJpegStream()
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
End Sub


/***********************************************************
'** Form_complete
 *	Description: 
 *		Set the properties for gdo video control to play rtsp stream
 
 *	Created by: Franklin Jacques On 2009-03-03 16:02:27
 
 ***********************************************************/
Sub Form_complete
	~wait = 0
	
	'Store all the control values in an array to validate changes in form.
	dimi i
	for i = 0 to ubound(ctrlValues$)-1	
		iff LabelName$(i) = "lblIPRatio1" or LabelName$(i) = "lblIPRatio2" or LabelName$(i) = "lblIPRatio3" then continue
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
	
	call alignGDOCtrl(#fradvanced.curtab)			
	call disp_streams()	
	showcursor(3)
	update
End Sub

/***********************************************************
'** disp_streams
 *	Description: 
 *		To set the URL for the GDO Control

 *	Created by: Franklin Jacques  On 2009-07-31 19:01:44
 *	History: 
 ***********************************************************/
sub disp_streams()
	dims url$,value$
	dimi ret,a	
	value$ = rtspUrl$(#fradvanced.curtab)      	   
	a = #gdovideo.play(value$)
	#gdovideo.hidden = 0
	
	checkForJpegStream()
	
End Sub

/***********************************************************
'** checkForJpegStream
 *	Description: If stream is jpeg then display message and hide all controls

 *	Created by:  On 2009-11-06 18:23:52
 ***********************************************************/
sub checkForJpegStream()
	'TR-16
	dims ctrlName$,tempName$
	dimi sNo,spltCount,i
	spltCount = noOfTabs 
	for i = 0 to spltCount-1
		pprint rtspUrl$(i)
		if find(ucase$(rtspUrl$(i)),"JPEG") > 0  then									
			sNo = i+1
			jpegStream = sNo		
			if #fradvanced.curtab = jpegStream-1 then 
				ctrlName$ = "frAdvStream"+sNo
				#{ctrlName$}.disabled = 1
				#{ctrlName$}.hidden = 1
				tempName$ = "lblipratio"+sNo
				#{tempName$}.hidden = 0 		
				#{tempName$}$ = "No Advanced Setting for JPEG is available in this version"
				#{tempName$}.w = 400
				#{tempName$}.x = #lblipratio1.x + #frAdvStream1.w/5
				#{tempName$}.y = #fradvanced.y + #fradvanced.h/3
				#{tempName$}.font = 10
				showcursor(0)
			end if
		end if
	next
End Sub



/***********************************************************
'** cmdCancel_Click
 *	Description: 
 *		Load initial values from camera
 *		
 *	Methods: To set the Initial Values For the VideoImageAdvanced setting
 *	Created by:Franklin Jacques.k  On 2009-04-16 14:20:12

 ***********************************************************/
Sub cmdCancel_Click	
	if canReload = 1 then
		~changeFlag = 0	
		call setInitialValues()		
		chkFaceDetect1_click()
	end if
End Sub


/***********************************************************
'** chkFaceDetect1_click
 *	Description: shows or hide region of interest controls
 
 *	Created by: Franklin Jacques On 2009-06-10 10:44:50
***********************************************************/
Sub chkFaceDetect1_click	
	
	if #chkfacedetect1$ = "1" then
		#btnconfigure1.disabled = 0
		showAllRegionCtrls(0,1)
	else
		#btnconfigure1.disabled = 1
		showAllRegionCtrls(1,1)
	end if
		
End Sub

/***********************************************************
'** chkFaceDetect2_click
 *	Description: shows or hide region of interest controls
 
 *	Created by: Franklin Jacques On 2009-06-10 10:46:48

 ***********************************************************/
Sub chkFaceDetect2_click	
	
	if #chkfacedetect2$ = "1" then
		#btnconfigure2.disabled = 0
		showAllRegionCtrls(0,2)
	else
		#btnconfigure2.disabled = 1
		showAllRegionCtrls(1,2)
	end if
	
End Sub


/***********************************************************
'** chkFaceDetect3_click
 *	Description: shows or hide region of interest controls
 
 *	Created by: Franklin Jacques On 2009-06-10 10:46:56

 ***********************************************************/
Sub chkFaceDetect3_click	
	
	if #chkfacedetect3$ = "1" then
		#btnconfigure3.disabled = 0
		showAllRegionCtrls(0,3)
	else
		#btnconfigure3.disabled = 1
		showAllRegionCtrls(1,3)
	end if
	
End Sub

/***********************************************************
'** showAllRegionCtrls
 *	Description: 
 *		To display all the region controls for stream1, stream2, stream3 
 *		
 *	Params:
'*		dimi hideVal: Numeric - Holds 0 or 1
 *		dimi frameNo: Numeric - Frame number
 *	Created by: Franklin On 2009-05-19 11:22:34

 ***********************************************************/
Sub showAllRegionCtrls(dimi hideVal,dimi frameNo)
	
	dimi i,j
	dims ctrlName$
	dims regCtrl$(4)=("X","Y","wdt","hgt")
	
	for i = 1 to 3		
		ctrlName$ = "lblRegion"+i+frameNo		
		#{ctrlName$}.hidden = hideVal
		
		for j = 0 to 3
			ctrlName$ = "lblreg"+i+regCtrl$(j)+frameNo		
			#{ctrlName$}.hidden = hideVal
			ctrlName$ = "txtreg"+i+regCtrl$(j)+frameNo	
			#{ctrlName$}.hidden = hideVal	
		next
		
	next
	
End Sub


/***********************************************************
'** Form_KeyPress
 *	Description: 
 *			To set wait flag before switching between forms	
			Checks entered key value based on the rule set to that user input control

 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by: Franklin Jacques On 2009-05-16 03:47:42
 *	History: 
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )		
	if Key = 15 then
	iff ~wait<=1 then return
		~wait = 2
	endif
	scroll_keypressed(key)
	dims keypressed$
	keypressed$ = chr$(getkey())
	
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)
	setSubMenuFocus(Key,0)
End Sub



/***********************************************************
'** cmdSave_Click
 *	Description: 
 *		Save all user input values to camera
 *		
 *	Params:
 *	Created by:Franklin Jacques  On 2009-05-11 19:57:09
 *	History: 
 ***********************************************************/
Sub cmdSave_Click
	if canReload = 1 then
		savePage()		
	end if
End Sub


/***********************************************************
'** getNoOfRegionsSelected
 *	Description: 
 *		call this function to get number of regions selected for a stream
 *		
 *	Params: regionNo - Numeric
 *	Created by:S.Vimala  On 2009-12-04 
 *	History: 
 ***********************************************************/
Function getNoOfRegionsSelected(dimi regionNo)	'TR-29 
	dims regName1$(4) = ("txtreg1X","txtreg1Y","txtreg1wdt","txtreg1hgt")
	dims regName2$(4) = ("txtreg2X","txtreg2Y","txtreg2wdt","txtreg2hgt")
	dims regName3$(4) = ("txtreg3X","txtreg3Y","txtreg3wdt","txtreg3hgt")
	
	dimi i,selectedFlag,totalRegion 
	dims tempName$
	selectedFlag = 0
	for i = 0 to ubound(regName1$)
		tempName$ = regName1$(i)+regionNo
		pprint tempName$
		if #{tempName$} > 0 then 
			selectedFlag = 1
			break
		end if
	next
	
	totalRegion = selectedFlag
	selectedFlag = 0
	for i = 0 to ubound(regName2$)
		tempName$ = regName2$(i)+regionNo
		pprint tempName$
		if #{tempName$} > 0 then 
			selectedFlag = 1
			break
		end if
	next
	
	totalRegion += selectedFlag
	selectedFlag = 0
	for i = 0 to ubound(regName3$)
		tempName$ = regName3$(i)+regionNo
		pprint tempName$
		if #{tempName$} > 0 then 
			selectedFlag = 1
			break
		end if
	next
	
	totalRegion += selectedFlag
	getNoOfRegionsSelected = totalRegion
End Function




/***********************************************************
'** savePage
 *	Description: 
 *		 Save all the tab values  to camera
 
 *	Created by: Franklin On 2009-05-28 16:34:07

 ***********************************************************/
Sub savePage()
	msgbox("videoimageadvanced.bas")
	if validateCtrlValues() = 0 then 
		fradvanced_change()
		return
	endif
	
	'Validation
	if  ValidateRegionValues(1) = 1 and #chkfacedetect1.checked = 1 then
		msgbox("Please enter valid X,Y,Widht,Height for stream1")
		#fradvanced.curtab = 0			
		setfocus("txtreg1x1")
		return
	elseif  ValidateRegionValues(2) = 1 and #chkfacedetect2.checked = 1  and noOfTabs >= 2 then
		 msgbox("Please enter valid X,Y,Widht,Height for stream2")
		 #fradvanced.curtab = 1	
		 setfocus("txtreg1x2")		
		 return
	elseif  ValidateRegionValues(3) = 1 and #chkfacedetect3.checked = 1 and noOfTabs=3  then
		 msgbox("Please enter valid X,Y,Widht,Height for stream3")
		 #fradvanced.curtab = 2
		 setfocus("txtreg1x3")
		 return
	end if
		
	dimi a
	a = #gdoVideo.stop(1)	
	#gdoVideo.hidden = 1	
	#gdobg.paint(1)
	#lblloading$= "Updating..."
	#lblloading.paint(1)	
	
	#lblloading.hidden = 0	
	'TR-29 
	dimi noOfRegions1,noOfRegions2,noOfRegions3
	if #chkFaceDetect1 = 1 then
		noOfRegions1 = getNoOfRegionsSelected(1)
	end if
	'TR-29 
	if #chkFaceDetect2 = 1 then
		noOfRegions2 = getNoOfRegionsSelected(2)
	end if
	'TR-29 
	if #chkFaceDetect3 = 1 then
		noOfRegions3 = getNoOfRegionsSelected(3)
	end if
	
	dimi ret1, ret2, ret3,i
	dims error$
	pprint #txtreg1hgt1
	ret1 = setVideoImageAdvanced1(#txtIPRatio1$,#chkForceIFrame1,#txtMin1$,#txtMax1$,#txtinit1$,_
								  #drpMEConfig1,#txtPacketSize1$,_
								  noOfRegions1,#txtreg1X1,#txtreg1Y1,#txtreg1wdt1,#txtreg1hgt1,_
								  #txtreg2X1,#txtreg2Y1,#txtreg2wdt1,#txtreg2hgt1,#txtreg3X1,_
								  #txtreg3Y1,#txtreg3wdt1,#txtreg3hgt1)				'TR-41
	error$ = ~errorKeywords$
	ret2 = 1
	
	if noOfTabs >= 2 and jpegStream=0 then 
		ret2 = setVideoImageAdvanced2(#txtIPRatio2$,#chkForceIFrame2,#txtMin2$,#txtMax2$,#txtinit2$,_
									  #drpMEConfig2,#txtPacketSize2$,_
									  noOfRegions2,#txtreg1X2,#txtreg1Y2,#txtreg1wdt2,#txtreg1hgt2,_
									  #txtreg2X2,#txtreg2Y2,#txtreg2wdt2,#txtreg2hgt2,#txtreg3X2,_
									  #txtreg3Y2,#txtreg3wdt2,#txtreg3hgt2)			'TR-41
		error$ += ~errorKeywords$	
	end if
	ret3 = 1
	if noOfTabs = 3 then 
		ret3 = setVideoImageAdvanced3(#txtIPRatio3$,#chkForceIFrame3,#txtMin3$,#txtMax3$,#txtinit3$,_
									  #drpMEConfig3,#txtPacketSize3$,_
									  noOfRegions3,#txtreg1X3,#txtreg1Y3,#txtreg1wdt3,#txtreg1hgt3,_
									  #txtreg2X3,#txtreg2Y3,#txtreg2wdt3,#txtreg2hgt3,_
									  #txtreg3X3,#txtreg3Y3,#txtreg3wdt3,#txtreg3hgt3)	'TR-41
		error$ += ~errorKeywords$
	end if
	
	if ret1>0 and ret2>0 and ret3>0 then 	
		saveSuccess = 1
	else 
		saveSuccess = 0
	end if
	
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
		#lblsuccessmessage$ = "Video - Advanced setting saved to camera "+~title$		'TR-35	
		isMessageDisplayed = 1														'TR-35		
	else 
		if ~keywordDetFlag = 1 then
			msgbox("Video - Advanced setting for \n"+error$+"\nfailed for the camera "+~title$)
		else
			msgbox("Video - Advanced setting failed for the camera "+~title$)
		endif	   
	endif
	~changeFlag = 0		
	
	if validateFlag = 1 then
		loadurl("!videoImageAdvanced.frm&noOfTabs="+noOfTabs+"&isMessageDisplayed="+isMessageDisplayed)
	end if
	
End Sub


/***********************************************************
'** validateCtrlValues
 *	Description: 
 *		To validate user input values

 *	Created by: Franklin On 2009-05-18 12:08:07

 ***********************************************************/
function validateCtrlValues()
	
	validateCtrlValues=1
	validateFlag = 1

	if #txtpacketsize1 > 100 then		
		msgbox("Packet Size should allow values between 0 to 100")
		#fradvanced.curtab = 0
		setfocus("txtpacketsize1")
		validateCtrlValues=0	
		validateFlag = 0			'TR-15
	elseif #txtmax1 < #txtmin1 then
		msgbox("QP value Max should be greater than Min")
		#fradvanced.curtab = 0
		setfocus("txtmax1")
		validateCtrlValues=0	
		validateFlag = 0	
	elseif jpegStream <> 2 and #txtpacketsize2 > 100 and  (noOfTabs = 2 or  noOfTabs = 3) then		
		msgbox("Packet Size should allow values between 0 to 100")
		#fradvanced.curtab = 1
		setfocus("txtpacketsize2")
		validateCtrlValues=0	
		validateFlag = 0			'TR-15
	elseif jpegStream <> 2  and #txtmax2 < #txtmin2  and  (noOfTabs = 2 or  noOfTabs = 3) then		
		msgbox("QP value Max should be greater than Min")
		#fradvanced.curtab = 1
		setfocus("txtmax2")
		validateCtrlValues=0	
		validateFlag = 0	
	elseif #txtmax3 < #txtmin3 then
		msgbox("QP value Max should be greater than Min")
		#fradvanced.curtab = 2
		setfocus("txtmax3")
		validateCtrlValues=0	
		validateFlag = 0	
	elseif #txtpacketsize3 > 100 and noOfTabs = 3  then		
		msgbox("Packet Size should allow values between 0 to 100")
		#fradvanced.curtab = 2
		setfocus("txtpacketsize3")
		validateCtrlValues=0	
		validateFlag = 0			'TR-15
	endif
	
	
End function

/***********************************************************
'** addTabImage
 *	Description:Used to Add the Tab images in Frame
 *		
 *		
 *	Params:
 *	Created by: C.Balaji On 2009-05-11 11:13:34
 *	History: 
 ***********************************************************/
sub addTabImage()
	getimage(TabsImagesA$,0,0,90,30,2,1,"!stream_1.bin")
	getimage(TabsImagesB$,0,0,90,30,2,1,"!stream_2.bin")
	getimage(TabsImagesC$,0,0,90,30,2,1,"!stream_3.bin")
	#fradvanced.tabheight=35	
	#fradvanced.curtab=0
	#fradvanced.paneimage(0)=TabsImagesA$
	#fradvanced.paneimage(1)=TabsImagesB$
	#fradvanced.paneimage(2)=TabsImagesC$
End Sub   

'Display cursor in control focus event else hide cursor
Sub chkForceIFrame1_Focus
	showcursor(1)
End Sub

Sub chkForceIFrame1_Blur
	showcursor(3)
End Sub

Sub optUMV1_Focus
	showcursor(1)
End Sub

Sub chkFaceDetect1_Focus
	showcursor(1)
End Sub

Sub chkFaceDetect1_Blur
	showcursor(3)
End Sub

Sub chkForceIFrame2_Focus
	showcursor(1)
End Sub

Sub chkForceIFrame2_Blur
	showcursor(3)
End Sub

Sub optUMV2_Focus
	showcursor(1)
End Sub

Sub chkFaceDetect2_Blur
	showcursor(3)
End Sub

Sub chkFaceDetect2_Focus
	showcursor(1)
End Sub

Sub chkForceIFrame3_Focus
	showcursor(1)
End Sub

Sub chkForceIFrame3_Blur
	showcursor(3)
End Sub

Sub optUMV3_Focus
	showcursor(1)
End Sub

Sub chkFaceDetect3_Blur
	showcursor(3)
End Sub

Sub chkFaceDetect3_Focus
	showcursor(1)
End Sub

/***********************************************************
'** btnBack_Click
 *	Description: 
 *		To load the videoImageSettings.frm when back button is pressed	
 *		
 *	Created by: Franklin Jacques.K  On 2009-07-16 14:40:55
 *	History: 
 ***********************************************************/
Sub btnBack_Click	
	chkValueMismatch()
	if ~changeFlag = 1	 then 
		msgbox("Do you want to save the changes",3)
		if Confirm()=1 then
			savePage()		
			Form_complete()				
		else 	
			~changeFlag = 0		
		endif 
	end if
	loadurl("!videoImageSettings.frm")
End Sub

/***********************************************************
'** form_Mouseclick
 *	Description: 
 *		To get the focus on the control
 *		
 *	Params:
'*		x: Numeric - mouse click x value
 *		y: Numeric - mouse click y value
 *	Created by:Vimala  On 2009-07-16 11:27:46
 *	History: 
 ***********************************************************/
sub form_Mouseclick(x,y)
	call getFocus()	
End Sub



/***********************************************************
'** btnConfigure1_Click
 *	Description: 
              To display the region of interest Frame 
              set the url with respect to the current stream
 *  Method: setDrpRegionValues()- to set the region values to the 
                                  dropdown boxes
            showRegionValues- to show the currently selected region co=ordinates
            btnrefresh_Click- to refresh the values of the textboxes to show the
							  currently selected region co-ordinates
 *	Created by: Franklin Jacques.K  On 2009-09-18 10:34:11
 *	History: 
 ***********************************************************/
Sub btnConfigure1_Click
	if canReload = 1 then
		dimi a,ret 
		dims url$,value$
			
		if #chkFaceDetect1.checked=1 then		
			if ValidateRegionValues(1) = 0 then 
				call setDrpRegionValues()
				call showRegionValues(1)
				call btnrefresh_Click()
				 if ErrorROIFlag = 0 then 
					#frmRegOfInterest.hidden=0
					a=#gdoVideo.stop(1)
					#gdoVideo.hidden=1
					#gdobg.hidden=1
					#cmdsave.hidden=1
					#cmdcancel.hidden=1
					#btnback.hidden=1
					value$ =rtspUrl$(0)  
					a=#gdoVideoROI.Play(value$)								//godVideoROI-gdo control for region of interest
					#gdoVideoROI.hidden=0
				 endif
			else
				msgbox("Please enter valid X,Y,Widht,Height for stream1")
			endif	
		endif
		
		ErrorROIFlag=0
	end if
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
function ValidateRegionValues(dimi tabNo)
	ValidateRegionValues = 0
	
	dims ctrlName$,ctrlX$, ctrlY$
	dims regCoordinates$(4) = ("X","Y","wdt","hgt")
	dimi xRes,yRes,i,j,errorFlag = 0	
	
	getCurStreamResolution(stream$(tabNo-1),xRes,yRes)
	
	for i = 1 to 3
		for j = 0 to ubound(regCoordinates$)
			ctrlName$ = "txtreg"+i+regCoordinates$(j)+tabNo
					
			if j = 0 or j=2 then
				if j=2 then
					ctrlX$ = "txtreg"+i+regCoordinates$(0)+tabNo
					if (#{ctrlName$} + #{ctrlX$}) > xRes then
						ValidateRegionValues = 1
						errorFlag = 1
						break
					endif
				endif
				if #{ctrlName$} > xRes then 
					ValidateRegionValues = 1
					errorFlag = 1
					break				
				end if
			elseif j = 1 or j = 3 then
				if j=3 then
					ctrlY$ = "txtreg"+i+regCoordinates$(1)+tabNo
					if (#{ctrlName$} + #{ctrlY$}) > yRes then
						ValidateRegionValues = 1
						errorFlag = 1
						break
					endif
				endif
				if #{ctrlName$} > yRes then 
					ValidateRegionValues = 1
					errorFlag = 1
					break				
				end if
			endif			
		next		
	next
	
	setfocus(ctrlName$)
End Function

/***********************************************************
'** showRegionValues
 *	Description: 
 *		  To populate the region Values and display the selected region in the 
          ActiveX control
 *		
 *	Methods : deCalcResolution- to calculate the the region Values for the current ActiveX Controls resolution
 *		dimi Index: Numeric - 
 *	Created by: Franklin Jacques.K On 2009-09-23 17:58:03
 *	History: 
 ***********************************************************/
sub showRegionValues(dimi Index)
	Dims regOfInterest$
	if index = 1 then 
		call deCalcResolution(1,#txtreg1X1$,#txtreg1Y1$,#txtreg1wdt1$,#txtreg1hgt1$,regOfInterest$)
		if ErrorROIFlag=1 then
			iff FocusFlag = 1 then setfocus("txtreg1wdt1")
			iff FocusFlag = 2 then setfocus("txtreg1hgt1")
			FocusFlag = 0
			return
		endif
		PPrint "showRegionValues: " + regOfInterest$
		#gdoVideoROI.RegionOfInterest(regOfInterest$)
		call deCalcResolution(2,#txtreg2X1$,#txtreg2Y1$,#txtreg2wdt1$,#txtreg2hgt1$,regOfInterest$)
		if ErrorROIFlag=1 then
			iff FocusFlag = 1 then setfocus("txtreg2wdt1")
			iff FocusFlag = 2 then setfocus("txtreg2hgt1")
			FocusFlag = 0
			return
		endif
		#gdoVideoROI.RegionOfInterest(regOfInterest$)
		call deCalcResolution(3,#txtreg3X1$,#txtreg3Y1$,#txtreg3wdt1$,#txtreg3hgt1$,regOfInterest$)
		if ErrorROIFlag=1 then
			iff FocusFlag = 1 then setfocus("txtreg3wdt1")
			iff FocusFlag = 2 then setfocus("txtreg3hgt1")
			FocusFlag = 0
			return
		endif
		#gdoVideoROI.RegionOfInterest(regOfInterest$)
	elseif index = 2 then 
		call deCalcResolution(1,#txtreg1X2$,#txtreg1Y2$,#txtreg1wdt2$,#txtreg1hgt2$,regOfInterest$)
		if ErrorROIFlag=1 then
			iff FocusFlag = 1 then setfocus("txtreg1wdt2")
			iff FocusFlag = 2 then setfocus("txtreg1hgt2")
			FocusFlag = 0
			return
		endif
		#gdoVideoROI.RegionOfInterest(regOfInterest$)
		call deCalcResolution(2,#txtreg2X2$,#txtreg2Y2$,#txtreg2wdt2$,#txtreg2hgt2$,regOfInterest$)
		if ErrorROIFlag=1 then
			iff FocusFlag = 1 then setfocus("txtreg2wdt2")
			iff FocusFlag = 2 then setfocus("txtreg2hgt2")
			FocusFlag = 0
			return
		endif
		#gdoVideoROI.RegionOfInterest(regOfInterest$)
		call deCalcResolution(3,#txtreg3X2$,#txtreg3Y2$,#txtreg3wdt2$,#txtreg3hgt2$,regOfInterest$)
		if ErrorROIFlag=1 then
			iff FocusFlag = 1 then setfocus("txtreg3wdt2")
			iff FocusFlag = 2 then setfocus("txtreg3hgt2")
			FocusFlag = 0
			return
		endif
		#gdoVideoROI.RegionOfInterest(regOfInterest$)
	elseif index = 3 then
		call deCalcResolution(1,#txtreg1X3$,#txtreg1Y3$,#txtreg1wdt3$,#txtreg1hgt3$,regOfInterest$)
		if ErrorROIFlag=1 then
			iff FocusFlag = 1 then setfocus("txtreg1wdt3")
			iff FocusFlag = 2 then setfocus("txtreg1hgt3")
			FocusFlag = 0
			return
		endif
		#gdoVideoROI.RegionOfInterest(regOfInterest$)
		call deCalcResolution(2,#txtreg2X3$,#txtreg2Y3$,#txtreg2wdt3$,#txtreg2hgt3$,regOfInterest$)
		if ErrorROIFlag=1 then
			iff FocusFlag = 1 then setfocus("txtreg2wdt3")
			iff FocusFlag = 2 then setfocus("txtreg2hgt3")
			FocusFlag = 0
			return
		endif
		#gdoVideoROI.RegionOfInterest(regOfInterest$)
		call deCalcResolution(3,#txtreg3X3$,#txtreg3Y3$,#txtreg3wdt3$,#txtreg3hgt3$,regOfInterest$)
		if ErrorROIFlag=1 then
			iff FocusFlag = 1 then setfocus("txtreg3wdt3")
			iff FocusFlag = 2 then setfocus("txtreg3hgt3")
			FocusFlag = 0
			return
		endif
		#gdoVideoROI.RegionOfInterest(regOfInterest$)
	endif
End Sub

/***********************************************************
'** deCalcResolution
 *	Description: 
 *		To calculate the the region Values for the current ActiveX Controls resolution
 *		
 *	Params:
'*		dimi Index: Numeric - current stream Index
'*		dims regX$: String - value of the text control 
'*		dims regY$: String - value of the text control 
'*		dims regW$: String - value of the text control 
 *		dims regH$: String - value of the text control 
 *      byref dims regOfInterest$ : String - Return region values concat with &
 *	Created by:  On 2009-09-23 18:10:36

 ***********************************************************/
sub deCalcResolution(dimi Index, dims regX$, dims regY$, dims regW$, dims regH$, byref dims regOfInterest$)
	Dimi xRes,yRes
	 
	getCurStreamResolution(stream$(#fradvanced.curtab),xRes,yRes)
	iff xRes<=0 or yRes<=0 then return
	dimi regX, regY, regW, regH
	dimi tabNo, MinValue
	pprint gdoWidth;gdoHeight;xRes;yRes
	MinValue = round(xRes/gdoWidth)
	MinValue = MinValue*2
	regX = round((atol(regX$)*gdoWidth)/xRes)
	regY = round((atol(regY$)*gdoHeight)/yRes)
	regW = round((atol(regW$)*gdoWidth)/xRes)
	tabNo = #fradvanced.curtab
	tabNo+=1
	if regW<2 and atol(regW$)<>0 then 
		MsgBox("Please enter valid width and height for Stream"+tabNo+"\nMin W : "+MinValue+" & Min H : "+MinValue+"")
		ErrorROIFlag=1
		FocusFlag = 1
		return
	endif
	regH = round((atol(regH$)*gdoHeight)/yRes)
	if regH<2 and atol(regH$)<>0 then 
		MsgBox("Please enter valid width and height for Stream"+tabNo+"\nMin W : "+MinValue+" & Min H : "+MinValue+"")
		ErrorROIFlag=1
		FocusFlag = 2
		return
	endif
	if (atol(regW$)<>0 and atol(regH$)=0) then 
		MsgBox("Please enter valid width and height for Stream"+tabNo+"\nMin W : "+MinValue+" & Min H : "+MinValue+"")
		ErrorROIFlag=1
		FocusFlag = 2
		return
	elseif (atol(regH$)<>0 and atol(regW$)=0) then 
		MsgBox("Please enter valid width and height for Stream"+tabNo+"\nMin W : "+MinValue+" & Min H : "+MinValue+"")
		ErrorROIFlag=1
		FocusFlag = 1
		return
	endif
	regOfInterest$ = Index+"&"+regX+"&"+regY+"&"+regW+"&"+regH
	pprint regOfInterest$
End Sub

/***********************************************************
'** setDrpRegionValues
 *	Description: Add three regions to drop downs
 
 *	Created by:  On 2009-09-21 16:53:42
 ***********************************************************/
sub setDrpRegionValues()
	#drpregion1.removeAll()
	#drpregion2.removeAll()
	#drpregion3.removeAll()
	#drpregion1.additem("0","Region1")
	#drpregion1.additem("1","Region2")
	#drpregion1.additem("2","Region3")
	#drpregion2.additem("0","Region1")
	#drpregion2.additem("1","Region2")
	#drpregion2.additem("2","Region3")
	#drpregion3.additem("0","Region1")
	#drpregion3.additem("1","Region2")
	#drpregion3.additem("2","Region3")
	#drpregion1.selIdx=0
	#drpregion2.selIdx=1
	#drpregion3.selIdx=2
End Sub

/***********************************************************
'** btnConfigure2_Click
 *	Description: 
              To display the region of interest Frame 
              set the url with respect to the current stream
 *  Method: setDrpRegionValues()- to set the region values to the 
                                  dropdown boxes
            showRegionValues- to show the currently selected region co=ordinates
            btnrefresh_Click- to refresh the values of the textboxes to show the
							  currently selected region co-ordinates
 *	Created by: Franklin Jacques.K  On 2009-09-18 10:34:11
 *	History: 
 ***********************************************************/
Sub btnConfigure2_Click
	if canReload = 1 then
		Dimi a,ret
		dims url$,value$
		
		if #chkfacedetect2.checked=1 then
			if ValidateRegionValues(2) = 0 then 
				call setDrpRegionValues()
				call showRegionValues(2)
				call btnrefresh_Click
				if ErrorROIFlag = 0 then 
					#frmRegOfInterest.hidden=0
					a=#gdoVideo.stop(1)
					#gdoVideo.hidden=1
					#gdoVideo.hidden=1
					#gdobg.hidden=1
					#cmdsave.hidden=1
					#cmdcancel.hidden=1
					#btnback.hidden=1
					value$ = rtspUrl$(1)  
					a=#gdoVideoROI.Play(value$)								//godVideoROI-gdo control for region of interest
					#gdoVideoROI.hidden=0
				endif
			else
				msgbox("Please enter valid X,Y,Widht,Height for stream2")
			endif
		endif
		
		ErrorROIFlag=0
	end if
End Sub


/***********************************************************
'** btnConfigure3_Click
 *	Description: 
              To display the region of interest Frame 
              set the url with respect to the current stream
 *  Method: setDrpRegionValues()- to set the region values to the 
                                  dropdown boxes
            showRegionValues- to show the currently selected region co=ordinates
            btnrefresh_Click- to refresh the values of the textboxes to show the
							  currently selected region co-ordinates
 *	Created by: Franklin Jacques.K  On 2009-09-18 10:34:11
 *	History: 
 ***********************************************************/
Sub btnConfigure3_Click
	if canReload = 1 then
		Dimi a,ret
		dims url$,value$
		
		if #chkfacedetect3.checked=1 then
			if ValidateRegionValues(3) = 0 then 
				call setDrpRegionValues()
				call showRegionValues(3)
				call btnrefresh_Click()
				if ErrorROIFlag = 0 then 
					#frmRegOfInterest.hidden=0
					a=#gdoVideo.stop(1)
					#gdoVideo.hidden=1
					#gdoVideo.hidden=1
					#gdobg.hidden=1
					#cmdsave.hidden=1
					#cmdcancel.hidden=1
					#btnback.hidden=1
					value$ = rtspUrl$(2)  
					a=#gdoVideoROI.Play(value$)								//godVideoROI-gdo control for region of interest
					#gdoVideoROI.hidden=0		
				endif
			else
				msgbox("Please enter valid X,Y,Widht,Height for stream3")
			endif
		endif
		
		ErrorROIFlag=0
	end if
End Sub


/***********************************************************
'** btnROI_Cancel_Click
 *	Description: To cancel all selected regions
 *		
 *		
 *	Methods: frmregofinterest_cancel- To cancel all the region selected recently and 
			 set back to the initial values
			
 *	Created by: Franklin Jacques.K On 2009-09-21 11:27:51
 ***********************************************************/
Sub btnROI_Cancel_Click
	call frmregofinterest_cancel()	
End Sub

/***********************************************************
'** setRegionValuesToMainScreen
 *	Description: 
 *		To set the values of selected region to the text boxes 
		of the Main screen(Video Advanced  setting)
 *		
 *	Params:
 *	Created by:Franklin Jacques.K  On 2009-10-06 16:55:52
 *	History: 
 ***********************************************************/
sub setRegionValuesToMainScreen()
	
	dims ctrlNameROI$, ctrlNameMainScreen$
	dims regCoordinates$(4) = ("X","Y","wdt","hgt")
	dims regCoordinatesOfMainScreen$(4) = ("X","Y","W","H")
	dimi i,j,tabNo,drpVal
	dims drpName$
	tabNo = #fradvanced.curtab
	tabNo = tabNo +1
	
	for i = 1 to 3
		drpName$ = "drpregion"+i+"$"
		drpVal = atol(#{drpName$}$) + 1
		for j = 0 to ubound(regCoordinates$)
			ctrlNameMainScreen$ = "txtreg"+drpVal+regCoordinates$(j)+tabNo
			ctrlNameROI$ = "txt"+regCoordinatesOfMainScreen$(j)+i
			pprint ctrlNameROI$ 
			pprint ctrlNameMainScreen$
			#{ctrlNameMainScreen$}$ = #{ctrlNameROI$}$
		next	
	next
End Sub


/***********************************************************
'** btnROI_Save_Click
 *	Description: 
 *		set the region values of the controls(region of interest) to the 
        controls of the VideoImageAdvanced setting
 *		
 *	Methods: regionSelected- the selected region
 *	Created by: Franklin Jacques.K On 2009-09-21 14:33:48
 *	History: 
 ***********************************************************/
Sub btnROI_Save_Click
	call regionSelected()	
	Dimi ret 
	#lblErrMsg.hidden = 0
	if #drpregion1$<>#drpregion2$ and #drpregion2$<>#drpregion3$ and  #drpregion3$<>#drpregion1$ then
		MsgColorFlag = -1
		btnROI_Cancel_Click()
		call regionSelected()	
		#lblErrMsg.hidden = 1
		call setRegionValuesToMainScreen()
	else		
		#lblErrMsg$="Drop down boxes should have different values"
		MsgColorFlag = 1
	endif

End Sub


/***********************************************************
'** regionSelected
 *	Description: 
 *		set the region values of the controls(region of interest) from the region selected
		in the ActiveX control
		
 *	Methods: RoiCalculation- to calculate the region values selected using the Mouse  
 *	Created by: Franklin Jacques.K On 2009-09-21 16:45:57

 ***********************************************************/
sub regionSelected()
	dims region$(5)
	RoiCalculation(strtoint(#drpregion1$), region$)
	
	if strtoint(region$(0))=1 then
		#txtX1$= strtoint(region$(1))                      
		#txtY1$= strtoint(region$(2))
		#txtW1$= strtoint(region$(3))                 
		#txtH1$= strtoint(region$(4))  
	elseif strtoint(region$(0))=2 then 
		#txtx2$= strtoint(region$(1))
		#txty2$= strtoint(region$(2))
		#txtw2$= strtoint(region$(3)) 
		#txth2$= strtoint(region$(4))  
	elseif strtoint(region$(0))=3 then 
		#txtx3$= strtoint(region$(1))
		#txty3$= strtoint(region$(2))
		#txtw3$= strtoint(region$(3)) 
		#txth3$= strtoint(region$(4))
	endif
	RoiCalculation(strtoint(#drpregion2$), region$)
	
	if strtoint(region$(0))=1 then
		#txtX1$= strtoint(region$(1))                      
		#txtY1$= strtoint(region$(2))
		#txtW1$= strtoint(region$(3))                 
		#txtH1$= strtoint(region$(4))   
	elseif strtoint(region$(0))=2 then 
		#txtx2$= strtoint(region$(1))
		#txty2$= strtoint(region$(2))
		#txtw2$= strtoint(region$(3)) 
		#txth2$= strtoint(region$(4))  
	elseif strtoint(region$(0))=3 then 
		#txtx3$= strtoint(region$(1))
		#txty3$= strtoint(region$(2))
		#txtw3$= strtoint(region$(3)) 
		#txth3$= strtoint(region$(4))
	endif
	RoiCalculation(strtoint(#drpregion3$), region$)                    
	
	if strtoint(region$(0))=1 then
		#txtX1$= strtoint(region$(1))                      
		#txtY1$= strtoint(region$(2))
		#txtW1$= strtoint(region$(3))                 
		#txtH1$= strtoint(region$(4))   
	elseif strtoint(region$(0))=2 then 
		#txtx2$= strtoint(region$(1))
		#txty2$= strtoint(region$(2))
		#txtw2$= strtoint(region$(3)) 
		#txth2$= strtoint(region$(4))  
	elseif strtoint(region$(0))=3 then 
		#txtx3$= strtoint(region$(1))
		#txty3$= strtoint(region$(2))
		#txtw3$= strtoint(region$(3)) 
		#txth3$= strtoint(region$(4))
	endif

End Sub

/***********************************************************
'** RoiCalculation
 *	Description: 
 *		To calculate the region values selected  for the stream resolution 

 *	Created by:  On 2009-09-21 14:11:18

 ***********************************************************/
sub RoiCalculation(dimi regionIndex, byref dims regionArray$())
	dims strVal$, tempVal$, region$
	dimi ret, xRes, yRes, regX, regY, res
	tempVal$=#gdoVideoROI.RegionOfInterest$
	PPrint "RoiCalculation:" + tempVal$
	ret=split(strVal$,tempVal$,"|")
	
	if ret>0 then
		split(region$,strVal$(regionIndex), "&")
		
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
		
		getCurStreamResolution(stream$(#fradvanced.curtab),xRes,yRes)
		iff xRes<=0 or yRes<=0 then return
		regionArray$(0)=region$(0)
		regX = atol(region$(1))
		regY = atol(region$(2))
		
		res = round((regX*xRes)/gdoWidth)
		regionArray$(1)=res 
		res = round((regY*yRes)/gdoHeight)
		regionArray$(2)=res  
		res = round((width*xRes)/gdoWidth)
		regionArray$(3)=res  
		res = round((height*yRes)/gdoHeight)
		regionArray$(4)=res  
	endif
End Sub

/***********************************************************
'** frmregofinterest_cancel
 *	Description: 
 *		 To cancel all the region selected recently and 
		 set back to the initial values
 *		
 *	Params:
 *	Created by: Farnklin Jacques.K  On 2009-09-21 14:52:15
 *	History: 
 ***********************************************************/
sub frmregofinterest_cancel()
	dimi a
	#frmregofinterest.hidden=1
	a=#gdoVideoROI.stop(1)
	#gdoVideoROI.hidden=1
	MsgColorFlag = -1
	call disp_streams()
	if #fradvanced.curtab=0 then 
		#chkFaceDetect1.checked = 1
	elseif #fradvanced.curtab=1 then 
		#chkfacedetect2.checked = 1
	elseif #fradvanced.curtab=2 then 
		#chkfacedetect3.checked = 1
	endif
	#gdobg.hidden=0
	#cmdsave.hidden=0
	#cmdcancel.hidden=0
	#btnback.hidden=0
	#lblErrMsg.hidden = 1
	setfocus("rosubmenu[0]")	
End Sub


/***********************************************************
'** btnrefresh_Click
 *	Description: 
 *		To set the region values for the controls based on the selected region on the 
			 ActiveX control
 *		
 *	Methods: regionSelected- To set the region values for the controls based on the selected region on the 
			 ActiveX control
 *	Created by: Franklin Jacques.K On 2009-09-23 16:51:34
 *	History: 
 ***********************************************************/
Sub btnrefresh_Click
	call regionSelected()
	#lblErrMsg.hidden = 1
End Sub



/***********************************************************
'** btnDelete1_Click
 *	Description: 
 *		To delete the selected region(Stream1) of the Activex Control
 *		
 *	Params:
 *	Created by:  On 2009-09-21 18:34:05
 *	History: 
 ***********************************************************/
Sub btnDelete1_Click
	dimi RegNo
	RegNo=strtoint(#drpRegion1$)+1
	#gdoVideoROI.RegionOfInterest("1&0&0&0&0")
	call btnrefresh_click
End Sub



/***********************************************************
'** btnDelete2_Click
 *	Description: 
 *		 To delete the selected region(Stream2) of the Activex Control
 *		
 *	Params:
 *	Created by: Franklin Jacques.K On 2009-10-08 16:58:10
 *	History: 
 ***********************************************************/
Sub btnDelete2_Click	
	dimi RegNo
	RegNo=strtoint(#drpRegion2$)+1	
	#gdoVideoROI.RegionOfInterest("2&0&0&0&0")
	call btnrefresh_click
End Sub



/***********************************************************
'** btnDelete3_Click
 *	Description: 
 *			To delete the selected region(Stream2) of the Activex Control	
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-10-08 16:59:16
 *	History: 
 ***********************************************************/
Sub btnDelete3_Click
	dimi RegNo
	RegNo=strtoint(#drpRegion3$)+1
	#gdoVideoROI.RegionOfInterest("3&0&0&0&0")
	call btnrefresh_click
End Sub

/***********************************************************
'** txtreg1X1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1X1_focus
	rule=7
End Sub


/***********************************************************
'** txtreg1Y1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K   On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1Y1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1Wdt1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K   On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1Wdt1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1Hgt1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1Hgt1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2X1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2X1_focus
	rule=7
End Sub


/***********************************************************
'** txtreg2Y1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2Y1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2Wdt1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2Wdt1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2Hgt1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2Hgt1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3X1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by:  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3X1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3Y1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3Y1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3wdt1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3wdt1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3hgt1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3hgt1_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1X2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1X2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1Y2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1Y2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1wdt2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1wdt2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1hgt2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1hgt2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2X2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2X2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2Y2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by:Franklin Jacques.K   On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2Y2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2wdt2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2wdt2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2hgt2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2hgt2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3X2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3X2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3Y2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3Y2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3wdt2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3wdt2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3Hgt2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3Hgt2_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1X3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1X3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1Y3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1Y3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1wdt3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by:  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1wdt3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg1hgt3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg1hgt3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2X3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2X3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2Y3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2Y3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2wdt3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2wdt3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg2hgt3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg2hgt3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3X3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3X3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3Y3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3Y3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3wdt3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by:  Franklin Jacques.K On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3wdt3_focus
	rule=7
End Sub

/***********************************************************
'** txtreg3Hgt3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
sub txtreg3Hgt3_focus
	rule=7
End Sub

/***********************************************************
'** txtPacketSize1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtPacketSize1_focus
	rule=7
End Sub

/***********************************************************
'** txtMin1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtMin1_focus
	rule=7
End Sub

/***********************************************************
'**txtIPRatio1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtIPRatio1_focus
	rule=7
End Sub

/***********************************************************
'**txtMax1_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtMax1_focus
	rule=7
End Sub

/***********************************************************
'**txtPacketSize2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtPacketSize2_focus
	rule=7
End Sub

/***********************************************************
'**txtMin2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtMin2_focus
	rule=7
End Sub

/***********************************************************
'**txtIPRatio2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtIPRatio2_focus
	rule=7
End Sub

/***********************************************************
'**txtMax2_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtMax2_focus
	rule=7
End Sub

/***********************************************************
'**txtPacketSize3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtPacketSize3_focus
	rule=7
End Sub

/***********************************************************
'**txtMin3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtMin3_focus
	rule=7
End Sub

/***********************************************************
'**txtIPRatio3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtIPRatio3_focus
	rule=7
End Sub

/***********************************************************
'**txtMax3_focus
 *	Description: 
 *	     Validation for the control to allow only the Numeric Values
 *		
 *	Params:
 *	Created by: Franklin Jacques.K  On 2009-09-28 11:48:07
 *	History: 
 ***********************************************************/
Sub txtMax3_focus
	rule=7
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
