unit typos;

{*
Module for simulating more human behavior by adding typos and to prevent ban by adding random salts to repeated answers
}

interface

uses Classes, SysUtils, configs;

type
	TTypo = class(TStringList)
	protected
		FOld, FOld2 : string;
		KTags : TStringList;
		FDisableOnce : boolean;
	public
		constructor Create; virtual;
		function Answer(AQuestion : string) : string;
		procedure DisableOnce;
	end;
    
var 
	Typo : TTypo;

implementation

constructor TTypo.Create;
{*
Load typo salts
}
begin
	if FileExists(GhostConfPath+GhostConfLang+PathDelim+'typo.dat') then
		LoadFromFile(GhostConfPath+GhostConfLang+PathDelim+'typo.dat');
end;

procedure TTypo.DisableOnce;
{*
Some modules must prevent typo from modifying output, e.g. eval 10+5 != 155
}
begin
  FDisableOnce := true;
end;

function TTypo.Answer(AQuestion : string) : string;
{*
Modify answer slightly
}
var a : integer;
    c : char;
begin
	result := AQuestion;
	if (result='')or(Count=0) then 
		exit;
	// musime zmenit vetu, inak neprejde!
	if (result = FOld)or(result = FOld2) then
	begin
		result := result+' '+Strings[random(Count)];
		while (result = FOld)and(length(result)<250) do
			result := result + ' ' + Strings[random(Count)];
	end; 
	// preklepy
	if (copy(result,1,1)<>'/')and(not FDisableOnce) then
	begin
		// prehodenie dvoch znakov
		if random(100) = 1 then
		begin
			a := random(length(result)-1)+1;
			if length(trim(copy(result,a,2))) = 2 then
			begin
				c := result[a];
				result[a] := result[a+1];
				result[a+1] := c;
			end;
		end;
		// zdvojenie dvoch znakov
		if random(50) = 1 then
		begin
			a := random(length(result))+1;
			result := copy(result,1,a)+copy(result,a,maxint);
		end;
	end;
	FOld2 := FOld;
	FOld := result;
	FDisableOnce := false;
end;

initialization

	Typo := TTypo.Create;

finalization

	Typo.Free;

end.
