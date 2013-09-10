0-pprint "data setting"
option(4+1)
showcursor(3) 

#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"

dimi noofctrl  								 'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS
pprint "getfldcount()="+getfldcount()
pprint "noofctrl="+noofctrl
dims LabelName$(noofctrl)					 'Form controls name
dimi XPos(noofctrl)							 'Form controls X position
dimi YPos(noofctrl) 						 'Form controls Y position
dimi Wdh(noofctrl)							 'Form controls Width position
dimi height(noofctrl)		                                         'Form controls height position
 
dims ctrlValues$(noofctrl)                                                        
pprint "date inc begn"

#include "dataCollection.inc"
pprint "dataCollection endend"														

dimi seluseto,gIndex,seltype,selchannel
dims  devicenumArray$(4),datatypeArrary$(4),channelArray$(8)
dims  baudrateArray$(7),databitArray$(4),stopbitArray$(2),paritycheckArray$(3),streamcontrolArray$(3),dealArray$(1)

devicenumArray$=("rs232-0","rs232-1","rs485-0","rs485-1")										
datatypeArrary$=("2","3","4","6")
channelArray$=("1","2","3","4","5","6","7","8")

baudrateArray$=("1200","2400","4800","9600","19200","38400","115200")
databitArray$=("7","8")
stopbitArray$=("1","2")
paritycheckArray$=("no parity check","odd parity check","even parity check")
streamcontrolArray$=("no stream control","soft stream control","hard stream control")
dealArray$=("MODBUS")
										
showcursor(3)
~wait = 2 				

end


sub form_load	
	dimi retVal
	dimi port
	dimi channel
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	pprint "form load begin"
	call displayControls(LabelName$,XPos,YPos,Wdh,height)	

pprint "-------------------------------------------------------displaycontrols end"


	showSubMenu(0,1)
	setfocus("rosubmenu[10]")
	selectSubMenu()
	
	setfocus("optSelect")
	call optSelect_Click
	setfocus("lbchannel")
//	call lbchannel_click
	pprint "opselect click end"
	port=0
	channel=0
	call ShowSerialSettingInfo(port,channel)
	pprint "ShowSerialSettingInfo end"
	
	call addItemsToDropDown("drpuseto", devicenumArray$, -1)	
	call addItemsToDropDown("drpchannel", channelArray$, -1)
	call addItemsToDropDown("drpprotocol", dealArray$, -1)

end Sub


sub ShowSerialSettingInfo( Dimi port,Dimi channel)	
	
//	dims id$,datatype$,plc$, startadd$, registernum$
	dimi retRS232,retRS485,index,retVal,findPos
	dimi findPosArray(16)
	dims data$(16),datatype$
	dimi i
	dims commandtype$,responeData$
	
	commandtype$="getplcserial"
	retVal =  getplcsetinfo(commandtype$,port,channel,responeData$)
//	retVal=1
//	responeData$="getplc=1@502@60@600@2005@1@oxfff@oxffa@200@4800@7@1@1@1"
pprint responeData$
	if retVal > 0  then	
		findPosArray(0)=find(responeData$,"=")
		for i=1 to 15
			findPos=findPosArray(i-1) +1
			findPosArray(i)=find(responeData$,"@",findPos)
			data$(i-1)=mid$(responeData$,findPos,(findPosArray(i)-findPos))
		next
		data$(15)=mid$(responeData$,findPosArray(15)+1)

		call addItemsToDropDown("drpprotocol", dealArray$, (strtoint(trim$( data$(2) ))) - 1 )
//		call addItemsToDropDown("drptype", datatypeArrary$, (strtoint(trim$( data$(0) ))) )
//		#Textport$=data$(1)
		#Textpoll$=data$(3)
		#Textexpire$=data$(4)
		#lbchannel.checked=strtoint(trim$(data$(5)))
//		call lbchannel_click
		#Textid$=data$(6)
//		call addItemsToDropDown("drptype", datatypeArrary$, (strtoint(trim$(data$(6)))) )

		call flagindex(datatypeArrary$,strtoint(trim$( data$(7) )))
//		call addItemsToDropDown("drptype", datatypeArrary$, gIndex )

		#drptype.SelIDX=strtoint(gIndex)
		#Textplc$=data$(8)
		#Textadd$=data$(10)
		#Textnum$=data$(9)
		call flagindex(baudrateArray$,strtoint(trim$( data$(11) )))
		call addItemsToDropDown("ddBaudRate1", baudrateArray$, gIndex )
