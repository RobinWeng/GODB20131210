/****************************************************************************
 * gTI IPNC - Common function
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
 

/***********************************************************
'** generateauthHeader$
 *	Description: 
 *		Generate the authentication header
 *		
 *	Params:
'*		dims userName$: String - User name
 *		dims password$: String - Password
 *	Created by: Partha Sarathi.K On 2009-02-27 15:16:53
 ***********************************************************/
function generateauthHeader$(dims userName$, dims password$)	
	dims Src$,Dest$ 
	dimi ret
	dims temp$,destTemp$
	
	Src$=userName$+":"+password$			'Merge user name and password
	pprint "Before encode: " + Src$ + " : " + Dest$
	ret = Encode(Src$,Dest$,1)				'Encode user name and password
	pprint "Encode ret = "+ret	
	temp$ = Src$+":"+~rememberPwd
	ret = Encode(temp$,destTemp$,1)	
	pprint "Write Profile = " + destTemp$
	writeprofile("IPNC",destTemp$)
	generateauthHeader$ = Dest$
	
End function

/***********************************************************
'** checkAspectRatio
 *	Description: Call this function to 
 *				 calculate width and height for the stream aspect ratio

 *	Params:
 *		byref dimi gdoCurWidth: Numeric - Video Width
 *		byref dimi gdoCurHeight: Numeric - Video Height
 *		dimi xRatio: Numeric - Stream x ratio
 *		dimi yRatio : Numeric - Stream y ratio
 *	Created by:  On 2009-06-30 14:37:28
 ***********************************************************/
function checkAspectRatio(byref dimi gdoCurWidth, byref dimi gdoCurHeight,dimi xRatio,dimi yRatio)
	//pprint "gdoCurWidth = " + gdoCurWidth
	//pprint "gdoCurHeight = " + gdoCurHeight

	iff xRatio = 0 then xRatio = 1
	iff yRatio = 0 then yRatio = 1

	Dimi TempW, TempH
	TempW = gdoCurHeight * xRatio/yRatio
	if TempW > gdoCurWidth then
		TempH = gdoCurWidth * yRatio/xRatio
		gdoCurHeight = TempH
	else
		gdoCurWidth = TempW
	end if
	
	gdoCurWidth = gdoCurWidth/16   
	gdoCurWidth = gdoCurWidth*16
	
	//pprint "gdoCurWidth = " + gdoCurWidth
	//pprint "gdoCurHeight = " + gdoCurHeight
End Function

/***********************************************************
'** createGDOControl
 *	Description: Call this function to create GDO control(Video player)
 
 *	Params:
'*		dims ctrlname$: String - Gdo control name
'*		dimi gdoX: Numeric - control x value
'*		dimi gdoY: Numeric - control y value
'*		dimi gdoW: Numeric - control w value
 *		dimi gdoH: Numeric - control h value
 *	Created by:  On 2009-06-19 12:31:55
 ***********************************************************/
function createGDOControl(dims ctrlname$, dimi gdoCurX, dimi gdoCurY, dimi gdoCurWidth, dimi gdoCurHeight)
	createobject("GDO", ctrlname$, " x='" + gdoCurX + "' y='" + gdoCurY + "' w='" + gdoCurWidth + "' h='" + gdoCurHeight +"' ProgID='Gffx.GFFMpeg.1'" )
	#{ctrlName$}.scrollable=0	
End Function

/***********************************************************
'** CheckKey
 * Description: 
 *    Load data into arraystring and check each key value for Validaion 

 * Params:
'* 		 Key: Numeric - Key Value
'*  	 rule: Numeric - Array Value 
 *  	 keypressed$: String - Keypressed value
 * Created by: Franklin Jacques On 2009-03-03 17:25:00
 ***********************************************************/
function CheckKey(Key,rule,keypressed$)
	dims strsplit$,charset$
	dimi num
	 
	strsplit$ = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 .~"_
				"1234567890.~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/-,. ()[]#~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890,-_.:/ ~"_
				"1234567890~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-/ ~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ .~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/~"_
				"1234567890#@/~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.@_-~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.@#$%^&*()_<>?/{}[]~"_
				"123456789~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.~"_
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_~"				
	num=split(charset$,strsplit$,"~")
	
	If Key > 31 and rule > 0 Then
	  Iff find(charset$(rule-1),ucase$(keypressed$))=-1 Then CheckKey=1
	Endif
 
End function


/***********************************************************
'** addItemsToDropDown
 *	Description: 
 *		Add the option values into the drop down box.
 *		
 *	Params:
'*		dims controlName$: String - Control name
 *		dims items$: String - Items to added to the drop down
 *		dimi selIndex: Numeric - Drop down selected item.
 *	Created by: Partha Sarathi.K  On 2009-02-26 19:20:58
 *	Modified by: Vimala On 2009-08-05 11:22:45
 ***********************************************************/
