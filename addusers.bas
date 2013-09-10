/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Add \ Edit Users                                                *
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
Can Add / Edit / Delete users using this page.
Maximum of 10 users can be added to the camera.
User authourity can be set for each user.
Selected user can be deleted after users confirmation.
*/

option(4+1)
showcursor(3)
#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"

#define GRID_USER_NAME_WIDTH    206
#define GRID_AUTHORITY_WIDTH    126
#define GRID_ADD_WIDTH          126
#define GRID_DELETE_WIDTH       126
#define GRID_HEIGHT             280
#define GRID_ROW_HEIGHT         25
#define GRID_BG_COL             2245
#define GRID_BDR_COL            35
#define GRID_LINE_COL           19216

dimi noofctrl  								 'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS
dims LabelName$(noofctrl)					 'Form controls name
dimi XPos(noofctrl)							 'Form controls X position
dimi YPos(noofctrl) 						 'Form controls Y position
dimi Wdh(noofctrl)							 'Form controls Width position
dimi height(noofctrl)						 'Form controls height position

#include "addusers.inc"

dimi authorityAdmin 						'User Authority admin value
dimi authorityOperator 						'User Authority Operator value
dimi authorityViewer 						'User Authority Viewer value
dimi minNameLen 							'User minimum name length
dimi minPwdLen 								'User Password length
dimi rule									'Rule for input key validation
~wait = 2									'To wait flag when switching between forms
dimi editFlag
end 

/***********************************************************
'** fetchUserDetails
 *	Description: Call this function to fetch user details from the camera
 *				 and display in the grid.
 *				 Cannot delete/edit Admin user.	
 
 *	Created by: vimala On 2009-03-17 12:50:41
 ***********************************************************/
Sub fetchUserDetails
		
	dims user$(10)					'Holds IPNC User names
	dims authority$(10)			    'Holds IPNC User's Authority
	dimi retVal						'IPNC return value
	
	retVal = getUserSetting(authorityAdmin,authorityOperator,authorityViewer, _
							minNameLen,minPwdLen,user$,authority$)
	#eguserlist.deleteall()
							
	if retVal >= 0 then
		dims username$(2)
		dims authname$(2)
		dimi sptidx,i
		dims authourityname$
		
		for i = 0 to Ubound(user$)
			sptidx = split(username$,user$(i),":")
			if sptidx = 2 then
				sptidx = split(authname$,authority$(i),":")
				if sptidx = 2 then 
					authourityname$ = getauthority$(atol(authname$(1)))
					
					/*if  username$(1)<>"" and authourityname$ <> "" then
						if ucase$(username$(1)) = "ADMIN"  then
							#eguserlist.addrow(username$(1)+chr$(255)+authourityname$+chr$(255)+"Edit"+chr$(255)+chr$(255)+atol(authname$(1)))
						elseif  ucase$(username$(1)) = ucase$(~authUserName$) then 
							#eguserlist.addrow(username$(1)+chr$(255)+authourityname$+chr$(255)+"Edit"+chr$(255)+chr$(255)+atol(authname$(1)))
						else
							#eguserlist.addrow(username$(1)+chr$(255)+authourityname$+chr$(255)+"Edit"+chr$(255)+"Delete"+chr$(255)+atol(authname$(1)))
						endif					
					endif*//* modified by mayue 2013.02.06, new code is below */
					
					/* add by mayue 2013.02.06 */

					if  username$(1)<>"" and authourityname$ <> "" then
						if ~loginAuthority = ADMIN then
							if username$(1) = ~authUserName$ then
								#eguserlist.addrow(username$(1)+chr$(255)+authourityname$+chr$(255)+"Edit"+chr$(255)+chr$(255)+atol(authname$(1)))
							else
								#eguserlist.addrow(username$(1)+chr$(255)+authourityname$+chr$(255)+"Edit"+chr$(255)+"Delete"+chr$(255)+atol(authname$(1)))
							endif
						elseif username$(1) = ~authUserName$ then
							#eguserlist.addrow(username$(1)+chr$(255)+authourityname$+chr$(255)+"Edit"+chr$(255)+chr$(255)+atol(authname$(1)))
						endif
					endif
					/* add by mayue 2013.02.06 */

				endif
			endif
		next
		 			
	endif
	
	setfocus("txtusername")
End Sub

/***********************************************************
'** Form_Load
 *	Description:Display controls based on the screen resolution 
 *				Call setGridSettings function to set egrid settings
 *				and call fetchUserDetails function to fetch and display 
 *				users avaiable in camera.		
 
 *	Created by: vimala On 2009-03-17 12:55:31

 ***********************************************************/
Sub Form_Load	
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	call setGridSettings()
	call fetchUserDetails()	  'TR-01
	#optauthority$ = "0"
	
	assignSelectedImage("imgmenu[1]")		
	setfocus("imgmenu[1]")
	showSubMenu(0,0)
	setfocus("txtusername")
	showcursor(3)
End Sub


/***********************************************************
'** setGridSettings
 *	Description: call this function to set column names,column widths 
 *				 and other egird properties.
 		
 *	Created by: vimala On 2009-03-17 12:57:00
 ***********************************************************/
