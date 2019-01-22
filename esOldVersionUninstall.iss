// return application uninstallation string
function esAppUninstallStringGet(uninstKey : string; var keyRoot : Integer) : string;
var
	key : string;
	uninst : string;
begin
	key := uninstKey+'_is1';
  Log('App Uninst String key: ' + key);

  if not RegQueryStringValue(HKLM, key, 'UninstallString', uninst) then begin
    if RegQueryStringValue(HKCU, key, 'UninstallString', uninst) then begin
      keyRoot := HKCU;
    end else begin
      keyRoot := -1;
    end;  
  end else begin
    keyRoot := HKLM;
  end;

  Log('App Uninst String: ' + uninst);
  result := uninst;
end;

// uninstall previous version of application if any.
// 0 - error executing the uninstaller
// 1 - successfully executed the uninstaller
function esAppUninstallOldVersion(uninstKey : string; userPrompt : string ): Boolean;
var
  uninst : string;
  ret : Integer;
  keyRoot : Integer;
begin
  // default return value
  result := False;
  // get the uninstall string of the old app
  uninst := RemoveQuotes(
    esAppUninstallStringGet(
      uninstKey, 
      keyRoot
    )
  );
  
  if uninst <> '' then begin

    if userPrompt <> '' then begin //< If we have something to ask from user - do it
      MsgBox( 
        userPrompt, 
        mbInformation, 
        mb_OK 
      );
    end;

    if FileExists( uninst ) then begin //< If uninstaller exists - launch it in silent mode
      result := Exec(
        uninst, 
        '/SILENT /NORESTART /SUPPRESSMSGBOXES',
        '', 
        SW_HIDE, 
        ewWaitUntilTerminated, 
        ret
      );
    end else if keyRoot <> -1 then begin  //< Just remove dangling installation info key from registry
      result := RegDeleteKeyIncludingSubkeys(
        keyRoot, 
        uninstKey+'_is1'
      );
    end;
  end else begin
    result := True;
  end;
end;