sub addItemsToDropDown(dims controlName$, dims items$(), dimi selItem)
	
	dimi ret
	dimi index
	dims tempVal$
	
	'Remove the drop down items if any
	#{controlName$}.removeall()
		
	'add items to drop down box
	ret = ubound(items$)
	iff ret < 0 then return
	for index = 0 to ret
		if trim$(items$(index)) <> "" then 
			#{controlName$}.additem(index, items$(index))
		endif
	next
		
	'set the current selected index
	iff selItem == -1 or selItem > ret then selItem = 0
	#{controlName$}$ = selItem
			
End Sub



/***********************************************************
'** displayControls
 *	Description: 
 *		Display the controls based on the screen resolution.
 *		Set the X and Y pos for form controls and it's properties.		

 *	Created by:vimala  On 2009-04-03 11:21:04
 ***********************************************************/
Sub displayControls(dims LabelName$(),dimi XPos(),dimi YPos(),dimi Wdh(),dimi height())	
	dimi i

	if  ~menuXRes > DESIGN_XVAL then		
		for i = 0 to ubound(LabelName$)		
			if XPos(i)> 70 then 
				XPos(i) = XPos(i) - 20 	
			else
				XPos(i) = XPos(i) - 5 
			end if 
		next
	end if
	pprint "ubound(LabelName$)="+ubound(LabelName$)		
	for i = 0 to ubound(LabelName$)-1	
	
		#{LabelName$(i)}.x = XPos(i)* ~factorX		
		#{LabelName$(i)}.y = YPos(i)* ~factorY

		if find(LabelName$(i),"img")= -1 then
			#{LabelName$(i)}.w = Wdh(i)* ~factorX
		end if
		
//	pprint i;LabelName$(i);#{LabelName$(i)}.x;#{LabelName$(i)}.y;#{LabelName$(i)}.w;#{LabelName$(i)}.h
	next	
	pprint "displayend"
End Sub

/***********************************************************
'** showimages
 *	Description: Call this function to assign image
 *		
 *	Params:
'*		dims ctrlName$: String - Control Name
'*		dims imageNameOn$: String - ON image name
 *		dims imageNameOff$: String - OFF image name
 *	Created by:Vimala  On 2009-05-19 10:26:24
 *	History: 
 ***********************************************************/
Sub showimages(dims ctrlName$,dims imageNameOn$,dims imageNameOff$)	
	if #{ctrlName$}.src$ = imageNameOn$ then 
		#{ctrlName$}.src$ = imageNameOff$
	else
		#{ctrlName$}.src$ = imageNameOn$
	end if
End Sub


/***********************************************************
'** loadTimeValues
 *	Description: call this function to add hour,minute and 
 *				 seconds values to drop down
 *	Params:
'*		dims ctrlName$: String - control name
 *		dimi maxValue: Numeric - Maximum value to be add to the drop down.
 *	Created by: vimala On 2009-03-17 17:47:16
 *	History: 
 ***********************************************************/
Sub loadTimeValues(dims ctrlName$,dimi maxValue)	
	dimi idx
	dims itemVal$
	
	for idx = 0 to maxValue
		itemVal$ = idx
		iff idx < 10 then itemVal$ = "0" + idx		
		#{ctrlName$}.additem(itemVal$,itemVal$)		
	next	
	
End Sub


/***********************************************************
'** calVideoDisplayRatio
 *	Description: call this function to calculate aspect ratio for the 
 *		         selected stream
 *	Params:
'*		dims selectedStream$: String - stream name with resolution eg:JPG(640x352)
'*		dimi byref xRatio: Numeric - returns the calculated X ratio
 *		dimi byref yRatio: Numeric - returns the calculated Y ratio
 *	Created by:  On 2009-09-07 12:45:34
 *	History: 
 ***********************************************************/
Sub calVideoDisplayRatio(dims selectedStream$,byref dimi xRatio,byref dimi yRatio)				' TR-04
	dimi gcdValue,startPos,endPos,splitCount,xResVal,yResVal
	dims streamRes$,splitArray$	
	startPos = find(selectedStream$,"(")
	endPos = find(selectedStream$,")")
	streamRes$ = mid$(selectedStream$,startPos+1,endPos-startPos)
	splitCount = split(splitArray$,streamRes$,"x")
	
	if splitCount = 2 then
		xResVal = strtoint(splitArray$(0))
		yResVal = strtoint(splitArray$(1))
		gcdValue = GCD(xResVal,yResVal)
		pprint xResVal/gcdValue
		pprint yResVal/gcdValue	
		xRatio = xResVal/gcdValue
		yRatio = yResVal/gcdValue	
		pprint xRatio
		pprint yRatio
		return 1
	end if	
	
	return 0
