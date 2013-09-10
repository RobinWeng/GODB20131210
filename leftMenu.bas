/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Left Menu                                                   *
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
***************************************************************************************/
dims ~menuArray$(MAXMAINMENU+MAXSUBMENU+3)
dims menuOffImg$(MAXMAINMENU) = ("!camera_Off.bin","!users_Off.bin","!settings_Off.bin","!playback_off.bin","!maintanance_off.bin","!support_off.bin")
dims ~menuOnImg$(MAXMAINMENU) = ("!camera_On.bin","!users_On.bin","!settings_On.bin","!playback_on.bin","!maintanance_on.bin","!support_on.bin")
dims ~urlMainArray$(MAXMAINMENU) = ("!liveVideo.frm", "!addusers.frm","!videoImageSettings.frm","!playback.frm","!maintenance.frm","!supportScreen.frm")
dims ~urlSubArray$(MAXSUBMENU) = ("!videoImageSettings.frm","!videoAnalyticsSetting.frm","!commuport.frm","!cameraSettings.frm", "!audioSetting.frm","!setDateTime.frm", "!NetworkSettings.frm", "!alarmSettings.frm", "!storageSetting.frm","!ptzSetting.frm","!dataCollection.frm")
' DMVAeventMonitor
dimi dmvaEnable

'#imgLogo.hidden=1

#imgselected.hidden = 1	
loadMenuCaptions()
#imgselected.desth = #rosubmenu.h +20	

dimi canReload = 1		 'Default is 1. When 0 display animation.Determines if page submit can be done without animation


dimi wait = 0			'wait flag to switch between screens using specific time gap 

call alginBGImage					'BFIX-05
call buildLeftTree()

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

/***********************************************************
	'** alginBGImage
 *	Description: Resize back ground images based on screen resolution.
 *	Created by: vimala  On 2009-05-15 06:07:30
 *	History: 
 ***********************************************************/
sub alginBGImage()
	dmvaEnable = getDMVAEnableValue()
	
	dimi START_YVALUE,MENU_GAP,SUBMENU_GAP	
	
	START_YVALUE=80
	MENU_GAP=50
	SUBMENU_GAP=30  	
	
	dimi i
	dimi xResVal,yResVal
	yResVal = ~menuYRes
	dims ctrlName$	
	#imgmainbg.x =243
	#imgmainbg.y =0	
	#imgmainbg.DESTW = ~menuXRes - 233
	#imgmainbg.DESTH = yResVal
	#imgleftmenu.DESTW = 248
	#imgleftmenu.DESTH = yResVal
	#imglogout.x = ~menuXRes - #imglogout.w - 20
	#imglogout.y = 35 * ~factorY
	#lblheading.x = 256
	#lblheading.y = 23 * ~factorY
	
	
	'Main menu align ment
	dimi yVal
	yVal = START_YVALUE * ~factorY
	if ~menuYRes = DESIGN_YVAL then
		yVal = START_YVALUE * ~factorY
		MENU_GAP=40 * ~factorY
		SUBMENU_GAP=28 * ~factorY
	end if
	for i = 0 to 2
		iff ~loginAuthority = OPERATOR  and i = 1 then  continue
		ctrlName$ = "imgmenu["+i+"]"		
		#{ctrlName$}.y = yVal
		ctrlName$ = "lblmenuval["+i+"]"		
		#{ctrlName$}.y = yVal+7
		yVal += MENU_GAP
	next	
	
	SUBMENU_GAP = SUBMENU_GAP * ~factorY	
	yVal = #lblmenuval[2].y + #imgmenu[2].desth + SUBMENU_GAP	
	
	for i = 0 to MAXSUBMENU-1		
		ctrlName$ = "rosubmenu["+i+"]"
		pprint "rosubmenu["+i+"]"
		#{ctrlName$}.y = yVal