sub setGridSettings	
	#eguserlist.coldelim$ = chr$(255)
	#eguserlist.colnames$ = "用户姓名 "+chr$(255)+"权限"+chr$(255)+"编辑"+chr$(255)+"删除"+chr$(255)+"Authid"
	#eguserlist.fldwidth(0) = GRID_USER_NAME_WIDTH * ~factorX
	#eguserlist.fldwidth(1) = GRID_AUTHORITY_WIDTH* ~factorX
	#eguserlist.fldwidth(2) = GRID_ADD_WIDTH* ~factorX
	#eguserlist.fldwidth(3) = GRID_DELETE_WIDTH* ~factorx
	#eguserlist.fldwidth(4) = 0
	#eguserlist.cellstyle(-1,2) = 10
	#eguserlist.cellstyle(-1,3) = 10	
	#eguserlist.LockColWidths = 1 	
	#eguserlist.showscroll = FALSE
	#eguserlist.rowheight  = GRID_ROW_HEIGHT
	#eguserlist.brdr       = GRID_BDR_COL
	#eguserlist.bg         = GRID_BG_COL
	#eguserlist.selbg      = GRID_BG_COL
	#eguserlist.selbrdr    = GRID_BDR_COL
	#eguserlist.font       = 2
	#eguserlist.cellbrdr   = GRID_LINE_COL				
End Sub

/***********************************************************
'** clearControlValue
 *	Description: call this function to clear all the control values.
 	
 *	Created by: vimala On 2009-03-17 12:58:42
 ***********************************************************/
sub clearControlValue()	
	#txtusername$ = ""
	#password$ = ""
	#pwdconfirm$ = "" 
	#optauthority$ = "0" 
	editFlag = 0
	disableCtrls(0)
End Sub

/***********************************************************
'** cmdSave_Click
 *	Description: call savePage to add users to camera
 
 *	Created by: vimala On 2009-03-17 12:59:17
 *	History: 
 ***********************************************************/
Sub cmdSave_Click
	savePage()
End Sub


/***********************************************************
'** savePage
 *	Description: Checks for mandatory fields
 *				 Add user to the camera and to egrid.
 
 *	Created by: Vimala On 2009-05-28 16:34:07
 ***********************************************************/
