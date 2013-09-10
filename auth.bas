/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Authentication Page                                         *
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
Login screen.
Load user name and password if remember password is enabled.
Validates entered user name and password.
On successful login loads live video screen.
*/
 
option(4)
showcursor(3)
#include "defines.inc"
#include "common.inc"
#include "functions.inc"

#define LOGIN_BG_W           1024
#define LOGIN_BG_H           600
#define USER_NAME_X          480 
#define USER_NAME_Y          380
#define LOGIN_CONTROL_GAP    13
#define LOGIN_TEXT_BOX_W     176

dims loginBG$			'Login background image
getimagefile(loginBG$, "!login_bg.jpg")
setstyle(GODB_BG_COL,1)

dimi loginImgX			'Login Bacground image X position
dimi loginImgY			'Login Bacground image Y position
dimi ~loginAuthority	'Holds login user's authority

call findXYPos()
call setControlPos()
dimi rule
dimi ~videocodecmode	'Holds Video Codec mode

setfocus("txtusername")

'Check remember password check box if remeber password is enabled.

/*call Get_username_pwd_rememberPwd()

if ~rememberPwd = 1 then
	#chkrememberpwd.checked = 1    	 	'TR-10
else
	#chkrememberpwd.checked = 0
end if*//* no remember passwd */
writeprofile("PAGENAME","LOGIN")
dimi ~reLoadTime				   		'TR-40
end


/***********************************************************
'** Get_username_pwd_rememberPwd
 *	Description: get username, paswwd and ~rememberPwd from profile
 
 *	Created by: Mayue On 2013-02-05 15:57:10
 ***********************************************************/

Sub Get_username_pwd_rememberPwd
'read ~rememberPwd from profile with IPNC. by mayue 5 feb 2013
                                                                                                                       
dims loginDet$,loginInfo$,tempDet$
dimi ret,splitcount

readprofile("IPNC",loginDet$)
ret = decode(loginDet$,loginInfo$,1)
splitcount	 = split(tempDet$,loginInfo$,":")
pprint "loginInfo$ = "  + loginInfo$

#txtusername$ = ""
#txtpassword$ = ""

