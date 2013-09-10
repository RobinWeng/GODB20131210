/****************************************************************************
 * gTI IPNC - Login
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
/*
This is the first page launched by the application.
Checks for whether remember password is enabled by reading the Name Value pair from temperory memory(readprofile) 
Checks which page to load based on the event. F5/refresh - load live video else login page
*/


/*Inculded files*/
#include "defines.inc"
#include "common.inc"
#include "functions.inc"

'set the background color of the form to black color
SetStyle(GODB_BG_COL,1)

'Disable scroll bar
showscroll(0)

'Empty default enable menu
loadmenu(" ")

'set connection timeout
SetOsVar("*ConnectionTimeOut",15000) 
SetOsVar("*SendTimeOut",20000) 
SetOsVar("*RecvTimeOut",20000)


'Global variables
dimi ~menuXRes			'Holds Screen X resolution
dimi ~menuYRes			'Holds Screen Y resolution

dims ~camAddPath$		'Holds IPNC IP Address
dims ~authUserName$		'Login user name
dims ~authPassword$		'Login user's password
dims ~authHeader$		'Holds Http header information
dims ~responseData$		'holds Http Response data value
dimi ~changeFlag	

'Get screen resolution
~menuXRes = getxres()
~menuYRes = getyres()


~maxXRes = ~menuXRes - DISPLAY_REGION_X - BORDER_GAP
~maxYRes = DISPLAY_REGION_H + HEADER_HEIGHT

dims ~iniProperties$(MAX_VALUES) 
dims ~iniPropValues$(MAX_VALUES)
dimi ~maxPropIndex
dims ~title$
dims ~imgSelMenu$, ~imgTopBanner$, ~imgMenuBG$, ~imgBannerRightEnd$, ~imgBannerBG$
dims ~imgLogo$, ~imgMenuExtract$, ~imgPageUPDown$, ~imgBG$, ~imgLogOut$, ~imgBGRightEnd$, ~imgMenuIcon$
dimi ~displayW
dimi ~selmenuIdx = 0, ~selSubMenuIdx = 0, ~subMenuCount
dimi ~subMenuStartIdx
dimi ~tiles(1,1)
dimi ~isSubMenuLoaded
~isSubMenuLoaded = 0
dimi ~subMenuIndex(1)
dimi ~subMenuH
dimi ~wait = 2
dimi ~keywordDetFlag = 1   
dims ~errorKeywords$
dim ~debugInfo$(10000)
dims ~chkImage$,~drpImage$,~optImage$,~tiLogo$
getimagefile(~chkImage$,"!check.bin")
getimagefile(~drpImage$,"!drop.bin")
getimagefile(~optImage$,"!radio.bin")

'Hold remember Pwd flag
dimi ~rememberPwd		

'Message appears when stream W/H > 2048
~Unable_To_Display_Msg$ = "This stream cannot be previewed as width or height is greater than 2048"
end


/***********************************************************
'** Form_Load
 *	Description: Read page naem and user name,password from temperory memory(readprofile).
 *				 Loads login page / live video page based on the key event.
 *				 F5/refresh - load live video else login page
 *	Created by: Vimala On 2009-02-26 13:22:22
 *	History: 
 ***********************************************************/
Sub Form_Load	
	authsuccess()
	dims pageName$	
	readprofile("PAGENAME",pageName$)
	
	dims loginDet$,loginInfo$,tempDet$
	dimi ret,splitcount
	readprofile("IPNC",loginDet$)
	ret = decode(loginDet$,loginInfo$,1)
	splitcount	 = split(tempDet$,loginInfo$,":")

	if splitcount = 3 then 
		#imgLoading.x = getxres()/2 - 200
		#imgLoading.y = getyres()/2 - 100
		
		~authUserName$ = trim$(tempDet$(0)) 
		~authPassword$ = trim$(tempDet$(1)) 
		~rememberPwd = 	atol(trim$(tempDet$(2)))
		GetIPAddress()		
		pprint ~camAddPath$	
		ret = dwnldIniFile()
		
		if ret > 0 then			
			~title$ = getTitle$()
			calXYVal()	
			'success
			dimi authRet
			authRet =  getUserAuthority()
			pprint "authRet = " + authRet
			/**********Added for testing *************************/
			/*authRet = 1
			~loginAuthority = ADMIN
			loadurl("!liveVideo.frm")*/
			/***********************************/
			if authRet = -1 then
				msgbox "Invalid user name or password"
				loadurl("!auth.frm")			
			else 
				if pageName$ = "LOGIN" then
					loadurl("!auth.frm")
				else					
					loadurl("!liveVideo.frm")					
				end if
			endif
		else
			'failure
			msgbox("Login Failed")
			loadurl("!auth.frm")
		end if	
	else		
		loadurl("!auth.frm")
	end if
	
End Sub