Sub savePage()
	msgbox("addusers.bas")
	dims authourityname$		'Added user's authority
	dimi retVal					'Holds IPNC return value
	dimi i						'Loop variable
	dimi userExistFlag
	
	iff validateuserdetails() = 0 then return
	~debugInfo$ += "Add User \n"
	if #eguserlist.rowcount < 10 then 
		authourityname$ =  getauthority$(#optauthority)
		
		for i = 0 to #eguserlist.rowcount-1	
			if #txtusername$ = #eguserlist$(i,0) then				
				userExistFlag = 1 
				break
			endif
		next
		
		if userExistFlag = 1 and editFlag = 0 then
			if msgbox("User already exist.Do you want to replace?",3) = 0 then
				clearControlValue()	
				return				
			end if					
		end if
			
			
		if trim$(#txtusername$)<>"" and trim$(#password$)<>"" and trim$(#optauthority$)<>"" then
			retVal = addUser(#txtusername$,#password$,#optauthority)
		else 
			msgbox("unable to add user")
			return	
		endif
		
		if retVal=0 then 
			msgbox("Added the user "+#txtusername$+" in the camera")	
			if editFlag = 1  and ~authUserName$=trim$(#txtusername$) then
				~authUserName$ = trim$(#txtusername$)
				~authPassword$ = trim$(#password$)
				dimi ret
				ret = dwnldIniFile()
				if ret < 0 then 
					msgbox "Login Failed"
					loadurl("!auth.frm")
				end if							
			end if								
			fetchUserDetails()
		else 
			msgbox("Could not create user in the camera")			
		endif	
				
	else 
		msgbox("Number of users should not exceed 10")
	endif
	
	call clearControlValue()		

End Sub

/***********************************************************
'**  validateuserdetails
 *	Description: Call this function to check for mandatory fields.
 *				 Checks for valid input.
 
 *	Created by: vimala On 2009-03-17 14:24:25
 ***********************************************************/
Function  validateuserdetails	
	validateuserdetails = 1
	
	if trim$(#txtusername$) = "" then
		msgbox("Enter user name")
		setfocus("txtusername")
		validateuserdetails = 0
		return
	elseif trim$(#password$) = "" then
		msgbox("Enter password")
		setfocus("password")
		validateuserdetails = 0
		return
	elseif trim$(#pwdconfirm$) = "" then
		msgbox("Enter confirm password")
		setfocus("pwdconfirm")
		validateuserdetails = 0
		return	
	elseif trim$(#optauthority$) = "" then
		msgbox("select authority")
		setfocus("optauthority")
		validateuserdetails = 0
		return	
	elseif len(trim$(#txtusername$))<minNameLen then
		msgbox("User name should have minimum of "+minNameLen+" characters")
		setfocus("txtusername")
		validateuserdetails = 0
		return	
	elseif len(trim$(#password$))<minPwdLen then
		msgbox("Password should have minimum of "+minPwdLen+" characters")
		setfocus("password")
		validateuserdetails = 0
		return	
	elseif trim$(#password$) <> trim$(#pwdconfirm$) then	
		msgbox("Password mismatch")
		setfocus("pwdconfirm")
		validateuserdetails = 0
		return		
	endif
	
End Function

/***********************************************************
'** getauthority$
 *	Description: Function returns authority name by passing authority id.
 *				  0 - Admin
 *				  1 - Operator
 *				  2 - Viewer
 *	Params:
 *		dims authorityid$: String - Authority ID
 * 		Return Value : Returns Authority Name.
 *	Created by: vimala On 2009-03-17 14:25:41
 ***********************************************************/
Function getauthority$(dims authorityid$)	
	dims authority$
	
	if authorityid$= "" then
		getauthority$ = "" 
		return
	endif
	
	if 	authorityid$ = "0" then
		authority$ = "Admin"
	elseif authorityid$ = "1" then
		authority$ = "Operator"
	elseif authorityid$ = "2" then
		authority$ = "Viewer"
	endif	
	
	getauthority$ = authority$
End Function

/***********************************************************
'** eguserlist_Click
 *	Description: Clicking on Edit link will populate the selected 
 *				 row values in user input control and can edit the authority 
 *				 and enter new password.
 *				 Delete the same row from the grid.
 
 *	Created by: vimala On 2009-03-17 14:28:16
 ***********************************************************/
Sub eguserlist_Click	
	
	dimi intSelCol				'Hold Egrid selected column value
	dimi intSelRow				'Hold Egrid selected row value
	dimi retVal					'Holds IPNC Return Value
		
	intSelRow = #eguserlist.currow
	intSelCol = #eguserlist.curcol		
	
	if #eguserlist.rowcount > 0 and #eguserlist.selrow >= 0 and #eguserlist.selcol >= 0  then
		
		if #eguserlist$(intSelRow,intSelCol) = "Edit" then
			#txtusername$ = #eguserlist$(intSelRow,0)
			#optauthority$ = #eguserlist$(intSelRow,4)
			#password$ = ""
			#pwdconfirm$ = ""
			editFlag = 1
			if ucase$(#txtusername$) = ucase$(~authUserName$) then 
				disableCtrls(1)
			else 
				disableCtrls(0)
			end if
		elseif  #eguserlist$(intSelRow,intSelCol) = "Delete" then	
			msgbox("Do you really want to delete the user?",3)
			
			if Confirm()=1 then
				retVal = deleteUser(#eguserlist$(intSelRow,0))
				
				if retVal=0 then 
					msgbox("Deleted the user successfully in the camera")
					#eguserlist.deleterow(intSelRow)
					call clearControlValue()
				elseif retVal=-11 then 
					msgbox("Users not able to delete onself")
				else
					msgbox("Could not delete the user in the camera")
				endif	
				
			endif
			
		endif
		
	endif
	
End Sub



/***********************************************************
'** disableCtrls$
 *	Description: Disable/enable user name and authority 
 *				 options based on disableFlag value
 
 *	Params:
 *		dimi disableFlag: Numeric - Holds either 1 or 0
 *	Created by: Vimala On 2010-02-05 15:34:56
 *	History: 
 ***********************************************************/
sub disableCtrls(dimi disableFlag)
	#txtusername.disabled = disableFlag
	#optauthority[0].disabled = disableFlag
	#optauthority[1].disabled = disableFlag
	#optauthority[2].disabled = disableFlag
End Sub

/***********************************************************
'** cmdcancel_Click
 *	Description: call clearControlValue function to clear all control values.
 
 *	Created by: vimala On 2009-03-17 14:31:39
 ***********************************************************/
Sub cmdcancel_Click	
	call clearControlValue()
End Sub

/***********************************************************
'** Form_KeyPress
 *	Description: User name and password will accept only alphanumeric characters.

 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by : vimala On 2009-03-17 14:13:58
	Modified by: Jacques Franklin On 2009-03-25 11:50:00
 ***********************************************************/
Sub Form_KeyPress(Key, FromMouse)
	scroll_keypressed(key)			' Lock mouse scroll
	
	dims keypressed$				'Holds the character of enter key
	keypressed$ = chr$(getkey())

	iff (CheckKey(Key,rule,keypressed$))=1 then keyhandled(2)
			
	setLeftMenuFocus(Key,1)
	
End Sub


'set key press rule for user input controls
Sub txtUserName_Focus
'	msgbox("nihaonihao")
'	rule = 5		
	showcursor(3)		 
End Sub

Sub password_Focus
	rule = 5		
End Sub

Sub pwdconfirm_Focus
	rule = 5		
End Sub

' To set the showcursor property for the controls
Sub optauthority_Focus
	showcursor(1)
End Sub

Sub optauthority_blur
	showcursor(3)
End Sub


sub chkValueMismatch()	
	'Please don't delete
End Sub


Sub txtusername_Change
	' Add Handler Code Here 
End Sub



Sub password_Change
	' Add Handler Code Here 
End Sub



Sub pwdconfirm_Change
	' Add Handler Code Here 
End Sub

