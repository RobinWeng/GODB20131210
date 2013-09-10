/*****************************************************************************
 * PROJECT NAME          : IPNC              							               *        
 * MODULE NAME           : Video Settings                       			           *
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
 * PERMISSION FROM GoDBTech.   
 ***************************************************************************/

dimi timerCount

#include "defines.inc" 
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"

option(4+1)

#define GDO_X			   673	
#define GDO_Y			   85	
#define GDO_W              288
#define GDO_H              200

dims TabsImagesA$,TabsImagesB$,TabsImagesC$,TabsImagesD$

dimi noofctrl															'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS                                  
dims LabelName$(noofctrl)                                               'Form controls name
dimi XPos(noofctrl)                                                     'Form controls X position
dimi YPos(noofctrl)                                                     'Form controls Y position
dimi Wdh(noofctrl)                                                      'Form controls Width position
dimi height(noofctrl)                                                   'Form controls height position
dims videocodecname$,videocodecmodename$, videocodecresname$ 
dimi videocodecmode,videocodecres   
dimi videocodec      

#include "videoImageSettings.inc"
dimi textenable1,textenable2,textenable3
dimi rule
settimer(1000)
showcursor(3)
dimi saveStream1,saveStream2,saveStream3
dims stream$(4),rtspUrl$(4)
dimi noOfTabs                                       'parameter which is passed to Video/Advanced setting

dimi displayCount,isMessageDisplayed				'TR-35  
displayCount = 1									'TR-35

dims framerateNameAll1$,framerateNameAll2$,framerateNameAll3$
dimi CodecModeCount
Dims arrCodeMode$(1,2)
dims streamType1$,streamType2$,streamType3$
dims ctrlValues$(noofctrl)
dimi saveSuccess = 0	 'Value of 1 is success
dimi animateCount = 0 	 ' Stores the count for the animation done.
dims error$ = "" 		 'Stores the error returned while saving.
dimi isAdvancedClicked = 0 			' Set to 1 when advanced button is clicked
end


/***********************************************************
'** form_timer
 *	Description: To set wait flag when switching between forms
 *				 Display save success message for 5 secs
 
 *	Created by:Franklin  On 2009-06-30 16:14:12
 
 ***********************************************************/
