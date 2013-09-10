/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : SD Card Explorer Screen                                              *
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
showcursor(3)
#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"

dimi noofctrl													'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS                          
dims LabelName$(noofctrl)                                       'Form controls name
dimi XPos(noofctrl)                                             'Form controls X position
dimi YPos(noofctrl)                                             'Form controls Y position
dimi Wdh(noofctrl)                                              'Form controls Width position
dimi height(noofctrl)                                           'Form controls height position
                                                         
#include "SDExplorer.inc"

~wait = 2
end

/***********************************************************
'** savePage
 *	Description: 
 *		Dummy procedure do not delete it
 *		
 *	Params:
 *	Created by:  On 2009-10-07 14:45:02
 *	History: 
 ***********************************************************/
sub savePage()
	msgbox("sdexplorer.bas")
	'Do not delete this proc
End Sub




/***********************************************************
'** Form_Load
 *	Description: Call displayControls function to algin contorls
 *				 based on the screen resolution.
 *				 Highlight the selected link in left menu.
 *				 Load SD Card Explorer(.htm) page from camera
 *	Created by: Vimala  On 2009-10-19 14:24:19
 *	History: 
 ***********************************************************/
Sub Form_Load
	call displayControls(LabelName$,XPos,YPos,Wdh,height)	
	
	#gdosdExplorer.h = #cmdback.y - HEADER_HEIGHT - #cmdback.w
	#gdosdExplorer.w = #imgmainbg.w - 30
	pprint ~camAddPath$
	#gdosdExplorer.navigate$(~camAddPath$+"sdget.htm")		'CR-02	
	call checkSDInsertValue()
	#lblupdate.hidden = 1
	#cmdback.hidden = 1
	
	assignSelectedImage("imgmenu[0]")		
	setfocus("imgmenu[0]")
	if ~loginAuthority = ADMIN or ~loginAuthority = OPERATOR then		
		showSubMenu(0,0)		
	endif
	#lblheading$ = "SD Card Explorer"
End Sub



/***********************************************************
'** checkSDInsertValue
 *	Description: Call this function to check SD card is mounted or not
 *  Created by:Vimala  On 2009-11-06 16:36:20
 *	History: 
 ***********************************************************/
Sub checkSDInsertValue()					'TR-22
	dimi sdInsert,retVal,findPos
	dims sdInsertVal$
	
	retVal =  getSDCardValue(sdInsertVal$)
	
	if retVal > 0  then
		findPos = find(sdInsertVal$,"sdinsert=")
		findPos += len("sdinsert=")
		sdInsert = atol(mid$(sdInsertVal$,findPos))		
	end if
	
	if sdInsert = 3 then
		#cmdmount$ = "Unmount"
	elseif sdInsert = 1 then
		#cmdmount$ = "Mount"
	end if
End Sub



/***********************************************************
'** cmdBack_Click
 *	Description: Reload SD Card Explorer(.htm) page from camera
 *	Created by: Vimala  On 2009-10-21 18:45:55
 *	History: 
 ***********************************************************/
Sub cmdBack_Click	
	#gdosdExplorer.navigate$(~camAddPath$+"sdget.htm")
	setfocus("imgmenu[0]")
End Sub


/***********************************************************
'** gdosdExplorer_BeforeNavigate
 *	Description: Shows back button when URL changes
 *	Params:
 *		DimS Page$: String - Navigate URL
 *	Created by:Vimala  On 2009-11-09 10:52:58
 *	History: 
 ***********************************************************/
 Sub gdosdExplorer_BeforeNavigate(DimS Page$)								'TR-22	
	pprint  Page$
	dimi spltCount
	dims temp$,url$
	spltCount = split(temp$,Page$,",")
	
	if spltCount = 6 then
		url$ = repl$(temp$(5),"\"","")
		
		if url$ = ~camAddPath$+"sdget.htm" then
			#cmdback.hidden = 1
		else 
			#cmdback.hidden = 0
		end if
		
	else 
		#cmdback.hidden = 0
	end if
	
	update
	
End Sub


 	


/***********************************************************
'** cmdFormat_Click
 *	Description: Clicking on  format button will format the SD explorer.
 *	Created by: Vimala On 2009-11-06 16:15:31
 *	History: 
 ***********************************************************/
Sub cmdFormat_Click									'TR-22
	#gdosdExplorer.hidden = 1
	#lblupdate.hidden = 0
	update
	
	dimi ret
	dims responseData$,status$
	
	ret = HTTPDNLD(~camAddPath$ + "vb.htm?sdformat=1", "","",2,0,~authHeader$,,,responseData$)
	
	if ret >= 0 then
		status$ = trim$(left$(responseData$,3))
		
		if status$ = "OK" then
			msgbox "SD Card Format Successful"
		else 
			msgbox "SD Card Format Failed"
		end if
	else 
		msgbox "SD Card Format Failed"		
	end if 
	
	#gdosdExplorer.hidden = 0
	#lblupdate.hidden = 1
End Sub



/***********************************************************
'** cmdMount_Click
 *	Description:To Mount/Unmountthe SD card.
 *				This button toggles between Moun/UnMount
 *	Created by: Vimala On 2009-11-06 16:40:33
 *	History: 
 ***********************************************************/
Sub cmdMount_Click
	#gdosdExplorer.hidden = 1
	#lblupdate.hidden = 0
	update
	
	dimi retVal,mountVal
	dims responseData$,status$
	
	if #cmdmount$ = "Unmount"	then	
		mountVal = 1
	elseif #cmdmount$ = "Mount" then
		mountVal = 8
	end if
	
	retVal = HTTPDNLD(~camAddPath$ + "vb.htm?sdunmount="+mountVal, "","",2,0,~authHeader$,,,responseData$)
	
	if retVal >= 0 then
		status$ = trim$(left$(responseData$,3))
		
		if status$ = "OK" then
			msgbox "SD Card "+#cmdmount$+" Successful"
		else 
			msgbox "SD Card "+#cmdmount$+" Failed"
		end if
	else 
		msgbox "SD Card "+#cmdmount$+" Failed"	
	end if 

	#gdosdExplorer.hidden = 0
	#lblupdate.hidden = 1
	#gdosdExplorer.navigate$(~camAddPath$+"sdget.htm")
	call checkSDInsertValue()
End Sub

sub chkValueMismatch()	
End Sub
