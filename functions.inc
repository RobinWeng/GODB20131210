/***************************************************************************************\
 * PROJECT NAME          : IPNC          								               *        
 * MODULE NAME           : Function.inc                                                *
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
'All the keywords corresponding label name will be defined in keyword.inc
'to display message for failure keywords
#include "keywords.inc"   


/*
varName$() - String array: Holds Variable names which returns fetched value from camera
propName$() - String array: IPNC keyword prefixed with character "g"	
~iniProperties$()- String array: Holds all the camera keywords required for GUI
~iniPropValues$ - String array: Holds keyword values which is fetched from IPNC
~errorKeywords$ - String : holds all the failure keywords


Common Methods :
 *  chkRetStatusAndUpdate$(dims responseStaus$,dims propName$(),dims propValue$())	
						- Parse the response string to identify the failure keywords
						- if response is not "ok" for any keyword then its a failure keyword
 *  call updateLatestValues(propName$,propValue$)
						- Call this function to update the modified value in ~iniPropValues$ array	
						
*/
  

/***********************************************************
'** getcameraSettingOptions
 *	Description: Get drop down values from camera  *		
 *	Returns 0 for Success; -1 failure

 *	Params:
'*		byref dims whiteBalance$ : String Array - Returns available white balance option values
'*		byref dims exposureCtrl$ : String Array - Returns available exposure control option values
'*		byref dims maxExpTime$ : String Array - Returns available max Exposure Time option values
'*		byref dims maxGain$ : String Array - Returns available max Gain option values
'*		byref dims spatialFilter$ : String Array - Returns available spatial Filter option values
'*		byref dims imgSensor$ : String Array - Returns available imgage Sensor option values
'*		byref dims twoAType$ : String Array - Returns available 2A engine option values
'*		byref dims backlightname$ : String Array - Returns available backlight option values
'*		byref dims twoAMode$ : String Array - Returns available 2A mode option values
'*		byref dims priorityName$ : String Array - Returns available Priority option values

 *	Created by: vimala On 2009-05-08 13:55:29
 ***********************************************************/
function getcameraSettingOptions(byref dims whiteBalance$(), byref dims exposureCtrl$(), _
								 byref dims maxExpTime$(), byref dims maxGain$(), _
								 byref dims spatialFilter$(), byref dims imgSensor$(),_
								 byref dims twoAType$(), byref dims backlightname$(), _
								 byref dims twoAMode$(), byref dims priorityName$())		'TR-18, TR-34

	dims varName$(10)  = ("whiteBalance$","exposureCtrl$","maxExpTime$","maxGain$", _
						 "spatialFilter$","imgSensor$","twoAType$","backlightname$","twoAMode$","priorityName$")
	
	dims propName$(10) = ("gawbname","gexposurename","gmaxexposuretimename","gmaxgainname", _
						 "gnfltctrlname","gbinningname","gimg2aname","gbacklightname","gimg2atypename","gpriorityname")
	dims tempVal$(10)
	dimi idx, splitidx, retVal,sptCount	
	dims optionValue$, splitChar$
	
	retVal = getIniValues(propName$, tempVal$)
	
	if retVal = 0 then
		
		for idx= 0 to ubound(tempVal$)
			
			splitChar$ = ";"
			sptCount = split(optionValue$, tempVal$(idx), splitChar$)
			iff sptCount>0 then redim {varName$(idx)}(sptCount)
			
			for splitidx = 0 to sptCount-1
				{varName$(idx)}(splitidx) = optionValue$(splitidx)
			next
			
		next
		
	endif
	
	return retVal
	
End Function

/***********************************************************
'** getTitle$
 *	Description: call this function to get camera name.
 
 *	Created by: Vimala On 2009-03-10 12:42:41
 ***********************************************************/
function getTitle$()	
	dims varName$(1)  = ("title$")
	dims propName$(1) = ("gtitle")
	dims tempVal$(1)	
	dimi retVal
	
	retVal = getIniValues(propName$, tempVal$)
	
	 
	
	if retVal = 0 then
		getTitle$ = tempVal$(0)
	endif
	getTitle$= "MFIIDT" //debug by wbb
	return retVal
	
End Function

/***********************************************************
'** getCameraSettings
 *	Description: 
 *		Provides the current mode setting values in the camera
 *	Returns 0 for Success; -1 failure	
 *  SRS Reference: Software Requirements> Modules> Settings> Camera Settings
 *	Params:
'*		byref dimi brightness : Numeric- Holds brightness Value
'*		byref dimi contrast : Numeric- Holds contrast Value
'*		byref dimi saturation : Numeric- Holds saturation Value
'*		byref dimi sharpness : Numeric- Holds sharpness Value
'*		byref dimi blc : Numeric- Holds Back light compensation Value
'*		byref dimi lbce : Numeric- Holds Dynamic Range Enhancement Value
'*		byref dimi whiteBal : Numeric- Holds White balance Value
'*		byref dimi mode : Numeric- Holds mode Value
'*		byref dimi expCtrl : Numeric- Holds flicker control Value
'*		byref dimi maxExposureTime : Numeric- Holds max Exposure Time Value
'*		byref dimi maxExposureGain : Numeric- Holds max Gain Value
'*		byref dimi spatialfilter : Numeric- Holds spatial filter Value
'*		byref dimi temporalfilter : Numeric- Holds temporal filter Value
'*		byref dimi videostable : Numeric- Holds video stabilization Value
'*		byref dimi lensDistCorr : Numeric- Holds lens Distortion Correction Value
'*		byref dimi imageSensor : Numeric- Holds image Sensor Value
'*		byref dimi TwoAEngine : Numeric- Holds 2A Type Value
'*  	byref dimi backlight : Numeric- Holds back light Value
'*		byref dimi histogram : Numeric- Holds histogram Value
'*		byref dimi TwoAMode : Numeric- Holds 2A Mode Value
'*		byref dimi priority : Numeric- Holds priority Value
 *	Created by: vimala On 2009-05-08 14:31:25
 *	History: 
 ***********************************************************/
function getCameraSettings(byref dimi brightness, byref dimi contrast, _
						   byref dimi saturation, byref dimi sharpness, _
						   byref dimi blc,  byref dimi lbce, byref dimi whiteBal, _
						   byref dimi mode, byref dimi expCtrl, _
						   byref dimi maxExpTime, byref dimi maxGain, _
						   byref dimi spatialfilter, byref dimi temporalfilter, _
						   byref dimi videostable, byref dimi lensDistCorr, _
						   byref dimi imageSensor, byref dimi TwoAType, _
						   byref dimi backlight, byref dimi histogram, byref dimi TwoAMode,byref dimi priority) 						'TR-12,TR-18, TR-34
	
					
	dims varName$(21)  = ("brightness","contrast","saturation","sharpness", _
						  "blc","lbce","whiteBal","mode","expCtrl", _
						  "maxExpTime","maxGain", _
						  "spatialfilter","temporalfilter", _
						  "videostable","lensDistCorr","imageSensor","TwoAType","backlight","histogram", "TwoAMode","priority") 

						  
	dims propName$(21) = ("gbrightness","gcontrast","gsaturation","gsharpness", _
						  "gblc","glbce","gawb","gcolorkiller","gexposurectrl", _
						  "gmaxexposuretime","gmaxgain", _
						  "gnfltctrl","gtnfltctrl", _
						  "gvidstb1","glensdistortcorrection","gbinning","gimg2a","gbacklight","ghistogram", "gimg2atype","gpriority")
		
	dims tempVal$(21)
	dimi i,retVal
	
	retVal = getiniValues(propName$,tempVal$)	
	
	if retVal = 0 then
			
		for i= 0 to ubound(tempVal$)	
			{varName$(i)} = strtoint(tempVal$(i))				
		next
		
	endif
	
	return retVal										
	
End Function



/***********************************************************
'** setCameraSettings
 *	Description: 
 *	Sets the Mode Setting values in the camera.
 *	Returns 0 for Success; -1 failure	
 *	SRS Reference: Software Requirements> Modules> Settings> Mode Setting 
 *	Params:
'*		dimi brightness : Numeric- Holds brightness Value
'*		dimi contrast : Numeric- Holds contrast Value
'*		dimi saturation : Numeric- Holds saturation Value
'*		dimi sharpness : Numeric- Holds sharpness Value
'*		dimi blc : Numeric- Holds Back light compensation Value
'*		dimi lbce : Numeric- Holds Dynamic Range Enhancement Value
'*		dimi whiteBal : Numeric- Holds White balance Value
'*		dimi mode : Numeric- Holds mode Value
'*		dimi expCtrl : Numeric- Holds flicker control Value
'*		dimi maxExposureTime : Numeric- Holds max Exposure Time Value
'*		dimi maxExposureGain : Numeric- Holds max Gain Value
'*		dimi spatialfilter : Numeric- Holds spatial filter Value
'*		dimi temporalfilter : Numeric- Holds temporal filter Value
'*		dimi videostable : Numeric- Holds video stabilization Value
'*		dimi lensDistCorr : Numeric- Holds lens Distortion Correction Value
'*		dimi imageSensor : Numeric- Holds image Sensor Value
'*		dimi TwoAEngine : Numeric- Holds 2A Type Value
'*  	dimi backlight : Numeric- Holds back light Value
'*		dimi histogram : Numeric- Holds histogram Value
'*		dimi TwoAMode : Numeric- Holds 2A Mode Value
'*		dimi priority : Numeric- Holds priority Value
 *	Created by: vimala On 2009-05-08 14:57:28
 *	History: 
 ***********************************************************/
function setCameraSettings(dimi brightness, dimi contrast, _
						   dimi saturation, dimi sharpness, _
						   dimi blc, dimi lbce, dimi whiteBal, _
						   dimi mode, dimi expCtrl, _
						   dimi maxExpTime, dimi maxGain, _
						   dimi spatialfilter,dimi temporalfilter, _
						   dimi videostable, dimi lensDistCorr, _
						   dimi imageSensor, dimi TwoAType,dimi backlight,_
						   dimi histogram,dimi twoAMode,dimi priority)  						'TR-12,TR-18
	dimi ret
	dims value$
	dims responseData$
	
	value$ = "brightness="+brightness+"&contrast="+contrast+"&saturation="+saturation+"&sharpness="+sharpness+_
			 "&blc="+blc+"&lbce="+lbce+"&awb="+whiteBal+"&colorkiller="+mode+"&exposurectrl="+expCtrl+_
			 "&maxexposuretime="+maxExpTime+"&maxgain="+maxGain+_
			 "&nfltctrl="+spatialfilter+"&tnfltctrl="+temporalfilter+"&vidstb1="+videostable+_
			 "&lensdistortcorrection="+lensDistCorr+"&binning="+imageSensor+"&img2a="+TwoAType+"&backlight="+backlight+_
			 "&histogram="+histogram+"&img2atype="+twoAMode+"&priority="+priority
	
	
	ret = setProperties(value$, responseData$)

	if ret > 0 then		
		
		dims propName$(21) = ("gbrightness","gcontrast","gsaturation","gsharpness", _
						      "gblc","glbce","gawb","gcolorkiller","gexposurectrl", _
							  "gmaxexposuretime","gmaxgain", _
							  "gnfltctrl","gtnfltctrl", _
							  "gvidstb1","glensdistortcorrection","gbinning",_
							  "gimg2a","gbacklight","ghistogram","gimg2atype","gpriority") 						'TR-12
		 
		dims propVal$(21)
		dims retVal$		
		
		propVal$(0) = brightness
		propVal$(1) = contrast
		propVal$(2) = saturation
		propVal$(3) = sharpness
		propVal$(4) = blc
		propVal$(5) = lbce
		propVal$(6) = whiteBal
		propVal$(7) = mode
		propVal$(8) = expCtrl
		propVal$(9) = maxExpTime
		propVal$(10) = maxGain
		propVal$(11) = spatialfilter
		propVal$(12) = temporalfilter
		propVal$(13) = videostable
		propVal$(14) = lensDistCorr
		propVal$(15) = imageSensor
		propVal$(16) = TwoAType 
		propVal$(17) = backlight 
		propVal$(18) = histogram 
		propVal$(19) = twoAMode 
		propVal$(20) = priority 
		
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif			
				
	endif 
	
	return ret				

End Function


/***********************************************************
'** chkRetStatusAndUpdate$
 *	Description: Check all the properties send to camera are saved or not by parsing response data.
 *		
 *		
 *	Params:
'*		dims responseStaus$: String - Response String
 *		dims propName$(): String array - All the set Keywords
 *		dims propValue$(): String array - value for each keyword , -1 for failure keywords 
 *	Created by:Vimala  On 2010-05-03 18:45:45
 *	History: 
 ***********************************************************/
Function chkRetStatusAndUpdate$(dims responseStaus$,dims propName$(),dims propValue$())	
	
	dimi retVal,splCount,idx,propidx,retLength,propLength, maxProp
	dims retStatus$,failedKeywords$,retVal$
	dims keyword$
	dimi findPos,nextPos
	dims actualStr$
	dimi sptNo
	dims outputStr$(2)
	dims keywordTemp$,propKey$	
	splCount = split(retStatus$,responseStaus$,"\n")					'get properties by response data
	maxProp = ubound(propName$)
	
	for idx = 0 to splCount-1
		
		retLength  = len(retStatus$(idx))
		retVal$    = trim$(right$(retStatus$(idx),retLength-3))			'get properties
				
		if retVal$ <> "" then
			for propidx = 0 to maxProp 
			
				propLength = len(propName$(propidx))				
				propKey$ = 	trim$(right$(propName$(propidx),propLength-1))	
				'Is response property is same as saved property
				if retVal$ = propKey$ then					
					'Is response is not OK, dont save the value
					if left$(retStatus$(idx),2) <> "OK" then	
						propValue$(propidx) = "-1"
						if ~keywordDetFlag = 1 then
							keyword$ = propKey$
							findPos = find(cameraKeywords$,keyword$)
			
							if findPos >= 0 then
								nextPos = find(cameraKeywords$,",",findPos)
								actualStr$ = mid$(cameraKeywords$,findPos,(nextPos-findPos))
								sptNo = split(outputStr$,actualStr$,"|")
																
								if sptNo = 2 then
									keywordTemp$ = outputStr$(1)
								else 
									keywordTemp$ = outputStr$(0)
								end if
								
							end if	
							failedKeywords$ = failedKeywords$ + keywordTemp$ +","
							iff (propidx%5) = 0 then failedKeywords$ += "\n"	
						else 
							failedKeywords$ = failedKeywords$ + right$(propName$(propidx),propLength-1)+","
						end if						
					endif
					break
					
				endif
				
			next
			
		endif
			
	next
		
	call updateLatestValues(propName$,propValue$)
	failedKeywords$ = left$(failedKeywords$,(len(failedKeywords$)-1))	
	chkRetStatusAndUpdate$ = failedKeywords$

End Function


/***********************************************************
'** getVideoAnalyticsSettings
 *	Description: 
 *		Gets video analytic screen value from  camera. 
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dimi facedetect : Numeric - Holds facedetect Value
'*		byref dimi regionX : Numeric - Holds regionX Value 
'*		byref dimi regionY : Numeric - Holds regionY Value
'*		byref dimi regionW : Numeric - Holds regionW Value
'*		byref dimi regionH : Numeric - Holds regionH Value 
'*		byref dimi confLevel : Numeric - Holds Face detect confidence level Value
'*		byref dimi direction : Numeric - Holds direction Value
'*		byref dimi faceRecog : Numeric - Holds face Recognition Value
'*		byref dimi frLevel : Numeric - Holds face Recognition confidence level Value
'*		byref dimi database : Numeric - Holds database Value
'*		byref dimi privacyMask : Numeric - Holds privacyMask Value
'*		byref dimi maskOptions : Numeric - Holds maskOptions Value  

 *	Created by: vimala On 2009-08-25 16:43:30
 ***********************************************************/
function getVideoAnalyticsSettings(byref dimi facedetect, byref dimi regionX, byref dimi regionY, _
								   byref dimi regionW, byref dimi regionH, _
								   byref dimi confLevel,byref dimi direction, _
								   byref dimi faceRecog, byref dimi frLevel, byref dimi database, _
								   byref dimi privacyMask, byref dimi maskOptions)
			
	dims varName$(12)  = ("facedetect","regionX","regionY",_
						  "regionW","regionH", _
						  "confLevel","direction",_
						  "faceRecog","frLevel","database", _
						  "privacyMask","maskOptions")
	dims propName$(12) = ("gfdetect","gfdx","gfdy",_
						  "gfdw","gfdh", _
						  "gfdconflevel","gfddirection",_
						  "gfrecognition","gfrconflevel","gfrdatabase", _
						  "gprivacymask","gmaskoptions")
	
	dims tempVal$(12)
	dimi idx,retVal
	
	retVal = getiniValues(propName$,tempVal$)	
	
	if 	retVal = 0 then
		
		for idx = 0 to ubound(tempVal$)				
						
			{varName$(idx)} = strtoint(tempVal$(idx))				
			
		next	
		
	endif
	
	return retVal			
	
End Function

/***********************************************************
'** setVideoAnalyticsSettings
 *	Description: call this function to set user input values of video analytic screen to camera
  
 *	Returns 0 for Success; -1 failure	
 
 *	Params:
'*		dimi facedetect : Numeric - Holds facedetect Value
'*		dimi regionX : Numeric - Holds regionX Value 
'*		dimi regionY : Numeric - Holds regionY Value
'*		dimi regionW : Numeric - Holds regionW Value
'*		dimi regionH : Numeric - Holds regionH Value 
'*		dimi confLevel : Numeric - Holds Face detect confidence level Value
'*		dimi direction : Numeric - Holds direction Value
'*		dimi faceRecog : Numeric - Holds face Recognition Value
'*		dimi frLevel : Numeric - Holds face Recognition confidence level Value
'*		dimi database : Numeric - Holds database Value
'*		dimi privacyMask : Numeric - Holds privacyMask Value
'*		dimi maskOptions : Numeric - Holds maskOptions Value   
            
 *	Created by: vimala On 2009-08-25 11:54:14
 ***********************************************************/
function setVideoAnalyticsSettings(dimi facedetect, dimi regionX,  dimi regionY,  _
								   dimi regionW,  dimi regionH, _
								   dimi confLevel, dimi direction, _
								   dimi faceRecog,  dimi frLevel, dimi database, _
								   dimi privacyMask,  dimi maskOptions)
	dimi ret
	dims value$
	dims responseData$
	'set string			 
	value$ = "fdetect="+facedetect+"&fdx="+regionX+"&fdy="+regionY+_
			 "&fdw="+regionW+"&fdh="+regionH+_
			 "&fdconflevel="+confLevel+"&fddirection="+direction+_
			 "&frecognition="+faceRecog+"&frconflevel="+frLevel+"&frdatabase="+database+_
			 "&privacymask="+privacyMask+"&maskoptions="+maskOptions
		 
	ret = setProperties(value$, responseData$)	
	
	if ret > 0 then
		
		dims propName$(12) = ("gfdetect","gfdx","gfdy",_
							  "gfdw","gfdh", _
							  "gfdconflevel","gfddirection",_
							  "gfrecognition","gfrconflevel","gfrdatabase", _
							  "gprivacymask","gmaskoptions")
		dims propVal$(12)
		
		propVal$(0) = facedetect
		propVal$(1) = regionX
		propVal$(2) = regionY
		propVal$(3) = regionW
		propVal$(4) = regionH
		propVal$(5) = confLevel
		propVal$(6) = direction
		propVal$(7) = faceRecog
		propVal$(8) = frLevel
		propVal$(9) = database
		propVal$(10) = privacyMask
		propVal$(11) = maskOptions
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret				
						
		
End Function


