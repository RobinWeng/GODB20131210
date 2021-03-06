#include "leftMenu.frm"
<LABEL UID="1"
Name="lblSuccessMessage"
X="314"
Y="588"
Style="64"
W="618"
H="20"
Font="9"
Scrollable="1"
/>
<READONLY UID="2"
Name="roCamera"
X="595"
Y="75"
Scrollable="1"
W="100"
Font="2"
Hidden="1"
Disabled="1"
/>
<CHECK UID="3"
Name="chkUploadViaFtp"
Value="1"
X="391"
Y="112"
Scrollable="1"
W="134"
H="14"
Label="FTP上传"
Font="2"
/>
<LIST UID="4"
Name="ddstorageformat"
Value="AVI"
X="690"
Y="110"
Scrollable="1"
W="177"
ITEMS=""
Font="2"
/>
<CHECK UID="5"
Name="chkLocalStorage"
Value="1"
X="391"
Y="151"
Scrollable="1"
W="186"
H="14"
Label="保存本地"
Font="2"
/>
<LIST UID="6"
Name="ddstorageformat1"
Value="AVI"
X="690"
Y="151"
Scrollable="1"
W="177"
ITEMS=""
Font="2"
/>
<RADIO UID="7"
Name="optlocalStorage"
Value="0"
X="715"
Y="191"
Scrollable="1"
W="71"
H="14"
Checked="0"
Label="SD/MMC"
Font="2"
/>
<RADIO UID="8"
Name="optrepeatschedule"
Value="1"
X="391"
Y="288"
Scrollable="1"
W="172"
H="14"
Checked="0"
Label="录像时间 / 每周"
Font="2"
/>
<TEXT UID="9"
Name="txtweeks"
X="595"
Y="287"
Scrollable="1"
W="38"
MaxLength="2"
Font="2"
Hidden="1"
Disabled="1"
/>
<RADIO UID="10"
Name="optruntimeinfinite"
Value="1"
X="715"
Y="288"
Scrollable="1"
W="133"
H="14"
Checked="0"
Label="常录"
Font="2"
/>
<BUTTON UID="11"
Name="btnAdd"
Value="增加计划"
X="382"
Y="618"
W="122"
H="20"
Scrollable="1"
Font="2"
/>
<BUTTON UID="12"
Name="btnSave"
Value="确定"
X="515"
Y="618"
Scrollable="1"
W="80"
H="20"
Font="2"
/>
<BUTTON UID="13"
Name="btnCancel"
Value="取消"
X="604"
Y="616"
Scrollable="1"
W="80"
H="20"
Font="2"
/>
<BUTTON UID="14"
Name="btnRemove"
Value="删除所有计划"
X="690"
Y="618"
Scrollable="1"
W="174"
H="20"
Font="2"
/>
<FRAME UID="15"
Name="frSchedule"
X="1059"
Y="200"
BG="65535"
SelBG="50712"
W="673"
H="298"
Objects="lblcolor2,lblcolor5,lblcolor6,lblcolor3,lblcolor4,lblcolor7,lblcolor1,btnFrameOK,drpday2,lblSchedule,drpday3,drpday4,drpday5,drpday6,drpday7,lblFrom1,lblFrom2,lblFrom3,lblFrom4,lblFrom5,lblFrom6,lblFrom7,drpFromHrs1,drpFromHrs2,drpFromHrs3,drpFromHrs4,drpFromHrs5,drpFromHrs6,drpFromHrs7,drpFromMin1,drpFromMin2,drpFromMin3,drpFromMin4,drpFromMin5,drpFromMin6,lblTo1,lblTo2,lblTo3,lblTo4,lblTo5,lblTo6,lblTo7,drpToHrs1,drpToHrs2,drpToHrs3,drpToHrs4,drpToHrs5,drpToHrs6,drpToHrs7,drpToMin7,drpToMin6,drpToMin5,drpToMin4,drpToMin3,drpToMin2,drpToMin1,btnFrameCancel,drpday1,chkSchedule1,chkSchedule2,chkSchedule3,chkSchedule4,chkSchedule5,chkSchedule6,chkSchedule7,drpFromMin7,"
Modal="1"
Border="2"
ButtonBG="54970"
Brdr="6603"
SelBrdr="6603"
Scrollable="1"
/>
<RADIO UID="16"
Name="optlocalStorage"
Value="1"
X="800"
Y="191"
Scrollable="1"
W="48"
H="14"
Checked="0"
Label="USB"
Font="2"
/>
<RADIO UID="17"
Name="optlocalStorage"
Value="2"
X="847"
Y="191"
Scrollable="1"
W="63"
H="14"
Checked="0"
Label="NAND"
Font="2"
/>
<LABEL UID="18"
Name="lblcamera"
Value="DVR"
X="391"
Y="76"
Scrollable="1"
W="103"
H="14"
Hidden="1"
/>
<LABEL UID="19"
Name="lblfileformat"
Value="文件格式"
X="596"
Y="112"
Scrollable="1"
W="77"
H="15"
Font="2"
/>
<LABEL UID="20"
Name="lblweeks"
Value="每周"
X="641"
Y="288"
Scrollable="1"
W="40"
H="14"
Font="2"
Hidden="1"
/>
<LABEL UID="21"
Name="lblStorageFormat"
Value="存储位置"
X="596"
Y="191"
Scrollable="1"
W="102"
H="14"
Font="2"
/>
<LABEL UID="22"
Name="lblFileFormat1"
Value="文件格式"
X="596"
Y="151"
Scrollable="1"
W="77"
H="14"
Font="2"
/>
<LABEL UID="23"
Name="lbldummy"
Value="do not delete"
X="382"
Y="325"
Scrollable="1"
Hidden="1"
W="80"
H="14"
Font="2"
/>
<LABEL UID="24"
Name="lblSelectChannel"
Value="录像通道选择"
X="391"
Y="56"
Scrollable="1"
Font="2"
W="90"
H="14"
/>
<LIST UID="25"
Name="videoChannel"
X="596"
Y="46"
Scrollable="1"
Font="2"
W="150"
PopHeight="4"
ITEMS=""
/>
<LABEL UID="26"
Name="lblcolor2"
X="1101"
Y="270"
BG="1638"
Brdr="10533"
SelBG="1638"
W="18"
H="18"
Scrollable="1"
/>
<LABEL UID="27"
Name="lblcolor5"
X="1101"
Y="355"
BG="1657"
Brdr="10533"
SelBG="1657"
W="18"
H="18"
Scrollable="1"
/>
<LABEL UID="28"
Name="lblcolor6"
X="1101"
Y="385"
BG="800"
Brdr="10533"
SelBG="800"
W="18"
H="18"
Scrollable="1"
/>
<LABEL UID="29"
Name="lblcolor3"
X="1101"
Y="300"
BG="38937"
Brdr="10533"
SelBG="38937"
W="18"
H="18"
Scrollable="1"
/>
<LABEL UID="30"
Name="lblcolor4"
X="1101"
Y="328"
BG="63878"
Brdr="10533"
SelBG="63878"
W="18"
H="18"
Scrollable="1"
/>
<LABEL UID="31"
Name="lblcolor7"
X="1101"
Y="416"
BG="52000"
Brdr="10533"
SelBG="52000"
W="18"
H="18"
Scrollable="1"
/>
<LABEL UID="32"
Name="lblcolor1"
X="1101"
Y="242"
BG="25"
Brdr="10533"
SelBG="25"
W="18"
H="18"
Scrollable="1"
/>
<BUTTON UID="33"
Name="btnFrameOK"
Value="确定"
X="1292"
Y="462"
W="100"
H="20"
Scrollable="1"
Font="2"
/>
<LIST UID="34"
Name="drpday2"
Value="Tuesday"
X="1140"
Y="270"
W="105"
Style="8"
ITEMS=""
Scrollable="1"
/>
<LABEL UID="35"
Name="lblSchedule"
X="1059"
Y="200"
FG="50712"
BG="6603"
Brdr="6603"
SelFG="50712"
SelBG="6603"
SelBrdr="6603"
W="645"
H="26"
Value=" 录像计划"
Style="136"
Scrollable="1"
Font="2"
/>
<LIST UID="36"
Name="drpday3"
Value="Wednesday"
X="1140"
Y="300"
W="105"
Style="8"
ITEMS=""
Scrollable="1"
/>
<LIST UID="37"
Name="drpday4"
Value="Thursday"
X="1140"
Y="328"
W="105"
Style="8"
ITEMS=""
Scrollable="1"
/>
<LIST UID="38"
Name="drpday5"
Value="Friday"
X="1140"
Y="355"
W="105"
Style="8"
ITEMS=""
Scrollable="1"
/>
<LIST UID="39"
Name="drpday6"
Value="Saturday"
X="1140"
Y="385"
W="105"
Style="8"
ITEMS=""
Scrollable="1"
/>
<LIST UID="40"
Name="drpday7"
Value="Sunday"
X="1140"
Y="416"
W="105"
Style="8"
ITEMS=""
Scrollable="1"
/>
<LABEL UID="41"
Name="lblFrom1"
Value="开始"
X="1281"
Y="242"
W="36"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="42"
Name="lblFrom2"
Value="开始"
X="1281"
Y="270"
W="36"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="43"
Name="lblFrom3"
Value="开始"
X="1281"
Y="300"
W="36"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="44"
Name="lblFrom4"
Value="开始"
X="1281"
Y="328"
W="36"
H="13"
Scrollable="1"
Font="2"
/>
<LABEL UID="45"
Name="lblFrom5"
Value="开始"
X="1281"
Y="355"
W="36"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="46"
Name="lblFrom6"
Value="开始"
X="1281"
Y="385"
W="36"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="47"
Name="lblFrom7"
Value="开始"
X="1281"
Y="416"
W="36"
H="14"
Scrollable="1"
Font="2"
/>
<LIST UID="48"
Name="drpFromHrs1"
Value="Val1"
X="1329"
Y="242"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="49"
Name="drpFromHrs2"
Value="Val1"
X="1329"
Y="270"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="50"
Name="drpFromHrs3"
Value="Val1"
X="1329"
Y="300"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="51"
Name="drpFromHrs4"
Value="Val1"
X="1329"
Y="328"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="52"
Name="drpFromHrs5"
Value="Val1"
X="1329"
Y="355"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="53"
Name="drpFromHrs6"
Value="Val1"
X="1329"
Y="385"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="54"
Name="drpFromHrs7"
Value="Val1"
X="1329"
Y="416"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="55"
Name="drpFromMin1"
Value="Val1"
X="1428"
Y="242"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="56"
Name="drpFromMin2"
Value="Val1"
X="1428"
Y="270"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="57"
Name="drpFromMin3"
Value="Val1"
X="1428"
Y="300"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="58"
Name="drpFromMin4"
Value="Val1"
X="1428"
Y="328"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="59"
Name="drpFromMin5"
Value="Val1"
X="1428"
Y="355"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="60"
Name="drpFromMin6"
Value="Val1"
X="1428"
Y="385"
W="63"
ITEMS=""
Scrollable="1"
/>
<LABEL UID="61"
Name="lblTo1"
Value="结束"
X="1518"
Y="242"
W="35"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="62"
Name="lblTo2"
Value="结束"
X="1518"
Y="270"
W="35"
H="13"
Scrollable="1"
Font="2"
/>
<LABEL UID="63"
Name="lblTo3"
Value="结束"
X="1518"
Y="300"
W="35"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="64"
Name="lblTo4"
Value="结束"
X="1518"
Y="328"
W="35"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="65"
Name="lblTo5"
Value="结束"
X="1518"
Y="355"
W="35"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="66"
Name="lblTo6"
Value="结束"
X="1518"
Y="385"
W="35"
H="14"
Scrollable="1"
Font="2"
/>
<LABEL UID="67"
Name="lblTo7"
Value="结束"
X="1517"
Y="416"
W="35"
H="14"
Scrollable="1"
Font="2"
/>
<LIST UID="68"
Name="drpToHrs1"
Value="Val1"
X="1554"
Y="242"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="69"
Name="drpToHrs2"
Value="Val1"
X="1554"
Y="270"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="70"
Name="drpToHrs3"
Value="Val1"
X="1554"
Y="300"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="71"
Name="drpToHrs4"
Value="Val1"
X="1554"
Y="328"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="72"
Name="drpToHrs5"
Value="Val1"
X="1554"
Y="355"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="73"
Name="drpToHrs6"
Value="Val1"
X="1554"
Y="385"
W="62"
ITEMS=""
Scrollable="1"
/>
<LIST UID="74"
Name="drpToHrs7"
Value="Val1"
X="1554"
Y="416"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="75"
Name="drpToMin7"
Value="Val1"
X="1652"
Y="416"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="76"
Name="drpToMin6"
Value="Val1"
X="1652"
Y="385"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="77"
Name="drpToMin5"
Value="Val1"
X="1652"
Y="355"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="78"
Name="drpToMin4"
Value="Val1"
X="1652"
Y="328"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="79"
Name="drpToMin3"
Value="Val1"
X="1652"
Y="300"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="80"
Name="drpToMin2"
Value="Val1"
X="1652"
Y="270"
W="63"
ITEMS=""
Scrollable="1"
/>
<LIST UID="81"
Name="drpToMin1"
Value="Val1"
X="1652"
Y="242"
W="63"
ITEMS=""
Scrollable="1"
/>
<BUTTON UID="82"
Name="btnFrameCancel"
Value="取消"
X="1407"
Y="462"
W="100"
H="20"
Scrollable="1"
Font="2"
/>
<LIST UID="83"
Name="drpday1"
Value="Monday"
X="1140"
Y="242"
W="105"
Style="8"
ITEMS=""
Scrollable="1"
/>
<CHECK UID="84"
Name="chkSchedule1"
Value="Value1"
X="1072"
Y="242"
W="21"
H="14"
Scrollable="1"
/>
<CHECK UID="85"
Name="chkSchedule2"
Value="Value2"
X="1072"
Y="270"
W="21"
H="14"
Scrollable="1"
/>
<CHECK UID="86"
Name="chkSchedule3"
Value="Value3"
X="1072"
Y="300"
W="21"
H="14"
Scrollable="1"
/>
<CHECK UID="87"
Name="chkSchedule4"
Value="Value4"
X="1072"
Y="328"
W="21"
H="14"
Scrollable="1"
/>
<CHECK UID="88"
Name="chkSchedule5"
Value="Value5"
X="1072"
Y="355"
W="21"
H="14"
Scrollable="1"
/>
<CHECK UID="89"
Name="chkSchedule6"
Value="Value6"
X="1072"
Y="385"
W="21"
H="14"
Scrollable="1"
/>
<CHECK UID="90"
Name="chkSchedule7"
Value="Value7"
X="1072"
Y="416"
W="21"
H="14"
Scrollable="1"
/>
<LIST UID="91"
Name="drpFromMin7"
Value="Val1"
X="1428"
Y="416"
W="63"
ITEMS=""
Scrollable="1"
/>
