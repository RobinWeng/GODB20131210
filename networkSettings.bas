/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Network Settings                                            *
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

dimi noofctrl														'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS                              
dims LabelName$(noofctrl)                                           'Form controls name
dimi XPos(noofctrl)                                                 'Form controls X position
dimi YPos(noofctrl)                                                 'Form controls Y position
dimi Wdh(noofctrl)                                                  'Form controls Width position
dimi height(noofctrl)                                               'Form controls height position
                                                             
#include "networkSettings.inc"

dimi rule, IPflag
dimi dhcpenable
dimi networkIdx,FTPIdx,SNTPIdx,SMTPIdx,PortIdx,RTSPIdx

'set focus in left menu
showSubMenu(0,1)
setfocus("rosubmenu[6]")
selectSubMenu()

showcursor(3)
~wait = 2 										'added by Franklin to set wait flag when switching between forms
dims tabImage$(10)
settimer(1000)									'TR-35  
dimi displayCount,isMessageDisplayed			'TR-35  
displayCount = 1								'TR-35
dims ctrlValues$(noofctrl)
dimi animateCount = 0 	 ' Stores the count for the animation done.
dimi saveSuccess = 0	 'Value of 1 is success
dims error$ = "" 		 'Stores the error returned while saving.
dimi tempX				 ' Holds sucess message label
end

/***********************************************************
'** Form_Load
 *	Description: Call displayControls function to algin contorls
 *				 based on the screen resolution. 
				 Sets control X,Y,W,H values.
 *	Created by: Franklin Jacques On 2009-06-10 10:41:23
 *	History: 
 ***********************************************************/
Sub Form_Load
	dimi retVal
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)	
		
	'Adjust back groud label to fit controls
	#lblFrame1.w = #txthttpport.x- #lblFrame1.x + #txthttpport.w + 12
	#lblFrame1.h = #txthttpport.y - #lblFrame1.y + #txthttpport.h + 10
	
	#lblframe2.w = #txtftpport.x - #lblframe2.x + #txtftpport.w + 20
	#lblframe2.h = #txtftpfileuploadpath.y - #lblframe2.y + #txtftpfileuploadpath.h + 10
	
	#lblframe3.w = #txthttpport.x- #lblFrame1.x + #txthttpport.w + 12
	#lblframe3.h = #txtsmtpemail.y - #lblframe3.y + #txtsmtpemail.h + 10
		
	#lblFrame4.w = #txtftpport.x - #lblframe2.x + #txtftpport.w + 20
	#lblFrame4.h = #chkrtspmulticast.y - #lblFrame4.y + #chkrtspmulticast.h + 10
	
	#lblFrame5.w =  #txtftpport.x - #lblframe2.x + #txtftpport.w + 20
	#lblFrame5.h = #txtsntpserver.y - #lblFrame5.y + #txtsntpserver.h + 10
	
	#lblFrame6.h = #ddportRS485.y - #lblFrame6.y + #ddportRS485.h + 10
	
	'Get network tab image and set its corresponding to enable selected tab
	getimage2(tabImage$,"!network_tab.jpg",106,30,12,1)
	networkIdx = 2
	FTPIdx = 3
	SNTPIdx = 7
	SMTPIdx = 5
	PortIdx = 9
	RTSPIdx = 11
	
	'fetch values from camera
	call ShowDefaultValues()
	#lblsuccessmessage$ = ""   					'TR-35
End Sub

/***********************************************************
'** Form_Complete
 *	Description: Store all the control values in an array to validate changes in form.

 *	Created by:  On 2010-05-03 14:41:03
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
'** ShowDefaultValues
 *	Description: To fetch the values for Network,Ftp,smtp,Sntp
				 controls from camera and load the same in user input controls

 *	Created by:Franklin Jacques  On 2009-03-18 14:35:05
 ***********************************************************/