/***********************************************************
'** getVideoAnalyticsOptions
 *	Description: 
 *		Get video analytic drop down option values from camera *
 *	Returns 0 for Success; -1 failure	
 
 *	Params: 
 *		byref dims direction$(): String array - Hold the available options of direction
 *		byref dims maskOptionsName$(): String array - Hold the available options of mask Options 
 *		byref dims frecognitionName$(): String array - Hold the available options of face recognition 
 *	Created by: vimala On 2009-08-25 11:54:14
 *	History: 
 ***********************************************************/
function getVideoAnalyticsOptions(byref dims direction$(), byref dims maskOptionsName$(), byref dims frecognitionName$())
	
	dims varName$(3)  = ("direction$","maskOptionsName$","frecognitionName$")
	dims propName$(3) = ("gfddirectionname","gmaskoptionsname","gfrecognitionname")				'TR-25 
	dims tempVal$(3)
	dimi idx, splitidx, retVal,sptCount
	dims optionValue$, splitChar$
	
	retVal = getIniValues(propName$, tempVal$)
	
	if retVal = 0 then
		'Split the value and assign to an array
		for idx = 0 to ubound(tempVal$)
			
			splitChar$ = ";"
			sptCount = split(optionValue$, tempVal$(idx), splitChar$)
			iff sptCount > 0 then redim {varName$(idx)}(sptCount)
			
			for splitidx = 0 to sptCount-1
				{varName$(idx)}(splitidx) = optionValue$(splitidx)
			next
			
		next
		
	endif
	
	return retVal
		
End Function


/***********************************************************
'** getNetworkDetails
 *	Description: 
 *		Provides the Network values for Network settings
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dims ip: Numeric - IP Address
'*		byref dims netmask: Numeric - Netmask
'*		byref dims defaultGWay: Numeric - Default Gateway
'*		byref dims priNameServer: Numeric - Primary Name server
 *		byref dimi httpPort: Numeric - Http port
 *	Created by: Franklin Jacques On 2009-02-27 12:24:47
 ***********************************************************/
function getNetworkDetails(byref dims ip$, byref dims netmask$, byref dims defaultGWay$, _
						   byref dims priNameServer$, byref dimi httpPort, byref dimi dhcpenable)
	dimi ret				
	dims varName$(6)  = ("ip$", "netmask$", "defaultGWay$", "priNameServer$", "httpPort", "dhcpenable")
	dims propName$(6) = ("gnetip", "gnetmask", "ggateway", "gdnsip", "ghttpport", "gdhcpenable")
	
	dims tempVal$(6)
	dimi i
	ret=getiniValues(propName$,tempVal$)
	if ret>=0 then
		for i= 0 to 5
			if i=4 or i=5 then
				{varName$(i)} = strtoint(tempVal$(i))			
			else
				{varName$(i)} = tempVal$(i)				
			endif
		next			
	endif
	return ret
End Function


/***********************************************************
'** setNetworkDetails
 *	Description: Sets the Network details for Network setting
 *	Returns 0 for Success; -1 failure	
  
 *	Params:
'*   	dims ip$ : String  - Holds ip address value
'*  	dims netmask$ : String - Holds netmask value
'*   	dims defaultGWay$ : Numeric - Holds default gateway value 
'*  	dims priNameServer$ : String - Holds primary name server value
'*  	dimi httpPort : Numeric - Holds http Port value
'*   	dimi dhcpenable : Numeric - Holds dhcp enable value
 *	Created by: Franklin Jacques On 2009-02-27 12:27:58
 ***********************************************************/
function setNetworkDetails(dims ip$, dims netmask$, dims defaultGWay$, _
						   dims priNameServer$,dimi dhcpenable)				'BFIX-02
	dims NWdetails$
	dims responsedata$
	dimi ret
	'DHCP is enabled then no need to set network setting values
	if dhcpenable=1 then
		NWdetails$=""				
	else
		NWdetails$="netip="+ip$+"&netmask="+netmask$+"&gateway="+defaultGWay$+"&dnsip="+priNameServer$+""						
		ret = setProperties(NWdetails$, responseData$)	
	end if
	
	if ret >= 0 then
		
		dims propName$(4) = ("gnetip", "gnetmask", "ggateway", "gdnsip")
							  
		dims propVal$(4)
		propVal$(0) = ip$
		propVal$(1) = netmask$
		propVal$(2) = defaultGWay$
		propVal$(3) = priNameServer$
		
			
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret				
	
End Function


/***********************************************************
'** getFTPDetails
 *	Description: 
 *		Get the FTP details for Network setting 
 *	Returns 0 for Success; -1 failure	
	
 *	Params:
'*		byref dims ftpServer$: String - Holds ftp Server value
'*		byref dims username$: String - Holds username value
'*		byref dims pwd$: String - Holds password value
'*		byref dims fileUpldpath$: String - Holds file upload path value
 *		byref dimi ftpport: Numeric - Holds ftp port value
: Numeric - 
 *	Created by: Franklin Jacques On 2009-02-27 12:32:03
 *	History: 
 ***********************************************************/
function getFTPDetails(byref dims ftpServer$, byref dims username$, _
					byref dims pwd$, byref dims fileUpldpath$, byref dimi ftpport)
	dimi ret				
	dims varName$(5)  = ("ftpServer$", "username$", "pwd$", "fileUpldpath$", "ftpport")
	dims propName$(5) = ("gftpip", "gftpuser", "gftppassword","gftppath", "gftpipport")
	dims tempVal$(5)
	dimi i
	ret=getiniValues(propName$,tempVal$)	
	if ret>=0 then
		for i= 0 to 4
			if i=4 then
				{varName$(i)} = strtoint(tempVal$(i))				
			else 
				{varName$(i)} = tempVal$(i)				
			endif
		next			
	endif
	return ret 	
End Function


/***********************************************************
'** setFTPDetails
 *	Description: 
 *		Sets the FTP details for Network setting
 *	Returns 0 for Success; -1 failure	
	
 *	Params:
'*		dims ftpServer: Numeric - IP address of FTP server
'*		dims username: Numeric - User name
'*		dims pwd: Numeric - Password
 *		dims fileUpldpath: Numeric - File Upload Path
 *	Created by: Franklin Jacques On 2009-02-27 12:39:27
 ***********************************************************/
function setFTPDetails(dims ftpServer$, dims username$, dims pwd$, dims fileUpldpath$, dimi ftpport)
	
	Dims FTPdetails$
	dims responsedata$
	dimi ret
	FTPdetails$="ftpip="+ftpServer$+"&ftpuser="+username$+"&ftppassword="+pwd$+"&ftppath="+fileUpldpath$+"&ftpipport="+ftpport+""

	ret = setProperties(FTPdetails$, responseData$)	
	
	if ret >= 0 then
		
		dims propName$(5) =  ("gftpip", "gftpuser", "gftppassword","gftppath", "gftpipport")
							  
		dims propVal$(5)
		propVal$(0) = ftpServer$
		propVal$(1) = username$
		propVal$(2) = pwd$
		propVal$(3) = fileUpldpath$
		propVal$(4) = ftpport
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret
End Function


/***********************************************************
'** getSMTPDetails
 *	Description: Get the SMTP details for Network setting 
 *	Returns 0 for Success; -1 failure	
 
 *	Params:
'*		byref dims accName$: String - Account Name
'*		byref dims pwd$: String - Password
'*		byref dims sender$: String - Sender email id
'*		byref dims smtpServer$: String - SMTP Server
'*		byref dims emailid$: String - Email ID
 *		byref dimi requiresAuth$: String - My server requires authentication
 *	Created by: Franklin Jacques On 2009-02-27 14:55:22
 ***********************************************************/
function getSMTPDetails(byref dims accName$, byref dims pwd$, byref dims sender$, _
						byref dims smtpServer$, byref dims emailid$, byref dimi requiresAuth)
    dimi ret
	dims varName$(6)  = ("accName$", "pwd$", "sender$", "smtpServer$", "emailid$","requiresAuth")
	dims propName$(6) = ("gsmtpuser", "gsmtppwd", "gsmtpsender","gsmtpip", "gemailuser","gsmtpauth")
	dims tempVal$(6)
	dimi i
	ret=getiniValues(propName$,tempVal$)
	if ret>=0 then		
		for i= 0 to 5
			
			if i=5 then
				{varName$(i)} = strtoint(tempVal$(i))				
			else 
				{varName$(i)} = tempVal$(i)			
			endif
		next
	endif
	return ret 
End Function


/***********************************************************
'** getSNTPDetails
 *	Description: Get the SNTP details for Network setting
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dims sntpServer$: String - SNTP server
'*		byref dimi multiCast: Numeric - MultiCast Value
 *	Created by: Franklin Jacques On 2009-02-27 15:27:40
 ***********************************************************/
function getSNTPRTSPDetails(byref dims sntpServer$,byref dimi multiCast)
	
	dims varName$(2)  = ("sntpServer$","multiCast")
	dims propName$(2) = ("gsntpip","gmulticast")
	dims tempVal$(2)
	dimi i,ret
	ret=getiniValues(propName$,tempVal$)
		
	if ret>=0 then
		for i= 0 to ubound(tempVal$)
			if i=1 then
				{varName$(i)} = strtoint(tempVal$(i))			
			else 
				{varName$(i)} = tempVal$(i)				
			endif
			
		next
	endif
	return ret 
	
End Function


/***********************************************************
'** setSNTPRTSPDetails
 *	Description: call this function to set sntp Server and multi Cast values to IPNC
 	
 *	Params:
'*		dims sntpServer$: String - Holds SNTP server name 
 *		dimi multiCast: Numeric - Holds MultiCast Value 
 *	Created by: Vimala On 2009-11-06 10:49:28
  ***********************************************************/
function setSNTPRTSPDetails(dims sntpServer$,dimi multiCast)
	dimi ret
	dims SNTPRTSPDetails$
	dims responseData$
	
	SNTPRTSPDetails$="sntpip="+sntpServer$+"&multicast="+multiCast	
					
	ret = setProperties(SNTPRTSPDetails$, responseData$)
	
	if ret >= 0 then
	
		dims propName$(2) = ("gsntpip","gmulticast")

		dims propVal$(2)
		propVal$(0) = sntpServer$
		propVal$(1) = multiCast		
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret			
	
End Function

/***********************************************************
'** getPORTDetails
 *	Description: To get the port details (https/http)
 
 *	Params:
'*		httpsport: Numeric - get the value for https port 
'*		portinput: Numeric - get the value for port input-on/off
'*		portoutput: Numeric - get the value for port output-on/off
'*		rs485: Numeric - get the value for rs485-on/off
'*		portinoutname$: String - get the label for port input-on/off
 *		rs485name$: String - get the label for rs485-on/off
 *	Created by: Franklin Jacques  On 2009-05-08 14:36:53
 *	History: 
 ***********************************************************/
function getPORTDetails(byref dimi httpsport,byref dimi portinput,byref dimi portoutput,_
						byref dimi rs485,byref dims portinputname$,byref dims portoutputname$,byref dims rs485name$)
	
		dims varName$(7)  = ("httpsport", "portinput", "portoutput", "rs485", "portinputname$","portoutputname$", "rs485name$")
		dims propName$(7) = ("ghttpsport", "gportinput", "gportoutput", "grs485", "gportinputname", "gportoutputname", "grs485name")
		dims tempVal$(7)
		dimi i,ret
		
		ret=getiniValues(propName$,tempVal$)
		if ret>=0 then
			for i= 0 to ubound(tempVal$)
				if i=4 or i=5 or i=6 then
					{varName$(i)} = tempVal$(i)					
				else 
					{varName$(i)} = strtoint(tempVal$(i))					
				endif
			next
		endif
		
		return ret 
		
End Function


/***********************************************************
'** setPORTDetails
 *	Description: To set the port details (https/http)
 	
 *	Params:
'*		dimi httpport: Numeric - get the value for http port
'*		dimi httpsport: Numeric - get the value for https port
'*		dimi portinput: Numeric - get the value for port input
'*		dimi portoutput: Numeric -  get the value for port output
 *		dimi rs485: Numeric - get rs485 value
 *		dimi dhcpenable: Numeric - get dhcp enable value
 *	Created by: Franklin On 2009-05-08 16:49:05
 ***********************************************************/
function setPORTDetails(dimi httpport,dimi httpsport,dimi portinput, _
						dimi portoutput,dimi rs485,dimi dhcpenable)
	
	dims PORTSetting$
	dims responseData$
	dimi ret
	
	if dhcpenable=1 then
		PORTSetting$="httpsport="+httpsport+"&portinput="+portinput+_
					 "&portoutput="+portoutput+"&rs485="+rs485+""
	else 
		PORTSetting$="httpport="+httpport+"&httpsport="+httpsport+"&portinput="+portinput+_
					 "&portoutput="+portoutput+"&rs485="+rs485+""
	end if
					
	ret = setProperties(PORTSetting$, responseData$)
	
	if ret >= 0 then
	
		dims propName$(6) = ("ghttpport","ghttpsport", "gportinput", "gportoutput", "grs485")

		dims propVal$(6)
		propVal$(0) = httpport
		propVal$(1) = httpsport
		propVal$(2) = portinput
		propVal$(3) = portoutput
		propVal$(4) = rs485	
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret			
	
End Function

/***********************************************************
'** getMotionDetectSettings
 *	Description: 
 *		Get the motion detection setting values from IPNC
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dimi isCustomvalue: Numeric - flag value to define if the sensitivity chosen is predefined or any custom value.
'*		byref dimi sensitivity: Numeric - the sensitivity value - 
'*								if isCustomvalue is 0 then sinsitivity will contain the value 
 *		byref dimi thresholdValue: Numeric - threshold value for customize 
 *		byref dimi minThreshold:Numeric - min customize threshold value
 *		byref dimi maxThreshold:Numeric - max customize threshold value
'*						in the dropdown else it will be the custom value entered.
 *	Created by: Franklin On 2009-03-02 12:13:49
 ***********************************************************/
function getMotionDetectSettings(byref dimi isCustomvalue, byref dimi sensitivity, byref dimi thresholdValue, _
								 byref dimi minThreshold, byref dimi maxThreshold, byref dims motionBlock$)
	
	dims tempVal$
	
	dims varName$(6)  = ("isCustomvalue", "sensitivity", "thresholdValue", "minThreshold", "maxThreshold", "motionBlock$")
	dims propName$(6) = ("gmotioncenable", "gmotionsensitivity", "gmotioncvalue", "gminmotionthreshold", "gmaxmotionthreshold", "gmotionblock")
	dims values$(6)
	dimi i, ret
	
	'Get the INI propery values
	ret = getIniValues(propName$, values$)
	
	if ret = 0 then
			
		for i= 0 to ubound(values$)
			if i = 5 then
				{varName$(i)} = values$(i)					'Assign the values into variables
			else
				{varName$(i)} = strtoint(values$(i))		'Assign the values into variables
			endif		
			
		next
		
	endif
	
	return ret
			
End Function

/***********************************************************
'** setMotionDetectSettings
 *	Description: 
 *		Set motion detection setting values 
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		dimi isCustomvalue: Numeric - flag value to define if the sensitivity chosen is predefined or any custom value.
'*		dimi sensitivity: Numeric - the sensitivity value - 
'*						if isCustomvalue is 0 then sinsitivity will contain the value 
'*						in the dropdown else it will be the custom value entered.
 *		dimi thresholdValue : customized threshold value
 *	Created by: Franklin On 2009-03-02 12:17:29
 ***********************************************************/
function setMotionDetectSettings(dimi isCustomvalue, dimi sensitivity, dimi thresholdValue, dims motionBlock$)
	
	dimi ret, i
	dims value$
	dims responseData$
	
	dims propName$(4) = ("motioncenable", "motioncvalue", "motionsensitivity", "motionblock")
	dims propValue$(4)= ("isCustomvalue", "thresholdValue", "sensitivity", "motionBlock$")
 
	value$ = propName$(0) + "=" + {propValue$(0)}
	
	'Combine the properties with value
	for i=1 to 3
		value$ +=  "&" + propName$(i) + "=" + {propValue$(i)}
	next
	
	'Set the properties
	ret = setProperties(value$, responseData$)

	if ret >= 0 then
		
		for i=0 to 3
			propName$(i) = "g"+propName$(i)
			propValue$(i) = {propValue$(i)}
		next
		
		'Update the value which values are succesfully updated
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propValue$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret
			
End Function

/***********************************************************
'** getMotionDetectOptions
 *	Description: 
 *		Get the Alarm setting module dropdown values 
 *	Returns 0 for Success; -1 failure	
	
 *	Params:
 *		byref dims arrSensitivity$: String - Returns the array containing the predefined sensitivity options.
 *	Created by: Partha Sarathi.K On 2009-03-02 12:30:15
 *	History: 
 ***********************************************************/
function getMotionDetectOptions(byref dims arrSensitivity$())
	
	dims tempVal$
	
	dims propName$(1) = ("gmotionname")
	dims values$(1)
	dimi ret, i, retVal
		
	retVal = getIniValues(propName$, values$)				'Get the motion name
	
	if retVal = 0 then
		ret = split(tempVal$, values$(0), ";")				'Split the motion names
	
		if ret >= 1 then
			redim arrSensitivity$(ret)						'Resize the fill array
			arrSensitivity$ = tempVal$						'Store th values
		endif
	endif
	
	return retVal
		
End Function


/***********************************************************
'** loadIniValues
 *	Description: 
 *		Load the properties from ini file.
 *		Parse the properties & value.

 *	Created by: Partha Sarathi.K On 2009-02-23 11:42:22
 *	Modified by: vimala 28-05-2008
 ***********************************************************/
