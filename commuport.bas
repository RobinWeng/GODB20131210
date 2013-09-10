

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

#include "commuport.inc"
														

dimi selDeviceNumVal,gIndex,selDeviceNumVal1,selDeviceChannelNumVal1
dims  baudrateArray$(7),databitArray$(4),stopbitArray$(2),channelnumArray$(4),paritycheckArray$(3),streamcontrolArray$(3),applytoArray$(3),devicenumArray$(4),/*add by wbb*/devicenum1Array$(1)

baudrateArray$=("1200","2400","4800","9600","19200","38400","115200")
databitArray$=("7","8")
stopbitArray$=("1","2")
channelnumArray$=("1","2","3","4")
paritycheckArray$=("no parity check","odd parity check","even parity check")
streamcontrolArray$=("no stream control","soft stream control","hard stream control")
applytoArray$=("narrow band transmission","console","alpha channel")		
//devicenumArray$=("1","2","3","4")										
devicenumArray$=("1","2")										
devicenum1Array$=("1")



										
showcursor(3)
~wait = 2 				

end


sub form_load	


	dimi retVal
	dimi channel,port
	channel=0
	port=0
	retVal = loadIniValues()
			
	if ~maxPropIndex = 0 then 
		msgbox("Unable to load initial values.")
		loadurl("!auth.frm")
	endif
	
	call displayControls(LabelName$,XPos,YPos,Wdh,height)	
	
	showSubMenu(0,1)
	setfocus("rosubmenu[2]")
	selectSubMenu()
	
	
	call ShowRs232SettingInfo(channel)	
	call ShowRs485SettingInfo(channel,port)
	
	/*	
	call addItemsToDropDown("ddBaudRate", baudrate$, -1)	'add by hst
	call addItemsToDropDown("ddDataBit", databit$, -1)	'add by hst
	call addItemsToDropDown("ddStopBit", stopbit$, -1)	'add by hst
	call addItemsToDropDown("ddParityCheck", paritycheck$, -1)	'add by hst
	call addItemsToDropDown("ddStreamControl", streamcontrol$, -1)	'add by hst
	call addItemsToDropDown("ddApplyTo", applyto$, -1)	'add by hst
	
	
	call addItemsToDropDown("ddChannelNum1", channelnum$, -1)	'add by hst
	call addItemsToDropDown("ddBaudRate1", baudrate$, -1)	'add by hst
	call addItemsToDropDown("ddDataBit1", databit$, -1)	'add by hst
	call addItemsToDropDown("ddStopBit1", stopbit$, -1)	'add by hst
	call addItemsToDropDown("ddParityCheck1", paritycheck$, -1)	'add by hst
	call addItemsToDropDown("ddStreamControl1", streamcontrol$, -1)	'add by hst
	*/	
	call addItemsToDropDown("ddDeviceNum", devicenumArray$, -1)	
	call addItemsToDropDown("ddDeviceNum1", devicenum1Array$, -1)	//mend by wbb
//	call addItemsToDropDown("ddChannelNum1", channelnumArray$, -1)	//delete by wbb
end Sub


sub ShowRs232SettingInfo( Dimi channel)	
	
	dims baudrate$,databit$,stopbit$, paritycheck$, streamcontrol$, applyto$, devicenum$
	dims baudrate1$,databit1$,stopbit1$, paritycheck1$, streamcontrol1$, channelnum1$,decoderaddr1$, devicenum1$
	dimi retRS232,retRS485,index,retVal,findpos
	
	dims commandtype$,responeData$
	'retRS232=getRS232Details(baudrate$,databit$,stopbit$, paritycheck$, streamcontrol$, applyto$, devicenum$)
