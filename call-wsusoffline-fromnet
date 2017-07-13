rem dennyhalim.com #updating windows using wsusoffline from networked shared folder
rem "=================="
rem " UPDATING WINDOWS "
rem "=================="
net use u: /d /y
net use u: \\wsusoffline\updater /persistent:no
rem U:
rem cd /d u:\wsusoffline\cmd\
call u:\wsusoffline\cmd\Doupdate.cmd /skipieinst /seconly /instpsh /instdotnet4 
cd /d %windir%
net use u: /d /y
exit
exit