function loadIniValues()
	
	dimi index
	dims value$, line$
	dimi ret, retVal
	dimi length
	dims tempProp$,temp$
	
	dim keywords$(5000) 
	
	'All the keyword required for GUI	
	keywords$ = ",title,audioenable,rotctrl,clicksnapfilename,democfgname,clicksnapstorage"_
				",democfg,ftpip,ftpuser,ftppassword,ftppath,ftpipport,smtpuser,smtppwd,smtpsender"_
				",smtpip,emailuser,smtpauth,sntpip,sntptimezone,daylight,httpsport,portinput"_
				",portoutput,rs485,portinputname,portoutputname,rs485name,netip,netmask,gateway,dnsip,httpport"_
				",dhcpenable,rftpenable,ftpfileformat,sdrenable,sdfileformat"_
				",sdfileformatname,recordlocalstorage,schedulerepeatenable,schedulenumweeks,scheduleinfiniteenable"_
				",fdetect,fdx,fdy,fdw,fdh,fdconflevel,fddirection,frecognition,frconflevel,frdatabase"_
				",privacymask,maskoptions,fddirectionname,maskoptionsname,motioncenable,motionsensitivity"_
				",motioncvalue,minmotionthreshold,maxmotionthreshold,motionname,brightness,contrast"_
				",saturation,sharpness,blc,lbce,awb,colorkiller,exposurectrl,priority,maxexposuretime"_
				",maxgain,nfltctrl,tnfltctrl,vidstb1,lensdistortcorrection,binning,img2a,awbname,backlight,backlightname"
				
	keywords$ +=",exposurename,priorityname,maxexposuretimename,maxgainname,nfltctrlname,binningname"_
				",img2aname,audioenable,audiomode,gainvalue,encoding,samplerate,audiobitrate"_
				",alarmlevel,audioinvolume,audiomodename,encodingname,sampleratename,audiobitratename"_
				",date,time,sntpip,timezone,daylight,timeformat,tstampformat,dateposition"_
				",timeposition,dateformatname,tstampformatname,datetimepositionname,datetimepositionname"_
				",alarmenable,alarmduration,alarmperiodicity,motionenable,lostalarm,darkblankalarm"_
				",extalarm,exttriggerinput,exttriggeroutput,aftpenable,ftpfileformat,asmtpenable,smtpminattach"_
				",smtpmaxattach,asmtpattach,sdaenable,sdfileformat,alarmlocalstorage,alarmaudioplay"_
				",alarmaudiofile,exttriggername,ftpfileformatname,attfileformatname,sdfileformatname"_
				",recordduration,alarmperiodicityname,alarmaudiofilename,devicename,videocodec,videomode"
			
	keywords$ +=",videocodecname,videocodecmode,videocodecmodename,videocodecres,videocodecresname"_
				",framerate1,frameratenameall1,framerate2,frameratenameall2,framerate3,frameratenameall3"_
				",bitrate1,ratecontrol1,ratecontrolname,datestampenable1"_
				",timestampenable1,logoenable1,logoposition1,logopositionname,textenable1,textposition1"_
				",textpositionname,encryptvideo,localdisplay,rotctrl,rotctrlname,mirctrl,mirctrlname"_
				",overlaytext1,bitrate2,ratecontrol2,datestampenable2"_
				",timestampenable2,logoenable2,logoposition2,textenable2,textposition2,overlaytext2"_
				",jpegframerate,livequality,datestampenable3,,timestampenable3"_
				",logoenable3,logoposition3,textenable3,textposition3,overlaytext3,devicename"_
				",ipratio1,qpmin1,qpmax1,meconfigname,packetsize1,forceiframe1,umv1,intrapframe1"
				
	keywords$ +=",regionofinterestenable1,meconfig1,str1x1,str1y1,str1w1,str1h1,str1x2,str1y2"_
				",str1w2,str1h2,str1x3,str1y3,str1w3,str1h3,ipratio2,qpmin2,qpmax2,packetsize2"_
				",forceiframe2,umv2,intrapframe2,regionofinterestenable2,meconfig2,str2x1,str2y1"_
				",str2w1,str2h1,str2x2,str2y2,str2w2,str2h2,str2x3,str2y3,str2w3,str2h3"_
				",ipratio3,qpmin3,qpmax3,packetsize3,forceiframe3,umv3,intrapframe3,regionofinterestenable3"_
				",meconfig3,str3x1,str3y1,str3w1,str3h1,str3x2,str3y2,str3w2,str3h2,str3x3,str3y3"_
				",str3w3,str3h3,authorityadmin,authorityoperator,authorityviewer,minnamelen,motionblock"_
				",kernelversion,biosversion,softwareversion,activexversion,guiversion,detailinfo1,detailinfo2"_
				",detailinfo3,histogram,img2atype,img2atypename,multicast,frecognitionname,audiooutvolume"_
	
	keywords$ +=",aviformat,aviformatname,aviduration,avidurationname,reloadtime,qpinit1,qpinit2,qpinit3"_
				",videocodeccombo,videocodeccomboname,streamname1,streamname2,streamname3,streamname4"_
				",localdisplayname,sdinsert,reloadflag,dmvaenable,rs232speed,rs232databit,rs232stopbit"_
				",rs232parity,rs232streamctrl,rs232applyto,rs232devicenum"_
				",RS485buadrate,RS485databit,RS485stopbit,RS485paritycheck,RS485streamcontrol,RS485channelnum,RS485decoderaddr,RS485devicenum"			
	retVal = dwnldIniFile()										'Load values from ini.htm
	
	if retVal > 0 then
						
		length = len(~responseData$)
		line$  = ""
		
		~maxPropIndex = 0
				
		for index = 0 to length-1
			iff ~responseData$(index) = "\r" then continue
			if ~responseData$(index) = "\n" then				'is newline fetched
				
				ret = split(value$, line$, "=")					'split the property and its value
				line$ = ""
				
				iff ret <= 1 then continue				
				tempProp$ = lcase$(value$(0)) 			
				
				if find(keywords$,tempProp$) >= 0  then					
					~iniProperties$(~maxPropIndex) = "g"+tempProp$		'propName$
					temp$ =  value$(1)									'propValue$
					iff ret = 3 then temp$ += "="+value$(2)   			'To get the complete stream address of RTSP URL
					~iniPropValues$(~maxPropIndex) = temp$ 
					
					~maxPropIndex++
				end if				
						
				continue
											
			endif
			line$ += ~responseData$(index)		'Add the string upto end of line
				
		next			
		
	endif	
	
	return retVal
				
End function


/***********************************************************
'** getiniValues
 *	Description: 
 *		Get the parsed ini value for given keyword.
 *		
 *	Params:
 *		dims propName$: String array - Holds the keywords for which value to fetched from server
 *      byref dims propValue$ : String array - Holds corresponding value for the keyword 
 *	Created by: Partha Sarathi.K On 2009-02-27 11:58:25
 ***********************************************************/
function getiniValues(dims propName$(), byref dims propValue$())
	
	dimi i, j
	dims tempVal$
	dimi ret
	dimi maxProperty
	
	maxProperty = ubound(propName$)
	
	for i=0 to maxProperty
		
		propValue$(i) = "-1"									'Set default as -1
		
		if trim$(propName$(i)) <> "" then			
			
			for j = 0 to ~maxPropIndex-1
				
				if ~iniProperties$(j) = propName$(i) then	    'Is given property found	
					propValue$(i)   = ~iniPropValues$(j)		'store the value
					break
				endif
			
			next
		
		endif
		
	next
	
	return 0
				
End function


/***********************************************************
'** dwnldIniFile
 *	Description: 
 *		Download the ini.htm file contents with user name password in header information.

 *	Created by: Partha Sarathi.K  On 2009-02-27 15:17:26
 ***********************************************************/
function dwnldIniFile()	
	dimi ret
	dims tempAuth$
	
	'Generate authentication header
	tempAuth$ = generateauthHeader$(~authUserName$, ~authPassword$)
	~authHeader$ = "Authorization: Basic " + tempAuth$ + "\r\n"
	pprint "header = " + ~authHeader$ 
	
	'Download the ini file data's
	ret = HTTPDNLD(~camAddPath$ + "ini.htm", "","a.txt",2,SUPRESSUI,~authHeader$,,,~responseData$)
	~responseData$ = Repl$(~responseData$, "<br>", "\n")
	dwnldIniFile = ret
	
End Function



/***********************************************************
'** dwnldLicenseFile
 *	Description: Download the file(.txt) from camera.
 *		
 *	Created by: Franklin Jacques.k  On 2009-10-08 10:25:11
 ***********************************************************/
function dwnldFile$(dims fileName$)
	
	dimi ret
	dims tempAuth$
	dim textInfo$(30000)
	dims filePath$
	
	'Generate authentication header
	tempAuth$ = generateauthHeader$(~authUserName$, ~authPassword$)
	~authHeader$ = "Authorization: Basic " + tempAuth$ + "\r\n"
	
	'Download the ini file data's
	filePath$ = ~camAddPath$ + fileName$
	ret = HTTPDNLD(filePath$, "",fileName$,2,SUPRESSUI,~authHeader$,,,textInfo$)
	textInfo$ = Repl$(textInfo$, "<br>", "\n")
	textInfo$ = Repl$(textInfo$, "\t", "    ")
	textInfo$ = Repl$(textInfo$, chr$(147), "\"")
	textInfo$ = Repl$(textInfo$, chr$(148), "\"")
	textInfo$ = Repl$(textInfo$, chr$(146), "'")
	pprint textInfo$
	if ret > 0 then
		dwnldFile$ = textInfo$
	else 
		dwnldFile$ = "NA"
	end if
		
End Function


/***********************************************************
'** updateLatestValues
 *	Description: Call this function to update property value in 
				 ~iniPropValues$ array if property value is not -1

 *	Params:
 *		dims propertyName$(): String array - Hold camera keywords
 *		dims propertyValues$(): String array - Holds updated values for each keyword
 *	Created by: Vimala On 2009-03-19 15:45:31
 ***********************************************************/
Sub updateLatestValues(dims propertyName$(),dims propertyValues$())
	
	dimi i, j	
	dimi maxVal
	
	maxVal = ubound(propertyName$)	
	
	iff maxVal <> ubound(propertyValues$) then return
	
	for i=0 to maxVal			
			
		for j = 0 to ~maxPropIndex-1	
					
			if ~iniProperties$(j) = propertyName$(i) then	
			
				iff propertyValues$(i) <> "-1" then ~iniPropValues$(j) = propertyValues$(i)					
				break
			endif	
					
		next	
			
	next
	
End Sub

/***********************************************************
'** getUserSetting
 *	Description: 
 *		Get all available users from camera
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dimi authorityAdmin: Numeric - Admin authority value
'*		byref dimi authorityOperator: Numeric - Operator authority value
'*		byref dimi authorityViewer: Numeric - Viewer authority value
'*		byref dimi minNameLen: Numeric - Minimum username length
'*		byref dimi minPwdLen: Numeric - Minimum password length = minNameLen
'*		byref dims user$(): String Array - Available users in the camera
'*		byref dims authority$(): String Array - Authority applicable for each user 
 *	Created by:  On 2009-03-06 16:03:46
 *	History: 
 ***********************************************************/
function getUserSetting(byref dimi authorityAdmin, byref dimi authorityOperator, _
						byref dimi authorityViewer, byref dimi minNameLen, _
						byref dimi minPwdLen, byref dims user$(), byref dims authority$())
	dims tempVal$
	
	dims varName$(5)  = ("authorityAdmin", "authorityOperator", "authorityViewer", "minNameLen", "minPwdLen")
	dims propName$(5) = ("gauthorityadmin", "gauthorityoperator", "gauthorityviewer", "gminnamelen", "gminnamelen")
	dims values$(5)
	dimi retVal
	
	retVal = getIniValues(propName$, values$)
	
	if retVal = 0 then	
		dimi idx	
		
		for idx= 0 to 4			
			{varName$(idx)} = strtoint(values$(idx))
		next	
		
		retVal = getPropValue("user", user$)
		retVal = getPropValue("authority", authority$)	
		
	endif
		
	return retVal
	
End Function

/***********************************************************
'** addUser
 *	Description: 
 *		Add user to the camera 
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		dims username$: String - Username to be added
'*		dims pwd$: String - Password of the user
 *		dimi authority: Numeric - Authority of the user Admin=0, Operator=1, Viewer=2
 *	Created by:  On 2009-03-06 16:19:09
 *	History: 
 ***********************************************************/
function addUser(dims username$, dims pwd$, dimi authority)
	dimi ret
	dims value$
	dims responseData$,retStatus$
	
	value$ = "adduser="+username$+":"+pwd$+":"+authority			 
	
	ret = setProperties(value$, responseData$)
	
	if ret > 0 then
	
		if trim$(left$(responseData$,3)) = "OK" then
			return 0
		else 
			return -10
		endif
		
	endif	
	
	return ret	
	
End Function

/***********************************************************
'** deleteUser
 *	Description: 
 *		Delete an user in the camera 
 *	Returns 0 for Success; -10/-11 failure	

 *	Params:
 *		dims username$: String - user name
 *	Created by:  On 2009-03-06 18:50:20
 *	History: 
 ***********************************************************/
function deleteUser(dims username$)
	dimi ret
	dims value$
	dims responseData$
	
	value$ = "deluser="+username$		

	ret = setProperties(value$, responseData$)

	if ret > 0 then
	
		if trim$(left$(responseData$,3)) = "OK" then
			return 0
		elseif trim$(left$(responseData$,3)) = "NG" then 
			return -11
		else
			return -10
		endif
		
	endif	
	
	return ret	
		
End Function

/***********************************************************
'** getPropValue
 *	Description: 
 *		Used to get the values of variables User, Authority, Schedule
 *		
 *	Params:
 *		dims prop$: String - Camera Keyword
 *		byref dims propVal$(): String array - Returns the Camera Keyword value in an array
 *	Created by:  On 2009-03-06 17:38:33
 *	History: 
 ***********************************************************/
Function getPropValue(dims prop$, byref dims propVal$())
	dimi pos1, pos2	,ret
	dims userdetail$
	dims retVal$
	
	ret=HTTPDNLD(~camAddPath$+"vb.htm?paratest="+prop$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,userdetail$)
	
	if ret > 0 then
		retVal$ = trim$(left$(userdetail$,3))
		
		if retVal$ = "OK" then
			
			userdetail$ = repl$(userdetail$,"OK ","\n")
			
			pos1 = find(userdetail$, "\n" + prop$ + "=")
			
			if pos1 > -1 then
				pos1 = len(prop$)+2+pos1
				pos2 = find(userdetail$, "\n\n", pos1+1)
				if pos2 > pos1+1 then
					dims tempStr$,arrStr$
					dimi retVal
					tempStr$ = Mid$(userdetail$, pos1, pos2-pos1)
					retVal = split(arrStr$, tempStr$, "\n") 
					propVal$ = arrStr$
					return ret
				else
					return -10
				end if
			else
				return -10
			end if
		elseif retVal$ = "UA" then 
			return -20  ' Viewer
		else
			return -10
		endif	
					
	else
		return ret
	endif
	
End Function



/***********************************************************
'** setSMTPDetails
 *	Description: 
 *		Sets the SMTP details for Network setting
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		dims accName$: String - Account Name
'*		dims pwd$: String - Password
'*		dims sender$: String - Sender email id
'*		dims smtpServer$: String - SMTP Server
'*		dims emailid$: String - Email ID
 *		dimi requiresAuth: Numeric - My server requires authentication
 *	Created by:  On 2009-02-27 15:08:21
 *	History: 
 ***********************************************************/
function setSMTPDetails(dims accName$, dims pwd$, dims sender$, _
					dims smtpServer$, dims emailid$, dimi requiresAuth)
	Dims SMTPDetails$
	dims responseData$
	dimi ret
	SMTPDetails$="smtpuser="+accName$+"&smtppwd="+pwd$+"&smtpsender="+sender$+"&smtpip="+smtpServer$+"&emailuser="+emailid$+"&smtpauth="+requiresAuth
	
	ret = setProperties(SMTPDetails$, responseData$)
	
	if ret > 0 then
		
		dims propName$(6) = ("gsmtpuser", "gsmtppwd", "gsmtpsender","gsmtpip", "gemailuser","gsmtpauth")
		dims propVal$(6)
		propVal$(0) = accName$
		propVal$(1) = pwd$
		propVal$(2) = sender$
		propVal$(3) = smtpServer$
		propVal$(4) = emailid$
		propVal$(5) = requiresAuth
					
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret										
		
End Function



/***********************************************************
'** setSNTPDetails
 *	Description: 
 *		Sets the SNTP details for Network setting
 *	Returns 0 for Success; -1 failure	
 *	SRS Reference: Software Requirements> Modules> Settings> Network Setting	
 *	Params:
'*		dims sntpServer$: String - SNTP server
'*		dims timezone$: String - Time zone name
 *		dimi daylight: Numeric - Automatically adjust for Daylight saving time changes
 *	Created by:Franklin On 2009-02-27 15:33:09
 *	History: 
 ***********************************************************/
function setSNTPDetails(dims sntpServer$, dimi timezone, dimi daylight)
	
	Dims SNTPDetails$
	dims responsedata$
	dimi ret
	
	SNTPDetails$="sntpfqdn="+sntpServer$+"&timezone="+timezone+"&daylight="+daylight+""
	
	ret = setProperties(SNTPDetails$, responseData$)
		
		if ret > 0 then
		
		dims propName$(3) = ("gsntpip","gtimezone","gdaylight")
		dims propVal$(3)
		propVal$(0) = sntpServer$
		propVal$(1) = timezone
		propVal$(2) = daylight
			
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret				
	
End Function


/***********************************************************
'** getTimezones
 *	Description: 
 *		Get the available list of Time zones
 *	Returns 0 for Success; -1 failure	
	
 *	Params:
 *		byref dims arrTimezones$(): String array - to return the timezones
 *		dims arrTimezones$(): String - file name to be downloaded from camera
 *	Created by:Franklin  On 2009-02-27 15:38:52
 ***********************************************************/
function getTimezones(byref dims arrTimezones$(),dims fileName$)
	dimi splitCount,i
	dims tempZoneVal$,timeZones$
	tempZoneVal$ =  dwnldFile$(fileName$)
	if tempZoneVal$ <> "" then
		splitCount = split(timeZones$,tempZoneVal$,"\n")
		if splitCount > 0  then
			redim arrTimezones$(splitCount)
			arrTimezones$ = timeZones$
			return 1
		else 
			return -1
		end if		
	else 
		return -1
	end if
	   
End Function

/***********************************************************
'** getDateTime
 *	Description: 
 *		Get the storage setting for the camera 
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dims dateInCamera$: String - Date as in Camera
'*		byref dims timeInCamera$: String - Time as in Camera		
'*		byref dims sntpServer$: String - SNTP server name
 *		byref dims Timezonename$: String - Time zone name
 *		byref dimi daylight : Numeric - Check to activate this functionality. 
 *		byref dimi dateformat: String - Time as in Camera
 *		byref dimi timeFormat : Numeric - Possible values are 24h, 12h
 *		byref dimi datePosition : Numeric - Possible values are top-left, bottom-left, top-right, bottom-right
 *		byref dimi timePosition : Numeric - Possible values are top-left, bottom-left, top-right, bottom-right
 *
 *	Created by: vimala On 2009-05-11 12:30:27
 *	History: 
 ***********************************************************/
function getDateTime(byref dims dateInCamera$, byref dims timeInCamera$, _
					 byref dims sntpServer$, byref dimi sntptimezone,byref dimi daylight, _
					 byref dimi dateformat, byref dimi timeFormat, byref dimi datePosition, _
					 byref dimi timePosition)
					 
	dims varName$(9)  = ("dateInCamera$","timeInCamera$","sntpServer$","sntptimezone","daylight",_
						 "dateformat","timeFormat","datePosition","timePosition")
						 
	dims propName$(9) = ("gdate","gtime","gsntpip","gtimezone","gdaylight",_
						 "gdateformat","gtstampformat","gdateposition","gtimeposition")
	
	dims tempVal$(9)
	dimi idx,retVal
	
	retVal = getiniValues(propName$,tempVal$)	
	
	if retVal = 0 then	
		for idx = 0 to ubound(tempVal$)		
			
			if  idx = 0  or idx = 1  or idx = 2 then
				{varName$(idx)} = tempVal$(idx)
						
			else 
				{varName$(idx)} = strtoint(tempVal$(idx))
			endif		
						
		next	
	
	endif
	
	return retVal
		
End Function