//		call addItemsToDropDown("ddBaudRate1", baudrateArray$, (strtoint(trim$( data$(11) ))) )

		call flagindex(databitArray$,strtoint(trim$( data$(12) )))		
		call addItemsToDropDown("ddDataBit1", databitArray$, gIndex )
//		call addItemsToDropDown("ddDataBit1", databitArray$, (strtoint(trim$( data$(12) ))) )
		call flagindex(stopbitArray$,strtoint(trim$( data$(13) )))
		call addItemsToDropDown("ddStopBit1", stopbitArray$, gIndex )
		#ddparitycheck1.SelIDX=strtoint(trim$(data$(14)))
//		call addItemsToDropDown("ddParityCheck1", paritycheckArray$, (strtoint(trim$( data$(13) ))) )
		#ddStreamControl1.SelIDX=strtoint(trim$(data$(15)))
//		call addItemsToDropDown("ddStreamControl1", streamcontrolArray$, (strtoint(trim$( data$(14) ))) )


	end if
end sub

sub flagindex(dims array$(),dims str$)
	
	dimi i
	for i=0 to ubound(array$)
		if trim$(str$) = trim$(array$(i)) then
			gIndex=i
			return 
		endif
	next
	
	gIndex=-1
	
End Sub


sub form_complete
	
	dimi i
	for i = 0 to ubound(ctrlValues$)-1		
		ctrlValues$(i) = #{LabelName$(i)}
		pprint 		"ctrlValues$("+i+")="+ctrlValues$(i)
	next
	
	
'	call disp_streams
	update							'Added by Vimala
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
	
'	update	
End Sub

sub savepage()
//	msgbox("dataCollection.bas")
	Dimi serial
	dimi tcp
	dims error$	
	error$ = ""	