/*
	dimi i,retVal
	dims rs232Info$(5),rs232commandtype$(5),controlName$(5)
	rs232Info$=("buadrate","databit","stopbit","paritycheck","streamcontrol")
	rs232commandtype$=("getrs232speed","getrs232databit","getrs232stopbit","getrs232parity","getrs232streamctrl")
	controlName$=("ddBaudRate","ddDataBit","ddStopBit","ddParietyCheck","ddStreamControl")
	for i=0 to 4
		commandtype$=rs232commandtype$(i)
		retVal =  getrs232setinfo(commandtype$,channel,responeData$)
		
		if retVal > 0  then
			findPos = find(responeData$,commandtype$)
			findPos += len(commandtype$)
			rs232Info$(i) = mid$(responeData$,(findPos+1))	
			
			index=flagindex(baudrateArray$,rs232Info$(i))
			if index=-1 then 
				call addItemsToDropDown(controlName(i), baudrateArray$, -1)	'add by hst
			else
				call addItemsToDropDown("ddBaudRate", baudrateArray$, (index+1))	'add by hst
			endif
		
		end if
		
		
	next
	*/
	commandtype$="getrs232speed"
	retVal =  getrs232setinfo(commandtype$,channel,responeData$)

	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		baudrate$ = mid$(responeData$,(findPos+1))	
		
		'gIndex=flagindex(baudrateArray$,baudrate$)
		call flagindex(baudrateArray$,baudrate$)
		
		if gIndex=-1 then 
			call addItemsToDropDown("ddBaudRate", baudrateArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddBaudRate", baudrateArray$, gIndex)	'add by hst
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
			call addItemsToDropDown("ddDataBit", databitArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddDataBit", databitArray$, gIndex)	'add by hst
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
			call addItemsToDropDown("ddStopBit", stopbitArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddStopBit", stopbitArray$, gIndex)	'add by hst
		endif	
		
	end if
	
	
	commandtype$="getrs232parity"
	retVal =  getrs232setinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		paritycheck$ = mid$(responeData$,(findPos+1))	
		
		#ddparitycheck.SelIDX=strtoint(trim$(paritycheck$))

	'	call addItemsToDropDown("ddparitycheck", paritycheckArray$, strtoint(trim$(paritycheck$)))	'add by hst
		/*
		call flagindex(paritycheckArray$,paritycheck$)
		if gIndex=-1 then 
			call addItemsToDropDown("ddparitycheck", paritycheckArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddparitycheck", paritycheckArray$, gIndex)	'add by hst
		endif	
		*/
	end if
	
	
	
	commandtype$="getrs232streamctrl"
	retVal =  getrs232setinfo(commandtype$,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		streamcontrol$ = mid$(responeData$,(findPos+1))	
		
		#ddStreamControl.SelIDX=strtoint(trim$(streamcontrol$))
		
'		call addItemsToDropDown("ddStreamControl", streamcontrolArray$, strtoint(trim$(streamcontrol$)))	'add by hst
	/*
		call flagindex(streamcontrolArray$,streamcontrol$)
		if gIndex=-1 then 
			call addItemsToDropDown("ddStreamControl", streamcontrolArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddStreamControl", streamcontrolArray$, gIndex)	'add by hst
		endif	
		*/
	end if

	
End Sub


sub ShowRs485SettingInfo( Dimi channel,Dimi port)	
	
	dims baudrate$,databit$,stopbit$, paritycheck$, streamcontrol$, applyto$, devicenum$
	dims baudrate1$,databit1$,stopbit1$, paritycheck1$, streamcontrol1$, channelnum1$,decoderaddr1$, devicenum1$
	dimi retRS232,retRS485,index,retVal,findpos
	
	dims commandtype$,responeData$


	commandtype$="getrs485speed"
	retVal =  getrs485setinfo(commandtype$,port,channel,responeData$)

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
	
	
	commandtype$="getrs485databit"
	retVal =  getrs485setinfo(commandtype$,port,channel,responeData$)
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
	
	
	
	commandtype$="getrs485stopbit"
	retVal =  getrs485setinfo(commandtype$,port,channel,responeData$)
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
	
	
	commandtype$="getrs485parity"
	retVal =  getrs485setinfo(commandtype$,port,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		paritycheck$ = mid$(responeData$,(findPos+1))	
		
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
	
	
	
	commandtype$="getrs485streamctrl"
	retVal =  getrs485setinfo(commandtype$,port,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		streamcontrol$ = mid$(responeData$,(findPos+1))	
		
		#ddStreamControl1.SelIDX=strtoint(trim$(streamcontrol$))
'		call addItemsToDropDown("ddStreamControl1", streamcontrolArray$,strtoint( trim$(streamcontrol$)))	'add by hst
		/*
		call flagindex(streamcontrolArray$,streamcontrol$)
		if gIndex=-1 then 
			call addItemsToDropDown("ddStreamControl1", streamcontrolArray$, -1)	'add by hst
		else
			call addItemsToDropDown("ddStreamControl1", streamcontrolArray$, gIndex)	'add by hst
		endif	
		*/
	end if
	
/*	commandtype$="getrs485devaddr"
	retVal =  getrs485setinfo(commandtype$,port,channel,responeData$)
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		streamcontrol$ = mid$(responeData$,(findPos+1))	
	
		#txtdecoderaddr1$=streamcontrol$
	end if
delete by wbb
*/ 
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
	for i = 0 to ubound(ctrlValues$)-1		//mend by wbb
		ctrlValues$(i) = #{LabelName$(i)}
		pprint 		ctrlValues$(i)
	next
	
	
'	call disp_streams
	update							'Added by Vimala
	SETOSVAR("*FLUSHEVENTS", "")	// Added By Rajan
	
'	update	
End Sub

sub savepage()
	msgbox("networksetting.bas")
	Dimi retRS232, retRS485
	dims error$	
	error$ = ""
	//#List2.itemvalue$(i)
	
	retRS232   = setRS232Details(#ddBaudRate.itemlabel$(#ddBaudRate.selidx), #ddDataBit.itemlabel$(#ddDataBit.selidx),#ddStopBit.itemlabel$(#ddStopBit.selidx), #ddParityCheck.selidx,#ddStreamControl.selidx,#ddApplyTo.selidx,#dddevicenum.selidx)		'BFIX-02

	retRS485   = setRS485Details(#ddBaudRate1.itemlabel$(#ddBaudRate1.selidx), #ddDataBit1.itemlabel$(#ddDataBit1.selidx),#ddStopBit1.itemlabel$(#ddStopBit1.selidx), #ddParityCheck1.selidx,#ddStreamControl1.selidx,1/*#txtdecoderaddr1$*/,2/*#dddevicenum1.selidx*/,0/*#ddChannelNum1.selidx*/)		'BFIX-02
/*
	error$ = ~errorKeywords$ 	
	pprint error$
	error$ += ~errorKeywords$ 
	
	if retRS232 >=0 and retRS485 >= 0  then
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
*/	
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



Sub ddDeviceNum_Click
	' Add Handler Code Here
	selDeviceNumVal= #ddDeviceNum.selidx 
End Sub

Sub ddDeviceNum_Change
	' Add Handler Code Here 
	iff selDeviceNumVal = #ddDeviceNum.selidx then return
	'playStreamChannel(selDeviceNumVal,#ddDeviceNum.selidx)
	call ShowRs232SettingInfo(#ddDeviceNum.selidx)
	selDeviceNumVal= #ddDeviceNum.selidx
		
End Sub

/*Sub ddChannelNum1_Click
	selDeviceChannelNumVal1= #ddChannelNum1.selidx 
End Sub

Sub ddChannelNum1_Change
	iff selDeviceChannelNumVal1 = #ddChannelNum1.selidx then return
	call ShowRs485SettingInfo(#ddChannelNum1.selidx,selDeviceNumVal1)
	selDeviceChannelNumVal1= #ddChannelNum1.selidx
		
End Sub
*/



Sub ddDeviceNum1_Click
	selDeviceNumVal1= #ddDeviceNum1.selidx 
End Sub

Sub ddDeviceNum1_Change
	dimi retVal,findPos,i
	dims responeData$,streamcontrol$,commandtype$
	
	commandtype$="getrs485devnum"
	
	iff selDeviceNumVal1 = #ddDeviceNum1.selidx then return
	
	selDeviceNumVal1= #ddDeviceNum1.selidx
	
	retVal=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+selDeviceNumVal1, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeData$)
	
	if retVal > 0  then
		findPos = find(responeData$,commandtype$)
		findPos += len(commandtype$)
		streamcontrol$ = mid$(responeData$,(findPos+1))	
		msgbox(streamcontrol$)
		redim channelnumArray$(strtoint(streamcontrol$))
		for i=0 to (strtoint(streamcontrol$)-1)
			channelnumArray$(i)=(i+1)
		next
	
		#ddChannelNum1.popHeight=strtoint(streamcontrol$)
		call addItemsToDropDown("ddChannelNum1", channelnumArray$, -1)	
		
	end if
	
	
		
End Sub




Sub ddBaudRate_Click
	' Add Handler Code Here 
End Sub