/***********************************************************
'** getDateFormatOptions
 *	Description: 
 *		Get the date/Time setting drop dowm values from camera 
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dims dateformat$ : String Array - Possible values are DD-MM-YYYY, MM-DD-YYYY,  YYYY-MM-DD.
'*		byref dims timeFormat$ : String Array - Possible values are 24h, 12h
'*		byref dims datePosition$ : String Array - Possible values are top-left, bottom-left, top-right, bottom-right
'*		byref dims timePosition$ : String Array - Possible values are top-left, bottom-left, top-right, bottom-right
 *                                           
 *	Created by: vimala  On 2009-05-11 12:38:43
 *	History: 
 ***********************************************************/
function getDateFormatOptions(byref dims dateformat$(),byref dims timeFormat$(), _
							  byref dims datePosition$(),byref dims timePosition$())
	
	
	dims varName$(4) = ("dateformat$","timeFormat$","datePosition$","timePosition$")  
	dims propName$(4) = ("gdateformatname","gtstampformatname","gdatetimepositionname","gdatetimepositionname")
	dims tempVal$(4)
	
	dimi splitidx, retVal, sptCount	,idx
	dims optionValue$, splitChar$
	
	retVal = getIniValues(propName$,tempVal$)
	
	if retVal = 0 then
				
		for idx= 0 to ubound(tempVal$)
		
			splitChar$ = ";"
			sptCount = split(optionValue$, tempVal$(idx), splitChar$)
			iff sptCount>0 then redim {varName$(idx)}(sptCount)
			
			for splitidx = 0 to sptCount-1
				{varName$(idx)}(splitidx) = optionValue$(splitidx)
			next
				
		next
		
	endif
	
	return retVal
		
End Function

/***********************************************************
'** setDatetime
 *	Description: 
 *		Set the date,time format / new date & time
 *				Based on the option selected the values are set to camera
 *				if response for the synchronise is TIMEOUT timefrequency display "SNTP request timed out due to network problem"
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		dimi setdate : Numeric - 0-Date not modified,1,2-Date modified,3-Synchronize with SNTP server
'*		dims newDate$ : String - The new date to be set
'*		dims newtime$ : String - The new time to be set 
'*		dimi dateformat : Numeric - Date format
'*		dimi timeFormat : Numeric - Time format
'*		dimi datePosition : Numeric - Date Position 
'*		dimi timePosition : Numeric - time Position
 *	Created by:  vimala On 2009-05-11 12:52:47
 *	History: 
 ***********************************************************/
function setDatetime(dimi setdate, dims newDate$, dims newtime$,_
					 dimi dateformat, dimi timeFormat, dimi datePosition,_
					 dimi timePosition,dimi timezone, dimi daylight)
	
	dims value$,responseData$
	dimi ret	
		
	if setdate = 0 then									'No option selected
		value$ = "dateformat="+dateformat+"&tstampformat="+timeFormat+"&dateposition="+datePosition+_
				 "&timeposition="+timePosition
	elseif 	setdate	= 1 or  setdate	= 2 then			'Selected set manually or synchronize with computer time option 
		value$ = "newdate="+newDate$+"&newtime="+newtime$+"&dateformat="+dateformat+_
				 "&tstampformat="+timeFormat+"&dateposition="+datePosition+_
				 "&timeposition="+timePosition
	elseif 	setdate	= 3 then							'Selected synchronize with SNTP server option 	
		value$ = "timefrequency=-1&daylight="+daylight+"&timezone="+timezone+"&dateformat="+dateformat+_
				 "&tstampformat="+timeFormat+"&dateposition="+datePosition+_
				 "&timeposition="+timePosition
		
	endif	
	pprint value$ 
	ret = setProperties(value$, responseData$)	
	
	if find(responseData$,"TIMEOUT timefrequency") <> -1 then
		settimer(0,"")
		msgbox("SNTP request timed out due to network problem")	
		ret = -11
		settimer(1000,"DisplayDigitalClock")
	else	
		
		dims propName$(8) = ("gdate","gtime","gdateformat",_
							 "gtstampformat","gdateposition","gtimeposition",_
							 "gdaylight","gtimezone")
							
		dims propVal$(8)
		
		propVal$(0) = newDate$
		propVal$(1) = newtime$
		propVal$(2) = dateformat				
		propVal$(3) = timeFormat				
		propVal$(4) = datePosition				
		propVal$(5) = timePosition				
		propVal$(6) = daylight				
		propVal$(7) = timezone				
			
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif				
		
	endif
	
	return ret
	
End Function

/***********************************************************
'** getStorageSetting
 *	Description: 
 *		Get the storage setting values for the camera 
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dimi uploadbyFTP: Numeric - Enabled/ Disabled
		byref dimi ftpfileformat: Numeric - Enabled/ Disabled
		byref dims ftpfileformatname$: string - MPEG/JPEG
'*		byref dimi storeLocally: Numeric - Enabled/ Disabled
		byref dimi sdfileformat: Numeric - Enabled/ Disabled
		byref dims sdfileformatname$: string - MPEG/JPEG
'*		byref dimi localStorage: Numeric - SD Card/ USB/ NAND
'*		byref dimi repeatSchedule: Numeric - Repeat for weeks/ Run infinite times
'*		byref dimi noOfWeeks: Numeric - No of weeks to repeat
 *		byref dims recordSchedule$(): String - Existing record schedule
 *	Created by:Franklin  On 2009-03-09 12:04:40
 *	History: 
 ***********************************************************/
Function getStorageRec(byref Dims commandtype$,dimi videochannel,byref dims responeData$)
	dimi ret,retVal
	
	ret=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+videochannel, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeData$)
	if ret > 0 then
		return ret
	else
		return -10	
	end if 		
End Function

Function getschedule(byref Dims commandtype$,dimi videochannel,byref dims recordSchedule$())
	dimi ret,retVal
	dims responeData$
	ret=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+videochannel, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeData$)
	if ret > 0 then
		return ret
	else
		return -10	
	end if 		
End Function

//function getStorageSetting(byref dimi uploadbyFTP,byref dimi ftpfileformat,byref dims ftpfileformatname$, byref dimi storeLocally, _
//						   byref dimi sdfileformat,byref dims sdfileformatname$, byref dimi localStorage, byref dimi repeatSchedule, byref dimi noOfWeeks, _
//						   byref dims recordSchedule$(),byref dimi scheduleInfinity,byref dimi sdCard)
//	
//	dimi retVal,ret,i
//	
//	retVal = getPropValue("schedule", recordSchedule$)
//	
//	dims varName$(11)  = ("uploadbyFTP","ftpfileformat","ftpfileformatname$","storeLocally","sdfileformat","sdfileformatname$","localstorage","repeatSchedule", _
//						 "noOfWeeks","scheduleInfinity","sdCard")
//	dims propName$(11) = ("grftpenable","gftpfileformat","gftpfileformatname","gsdrenable","gsdfileformat","gsdfileformatname","grecordlocalstorage","gschedulerepeatenable", _
//						 "gschedulenumweeks","gscheduleinfiniteenable","gsdinsert")
///	dims tempVal$(11)
///	ret=getiniValues(propName$,tempVal$)	
//	if ret>=0 then	
//		for i= 0 to ubound(tempVal$)
//			if i=2 or i=5 then
//				{varName$(i)} = tempVal$(i)				
//			else
//				{varName$(i)} = strtoint(tempVal$(i))			
//			endif
//		next
//	endif
//	return ret 
//End Function


/***********************************************************
'** setStorageSetting
 *	Description: 
 *		Sets the storage setting values to camera 
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dimi storageformat: Numeric - Available options are AVI, MP4
'*		byref dimi uploadbyFTP: Numeric - Enabled/ Disabled
'*		byref dimi storeLocally: Numeric - Enabled/ Disabled
'*		byref dimi localStorage: Numeric - SD Card/ USB/ NAND
'*		byref dimi repeatSchedule: Numeric - Repeat for weeks/ Run infinite times
'*		byref dimi noOfWeeks: Numeric - No of weeks to repeat
 *		byref dims recordSchedule$(): String - Existing record schedule
 *	Created by:Franklin  On 2009-03-09 14:02:04
 *	History: 
 ***********************************************************/
Function setStorageRec(dimi videochannel,dimi repeatSchedule, _
						   dimi scheduleInfinity, dims recordSchedule$)
	dims storage$
	dims responsedata$
	dimi ret
	storage$="setstoragerec="+videochannel+"@"+repeatSchedule+"@"+scheduleInfinity+"&schedule="+recordSchedule$
//	msgbox(plc$)
	ret = setProperties(storage$, responseData$)	
	return ret					
end function
//function setStorageSetting(dimi uploadbyFTP,dimi ftpfileformat, dimi storeLocally, _
//						   dimi sdfileformat, dimi localStorage, dimi repeatSchedule, dimi noOfWeeks, _
//						   dimi scheduleInfinity, dims recordSchedule$)
//	dims storageSetting$
//	dims responseData$
//	dimi ret
//	storageSetting$="rftpenable="+uploadbyFTP+"&ftpfileformat="+ftpfileformat+"&sdrenable="+storeLocally+_
//					"&sdfileformat="+sdfileformat+"&recordlocalstorage="+localStorage+"&schedulerepeatenable="+repeatSchedule+"&schedulenumweeks="+noOfWeeks+_
//					"&schedule="+recordSchedule$+"&scheduleinfiniteenable="+scheduleInfinity+""
//					
//	ret = setProperties(storageSetting$, responseData$)
//	
//	if ret > 0 then
//	
//		dims propName$(8) = ("grftpenable","gftpfileformat","gsdrenable","gsdfileformat","grecordlocalstorage","gschedulerepeatenable", _
//						      "gschedulenumweeks","gscheduleinfiniteenable")
//
//		dims propVal$(8)
//		propVal$(0) = uploadbyFTP
//		propVal$(1) = ftpfileformat
//		propVal$(2) = storeLocally
//		propVal$(3) = sdfileformat
//		propVal$(4) = localStorage
//		propVal$(5) = repeatSchedule
//		propVal$(6) = noOfWeeks
//		propVal$(7) = scheduleInfinity
//		
//		~errorKeywords$ = ""
//		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
//		
//		if len(~errorKeywords$) > 0 then
//			return -10
//		else
//			return ret
//		endif		
//		
//	endif 
//	
//	return ret				
//	
//End Function

/***********************************************************
'** getAlarmSetting
 * Description: 
 *  Get the Alarm setting details
 * Returns 0 for Success; -1 failure 
 * SRS Reference: Software Requirements> Modules> Settings> Alarm Setting 
 * Params:
'*		 byref dimi enableAlarm: Numeric - Check to enable alarm
'* 		 byref dimi storageDuration: Numeric - Duration of file to be stored in case of alarm
'* 		 byref dimi periodicity: Numeric - Periodicity
'*		 byref dimi motionEnabled: Numeric - Is Motion detection enabled
'*		 byref dimi ethernetLost: Numeric - Alarm on Ethernet lost
'*  	 byref dimi darkImages: Numeric - Alarm on Dark Images
'*       byref dimi extTriggerEnabled: Numeric - Alarm on External Trigger.
'*  	 byref dimi extTrigger: Numeric - OFF, SIGNAL LOW & SIGNAL HIGH 
'*  	 byref dimi ftpUpload: Numeric - Upload via FTP
'*  	 byref dimi ftpFormat: Numeric - File format for FTP
'*  	 byref dimi smtpUpload: Numeric - Upload via SMTP
'*  	 byref dimi smtpFormat: Numeric - File format for SMTP
'*		 byref dimi smtpMinFiles: Numeric - SMTP Minimum number of files to be uploaded
'*		 byref dimi smtpMaxFiles: Numeric - SMTP Maximum number of files to be uploaded
'* 		 byref dimi noOfFiles: Numeric - No of files to attach for SMTP
'* 		 byref dimi localStore: Numeric - Store locally
'* 		 byref dimi localFormat: Numeric - File format for local storage
'*       byref dimi storageLocation: Numeric - Available options are SD/MMC, USB and NAND
'*		 byref dimi playAudio: Numeric - Check to activate this functionality 
'*		 byref dimi audioFiles: Numeric - List of audio files available in the IPNC
 * Created by: vimala On 2009-05-11 17:12:10
 * History: 
 ***********************************************************/
function getAlarmSetting(byref dimi enableAlarm, byref dimi storageDuration, _
						 byref dimi motionEnabled, byref dimi ethernetLost, _
						 byref dimi darkImages, byref dimi extTriggerEnabled, _
						 byref dimi extTriggerInput, byref dimi exttriggeroutput, _
						 byref dimi ftpUpload, byref dimi ftpFormat, byref dimi smtpUpload, byref dimi smtpFormat, _
						 byref dimi smtpMinFiles,byref dimi smtpMaxFiles,byref dimi noOfFiles, _
						 byref dimi localStore, byref dimi localFormat, _
						 byref dimi storageLocation, byref dimi playAudio, byref dimi audioFiles,byref dimi sdCard)
						  
	dims varName$(21)  = ("enableAlarm", "storageDuration", _
						  "motionEnabled", "ethernetLost", _
						  "darkImages", "extTriggerEnabled", _
						  "extTriggerInput", "exttriggeroutput", _
						  "ftpUpload", "ftpFormat", "smtpUpload", "smtpFormat", _
						  "smtpMinFiles","smtpMaxFiles","noOfFiles", _
						  "localStore", "localFormat", _
						  "storageLocation", "playAudio", "audioFiles","sdCard")
						  
	dims propName$(21) = ("galarmenable", "galarmduration", _
						  "gmotionenable", "glostalarm", _
						  "gdarkblankalarm", "gextalarm", _
						  "gexttriggerinput", "gexttriggeroutput", _
						  "gaftpenable", "gftpfileformat", "gasmtpenable", "gattfileformat", _
						  "gsmtpminattach", "gsmtpmaxattach", "gasmtpattach", _
						  "gsdaenable", "gsdfileformat", _
						  "galarmlocalstorage", "galarmaudioplay", "galarmaudiofile","gsdinsert")	
	
	dimi idx,retVal
	dims tempVal$(21)
	
	retVal = getiniValues(propName$,tempVal$)	
	
	if retVal = 0 then
			
		for idx = 0 to ubound(tempVal$)				
			{varName$(idx)} = strtoint(tempVal$(idx))					
		next
	
	endif
	
	return retVal 
 
End Function
 
/***********************************************************
'** getAlarmSettingOptions
 * Description: 
 *  Get the Alarm setting module dropdown values 
 * Returns 0 for Success; -1 failure 
 * SRS Reference: Software Requirements> Modules> Settings> Alarm Setting 
 * Params:
'*  	byref dims arrExtInpTriger$: String Array - Returns options for external Input Trigger - OFF, SIGNAL LOW & SIGNAL HIGH
'*  	byref dims arrExtOutTriger$: String Array - Returns options for external Output Trigger - OFF, SIGNAL LOW & SIGNAL HIGH
'* 		byref dims arrFtpFormat$: String Array - Returns the FTP upload file formats
'* 		byref dims arrSmtpFormat$: String Array - Returns the SMTP upload file formats
'* 		byref dims arrLocalFormat$: String Array - Returns the local storage file formats
'* 		byref dimi arrStorageDuration$: String Array - Returns the storage duration 
'*  	byref dimi arrPeriodicity$: String Array - Returns the periodicity
 *  	byref dimi audioFiles$: String Array - Returns the durations to be saved before alarm.
 * Created by: vimala On 2009-05-11 10:52:31
 * History: 
 ***********************************************************/
function getAlarmSettingOptions(byref dims arrExtInpTriger$(), byref dims arrExtOutTriger$(), _
								byref dims arrFtpFormat$(), byref dims arrSmtpFormat$(), byref dims arrLocalFormat$(), _
								byref dims arrStorageDuration$(), byref dims audioFiles$())
								
	dims varName$(7)  = ("arrExtInpTriger$","arrExtOutTriger$", _
						 "arrFtpFormat$","arrSmtpFormat$","arrLocalFormat$", _
						 "arrStorageDuration$","audioFiles$")
	
	
	dims propName$(7) = ("gexttriggername","gexttriggername",_
						 "gftpfileformatname","gattfileformatname","gsdfileformatname",_
						 "grecordduration","galarmaudiofilename")
						
	dims tempVal$(7)
	dimi idx, splitidx, retVal,sptCount
	dims optionValue$, splitChar$
	
	retVal = getIniValues(propName$, tempVal$)
	
	if retVal = 0 then
		
		for idx= 0 to ubound(tempVal$)
		
			splitChar$ = ";"
			sptCount = split(optionValue$, tempVal$(idx), splitChar$)
			iff sptCount>0 then redim {varName$(idx)}(sptCount)
			
			for splitidx = 0 to sptCount-1
				{varName$(idx)}(splitidx) = optionValue$(splitidx)
			next
		
		next
		
	endif
	
	return retVal
	
End Function
 
/***********************************************************
'** setAlarmSetting
 * Description: 
 *  set the Alarm setting details
 * Returns 0 for Success; -1 failure 
 * SRS Reference: Software Requirements> Modules> Settings> Alarm Setting 
 * Params:
'*		  dimi enableAlarm: Numeric - Check to enable alarm 
'* 		  dimi storageDuration: Numeric - Duration of file to be stored in case of alarm
'* 		  dimi periodicity: Numeric - Periodicity
'*		  dimi motionEnabled: Numeric - Is Motion detection enabled
'*		  dimi ethernetLost: Numeric - Alarm on Ethernet lost
'*  	  dimi darkImages: Numeric - Alarm on Dark Images
'*        dimi extTriggerEnabled: Numeric - Alarm on External Trigger.
'*  	  dimi extTrigger: Numeric - OFF, SIGNAL LOW & SIGNAL HIGH 
'*  	  dimi ftpUpload: Numeric - Upload via FTP
'*  	  dimi ftpFormat: Numeric - File format for FTP
'*  	  dimi smtpUpload: Numeric - Upload via SMTP
'*  	  dimi smtpFormat: Numeric - File format for SMTP
'* 		  dimi noOfFiles: Numeric - No of files to attach for SMTP
'* 		  dimi localStore: Numeric - Store locally
'* 		  dimi localFormat: Numeric - File format for local storage
'*        dimi storageLocation: Numeric - Storage location .
'*		  dimi playAudio: Numeric - Check to activate this functionality 
'*		  dimi audioFiles: Numeric - List of audio files available in the IPNC
 * Created by: vimala On 2009-05-11 17:12:10
 * History: 
 ***********************************************************/