/*	add by wbb*/
	if #optselect.checked==1 then     
		serial = setSerialDetails(#lbchannel.checked, (1+ strtoint(#drpprotocol$)),#textpoll$,#textexpire$,#Textid$,datatypeArrary$(#drptype.selidx),#Textplc$, #Textadd$,#Textnum$,#ddBaudRate1.itemlabel$(#ddBaudRate1.selidx), #ddDataBit1.itemlabel$(#ddDataBit1.selidx),#ddStopBit1.itemlabel$(#ddStopBit1.selidx),#ddparitycheck1.selidx,#ddstreamcontrol1.selidx,#drpuseto.selidx,#drpchannel.selidx)		'BFIX-02
	else
		tcp = setTcpDetails(#lbchannel.checked,#Textid$, datatypeArrary$(#drptype.selidx),#Textplc$, #Textadd$,#Textnum$,#Textip$,#drpchannel.selidx,#Textport,#textpoll$,#textexpire$)		'BFIX-02
	end if
End Sub


sub chkValueMismatch()
'	checkForModification(ctrlValues$, LabelName$)	
End Sub



Sub btnFrameOK_Click
	' Add Handler Code Here 
	if canReload = 1 then
		savePage()		
	end if
End Sub



Sub drpuseto_Click
	seluseto= #drpuseto.selidx 
End Sub

Sub drpuseto_Change
	' Add Handler Code Here 
	iff seluseto == #drpuseto.selidx then return
	seluseto= #drpuseto.selidx 
	if seluseto==0 or seluseto==1 then
		#drpchannel.disabled=1
		
	else #drpchannel.disabled=0
	end if
	call addItemsToDropDown("drpchannel", channelArray$, -1)
/*	
	#Textid$=""
	call addItemsToDropDown("drptype", datatypeArrary$, -1)	
	#Textplc$=""
	#Textadd$=""
	#Textnum$=""
	*/
	call ShowSerialSettingInfo(#drpuseto.selidx,0)
End Sub

Sub drpchannel_Click
	selchannel = #drpchannel.selidx
End Sub

Sub drpchannel_Change
	iff selchannel == #drpchannel.selidx then return
	selchannel=#drpchannel.selidx
	if #optselect.checked==1 then
		call ShowSerialSettingInfo(#drpuseto.selidx,#drpchannel.selidx)
	else
		call ShowTcpSettingInfo(#drpchannel.selidx)
	end if
End Sub



Sub ddrptype_Click
	seltype= #drptype.selidx 
End Sub

Sub drptype_Change
	iff seltype = #drptype.selidx then return
	seltype= #drptype.selidx
		
End Sub

Sub optSelect_Click
	grayOutCtrls1(0,38166,40180,1,10961)	
	grayOutCtrls2(1,UNSELECTED_TXT_COLOR,UNSELECTED_BG_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_BG_COLOR)	
	#optSelectTcp.checked=0
	#drpuseto.disabled = 0
	#Textip.disabled=1

	#Textport.hidden=1
	#lblport.hidden=1
	#lblprotocol.hidden=0
	#drpprotocol.hidden=0
//	#Textport.disabled=1
//	#lblFrame.hidden=0
//	add by wbb
/*
	#Textid.disabled=0
	#drptype.disabled=0
	#Textplc.disabled=0
	#Textadd.disabled=0
	#Textnum.disabled=0
*/	
//	#lbluseto.hidden=0
//	#drpuseto.hidden=0
//	#drpuseto.disabled=0
	#textip.hidden=1
	#textip.disabled=1
//	#textport.hidden=1
//	#textport.disabled=1
	#lblip.hidden=1
//	#lblport.hidden=1
	#lbchannel.checked = 0
//	call lbchannel_Click
	#lblbaudrate1.hidden=0
	#lbldatabit1.hidden=0
	#lblstopbit1.hidden=0
	#lblparitycheck1.hidden=0
	#lblstreamcontrol1.hidden=0
	#ddbaudrate1.hidden=0
	#dddatabit1.hidden=0
	#ddstopbit1.hidden=0
	#ddparitycheck1.hidden=0
	#ddstreamcontrol1.hidden=0
	call addItemsToDropDown("drpuseto", devicenumArray$, -1)	
	call addItemsToDropDown("drpchannel", channelArray$, -1)
	call ShowSerialSettingInfo(#drpuseto.selidx,0)
End Sub

Sub optSelectTcp_Click
	' Add Handler Code Here 
	grayOutCtrls2(0,38166,40180,1,10961)	
	grayOutCtrls1(1,UNSELECTED_TXT_COLOR,UNSELECTED_BG_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_BG_COLOR)	
	#optSelect.checked=0
	#drpuseto.disabled = 1
	#Textip.disabled=0
	#Textport.disabled=0
//	#lblFrame.hidden=0
//	add by wbb
/*
	#Textid.disabled=0
	#drptype.disabled=0
	#Textplc.disabled=0
	#Textadd.disabled=0
	#Textnum.disabled=0
	
*/
//	#lbluseto.hidden=1
//	#drpuseto.hidden=1
//	#drpuseto.disabled=1
	#textip.hidden=0
	#textip.disabled=0
	#textport.hidden=0
	#textport.disabled=0
	#lblip.hidden=0
	#lblport.hidden=0
	#lbchannel.checked = 0
//	lbchannel_Click
	#lblbaudrate1.hidden=1
	#lbldatabit1.hidden=1
	#lblstopbit1.hidden=1
	#lblparitycheck1.hidden=1
	#lblstreamcontrol1.hidden=1
	#ddbaudrate1.hidden=1
	#dddatabit1.hidden=1
	#ddstopbit1.hidden=1
	#ddparitycheck1.hidden=1
	#ddstreamcontrol1.hidden=1
	#lblprotocol.hidden=1
	#drpprotocol.hidden=1
	call addItemsToDropDown("drpchannel", channelArray$, -1)	
	call ShowTcpSettingInfo(0)
End Sub


Sub btncancel_Click
	' Add Handler Code Here 
End Sub


/***********************************************************
'** grayOutCtrls
 *	Description: Call this function to set control fg,bg and border color .
 *				
 *	Params:
'*		disableFlag: Numeric - Holds disable value (0-enable/1 - disable)
'*		fgColor: Numeric - Display Foreground color
'*		bgColor: Numeric - Control Background color
'*		brdrColor: Numeric - Control border color
 *		selBgColor: Numeric -  control selected back ground color
 *	Created by: Vimala On 2009-11-05 19:19:12
 *	History: 
 ***********************************************************/
Sub grayOutCtrls1(disableFlag,fgColor,bgColor,brdrColor,selBgColor)				'TR-19	
	
/*	
	#lblprotocol.fg = fgColor
	#lblprotocol.selfg = fgColor
	#drpprotocol.disabled = disableFlag
	#drpprotocol.fg = brdrColor
	#drpprotocol.selfg = brdrColor	
	#drpprotocol.bg = bgColor	
	#drpprotocol.brdr = bgColor	
	iff disableFlag = 0 then #drpprotocol.brdr = brdrColor	
	#drpprotocol.selbrdr = brdrColor	
	#drpprotocol.selbg = selBgColor	
*/	
	#lbluseto.fg = fgColor
	#lbluseto.selfg = fgColor
	#drpuseto.disabled = disableFlag
	#drpuseto.fg = brdrColor
	#drpuseto.selfg = brdrColor	
	#drpuseto.bg = bgColor	
	#drpuseto.brdr = bgColor	
	iff disableFlag = 0 then #drpuseto.brdr = brdrColor	
	#drpuseto.selbrdr = brdrColor	
	#drpuseto.selbg = selBgColor

	
End Sub

Sub grayOutCtrls2(disableFlag,fgColor,bgColor,brdrColor,selBgColor)				'TR-19		
	#Textip.disabled = disableFlag
	#Textip.fg = brdrColor
	#Textip.selfg = brdrColor	
	#Textip.bg = bgColor	
	#Textip.brdr = bgColor	
	iff disableFlag = 0 then #Textip.brdr = brdrColor	
	#Textip.selbrdr = brdrColor	
	#Textip.selbg = selBgColor


	#lblport.fg = fgColor
	#lblport.selfg = fgColor
	#Textport.disabled = disableFlag
	#Textport.fg = brdrColor
	#Textport.selfg = brdrColor	
	#Textport.bg = bgColor	
	#Textport.brdr = bgColor	
	iff disableFlag = 0 then #Textport.brdr = brdrColor	
	#Textport.selbrdr = brdrColor	
	#Textport.selbg = selBgColor

	
	/*	
	#Textport.disabled = disableFlag
	#Textport.fg = brdrColor
	#Textport.selfg = brdrColor	
	#Textport.bg = bgColor	
	#Textport.brdr = bgColor	
	iff disableFlag = 0 then #Textport.brdr = brdrColor	
	#Textport.selbrdr = brdrColor	
	#Textport.selbg = selBgColor
*/	

End Sub




Sub btnFrameCancel_Click
	' Add Handler Code Here 
End Sub

sub ShowTcpSettingInfo(Dimi channel)
	
	dims id$,datatype$,plc$, startadd$, registernum$,port$,ip$
	dimi retRS232,retRS485,index,retVal,findPos
	dimi findPosArray(11)
	dims commandtype$,responeData$
	dims data$(11)
	dimi i
	
	commandtype$="getplctcp"
	retVal =  gettcpsetinfo(commandtype$,channel,responeData$)
//	retVal=1
//	responeData$="gettcp=192.168.1.173@501@200@8888@10@1@Ox8888@Ox87af@100@502"
pprint responeData$
	if retVal > 0 then  
		findPosArray(0)=find(responeData$,"=")
		pprint "respone begin"
		for i=1 to 10
			findPos=findPosArray(i-1) +1
			findPosArray(i)=find(responeData$,"@",findPos)
			data$(i-1)=mid$(responeData$,findPos,(findPosArray(i)-findPos))
			pprint "data$("+i+"-1)="+data$(i-1)
		next
		data$(10)=mid$(responeData$,findPosArray(10)+1)
		#lbchannel.checked=strtoint(trim$(data$(1)))
//		call lbchannel_click
		#textip$=data$(2)
		#Textport$=data$(3)
		#textpoll$=data$(4)
		#textexpire$=data$(5)
		#Textid$=data$(6)
		call flagindex(datatypeArrary$,strtoint(trim$( data$(7) )))
//		call addItemsToDropDown("drptype", datatypeArrary$, gIndex )	
		#drptype.SelIDX=strtoint(gIndex)	
//		datatype$=data$(6)
//		call addItemsToDropDown("drptype", datatypeArrary$, (strtoint(trim$(datatype$))) )
		#Textplc$=data$(8)
		#Textadd$=data$(10)
		#Textnum$=data$(9)
//		#Textport$=data$(11)

	end if
end sub

/*
Sub lbchannel_Click
	' Add Handler Code Here 
	if #lbchannel.checked = 0 then 
		grayOutCtrls3(1,UNSELECTED_TXT_COLOR,UNSELECTED_BG_COLOR,UNSELECTED_TXT_COLOR,UNSELECTED_BG_COLOR)				
	else 
		grayOutCtrls3(0,38166,40180,1,10961)
	end if
End Sub

Sub grayOutCtrls3(disableFlag,fgColor,bgColor,brdrColor,selBgColor)				'TR-19	
	
	#drpchannel.disabled = disableFlag
	#drpchannel.fg = brdrColor
	#drpchannel.selfg = brdrColor	
	#drpchannel.bg = bgColor	
	#drpchannel.brdr = bgColor	
	iff disableFlag = 0 then #drpchannel.brdr = brdrColor	
	#drpchannel.selbrdr = brdrColor	
	#drpchannel.selbg = selBgColor
	
End Sub
*/

