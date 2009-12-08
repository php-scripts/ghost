unit sams;

{*
Simple question-answer ai module
}

interface

uses Classes, SysUtils, configs, sentences;

type
	TSam = class(TStringList)
	protected
		FCache : TStringList;
	public
        constructor Create(AFileName : string); virtual;
		destructor Destroy; override;
		function Answer(AQuestion : string) : string; virtual;
    procedure TransformAttributes;
	end;
    
var 
	Sam : TSam;
	Dialect : TSam;
	Attribute : TSam;
	Fisher : TSam;

implementation

uses StrUtils;

constructor TSam.Create(AFileName : string);
{*
Load database, allocate answer cache
}
begin
	if FileExists(GhostConfPath+GhostConfLang+PathDelim+AFileName) then
		LoadFromFile(GhostConfPath+GhostConfLang+PathDelim+AFileName);
	FCache := TStringList.Create;
end;

destructor TSam.Destroy;
{*
Release cache
}
begin
	FCache.Free;
	inherited;
end;

function TSam.Answer(AQuestion : string) : string;
{*
Find answer to question, if there are more answers, return random one
}
var i : integer;
begin
	FCache.Clear;
	for i := 0 to (Count div 2) - 1 do
		if Strings[i*2] = AQuestion then
			FCache.Add(Strings[i*2+1]);
	result := '';
	if FCache.Count>0 then
		result := FCache.Strings[random(FCache.Count)];
end;

procedure TSam.TransformAttributes;
{*
Convert all attributes to it's values, e.g. $nick; to real nick
}
var i,a : integer;
begin
  for a := 0 to Attribute.Count div 2 - 1 do
    for i := 0 to Count-1 do
      Strings[i] := AnsiReplaceStr(Strings[i],Attribute[a*2],Attribute[a*2+1]);
end;

var i,a : integer;

initialization

  Attribute := TSam.Create('attribute.dat');
  Sam := TSam.Create('sam.dat');
  Sam.TransformAttributes;
  Dialect := TSam.Create('dialect.dat');
  Fisher := TSam.Create('fisher.dat');
  
  // add -a <attribute> from command line, e.g. -a learn disabled -a fisher enabled -a foo bar
  for i := 1 to ParamCount-2 do
  	if ParamStr(i) = '-a' then
	begin
	  a := Attribute.IndexOf(ParamStr(i+1));
	  if a >= 0 then
	      Attribute[a+1] := ParamStr(i+2)
	  else begin	  
	      Attribute.Add(ParamStr(i+1));
    	  Attribute.Add(ParamStr(i+2));
	  end;
	end;

finalization

  Sam.Free;
  Dialect.Free;
  Attribute.Free;
  Fisher.Free;

end.