function setAlarmSetting(dimi enableAlarm, dimi storageDuration, _
						 dimi motionEnabled, dimi ethernetLost, _
						 dimi extTriggerEnabled, _
						 dimi extTriggerInput, dimi exttriggeroutput, _
						 dimi ftpUpload, dimi ftpFormat, dimi smtpUpload, dimi smtpFormat, _
						 dimi noOfFiles, dimi localStore, dimi localFormat, _
						 dimi storageLocation, dimi playAudio, dimi audioFiles)
 
	dimi ret
	dims value$
	dims responseData$

	value$ = "alarmenable="+enableAlarm+"&alarmduration="+storageDuration+ _
			 "&motionenable="+motionEnabled+"&lostalarm="+ethernetLost+ _
			 "&extalarm="+extTriggerEnabled+ _
			 "&exttriggerinput="+extTriggerInput+"&exttriggeroutput="+exttriggeroutput+ _
			 "&aftpenable="+ftpUpload+"&ftpfileformat="+ftpFormat+ "&asmtpenable="+smtpUpload+ "&attfileformat="+smtpFormat+ _
			 "&asmtpattach="+noOfFiles+"&sdaenable="+localStore+"&sdfileformat="+localFormat+ _
			 "&alarmlocalstorage="+storageLocation+"&alarmaudioplay="+playAudio+"&alarmaudiofile="+audioFiles

	pprint value$
	ret = setProperties(value$, responseData$)	

	if ret > 0 then		

		dims propName$(17) = ("galarmenable", "galarmduration", _
							  "gmotionenable", "glostalarm", _
							  "gextalarm", _
							  "gexttriggerinput", "gexttriggeroutput", _
							  "gaftpenable", "gftpfileformat", "gasmtpenable", "gattfileformat", _
							  "gasmtpattach","gsdaenable", "gsdfileformat", _
							  "galarmlocalstorage", "galarmaudioplay", "galarmaudiofile")
		
		dims propVal$(17)
		
		propVal$(0) = enableAlarm
		propVal$(1) = storageDuration
		propVal$(2) = motionEnabled
		propVal$(3) = ethernetLost
		propVal$(4) = extTriggerEnabled
		propVal$(5) = extTriggerInput
		propVal$(6) = exttriggeroutput
		propVal$(7) = ftpUpload
		propVal$(8) = ftpFormat
		propVal$(9) = smtpUpload
		propVal$(10) = smtpFormat
		propVal$(11) = noOfFiles
		propVal$(12) = localStore
		propVal$(13) = localFormat
		propVal$(14) = storageLocation
		propVal$(15) = playAudio
		propVal$(16) = audioFiles			
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif	
						
	endif 
	
	return ret				
 
End Function
 
/***********************************************************
'** getLiveVideoOptions
 *	Description: 
 *		Get the Live video values from camera
 *		
 *	Params:
 *		byref dims streams$(): String - To get the value of the streams
 *		byref dims clicksnapfilename$(): String - To get the filename
 *		byref dims democfgname$(): String - 
 *		byref dims audioenable: integer - To get the audioenable value
 *		byref dims rotation: integer - To get the rotation value
 *		byref dims clicksnapstorage: integer - To get the clicksnapstorage value
 *		byref dims democfg: integer - To get the democfg value
 *		byref dims frecognition: integer -  To get the frecognition value
 *	Created by:Franklin  On 2009-05-19 12:46:05
 *	History: 
 ***********************************************************/
function getLiveVideoOptions(byref dims clicksnapfilename$,byref dims democfgname$, byref dimi audioenable,_
							 byref dimi clicksnapstorage,byref dimi democfg,byref dimi audiomode)
	
	dims varName$(6) = ("clicksnapfilename$","democfgname$","audioenable",_
						"clicksnapstorage","democfg","audiomode")
	dims propName$(6) = ("gclicksnapfilename","gdemocfgname","gaudioenable",_
						 "gclicksnapstorage","gdemocfg","gaudiomode")
	dims tempVal$(6)
	dimi idx, splitidx, retVal, ret	,streamIndex
	dims optionValue$, splitChar$
	
	retVal = getIniValues(propName$, tempVal$)
	
	if retVal = 0 then
		
		for idx=0 to ubound(tempVal$)
			if idx=0 or idx=1 then
				{varName$(idx)} = tempVal$(idx)				
			else
				{varName$(idx)} = strtoint(tempVal$(idx))				
			endif			
		next
	
	endif

	return retVal		
End Function

/***********************************************************
'** setAudioStatus
 *	Description: 
 *		   set audio status(enable/disable)
 *		
 *	Params:
 *		dimi audiostatus: Numeric - Audio status
 *		dimi audiomode: Numeric - Audio mode
 *	Created by:  On 2009-03-13 15:18:23
 ***********************************************************/
function setAudioStatus(dimi audiostatus,dimi audiomode)	
	Dimi ret
	Dims responseData$, data$ 
	data$ = "audioenable="+audiostatus+"&audiomode="+audiomode
	ret = setProperties(data$, responseData$)
	
	if ret > 0 then				
		dims propName$(2) = ("gaudioenable","gaudiomode")
		
		dims propVal$(2)
		propVal$(0) = audiostatus
		propVal$(1) = audiomode
				
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
						
	endif 
	
	return ret
		
End Function

/***********************************************************
'** getAlarmstatus
 *	Description: 
 *		   To get the alarm status(On / Off) from camera
 *		
 *	Params:
 *		dims alarmStatus: Numeric - Alarm status
 *	Created by:Franklin  On 2009-03-13 18:49:49
 ***********************************************************/
Sub getAlarmstatus(byref dims alarmStatus$)	'Added by Rajan to getAlarmStatus1 for testing	
	Dims responseData$
	Dimi ret 
	'hardcoded by Rajan for testing
	ret=HTTPDNLD(~camAddPath$+"vb.htm?getalarmstatus", "","result.txt",2,SUPRESSUI,~authHeader$,1,,responseData$)	
End Sub


/***********************************************************
'** setProperties
 *	Description: Call this function to set property value for each property.
 *		
 *		
 *	Params:
'*		dims data$: String - Keyword with value string
 *		byref dims responseData$: String - Return value from the camera
 *	Created by: rajan  On 2009-03-18 17:38:12
 *	History: 
 ***********************************************************/
function setProperties(dims data$, byref dims responseData$)
	dimi retVal	
	retVal=HTTPDNLD(~camAddPath$+"vb.htm?"+data$, "","result.txt",2,SUPRESSUI,~authHeader$,,,responseData$)
	responseData$ = Repl$(responseData$, "OK ", "\nOK ")
	responseData$ = Repl$(responseData$, "UW ", "\nUW ")
	responseData$ = Repl$(responseData$, "NG ", "\nNG ")
	responseData$ = Repl$(responseData$, ":", "\n")
	responseData$ = Repl$(responseData$, "\n\n", "\n")
	setProperties = retVal	
end function


/***********************************************************
'** getVideoImageSetting
			Get video setting value to camera
 *	Params: 
 *		byref dimi videocodec: Numeric - get the value for the stream type
 *		byref dims videocodecname$: String - Holds stream type drop down options
'*		byref dimi videocodecmode: Numeric - get the value for the codec type 
 *		byref dims videocodecname$: String - Holds codec combo drop down options
 *		byref dimi videocodecres: Numeric - get the value for the resolution type
 *		byref dims videocodecresname$: String  - Hold resolution drop down options 
 *	Created by:  On 2009-05-11 09:44:29
 ***********************************************************/
function getVideoImageSetting(byref dimi videocodec, byref dims videocodecname$, byref dimi videocodecmode, _
							  byref dims videocodecmodename$, byref dimi videocodecres, byref dims videocodecresname$)		 
		dims varName$(6)  = ("videocodec", "videocodecname$", "videocodecmode",_
							 "videocodecmodename$", "videocodecres","videocodecresname$")
		dims propName$(6) = ("gvideocodec", "gvideocodecname", "gvideocodeccombo",_
							 "gvideocodeccomboname", "gvideocodecres","gvideocodecresname")
		dims tempVal$(6)
		dimi i,ret
		
		ret=getiniValues(propName$,tempVal$)
		if ret>=0 then
			for i= 0 to ubound(tempVal$)
				if i=1 or i=3 or i=5 then
					{varName$(i)} = tempVal$(i)							
				else 
					{varName$(i)} = strtoint(tempVal$(i))					
				endif
			next
		endif
		
		return ret 	

End Function


/***********************************************************
'** getVideoStream1
			Get video stream 1 values from camera
 *	Description: 
 *		byref dimi framerate1: Numeric - get the framerate for stream1
 *		byref dimi frameratename1$: String - get all possible frame rate options to load drop down
'*		byref dimi bitrate1: Numeric -  get the livequality value
'*		byref dimi ratecontrol1: Numeric - get the value of ratecontrol for stream1
'*		byref dims ratecontrolname$: String - get ratecontrol drop down option values 
'*		byref dimi datestampenable1: Numeric - get the option value for date-enable/disable
'*		byref dimi timestampenable1: Numeric - get the option value for time-enable/disable
'*		byref dimi logoenable1: Numeric - get the option value to display logo-enable/disable
'*		byref dimi logoposition1: Numeric - get the value for logoposition of stream1
'*		byref dims logopositionname$: String - get the value for logo position drop down option values 
'*		byref dimi textenable1: Numeric - get the value for textanable-enable/disable
 *		byref dimi textposition1: Numeric - get the value for textposition of stream1
 *		byref dims  textpositionname$: String - get the value for text position drop down option values 
'*		byref dimi encryptvideo: Numeric - get the option for encryptvideo-on/off
'*		byref dimi localdisplay: Numeric - get the option for encryptvideo-enable/disable
 *		byref dimi mirctrl: Numeric - get the option for mirctrl-enable/disable
 *		byref dims mirctrlname$: String - get the option for mirror ctrl drop down option values 
 *		byref dims overlaytext1$: String - get the overlay text value
 *		byref dimi detailinfo1: Numeric - get the  detail info value
 *		byref dims localdisplayname$: String - get the local display drop down option values 
 *
 *	Created by:  On 2009-05-11 09:44:41
 *	Histbyref ory: 
 ***********************************************************/
function getVideoStream1(byref dimi framerate1, byref dims frameratename1$, byref dimi bitrate1, _
					     byref dimi ratecontrol1, byref dims ratecontrolname$, byref dimi datestampenable1, byref dimi timestampenable1,_
						 byref dimi logoenable1, byref dimi logoposition1, byref dims logopositionname$,_
						 byref dimi textenable1, byref dimi textposition1, byref dims textpositionname$,_
						 byref dimi encryptvideo, byref dimi localdisplay, byref dimi mirctrl,_
						 byref dims mirctrlname$, byref dims overlaytext1$,byref dimi detailinfo1,byref dims localdisplayname$)			'TR-11	
		
		dims varName$(20)  = ("framerate1", "frameratename1$", "bitrate1", "ratecontrol1", "ratecontrolname$","datestampenable1","timestampenable1",_
							"logoenable1","logoposition1","logopositionname$","textenable1","textposition1","textpositionname$","encryptvideo",_
							"localdisplay","mirctrl","mirctrlname$","overlaytext1$","detailinfo1","localdisplayname$")
							
		dims propName$(20) = ("gframerate1", "gframeratenameall1", "gbitrate1", "gratecontrol1", "gratecontrolname","gdatestampenable1","gtimestampenable1",_
							"glogoenable1","glogoposition1","glogopositionname","gtextenable1","gtextposition1","gtextpositionname","gencryptvideo",_
							"glocaldisplay","gmirctrl","gmirctrlname","goverlaytext1","gdetailinfo1","glocaldisplayname")
		dims tempVal$(20)
		dimi i,ret
		
		ret=getiniValues(propName$,tempVal$)
		if ret>=0 then
			for i= 0 to ubound(tempVal$)			
				if i=1 or i=4 or i=9 or i=12 or i=16 or i=17 or i=19 then
					{varName$(i)} = tempVal$(i)				
				else 
					{varName$(i)} = strtoint(tempVal$(i))				
				endif
			next
		endif
		
		return ret 
		
	
End Function


/***********************************************************
'** getVideoStream2
 *	Description: 
		Get video stream 2 values from camera
		
 *	Params:
 *		byref dimi framerate2: Numeric - get the framerate for stream2
 *		byref dims frameratename2$: String - get all possible frame rate options to load drop down
'*		byref dimi bitrate2: Numeric -  get the bitrate value
'*		byref dimi ratecontrol2: Numeric - get the value of ratecontrol for stream2
'*		byref dimi datestampenable2: Numeric - get the option value for date-enable/disable
'*		byref dimi timestampenable2: Numeric - get the option value for time-enable/disable
'*		byref dimi logoenable2: Numeric - get the option value to display logo-enable/disable
'*		byref dimi logoposition2: Numeric - get the value for logoposition of stream2
'*		byref dimi textenable2: Numeric - get the value for textanable-enable/disable
 *		byref dimi textposition2: Numeric - get the value for textposition of stream2
 *		byref dims overlaytext2$: String - get the overlay text value
 *		byref dimi detailinfo2: Numeric - get the  detail info value
 
 *	Created by:  On 2009-05-11 09:44:52
 ***********************************************************/
function getVideoStream2(byref dimi framerate2, byref dims frameratename2$, byref dimi bitrate2, byref dimi ratecontrol2, byref dimi datestampenable2,_
						 byref dimi timestampenable2, byref dimi logoenable2, byref dimi logoposition2, byref dimi textenable2, byref dimi textposition2,_
						 byref dims overlaytext2$,byref dimi detailinfo2)				'TR-11	
		  
		dims varName$(12)  = ("framerate2", "frameratename2$", "bitrate2", "ratecontrol2", "datestampenable2",_
							 "timestampenable2", "logoenable2", "logoposition2", "textenable2", "textposition2","overlaytext2$","detailinfo2")
	
		dims propName$(12) = ("gframerate2", "gframeratenameall2", "gbitrate2", "gratecontrol2", "gdatestampenable2",_
							   "gtimestampenable2", "glogoenable2", "glogoposition2", "gtextenable2", "gtextposition2","goverlaytext2","gdetailinfo2")
									 
		dims tempVal$(12)
		dimi i,ret
		
		ret=getiniValues(propName$,tempVal$)
		if ret>=0 then
			for i= 0 to ubound(tempVal$)
				if i=1 or i=10 then
					{varName$(i)} = tempVal$(i)
				else 
					{varName$(i)} = strtoint(tempVal$(i))				
				endif
			next
		endif
		
		return ret 
	
End Function


/***********************************************************
'** getVideoStream3
 *	Description: 
		Get video stream 3 values from camera
		
 *	Params:
 *		byref dimi framerate3: Numeric - get the framerate for stream3
 *		byref dims frameratename3$: String - get all possible frame rate options to load drop down
'*		byref dimi bitrate3: Numeric -  get the bitrate value
'*		byref dimi ratecontrol3: Numeric - get the value of ratecontrol for stream3
'*		byref dims livequality: Numeric - get the livequality value
'*		byref dimi datestampenable3: Numeric - get the option value for date-enable/disable
'*		byref dimi timestampenable3: Numeric - get the option value for time-enable/disable
'*		byref dimi logoenable3: Numeric -  get the option value to display logo-enable/disable
'*		byref dimi logoposition3: Numeric - get the value for logoposition of stream3
'*		byref dimi textenable3: Numeric - get the value for textanable-enable/disable
 *		byref dimi textposition3: Numeric - get the value for textposition of stream3
 *		byref dims overlaytext3$: String - get the overlay text value
 *		byref dimi detailinfo3: Numeric - get the  detail info value
 *	Created by:  On 2009-05-11 09:45:02
 ***********************************************************/
function getVideoStream3(byref dimi framerate3, byref dims frameratename3$, byref dimi bitrate3, byref dimi ratecontrol3, _
						 byref dimi livequality, byref dimi datestampenable3, byref dimi timestampenable3,_
						 byref dimi logoenable3, byref dimi logoposition3,_
						 byref dimi textenable3, byref dimi textposition3,byref dims overlaytext3$,_
						 byref dimi detailinfo3)	'TR-02,TR-11	
		
		dims varName$(13)  = ("framerate3","frameratename3$","livequality","bitrate3","ratecontrol3","datestampenable3", "timestampenable3",_
							  "logoenable3", "logoposition3", "textenable3", "textposition3","overlaytext3$",_
							  "detailinfo3")
		dims propName$(13) = ("gframerate3","gframeratenameall3","glivequality","gbitrate2", "gratecontrol2", "gdatestampenable3", "gtimestampenable3",_
							   "glogoenable3", "glogoposition3","gtextenable3", "gtextposition3","goverlaytext3",_
							   "gdetailinfo3")
	
		dims tempVal$(13)
		dimi i,ret
		
		ret=getiniValues(propName$,tempVal$)
		if ret>=0 then
			for i= 0 to ubound(tempVal$)
				if i=1 or i=11 then
					{varName$(i)} = tempVal$(i)					
				else 
					{varName$(i)} = strtoint(tempVal$(i))				
				endif
			next
		endif
		
		return ret 		
	
End Function

/***********************************************************
'** setVideoImageSetting
 *	Description: 
 *		To set the values for video Image setting to camera
 *		
 *	Params:
'*		dimi videocodec: Numeric - set the value for stream type
'*		dimi videocodecmode: Numeric - set the value for codec type 
 *		dimi videocodecres: Numeric - set the value for resolution type
 *		dimi mirctrl: Numeric - set the value for mirror control
 *	Created by:  On 2009-05-11 15:04:26
 ***********************************************************/
function setVideoImageSetting(dimi videocodec,dimi videocodecmode,dimi videocodecres,dimi mirctrl)
	
	dims VideoImageSetting$
	dims responseData$
	dimi ret

	VideoImageSetting$="videocodec="+videocodec+"&videocodeccombo="+videocodecmode+"&videocodecres="+videocodecres+_
					   "&mirctrl="+mirctrl
	
	pprint VideoImageSetting$
	ret = setProperties(VideoImageSetting$, responseData$)

	if ret > 0 then
	
		dims propName$(4) = ("gvideocodec","gvideocodeccombo", "gvideocodecres","gmirctrl")

		dims propVal$(4)
		propVal$(0) = videocodec
		propVal$(1) = videocodecmode
		propVal$(2) = videocodecres			
		propVal$(3) = mirctrl
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret			
End Function


/***********************************************************
'** setVideoStream1
 *	Description: 
 *		To set the Values for Video Stream1
 *		
 *	Params:
'*		dimi framerate1: Numeric - set the framerate for stream1
'*		dimi bitrate1: Numeric -  set the bit rate value
'*		dimi ratecontrol1: Numeric - set the value of ratecontrol for stream1
'*		dimi liveQuality: Numeric - set the value of live quality for stream1
'*		dimi datestampenable1: Numeric - set the option value for date-enable/disable
'*		dimi timestampenable1: Numeric - set the option value for time-enable/disable
'*		dimi logoenable1: Numeric - set the option value to display logo-enable/disable
'*		dimi logoposition1: Numeric - set the value for logoposition of stream1
'*		dimi textenable1: Numeric - set the value for textanable-enable/disable
 *		dimi devicename: Numeric - set the device name	
 *		dimi textposition1: Numeric - set the value for textposition of stream1
'*		dimi encryptvideo: Numeric - set the option for encryptvideo-on/off
'*		dimi localdisplay: Numeric - set the option for encryptvideo-enable/disable
'*		dims overlaytext1$: String - set overlay text value
 *		dimi detailinfo1: Numeric - set the detail info value
 *		dims streamType$: String - Hold stream 1 stream type(JPEG / other stream(H264,MPEG4))
 *	Created by:  On 2009-05-11 15:09:54
 *	History: 
 ***********************************************************/
