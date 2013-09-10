/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : SupportScreen                                              *
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

#define KEY_ESC 15
#define KEY_RETURN  13
#define KEY_UP 23
#define KEY_DOWN 24
#define SCROLL_UP 25
#define SCROLL_DOWN 26


dimi noofctrl  								 'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS
dims LabelName$(noofctrl)					 'Form controls name
dimi XPos(noofctrl)							 'Form controls X position
dimi YPos(noofctrl) 						 'Form controls Y position
dimi Wdh(noofctrl)							 'Form controls Width position
dimi height(noofctrl)	

#include "supportScreen.inc"

dims GUIVersion$                             'GUI Version  'TR-32
GUIVersion$  = "1.0.57"
~wait = 2
end

/***********************************************************
'** Form_Load
 *	Description: 
 *		To align the control's position during the form load
 *		
 *	Params:
 *  Methods: displayControls- to align the X,Y,W,H of the Controls
		   : retieveSupportData- to retrieve the Support Info from the server
		   : assignSelectedImage- to assign the current selected Image to the leftMenu(Support Link)
		   
 *	Created by:  On 2009-10-07 15:56:18
 *	History: 
 ***********************************************************/
Sub Form_Load	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)
	
	#txtalicense.h = #txtalicense.h * ~factorY		
	#txtasupportdocs.h = #txtasupportdocs.h * ~factorY
	#txtacredits.h = #txtacredits.h * ~factorY
	#txtacopyright.h = #txtacopyright.h * ~factorY
	
	call retieveSupportData()
	showcursor(3)
	assignSelectedImage("imgmenu[5]")		
	setfocus("imgmenu[5]")		
	showSubMenu(0,0)
	setfocus("lblabout")
	
End Sub

/***********************************************************
'** retieveSupportData
 *	Description: 
 *		To fetch the Support data from the server and display it 
 *		To DownLoad the License file from thr Server
 *      To DownLoad the SupportInfo file from thr Server
 *      To DownLoad the Credits file from thr Server
 *      To DownLoad the Copyright file from thr Server
 *	Params:
 *  Methods: DownLoadFile(FileName)-To downLoad the file From the server 
		   : getSupportData- To get the Release Version Informations
		     (Kernel, Uboot, Software, activeX and GUI version)
 *	Created by: Franklin Jacques.k On 2009-10-08 12:10:16
 *	History: 
 ***********************************************************/
sub retieveSupportData()
	Dimi ret 
	Dims kernelVersion$, UbootVersion$, SoftwareVersion$
	
	ret = getSupportData(kernelVersion$, UbootVersion$, SoftwareVersion$)
	
	#txtkernelVersion$ = kernelVersion$
	#txtUbootVersion$ = UbootVersion$
	#txtSWversion$ = SoftwareVersion$
	
	#txtActiveXVersion$ = repl$(~videoPlayerVersion$,", ",".")			'TR-32
	#txtGUIVersion$ = GUIVersion$
	#txtCamera$ = ~title$	

	#txtALicense$ = dwnldFile$("license.txt")
	#txtASupportDocs$ = dwnldFile$("supportinfo.txt")
	#txtACredits$ = dwnldFile$("credits.txt")
	#txtACopyright$ = dwnldFile$("copyright.txt")	
	
	//debug by wbb
	#txtkernelVersion$ = "Linux 版本 2.6.18_pro500-davinci_IPNC_DM36x_2.0.0 "
	#txtUbootVersion$ = "(null)"
	#txtSWversion$ = "容智 2.0.0"
	
	#txtALicense$ = "IPNC 软件及相关的设计许可文件"
	#txtASupportDocs$ = "所有的支持文档都在相应的文件目录中"
	#txtACredits$ = "文本介绍信息请访相关网页�  "  
	#txtACopyright$ = "版权归容智所有 "	
	//will be delete later
End Sub


/***********************************************************
'** Form_KeyPress
 *	Description: Validate key press
 
 *	Params:
'*		Key: Numeric - char code of the key pressed
 *		FromMouse : Numeric - char code of the mouse pressed
 *	Created by:  On 2009-10-09 16:45:34
 *	History: 
 ***********************************************************/
Sub Form_KeyPress( Key, FromMouse )
	
	if key<> KEY_RETURN and key<>KEY_DOWN and key<>KEY_UP and key<>SCROLL_UP and key<>SCROLL_DOWN and key<> KEY_ESC then
		keyhandled(2)
	end if
	
	setLeftMenuFocus(Key,-1)	
End Sub

sub savePage()
	'Please Do not delete this proc
End Sub

sub chkValueMismatch()	
	'Please Do not delete this proc
End Sub