/*		if dmvaEnable <= 0 and i = 2 then 			'Hiding Smart Analytics setting sub menu from left menu
			#{ctrlName$}.hidden = 1 
		else
			yVal += SUBMENU_GAP
		end if
*/

		if i = 3 or i=1 or i=2 then 			'Hiding camera setting sub menu from left menu
			#{ctrlName$}.hidden = 1 
		else
			yVal += SUBMENU_GAP
		end if
	next
	
	for i = 3 to 5
		ctrlName$ = "imgmenu["+i+"]"		
		#{ctrlName$}.y = yVal
		ctrlName$ = "lblmenuval["+i+"]"		
		#{ctrlName$}.y = yVal+7
		yVal += MENU_GAP
	next	
	pprint "alginBGImage end"
	

	
End Sub


/***********************************************************
'** imgmenu_focus
 *	Description: Assign selected image for the selected image
 *	Created by:Vimala On 2009-05-19 11:53:33
 *	History: 
 ***********************************************************/
Sub imgmenu_focus
	
	iff ~wait <= 1 then return

	dims ctrlName$
	ctrlName$ = curfld$()
	
	if ~changeFlag = 0	 then 
		
		#imgselected.hidden = 0	
		#imgselected.x = #{ctrlName$}.x
		pprint #imgselected.x
		#imgselected.y = #{ctrlName$}.y	
		pprint #imgselected.y
		#imgselected.destw = #{ctrlName$}.destw+10
		pprint ctrlName$
		pprint #imgselected.destw
		#imgselected.desth = #rosubmenu.h +20
		pprint #imgselected.desth
	endif
	showcursor(0)
End Sub                        

/***********************************************************
'** rosubmenu_Focus
 *	Description: Assign selected image for the selected readonly box
 *	Created by: Vimala On 2009-05-19 11:56:05
 *	History: 
 ***********************************************************/
Sub rosubmenu_Focus	
	iff ~wait <= 1 then return
	
	dims ctrlName$
	ctrlName$ = curfld$()
	
	if ~changeFlag = 0	 then 		
		#imgselected.hidden = 0
		#imgselected.x = #{ctrlName$}.x
		#imgselected.y = #{ctrlName$}.y-10
		#imgselected.destw = #{ctrlName$}.w+17
		#imgselected.desth = #rosubmenu.h +20
	endif
	showcursor(0)
End Sub

/***********************************************************
'** loadMenuCaptions
 *	Description: Call this function to load the menu captions
 *				 from menuCaptions.lan
 
 *	Created by: vimala On 2009-05-19 12:02:04
 ***********************************************************/
Sub loadMenuCaptions()	

	dimi i,j
	dims ctrlName$
	loadarray(~menuArray$,"menuCaptions.lan")

	
	for i = 0 to MAXMAINMENU-1
		ctrlName$ = "lblmenuval["+i+"]"
		#{ctrlName$}$ = ~menuArray$(i)
	next
	
	for j = 0 to MAXSUBMENU-1
		ctrlName$ = "rosubmenu["+j+"]"
		#{ctrlName$}$ = ~menuArray$(i)
		pprint "rosubmenu["+j+"]="+~menuArray$(i)
		i++
	next	
	pprint "loadMenuCaptions end"
End Sub

/***********************************************************
'** imgmenu_Click
 *	Description: Loads the selected screen
 *	Created by: vimala On 2009-05-19 12:03:02
 *	History: 
 ***********************************************************/
Sub imgmenu_Click
	
	iff ~wait <= 1 then return
	
	if canReload = 1 then	
		dims ctrlName$
		dimi arrPos
			
		ctrlName$ = curfld$()
		arrPos = getctrlNo(ctrlName$)	
		iff loadedpage$() = ~urlMainArray$(arrPos) then return
		call chkValueMismatch()
		if ~changeFlag = 1	 then 
			~mousemoveflag=1
			msgbox("Do you want to save the changes ",3)
			~mousemoveflag=0
			if Confirm()=1 then		
				showcursor(0)	
				~UrlToLoad$ = ~urlMainArray$(arrPos)
				savePage()	
				iff ~changeFlag = 0	 then loadurl(~urlMainArray$(arrPos))	
			else 
				~changeFlag = 0
				loadurl(~urlMainArray$(arrPos))
			endif 
		else
			loadurl(~urlMainArray$(arrPos))
		endif
	end if
	
