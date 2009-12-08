unit configs;

{*
Simple configuration in ~/.ghost/<mode>/...
}

interface

uses
  SysUtils, Classes;

var
  GhostConfPath: string;
  GhostConfLang: string;

function CmdLineSwitchValue(ASwitch : string; ADefault : string) : string;

implementation

function CmdLineSwitchValue(ASwitch : string; ADefault : string) : string;
{*
Return first string after the given switch in command line arguments
}
var i : integer;
begin
	result := ADefault;
	for i := 1 to ParamCount-1 do
		if ParamStr(i)=ASwitch then
			result := ParamStr(i+1);
end;

var m : string;

initialization

  // get the home directory
  GhostConfPath := GetEnvironmentVariable('HOME');
  if GhostConfPath = '' then
    raise Exception.Create('Enviroment variable "HOME" is not set!');
  if not DirectoryExists(GhostConfPath) then
    raise Exception.Create('Home directory "' + GhostConfPath + '" do not exist!');
  GhostConfPath := GhostConfPath + PathDelim+'.ghost'+PathDelim;
  ForceDirectories(GhostConfPath);
  // find mode
  m := CmdLineSwitchValue('-m','en');
  if m = '' then
  	raise Exception.Create('Undefined mode, use switch: -m <mode>');
  GhostConfLang := m;
  if not DirectoryExists(GhostConfPath+GhostConfLang) then
  	raise Exception.Create('Config directory "'+GhostConfPath+GhostConfLang+'" doesn''t exists');

finalization

end.