if splitcount = 3 then 
	~rememberPwd = 	atol(trim$(tempDet$(2)))
	
	if ~rememberPwd = 1 then
	#txtusername$ = tempDet$(0)
	#txtpassword$ = tempDet$(1)
	~authUserName$ = trim$(#txtusername$)
	~authPassword$ = trim$(#txtpassword$)
	end if	
end if

'read ~rememberPwd from profile with IPNC. by mayue 5 feb 2013
End Sub

/***********************************************************
'** Save_username_pwd_rememberPwd
 *	Description: save username, paswwd and ~rememberPwd from profile
 
 *	Created by: Mayue On 2013-02-05 15:57:10
 ***********************************************************/

/*Sub Save_username_pwd_rememberPwd

'save ~rememberPwd to profile with IPNC. by mayue 5 feb 2013
dims loginDet$,loginInfo$
dimi ret

if ~rememberPwd = 1 then
	loginInfo$ = #txtusername$+":"+#txtpassword$+":"+~rememberPwd
	ret = Encode(loginInfo$,loginDet$,1);
	writeprofile("IPNC",loginDet$)
endif

'save ~rememberPwd to profile with IPNC. by mayue 5 feb 2013
End Sub*//* no remember passwd */

/***********************************************************
'** Form_paint
 *	Description: Display the BG img for login page and display the login controls.
 
 *	Created by: Partha Sarathi.K On 2009-03-06 12:53:10
 ***********************************************************/
Sub Form_paint	
	putimage2(loginBG$, loginImgX, loginImgY, 5, 0, 0)
	#txtusername.paint(0)
	#txtpassword.paint(0)
	#cmdsubmit.paint(0)
	/*#chkRememberPwd.paint(0)*//* no remember passwd */ 				'TR-10
End Sub

/***********************************************************
'** findXYPos
 *	Description: Find the X and Y pos for display the login controls.
 
 *	Created by: Partha Sarathi.K  On 2009-03-06 14:22:27
 ***********************************************************/
sub findXYPos()
	
	loginImgX = (~menuXRes - LOGIN_BG_W)/2
	iff loginImgX < 0 then loginImgX = 0
	
	loginImgY = (~menuYRes - LOGIN_BG_H)/2
	iff loginImgY < 0 then loginImgY = 0
	
End Sub

/***********************************************************
'** setControlPos
 *	Description: Set the X and Y pos for login controls based on screen resolution.
 
 *	Created by: Partha Sarathi.K On 2009-03-06 14:36:25
 ***********************************************************/
sub setControlPos()
	
	dims ctrlName$(3/*4*//* no remember passwd */) = ("txtusername", "txtpassword",/*"chkRememberPwd",*//* no remember passwd */"cmdsubmit",)     				'TR-10
	dimi i
	dimi yPos
	
	yPos = loginImgY + USER_NAME_Y
	
	for i=0 to ubound(ctrlName$) 
		
		if i<>2/*3*//* no remember passwd */ then			 				'TR-10
			#{ctrlName$(i)}.x = loginImgX + USER_NAME_X
			#{ctrlName$(i)}.w = LOGIN_TEXT_BOX_W
		else
			#{ctrlName$(i)}.x = loginImgX + USER_NAME_X+LOGIN_CONTROL_GAP
		endif
		
		#{ctrlName$(i)}.y = yPos
		
		yPos += CONTROL_HEIGHT + LOGIN_CONTROL_GAP
		
	next
		
End Sub


/***********************************************************
'** cmdimgSubmit_Click
 *	Description: Get the ip address from command line.
 *				 validates entered user name and passwords.
 *				 Gets user authority.
 *				 Redirects to live video on successful login.
 *	Created by: Partha Sarathi.K On 2009-03-06 15:05:47
 ***********************************************************/
Sub cmdSubmit_Click
	iff len(~debugInfo$) > 9900 then ~debugInfo$ = ""
	
	dimi ret, file
	dims userName$(10), userAuth$(10)
	
	if trim$(#txtusername$) = "" then
		msgbox("Enter User Name")
		setfocus("txtusername")
		return		
	elseif trim$(#txtpassword$) = "" then
		msgbox("Enter Password")
		setfocus("txtpassword")
		return	
	endif	
	
	~authUserName$ = trim$(#txtusername$)
	~authPassword$ = trim$(#txtpassword$)

	GetIPAddress()
	
	ret = dwnldIniFile()

	if ret > 0 then
		
		~title$ = getTitle$()
		calXYVal()	
		'success
		dimi authRet
		authRet =  getUserAuthority()
		/**********Added for testing *************************/
		/*authRet = 1
		~loginAuthority = ADMIN
		loadurl("!liveVideo.frm")*/
		/***********************************/
		pprint "authRet = " + authRet		
		if authRet = -1 then
			msgbox "Invalid user name or password"
		else
			writeprofile("PAGENAME","LIVEVIDEO")
			/*call Save_username_pwd_rememberPwd()*//* no remember passwd */
			loadurl("!liveVideo.frm")
		endif
	else
		'failure
		#txtusername$ = ""
		#txtpassword$ = ""
		SETFOCUS("txtusername")
		msgbox("Login Failed")
	end if	
	
End Sub

/***********************************************************
'** Form_KeyPress
 *	Description:  Checks for key validation		
	
 *	Params:
'*		Key: Numeric -  char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by:  On 2009-03-23 16:28:40
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )	
	dims keypressed$
	keypressed$ = chr$(getkey())
	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)	
End Sub


/***********************************************************
'** Form_Load
 *	Description: Load the user name and password if remember flag is set
 *	Created by: Vimala  On 2009-10-22 15:16:48
 *	History: 
 ***********************************************************/
Sub Form_Load		 				'TR-10
	
	/*if #chkrememberpwd.checked = 1 then 
		dims loginDet$,loginInfo$,tempDet$
		dimi ret,splitcount
		readprofile("IPNC",loginDet$)
		ret = decode(loginDet$,loginInfo$,1)
		splitcount	 = split(tempDet$,loginInfo$,":")
		pprint "loginInfo$ = "  + loginInfo$
		if splitcount = 3 then 
			#txtusername$ = tempDet$(0)
			#txtpassword$ = tempDet$(1)
			~authUserName$ = trim$(#txtusername$)
			~authPassword$ = trim$(#txtpassword$)	
			~rememberPwd = 	atol(trim$(tempDet$(2)))
		else 
			#txtusername$ = ""
			#txtpassword$ = ""
		end if
	else 
		#txtusername$ = ""
		#txtpassword$ = ""
		writeprofile("IPNC","")	
	end if*/
End Sub


/***********************************************************
'** chkRememberPwd_Click
 *	Description: clear the stored user name and password from temprory memory 
 *				 when remeber password is unchecked.
 
 *	Created by: Vimala On 2009-10-22 15:18:09
 ***********************************************************/
/*Sub chkRememberPwd_Click
	
	if #chkRememberPwd.checked = 0 then
		~rememberPwd = 0
		writeprofile("IPNC","")	
	else
		~rememberPwd = 1
	end if

End Sub*//* no remember passwd */

'Cursor is turned on
Sub chkRememberPwd_Focus
	showcursor(1)
End Sub

'Only Edit Box Cursor is displayed 
Sub chkRememberPwd_Blur
	showcursor(3)
End Sub


'Validates each key press based on the rule assigned to that user input control
Sub txtUserName_Focus	
	rule = 5
End Sub

Sub txtPassword_Focus
	rule = 5
End Sub