End Sub


/***********************************************************
'** assignSelectedImage
 *	Description: Call assignOffImages function to assign OFF image.
 *				 Assign selected image for the control.
 *				 
 *	Params:
 *		dims ctrlName$: String - Name of the control.
 *	Created by: vimala On 2009-05-19 12:03:33
 *	History: 
 ***********************************************************/
Sub assignSelectedImage(dims ctrlName$)	
	dimi arrPos
			
	assignOffImages()

	arrPos = getctrlNo(ctrlName$)
	#{ctrlName$}.src$ =  ~menuOnImg$(arrPos)
	
	if arrPos = 2 then
		showSubMenu(0,1)
		setfocus("rosubmenu")
		rosubmenu_Click
	else 
		showSubMenu(1,0)		
	end if 
	
	#lblheading$=~menuArray$(arrPos)
	pprint "assignSelectedImage end"
End Sub


/***********************************************************
'** getctrlNo
 *	Description: Call this function to get the control array index.
 *	Params:
 *		dims ctrlName$: String - Name of the control
 *	Created by: vimala On 2009-05-19 12:11:34
 *	History: 
 mend by wbb
 ***********************************************************/
Function getctrlNo(dims ctrlName$)
	
	dimi pos,pos1,pos2
	pos1= find(ctrlName$,"[")
	iff pos1 = -1 then return 0
	//ctrlName$ = repl$(ctrlName$,"]","")
	pos2= find(ctrlName$,"]")
	pos = atol(midb$(ctrlName$,pos1+1,pos2-1))
	return pos	
	
End Function


/***********************************************************
'** assignOffImages
 *	Description: Call this function to assign OFF image to all 
 *				 the image control.
 *	Created by: vimala On 2009-05-19 12:12:31
 *	History: 
 ***********************************************************/
Sub assignOffImages()
	
	dimi i
	dims ctrlName$
	
	for i = 0 to MAXMAINMENU-1
		ctrlName$ = "imgmenu["+i+"]"		
		#{ctrlName$}.src$ = menuOffImg$(i)
	next
	
End Sub

/***********************************************************
'** showSubMenu
 *	Description: Call this function to show or hide the settings sub menu.
 *	Params:
'*		dimi showFlag: Numeric - 0 - show sub menu
 *								 1 - Hide sub menu			
 *		dimi selFlag: Numeric -  if set to 1, sets focus to setting image.
 *	Created by: vimala On 2009-05-19 12:13:30
 *	History: 
 ***********************************************************/
Sub showSubMenu(dimi showFlag,dimi selFlag)
	
	dimi j
	dims ctrlName$
	
	for j = 0 to MAXSUBMENU-1
		ctrlName$ = "rosubmenu["+j+"]"
'		iff dmvaEnable <= 0 and j = 2 then continue				'Hiding Smart Analytics setting sub menu from left menu
		iff  j = 3 or j=1 or j=2 then continue				'Hiding Smart Analytics setting sub menu from left menu
		#{ctrlName$}.hidden = showFlag			
	next	
	
	iff selFlag = 1 then #imgmenu[2].src$ =  ~menuOnImg$(2);setfocus("imgmenu[2]")
	pprint "showSubMenu end"
End Sub



/***********************************************************
'** rosubmenu_Click
 *	Description: Load the selected setting screen
 *	Created by: vimala On 2009-05-19 12:17:38
 *	History: 
 ***********************************************************/
