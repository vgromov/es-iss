// Vsevolod V Gromov <mailto:gromov.vsevolod@yandex.ru>. 
// Based on modified code from:
// Michael Weiner <mailto:spam@cogit.net>
// Function for Inno Setup Compiler
// 13 November 2015
// Returns True if Microsoft Visual C++ Redistributable is installed, otherwise False.
// The programmer may set the year of redistributable to find; see below.
//
function vcrtInstalled(redistYear: string; redistBits: string): Boolean;
var
  names: TArrayOfString;
  foundPos, i: Integer;
  dName, strLookup, key: String;
begin
  Result := False;
  key := 'Software\Microsoft\Windows\CurrentVersion\Uninstall';
  strLookup := 'Visual C++';
  if redistYear <> '' then 
  begin
    strLookup := strLookup + ' ' + redistYear;
  end;
 
  // Get an array of all of the uninstall subkey names.
  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, key, names) then //< Uninstall subkey names were found.
  begin
    i := 0

    // The loop will end as soon as one instance of a Visual C++ redistributable is found.
    while((i < GetArrayLength(names)) and (Result = False)) do
    begin
      // For each uninstall subkey, look for a DisplayName value.
      // If not found, then the subkey name will be used instead.
      if not RegQueryStringValue(HKEY_LOCAL_MACHINE, key + '\' + names[i], 'DisplayName', dName) then
        dName := names[i];
      
      foundPos := Pos(
          strLookup,
          dName
        ) * 
        Pos(
          'Redistributable',
          dName
        );

      if (foundPos > 0) and (redistBits <> '') then begin
        foundPos := foundPos * Pos(
            redistBits,
            dName
          );
      end;
      
      // Update search result
      Result := ( foundPos <> 0 );
      
      i := i + 1;
    end;
  end;
end;
//---------------------------------------------------------------------------