sub ShowDefaultValues()	
	Dims ip$,netmask$,defaultGWay$,priNameServer$,ftpServer$,username$,ftppwd$,fileUpldpath$
	Dims accName$, smtppwd$, sender$, smtpServer$, emailid$,sntpServer$
	Dimi httpPort, ftpport, requiresAuth, daylight,sntptimezone
	Dimi retTimezone,retNetwork,retFTP,retSMTP,retPORTSETTINGS,retPORT,retVal
	Dimi httpsport, portinput, portoutput, rs485
	dimi multiCast															'TR-20
	Dims portinputname$,portoutputname$,rs485name$
	Dims timezone$(1),ddValue$(2),ddValue1$(3)
	Dims defaultValue$ = "0"
	#roCamera$ =  ~title$
	
	retNetwork=getNetworkDetails(ip$, netmask$, defaultGWay$, priNameServer$, httpPort, dhcpenable)
	retFTP=getFTPDetails(ftpServer$,username$,ftppwd$,fileUpldpath$,ftpport)
	retSMTP=getSMTPDetails(accName$, smtppwd$, sender$, smtpServer$, emailid$, requiresAuth)
	retVal=getSNTPRTSPDetails(sntpServer$, multiCast)						'TR-20
	retPORT=getPORTDetails(httpsport, portinput, portoutput, rs485, portinputname$,portoutputname$, rs485name$)
		
	'*************************Network-Text controls**************
	if retNetwork<>-1 then
		#txtIPaddress$=suppressZero$(ip$)									'	TR-03
		iff trim$(ip$) = "" then #txtIPaddress$ = defaultValue$
		pprint netmask$
		#txtnetmask$=suppressZero$(netmask$)								'	TR-03
		iff trim$(netmask$) = "" then #txtnetmask$ =  "0.0.0.0"
		#txtgateway$=suppressZero$(defaultGWay$)							'	TR-03
		iff trim$(defaultGWay$) = "" then #txtgateway$ =  "0.0.0.0"
		#txtserver$=suppressZero$(priNameServer$)							'	TR-03
		iff trim$(priNameServer$) = "" then #txtserver$ = defaultValue$
	else
		msgbox("unable to fetch network details")
	endif
	
	'***********************ftp-Text controls**********
	if retFTP<>-1 then
		#txtftpserver$=suppressZero$(ftpServer$)					'	TR-03
		iff trim$(ftpServer$) = "" then #txtftpserver$ =  "0.0.0.0"
		#txtftpusername$=username$
		iff trim$(username$) = "" then #txtftpusername$ = defaultValue$
		#txtftppassword$=ftppwd$
		iff trim$(ftppwd$) = "" then #txtftppassword$ = defaultValue$
		#txtftpfileuploadpath$=fileUpldpath$
		iff trim$(fileUpldpath$) = "" then #txtftpfileuploadpath$ = defaultValue$
		#txtftpport$=ftpport
	else
		msgbox("unable to fetch FTP details")
	endif
	
	'**********************Smtp controls**************
	if retSMTP<>-1 then 
		#txtsmtpaccountname$=accName$ 
		iff trim$(accName$) = "" then #txtsmtpaccountname$ = defaultValue$
		#txtsmtppassword$=smtppwd$ 
		iff trim$(smtppwd$) = "" then #txtsmtppassword$ = defaultValue$
		#txtsmtpsender$=sender$
		iff trim$(sender$) = "" then #txtsmtpsender$ = defaultValue$
		#txtsmtpserver$= suppressZero$(smtpServer$) 					'	TR-03
		iff trim$(smtpServer$) = "" then #txtsmtpserver$ =  "0.0.0.0"
		#txtsmtpemail$=emailid$
		iff trim$(emailid$) = "" then #txtsmtpemail$ = defaultValue$
		#Checksmtpserverauth$=requiresAuth		
	else
		msgbox("unable to fetch SMTP details")
	endif
		
	'********************RTSP and SNTP Text Controls***********
	if retVal<>-1 then
		#txtsntpserver$=sntpServer$	
		iff trim$(sntpServer$) = "" then #txtsntpserver$ = "0.0.0.0"
		#chkrtspmulticast$ = multiCast					'TR-20
	else
		msgbox("unable to fetch SNTP/RTSP details")
	endif
	if dhcpenable=1 then									'TR-05	
		disableNetwork(1)                 
		setfocus("txtftpserver")
		FTPIdx = 4
		networkIdx = 1		
	else
		disableNetwork(0)
		setfocus("txtIPaddress")
		networkIdx = 2
	endif
	
	'*********************Port Setting****************
	if retPORT<>-1 then
		#txtporthttp$=trim$(httpPort)
		iff httpPort = 0 then #txtporthttp$ = "00"
		#txtporthttps$=trim$(httpsport)
		iff httpsport = 0 then #txtporthttps$ = "00"
		split(ddValue$,portinputname$,";")
		call addItemsToDropDown("ddportInput", ddValue$, portinput)
		split(ddValue$,portoutputname$,";")
		call addItemsToDropDown("ddportOutput", ddValue$, portoutput)
		split(ddValue1$,rs485name$,";")
		call addItemsToDropDown("ddportRS485", ddValue1$, rs485)
	else
		msgbox("unable to fetch PORT details")
	endif
		