Sub rosubmenu_Click
	showcursor(0)
	iff ~wait <= 1 then return
	
	if canReload = 1 then	
		dims ctrlName$
		dimi arrPos
		
		ctrlName$ = curfld$()
		pprint  "ctrlName$==============================="+curfld$()
		arrPos = getctrlNo(ctrlName$)
		pprint "arrpos======================================"+arrpos
		iff loadedpage$() = ~urlSubArray$(arrPos) then return
		call chkValueMismatch()
		if ~changeFlag = 1 then 
			~mousemoveflag=1
			msgbox("Do you want to save the changes",3)
			~mousemoveflag=0
			if Confirm()=1 then		
				showcursor(0)	
				~UrlToLoad$ = ~urlSubArray$(arrPos)
				savePage()	
				iff ~changeFlag = 0	 then loadurl(~urlSubArray$(arrPos))						
			else 
				~changeFlag = 0
				loadurl(~urlSubArray$(arrPos))				
			endif 
		else
			pprint "~urlSubArray$(arrPos)="+~urlSubArray$(arrPos)
			loadurl(~urlSubArray$(arrPos))			
		endif
	end if
End Sub



/***********************************************************
'** rosubmenu_blur
 *	Description: set showcursor
 *	Created by: Franklin On 2009-05-19 12:17:38
 *	History: 
 ***********************************************************/
sub rosubmenu_blur
	showcursor(3)
End Sub

/***********************************************************
'** selectSubMenu
 *	Description: Call assignFGcolor function to set default FG color
 *				 and change the FG color for the selected setting
 *	Created by: vimala On 2009-05-19 12:18:04
 *	History: 
 ***********************************************************/
Sub selectSubMenu()
	
	dims ctrlName$
	dimi arrPos
	
	assignFGcolor()
	
	ctrlName$ = curfld$()
	
	arrPos = getctrlNo(ctrlName$)
	
	#{ctrlName$}.fg = 64512
	#{ctrlName$}.selfg = 64512
	#lblheading$=~menuArray$(MAXMAINMENU+arrPos)
	
End Sub

/***********************************************************
'** assignFGcolor
 *	Description: Call this function to set default FG color.
 *	Created by: vimala On 2009-05-19 12:19:30
 *	History: 
 ***********************************************************/
Sub assignFGcolor()
	
	dimi j
	dims ctrlName$
	
	for j = 0 to MAXSUBMENU-1
		ctrlName$ = "rosubmenu["+j+"]"
		#{ctrlName$}.fg = 42228
		#{ctrlName$}.selfg = 42228
	next	
	pprint "assignFGcolor end"
End Sub


/***********************************************************
'** lblmenuval_Click
 *	Description: Click on the image label loads the selected screen
 *	Created by: vimala On 2009-05-19 12:21:16
 *	History: 
 ***********************************************************/
Sub lblmenuval_Click	
	call imgmenu_Click
End Sub



/***********************************************************
'** setLeftMenuFocus
 *	Description: Hitting ESC key sets focus to next main menu control
 *	Params:
'*		dimi key: Numeric - Key value
 *		dimi menuNo: Numeric - currently selected menu number
 *	Created by: vimala On 2009-05-19 12:22:24
 *	History: 
 ***********************************************************/
Sub setLeftMenuFocus(dimi key,dimi menuNo)	
	
	dims ctrlName$
	
	if key = 15 then
		menuNo++
		ctrlName$ = "imgmenu["+menuNo+"]"
		setfocus(ctrlName$)	
		showcursor(0)
	end if

End Sub



/***********************************************************
'** setSubMenuFocus
 *	Description: Hitting ESC key sets focus to next Sub menu control
 *	Params:
'*		dimi key: Numeric - Key value
 *		dimi menuNo: Numeric - currently selected menu number
 *	Created by: vimala On 2009-05-19 12:23:17
 *	History: 
 ***********************************************************/
Sub setSubMenuFocus(dimi key,dimi menuNo)
	
	
	dims ctrlName$
	
	if key = 15 then
		
		if menuNo = 7 then 
			setLeftMenuFocus(key,2)				
		else
			menuNo++
			ctrlName$ = "rosubmenu["+menuNo+"]"
			setfocus(ctrlName$)				
		end if
		showcursor(0)
	end if
	pprint "setSubMenuFocus0/end"
End Sub


/***********************************************************
'** buildLeftTree
 *	Description: call this function to hide and show 
 *				 left menu controls based on user's authority
 *	Created by:  On 2009-05-17 23:50:13
 *	History: 
 ***********************************************************/