End Sub


/***********************************************************
'** getCurStreamResolution
 *	Description: Call this function to get the selected stream resolution
 *		
 *	Params:
'*		dims selectedStream$: String - Stream stream value
'*		byref dimi xRes: Numeric - X resolution
 *		byref dimi yRes: Numeric - Y Resolution
 *	Created by:  On 2009-09-23 17:08:49
***********************************************************/
sub getCurStreamResolution(dims selectedStream$,byref dimi xRes,byref dimi yRes)
	if selectedStream$ <> "" then
		dimi startPos,endPos,splitCount,xResVal,yResVal
		dims streamRes$,splitArray$	
		startPos = find(selectedStream$,"(")
		endPos = find(selectedStream$,")")
		streamRes$ = mid$(selectedStream$,startPos+1,endPos-startPos)
		splitCount = split(splitArray$,streamRes$,"x")
		
		if splitCount = 2 then
			xRes = strtoint(splitArray$(0))
			yRes = strtoint(splitArray$(1))
		endif
	else 
		xRes = 0
		yRes = 0
	end if
	
End Sub


/***********************************************************
'** GCD
 *	Description: Call this function to find GCD of two numbers		
 *		
 *	Params:
'*		num1: Numeric - X resolution
 *		num2: Numeric - Y resolution
 *	Created by:S.Vimala On 2009-09-07 10:45:09
 ***********************************************************/
Function GCD(num1,num2)					' TR-04
	iff num1=0 and num2=0 then return 1
	iff num2=0 then return num1
	return GCD(num2,num1%num2)		
End Function



/***********************************************************
'** loadStreamDetails
 *	Description: call this function to get stream names and its rtsp urls
 *		
 *	Created by:Vimala  On 2009-09-08 16:02:29
  ***********************************************************/
Sub loadStreamDetails(byref dims stream$(),byref dims rtspUrl$())				' TR-04
	
	dims streamName1$,streamName2$,streamName3$,streamName4$
	dims tempStream1$,tempStream2$,tempStream3$,tempStream4$
	dimi videocodec,sptCount1,sptCount2,sptCount3,sptCount4
	dimi retVal,i
	
	'fetches value from ini.htm and assign the streams in order of display	
	retVal = getStreamDisplayOrder(videocodec,streamName1$,streamName2$,streamName3$,streamName4$)
	pprint "videocodec="+videocodec;"streamName1$="+streamName1$;streamName2$;streamName3$,streamName4$
				                       
	if retVal>=0 then
		'Split stream and rtsp url and assign values in corresponding arrays
		sptCount1 = split(tempStream1$,streamName1$,"@")
		sptCount2 = split(tempStream2$,streamName2$,"@")
		sptCount3 = split(tempStream3$,streamName3$,"@")	
		sptCount4 = split(tempStream4$,streamName4$,"@")
		pprint "sptCount1234"+sptCount1;sptCount2;sptCount3;sptCount4
		if videocodec = 0 then			
			if sptCount1 = 2 then
				stream$(0) = tempStream1$(0)
				rtspUrl$(0) = tempStream1$(1)
				stream$(1) = tempStream2$(0)
				rtspUrl$(1) = tempStream2$(1)
				
				stream$(2) = tempStream3$(0)
				rtspUrl$(2) = tempStream3$(1)
				
				stream$(3) = tempStream4$(0)
				rtspUrl$(3) = tempStream4$(1)
				pprint "tempStream1$,tempStream2$,tempStream3$,tempStream4$="
				pprint stream$(0);rtspUrl$(0);stream$(1);rtspUrl$(1);stream$(2);rtspUrl$(2);stream$(3);rtspUrl$(3)
			end if
		elseif videocodec = 1 then
			if sptCount1 = 2 then
				stream$(0) = tempStream1$(0)
				rtspUrl$(0) = tempStream1$(1)
			end if
			if sptCount2 = 2 then
				stream$(1) = tempStream2$(0)
				rtspUrl$(1) = tempStream2$(1)
			end if
		elseif videocodec = 2 then
			if sptCount1 = 2 then
				stream$(0) = tempStream1$(0)
				rtspUrl$(0) = tempStream1$(1)
			end if
			if sptCount2 = 2 then
				stream$(1) = tempStream2$(0)
				rtspUrl$(1) = tempStream2$(1)
			end if
			if sptCount3 = 2 then
				stream$(2) = tempStream3$(0)
				rtspUrl$(2) = tempStream3$(1)
			end if
		end if
	else 
		msgbox("Valid stream not available")
		loadurl("!auth.frm")
	end if	 	
		
End Sub