End Sub


/***********************************************************
'** disableNetwork
 *	Description: Call this function to enable / Disable network Controls

 *	Params:
 *		dimi disableFlag: Numeric - 1 - Disable control
 *									0 - Enable control
 *	Created by: vimala On 2009-10-14 14:45:13
 ***********************************************************/
sub disableNetwork(dimi disableFlag)						'TR-05	
	#txtIPaddress.disabled = disableFlag
	#txtnetmask.disabled = disableFlag
	#txtgateway.disabled = disableFlag
	#txtserver.disabled = disableFlag
	#txtporthttp.disabled = disableFlag
End Sub


/***********************************************************
'** suppressZero$
 *	Description: Call this function to remove prefix zeor's from the ip address
 *
 *	Params:
 *		dims ipAddress: Numeric - Valid IP address
 *	Return:
		 IP address without prefix zero's
 *	Created by:  On 2009-09-04 11:50:49
 *	History: 
 ***********************************************************/
Function suppressZero$(dims ipAddress$)					'	TR-03
	dimi i,splitCount
	dims splitArray$,ResArray$(4),temp$
	splitCount = split(splitArray$,ipAddress$,".")
	if splitCount = 4 then
		
		for i = 0 to splitCount-1
			ResArray$(i) = strtoint(splitArray$(i))	
			temp$ += ResArray$(i)+"."				
		next		
		
		suppressZero$ = left$(temp$,len(temp$)-1)
	else 
		suppressZero$=ipAddress$
	end if 
	
End Function



/***********************************************************
'** btncancel_click
 *	Description: To cancel the changed values and show the 
				 default values set initially

 *	Created by:Jacques Franklin  On 2009-03-19 13:00:41
 ***********************************************************/
sub btncancel_click
	if canReload = 1 then
		~changeFlag = 0	
		call ShowDefaultValues()
	end if
End Sub

/***********************************************************
'** Form_KeyPress
 *	Description: * 	To Validate the textbox controls when the
				 key press event is fired
			     *	Method getSubMenu_Keypress is used to get
				 the sub menu index
 *		
 *	Params:
'*		Key: Numeric - To handle the key event
 *		FromMouse: Numeric - Mouse value 
 *	Created by:Jacques Franklin On 2009-03-19 12:58:33
 ***********************************************************/
Sub Form_KeyPress(Key, FromMouse) 
	scroll_keypressed(key)  'lock  mouse scroll
	
	dims keypressed$
	keypressed$ = chr$(getkey())
	pprint keypressed$
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)
	setSubMenuFocus(Key,5)
	
	/* to set selected tab color*/
	dims ctrlName$ 
	ctrlName$ = curfld$()	
	'set disable color
	networkIdx = 1
	FTPIdx = 3
	SNTPIdx = 7
	SMTPIdx = 5
	PortIdx = 9	
	RTSPIdx = 11
	'Enable for the selected tab
	if find(ctrlName$,"ftp")<> -1 then
		FTPIdx = 4
	elseif find(ctrlName$,"sntp")<> -1 then
		SNTPIdx = 8
	elseif find(ctrlName$,"smtp")<> -1 then
		SMTPIdx = 6
	elseif find(ctrlName$,"port")<> -1 then
		PortIdx = 10
	elseif find(ctrlName$,"rtsp")<> -1 then
		RTSPIdx = 12
	else 
		networkIdx = 2
	end if
	
End Sub


