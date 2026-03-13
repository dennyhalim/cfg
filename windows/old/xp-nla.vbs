'Enables Network Level Authentication on XP SP3 (disabled by default)
'which allows you to use the Remote Desktop Client 6.1 to connect to
'Windows 7 and Windows Server 2008 R2 without degrading security
'https://pcloadletter.co.uk/2010/09/07/enabling-nla-on-xp/ 

Option Explicit
 
Const HKEY_LOCAL_MACHINE = &H80000002
 
Dim strLsaKey, strLsaValue, strHostname, size, arrMultiRegSZ, objReg, objWMI, colItems, i, found, modified
Dim objItem, SPlevel, strOSVer, strSecProvKey, strSecProvValue, strValue
 
strLsaKey = "SYSTEM\CurrentControlSet\Control\Lsa"
strLsaValue = "Security Packages"
strSecProvKey = "SYSTEM\CurrentControlSet\Control\SecurityProviders"
strSecProvValue = "SecurityProviders"
strHostname = "."
modified = false
found = false
 
Set objWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strHostname & "\root\cimv2")
Set colItems = objWMI.ExecQuery("SELECT * FROM Win32_OperatingSystem")
For Each objItem In colItems
  strOSVer = objItem.Version
  SPlevel = objItem.ServicePackMajorVersion
Next
If Not Left(strOSVer,3) = "5.1" Then
  WScript.Echo "This script is only intended for Windows XP."
  WScript.Quit
End If
If Not SPlevel >= 3 Then
  WScript.Echo "Please install the latest Windows XP Service Pack from Windows Update."
  WScript.Quit
End If
 
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strHostname & "\root\default:StdRegProv")
objReg.GetMultiStringValue HKEY_LOCAL_MACHINE, strLsaKey, strLsaValue, arrMultiRegSZ
size = Ubound(arrMultiRegSZ)
For i=0 to size
  If arrMultiRegSZ(i) = "tspkg" Then
    found = true
  End If
Next
If found Then
  WScript.Echo "tspkg already added to HKLM\SYSTEM\CurrentControlSet\Control\Lsa"
Else
  ReDim Preserve arrMultiRegSZ(size + 1)
  arrMultiRegSZ(size + 1) = "tspkg"
  objReg.SetMultiStringValue HKEY_LOCAL_MACHINE, strLsaKey, strLsaValue, arrMultiRegSZ
  modified = true
End If
 
objReg.GetStringValue HKEY_LOCAL_MACHINE, strSecProvKey, strSecProvValue, strValue
 
If Instr(strValue,"credssp.dll") Then
  WScript.Echo "credssp.dll already added to HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders"
Else
  strValue = strValue & ", credssp.dll"
  objReg.SetStringValue HKEY_LOCAL_MACHINE, strSecProvKey, strSecProvValue, strValue
  modified = true
End If
If modified Then
  WScript.Echo "Settings updated. You will need to restart for the changes to become active."
End If
 
Set objReg = nothing
Set objWMI = nothing
