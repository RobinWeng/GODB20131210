option(4+1)
showcursor(3) 

#include "defines.inc"
#include "common.inc"
#include "functions.inc"
'#include "leftMenu.bas"


dims LabelName$(10)	
dims ctrlValues$(10)   

'showSubMenu(0,1)
'setfocus("rosubmenu[2]")
'selectSubMenu()

showcursor(3)
~wait = 2 				

end

Sub Form_Load
	pprint "hello"
End Sub



Sub cmdHome_Click
	loadurl("!liveVideo.frm")
End Sub


sub savepage()
	
End Sub

sub chkValueMismatch()
	checkForModification(ctrlValues$, LabelName$)	
End Sub
