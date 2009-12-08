unit dumbs;

{*
This AI module know always answer - because it read random answer from ~/.ghost/dumbs.dat
}

interface

uses
  SysUtils,
  Classes,
  configs;

type
  TDumb = class(TStringList)
  public
  	Enabled : boolean;
	constructor Create; virtual;
    function Answer(AQuestion : string): string;
  end;

var
  Dumb: TDumb;

implementation

{ TDumb }

function TDumb.Answer(AQuestion : string): string;
{*
Print random sentence from ~/.ghost/dumbs.dat
}
begin
	if not Enabled then
	begin
		result := '';
		exit;
	end; 
	Randomize;
	// if there is really no answer at all, reply with question + ?
	result := AQuestion+'?';
	if Count > 0 then
		result := Strings[random(count)];
end;

constructor TDumb.Create;
{*
Load dumb data
}
begin
	Enabled := true;
	if FileExists(GhostConfPath + GhostConfLang +PathDelim+ 'dumb.dat') then
		LoadFromFile(GhostConfPath + GhostConfLang +PathDelim+ 'dumb.dat');
end;

initialization

  Dumb := TDumb.Create;

finalization

  Dumb.Free;

end.