function setVideoStream1(dimi framerate1,dimi bitrate1,dimi ratecontrol1,dimi liveQuality,dimi datestampenable1,_
						 dimi timestampenable1,dimi logoenable1,dimi logoposition1,dimi textenable1, dims devicename$,_
						 dimi textposition1, dimi encryptvideo,dimi localdisplay, dims overlaytext1$,dimi detailinfo1,dims streamType$)
	
	dims VideoStream1$
	dims responseData$
	dimi ret
	if streamType$ = "JPEG" then
		
		VideoStream1$="framerate1="+framerate1+"&livequality="+liveQuality+_
					  "&datestampenable1="+datestampenable1+"&timestampenable1="+timestampenable1+_
					  "&logoenable1="+logoenable1+"&logoposition1="+logoposition1+"&textenable1="+textenable1+"&title="+devicename$+_
					  "&textposition1="+textposition1+"&encryptvideo="+encryptvideo+"&localdisplay="+localdisplay+"&overlaytext1="+overlaytext1$+_
					  "&detailinfo1="+detailinfo1
	else 
		VideoStream1$="framerate1="+framerate1+"&bitrate1="+bitrate1+"&ratecontrol1="+ratecontrol1+_
					  "&datestampenable1="+datestampenable1+"&timestampenable1="+timestampenable1+_
					  "&logoenable1="+logoenable1+"&logoposition1="+logoposition1+"&textenable1="+textenable1+"&title="+devicename$+_
					  "&textposition1="+textposition1+"&encryptvideo="+encryptvideo+"&localdisplay="+localdisplay+"&overlaytext1="+overlaytext1$+_
					  "&detailinfo1="+detailinfo1
	end if
	pprint VideoStream1$
	ret = setProperties(VideoStream1$, responseData$)
	
	iff find(responseData$,"OK title")>0 then ~title$ = devicename$
	
	if ret > 0 then
	
		dims propName$(15) = ("gframerate1","gbitrate1","gratecontrol1","glivequality"_
							"gdatestampenable1","gtimestampenable1",_
							"glogoenable1","glogoposition1","gtextenable1","gtitle",_
							"gtextposition1","gencryptvideo","glocaldisplay","goverlaytext1","gdetailinfo1")
	
		dims propVal$(15)
		propVal$(0) = framerate1
		propVal$(1) = bitrate1
		propVal$(2) = ratecontrol1
		propVal$(3) = liveQuality
		propVal$(4) = datestampenable1
		propVal$(5) = timestampenable1
		propVal$(6) = logoenable1
		propVal$(7) = logoposition1
		propVal$(8) = textenable1
		propVal$(9) = devicename$
		propVal$(10) = textposition1
		propVal$(11) = encryptvideo
		propVal$(12) = localdisplay		
		propVal$(13) = overlaytext1$
		propVal$(14) = detailinfo1	
		
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret			
	
	
End Function

/***********************************************************
'** setVideoStream2
 *	Description: 
 *			To set the Values for Video Stream2
 *		
 *	Params:
 '*		dimi framerate2: Numeric - set the framerate for stream2
'*		dimi bitrate2: Numeric -  set the bit rate  value
'*		dimi ratecontrol2: Numeric - set the value of ratecontrol for stream2
'*		dimi liveQuality: Numeric - set the value of live quality for stream2
'*		dimi datestampenable2: Numeric - set the option value for date-enable/disable
'*		dimi timestampenable2: Numeric - set the option value for time-enable/disable
'*		dimi logoenable2: Numeric - set the option value to display logo-enable/disable
'*		dimi logoposition2: Numeric - set the value for logoposition of stream2
'*		dimi textenable2: Numeric - set the value for textanable-enable/disable
 *		dimi textposition2: Numeric - set the value for textposition of stream2
'*		dims overlaytext2$: String - set overlay text value
 *		dimi detailinfo2: Numeric - set the detail info value
 *		dims streamType$: String - Hold stream 2 stream type(JPEG / other stream(H264,MPEG4))

 *	Created by:  On 2009-05-11 15:16:10   
 *	History: 
 ***********************************************************/
function setVideoStream2(dimi framerate2,dims bitrate2$,dimi ratecontrol2,dimi liveQuality,dimi datestampenable2,_
						 dimi timestampenable2,dimi logoenable2,dimi logoposition2, dimi textenable2,_
						 dimi textposition2, dims overlaytext2$,dimi detailinfo2,dims streamType$)	
					
	dims VideoStream2$
	dims responseData$
	dimi ret
	if streamType$ = "JPEG" then
		VideoStream2$= "framerate2="+framerate2+"&livequality="+liveQuality+_
					   "&datestampenable2="+datestampenable2+"&timestampenable2="+timestampenable2+_
					   "&logoenable2="+logoenable2+"&logoposition2="+logoposition2+"&textenable2="+textenable2+_
					   "&textposition2="+textposition2+"&overlaytext2="+overlaytext2$+"&detailinfo2="+detailinfo2
	else 
		VideoStream2$= "framerate2="+framerate2+"&bitrate2="+bitrate2$+"&ratecontrol2="+ratecontrol2+_
				   "&datestampenable2="+datestampenable2+"&timestampenable2="+timestampenable2+_
				   "&logoenable2="+logoenable2+"&logoposition2="+logoposition2+"&textenable2="+textenable2+_
	               "&textposition2="+textposition2+"&overlaytext2="+overlaytext2$+"&detailinfo2="+detailinfo2
	end if
	
	ret = setProperties(VideoStream2$, responseData$)
	
	if ret > 0 then
	
		dims propName$(12) = ("gframerate2","gbitrate2","gratecontrol2","glivequality"_
							  "gdatestampenable2","gtimestampenable2",_
							  "glogoenable2","glogoposition2","gtextenable2",_
							  "gtextposition2","goverlaytext2","gdetailinfo2")

		dims propVal$(12)
		propVal$(0)=framerate2
		propVal$(1)=bitrate2$
		propVal$(2)=ratecontrol2
		propVal$(3)=livequality
		propVal$(4)=datestampenable2
		propVal$(5)=timestampenable2
		propVal$(6)=logoenable2
		propVal$(7)=logoposition2
		propVal$(8)=textenable2
		propVal$(9)=textposition2
		propVal$(10)=overlaytext2$
		propVal$(11)=detailinfo2
		
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret			
	
End Function


/***********************************************************
'** setVideoStream3
 *	Description: 
 *			To set the Values for Video Stream3
 *		
 *	Params:
 '*		dimi framerate3: Numeric - set the framerate for stream3
'*		dimi bitrate3: Numeric -  set the bit rate  value
'*		dimi ratecontrol3: Numeric - set the value of ratecontrol for stream3
'*		dimi liveQuality: Numeric - set the value of live quality for stream3
'*		dimi datestampenable3: Numeric - set the option value for date-enable/disable
'*		dimi timestampenable3: Numeric - set the option value for time-enable/disable
'*		dimi logoenable3: Numeric - set the option value to display logo-enable/disable
'*		dimi logoposition3: Numeric - set the value for logoposition of stream3
'*		dimi textenable3: Numeric - set the value for textanable-enable/disable
 *		dimi textposition3: Numeric - set the value for textposition of stream3
'*		dims overlaytext3$: String - set overlay text value
 *		dimi detailinfo3: Numeric - set the detail info value
 *		dims streamType$: String - Hold stream 3 stream type(JPEG / other stream(H364,MPEG4))
 *	Created by:  On 2009-05-11 15:55:09
 ***********************************************************/
function setVideoStream3(dimi framerate3,dims bitrate3$,dimi ratecontrol3,dimi liveQuality,_
						 dimi datestampenable3,dimi timestampenable3,dimi logoenable3,dimi logoposition3,_
						 dimi textenable3,dimi textposition3, dims overlaytext3$,dimi detailinfo3,dims streamType$)
						
	dims VideoStream3$
	dims responseData$
	dimi ret
	
	if streamType$ = "JPEG" then
		VideoStream3$="framerate3="+framerate3+"&livequality="+liveQuality+_
					  "&datestampenable3="+datestampenable3+"&timestampenable3="+timestampenable3+"&logoenable3="+logoenable3+_
					  "&logoposition3="+logoposition3+"&textenable3="+textenable3+_
					  "&textposition3="+textposition3+"&overlaytext3="+overlaytext3$+"&detailinfo3="+detailinfo3
	else 
		VideoStream3$="framerate3="+framerate3+"&bitrate2="+bitrate3$+"&ratecontrol2="+ratecontrol3+_
					  "&datestampenable3="+datestampenable3+"&timestampenable3="+timestampenable3+"&logoenable3="+logoenable3+_
					  "&logoposition3="+logoposition3+"&textenable3="+textenable3+_
					  "&textposition3="+textposition3+"&overlaytext3="+overlaytext3$+"&detailinfo3="+detailinfo3
	end if	
	
	pprint VideoStream3$
			
	ret = setProperties(VideoStream3$, responseData$)
	
	if ret > 0 then
	
		dims propName$(12) = ("gframerate3","gbitrate2","gratecontrol2","glivequality"_
							  "gdatestampenable3","gtimestampenable3",_
							  "glogoenable3","glogoposition3","gtextenable3",_
							  "gtextposition3","goverlaytext3","gdetailinfo3")

		dims propVal$(12)
		propVal$(0)=framerate3
		propVal$(1)=bitrate3$
		propVal$(2)=ratecontrol3
		propVal$(3)=liveQuality
		propVal$(4)=datestampenable3
		propVal$(5)=timestampenable3
		propVal$(6)=logoenable3
		propVal$(7)=logoposition3
		propVal$(8)=textenable3
		propVal$(9)=textposition3
		propVal$(10)=overlaytext3$		
		propVal$(11)=detailinfo3	
		
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret			
End Function


/***********************************************************
'** getVideoImageAdvanced1
 *	Description: 
 *			To get the Values for Video - Advanced setting from camera
 *	Params:
'*		byref dims ipratio1$: String - Get IP ratio value 4 digit number
'*		byref dimi forceiframe1: Numeric - Get forceiframe3 value 
'*		byref dims qpmin1$: String - Get min QP value
'*		byref dims qpmax1$: String - Get max QP value
'*		byref dimi meconfig1: Numeric - To get the value for Encode Preset
'*		byref dims meconfigname$: String - To get the value for Encode Preset drop down values
'*		byref dims packetsize1$: String - To get the packet size value in % Frame data value
'*		byref dimi regionofinterestenable1: Numeric - get the option for enage face detect region
'*		byref dimi str1x1: Numeric - Region parameters x value
'*		byref dimi str1y1: Numeric - Region parameters y value
'*		byref dimi str1w1: Numeric - Region parameters value for width 
'*		byref dimi str1h1: Numeric - Region parameters value for Height
'*		byref dimi str1x2: Numeric - Region parameters x value
'*		byref dimi str1y2: Numeric - Region parameters y value
'*		byref dimi str1w2: Numeric - Region parameters value for width
'*		byref dimi str1h2: Numeric - Region parameters value for Height
'*		byref dimi str1x3: Numeric - Region parameters x value
'*		byref dimi str1y3: Numeric - Region parameters y value
'*		byref dimi str1w3: Numeric - Region parameters value for width
 *		byref dimi str1h3: Numeric - Region parameters value for Height
 *		byref dimi qpinit1: Numeric - Get QP init value
	
 *	Created by:  On 2009-05-11 17:35:48
 *	History: 
 ***********************************************************/
function getVideoImageAdvanced1(byref dims ipratio1$, byref dimi forceiframe1, byref dims qpmin1$,_
								byref dims qpmax1$, byref dimi meconfig1, byref dims meconfigname$, byref dims packetsize1$,_
								byref dimi regionofinterestenable1,_
								byref dimi str1x1, byref dimi str1y1, byref dimi str1w1, byref dimi str1h1,_
								byref dimi str1x2, byref dimi str1y2, byref dimi str1w2, byref dimi str1h2,_
								byref dimi str1x3, byref dimi str1y3, byref dimi str1w3, byref dimi str1h3,_
								byref dimi qpinit1)	'TR-41
								
								
			dims varName$(21)=("ipratio1$","qpmin1$","qpmax1$","meconfigname$","packetsize1$",_
							"forceiframe1","regionofinterestenable1","meconfig1",_
							"str1x1","str1y1","str1w1","str1h1",_
							"str1x2","str1y2","str1w2","str1h2",_
							"str1x3","str1y3","str1w3","str1h3","qpinit1")
								
			dims propName$(21)=("gipratio1","gqpmin1","gqpmax1","gmeconfigname","gpacketsize1",_
								"gforceiframe1","gregionofinterestenable1","gmeconfig1",_
								"gstr1x1","gstr1y1","gstr1w1","gstr1h1",_
								"gstr1x2","gstr1y2","gstr1w2","gstr1h2",_
								"gstr1x3","gstr1y3","gstr1w3","gstr1h3","gqpinit1")
			dims tempVal$(21)
			dimi i,ret
			
			ret=getiniValues(propName$,tempVal$)
			if ret>=0 then
				for i= 0 to ubound(tempVal$)
					if i<=4 then					
						{varName$(i)} = tempVal$(i)		
					else 
						{varName$(i)} = strtoint(tempVal$(i))
					endif
				next
			endif

			return ret 
	
End Function

/***********************************************************
'** getVideoImageAdvanced2
 *	Description: 
 *		To get the Values for VideoImageAdvanced2 setting
 *		
 *	Params:
'*		byref dims ipratio2$: String - to get the IP ratio value 4 digit number
'*		byref dimi forceiframe2: Numeric - to get the value for forceiframe3
'*		byref dims qpmin2$: String - To get the min QP value
'*		byref dims qpmax2$: String - To get the max QP value
'*		byref dimi meconfig2: Numeric - To get the value for Encode Preset
'*		byref dims packetsize2$: String - To get the packet size value in % Frame data value
'*		byref dimi regionofinterestenable2: Numeric - get the option for enage face detect region
'*		byref dimi str2x1: Numeric - Region parameters x value
'*		byref dimi str2y1: Numeric - Region parameters y value
'*		byref dimi str2w1: Numeric - Region parameters value for width 
'*		byref dimi str2h1: Numeric - Region parameters value for Height
'*		byref dimi str2x2: Numeric - Region parameters x value
'*		byref dimi str2y2: Numeric - Region parameters y value
'*		byref dimi str2w2: Numeric - Region parameters value for width
'*		byref dimi str2h2: Numeric - Region parameters value for Height
'*		byref dimi str2x3: Numeric - Region parameters x value
'*		byref dimi str2y3: Numeric - Region parameters y value
'*		byref dimi str2w3: Numeric - Region parameters value for width
 *		byref dimi str2h3: Numeric - Region parameters value for Height
  *		byref dimi qpinit2: Numeric - Get QP init value
 *	Created by:  On 2009-05-11 17:43:36
 *	History: 
 ***********************************************************/
function getVideoImageAdvanced2(byref dims ipratio2$, byref dimi forceiframe2, byref dims qpmin2$, byref dims qpmax2$,_
								byref dimi meconfig2, byref dims packetsize2$, byref dimi regionofinterestenable2,_
								byref dimi str2x1, byref dimi str2y1, byref dimi str2w1, byref dimi str2h1,_
								byref dimi str2x2, byref dimi str2y2, byref dimi str2w2, byref dimi str2h2,_
								byref dimi str2x3, byref dimi str2y3, byref dimi str2w3, byref dimi str2h3, byref dimi qpinit2)	'TR-41
								
			dims varName$(20)=("ipratio2$","qpmin2$","qpmax2$","packetsize2$",_
							"forceiframe2","regionofinterestenable2","meconfig2",_
							"str2x1","str2y1","str2w1","str2h1",_
							"str2x2","str2y2","str2w2","str2h2",_
							"str2x3","str2y3","str2w3","str2h3","qpinit2")
								
			dims propName$(20)=("gipratio2","gqpmin2","gqpmax2","gpacketsize2",_
							"gforceiframe2","gregionofinterestenable2","gmeconfig2",_
							"gstr2x1","gstr2y1","gstr2w1","gstr2h1",_
							"gstr2x2","gstr2y2","gstr2w2","gstr2h2",_
							"gstr2x3","gstr2y3","gstr2w3","gstr2h3","gqpinit2")
							
			dims tempVal$(20)
			dimi i,ret
			
			ret=getiniValues(propName$,tempVal$)
			if ret>=0 then
				for i= 0 to ubound(tempVal$)
					if i<=3 then
						{varName$(i)} = tempVal$(i)						
					else 
						{varName$(i)} = strtoint(tempVal$(i))					
					endif
				next
			endif
			
			return ret 
			
End Function

/***********************************************************
'** getVideoImageAdvanced3
 *	Description: 
 *		To get the Values for VideoImageAdvanced3 setting
 *		
 *	Params:
'*		byref dims ipratio3$: String - to get the IP ratio value 4 digit number
'*		byref dimi forceiframe3: Numeric - to get the value for forceiframe3
'*		byref dims qpmin3$: String - To get the min QP value
'*		byref dims qpmax3$: String - To get the max QP value
'*		byref dimi meconfig3: Numeric - To get the value for  Encode Preset
'*		byref dims packetsize3$: String - To get the packet size value in % Frame data value
'*		byref dimi umv3: Numeric - get UMV option 
'*		byref dimi intraPframe3: Numeric - sget the infra in P frame
'*		byref dimi regionofinterestenable3: Numeric - get the option for enage face detect region
'*		byref dimi str3x1: Numeric - Region parameters x value
'*		byref dimi str3y1: Numeric - Region parameters y value
'*		byref dimi str3w1: Numeric - Region parameters value for width 
'*		byref dimi str3h1: Numeric - Region parameters value for Height
'*		byref dimi str3x2: Numeric - Region parameters x value
'*		byref dimi str3y2: Numeric - Region parameters y value
'*		byref dimi str3w2: Numeric - Region parameters value for width
'*		byref dimi str3h2: Numeric - Region parameters value for Height
'*		byref dimi str3x3: Numeric - Region parameters x value
'*		byref dimi str3y3: Numeric - Region parameters y value
'*		byref dimi str3w3: Numeric - Region parameters value for width
 *		byref dimi str3h3: Numeric - Region parameters value for Height
  *		byref dimi qpinit3: Numeric - Get QP init value
 *	Created by:  On 2009-05-11 17:47:28
 *	History: 
 ***********************************************************/
function getVideoImageAdvanced3(byref dimS ipratio3$, byref dimi forceiframe3, byref dimS qpmin3$, byref dimS qpmax3$, byref dimi meconfig3,_
								byref dims packetsize3$, byref dimi regionofinterestenable3,_
								byref dimi str3x1, byref dimi str3y1, byref dimi str3w1, byref dimi str3h1,_
								byref dimi str3x2, byref dimi str3y2, byref dimi str3w2, byref dimi str3h2,_
								byref dimi str3x3, byref dimi str3y3, byref dimi str3w3, byref dimi str3h3, byref dimi qpinit3)	'TR-41
			
			dims varName$(20)=("ipratio3$","qpmin3$","qpmax3$","packetsize3$",_
							"forceiframe3","regionofinterestenable3","meconfig3",_
							"str3x1","str3y1","str3w1","str3h1",_
							"str3x2","str3y2","str3w2","str3h2",_
							"str3x3","str3y3","str3w3","str3h3","qpinit3")
								
			dims propName$(20)=("gipratio3","gqpmin3","gqpmax3","gpacketsize3",_
							"gforceiframe3","gregionofinterestenable3","gmeconfig3",_
							"gstr3x1","gstr3y1","gstr3w1","gstr3h1",_
							"gstr3x2","gstr3y2","gstr3w2","gstr3h2",_
							"gstr3x3","gstr3y3","gstr3w3","gstr3h3","gqpinit3")
							
			dims tempVal$(20)
			dimi i,ret
			
			ret=getiniValues(propName$,tempVal$)
			if ret>=0 then
				for i= 0 to ubound(tempVal$)
					if i<=3 then
						{varName$(i)} = tempVal$(i)						
					else 
						{varName$(i)} = strtoint(tempVal$(i))						
					endif
				next
			endif
			
			return ret 					
	
