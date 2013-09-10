/*
Change Request
--------------
--------------------------------------------------------------------------------------------------------------------------------------------
S.No	Track No	CR No 	Description				   						Done by  	      Modified On			Reviewed by  	Reviewed On
--------------------------------------------------------------------------------------------------------------------------------------------
 1.		TR-01		CR-01	UI for the storage setting has to accommodate 
							for providing selection up to timeslot of 
							1 minute 
										
							UI Design  and date Validation				      Vimala		   31-Aug-2009			
						
							Schedule save to camera	and display	display 
							in UI											  Franklin	       31-Aug-2009					

 2.   	TR-02 		CR-01	Modified keywords as frameratename1, 
							frameratename2, jpegframeratename1,
							jpegframeratename2, jpegframeratename3 variable 
							to populate drop down of framerate for stream1, 
							stream2 and stream3 based on selected streamtype 
							and codec										   Vimala			1-Sep-2009

 3.   	TR-03      CR-01  	Suppress zero's in IP address					   Vimala			4-Sep-2009
 
 4.   	TR-04      CR-01	Display streams based on the use case and 
							display video in selected streams aspect ratio	   Vimala			8-sep-2009
 5.   	TR-05	   CR-01	Disabled "Network" tab and "HTTP Port" when 
							dhcpenable is set .								   vimala			16-Oct-2009
 6.   	TR-06      CR-01	Modified stream based on the usecase  			   vimala			16-Oct-2009
 7.   	TR-07	   CR-01	Modified keyword “jpegframeratename3” for the
						    frame rate dropdown for Stream Type = single,
							Codec Combo = MegaPixel Jpeg and 
							Resolution = JPG:2048x1536.						   vimala			16-Oct-2009
 8.		TR-08	   CR-02	Changes in maintenance module and SD Card 
							explorer.Changes made in .htm pge				   vimala			19-Oct-2009
 9.  	TR-09	   CR-03   	Displaying the Jpeg tab as second tab 
							for Tri-Stream									   vimala			21-Oct-2009
 10.     TR-10	   CR-03	Remember Password								   vimala			22-Oct-2009
 11.    TR-11	   CR-03	"Detailed Info"  check box in video for	
							stream1,stream2,stream3							    vimala			22-Oct-2009
							
 12.	TR-12	  CR-03	    Move the "Exposure Control" drop down to the
						    right side under "Auto Exposure Setting"
						    Add the "Histogram" radio button in the same 
						    place where "Exposure Control" drop down  			vimala			22-Oct-2009
 13.	TR-13	  CR-04		Display in 1X" should be given as a Icon 
							instead of a button to the right hand side of 
							stream dropdown. The icon should have tool tip 
							which reads as "Full Screen Display". 
							You can rename "close 1x mode" to "close full 
							screen mode"  										vimala			05-Nov-2009		
 14.    TR-14     CR-04		Remove the "Rotate" field and the corresponding 
							drop down from the screen.
							The "Encrypt Video" field should be grayed out.		vimala			05-Nov-2009		
 15.	TR-15     CR-04		Packet Size text box should allow values between 
							0 to 100 only as this is represented in % mode		vimala			05-Nov-2009	
 16.    TR-16     CR-04     For MJPEG streams, the advanced screen should be 
							blank with the message "No Advanced Setting 
							for JPEG is available in this version"				vimala			05-Nov-2009	
 17.    TR-17	  CR-04		Face Detect/Face Recognition confidence level 
							text box should allow values between 0 to 100 
							only 												vimala			05-Nov-2009	
 18.    TR-18     CR-04		A new subgroup called "2A Setting".
							The "2A Type" field should be moved under 
							this sub group renamed as "2A Engine" and  
							add field called "2A Mode" needs to be 
							added under "2A Setting"							vimala			05-Nov-2009	

 19. 	TR-19   CR-04		The "Audio Mode" field should be grayed out 
							when 'Enable Audio" is not selected and 
							Gray out the "Alarm Level" field.					vimala			05-Nov-2009	

 20. 	TR-20   CR-04		Added "RTSP" Tab, under this tab  a check box
							with text as "Enable Multicast".					vimala			06-Nov-2009	
 21.    TR-21	CR-04		All the fields in the screen should be grayed 
							out when "Enable Alarm" is not selected.
							"Dark/Blank Images" field should be grayed out.		vimala			06-Nov-2009	
 22.    TR-22	CR-04		Added additional buttons for "Format" 
							and "Unmount" in the SD Card Explorer page.  
							Also, if unmount is done, then it should activate
							Mount button.										vimala			06-Nov-2009	

 23.    TR-23   CR-05      Demo mode should appear for all modes, 
						   removed the check for super-user					    vimala			30-Nov-2009	
 24.    TR-24   CR-05      Click snap should appear for all modes,
						   removed check for face recognition check             vimala			30-Nov-2009	
 25.     		CR-05      removed Super admin option from the .frm screen	    vimala			30-Nov-2009	
 26.    TR-25 	CR-05      Changed Face recog as drop down , 
						   variable are "frecognition" and "frecognitionname"   vimala			30-Nov-2009	
 27.    TR-26 	CR-05      Renamed Gain Value as Input Volume and removed 
						   dB as unit and use "audioinvolume" variable.
						   Output volume: use "audiooutvolume" variable         vimala			30-Nov-2009	
 28.   TR-27    CR-05	   Removed IP ratio, check for 4digit validation        vimala			30-Nov-2009	
 29.   TR-28    CR-05	   Grayed USB and NAND option for Click Snap		    vimala			30-Nov-2009	
 30.   TR-29    CR-05	   Return number of regions selected				    vimala			30-Nov-2009	
 31.   TR-30    CR-05	   Demo mode save functionality implementation and 
						   Loading caption animation 							vimala			15-Dec-2009	
 32.   		    CR-06	   Moved the example dropdown near PTZ. 
						   Modified in LiveVideo.frm 							vimala			15-Dec-2009	
 33.   TR-31 	CR-06	   In Video Setting,Added a section "Video File" 
						   with Stream,Video Sizedrop down						vimala			15-Dec-2009	
 34.   		 	CR-06	   Removed Periodicity from Alarm page.
						   Removed corresponding coding in .bas file.			vimala			15-Dec-2009	
 35.   TR-32    CR-06      GUI Version and Video Player Version modification 	vimala			15-Dec-2009	  
 36.   TR-33    CR-06      ROI for Face detect								 	vimala			15-Dec-2009	  
 37.   		    CR-07      In Camera settings page 
							1.Renamed "Exposure Control" to 
							"Flicker Control" and move it just below GBCE.
							2.Renamed GBCE to “Dynamic Range Enhancement”
							3. Renamed “Auto Exposure Setting” to 
							“Low Light Behavior”		
							Modified above changes in cameraSetting.frm			vimala			20-Dec-2009	 
 38.   TR-34	CR-07		Added a label “Priority” with drop down menu 
							just below “Auto Exposure Setting”. 
							The dropdown values shall be fetched from 
							“priorityname” and “priority”.						vimala			20-Dec-2009	 
 39.   TR-35	CR-07		On successful saving of the application,a message 
							displayed at the bottom of the screen just above 
							the "OK"/"Cancel" buttons. 							vimala			20-Dec-2009	 
 40.   TR-36	CR-07		In "Display all streams", while displaying dual
							stream with equal resolution display them in 
							equal size.											vimala			20-Dec-2009	 
 41.   TR-37	CR-07	    In "LIVE VIDEO" Rename the "Click Snap"
							button to "Snapshot.								vimala			20-Dec-2009	
 42.   			CR-07	    Rename NFS in Video Analytics Screen to NAND.
							Modified in .frm									vimala			21-Dec-2009	
 43.   TR-38    CR-07.1	    Clicking clear must clear the region in the Video 	vimala			23-Dec-2009	
 44.   TR-39    CR-07.1	    Fetch camera reload time from variable “reloadtime” vimala			29-Dec-2009	
 45.   TR-40    	    	Mofified camera load time as gobel variable and used 
							in live video,all streams ,video			 		vimala			04-jan-2010	
 46.   TR-41	CR-08		QP Min value should be less then QP Max value,
							Added new field QP Value Init for all stream,
							Removed "Intra in P frame" and "UMV" ,
							Renamed "ME Config" to "Encode Preset" 		
							Added new variable qpinit1,qpinit2,qpinit3			vimala			05-jan-2010	
 47.  TR-42    CR-09		In video settings , framerate for stream 1,
							stream2,stream3 are fetch from  framerate1, 
							framerate2, framerate3, framerateall1, 
							framerateall2, framerateall3.
							Frame rate should load based on the resolution. 
							Modified Codec and resolution displying logic.     vimala			11-jan-2010	
 48.		   CR-10		Modified video setting get,set function and codec
							,frame rate logic								   Vimala			13-jan-2010
 49.  TR-43	   CR-11		Removed PTZ Button from live video and all streams Vimala			20-jan-2010
 50.  TR-45    CR-14		Wait for IPNC to restart based on the "reloadflag" Vimala			13-April-2010	
 
 
------------------------------------------------------------------------------------------------------------------------------------------

Bug Fix
-------
------------------------------------------------------------------------------------------------------------------------------------------
1.		BFIX-01    In Date time setting,Date format of Set manually,
				   synchronize with SMTP date and time not showing 
				   correctly issue(Given latest cramfsimagev.9)			vimala         	 2-Sep-2009   
2.		BFIX-02    In Network setting removed validation
				   written in blur event.
				   HttpPort save two times removed the same 			vimala			 2-Sep-2009
3.   	BFIX-03	   Framerate not showing the saved value for 
				   stream 2 and stream 3 	   							vimala			 14-Sep-2009
4.      BFIX-04	   In Video setting ,fixed issue in overlay 
				   setting validation for text and Logo .				vimala			 16-Oct-2009	
5.		BFIX-05	   All the left menu options starting from 
				   "Live Video" to "Support" should be 
				   uniformly placed between the top of the 
				   GUI window and the TI logo at the bottom.		    vimala			22-Oct-2009
6.		BFIX-06	   Stream not loading after saving video without
				   doing any change and detail info not saving not 
				   properly issue(Working cramfsImage not available)	vimala			22-Oct-2009
7.   	BFIX-07	   Click snap image selected image not changing 
				   properly												vimala			11-jan-2010
------------------------------------------------------------------------------------------------------------------------------------------

Code Rework
-----------
-------------------------------------------------------------------------------------------------------------------------------------------
1.     RE_WK-01
 
 
--------------------------------------------------------------------------------------------------------------------------------------------






CR     - Change Request
RE_WK  - Code Rework
BFIX   - Bug Fix













*/