/***********************************************************
'** IP_Validation
 *	Description: To check the whether the IP is valid or not
 *		
 *	Params:
'*		Dims ipadd$: String - value of IP address
 *		Dims fieldname$: String - value of the fieldname
 *	Created by:Jacques Franklin On 2009-03-19 12:57:23
 *	History: 
 ***********************************************************/
function IP_Validation(Dims ipadd$,Dims fieldname$)
	Dims ArrNum$
	Dimi i 
	if ipadd$<>"" and fieldname$<>"" then
		split(ArrNum$,ipadd$,".")
		for i = 0 to Ubound(ArrNum$)
			pprint ArrNum$(i);ipadd$
			if atol(ArrNum$(i))>255 and ipadd$<>"" then
				msgbox("Invalid " + fieldname$)
				return 1
			endif
		Next
		if i<>4 then
			msgbox("Invalid " + fieldname$)
			return 1
		endif
	endif
   return 0 
End function

/***********************************************************
'** txtipaddress_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtipaddress_focus	
	rule=2				 'IP address-textbox control validation
End Sub

/***********************************************************
'** txtnetmask_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtnetmask_focus
	rule=2				   'netmask-textbox control validation
End Sub

/***********************************************************
'** txtnetmask_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtnetmask_Blur	      'BFIX-02
	rule=0
End Sub 

/***********************************************************
'** txtgateway_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtgateway_focus	
	rule=2				   'gateway-textbox control validation
End Sub

/***********************************************************
'** txtgateway_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtgateway_Blur	            'BFIX-02
	rule=0
End Sub 

/***********************************************************
'** txtserver_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtserver_focus	
	rule=2				   'primary name server-textbox control validation
End Sub

/***********************************************************
'** txtserver_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtserver_Blur	                        'BFIX-02
	rule=0
End Sub 


/***********************************************************
'** txtftpserver_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftpserver_focus	
	rule=2				   'ftpserver-textbox control validation
End Sub

/***********************************************************
'** txtftpserver_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftpserver_Blur				'BFIX-02		  
	rule=0
End Sub 

/***********************************************************
'** txtftpusername_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftpusername_focus	
	rule=5				   'ftpusername-textbox control validation
End Sub

/***********************************************************
'** txtftpusername_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftpusername_Blur	
	rule=0
End Sub 

/***********************************************************
'** txtftppassword_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftppassword_focus	
	rule=5				   'ftppassword-textbox control validation
End Sub

/***********************************************************
'** txtftppassword_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftppassword_Blur	
	rule=0
End Sub 

/***********************************************************
'** txtftpfileuploadpath_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftpfileuploadpath_focus	
	rule=6				   'fileuploadpath-textbox control validation
End Sub

/***********************************************************
'** txtftpfileuploadpath_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftpfileuploadpath_Blur	
	rule=0
End Sub 


/***********************************************************
'** txtftpport_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftpport_focus	
	rule=7				   'ftpport-textbox control validation
End Sub

/***********************************************************
'** txtftpport_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtftpport_Blur	
	rule=0
End Sub 

/***********************************************************
'** txtsmtpaccountname_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtsmtpaccountname_focus	
	rule=5				   'accountname-textbox control validation
End Sub

/***********************************************************
'** txtsmtpaccountname_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtsmtpaccountname_Blur	
	rule=0
End Sub 


/***********************************************************
'** txtsmtppassword_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtsmtppassword_focus	
	rule=5				   'accountname-textbox control validation
End Sub

/***********************************************************
'** txtsmtppassword_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtsmtppassword_Blur
	rule=0
End Sub 

/***********************************************************
'** txtsmtpserver_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtsmtpserver_focus
	rule=2				   'SMTPserver-textbox control validation
End Sub

/***********************************************************
'** txtsmtpserver_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-03-19 13:03:21
 ***********************************************************/
sub txtsmtpserver_Blur  		'BFIX-02
	rule=0
End Sub 

/***********************************************************
'** emailValidation
 *	Description: 
 *		To check whether the entered email ID is valid or not
 *	Params:
 *		emailID$: String - Email ID value
 *	Created by: Franklin On 2008-07-21 15:03:00
 ***********************************************************/