/***********************************************************
'** GetIPAddress
 *	Description: Call this function to get camera IP address from 
 *				 CommandLine Parameters Passed to the GoDB VM
 *		
 *	Created by:  On 2009-09-23 10:16:33
***********************************************************/
Sub GetIPAddress()
	dims cmdline$
	dimi file
	cmdline$ = getosvar$("*CMDLINE")
    
    /* For Debug */
    cmdline$ = "http://192.168.1.173/gIPNC-ro.gz"
	
	if find(cmdline$, "http:") = 0 Then
		~uiType = WEB_VERSION
		dimi pos1
		pos1 = find(cmdline$, "/", 0, 1)
		if pos1 > 0 then
			~camAddPath$ = mid$(cmdline$, 0, pos1+1)
		else
			~camAddPath$ = cmdline$
		end if
	else  ' if command line value is not avaiable read the ip address from ip.txt
		dims ipAddress$
		file = fopen("ip.txt", 1, 1)
		
		if file <> -1 then
			ipAddress$ = fread$(file)
			~camAddPath$ = "http://"+trim$(ipAddress$)+"/"
			fclose(file)
		endif
		
	end if
End Sub




/***********************************************************
'** getUserAuthority
 *	Description: call this function to get user authourity for logged in 
				 user name.
 
 *	Created by: Vimala On 2009-05-17 22:55:12
 ***********************************************************/
Function getUserAuthority
	dims user$(10)
	dims authority$(10)
	dimi retVal,retVal1,i,sptidx
	dimi retFlag
	
	retVal = getPropValue("user", user$)
	retVal1 = getPropValue("authority", authority$)	
	
	if retVal >= 0  and retVal1 >= 0 then		
		dims username$(2)
		dims authname$(2)		
		retFlag = -1
		for i = 0 to Ubound(user$)
			sptidx = split(username$,user$(i),":")
			if sptidx = 2 then
				sptidx = split(authname$,authority$(i),":")
				if sptidx = 2 then 
					if username$(1) = ~authUserName$ then
						~loginAuthority = atol(authname$(1))
						retFlag = 0
						return 1
						break	
					endif
				endif
			endif
		next
		pprint	"retFlag="+ retFlag	
		iff retFlag = -1 then return -1   	' invalid user name \ password
	elseif retVal = -20 then
		~loginAuthority = VIEWER 			'Viewer
		return 1
	else
		return -1							' invalid user name \ password	
	endif	
	
End Function


/***********************************************************
'** calXYVal
 *	Description: Calculates X,Y position based on the screen resolution
				 with screen designed resolution
 
 *	Created by: Vimala On 2009-03-23 16:28:40
 ***********************************************************/
Sub calXYVal()	
	dimf designX ,designY
	dimf ~factorX,~factorY
	designX = DESIGN_XVAL
	designY = DESIGN_YVAL				
	~factorX = ~menuXRes/designX

	iff ~factorX <= 1 then ~factorX = 1	
	~factorY = ~menuYRes/designY	

	iff ~factorY <= 1 then ~factorY = 1

	pprint "designX: "; designX; "~menuXRes: "; ~menuXRes; "  ~factorX = " + format$("10.2",~factorX)
	pprint "designY: "; designY; "~menuYRes: "; ~menuYRes; "  ~factorY = " + format$("10.2",~factorY)
End sub

/***********************************************************
'** animateLabel
 *	Description:Call this function to animate displayMsg with dots
 
 *	Params:
'*		dims ctrlName$: String - Label name which displays message
 *		dims displayMsg$: String - Message string to be animated
 *	Created by:Vimala  On 2010-04-13 18:33:39
 ***********************************************************/
sub animateLabel(dims ctrlName$, dims displayMsg$)				'TR-45		
	dims tempMsg$
	timerCount++
	iff timerCount > 4  then timerCount=1
	if timerCount = 1 then 
		tempMsg$ = displayMsg$ + " . "		
	elseif timerCount = 2 then
		tempMsg$ =  displayMsg$ + " . ."
	elseif timerCount = 3 then 	
		tempMsg$ =  displayMsg$ + " . . ." 
	elseif timerCount = 4 then 	
		tempMsg$ =  displayMsg$ + " . . . ." 
	end if
	
	#{ctrlName$}$ = tempMsg$
	#{ctrlName$}.paint(1)	
End Sub


/***********************************************************
'** checkForStreamRes
 *	Description: 
 *		
 *		
 *	Params:
 *		dims streamName$: String - 
 *	Created by:  On 2010-07-06 15:25:29
 *	History: 
 ***********************************************************/
Function checkForStreamRes(dims streamName$)
	checkForStreamRes = 0
	dimi xRes,yRes
	getCurStreamResolution(streamName$,xRes,yRes)
	
	if xRes > 2048 or yRes > 2048 then
		checkForStreamRes = 1
	end if
End Function


