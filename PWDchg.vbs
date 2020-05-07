''PWDCHG.VBS
''DESIGNED TO CHANGE AND UPDATE LOCAL AND DOMAIN USER PASSWORD
''REQUIRES 2 PARAMETERS; 'STRUSR', 'STRPWD'
''REQUIRED PARAMETER : 'STRUSR', STRING TO SET TARGET USER
''REQUIRED PARAMETER : 'STRPWD', STRING TO SET NEW PASSWORD
''OPTIONAL PARAMETER : 'STRLVL', STRING TO SET OPERATION LEVEL (LOCAL / DOMAIN), ATTEMPTS BOTH IF BLANK ("")
''WRITTEN BY : CJ BLEDSOE / CJ<@>THECOMPUTERWARRIORS.COM
on error resume next
''SCRIPT VARIABLES
dim errRET, strVER
''VARIABLES ACCEPTING PARAMETERS - CONFIGURES USER , PASSWORD , OPERATION LEVEL
dim strUSR, strPWD, strLVL
''SCRIPT OBJECTS
dim objLOG, objHOOK, objHTTP, objXML
dim objIN, objOUT, objARG, objWSH, objFSO
''VERSION FOR SCRIPT UPDATE, PWDCHG.VBS, REF #2 , REF #68 , REF #69
strVER = 4
strREPO = "scripts"
strBRCH = "master"
strDIR = vbnullstring
''DEFAULT SUCCESS
errRET = 0
''STDIN / STDOUT
set objIN = wscript.stdin
set objOUT = wscript.stdout
set objARG = wscript.arguments
''OBJECTS FOR LOCATING FOLDERS
set objWSH = createobject("wscript.shell")
set objFSO = createobject("scripting.filesystemobject")
''CHECK 'PERSISTENT' FOLDERS , REF #2 , REF #73
if (not (objFSO.folderexists("C:\IT\"))) then
  objFSO.createfolder("C:\IT\")
end if
if (not (objFSO.folderexists("C:\IT\Scripts\"))) then
  objFSO.createfolder("C:\IT\Scripts\")
end if
''PREPARE LOGFILE
if (objFSO.fileexists("C:\temp\PWDCHG")) then              ''LOGFILE EXISTS
  objFSO.deletefile "C:\temp\PWDCHG", true
  set objLOG = objFSO.createtextfile("C:\temp\PWDCHG")
  objLOG.close
  set objLOG = objFSO.opentextfile("C:\temp\PWDCHG", 8)
else                                                        ''LOGFILE NEEDS TO BE CREATED
  set objLOG = objFSO.createtextfile("C:\temp\PWDCHG")
  objLOG.close
  set objLOG = objFSO.opentextfile("C:\temp\PWDCHG", 8)
end if
''READ PASSED COMMANDLINE ARGUMENTS
if (wscript.arguments.count > 0) then                       ''ARGUMENTS WERE PASSED
  for x = 0 to (wscript.arguments.count - 1)
    objOUT.write vbnewline & now & vbtab & " - ARGUMENT " & (x + 1) & " (ITEM " & x & ") " & " PASSED : " & ucase(objARG.item(x))
    objLOG.write vbnewline & now & vbtab & " - ARGUMENT " & (x + 1) & " (ITEM " & x & ") " & " PASSED : " & ucase(objARG.item(x))
  next 
  if (wscript.arguments.count > 0) then                     ''SET USER , PASSWORD , AND OPERATION LEVEL VARIABLES
    strUSR = objARG.item(0)
    strPWD = objARG.item(1)
    strLVL = objARG.item(2)
  else                                                      ''NOT ENOUGH ARGUMENTS PASSED, END SCRIPT
    errRET = 1
    call CLEANUP()
  end if
else                                                        ''NO ARGUMENTS PASSED, END SCRIPT
  errRET = 1
  call CLEANUP()
end if

''------------
''BEGIN SCRIPT
if (errRET = 0) then
  objOUT.write vbnewline & vbnewline & now & vbtab & " - EXECUTING PWDCHG"
  objLOG.write vbnewline & vbnewline & now & vbtab & " - EXECUTING PWDCHG"
	''AUTOMATIC UPDATE, PWDCHG.VBS, REF #2 , REF #69 , REF #68
  ''DOWNLOAD CHKAU.VBS SCRIPT, REF #2 , REF #69 , REF #68
  call FILEDL("https://raw.githubusercontent.com/CW-Khristos/scripts/master/chkAU.vbs", "C:\IT\Scripts", "chkAU.vbs")
  ''EXECUTE CHKAU.VBS SCRIPT, REF #69
  objOUT.write vbnewline & now & vbtab & vbtab & " - CHECKING FOR UPDATE : PWDCHG : " & strVER
  objLOG.write vbnewline & now & vbtab & vbtab & " - CHECKING FOR UPDATE : PWDCHG : " & strVER
  intRET = objWSH.run ("cmd.exe /C " & chr(34) & "cscript.exe " & chr(34) & "C:\IT\Scripts\chkAU.vbs" & chr(34) & " " & _
    chr(34) & strREPO & chr(34) & " " & chr(34) & strBRCH & chr(34) & " " & chr(34) & strDIR & chr(34) & " " & _
    chr(34) & wscript.scriptname & chr(34) & " " & chr(34) & strVER & chr(34) & " " & _
    chr(34) & strUSR & "|" & strPWD & "|" & strLVL & chr(34) & chr(34), 0, true)
  ''CHKAU RETURNED - NO UPDATE FOUND , REF #2 , REF #69 , REF #68
  objOUT.write vbnewline & "errRET='" & intRET & "'"
  objLOG.write vbnewline & "errRET='" & intRET & "'"
  intRET = (intRET - vbObjectError)
  objOUT.write vbnewline & "errRET='" & intRET & "'"
  objLOG.write vbnewline & "errRET='" & intRET & "'"
  if ((intRET = 4) or (intRET = 10) or (intRET = 11) or (intRET = 1) or (intRET = 2147221505) or (intRET = 2147221517)) then
    ''CHANGE LOCAL USER PASSWORD
    if ((strLVL = vbnullstring) or (ucase(strLVL) = "LOCAL")) then
      objOUT.write vbnewline & vbnewline & now & vbtab & vbtab & " - EXECUTING LOCAL PWDCHG"
      objLOG.write vbnewline & vbnewline & now & vbtab & vbtab & " - EXECUTING LOCAL PWDCHG"
      call HOOK("net user " & chr(34) & strUSR & chr(34) & " " & chr(34) & strPWD & chr(34) & " /y")
      call HOOK("net user " & chr(34) & strUSR & chr(34) & " " & chr(34) & strPWD & chr(34) & " /ADD /y")
    end if
    ''CHANGE DOMAIN USER PASSWORD
    if ((strLVL = vbnullstring) or (ucase(strLVL) = "DOMAIN")) then
      objOUT.write vbnewline & vbnewline & now & vbtab & vbtab & " - EXECUTING DOMAIN PWDCHG"
      objLOG.write vbnewline & vbnewline & now & vbtab & vbtab & " - EXECUTING DOMAIN PWDCHG"
      call HOOK("net user " & chr(34) & strUSR & chr(34) & " " & chr(34) & strPWD & chr(34) & " /DOMAIN /y")
      call HOOK("net user " & chr(34) & strUSR & chr(34) & " " & chr(34) & strPWD & chr(34) & " /DOMAIN /ADD /y")
    end if
  end if
elseif (errRET <> 0) then
  call LOGERR(errRET)
end if
''END SCRIPT
call CLEANUP()
''END SCRIPT
''------------

''SUB-ROUTINES
sub FILEDL(strURL, strDL, strFILE)                            ''CALL HOOK TO DOWNLOAD FILE FROM URL , 'ERRRET'=11
  strSAV = vbnullstring
  ''SET DOWNLOAD PATH
  strSAV = strDL & "\" & strFILE
  objOUT.write vbnewline & now & vbtab & vbtab & "HTTPDOWNLOAD-------------DOWNLOAD : " & strURL & " : SAVE AS :  " & strSAV
  objLOG.write vbnewline & now & vbtab & vbtab & "HTTPDOWNLOAD-------------DOWNLOAD : " & strURL & " : SAVE AS :  " & strSAV
  ''CHECK IF FILE ALREADY EXISTS
  if objFSO.fileexists(strSAV) then
    ''DELETE FILE FOR OVERWRITE
    objFSO.deletefile(strSAV)
  end if
  ''CREATE HTTP OBJECT
  set objHTTP = createobject( "WinHttp.WinHttpRequest.5.1" )
  ''DOWNLOAD FROM URL
  objHTTP.open "GET", strURL, false
  objHTTP.send
  if (objHTTP.status = 200) then
    dim objStream
    set objStream = createobject("ADODB.Stream")
    with objStream
      .Type = 1 'adTypeBinary
      .Open
      .Write objHTTP.ResponseBody
      .SaveToFile strSAV
      .Close
    end with
    set objStream = nothing
  end if
  ''CHECK THAT FILE EXISTS
  if objFSO.fileexists(strSAV) then
    objOUT.write vbnewline & vbnewline & now & vbtab & " - DOWNLOAD : " & strSAV & " : SUCCESSFUL"
    objLOG.write vbnewline & vbnewline & now & vbtab & " - DOWNLOAD : " & strSAV & " : SUCCESSFUL"
  end if
	set objHTTP = nothing
  if ((err.number <> 0) and (err.number <> 58)) then          ''ERROR RETURNED DURING UPDATE CHECK , 'ERRRET'=11
    call LOGERR(11)
  end if
end sub

sub HOOK(strCMD)                                        ''CALL HOOK TO MONITOR OUTPUT OF CALLED COMMAND
  on error resume next
  'comspec = objWSH.ExpandEnvironmentStrings("%comspec%")
  objOUT.write vbnewline & now & vbtab & vbtab & "EXECUTING : " & strCMD
  objLOG.write vbnewline & now & vbtab & vbtab & "EXECUTING : " & strCMD
  set objHOOK = objWSH.exec(strCMD)
  if (instr(1, strCMD, "takeown /F ") = 0) then         ''SUPPRESS 'TAKEOWN' SUCCESS MESSAGES
    while (not objHOOK.stdout.atendofstream)
      strIN = objHOOK.stdout.readline
      if (strIN <> vbnullstring) then
        objOUT.write vbnewline & now & vbtab & vbtab & vbtab & strIN 
        objLOG.write vbnewline & now & vbtab & vbtab & vbtab & strIN 
      end if
    wend
    wscript.sleep 10
    strIN = objHOOK.stdout.readall
    if (strIN <> vbnullstring) then
      objOUT.write vbnewline & now & vbtab & vbtab & vbtab & strIN 
      objLOG.write vbnewline & now & vbtab & vbtab & vbtab & strIN 
    end if
  end if
  set objHOOK = nothing
  if (err.number <> 0) then
    errRET = 3
    objOUT.write vbnewline & now & vbtab & vbtab & vbtab & err.number & vbtab & err.description
    objLOG.write vbnewline & now & vbtab & vbtab & vbtab & err.number & vbtab & err.description
    err.clear
  end if
end sub

sub LOGERR(intSTG)                                            ''CALL HOOK TO MONITOR OUTPUT OF CALLED COMMAND
  errRET = intSTG
  if (err.number <> 0) then
    objOUT.write vbnewline & now & vbtab & vbtab & vbtab & err.number & vbtab & err.description & vbnewline
    objLOG.write vbnewline & now & vbtab & vbtab & vbtab & err.number & vbtab & err.description & vbnewline
		err.clear
  end if
end sub

sub CLEANUP()                                           ''SCRIPT CLEANUP
  on error resume next
  if (errRET = 0) then                                 ''SCRIPT COMPLETED SUCCESSFULLY
    objOUT.write vbnewline & vbnewline & now & vbtab & " - PWDCHG COMPLETE : " & now
    objLOG.write vbnewline & vbnewline & now & vbtab & " - PWDCHG COMPLETE : " & now
    err.clear
  elseif (errRET <> 0) then                            ''SCRIPT FAILED
    objOUT.write vbnewline & vbnewline & now & vbtab & " - PWDCHG FAILURE : " & errRET & " : " & now
    objLOG.write vbnewline & vbnewline & now & vbtab & " - PWDCHG FAILURE : " & errRET & " : " & now
    ''RAISE CUSTOMIZED ERROR CODE, ERROR CODE WILL BE DEFINED RESTOP NUMBER INDICATING WHICH SECTION FAILED
    call err.raise(vbObjectError + errRET, "PWDCHG", "fail")
  end if
  ''EMPTY OBJECTS
  set objEXEC = nothing
  set objLOG = nothing
  set objFSO = nothing
  set objWSH = nothing
  set objARG = nothing
  set objOUT = nothing
  set objIN = nothing
  ''END SCRIPT, RETURN ERROR
  wscript.quit err.number
end sub