Sub form_timer
	~wait = ~wait +1						'added by Franklin to set wait flag when switching between forms	
	
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
'** cmdadvanced_Click
 *	Description: save video settings before loading 
 *				 video --> advanced only if some modification done in video setting screen

 *  Methods: validateCtrlValues- To validate the controls before  saving the page 
			 displayframes- To display the current frame and the ontrols in it 
			 savePage- To save the page( set the values(parameters) to the camera
			 setInitialValues - loaded saved video values
 *	Created by: Franklin On 2009-05-12 05:50:38
 ***********************************************************/
Sub cmdadvanced_Click	
	showcursor(0)
	dims ddValue$
	if canReload = 1 then	
		if ~changeFlag = 1	 then 
			msgbox("Do you want to save the changes",3)
			if Confirm()=1 then
				dimi streamNo		
				streamNo=  #ddStreamType.selidx			
				if streamNo = 0 then
					saveStream1 = 1
					saveStream2 = 0
					saveStream3 = 0				
				elseif streamNo = 1 then
					saveStream1 = 1
					saveStream2 = 1
					saveStream3 = 0	
				elseif streamNo = 2 then
					saveStream1 = 1
					saveStream2 = 1
					saveStream3 = 1	
				end if			
				
				if validateCtrlValues() = 0 then 
					frvideoimage_change()
					return
				endif
				
				isAdvancedClicked = 1
				savePage()
						
			else 
				~changeFlag = 0		
				call setInitialValues()
				noOfTabs = atol(#ddstreamtype$)+1
				noOfTabs = atol(#ddstreamtype$)+1
				if noOfTabs = 1  and find(ucase$(#ddcodec.itemlabel$(#ddcodec.selidx)),"JPEG") > 0 then
					#cmdadvanced.hidden = 1
					call ddCodec_Change()
					return
				else 
					#cmdadvanced.hidden = 0
					loadurl("!videoImageAdvanced.frm&noOfTabs="+noOfTabs)	
				end if 	
			endif 
		else 		
			~changeFlag = 0		
			call setInitialValues()
			noOfTabs = atol(#ddstreamtype$)+1
			if noOfTabs = 1  and find(ucase$(#ddcodec.itemlabel$(#ddcodec.selidx)),"JPEG") > 0 then
				#cmdadvanced.hidden = 1
				call ddCodec_Change()
				return
			else 
				#cmdadvanced.hidden = 0
				loadurl("!videoImageAdvanced.frm&noOfTabs="+noOfTabs)	
			end if 			
		endif	
		
		isAdvancedClicked = 1 
	end if
	
End Sub

/***********************************************************
'** Form_Load
 *	Description: Align controls, get and display all the values from ipnc
 
	Methods Called:
 				 loadIniValues() - Fetch values for keyword from ini.htm.
 				 displayControls - Display controls based on the screen resolution .
				 setInitialValues() - Get values for all screen controls
				 ddCodec_Change() - Display resolution based on selected codec
				 displayframes() - To display the current frame and the controls in it 
 				 createGDOControl - Create video player based on the stream resolution aspect ratio
				 showSubMenu - To display setting menu
				 selectSubMenu - Highlight selected setting screen		
				 		 
 *	Created by:Franklin  On 2009-07-16 11:28:39
 ***********************************************************/
Sub Form_Load
	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	
	Dimi curW ,curH
	curW = GDO_W * ~factorX
	curH = GDO_H * ~factorY
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	
	call setInitialValues()		
	call ddCodec_Change()
	call displayframes()	
		
	createGDOControl("gdoVideo",GDO_X,GDO_Y,GDO_W, GDO_H)
	
	showSubMenu(0,1)
	setfocus("rosubmenu")
	selectSubMenu()	
	setfocus("txtcameraname")
	#lblloading.hidden = 1	
	noOfTabs = atol(#ddstreamtype$)+1
	
	'TR-14
	#optencryptvideo$ = ""
	#optencryptvideo.disabled = 1
	#optencryptvideo[1].disabled = 1
	#optencryptvideo.fg = UNSELECTED_TXT_COLOR
	#optencryptvideo[1].fg = UNSELECTED_TXT_COLOR
	#optencryptvideo.selfg = UNSELECTED_TXT_COLOR
	#optencryptvideo[1].selfg = UNSELECTED_TXT_COLOR
	#lblencryptvideo.fg = UNSELECTED_TXT_COLOR
	#lblencryptvideo.selfg = UNSELECTED_TXT_COLOR
	#optencryptvideo.font = 2
	#optencryptvideo[1].font = 2
	
	'TR-16
	pprint find(ucase$(#ddcodec.itemlabel$(#ddcodec.selidx)),"JPEG")
	if noOfTabs = 1  and find(ucase$(#ddcodec.itemlabel$(#ddcodec.selidx)),"JPEG") > 0 then
		#cmdadvanced.hidden = 1
	else 
		#cmdadvanced.hidden = 0
	end if 
	
	#lblsuccessmessage$ = ""													'TR-35
	isMessageDisplayed = atol(request$("isMessageDisplayed"))
	if isMessageDisplayed = 1 then
		#lblsuccessmessage$ = "Video setting saved to camera "+~title$			'TR-35	
	end if
	
	call alignGDOCtrl(#frvideoimage.curtab)
	
	
	#ddStreamType.disabled=1
	#ddCodec.disabled=1
	#ddResolution.disabled=1
	#drpLocalDisplay.disabled=1
	#ddMirror.disabled=1
	#drpStream.disabled=1
	#drpVideoSize.disabled=1
	#ddFrameRate1.disabled=1
	#txtBitrate1.disabled=1
	#ddRateControl1.disabled=1
	#txtQualityFactor1.disabled=1
	#chkdetailinfo1.hidden = 1 
	
	
End Sub


/***********************************************************
'** Form_Paint
 *	Description: Gray Out encrypt video options
 *	Created by: Vimala  On 2009-11-05 15:51:11
 *	History: 
 ***********************************************************/
Sub Form_Paint			'TR-14
	#optencryptvideo$ = ""	
	putimage2(~optImage$,#optencryptvideo.x,#optencryptvideo.y,5,0,0)
	putimage2(~optImage$,#optencryptvideo[1].x,#optencryptvideo[1].y,5,0,0)
End Sub

/***********************************************************
'** AlignGDO
 *	Description: Call this function to align GDO control 
                 based on the screen resolution
 *	 
 *  Methods: loadStreamDetails- to load the current stream and the 
			 Stream Resolution
 *	Created by: S.Vimala On 2009-09-08 16:18:38
 *	History: 
 ***********************************************************/
Sub alignGDOCtrl(dimi streamNo)
	dimi gdoCurX, gdoCurY, gdoCurWidth, gdoCurHeight	
	Dimi xRatio,yRatio
	pprint stream$
	loadStreamDetails(stream$,rtspUrl$)           			'TR-04
	call addItemsToDropDown("ddstream", stream$, -1) 		'loads the stream to drop down              
	iff streamNo >= #ddstream.itemcount or streamNo<0 then streamNo=0
	~previewVideoRes$ = #ddstream.itemlabel$(streamNo)
	
	#frvideostream1.w = #lblEncryptVideo.x - #frvideoimage.x - 12
	#frvideostream2.w = #lblEncryptVideo.x - #frvideoimage.x - 12
	#frvideostream3.w = #lblEncryptVideo.x - #frvideoimage.x - 12
	#frvideoimage.w = #lblEncryptVideo.x - #frvideoimage.x - 10
	#frvideostream1.h = #chkdetailinfo1.y - #frvideoimage.y - 10		
	#frvideostream2.h = #chkdetailinfo1.y - #frvideoimage.y - 10	
	#frvideostream3.h = #chkdetailinfo1.y - #frvideoimage.y - 10	
	#frvideoimage.h = #frvideostream1.h + 40
	
	calVideoDisplayRatio(~previewVideoRes$,xRatio,yRatio)				' TR-04
	gdoCurX = GDO_X * ~factorX
	gdoCurY = GDO_Y * ~factorY
	gdoCurWidth  = GDO_W * ~factorX
	gdoCurHeight = GDO_H * ~factorY
	pprint gdoCurWidth;gdoCurHeight	
	checkAspectRatio(gdoCurWidth, gdoCurHeight,xRatio,yRatio)
	pprint gdoCurWidth;gdoCurHeight
	#gdobg.x=gdoCurX-1
	#gdobg.y=gdoCurY-1
	#gdobg.w = gdoCurWidth+1 
	#gdobg.h = gdoCurHeight+1	
	#gdoVideo.x = gdoCurX
	#gdoVideo.y = gdoCurY

	#gdoVideo.w = gdoCurWidth
	#gdoVideo.h = gdoCurHeight	
	#gdoVideo.paint(1)
	#gdobg.paint(1)
	#gdoVideo.Audio = 0	
End Sub

/***********************************************************
'** alignCtrls
 *	Description: 
 *		To align the controls in the frames for all the streams, 
		during the frame change event 

 *	Created by: vimala On 2009-05-12 05:55:42

 ***********************************************************/
Sub alignCtrls(dimi tabno)
	dims ctrlname$(21) = ("ddFrameRate","chkDate","chkTime","chkLogo","ddLogoPos", _
						  "chkText","txtCameratext","ddTextPos","lblFramerate", _
						  "lblTextPos","lblLogoPos","lblOverlay","txtBitrate","lblBitRate",_
						  "ddRateControl","lblRateControl","lblfps","lblkbps","chkdetailinfo",_
						  "lblQualityFactor","txtQualityFactor")
						  
	dimi i,ctrlLen
	dims controlName$,tempctrl$,tempctrl1$,temp$
	
	for i = 0 to ubound(ctrlname$)
		
		iff ctrlname$(i) = "" then continue
		
		controlName$ = ctrlname$(i)+tabno		
		tempctrl$ = ctrlname$(i)+"1"	
	
		#{controlName$}.x = #{tempctrl$}.x
		#{controlName$}.y = #{tempctrl$}.y		
		#{controlName$}.w = #{tempctrl$}.w	
	next
	
End Sub

/***********************************************************
'** frvideoimage_change
 *	Description: Display Bit rate,Rate conrol,Qaulity factor controls
				 based on the selected condec. 
 				 Algin GDO for selected codec aspect resolution 
				 and Load stream for the selected codec

 *	Created by: Franklin Jacques On 2009-05-15 02:12:15
 ***********************************************************/
Sub frvideoimage_change	
	
	Dimi ret
	dims url$,value$
	dims streamType$
    dimi sptCount
    dimi currTabVal
    
    'TR-42   -  Loads the frame based on the codec type
    currTabVal = #frvideoimage.curtab
    streamType$ = #ddresolution.itemlabel$(#ddresolution.selidx)
       
    Dimi n, StreamCnt, j
    Dims arrTemp$, Stream$(4),temp$
    StreamCnt = 0			
	n = Split(arrTemp$, streamType$, ",") 
	For j = 0 to n - 1
	iff Find(ucase$(arrTemp$(j)),"JPG")>= 0 then arrTemp$(j) = "JPEG"
		If Find(Ucase$(arrTemp$(j)), "JPEG") >= 0 Then
			Stream$(StreamCnt) = "JPEG"
		Else
			Stream$(StreamCnt) = "MP4"
		End If		
		StreamCnt++		
	Next
	
	
	If StreamCnt >= currTabVal+1 Then
		'Hide and show controls based on selected codec
		hideAndShowCtrls(Stream$(currTabVal),(currTabVal+1))	
	End If
	
	if currTabVal < #ddstream.itemcount then			
		call alignGDOCtrl(#frvideoimage.curtab)				'Algin Video player size 
		call disp_streams()									'display stream in video player
	end if
	
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
	
End Sub

/***********************************************************
'** displayframes
 *	Description: 
 *		To display the text control depending on the value of
		checkbox control during the frame change event 

 *	Created by: Franklin Jacques On 2009-05-18 14:35:30

 ***********************************************************/
sub displayframes()

	if #frvideoimage.curtab = 0 then
		disableCtrls("chktext1","txtCameratext1","ddtextpos1")  
		disableCtrls("chklogo1","","ddlogopos1")		
	elseif #frvideoimage.curtab = 1 then
		disableCtrls("chktext2","txtCameratext2","ddtextpos2")  
		disableCtrls("chklogo2","","ddlogopos2")				
	elseif #frvideoimage.curtab = 2 then
		disableCtrls("chktext3","txtCameratext3","ddtextpos3")  
		disableCtrls("chklogo3","","ddlogopos3")			
	endif

End Sub

/***********************************************************
'** disableCtrls
 *	Description: To display the text control depending on the value of
				 checkbox control
 *		
 *	Params:
'*		dims ctrlname$: String - Check box Control name
'*		dims txtctrlname$: String - corresponding text control
 *		dims drpctrlname$: String - corresponding drop down control
 *	Created by:Vimala  On 2009-06-02 10:44:12
 *	History: 
 ***********************************************************/
function disableCtrls(dims ctrlname$, dims txtctrlname$,dims drpctrlname$)
	
	if #{ctrlname$}.checked = 0 then
		 iff txtctrlname$<>"" then #{txtctrlname$}.disabled = 1
		 #{drpctrlname$}.disabled = 1
	else
		iff txtctrlname$<>"" then  #{txtctrlname$}.disabled = 0
		 #{drpctrlname$}.disabled = 0
	endif 
		
End Function


/***********************************************************
'** tabFrames
 *	Description: sub procedure to add tabs for the main frame

 *	Created by:Franklin Jacques  On 2009-04-16 12:03:51
 ***********************************************************/
Sub tabFrames()
	dim ret 
	ret = #frVideoImage.addtab("frVideoStream1","stream 1")
	ret = #frVideoImage.addtab("frVideoStream2","stream 2")
	ret = #frVideoImage.addtab("frVideoStream3","stream 3")	
End Sub



/***********************************************************
'** addTabImage
 *	Description:Used to Add the Tab images in Frame

 *	Created by: C.Balaji On 2009-05-11 11:13:34

 ***********************************************************/
sub addTabImage()
	getimage(TabsImagesA$,0,0,90,30,2,1,"!stream_1.bin")
	getimage(TabsImagesB$,0,0,90,30,2,1,"!stream_2.bin")
	getimage(TabsImagesC$,0,0,90,30,2,1,"!stream_3.bin")
	getimage(TabsImagesD$,0,0,90,30,2,1,"!stream_4.bin")
	#frvideoimage.tabheight=35	
	#frvideoimage.curtab=0
	#frvideoimage.paneimage(0)=TabsImagesA$
	#frvideoimage.paneimage(1)=TabsImagesB$
	#frvideoimage.paneimage(2)=TabsImagesC$
	#frvideoimage.paneimage(3)=TabsImagesD$
End Sub   



/***********************************************************
'** setInitialValues
 *	Description: 
 *		To set the initial values for the Video settings
		(stream1, stream2, stream3)
 *
 *	Created by:Franklin Jacques.k  On 2009-05-08 17:43:04

 ***********************************************************/
sub setInitialValues()
	
	dimi i,splitCount,tempvideocodecmode
	dimi ret,startIdx,endIdx
	dims ddValue$
	
	ret = getVideoImageSetting(videocodec, videocodecname$, videocodecmode, _
							   videocodecmodename$, videocodecres, videocodecresname$)
	 
	'assigning the retreived values to the subsequent control
	#txtCameraName$=~title$			
	split(ddValue$,videocodecname$,";")
	call addItemsToDropDown("ddStreamType", ddValue$, videocodec)
	
	'Remove MegaPixel from stream type drop down
	for i = 0 to #ddStreamType.ITEMCOUNT-1	
		if #ddStreamType.itemlabel$(i) = "MegaPixel" then
			#ddstreamtype.RemoveItem(i)
		end if 
	next 
	
	call ParseCodecMode(videocodecmodename$)
	call addCodecdetail((#ddStreamType+1), videocodecmode)	
	videocodecmode=0		
	call addResolutionDetail(videocodecres, videocodecmode)	
	call noOfFrame(#ddcodec$)
	
End Sub



/***********************************************************
'** ParseCodecMode
 *	Description: Call this function to load the codec for selected stream type
 *		Codec$: String - All available codec
 *	Created by: Rajan On 2010-01-09 05:57:59
 *	History: 
 ***********************************************************/
Sub ParseCodecMode(Codec$)		'TR-42
	Dimi Cnt
	Dims arrTempCodec$,arrTemp$
	dimi StreamCnt
	pprint Codec$
	Codec$ = repl$(Codec$,"@",";")
	CodecModeCount = Split(arrTempCodec$, Codec$, ";")
	redim arrCodeMode$(CodecModeCount,2)
	
	If CodecModeCount > 0 Then
		Dimi n, j
		For Cnt = 0 To CodecModeCount - 1
			StreamCnt = 0		
			pprint arrTempCodec$(Cnt)	
			n = Split(arrTemp$, arrTempCodec$(Cnt), "+") 
			For j = 0 to n - 1
				StreamCnt++
				If Find(Ucase$(arrTemp$(j)), "DUAL") >= 0 Then
					StreamCnt++
				End If
			Next
			pprint StreamCnt;arrTempCodec$(Cnt)
			arrCodeMode$(Cnt, 0) = StreamCnt			
			arrCodeMode$(Cnt, 1) = arrTempCodec$(Cnt)
		Next
	End If
End Sub





/***********************************************************
'** loadTabInfo
 *	Description: 
 *			To load the values for the controls for the selected Tab
 *		
 *	Methods: getVideoStream1- to get the values for the controls(stream1)
			 getVideoStream2- to get the values for the controls(stream2)
			 getVideoStream3- to get the values for the controls(stream3)
             
 *	Created by:  On 2009-10-07 10:50:59

 ***********************************************************/
sub loadTabInfo
	
	dims ddValue$	
	dimi ret1,ret2,ret3
	
	'stream1
	dimi bitrate1,ratecontrol1,datestampenable1,timestampenable1,logoenable1,logoposition1
	dimi textposition1,encryptvideo,localdisplay,mirctrl
	dims bitrate1$,ratecontrolname$,logopositionname$,textpositionname$,mirctrlname$,overlaytext1$
	dimi framerate1
	dims localdisplayname$
	
	'stream2
	dimi bitrate2,ratecontrol2,datestampenable2,timestampenable2,logoenable2,logoposition2,textposition2
	dims overlaytext2$
	dimi framerate2
	
	'stream3
	dimi datestampenable3,timestampenable3,logoenable3,logoposition3,textposition3
	dimi livequality,bitrate3, ratecontrol3
	dims overlaytext3$
	dimi framerate3
		
	'display info   'TR-11	
	dimi detailinfo1,detailinfo2,detailinfo3		
	pprint localdisplayname$	  		  
	'TR-42 
	'stream1
	ret1= getVideoStream1(framerate1, framerateNameAll1$,bitrate1, _
						  ratecontrol1, ratecontrolname$, datestampenable1, timestampenable1,_
						  logoenable1, logoposition1, logopositionname$, textenable1, _
						  textposition1, textpositionname$,_
						  encryptvideo, localdisplay, mirctrl, mirctrlname$,overlaytext1$,detailinfo1, localdisplayname$)
	pprint localdisplayname$		  
	'stream2
	ret2= getVideoStream2(framerate2, framerateNameAll2$, bitrate2, ratecontrol2, datestampenable2,_
						  timestampenable2, logoenable2, logoposition2, textenable2,_
						  textposition2,overlaytext2$,detailinfo2)  	  'TR-08
						
	'stream3
	ret3= getVideoStream3(framerate3, framerateNameAll3$, bitrate3, ratecontrol3, _
						  livequality, datestampenable3, timestampenable3, logoenable3, logoposition3,_
						  textenable3, textposition3,overlaytext3$,detailinfo3)   'TR-02
	
	'stream1			
	#txtBitrate1$=bitrate1
	split(ddValue$,ratecontrolname$,";")
	call addItemsToDropDown("ddRateControl1", ddValue$, ratecontrol1)	
	#txtqualityfactor1$ = livequality
	'overlay
	split(ddValue$,logopositionname$,";")
	call addItemsToDropDown("ddLogoPos1", ddValue$, logoposition1)	
	#chkDate1$=datestampenable1
	#chkTime1$=timestampenable1
	#chkLogo1$=logoenable1
	#chkText1$=textenable1
	#txtCameratext1$=overlaytext1$
	split(ddValue$,textpositionname$,";")	
	call addItemsToDropDown("ddTextPos1", ddValue$, textposition1)
	split(ddValue$,localdisplayname$,";")	
	call addItemsToDropDown("drpLocalDisplay", ddValue$, localdisplay)
	split(ddValue$,mirctrlname$,";")	
	call addItemsToDropDown("ddMirror", ddValue$, mirctrl)
	#chkdetailinfo1$ = detailinfo1				  'TR-11	
	
	'stream2
	#txtBitrate2$=bitrate2
	split(ddValue$,ratecontrolname$,";")
	call addItemsToDropDown("ddRateControl2", ddValue$, ratecontrol2)
	#txtqualityfactor2$ = livequality
	'overlay
	#chkDate2$=datestampenable2
	#chkTime2$=timestampenable2
	#chkLogo2$=logoenable2
	#chkText2$=textenable2
	#txtCameratext2$=overlaytext2$	
	split(ddValue$,logopositionname$,";")
	call addItemsToDropDown("ddLogoPos2", ddValue$, logoposition2)	
	split(ddValue$,textpositionname$,";")
	call addItemsToDropDown("ddTextPos2", ddValue$, textposition2)
	#chkdetailinfo2$ = detailinfo2				  'TR-11	
	
	'stream3		
	#txtBitrate3$=bitrate3
	split(ddValue$,ratecontrolname$,";")
	call addItemsToDropDown("ddRateControl3", ddValue$, ratecontrol3)
	#txtqualityfactor3$ = livequality
	'overlay
	#ChkDate3$=datestampenable3
	#chkTime3$=timestampenable3
	#chkLogo3$=logoenable3
	#chkText3$=textenable3
	#txtCameratext3$=overlaytext3$
	#chkdetailinfo3$ = detailinfo3				  'TR-11	
	
	split(ddValue$,logopositionname$,";")
	call addItemsToDropDown("ddLogoPos3", ddValue$, logoposition3)	
	split(ddValue$,textpositionname$,";")
	call addItemsToDropDown("ddTextPos3", ddValue$, textposition3)
    
   'TR-31
    dimi videoStream,videoSize,retVal
	dims videoStreamName$(1),VideoSize$(1)
	
    'Load Video File
    retVal = getVideoFile(videoStream,videoStreamName$,videoSize,VideoSize$)
   
    if retVal = 0 then
    	call addItemsToDropDown("drpstream", videoStreamName$, videoStream)	
    	call addItemsToDropDown("drpvideosize", VideoSize$, videoSize)	
    end if
       
	#ddresolution$ = videocodecres
	videocodecres = 0
	
	'Load frame rate based on selected resolution
    loadFrameRates(framerate1,framerateNameAll1$,1)
    loadFrameRates(framerate2,framerateNameAll2$,2)
    loadFrameRates(framerate3,framerateNameAll3$,3)       
	
	dims streamType$
    streamType$ = #ddresolution.itemlabel$(#ddresolution.selidx)                       
    dims streamTypeName$(3)
	assignStreamType(streamtype$,streamTypeName$)	
	pprint streamTypeName$(0)		
	hideAndShowCtrls(streamTypeName$(0),1)	
End Sub




/***********************************************************
'** hideAndShowCtrls
 *	Description: Call this function to hide/show controls based on the codec type(JPEG/MP4).
 
	 Params:
		dims streamType$:codec type (JPEG/MP4-for other codedc type)
		dimi tabNo : control display tab number

 *	Created by:Vimala  On 2010-01-09 07:16:43
 ***********************************************************/
Sub hideAndShowCtrls(dims streamType$,dimi tabNo)	

	if find(streamType$,"JPEG") >= 0  then
		#{"txtBitrate"+tabNo}.hidden = 1
		#{"lblBitRate"+tabNo}.hidden = 1
		#{"ddRateControl"+tabNo}.hidden = 1
		#{"lblRateControl"+tabNo}.hidden = 1
		#{"lblkbps"+tabNo}.hidden = 1			
		#{"lblQualityFactor"+tabNo}.hidden = 0
		#{"txtQualityFactor"+tabNo}.hidden = 0
		#{"lblQualityFactor"+tabNo}.y = #lblBitRate1.y
		#{"txtQualityFactor"+tabNo}.y = #txtBitrate1.y
	else 
		#{"txtBitrate"+tabNo}.hidden = 0
		#{"lblBitRate"+tabNo}.hidden = 0
		#{"ddRateControl"+tabNo}.hidden = 0
		#{"lblRateControl"+tabNo}.hidden = 0
		#{"lblkbps"+tabNo}.hidden = 0		
		#{"lblQualityFactor"+tabNo}.hidden = 1
		#{"txtQualityFactor"+tabNo}.hidden = 1
	end if
	
End Sub


/***********************************************************
'** loadFrameRates
 *	Description: Call this function to load the frame rate based on selected 
 *				  stream type and codec
 *	Params:
'*		framerate1: Numeric - Available frame rate1 values
'*		framerate2: Numeric - Available frame rate2 values
 *		framerate3: Numeric - Available frame rate3 values
 *	Created by:vimala  On 2010-01-09 04:18:09
 *	History: 
 ***********************************************************/
Sub loadFrameRates(dimi framerate,dims framerateNameAll$,dimi tabNo)	'TR-42
	dimi splitCount,index
	dims items$,ctrlName$,tempFrameRate$,tempValue$
	
	splitCount = split(items$,framerateNameAll$,"@")
	iff splitCount<=1 then return
	
	ctrlName$ = "ddframerate"+tabNo
	#{ctrlName$}.removeall()
	
	'add items to drop down box	
	pprint "Codec number = " + #ddcodec ; tempValue$
	tempValue$ = items$(#ddcodec)		
	splitCount  = split(tempFrameRate$,tempValue$, ";")

	if splitCount = #ddresolution.itemcount then
		tempValue$ = tempFrameRate$(#ddresolution)	
		pprint "Resolution number = " + #ddresolution ; tempValue$
		splitCount  = split(tempFrameRate$,tempValue$, ",")
		
		for index = 0 to splitCount-1		
			#{ctrlName$}.additem(index, trim$(tempFrameRate$(index)))
		next
		
		#{ctrlName$}$ = framerate
		
	end if	
	
End Sub


/***********************************************************
'** addResolutionDetail
 *	Description: Call this function to load the values in resolutuon drop down
 *				 based on selected codec and stream type
 *		
 *	Created by: Franklin Jacques.k  On 2009-08-05 19:29:40
 ***********************************************************/
sub addResolutionDetail(dimi selIndex, dimi videocodecmode)
	dimi ret
	dims tempResName$, tempValue$
	dimi index,splitCount
	dims items$
	'Remove the drop down items if any
	#ddResolution.removeall()	
	
	splitCount = split(items$,videocodecresname$,"@")
	iff splitCount<=1 then return
	
	'add items to drop down box	
	tempValue$ = items$(videocodecmode)
	ret  = split(tempResName$,tempValue$, ";")
	
	for index =0 to ret-1		
		#ddResolution.additem(index, trim$(tempResName$(index)))
	next
	
	'set the current selected index
	iff selIndex < 0 or selIndex >= ret then selIndex = 0
	#ddResolution$ = selIndex
End Sub


/***********************************************************
'** addCodecdetail
 *	Description:  To add the codec details for the selected stream 
 *		
 *	Params:
'*		dims streamcount: Numeric - stream number 
 *		dims selItem: Numeric - codec drop down selected value
 *	Created by: Franklin Jacques.k  On 2009-08-05 18:46:12
 *	History: 
 ***********************************************************/
sub addCodecdetail(dimi streamcount, dimi selItem)			'TR-42
	'Remove the drop down items if any
	#ddCodec.removeall()
	dimi Cnt
	
	For Cnt = 0 To CodecModeCount - 1
		pprint arrCodeMode$(Cnt, 0)
		If arrCodeMode$(Cnt, 0) = streamcount Then
			#ddCodec.additem(Cnt, arrCodeMode$(Cnt, 1))
		End If
	Next
	
	#ddCodec.selidx = selItem	
End Sub



/***********************************************************
'** noOfFrame
 *	Description: 
 *		This procedure to display number of frames with resoect to the value 
		of the ddCodec dropdown box 
 *		
 *	Method : alignCtrls- to align the controls of the frame 
 *	Created by: Franklin Jacques.k On 2009-05-18 15:13:28
 *	History: 
 ***********************************************************/
sub noOfFrame(dims value$)
	call removeTabs()	
	dimi ret
	
	if #ddstreamtype = 0 then
		ret = #frVideoImage.addtab("frVideoStream1","stream 1")			
	elseif #ddstreamtype = 1 then
		ret = #frVideoImage.addtab("frVideoStream1","stream 1")
		ret = #frVideoImage.addtab("frVideoStream2","stream 2")	
		alignCtrls(2)	
	elseif #ddstreamtype = 2 then
		ret = #frVideoImage.addtab("frVideoStream1","stream 1")			
		ret = #frVideoImage.addtab("frVideoStream2","stream 2")	  
		ret = #frVideoImage.addtab("frVideoStream3","stream 3")	
		ret = #frVideoImage.addtab("frVideoStream4","stream 4")	  
		alignCtrls(2)
		alignCtrls(3)
		alignCtrls(4)
	end if	
	
	call addTabImage()
End Sub


/***********************************************************
'** removeTabs
 *	Description: 
 *		This procedure is to remove all the tabs and hide all the 
		frames

 *	Created by: Franklin Jacques.k On 2009-05-18 16:02:22
 ***********************************************************/
Sub removeTabs()
	dimi ret
	#frvideostream1.hide()
	#frvideostream2.hide()
	#frvideostream3.hide()
	ret = #frVideoImage.removetab(0)
	ret = #frVideoImage.removetab(0)
	ret = #frVideoImage.removetab(0) 	
End Sub



/***********************************************************
'** cmdSave_Click
 *	Description: To set the video setting user input control values

 *	Created by:Franklin Jacques  On 2009-07-16 12:22:33

 ***********************************************************/
Sub cmdSave_Click
	if canReload = 1 then
		Dimi a
		a = #gdoVideo.stop(1)
	
		'~changeFlag sets only if some modification happened in any user input control
		if ~changeFlag = 1	then 	
		//	msgbox("save")	
			savePage()
		else 
			if validateCtrlValues() = 0 then 
				frvideoimage_change()
				return
			endif
//			#lblsuccessmessage$ = "Video setting saved to camera "+~title$			'TR-35	
			isMessageDisplayed = 1													'TR-35	
			~videocodecmode = #ddCodec												'BFIX-06
			call Form_complete														'BFIX-06	
			setfocus("txtcameraname")	
		end if
	end if
End Sub


/***********************************************************
'** savePage
 *	Description: Validates input values.
				 Save all the user input values to IPNC

 *	Created by: Franklin Jacques.k On 2009-05-28 16:33:23

 ***********************************************************/
sub savePage
	pprint "videoimagesetting.bas"
	dimi streamNo	
	dims selCodec$,sptArray$	
	dimi splitCount,tabNo,i	
	streamNo=  #ddStreamType.selidx
	dims streamType$
	
	streamType$ = #ddresolution.itemlabel$(#ddresolution.selidx)
    dims streamTypeName$(3)
	assignStreamType(streamtype$,streamTypeName$)
	'sets flag to save number of streams
	if streamNo = 0 then
		saveStream1 = 1
		saveStream2 = 0
		saveStream3 = 0				
	elseif streamNo = 1 then
		saveStream1 = 1
		saveStream2 = 1
		saveStream3 = 0	
	elseif streamNo = 2 then
		saveStream1 = 1
		saveStream2 = 1
		saveStream3 = 1	
	end if
	
	if validateCtrlValues() = 0 then 
		frvideoimage_change()		
		return
	endif
	
	#lblloading.hidden = 0
	dimi a 
	dims error$	
	dimi ret,ret1,ret2,ret3,retVideoFile		

	a = #gdoVideo.stop(1)	
	#gdoVideo.hidden = 1	
	#gdobg.paint(1)
	#lblloading$= "Updating..."
	#lblloading.paint(1)
	
	ret = 1	
	
	'Set stream related values
	ret=setVideoImageSetting(#ddStreamType,#ddCodec.selidx,#ddResolution,#ddMirror)
	error$ =~errorKeywords$		
	~videocodecmode = #ddCodec		
	ret1 = 1
	ret2 = 1
	ret3 = 1	
	
	
	if saveStream1 = 1 then
		'stream1
		ret1=setVideoStream1(#ddFrameRate1,#txtBitrate1,#ddRateControl1,#txtqualityfactor1,#chkDate1,_
							 #chkTime1,#chkLogo1,#ddLogoPos1,#chkText1,#txtCameraName$,_
							 #ddTextPos1,#optEncryptVideo,#drpLocalDisplay,#txtCameratext1$,#chkdetailinfo1,streamTypeName$(0))
		error$ +=~errorKeywords$		
	endif
	
	if saveStream2 = 1  then
		'stream2	
		ret2=setVideoStream2(#ddFrameRate2,#txtBitrate2$,#ddRateControl2,#txtqualityfactor2,_
							 #chkDate2,#chkTime2,#chkLogo2,#ddLogoPos2,_
							 #chkText2,#ddTextPos2,#txtCameratext2$,#chkdetailinfo2,streamTypeName$(1))     	  
		error$ +=~errorKeywords$
	end if
	if saveStream3 = 1 then	
		'stream3
		ret3=setVideoStream3(#ddFrameRate3,#txtBitrate3$,#ddRateControl3,#txtqualityfactor3,_
							 #ChkDate3,#chkTime3,#chkLogo3,#ddLogoPos3,#chkText3,_
							 #ddTextPos3,#txtCameratext3$,#chkdetailinfo3,streamTypeName$(2))							 
		error$ +=~errorKeywords$
	endif
	
	'saves video file values
	retVideoFile = setVideoFile(#drpstream,#drpvideosize)		'TR-31
	error$ +=~errorKeywords$									'TR-31
	
	error$ = left$(error$,len(error$)-1)	
	
	//Rajan
	if ret > 0 and ret1>0 and ret2>0 and ret3>0 and retVideoFile > 0 then 
		saveSuccess = 1
	else
		saveSuccess = 0
	end if
	//Rajan
	
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
 *	Description: Call this functionto display save status message both.

 *	Params:
 *		saveStatus: Numeric - 1-success message,0-Failure message
 *	Created by: Vimala On 2010-06-24 14:39:33
 ***********************************************************/
Sub displaySaveStatus(saveStatus)
	if saveStatus = 1 then 
		'success message   
//		#lblsuccessmessage$ = "视频设置已保存到系统 "+~title$			'TR-35	
//		isMessageDisplayed = 1													'TR-35	
	else 
		'Failure message
		if ~keywordDetFlag = 1 then					
			msgbox("Video setting for \n "+error$+"\nfailed for the camera "+~title$)			
		else
			msgbox("Video setting failed for the camera "+~title$)		
		endif
				
	endif
		
	~changeFlag = 0
	
	if isAdvancedClicked = 0  then
		loadUrl("!videoImageSettings.frm?isMessageDisplayed="+isMessageDisplayed)
	else 
		call setInitialValues()
		call displayframes()	
		noOfTabs = atol(#ddstreamtype$)+1
		loadurl("!videoImageAdvanced.frm&noOfTabs="+noOfTabs)
	end if
	
End Sub

                           


/***********************************************************
'** assignStreamType
 *	Description: Call this function to get stream type for the selected codec
 
 *	Params:
'*		dims streamtype$: String - selected resolution
 *		byref dims streamTypeName$(): String - returns selected codec type(JPEG/MP4)
 *	Created by:  On 2010-02-05 17:23:36
 *	History: 
 ***********************************************************/
Function assignStreamType(dims streamtype$,byref dims streamTypeName$())
	Dims arrTemp$,temp$
	Dimi n, StreamCnt, j
	 
    StreamCnt = 0			
	n = Split(arrTemp$, streamType$, ",") 
	For j = 0 to n - 1
		iff Find(ucase$(arrTemp$(j)),"JPG")>= 0 then arrTemp$(j) = "JPEG"
		If Find(Ucase$(arrTemp$(j)), "JPEG") >= 0 Then
			streamTypeName$(StreamCnt) = "JPEG"
		Else
			streamTypeName$(StreamCnt) = "MP4"
		End If		
		StreamCnt++		
	Next
End Function



/***********************************************************
'** Form_KeyPress
 *	Description: 
			To set wait flag before switching between forms	
			Checks entered key value based on the rule set to that user input control
 
 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by : Partha Sarathi.K On 2009-03-04 14:04:47
	Modified by: Jacques Franklin On 2009-03-25 11:53:50
 *	History: 
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )
	if Key = 15 then
	iff ~wait<=1 then return
		~wait = 2
	endif
	
	scroll_keypressed(key)
	
	checkForModification(ctrlValues$, LabelName$)

	dims keypressed$
	keypressed$ = chr$(getkey())	
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)	
	setSubMenuFocus(Key,0)
End Sub

'set key press rule for user input controls
Sub txtBitrate1_Focus
	rule = 7 
End Sub

Sub txtBitrate2_Focus
	rule = 7 
End Sub

Sub txtQualityFactor1_Focus
	rule = 7 
End Sub

Sub txtcameratext1_Focus
'	rule = 12
End Sub

Sub txtcameratext2_Focus
	rule = 12 
End Sub

Sub txtcameratext3_Focus
	rule = 12 
End Sub

/***********************************************************
'** validateCtrlValues
 *	Description: 
 *		     validation user input values

 *	Created by: vimala On 2009-04-03 12:10:14

 ***********************************************************/
Function validateCtrlValues()
	dims ddValue$,streamType$
	dimi streamType
	validateCtrlValues = 1
	streamType$ = #ddresolution.itemlabel$(#ddresolution.selidx)
    dims streamTypeName$(3)
	assignStreamType(streamtype$,streamTypeName$)

	if  saveStream1 = 1 and streamTypeName$(0)="MP4" and (#txtbitrate1 < 10 or  #txtbitrate1 > 32000) then		
		msgbox("Bit rate should range from  10  - 32000 ")
		#frvideoimage.curtab = 0
		setfocus("txtbitrate1")
		validateCtrlValues = 0
		return
	elseif  saveStream1 = 1 and streamTypeName$(0)="JPEG" and (#txtQualityFactor1 < 2 or  #txtQualityFactor1 > 97) then		
		msgbox("Quality Factor should range from  2 - 97 ")
		#frvideoimage.curtab = 0
		setfocus("txtQualityFactor1")
		validateCtrlValues = 0
		return	
	elseif  saveStream2 = 1 and streamTypeName$(1)="MP4" and (#txtbitrate2 < 10 or  #txtbitrate2 > 32000)  then		
		msgbox("Bit rate should range from  10  - 32000 ")
		#frvideoimage.curtab = 1
		setfocus("txtbitrate2")
		validateCtrlValues = 0
		return	
	elseif  saveStream2 = 1 and streamTypeName$(1)="JPEG" and (#txtQualityFactor2 < 2 or  #txtQualityFactor2 > 97) then		
		msgbox("Quality Factor should range from  2 - 97 ")
		#frvideoimage.curtab = 1
		setfocus("txtQualityFactor2")
		validateCtrlValues = 0
		return	
	elseif  saveStream3 = 1 and streamTypeName$(2)="MP4" and (#txtbitrate3 < 10 or #txtbitrate3 > 32000)  then		
		msgbox("Bit rate should range from  10  - 32000 ")
		#frvideoimage.curtab = 2
		setfocus("txtbitrate3")
		validateCtrlValues = 0
		return	
	elseif  saveStream3 = 1 and streamTypeName$(2)="JPEG" and (#txtQualityFactor3 < 2 or #txtQualityFactor3 > 97) then		
		msgbox("Quality Factor should range from  2 - 97 ")
		#frvideoimage.curtab = 2
		setfocus("txtQualityFactor3")
		validateCtrlValues = 0
		return	
	end if	
	
End Function


'Display cursor in control focus event else hide cursor
Sub optEncryptVideo_Focus  
	iff #optencryptvideo.disabled = 0 then showcursor(1)
End Sub

Sub optEncryptVideo_Blur
	showcursor(3)
End Sub

Sub optDisplayVideo_Focus
	showcursor(1)
End Sub

Sub optDisplayVideo_Blur
	showcursor(3)
End Sub

Sub chkDate1_Focus
	showcursor(1)
End Sub

Sub chkDate1_Blur
	showcursor(3)
End Sub

Sub chkTime1_Focus
	showcursor(1)
End Sub

Sub chkTime1_Blur
	showcursor(3)
End Sub

Sub chkLogo1_Focus
	showcursor(1)
End Sub


Sub chkText1_Focus
	showcursor(1)
End Sub


Sub chkDate2_Focus
	showcursor(1)
End Sub


Sub chkTime2_Focus
	showcursor(1)
End Sub

Sub chkDate2_Blur
	showcursor(3)
End Sub


Sub chkTime2_Blur
	showcursor(3)
End Sub

Sub chkLogo2_Focus
	showcursor(1)
End Sub


Sub chkText2_Focus
	showcursor(1)
End Sub

Sub chkDate3_Focus
	showcursor(1)
End Sub


Sub chkTime3_Focus
	showcursor(1)
End Sub

Sub chkDate3_blur
	showcursor(3)
End Sub


Sub chkTime3_blur
	showcursor(3)
End Sub

Sub chkLogo3_Focus
	showcursor(1)
End Sub

Sub chkText3_Focus
	showcursor(1)
End Sub


Sub chkLogo1_Blur
	showcursor(3)
End Sub


Sub chkText1_Blur
	showcursor(3)
End Sub

Sub chkLogo2_Blur
	showcursor(3)
End Sub


Sub chkText2_Blur
	showcursor(3)
End Sub

Sub chkLogo3_Blur
	showcursor(3)
End Sub


Sub chkText3_Blur
	showcursor(3)
End Sub

Sub chkdetailinfo1_Focus
	showcursor(1)
End Sub

Sub chkdetailinfo1_Blur
	showcursor(3)
End Sub

Sub chkdetailinfo2_Focus
	showcursor(1)
End Sub


Sub chkdetailinfo2_Blur
	showcursor(3)
End Sub


Sub chkdetailinfo3_Focus
	showcursor(1)
End Sub

Sub chkdetailinfo3_Blur
	showcursor(3)
End Sub

/***********************************************************
'** Form_complete
 *	Description: Algin and Set the properties for gdo video control to play rtsp stream
 *		
 *	Created by: Partha Sarathi.K On 2009-03-03 16:02:27
 ***********************************************************/
Sub Form_complete
	~wait = 0

	'call alignGDOCtrl(#frvideoimage.curtab)
	call disp_streams()
	
	'Store all the control values in an array to validate changes in form.
	dimi i
	for i = 0 to ubound(ctrlValues$)-1			
		ctrlValues$(i) = #{LabelName$(i)}$		
	next
	showcursor(3)		
	
	'Load the leftmenu url after user saves the current changes
	if canReload = 1 and ~UrlToLoad$ <> "" then		
		Dims ChangeUrl$
		ChangeUrl$ = ~UrlToLoad$
		~UrlToLoad$ = ""
		LoadUrl(ChangeUrl$)
	end If
	
	update
End Sub

/***********************************************************
'** disp_streams
 *	Description: 
 *		To set the URL for the GDO Control

 *	Created by: Franklin Jacques  On 2009-07-31 19:01:44

 ***********************************************************/
sub disp_streams()
	dims url$,value$
	dimi ret,a
	value$ = rtspUrl$(#frvideoimage.curtab)      	  
	a = #gdovideo.stop(1)
	Sleep(2)	
	
	'check whether video stream can to displayed by ActiveX or not
	dimi playVideoFlag,fontNo,styleNo
	dims dispStr$
	
	playVideoFlag = checkForStreamRes(stream$(#ddstream.selidx))
	
	if playVideoFlag = 1 then
		dispStr$ = ~Unable_To_Display_Msg$
		#lblloading.hidden = 0		
		#gdovideo.hidden = 1		
		#lblloading.paint(1)
		styleNo = 0
		#lblloading.h = 120
	else
		dispStr$ = "Updating . . . .    "
		'Play stream
		#gdovideo.hidden = 0
		a = #gdovideo.play(value$)		
		styleNo = 8
		#lblloading.h = 80
	end if
	
	#lblloading.style = styleNo	
	#lblloading$ = dispStr$
	#lblloading.w = #gdobg.w - (#gdobg.w/3)
	
	#lblloading.x =  ((#gdobg.w/2) - (#lblloading.w/2)) +  #gdobg.x
	
	'a = #gdovideo.play(value$)
	'#gdovideo.hidden = 0
End Sub


/***********************************************************
'** chkText1_Click
 *	Description: Disable related control if check box is unchecked	 

 *	Created by: Franklin On 2009-07-16 14:38:01

 ***********************************************************/
Sub chkText1_Click	
	disableCtrls("chktext1","txtCameratext1","ddtextpos1")
End Sub

/***********************************************************
'** chkText1_Click
 *	Description: 
 *		Disable related control if check box is unchecked	 

 *	Created by: Franklin On 2009-07-16 14:38:01

 ***********************************************************/
Sub chkText2_Click
	disableCtrls("chktext2","txtCameratext2","ddtextpos2")
End Sub

/***********************************************************
'** chkText1_Click
 *	Description: 
 *		Disable related control if check box is unchecked	 

 *	Created by: Franklin On 2009-07-16 14:38:01

 ***********************************************************/
Sub chkText3_Click
	disableCtrls("chktext3","txtCameratext3","ddtextpos3")	
End Sub

/***********************************************************
'** chkText1_Click
 *	Description: 
 *		Disable related control if check box is unchecked	 

 *	Created by: Franklin On 2009-07-16 14:38:01

 ***********************************************************/
Sub chklogo1_click
	disableCtrls("chklogo1","","ddlogopos1")
End Sub

/***********************************************************
'** chkText1_Click
 *	Description: 
 *		Disable related control if check box is unchecked	 

 *	Created by: Franklin On 2009-07-16 14:38:01

 ***********************************************************/
Sub chklogo2_click
	disableCtrls("chklogo2","","ddlogopos2")
End Sub

/***********************************************************
'** chkText1_Click
 *	Description: 
 *		Disable related control if check box is unchecked	 

 *	Created by: Franklin On 2009-07-16 14:38:01
 ***********************************************************/
Sub chklogo3_click
	disableCtrls("chklogo3","","ddlogopos3")
End Sub



/***********************************************************
'** cmdCancel_Click
 *	Description: 
 *		To Load the videoImageSettings.frm when the cancel
		button is clicked

 *	Created by: Franklin  On 2009-07-16 14:38:56
 ***********************************************************/
Sub cmdCancel_Click	
	if canReload = 1 then
		~changeFlag = 0	
		loadurl("!videoImageSettings.frm")	
	end if
End Sub



/***********************************************************
'** ddStreamType_Change
 *	Description: Load codec for the selected stream type

 *	Created by:Franklin  On 2009-05-18 14:39:51

 ***********************************************************/
Sub ddStreamType_Change
	dims Value$,ddValue$
	
	call addCodecdetail((#ddStreamType+1), videocodecmode)	
	call ddCodec_Change()
	
	/*if prvStream$ <> #ddStreamType$ then
		saveFlag=0
	endif

	prvStream$ = #ddStreamType$	*/
End Sub

/***********************************************************
'** ddCodec_Change
 *	Description: 
 *				Load resolution based on selected codec
 *				Display number on streams based on the codec selected.

 *	Created by: Franklin On 2009-05-18 15:10:53
 ***********************************************************/
sub ddCodec_Change
	dimi arrayIdx,endIdx
	
	call addResolutionDetail(0, #ddCodec)	
	call noOfFrame(#ddcodec$)
	call loadTabInfo()	

	'TR-16 Hide advanced button if MegaPixel JPEG is selected as codec
	pprint noOfTabs ;find(ucase$(#ddcodec.itemlabel$(#ddcodec.selidx)),"JPEG")
	noOfTabs = atol(#ddstreamtype$)+1
	if noOfTabs = 1  and find(ucase$(#ddcodec.itemlabel$(#ddcodec.selidx)),"JPEG") > 0  then
		#cmdadvanced.hidden = 1
	else 
		#cmdadvanced.hidden = 0
	end if 
	
End Sub



/***********************************************************
'** form_Mouseclick
 *	Description: To get the focus on user input control
 *		
 *	Params:
'*		x: Numeric - X Position
 *		y: Numeric - Y Position

 *	Created by:Vimala  On 2009-07-16 11:32:54

 ***********************************************************/
sub form_Mouseclick(x,y)	
	call getFocus()	
End Sub


/***********************************************************
'** checkForModification
 *	Description: Call this function to check whether the control values are modified or not.
 *				 set ~changeFlag = 1 if control value modified.

 *	Params:
 *		key: Numeric - Key value
 *	Created by:  On 2009-06-10 10:32:11
 ***********************************************************/
sub checkStreamctrlModifed(key)	
	dimi ctrlType,i
	dims ctrlval$
	dims fldname$(4) = ("ddStreamType","ddCodec","ddResolution","ddMirror")
	dimi fldType(4) = (3,3,3,3)
	
	for i = 0 to ubound(fldname$)
	
		if find(curfld$(),fldname$(i)) <> -1 then
			ctrlType = fldType(i)			
			break
		endif
		
	next	

	if key = 13 and ctrlType = 3 then		
		streamFlag = 1					
	end if

End Sub


/***********************************************************
'** ddresolution_change
 *	Description: Load fram rates based on the selected resolution

 *	Created by:  Vimala On 2009-10-14 12:17:53
 ***********************************************************/
Sub ddresolution_change()	
	loadFrameRates(0,framerateNameAll1$,1)
    loadFrameRates(0,framerateNameAll2$,2)
    loadFrameRates(0,framerateNameAll3$,3)	
End Sub



/***********************************************************
'** chkValueMismatch
 *	Description: Call this function to check whether the control values are modified or not.
 *				 set ~changeFlag = 1 if control value modified.

 *	Created by:vimala  On 2010-04-30 17:28:31

 ***********************************************************/
sub chkValueMismatch()	
	checkForModification(ctrlValues$, LabelName$)	
End Sub