Function emailValidation(dims emailID$)	
	dimi loopCnt					'Declare for store the Loop count value
	dimi emaillen					'Declare for store Length of the entered Email ID
	dimi atcnt						'Declare for store the '@' count value
	dimi dotcnt						'Declare for store the '.' count value
	dimi nextpos					'Declare for store the Next position value
		
	emailValidation = 1	'Assign the email validation value as 1 by default
	emaillen = len(trim$(emailId$))	'Take the length of the entered string
	if emailId$(0) = "@" or emailId$(0) = "_" or emailId$(0) = "-" or emailId$(0) = "." then
		emailValidation = 0 'InValid Email Id
		return
	else
		for loopCnt = 0 to emailLen-1  
			'To check whether the special characters are exist or not except "@,.,-,_"
			if (emailId$(loopCnt) >= chr$(65) and emailId$(loopCnt) <= chr$(90)) or (emailId$(loopCnt) >= chr$(97) and emailId$(loopCnt) <= chr$(122)) or (emailId$(loopCnt) >= chr$(48) and emailId$(loopCnt) <= chr$(57)) or emailId$(loopCnt) = chr$(46) or emailId$(loopCnt) = chr$(64) or emailId$(loopCnt) = chr$(45) or emailId$(loopCnt) = chr$(95) then
				emailValidation = 1  
			else
				emailValidation = 0
				return
			endif 
			iff emailId$(loopCnt) = "@" then atcnt++ 
			if emailId$(loopCnt) = "." then 
				dotcnt++
				if dotcnt = 1 then
					nextpos = loopcnt + 1
					if emailId$(nextpos) = "." then
						emailValidation = 0
						return
					endif
				endif
			endif	
		next
		'If '@' count is > 1 or '.' count is > 3 then assign the email validation as 0
		if atcnt = 1 and dotcnt >= 1 and dotcnt <= 3 then
			emailValidation = 1
		else
			emailValidation = 0
		endif
	endif
End Function


/***********************************************************
'** txtsntpserver_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-07-16 13:58:51
 ***********************************************************/
sub txtsntpserver_focus
	rule=6				   'SNTPserver-textbox control validation
End Sub

/***********************************************************
'** txtsntpserver_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-07-16 13:58:51
 ***********************************************************/
sub txtsntpserver_Blur
	rule=0
End Sub 


/***********************************************************
'** txttimezone_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-07-16 13:58:51
 ***********************************************************/
sub txttimezone_focus	
	rule=6				   'SNTPserver-textbox control validation
End Sub

/***********************************************************
'** txttimezone_Blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-07-16 13:58:51
 ***********************************************************/
sub txttimezone_Blur	
	rule=0
End Sub 


/***********************************************************
'** buttonSave_Click
 *	Description: 
 *		Save the network settings.
 *		If failed to save throught the err msg.
 *	Params:
 *	Created by: Franklin  On 2009-03-13 10:27:39
 *	History: Modified by Partha Sarathi.K
 ***********************************************************/
Sub buttonSave_Click
	if canReload = 1 then
		savePage()		
	end if
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
'** savePage
 *	Description: 
 *		set the network, FTP, SMTP, port details to the Camera

 *	Created by:Franklin Jacques  On 2009-05-28 16:34:07
 ***********************************************************/
