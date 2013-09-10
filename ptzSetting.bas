
pprint "ptzptz setting"
option(4+1)
showcursor(3) 

#include "defines.inc"
#include "common.inc"
#include "functions.inc"
#include "leftMenu.bas"


dimi noofctrl  								 'Number of Form controls
noofctrl = getfldcount()-LEFTMENUCTRLS
dims LabelName$(noofctrl)					 'Form controls name
dimi XPos(noofctrl)							 'Form controls X position
dimi YPos(noofctrl) 						 'Form controls Y position
dimi Wdh(noofctrl)							 'Form controls Width position
dimi height(noofctrl)		                                         'Form controls height position
 
dims ctrlValues$(noofctrl)                                                        

#include "ptzSetting.inc"
														

dimi selDeviceNumVal,gIndex,selDeviceNumVal1,selDeviceChannelNumVal1
dims  baudrateArray$(7),databitArray$(4),stopbitArray$(2),channelnumArray$(4),paritycheckArray$(3),streamcontrolArray$(3),applytoArray$(3),devicenumArray$(5),dealArray$(1)

baudrateArray$=("1200","2400","4800","9600","19200","38400","115200")
databitArray$=("7","8")
stopbitArray$=("1","2")
channelnumArray$=("1","2","3","4")
paritycheckArray$=("no parity check","odd parity check","even parity check")
streamcontrolArray$=("no stream control","soft stream control","hard stream control")
applytoArray$=("narrow band transmission","console","alpha channel")		
devicenumArray$=("NULL","rs232-0","rs232-1","rs485-0","rs485-1")
dealArray$=("Palco-D")									

										
showcursor(3)
~wait = 2 				

end


sub form_load	


	dimi retVal
	dimi channel,port
	channel=0
//	port=0
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	pprint "form load begin"
	call displayControls(LabelName$,XPos,YPos,Wdh,height)	
	
	showSubMenu(0,1)
	setfocus("rosubmenu[9]")                                                                
	selectSubMenu()
	
	call showPtzSettingInfo(channel)
//	call ShowRs485SettingInfo(channel,port)
//	pprint "ShowRs485SettingInfo end"
		
//	call addItemsToDropDown("ddDeviceNum1", devicenumArray$, -1)	
	call addItemsToDropDown("ddChannelNum1", channelnumArray$, -1)
//	call addItemsToDropDown("ddDeal", dealArray$, -1)	
end Sub


