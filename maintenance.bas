/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Maintenance Screen                                              *
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
                                                         
#include "maintenance.inc"
~wait = 2
end




/***********************************************************
'** Form_Load
 *	Description: Call displayControls function to algin contorls
 *				 based on the screen resolution.
 *				 Highlight the selected link in left menu.
 *				 Load maintenance(.htm) page from camera

 *	Created by: Vimala On 2009-10-19 14:24:55
 ***********************************************************/
Sub Form_Load
	call displayControls(LabelName$,XPos,YPos,Wdh,height)

	#gdomaintenance.h = #gdomaintenance.h*~factorY 		
	#gdomaintenance.w = #imgmainbg.w - 30
	#lblnote.h = 47 * ~factorY 
		
	assignSelectedImage("imgmenu[4]")		
	setfocus("imgmenu[4]")
	showSubMenu(0,0)
	#cmdback.hidden = 1
	setfocus("lblnote")
	#gdomaintenance.navigate$(~camAddPath$+"\MaintD.htm")				'CR-02
	
End Sub

/***********************************************************
'** cmdBack_Click
 *	Description:  Load maintenance(.htm) page from camera
 *		
 *	Created by: Vimala On 2009-10-21 18:46:25
 *	History: 
 ***********************************************************/
Sub cmdBack_Click	
	#gdomaintenance.navigate$(~camAddPath$+"\MaintD.htm")
	setfocus("imgmenu[3]")
End Sub

/***********************************************************
'** gdomaintenance_BeforeNavigate
*	Description: Shows back button when URL changes

 *	Params:
 *		DimS Page$: String - Navigate URL
 *	Created by:Vimala  On 2009-11-09 10:52:58
 *	History: 
 ***********************************************************/
Sub gdomaintenance_BeforeNavigate2(dims Page$)	
	dimi spltCount
	dims temp$,url$
	pprint "Page$ =" + Page$	
	iff Page$="" then return
	pprint find(Page$,"\MaintD.htm\"")
	if find(Page$,"about:blank")=-1  then
		if find(Page$,"\MaintD.htm\"") >= 0 or find(Page$,"/vb.htm?")>=0 then
			#cmdback.hidden = 1
			#lblnote.hidden = 0
		else 
			#cmdback.hidden = 0
			#lblnote.hidden = 1
		end if
	end if
	update
	
End Sub


sub chkValueMismatch()	
	'Please Do not delete this proc
End Sub

sub savePage()
	'Please Do not delete this proc
End Sub