Sub savePage()
	pprint "networksetting.bas" 
	Dimi retNW, retFTP, retSMTP, retPORT, retVal,i
	dims error$	
	error$ = ""
	iff validateNetwork()=0 then return
	iff validateFTP()=0  then return
	iff validateSMTP()=0  then return
	iff validatePort()=0 then return
	retNW   = setNetworkDetails(#txtIPaddress$, #txtnetmask$, #txtgateway$, #txtserver$,dhcpenable)		'BFIX-02
	error$ = ~errorKeywords$ 
	retFTP  = setFTPDetails(#txtftpserver$, #txtftpusername$, #txtftppassword$,#txtftpfileuploadpath$, strtoint(#txtftpport$))					
	error$ += ~errorKeywords$ 
	retSMTP = setSMTPDetails(#txtsmtpaccountname$, #txtsmtppassword$,#txtsmtpsender$, #txtsmtpserver$, #txtsmtpemail$, strtoint(#Checksmtpserverauth$))
	error$ += ~errorKeywords$ 
	retPORT = setPORTDetails(#txtporthttp, #txtporthttps, #ddportInput, #ddportOutput, #ddportRS485,dhcpenable) 
	error$ += ~errorKeywords$ 
	retVal = setSNTPRTSPDetails(#txtsntpserver$, #chkrtspmulticast)					'TR-20
	pprint error$
	error$ += ~errorKeywords$ 
	
   	if retNW >=0 and retFTP >= 0 and retSMTP>=0 and retVal>=0 then
		saveSuccess = 1
   	else 
   		saveSuccess = 0
	end if
	tempX = #lblsuccessmessage.x
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
//		#lblsuccessmessage.style = 64
//		#lblsuccessmessage.x = tempX  
//		#lblsuccessmessage$ = "网络端口设置已保存到系统 "+~title$		'TR-35	
//		isMessageDisplayed = 1												'TR-35	
//		#lblsuccessmessage.paint(1)		
	else		
		if ~keywordDetFlag = 1 then		
			msgbox("Network setting for \n"+error$+"\nfailed for the camera "+~title$)
   		else
   			msgbox("Network setting failed for the camera "+~title$)
		endif
   	endif
   	call ShowDefaultValues()   		
   	if dhcpenable = 1 then
   		setfocus("txtftpserver")
	else
		setfocus("txtnetmask")
   	end if     	
   	~changeFlag = 0
   	canReload = 1	
   	call Form_complete()
End sub

/***********************************************************
'** validateNetwork
 *	Description: Validate network tab user input controls

 *	Created by:Franklin Jacques  On 2009-05-20 10:26:14
 ***********************************************************/
function validateNetwork()
	validateNetwork=1
	if #txtIPaddress$="" then
		msgbox("IP address is a mandatory field")
		validateNetwork=0
		setfocus("txtIPaddress")
		return
	elseif #txtnetmask$="" then
		msgbox("Sub netmask is a mandatory field")
		validateNetwork=0
		setfocus("txtnetmask")
		return
	elseif #txtgateway$="" then 
		msgbox("Default gateway is a mandatory field")
		validateNetwork=0
		setfocus("txtgateway")
		return
	elseif #txtserver$="" then
		msgbox("Primary server is a mandatory field")
		validateNetwork=0
		setfocus("txtserver")
		return'
	elseif IP_Validation(#txtnetmask$,"subnet mask name") = 1 then			'BFIX-02
		validateNetwork=0
		setfocus("txtnetmask")
		return
	elseif IP_Validation(#txtgateway$,"gateway name") = 1 then			'BFIX-02
		validateNetwork=0
		setfocus("txtgateway")
		return
	elseif IP_Validation(#txtserver$,"primary server name") = 1 then			'BFIX-02
		validateNetwork=0
		setfocus("txtserver")
		return
	endif
End function


/***********************************************************
'** validateFTP
 *	Description: Validate FTP tab user input controls

 *	Created by:Franklin Jacques  On 2009-05-20 10:30:31
 ***********************************************************/
function validateFTP()
	validateFTP=1
	if #txtftpserver$="" then
		msgbox("FTP server is a mandatory field")
		validateFTP=0
		setfocus("txtftpserver")
		return
	elseif #txtftpusername$="" then
		msgbox("FTP username is a mandatory field")
		validateFTP=0
		setfocus("txtftpusername")
		return
	elseif #txtftppassword$="" then 
		msgbox("FTP password is a mandatory field")
		validateFTP=0
		setfocus("txtftppassword")
		return
	elseif #txtftpport$="" then
		msgbox("FTP port is a mandatory field")
		validateFTP=0
		setfocus("txtftpport")
		return
	elseif IP_Validation(#txtftpserver$,"ftp server name") = 1 then			'BFIX-02
		validateFTP=0
		setfocus("txtftpserver")
		return	
	endif
End Function

/***********************************************************
'** validateSMTP
 *	Description: Validate SMTP tab user input controls

 *	Created by:Franklin Jacques On 2009-05-20 10:37:56
 ***********************************************************/
function validateSMTP()
	validateSMTP=1
	if #txtsmtpaccountname$="" then
		msgbox("Account name is a mandatory field")
		validateSMTP=0
		setfocus("txtsmtpaccountname")
		return
	elseif #txtsmtpsender$="" then
		msgbox("Sender is a mandatory field")
		validateSMTP=0
		setfocus("txtsmtpsender")
		return
	elseif #txtsmtpserver$="" then 
		msgbox("SMTP server is a mandatory field")
		validateSMTP=0
		setfocus("txtsmtpserver")
		return
	elseif #txtsmtpemail$="" then
		msgbox("Email is a mandatory field")
		validateSMTP=0
		setfocus("txtsmtpemail")
		return
	elseif trim$(#txtsmtpsender$) <> "" and trim$(#txtsmtpsender$) <> "0" then  		'BFIX-02
		if emailValidation(trim$(#txtsmtpsender$))=0  then 
			validateSMTP=0
			msgbox("Sender Email ID should be in correct format")
			setfocus("txtsmtpsender")
			return
		end if	
	elseif IP_Validation(#txtsmtpserver$,"smtp server name") then 		'BFIX-02
		validateSMTP=0
		setfocus("txtsmtpserver")
		return
	elseif trim$(#txtsmtpemail$) <> "" and trim$(#txtsmtpemail$) <> "0" then 		'BFIX-02
		if emailValidation(trim$(#txtsmtpemail$))=0  then 
			msgbox("Email ID should be in correct format")
			setfocus("txtsmtpemail")
			return
		end if	
	endif
End Function

/***********************************************************
'** validatePort
 *	Description: Validate Port tab user input controls

 *	Created by:Franklin Jacques  On 2009-05-20 11:44:44
 ***********************************************************/
function validatePort()	
	validatePort=1
	pprint len(#txtporthttp$)
	if #txtporthttp$<>"" and len(#txtporthttp$)<2 or  len(#txtporthttp$)>5 then 
		msgbox("Invalid http port number")
		validatePort=0
		setfocus("txtporthttp")
		return
	elseif #txtporthttps$<>"" and len(#txtporthttps$)<2 or  len(#txtporthttps$)>5 then
		msgbox("Invalid https port number")
		validatePort=0
		setfocus("txtporthttps")
		return
	endif 
	
End Function

/***********************************************************
'** txtporthttps_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-07-16 13:58:51
 ***********************************************************/
sub txtporthttp_focus
	rule=2
End Sub

/***********************************************************
'** txtporthttps_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-07-16 13:58:51
 ***********************************************************/
sub txtporthttps_focus
	rule=2
End Sub


/***********************************************************
'** Checksmtpserverauth_focus
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-07-16 13:58:51
 ***********************************************************/
sub Checksmtpserverauth_focus
	showcursor(1)
End Sub

/***********************************************************
'** Checksmtpserverauth_blur
 *	Description: Control Validation
 
 *	Created by: Franklin Jacques On 2009-07-16 13:58:51
 ***********************************************************/
sub Checksmtpserverauth_blur	
	showcursor(3)
End Sub


/***********************************************************
'** Form_Paint
 *	Description: Paint tab image based on the idx value set
 
 *	Created by: Vimala On 2009-09-30 13:02:20
 ***********************************************************/
Sub Form_Paint
	putimage2(tabImage$,#lblnetwork.x,#lblnetwork.y,5,1,networkIdx)
	putimage2(tabImage$,#lblftp.x,#lblftp.y,5,1,FTPIdx)
//	putimage2(tabImage$,#lblsntp.x,#lblsntp.y,5,1,SNTPIdx)
	putimage2(tabImage$,#lblsmtp.x,#lblsmtp.y,5,1,SMTPIdx)
	putimage2(tabImage$,#lblportsetting.x,#lblportsetting.y,5,1,PortIdx)
	putimage2(tabImage$,#lblrtsp.x,#lblrtsp.y,5,1,RTSPIdx)
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


Sub txtsmtpsender_Focus
	rule = 13
End Sub

Sub txtsmtpsender_blur
	rule=0
End Sub


Sub txtsmtpemail_Focus
	rule = 13
End Sub

Sub txtsmtpemail_blur
	rule = 0
End Sub