sub ShowPtzSettingInfo( Dimi channel)	
	
	dims baudrate$,databit$,stopbit$, paritycheck$, streamcontrol$, applyto$, devicenum$
	dims baudrate1$,databit1$,stopbit1$, paritycheck1$, streamcontrol1$, channelnum1$,decoderaddr1$, devicenum1$,protocol$
	dimi retRS232,retRS485,index,retVal,findpos
	
	dims commandtype$,responeData$
	
	commandtype$="getptzspeed"
	retVal =  getptzsetinfo(commandtype$,channel,responeData$)

	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		baudrate$ = mid$(responeData$,(findPos+1))	
		pprint "responeData$="+responeData$
		pprint "retVal="+retVal
		pprint "baudrate$="+baudrate$
		'gIndex=flagindex(baudrateArray$,baudrate$)
		call flagindex(baudrateArray$,baudrate$)
		
		if gIndex=-1 then 
			call addItemsToDropDown("ddBaudRate1", baudrateArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddBaudRate1", baudrateArray$, gIndex)	'add by hst
		endif
		
	end if
	
	
	commandtype$="getptzdatabit"
	retVal =  getptzsetinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		databit$ = mid$(responeData$,(findPos+1))	
		pprint "responeData$="+responeData$
		pprint "retVal="+retVal
		pprint "databit$="+databit$
		'gIndex=flagindex(databitArray$,databit$)
		call flagindex(databitArray$,databit$)
		if gIndex=-1 then 
			call addItemsToDropDown("ddDataBit1", databitArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddDataBit1", databitArray$, gIndex)	'add by hst
		endif	
		
	end if
	
	
	
	commandtype$="getptzstopbit"
	retVal =  getptzsetinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		stopbit$ = mid$(responeData$,(findPos+1))
		pprint "responeData$="+responeData$
		pprint "retVal="+retVal	
		pprint "stopbit$="+stopbit$
		'gIndex=flagindex(databitArray$,databit$)
		call flagindex(stopbitArray$,stopbit$)
		if gIndex=-1 then 
			call addItemsToDropDown("ddStopBit1", stopbitArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddStopBit1", stopbitArray$, gIndex)	'add by hst
		endif	
		
	end if
	
	
	commandtype$="getptzparity"
	retVal =  getptzsetinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		paritycheck$ = mid$(responeData$,(findPos+1))	
		pprint "responeData$="+responeData$
		pprint "retVal="+retVal
		pprint "paritycheck="+paritycheck$
		#ddparitycheck1.SelIDX=strtoint(trim$(paritycheck$))
	'	call addItemsToDropDown("ddparitycheck1", paritycheckArray$, strtoint(trim$(paritycheck$)))	'add by hst
		/*
		call flagindex(paritycheckArray$,paritycheck$)
		if gIndex=-1 then 
			call addItemsToDropDown("ddparitycheck1", paritycheckArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddparitycheck1", paritycheckArray$, gIndex)	'add by hst
		endif	
		*/
	end if
	
	
	commandtype$="getptzstreamctrl"
	retVal =  getptzsetinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		streamcontrol$ = mid$(responeData$,(findPos+1))	
		
		pprint "streamcontrol$="+streamcontrol$
		
		#ddStreamControl1.SelIDX=strtoint(trim$(streamcontrol$))

	end if
	
	commandtype$="getptzdevaddr"
	retVal =  getptzsetinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		decoderaddr1$ = mid$(responeData$,(findPos+1))	
		pprint "responeData$="+responeData$
		pprint "retVal="+retVal
		pprint "decoderaddr1$="+decoderaddr1$
		#txtdecoderaddr1$=decoderaddr1$
	end if
	
	commandtype$="getptzport"
	retVal =  getptzsetinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		devicenum1$ = mid$(responeData$,(findPos+1))	
		pprint "responeData$="+responeData$
		pprint "retVal="+retVal
		pprint "devicenum1$="+devicenum1$
		call flagindex(devicenumArray$,devicenum1$)
		pprint "bigin getptzport"
//		#ddDeviceNum1.selidx= strtoint(1)
//		#ddDeviceNum1.SelIDX=strtoint(trim$(devicenum1$))+1
		
		call addItemsToDropDown("ddDeviceNum1", devicenumArray$, (strtoint(trim$(devicenum1$))+1))
		pprint "end getptzport"
	
/*		if gIndex=-1 then 
			call addItemsToDropDown("ddDeviceNum1", devicenumArray$, -1)	'add by hst
			pprint "gIndex=-1"
		else
			call addItemsToDropDown("ddDeviceNum1", devicenumArray$, (gIndex + 1))	'add by hst
			pprint "gIndex="+gIndex
		endif	
*/
	end if
	
	commandtype$="getptzprotocol"
	retVal =  getptzsetinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		protocol$ = mid$(responeData$,(findPos+1))	
		pprint "responeData$="+responeData$
		pprint "retVal="+retVal
		pprint "protocol$="+protocol$
		call flagindex(dealArray$,protocol$)
		if gIndex=-1 then 
			call addItemsToDropDown("ddDeal", dealArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddDeal", dealArray$, gIndex)	'add by hst
		endif	
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
		pprint 		"ctrlValues$(i)="+ctrlValues$(i)
	next
	
	
'	call disp_streams
	update							'Added by Vimala
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
	
'	update	
End Sub

sub savepage()
//	msgbox("networksetting.bas")
//	Dimi retRS232, retRS485
	dimi ptz
	dims error$	
	error$ = ""
	//#List2.itemvalue$(i)
	
	ptz=setPTZDetails(#ddBaudRate1.itemlabel$(#ddBaudRate1.selidx), #ddDataBit1.itemlabel$(#ddDataBit1.selidx),#ddStopBit1.itemlabel$(#ddStopBit1.selidx), #ddParityCheck1.selidx,#ddStreamControl1.selidx,#txtdecoderaddr1$,(#ddDevicenum1.selidx - 1),#ddChannelNum1.selidx)		'BFIX-02

//	if 	#ddDeviceNum1.selidx==0 or #ddDeviceNum1.selidx==1 then 
//		retRS232   = setRS232Details(#ddBaudRate1.itemlabel$(#ddBaudRate1.selidx), #ddDataBit1.itemlabel$(#ddDataBit1.selidx),#ddStopBit1.itemlabel$(#ddStopBit1.selidx), #ddParityCheck1.selidx,#ddStreamControl1.selidx,/*#ddApplyTo.selidx*/0,#dddevicenum1.selidx)		'BFIX-02
//	else
//		retRS485   = setRS485Details(#ddBaudRate1.itemlabel$(#ddBaudRate1.selidx), #ddDataBit1.itemlabel$(#ddDataBit1.selidx),#ddStopBit1.itemlabel$(#ddStopBit1.selidx), #ddParityCheck1.selidx,#ddStreamControl1.selidx,#txtdecoderaddr1$,(#dddevicenum1.selidx -2),#ddChannelNum1.selidx)		'BFIX-02
//	endif
	
End Sub



sub chkValueMismatch()
'	checkForModification(ctrlValues$, LabelName$)	
End Sub



Sub btnSave_Click
	' Add Handler Code Here 
	if canReload = 1 then
		savePage()		
	end if
End Sub


/*
Sub ddDeviceNum_Click
	' Add Handler Code Here
	selDeviceNumVal= #ddDeviceNum.selidx 
End Sub

Sub ddDeviceNum_Change
	' Add Handler Code Here 
	iff selDeviceNumVal = #ddDeviceNum.selidx then return
	'playStreamChannel(selDeviceNumVal,#ddDeviceNum.selidx)
	//call ShowRs232SettingInfo(#ddDeviceNum.selidx)
	selDeviceNumVal= #ddDeviceNum.selidx
		
End Sub
*/

Sub ddChannelNum1_Click
	selDeviceChannelNumVal1= #ddChannelNum1.selidx 
End Sub

Sub ddChannelNum1_Change
	iff selDeviceChannelNumVal1 = #ddChannelNum1.selidx then return
	call ShowPtzSettingInfo(#ddChannelNum1.selidx)
	selDeviceChannelNumVal1= #ddChannelNum1.selidx
		
End Sub

Sub ddDeviceNum1_Click
	selDeviceNumVal1= (#ddDeviceNum1.selidx - 1)
	pprint  "selDeviceNumVal1="+selDeviceNumVal1
End Sub

Sub ddDeviceNum1_Change
	iff selDeviceNumVal1 = (#ddDeviceNum1.selidx - 1) then return
	selDeviceNumVal1= (#ddDeviceNum1.selidx - 1)
		
End Sub
/*
Sub ddDeviceNum1_Change 
	dimi retVal,findPos,i
	dims responeData$,streamcontrol$,commandtype$	
	
	iff selDeviceNumVal1 = #ddDeviceNum1.selidx then return	
	
	if 	#ddDeviceNum1.selidx==0 or #ddDeviceNum1.selidx==1 then
			call ShowRs232SettingInfo(#ddDeviceNum1.selidx)
			pprint "#ddDeviceNum1.selidx="+#ddDeviceNum1.selidx
			selDeviceNumVal1= #ddDeviceNum1.selidx
			pprint  "232selDeviceNumVal1="+selDeviceNumVal1
			#ddchannelnum1.disabled=1
			#txtdecoderaddr1.disabled=1
			#ddDeal.disabled=1
	else 
			#ddChannelNum1.disabled=0
			#txtdecoderaddr1.disabled=0
			#ddDeal.disabled=0
			commandtype$="getrs485devnum"
			selDeviceNumVal1= #ddDeviceNum1.selidx-2	
			pprint  "485selDeviceNumVal1="+selDeviceNumVal1
			retVal=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+selDeviceNumVal1, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeData$)
			
			if retVal > 0  then
				findPos = find(responeData$,commandtype$)
				findPos += len(commandtype$)
				streamcontrol$ = mid$(responeData$,(findPos+1))	
				pprint "responsedata="+responeData$
				pprint "streamcontrol="+streamcontrol$
				
				msgbox(streamcontrol$)
				redim channelnumArray$(strtoint(streamcontrol$))
				for i=0 to (strtoint(streamcontrol$)-1)
					channelnumArray$(i)=(i+1)
				next
			
				#ddChannelNum1.popHeight=strtoint(streamcontrol$)
				call addItemsToDropDown("ddChannelNum1", channelnumArray$, -1)	
				
			end if
			call ShowRs485SettingInfo(0,#ddDeviceNum1.selidx-2)

	endif
	
End Sub
*/



Sub ddBaudRate_Click
	' Add Handler Code Here 
End Sub

/*
sub ShowRs232SettingInfo( Dimi channel)	
	
	dims baudrate$,databit$,stopbit$, paritycheck$, streamcontrol$, applyto$, devicenum$
	dims baudrate1$,databit1$,stopbit1$, paritycheck1$, streamcontrol1$, channelnum1$,decoderaddr1$, devicenum1$
	dimi retRS232,retRS485,index,retVal,findpos
	
	dims commandtype$,responeData$

	commandtype$="getrs232speed"
	retVal =  getrs232setinfo(commandtype$,channel,responeData$)

	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		baudrate$ = mid$(responeData$,(findPos+1))	
		
		'gIndex=flagindex(baudrateArray$,baudrate$)
		call flagindex(baudrateArray$,baudrate$)
		
		if gIndex=-1 then 
			call addItemsToDropDown("ddBaudRate1", baudrateArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddBaudRate1", baudrateArray$, gIndex)	'add by hst
		endif
		
	end if
	
	
	commandtype$="getrs232databit"
	retVal =  getrs232setinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		databit$ = mid$(responeData$,(findPos+1))	
		
		'gIndex=flagindex(databitArray$,databit$)
		call flagindex(databitArray$,databit$)
		if gIndex=-1 then 
			call addItemsToDropDown("ddDataBit1", databitArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddDataBit1", databitArray$, gIndex)	'add by hst
		endif	
		
	end if
	
	
	
	commandtype$="getrs232stopbit"
	retVal =  getrs232setinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		stopbit$ = mid$(responeData$,(findPos+1))	
		
		'gIndex=flagindex(databitArray$,databit$)
		call flagindex(stopbitArray$,stopbit$)
		if gIndex=-1 then 
			call addItemsToDropDown("ddStopBit1", stopbitArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddStopBit1", stopbitArray$, gIndex)	'add by hst
		endif	
		
	end if
	
	
	commandtype$="getrs232parity"
	retVal =  getrs232setinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		paritycheck$ = mid$(responeData$,(findPos+1))	
		
		#ddparitycheck1.SelIDX=strtoint(trim$(paritycheck$))

	'	call addItemsToDropDown("ddparitycheck", paritycheckArray$, strtoint(trim$(paritycheck$)))	'add by hst
	end if
	
	
	
	commandtype$="getrs232streamctrl"
	retVal =  getrs232setinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		streamcontrol$ = mid$(responeData$,(findPos+1))	
		
		#ddstreamcontrol1.SelIDX=strtoint(trim$(streamcontrol$))
		
'		call addItemsToDropDown("ddStreamControl", streamcontrolArray$, strtoint(trim$(streamcontrol$)))	'add by hst

	end if

	
End Sub
*/