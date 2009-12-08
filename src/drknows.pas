unit drknows;

{*
AI for simple encyclopedical info, answer questions like "what is it XXXX", "what time it is", etc
Name inspired by movie AI
HISTORY
    Wed Dec 31 21:05:28 2003 - zaciatok vyvoja, prepis MAS
    Wed Dec 31 21:50:23 2003 - prva verzia hotova
    Thu Jan  1 13:11:51 2004 - cas a datum
    Thu Jan  1 13:55:28 2004 - matematika
    Thu Jan  1 14:27:45 2004 - vypis vysledkov typu int nie typu cislo.00
    Thu Jan  1 15:21:10 2004 - realne cisla 3.14 3,14
    Thu Jan  1 15:29:36 2004 - pi, sin, cos, exp, ln, sqrt ...
    Sat Feb  7 19:02:01 2004 - zmena cesty k suborom
    Mon Mar 29 20:11:15 2004 - kolko mas hodin, jaky je cas
    Tue 03 Apr 2007 11:20:42 PM CEST - kompletne prepisanie
}

interface

uses Classes, SysUtils, configs, sentences, sams;

type
	TDrKnow = class(TSam)
	public
		function Answer(AQuestion : string) : string; override;
	end;
    
var 
	DrKnow : TDrKnow;

implementation

function TDrKnow.Answer(AQuestion : string) : string;
{*
Search for dictionary terms like "what is", "what is it"
}
var vec : string;
begin
	result := '';
	// what is it
	//writeln('__',sentence.Part(0,2),'__');
	if (sentence.Part(0,2) = 'co je to')
	or (sentence.Part(0,2) = 'co to je') then
	begin
		vec := LowerCase(sentence.Part(3,-1));
		result := inherited Answer(vec);
		exit;
	end;
	// what is
	if sentence.Part(0,1) = 'co je' then
	begin
		vec := LowerCase(sentence.Part(2,-1));
		result := inherited Answer(vec);
		exit;
	end;
end;

initialization

  DrKnow := TDrKnow.Create('drknow.dat');

finalization

  DrKnow.Free;

end.
    
    
    