Sub buildLeftTree	
	
	if ~loginAuthority = OPERATOR then
		#imgmenu[1].hidden = 1
		#lblmenuval[1].hidden = 1		
		'reAlignMenu()
	elseif ~loginAuthority = VIEWER then
		#imgmenu[1].hidden = 1
		#imgmenu[2].hidden = 1
		#lblmenuval[1].hidden = 1
		#lblmenuval[2].hidden = 1
		#imgmenu[3].hidden = 1
		#imgmenu[4].hidden = 1
		#imgmenu[5].hidden = 1
		#lblmenuval[3].hidden = 1
		#lblmenuval[4].hidden = 1
		#lblmenuval[5].hidden = 1
		showSubMenu(1,0)
	else
		#imgmenu[1].hidden = 0
		#imgmenu[2].hidden = 0
		#lblmenuval[1].hidden = 0
		#lblmenuval[2].hidden = 0
		showSubMenu(0,0)	
	endif	
	
'	#imgLogo.x = #imgmenu[1].x + 5 
	#imgLogo.y = #imgleftmenu.desth - (70 * ~factorY )
	#imgLogo.x = #imgmenu[1].x + 35 
	'#imgLogo.y = #imgleftmenu.desth - (50 * ~factorY )
End Sub


/***********************************************************
'** ReAlignMenu
 *	Description: Call this function to re algin control positions
 *	Created by: Vimala On 2009-05-18 00:32:20
 *	History: 
 ***********************************************************/
sub reAlignMenu()
	dimi j,yVal,SUBMENU_GAP
	dims ctrlName$,prevCtrl$
	#lblmenuval[2].y = #lblmenuval[1].y
	#imgmenu[2].y = #imgmenu[1].y
	SUBMENU_GAP = 35 * ~factorY 	
	yVal = #lblmenuval[2].y + #imgmenu[2].desth + SUBMENU_GAP 

	for j =  0  to MAXSUBMENU-1 
		ctrlName$ = "rosubmenu["+j+"]"	
		#{ctrlName$}.y  = yVal
		yVal += SUBMENU_GAP	
	next	

	
	
End Sub



/***********************************************************
'** imgLogout_Click
 *	Description: Loads the login screen
 *	Created by: vimala On 2009-05-19 12:27:07
 *	History: 
 ***********************************************************/
Sub imgLogout_Click
	loadurl("!auth.frm")	
End Sub


/***********************************************************
'** checkForModification
 *	Description: Call this function to check whether the control values are modified or not.
 *				 set ~changeFlag = 1 if control value modified.
 *		
 *		
 *	Params:
 *		key: Numeric - Key value
 *	Created by:  On 2009-06-10 10:32:11
 *	History: 
 ***********************************************************/
Sub checkForModification(dims ctrlValues$(), dims LabelName$())	
	~changeFlag = 0
	dimi i
	for i = 0 to ubound(ctrlValues$)			
		iff LabelName$(i) = "" or LabelName$(i) = "lblSuccessMessage" then continue
		pprint LabelName$(i);ctrlValues$(i);#{LabelName$(i)}$ 
		if ctrlValues$(i) <> #{LabelName$(i)}$ then
			~changeFlag = 1		
			break
		end if
	next
End Sub


/***********************************************************
'** getFocus
 *	Description: Call this function to return control window handle 
 
 *		key: Numeric - Key value
 *	Created by: vimala  On 2009-06-10 10:32:11
 *	History: 
 ***********************************************************/
Sub getFocus()  	                                                                                                                        
	dimi focusHandle   'Declare for LIB Handle returned by LOADLIB                                                                         
	dimi hwnd          'Default parameters for setting window style                                                                        
	focusHandle = loadlib("user32.dll") 'if win32 means load the coredll for calling SetFocus function                                     
	hwnd = atol(getosvar$("*hwnd"))   'Returns the control window handle                                                                
	CallLibFuncPas(focusHandle,"SetFocus",hwnd) 'call the DLL function 'SetFocus'                                                       
	unloadlib(focusHandle)            'Unloading the handle                                                                             
End Sub  


