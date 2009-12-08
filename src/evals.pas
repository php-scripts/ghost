unit evals;

{*
AI module that responds to complex math questions and questions about time and date
}

interface

uses Classes, SysUtils, StrUtils, configs, evalengines, sams;

type
	TEval = class(TSam)
	protected
		KXAEvalEngine : TXAEvalEngine;
	public
		constructor Create(AFileName : string); override;
		destructor Destroy; override;
		function Answer(AQuestion : string) : string; override;
	end;
    
var 
	Eval : TEval;

implementation

constructor TEval.Create(AFileName : string);
{*
Initialize evaluator
}
begin
	inherited Create(AFileName);
	KXAEvalEngine := TXAEvalEngine.Create;
end;

destructor TEval.Destroy;
{*
Release evaluator
}
begin
	KXAEvalEngine.Free;
	inherited;
end;

function TEval.Answer(AQuestion : string) : string;
{*
Evaluate expression
}
var
	vyraz : string;
	s : string;
	i : integer;
procedure v(prefix : string);
var 
	a,b : integer;
begin
	if vyraz <> '' then exit;
	a := pos(prefix,s);
	b := length(prefix);
	if a=1 then
		vyraz := trim(copy(s,b+1,length(s)));
end;
begin
	s := AnsiReplaceText(AQuestion,'?','');
	result := '';
	// time
	if inherited Answer(AQuestion) = '$time;' then
	begin
		// format
		case random(2) of
			0: result := FormatDateTime('HH:MM',now);
			1: result := FormatDateTime('HH:MM:SS',now);
		end;
		// salt prefix
		result := inherited Answer('$timereply;') + ' ' + result;
		exit;
	end;
	// date
	if inherited Answer(AQuestion) = '$date;' then
	begin
		// format
		case random(2) of
			0: result := FormatDateTime('d.m.yyyy',now);
			1: result := FormatDateTime('d.m',now);
		end;
		// salt prefix
		result := inherited Answer('$datereply;') + ' ' + result;
		exit;
	end;
	// eval
	vyraz := '';
	for i := 0 to Count-2 do
		if i mod 2 = 0 then
			if Strings[i] = '$eval;' then
				v(Strings[i+1]);
	if vyraz <> '' then
	begin
		if pos('!',vyraz)>0 then
		begin
			result := 'for factorial use fact(n)';
			exit;
		end;
		try
			result := KXAEvalEngine.Evaluate(vyraz);
			if result <> '' then
				if random(3) = 1 then
					result := inherited Answer('$evalreply;') + ' ' + result;
		except
			result := inherited Answer('$fail;');
		end;
	end;
end;

initialization

  Eval := TEval.Create('eval.dat');

finalization

  Eval.Free;

end.