End Function

/***********************************************************
'** setVideoImageAdvanced1
 *	Description: 
 *		To set the Values for Video Advanced 1 setting
 *		
 *	Params:
'*		dims ipratio1$: String - to set the IP ratio value 4 digit number
'*		dimi forceiframe1: Numeric - to set the value for forceiframe3
'*		dims qpmin1$: String - To set the min QP value
'*		dims qpmax1$: String - To set the max QP value
'*		dims qpinit1$: String - set QP init value
'*		dimi meconfig1: Numeric - To set the value for  Encode Preset
'*		dims packetsize1$: String - To set the packet size value in % Frame data value
'*		dimi regionofinterestenable1: Numeric - set the option for enage face detect region
'*		dimi str1x1: Numeric - Region parameters x value
'*		dimi str1y1: Numeric - Region parameters y value
'*		dimi str1w1: Numeric - Region parameters value for width 
'*		dimi str1h1: Numeric - Region parameters value for Height
'*		dimi str1x2: Numeric - Region parameters x value
'*		dimi str1y2: Numeric - Region parameters y value
'*		dimi str1w2: Numeric - Region parameters value for width
'*		dimi str1h2: Numeric - Region parameters value for Height
'*		dimi str1x3: Numeric - Region parameters x value
'*		dimi str1y3: Numeric - Region parameters y value
'*		dimi str1w3: Numeric - Region parameters value for width
 *		dimi str1h3: Numeric - Region parameters value for Height
 *	Created by:  On 2009-05-11 20:05:42
 *	History: 
 ***********************************************************/
function setVideoImageAdvanced1(dims ipratio1$, dimi forceiframe1, dims qpmin1$, dims qpmax1$, dims  qpinit1$,_
								dimi meconfig1, dims packetsize1$, dimi regionofinterestenable1,_
								dimi str1x1, dimi str1y1, dimi str1w1, dimi str1h1,_
								dimi str1x2, dimi str1y2, dimi str1w2, dimi str1h2,_
								dimi str1x3, dimi str1y3, dimi str1w3, dimi str1h3)					'TR-41

	dims VideoImageAdvanced1$
	dims responseData$
	dimi ret
	VideoImageAdvanced1$="ipratio1="+ipratio1$+"&forceiframe1="+forceiframe1+"&qpmin1="+qpmin1$+"&qpmax1="+qpmax1$+"&qpinit1="+qpinit1$+_
								"&meconfig1="+meconfig1+"&packetsize1="+packetsize1$+"&regionofinterestenable1="+regionofinterestenable1+_
								"&str1x1="+str1x1+"&str1y1="+str1y1+"&str1w1="+str1w1+"&str1h1="+str1h1+_
								"&str1x2="+str1x2+"&str1y2="+str1y2+"&str1w2="+str1w2+"&str1h2="+str1h2+_
								"&str1x3="+str1x3+"&str1y3="+str1y3+"&str1w3="+str1w3+"&str1h3="+str1h3+""
	pprint VideoImageAdvanced1$
	
	ret = setProperties(VideoImageAdvanced1$, responseData$)

	if ret > 0 then
	
		dims propName$(20) = ("gipratio1","gforceiframe1","gqpmin1","gqpmax1","gqpinit1"_
							  "gmeconfig1","gpacketsize1","gregionofinterestenable1",_
							  "gstr1x1","gstr1y1","gstr1w1","gstr1h1",_
							  "gstr1x2","gstr1y2","gstr1w2","gstr1h2",_
							  "gstr1x3","gstr1y3","gstr1w3","gstr1h3")

		dims propVal$(20)
		propVal$(0)=ipratio1$               
		propVal$(1)=forceiframe1            
		propVal$(2)=qpmin1$                 
		propVal$(3)=qpmax1$                 
		propVal$(4)=qpinit1$             
		propVal$(5)=meconfig1               
		propVal$(6)=packetsize1$              
		propVal$(7)=regionofinterestenable1 
		propVal$(8)=str1x1                  
		propVal$(9)=str1y1                  
		propVal$(10)=str1w1                  
		propVal$(11)=str1h1                  
		propVal$(12)=str1x2                  
		propVal$(13)=str1y2                  
		propVal$(14)=str1w2                  
		propVal$(15)=str1h2                  
		propVal$(16)=str1x3                  
		propVal$(17)=str1y3                  
		propVal$(18)=str1w3                  
		propVal$(19)=str1h3 
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret		
	
End Function
/***********************************************************
'** setVideoImageAdvanced2
 *	Description: 
 *		To set the Values for Video Advanced 2 setting
 *		
 *	Params:
'*		dims ipratio2$: String - to set the IP ratio value 4 digit number
'*		dimi forceiframe2: Numeric - to set the value for forceiframe3
'*		dims qpmin2$: String - To set the min QP value
'*		dims qpmax2$: String - To set the max QP value
'*		dims qpinit2$: String - set QP init value
'*		dimi meconfig2: Numeric - To set the value for  Encode Preset
'*		dims packetsize2$: String - To set the packet size value in % Frame data value
'*		dimi regionofinterestenable2: Numeric - set the option for enage face detect region
'*		dimi str2x1: Numeric - Region parameters x value
'*		dimi str2y1: Numeric - Region parameters y value
'*		dimi str2w1: Numeric - Region parameters value for width 
'*		dimi str2h1: Numeric - Region parameters value for Height
'*		dimi str2x2: Numeric - Region parameters x value
'*		dimi str2y2: Numeric - Region parameters y value
'*		dimi str2w2: Numeric - Region parameters value for width
'*		dimi str2h2: Numeric - Region parameters value for Height
'*		dimi str2x3: Numeric - Region parameters x value
'*		dimi str2y3: Numeric - Region parameters y value
'*		dimi str2w3: Numeric - Region parameters value for width
 *		dimi str2h3: Numeric - Region parameters value for Height
 *	Created by:  On 2009-05-11 20:05:42
 *	History: 
 ***********************************************************/
function setVideoImageAdvanced2(dims ipratio2$, dimi forceiframe2, dims qpmin2$, dims qpmax2$, dims qpinit2$,_
								dimi meconfig2, dims packetsize2$, dimi regionofinterestenable2,_
								dimi str2x1, dimi str2y1, dimi str2w1, dimi str2h1,_
								dimi str2x2, dimi str2y2, dimi str2w2, dimi str2h2,_
								dimi str2x3, dimi str2y3, dimi str2w3, dimi str2h3)	'TR-41
	dims VideoImageAdvanced2$
	dims responseData$
	dimi ret
	VideoImageAdvanced2$="ipratio2="+ipratio2$+"&forceiframe2="+forceiframe2+"&qpmin2="+qpmin2$+"&qpmax2="+qpmax2$+"&qpinit2="+qpinit2$+_
								"&meconfig2="+meconfig2+"&packetsize2="+packetsize2$+"&regionofinterestenable2="+regionofinterestenable2+_
								"&str2x1="+str2x1+"&str2y1="+str2y1+"&str2w1="+str2w1+"&str2h1="+str2h1+_
								"&str2x2="+str2x2+"&str2y2="+str2y2+"&str2w2="+str2w2+"&str2h2="+str2h2+_
								"&str2x3="+str2x3+"&str2y3="+str2y3+"&str2w3="+str2w3+"&str2h3="+str2h3+""
	
	pprint VideoImageAdvanced2$				
					
	ret = setProperties(VideoImageAdvanced2$, responseData$)

	if ret > 0 then
	
		dims propName$(20) = ("gipratio2","gforceiframe2","gqpmin2","gqpmax2","gqpinit2"_
							  "gmeconfig2","gpacketsize2","gregionofinterestenable2",_
							  "gstr2x1","gstr2y1","gstr2w1","gstr2h1",_
							  "gstr2x2","gstr2y2","gstr2w2","gstr2h2",_
							  "gstr2x3","gstr2y3","gstr2w3","gstr2h3")

		dims propVal$(20)
		propVal$(0)=ipratio2$                  
		propVal$(1)=forceiframe2            
		propVal$(2)=qpmin2$                 
		propVal$(3)=qpmax2$                 
		propVal$(4)=qpinit2$        
		propVal$(5)=meconfig2               
		propVal$(6)=packetsize2$ 
		propVal$(7)=regionofinterestenable2 
		propVal$(8)=str2x1                  
		propVal$(9)=str2y1                  
		propVal$(10)=str2w1                  
		propVal$(11)=str2h1                  
		propVal$(12)=str2x2                  
		propVal$(13)=str2y2                  
		propVal$(14)=str2w2                  
		propVal$(15)=str2h2                  
		propVal$(16)=str2x3                  
		propVal$(17)=str2y3                  
		propVal$(18)=str2w3                  
		propVal$(19)=str2h3                                   
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret		
				
End Function 

/***********************************************************
'** setVideoImageAdvanced3
 *	Description: 
 *		To set the Values for VideoImageAdvanced3 setting
 *		
 *	Params:
'*		dims ipratio3$: String - to set the IP ratio value 4 digit number
'*		dimi forceiframe3: Numeric - to set the value for forceiframe3
'*		dims qpmin3$: String - To set the min QP value
'*		dims qpmax3$: String - To set the max QP value
'*		dims qpinit3$: String - set QP init value
'*		dimi meconfig3: Numeric - To set the value for  Encode Preset
'*		dims packetsize3$: String - To set the packet size value in % Frame data value
'*		dimi regionofinterestenable3: Numeric - set the option for enage face detect region
'*		dimi str3x1: Numeric - Region parameters x value
'*		dimi str3y1: Numeric - Region parameters y value
'*		dimi str3w1: Numeric - Region parameters value for width 
'*		dimi str3h1: Numeric - Region parameters value for Height
'*		dimi str3x2: Numeric - Region parameters x value
'*		dimi str3y2: Numeric - Region parameters y value
'*		dimi str3w2: Numeric - Region parameters value for width
'*		dimi str3h2: Numeric - Region parameters value for Height
'*		dimi str3x3: Numeric - Region parameters x value
'*		dimi str3y3: Numeric - Region parameters y value
'*		dimi str3w3: Numeric - Region parameters value for width
 *		dimi str3h3: Numeric - Region parameters value for Height
 *	Created by:  On 2009-05-19 12:08:27
 ***********************************************************/

function setVideoImageAdvanced3(dims ipratio3$, dimi forceiframe3, dims qpmin3$, dims qpmax3$,dims qpinit3$, _
								dimi meconfig3, dims packetsize3$, dimi regionofinterestenable3,_
								dimi str3x1, dimi str3y1, dimi str3w1, dimi str3h1,_
								dimi str3x2, dimi str3y2, dimi str3w2, dimi str3h2,_
								dimi str3x3, dimi str3y3, dimi str3w3, dimi str3h3)	'TR-41
			
	dims VideoImageAdvanced3$
	dims responseData$
	dimi ret
	VideoImageAdvanced3$="ipratio3="+ipratio3$+"&forceiframe3="+forceiframe3+"&qpmin3="+qpmin3$+"&qpmax3="+qpmax3$+"&qpinit3="+qpinit3$+_
								"&meconfig3="+meconfig3+"&packetsize3="+packetsize3$+"&regionofinterestenable3="+regionofinterestenable3+_
								"&str3x1="+str3x1+"&str3y1="+str3y1+"&str3w1="+str3w1+"&str3h1="+str3h1+_
								"&str3x2="+str3x2+"&str3y2="+str3y2+"&str3w2="+str3w2+"&str3h2="+str3h2+_
								"&str3x3="+str3x3+"&str3y3="+str3y3+"&str3w3="+str3w3+"&str3h3="+str3h3+""
	pprint VideoImageAdvanced3$
					
					
	ret = setProperties(VideoImageAdvanced3$, responseData$)

	if ret > 0 then
	
		dims propName$(20) = ("gipratio3","gforceiframe3","gqpmin3","gqpmax3","gqpinit3"_
							  "gmeconfig3","gpacketsize3","gregionofinterestenable3",_
							  "gstr3x1","gstr3y1","gstr3w1","gstr3h1",_
							  "gstr3x2","gstr3y2","gstr3w2","gstr3h2",_
							  "gstr3x3","gstr3y3","gstr3w3","gstr3h3")
		dims propVal$(20)
		propVal$(0)=ipratio3$                  
		propVal$(1)=forceiframe3            
		propVal$(2)=qpmin3$                 
		propVal$(3)=qpmax3$                 
		propVal$(4)=qpinit3$            
		propVal$(5)=meconfig3               
		propVal$(6)=packetsize3$      
		propVal$(7)=regionofinterestenable3 
		propVal$(8)=str3x1                  
		propVal$(9)=str3y1                  
		propVal$(10)=str3w1                  
		propVal$(11)=str3h1                  
		propVal$(12)=str3x2                  
		propVal$(13)=str3y2                  
		propVal$(14)=str3w2                  
		propVal$(15)=str3h2                  
		propVal$(16)=str3x3                  
		propVal$(17)=str3y3                  
		propVal$(18)=str3w3                  
		propVal$(19)=str3h3                                   
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret		
								
End Function 




/***********************************************************
'** getAudioSetting
 *	Description: To get audio setting screen values
 *		
 *		
 *	Params:
'*		byref dimi enableAudio: Numeric - Check to enable/disable audio.
'*		byref dimi audioMode: Numeric - Audio Mode
'*		byref dimi inputVolume: Numeric - Value ranges between 1 and 100.
'*		byref dimi encoding: Numeric - Encoding
'*		byref dimi sampleRate: Numeric - Sample Rate
 *		byref dimi bitRate: Numeric - Bit Rate
 *		byref dimi alarmLevel: Numeric - Value ranges between 1 and 100
 *		byref dimi outputVolume Numeric - Value ranges between 1 and 100.
 *	Created by: vimala On 2009-05-11 21:59:09
 ***********************************************************/
function getAudioSetting(byref dimi enableAudio, byref dimi audioMode, byref dimi inputVolume, _
						 byref dimi encoding, byref dimi sampleRate, byref dimi bitRate, _
						 byref dimi alarmLevel, byref dimi outputVolume)
	'TR-26					 
	dims varName$(8)  = ("enableAudio","audioMode","inputVolume", _
						  "encoding","sampleRate","bitRate", _
						  "alarmLevel","outputVolume") 

						  
	dims propName$(8) = ("gaudioenable","gaudiomode","gaudioinvolume", _
						 "gencoding","gsamplerate","gaudiobitrate", _
						 "galarmlevel","gaudiooutvolume")
		
	dims tempVal$(8)
	dimi i,retVal
	
	retVal = getiniValues(propName$,tempVal$)	
	
	if retVal = 0 then
			
		for i= 0 to ubound(tempVal$)	
			
			{varName$(i)} = strtoint(tempVal$(i))		
			
		next
		
	endif
	
	return retVal	
	
End Function



/***********************************************************
'** getAudioOptions
 *	Description: 
 *		Get drop down values for audio setting
 *		
 *	Params:
 *		byref dims audioMode$: String array - Audio mode drop down option
 *		byref dims encoding$: String array - Encoding drop down option
 *      byref dims sampleRate$: String array - Sample Rate drop down option
 *		byref dims bitRate$: String array- Bit Rate drop down option *
 *	Created by: vimala On 2009-05-11 22:03:36
 ***********************************************************/
function getAudioOptions( byref dims audioMode$(), byref dims encoding$(), _
						  byref dims sampleRate$(), byref dims bitRate$())
	
	dims varName$(4)  = ("audioMode$","encoding$","sampleRate$","bitRate$")
	dims propName$(4) = ("gaudiomodename","gencodingname","gsampleratename","gaudiobitratename")
	dims tempVal$(4)
	dimi idx, splitidx, retVal,sptCount
	dims optionValue$, splitChar$
	
	retVal = getIniValues(propName$, tempVal$)
	
	if retVal = 0 then
		
		for idx = 0 to ubound(tempVal$)
			
			splitChar$ = ";"
			sptCount = split(optionValue$, tempVal$(idx), splitChar$)
			iff sptCount > 0 then redim {varName$(idx)}(sptCount)
			
			for splitidx = 0 to sptCount-1
				{varName$(idx)}(splitidx) = optionValue$(splitidx)
			next
			
		next
		
	endif
	
	return retVal
	
End Function


/***********************************************************
'** setAudioSetting
 *	Description: 
 *		To set the values for Audio Setting to camera
 *		
 *	Params:
'*		dimi enableAudio: Numeric - Enable audio value(0/1)
'*		dimi audioMode: Numeric - Audio Mode selected value
'*		dimi inputVolume: Numeric - Value ranges between 1 and 100.
'*		dimi encoding: Numeric - Encoding selected value
'*		dimi sampleRate: Numeric - Sample Rate selected value	
'*		dimi bitRate: Numeric - Bit Rate selected value	
'*		dimi alarmLevel: Numeric - Value ranges between 1 and 100
 *		dimi outputVolume Numeric - Value ranges between 1 and 100.
 *	Created by:  vimala On 2009-05-11 06:55:30
 ***********************************************************/
function setAudioSetting(dimi enableAudio, dimi audioMode, dimi inputVolume, _
						 dimi encoding, dimi sampleRate, dimi bitRate, _
						 dimi alarmLevel, dimi outputVolume)	
	dimi ret
	dims value$
	dims responseData$
	' TR-26
	value$ = "audioenable="+enableAudio+"&audiomode="+audioMode+"&audioinvolume="+inputVolume+_
			 "&encoding="+encoding+"&samplerate="+sampleRate+"&audiobitrate="+bitRate+_
			 "&alarmlevel="+alarmLevel+"&audiooutvolume="+outputVolume
	pprint value$		 
	ret = setProperties(value$, responseData$)	
	
	if ret > 0 then
		
		dims propName$(8) = ("gaudioenable","gaudiomode","gaudioinvolume", _
							 "gencoding","gsamplerate","gaudiobitrate", _
							 "galarmlevel","gaudiooutvolume")
		dims propVal$(8)
		
		propVal$(0) = enableAudio
		propVal$(1) = audioMode
		propVal$(2) = inputVolume
		propVal$(3) = encoding
		propVal$(4) = sampleRate
		propVal$(5) = bitRate
		propVal$(6) = alarmLevel
		propVal$(7) = outputVolume
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret				
						
End Function


/***********************************************************
'** setLiveVideoOptions
 *	Description: 
 *		To set the Values for click snap user input controls
 *		
 *	Params:
'*		dims clicksnapfilename$: String - click snap file name
 *		dimi clicksnapstorage: Numeric - click snap storage option value
 *	Created by:  On 2009-05-20 11:07:09
 ***********************************************************/
function setLiveVideoOptions(dims clicksnapfilename$, dimi clicksnapstorage)
	
	dimi ret
	dims value$
	dims responseData$
	
	value$ = "clicksnapfilename="+clicksnapfilename$+"&clicksnapstorage="+clicksnapstorage+""

	ret = setProperties(value$, responseData$)

	if ret > 0 then
		
		dims propName$(2) = ("gclicksnapfilename","gclicksnapstorage")
		
		dims propVal$(8)
		
		propVal$(0) = clicksnapfilename$
		propVal$(1) = clicksnapstorage
		
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
		
	endif 
	
	return ret	
	
End Function



/***********************************************************
'** getStreamDisplayOrder
 *	Description: Get stream avaiable stream name feom camera
 *		
 *	Params:
'*		byref dimi videocodec: Numeric - selected codec type(single,dual,triple)
'*		byref dims streamName1$: String - Stream name 1
'*		byref dims streamName2$: String - Stream name 2
'*		byref dims streamName3$: String - Stream name 3
 *	Created by: Vimala On 2010-01-13 02:21:31
 ***********************************************************/
function getStreamDisplayOrder(byref dimi videocodec,byref dims streamName1$,_
							   byref dims streamName2$, byref dims streamName3$,byref dims streamName4$)					
	dims varName$(5) = ("videocodec","streamName1$","streamName2$","streamName3$","streamName4$")	
	dims propName$(5) = ("gvideocodec","gstreamname1","gstreamname2","gstreamname3","gstreamname4")
	
	dims tempVal$(5)
	dimi i,retVal	
		
	retVal = getiniValues(propName$,tempVal$)	
	
	if retVal = 0 then
			
		for i= 0 to ubound(tempVal$)
			if i = 0 then
				{varName$(i)} = strtoint(tempVal$(i))
			else 
				{varName$(i)} = tempVal$(i)			
			end if
		next
	
		
	endif
	
	return retVal										
	
End Function


/***********************************************************
'** getSupportData
 *	Description: 
 *		To get the Version Number for the params from the ini.htm
 *		
 *	Params:
'*		byref Dims kernelVersion: Numeric - retrieve the Version Number 
'*		byref Dims UbootVersion: Numeric - retrieve the Version Number
'*		byref Dims SoftwareVersion: Numeric - retrieve the Version Number
'*		byref Dims ActiveXVersion: Numeric - retrieve the Version Number
 *		byref Dims GUIVersion: Numeric - retrieve the Version Number
 *	Created by: Franklin Jacques.k On 2009-10-08 11:28:28
 ***********************************************************/
function getSupportData(byref Dims kernelVersion$, byref Dims UbootVersion$, byref Dims SoftwareVersion$)
	
	dims varName$(3)=("kernelVersion$", "UbootVersion$", "SoftwareVersion$")
	dims propName$(3)=("gkernelversion", "gbiosversion", "gsoftwareversion")
	dims tempVal$(3)
	dimi i,retVal
	
	retVal = getiniValues(propName$,tempVal$)	
	
	if retVal = 0 then
			
		for i= 0 to ubound(tempVal$)
			{varName$(i)} = tempVal$(i)
		next
		
	endif
	
	return retVal
	
End Function


/***********************************************************
'** getSDCardValue
 *	Description: Get SD card insert status from camera
					0: SD card is not inserted.
					1: SD card is inserted, but not mounted
					3: SD card is inserted & mounted
 *	Params:
 *		byref Dims sdInsertVal$: String - SD card inserted value 
 *	Created by:  On 2009-10-19 12:25:29
 *	History: 
 ***********************************************************/
Function getSDCardValue(byref Dims sdInsertVal$)
	dimi ret 
		
	ret=HTTPDNLD(~camAddPath$+"vb.htm?paratest=sdinsert", "","test1.txt",2,SUPRESSUI,~authHeader$,,,sdInsertVal$)
	
	if ret > 0 then
		return ret
	else
		return -10	
	end if 
	
	
End Function


/***********************************************************
'** setExampleValue
 *	Description: Set example value to camera
 *		
 *	Params:
 *		byref Dimi democfg: Numeric - Example drop down selected value 	 
 *	Created by: Vimala On 2009-12-15 00:26:47
 ***********************************************************/
Function setExampleValue(dimi democfg)
	dimi ret
	dims responseData$, data$ 
	data$ = "democfg="+democfg
	ret = setProperties(data$, responseData$)
	
	if ret > 0 then				
		dims propName$(1) = ("gdemocfg")
		
		dims propVal$(1)
		propVal$(0) = democfg
				
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
					
	endif 
	
	return ret
		
End Function

/***********************************************************
'** getVideoFile
 *	Description: Call this function to get the values of video file section
 
 *	Params:
'*		videoStream: Numeric - Stream selected value
'*		videoStreamName$: String - Stream drop down values
'*		videoSize: Numeric - Video size selected value
 *		VideoSize$: String - Video size drop down
 *	Created by: vimala On 2009-12-15 03:11:55
 *	History: 
 ***********************************************************/
Function getVideoFile(byref dimi videoStream,byref dims videoStreamName$(),byref dimi videoSize,byref dims VideoSize$())				'TR-31
	dims varName$(4)  = ("videoStreamName$","VideoSize$","videoStream","videoSize")
	dims propName$(4) = ("gaviformatname","gavidurationname","gaviformat","gaviduration")
	
	dims tempVal$(4)
	dimi idx, splitidx, retVal,sptCount	
	dims optionValue$, splitChar$
	
	retVal = getIniValues(propName$, tempVal$)
	
	if retVal = 0 then
		
		for idx= 0 to ubound(tempVal$)
			
			if idx = 0 or idx =1 then
				splitChar$ = ";"
				sptCount = split(optionValue$, tempVal$(idx), splitChar$)
				iff sptCount>0 then redim {varName$(idx)}(sptCount)
				
				for splitidx = 0 to sptCount-1
					{varName$(idx)}(splitidx) = optionValue$(splitidx)
				next
				
			else 
				{varName$(idx)} = strtoint(tempVal$(idx))
			end if
			
		next
		
	endif
	
	return retVal
End Function



/***********************************************************
'** setVideoFile
 *	Description: Call this function to Set the values of video file section
 *		
 *		
 *	Params:
'*		dimi videoStream: Numeric - Video stream selected value
 *		dimi videoSize: Numeric - video size selected value
 *	Created by: Vimala On 2010-05-04 14:51:03
 *	History: 
 ***********************************************************/
Function setVideoFile(dimi videoStream, dimi videoSize)	
	dimi ret
	dims responseData$, data$ 
	data$ = "aviformat="+videoStream+"&aviduration="+videoSize
	pprint data$
	ret = setProperties(data$, responseData$)
	
	if ret > 0 then				
		dims propName$(2) = ("gaviformatname","gaviduration")
		
		dims propVal$(2)
		propVal$(0) = videoStream
		propVal$(1) = videoSize
				
		~errorKeywords$ = ""
		~errorKeywords$ =  chkRetStatusAndUpdate$(responseData$,propName$,propVal$)
		
		if len(~errorKeywords$) > 0 then
			return -10
		else
			return ret
		endif		
					
	endif 
	
	return ret
		
End Function


/***********************************************************
'** getLoadingTime
 *	Description: Call this function to get the reload time from IPNC
 *		
 *		
 *	Params:
 *		reloadTime: Numeric - IPNC reload time
 *	Created by: Vimala On 2010-01-05 06:20:36
 *	History: 
 ***********************************************************/
Function getLoadingTime(byref dimi reloadTime)   'TR-40
	dims propName$(1) = ("greloadtime")
	dims tempVal$(1)	
	dimi retVal
	
	retVal = getIniValues(propName$, tempVal$)
	
	if retVal = 0 then
		reloadTime = strtoint(tempVal$(0))
	endif
	
	return retVal
End Function


/***********************************************************
'** setDeleteSchedule$
 *	Description: Call this function to delete all the schedules
 *		
 *	Created by: Vimala On 2010-05-04 14:52:13
  ***********************************************************/
Sub setDeleteSchedule$()	
	dimi ret
	dims responseData$, data$ 
	data$ = "delschedule=1"
	pprint data$
	ret = setProperties(data$, responseData$)	
End Sub



/***********************************************************
'** getReloadFlag
 *	Description: Call this function to fetch reloadflag from IPNC
 
 *	Created by: Vimala On 2010-04-13 18:32:14
  ***********************************************************/
function getReloadFlag()	'TR-45		
	getReloadFlag = -1
	dimi retVal
	dims responseData$
	
	retVal=HTTPDNLD(~camAddPath$+"vb.htm?paratest=reloadflag", "","test1.txt",2,SUPRESSUI,~authHeader$,,,responseData$)
	
	if retVal >= 0 then
		pprint responseData$
		getReloadFlag = atol(repl$(responseData$,"OK reloadflag=",""))
	endif
	
	pprint "getReloadFlag = " + getReloadFlag
		
End Function



/***********************************************************
'** getDMVAEnableValue
 *	Description: Call this function to get dmva enable value from camera
 *				 Enable Smart Analytics in the left menu only if the flag "dmvaenable" = 1 
 *	Created by:Vimala  On 2010-05-24 10:53:08
 *	History: 
 ***********************************************************/
function getDMVAEnableValue()	
	getDMVAEnableValue = -1
	dimi retVal
	dims responseData$
	
	retVal=HTTPDNLD(~camAddPath$+"vb.htm?paratest=dmvaenable", "","test1.txt",2,SUPRESSUI,~authHeader$,,,responseData$)
	
	if retVal >= 0 then
		pprint responseData$
		getDMVAEnableValue = atol(repl$(responseData$,"OK dmvaenable=",""))
	endif
	
	pprint "dmvaenable = " + getDMVAEnableValue
	
End Function



Function getRecordDate(byref Dims recordDate$,byref Dims responeRecordDate$)
	dimi ret 
		
	'ret=HTTPDNLD(~camAddPath$+"vb.htm?paratest=sdinsert", "","test1.txt",2,SUPRESSUI,~authHeader$,,,sdInsertVal$)
	ret=HTTPDNLD(~camAddPath$+"vb.htm?pbrechourdata="+recordDate$, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeRecordDate$)
	if ret > 0 then
		return ret
	else
		return -10	
	end if 
	
	
End Function


/***********************************************************
'** setRS232Details
 *	Description: Sets the Network details for Network setting
 *	Returns 0 for Success; -1 failure	
  
 *	Params:
'*   	dims ip$ : String  - Holds ip address value
'*  	dims netmask$ : String - Holds netmask value
'*   	dims defaultGWay$ : Numeric - Holds default gateway value 
'*  	dims priNameServer$ : String - Holds primary name server value
'*  	dimi httpPort : Numeric - Holds http Port value
'*   	dimi dhcpenable : Numeric - Holds dhcp enable value
 *	Created by: Franklin Jacques On 2009-02-27 12:27:58
 ***********************************************************/
 
function setRS232Details(dims buadrate$, dims databit$, dims stopbit$, _
						   dimi paritycheck,dimi streamcontrol,dimi applyto,dimi devicenum)				'BFIX-02
	dims RS232details$
	dims responsedata$
	dimi ret
	'DHCP is enabled then no need to set network setting values
	
	RS232details$="rs232="+devicenum+"@"+buadrate$+"@"+paritycheck+"@"+databit$+"@"+stopbit$+"@"+streamcontrol
	
//	msgbox(RS232details$)
	ret = setProperties(RS232details$, responseData$)	
	

	return ret				
	
End Function







/***********************************************************
'** setRS485Details
 *	Description: Sets the Network details for Network setting
 *	Returns 0 for Success; -1 failure	
  
 *	Params:
'*   	dims ip$ : String  - Holds ip address value
'*  	dims netmask$ : String - Holds netmask value
'*   	dims defaultGWay$ : Numeric - Holds default gateway value 
'*  	dims priNameServer$ : String - Holds primary name server value
'*  	dimi httpPort : Numeric - Holds http Port value
'*   	dimi dhcpenable : Numeric - Holds dhcp enable value
 *	Created by: Franklin Jacques On 2009-02-27 12:27:58
 ***********************************************************/
function setRS485Details(dims buadrate$, dims databit$, dims stopbit$, _
						   dims paritycheck$,dims streamcontrol$,dims decoderaddr$,dims devicenum$,dims channelnum$)				'BFIX-02
	dims RS485details$
	dims responsedata$
	dimi ret
	
	RS485details$="rs485="+devicenum$+"@"+channelnum$+"@"+decoderaddr$+"@ch0@"+buadrate$+"@"+paritycheck$+"@"+databit$+"@"+stopbit$+"@"+streamcontrol$
	msgbox(RS485details$)
	ret = setProperties(RS485details$, responseData$)	
	

	return ret				
	
End Function


//add by wbb
function setPTZDetails(dims buadrate$, dims databit$, dims stopbit$, _
						   dims paritycheck$,dims streamcontrol$,dims decoderaddr$,dims devicenum$,dims channelnum$)				'BFIX-02
	dims PTZdetails$
	dims responsedata$
	dimi ret
	
	PTZdetails$="setPtz="+channelnum$+"@"+decoderaddr$+"@0@"+devicenum$+"@"+buadrate$+"@"+paritycheck$+"@"+databit$+"@"+stopbit$+"@"+streamcontrol$
//	msgbox(PTZdetails$)
	ret = setProperties(PTZdetails$, responseData$)	

	return ret				
	
End Function

/***********************************************************
'** getRS232Details
 *	Description: 
 *		Provides the Network values for Network settings
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dims ip: Numeric - IP Address
'*		byref dims netmask: Numeric - Netmask
'*		byref dims defaultGWay: Numeric - Default Gateway
'*		byref dims priNameServer: Numeric - Primary Name server
 *		byref dimi httpPort: Numeric - Http port
 *	Created by: Franklin Jacques On 2009-02-27 12:24:47
 ***********************************************************/
function getRS232Details(byref dims buadrate$, byref dims databit$, byref dims stopbit$, _
						   byref dims paritycheck$, byref dims  streamcontrol$, byref dims applyto$,byref dims devicenum$)
	dimi ret				
	dims varName$(7)  = ("buadrate$", "databit$", "stopbit$", "paritycheck$", "streamcontrol$", "applyto$","devicenum$")
	dims propName$(7) = ("gRS232buadrate", "gRS232databit", "gRS232stopbit", "gRS232paritycheck", "gRS232streamcontrol", "gRS232applyto","gRS232devicenum")
	
	dims tempVal$(7)
	dimi i
	ret=getiniValues(propName$,tempVal$)
	if ret>=0 then
		for i= 0 to 6
			{varName$(i)} = tempVal$(i)	
		next			
	endif
	return ret
End Function




/***********************************************************
'** getRS485Details
 *	Description: 
 *		Provides the Network values for Network settings
 *	Returns 0 for Success; -1 failure	

 *	Params:
'*		byref dims ip: Numeric - IP Address
'*		byref dims netmask: Numeric - Netmask
'*		byref dims defaultGWay: Numeric - Default Gateway
'*		byref dims priNameServer: Numeric - Primary Name server
 *		byref dimi httpPort: Numeric - Http port
 *	Created by: Franklin Jacques On 2009-02-27 12:24:47
 ***********************************************************/
function getRS485Details(byref dims buadrate$, byref dims databit$, byref dims stopbit$, _
						   byref dims paritycheck$, byref dims  streamcontrol$, byref dims channelnum$,byref dims decoderaddr$,byref dims devicenum$)
	dimi ret				
	dims varName$(8)  = ("buadrate$", "databit$", "stopbit$", "paritycheck$", "streamcontrol$", "channelnum$","decoderaddr$","devicenum$")
	dims propName$(8) = ("gRS485buadrate", "gRS485databit", "gRS485stopbit", "gRS485paritycheck", "gRS485streamcontrol", "gRS485channelnum","gRS485decoderaddr","gRS485devicenum")
	
	dims tempVal$(8)
	dimi i
	ret=getiniValues(propName$,tempVal$)
	if ret>=0 then
		for i= 0 to 7
			{varName$(i)} = tempVal$(i)	
		next			
	endif
	return ret
End Function


Function getrs232setinfo(byref Dims commandtype$,byref Dimi channel,byref Dims responeRecordDate$)
	dimi ret 
		
	'ret=HTTPDNLD(~camAddPath$+"vb.htm?paratest=sdinsert", "","test1.txt",2,SUPRESSUI,~authHeader$,,,sdInsertVal$)
	
	ret=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+channel, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeRecordDate$)
	if ret > 0 then
		return ret
	else
		return -10	
	end if 
	
	
End Function

Function getrs485setinfo(byref Dims commandtype$,byref Dimi port,byref Dimi channel,byref Dims responeRecordDate$)
	dimi ret 
		
	'ret=HTTPDNLD(~camAddPath$+"vb.htm?paratest=sdinsert", "","test1.txt",2,SUPRESSUI,~authHeader$,,,sdInsertVal$)
	
	ret=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+port+"@"+channel, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeRecordDate$)
	if ret > 0 then
		return ret
	else
		return -10	
	end if 
	
	
End Function
//////////add by wbb//////////////////////
Function getptzsetinfo(byref Dims commandtype$,byref Dimi channel,byref Dims responeRecordDate$)
	dimi ret 
		
	'ret=HTTPDNLD(~camAddPath$+"vb.htm?paratest=sdinsert", "","test1.txt",2,SUPRESSUI,~authHeader$,,,sdInsertVal$)
	
//	ret=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+port+"@"+channel, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeRecordDate$)
	ret=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+channel, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeRecordDate$)

	if ret > 0 then
		return ret
	else
		return -10	
	end if 
		
End Function


////////add by wbb///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function getplcsetinfo(byref Dims commandtype$,byref Dimi port,byref Dimi channel,byref Dims responeRecordDate$)
	dimi ret
	ret=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+port+"@"+channel, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeRecordDate$)
	
	if ret > 0 then
		return ret
	else
		return -10	
	end if 		
End Function

Function gettcpsetinfo(byref Dims commandtype$,byref Dimi port,byref Dims responeRecordDate$)
	dimi ret 
		
	'ret=HTTPDNLD(~camAddPath$+"vb.htm?paratest=sdinsert", "","test1.txt",2,SUPRESSUI,~authHeader$,,,sdInsertVal$)
	
	ret=HTTPDNLD(~camAddPath$+"vb.htm?"+commandtype$+"="+port, "","test1.txt",2,SUPRESSUI,~authHeader$,,,responeRecordDate$)
	if ret > 0 then
		return ret
	else
		return -10	
	end if 		
End Function

function setTcpDetails(dims flag$,dims id$, dims datatype$, dims plc$, dims startadd$,dims registernum$,dims ip$,dims channel$,dims port,dims poll$, dims expire$)				'BFIX-02
	dims tcp$
	dims responsedata$
	dimi ret
	tcp$="setplctcp="+channel$+"@"+flag$+"@"+ip$+"@"+port+"@"+poll$+"@"+expire$+"@"+id$+"@"+datatype$+"@"+plc$+"@"+registernum$+"@"+startadd$
	msgbox(tcp$)
	ret = setProperties(tcp$, responseData$)	
	return ret				
	
End Function


Function setSerialDetails(dims flag$,dims protocol$,dims poll$, dims expire$,dims id$, dims datatype$, dims plc1$,dims startadd$,dims registernum$,dims buadrate$, dims databit$, dims stopbit$, dims paritycheck$,dims streamcontrol$,dims serial$,dims channel$)				'BFIX-02
	dims plc$
	dims responsedata$
	dimi ret
	plc$="setplcserial="+serial$+"@"+channel$+"@"+protocol$+"@"+poll$+"@"+expire$+"@"+flag$+"@"+id$+"@"+datatype$+"@"+plc1$+"@"+registernum$+"@"+startadd$+"@"+buadrate$+"@"+databit$+"@"+stopbit$+"@"+paritycheck$+"@"+streamcontrol$
//	msgbox(plc$)
	ret = setProperties(plc$, responseData$)	

	return ret				
	
end function
