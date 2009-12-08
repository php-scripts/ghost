unit peoples;

{*
Managing of people, when somebody sey my name add him to people list as friend
}

interface

uses Classes, SysUtils, StrUtils, configs, sentences, sams;

type
	TPeople = class(TSam)
	protected
	public
    Enabled : boolean;
		function AddTalker(ANick : string) : boolean;
		function Answer(AQuestion : string) : string; override;
	end;
    
var 
	People : TPeople;

implementation

function TPeople.AddTalker(ANick : string) : boolean;
{*
If somebody say hello to me, add him to people list as talker
}
var i : integer;
	me : string;
	hi,ni : boolean;
begin
	// analyze sentence for greeting and my nick
	result := false;
	hi := false;
	ni := false;
	me := Attribute.Answer('$nick;');
	for i := 0 to Sentence.Count-1 do
	begin
		if Sentence[i]=me then
			ni := true;
		if (Sentence[i] = 'hi')
		or (Sentence[i] = 'hello')
		or (Sentence[i] = 'welcome')
		or (Sentence[i] = 'ahoj')
		or (Sentence[i] = 'nazdar')
		or (Sentence[i] = 'cau') then
			hi := true;
	end;
//	writeln('ni=',ni,' hi=',hi);
	// if sentence contained both greetings and my name, add that person to list of friends temporarily
	if hi and ni then
		if (IndexOf(ANick)=-1)
		or (IndexOf(ANick) mod 2 <> 1) then
		begin
			Add(ANick);
			Add('talker');
			writeln('  pridavam ',ANick,' ako talker');
			result := true;
		end;
end;

function TPeople.Answer(AQuestion : string) : string;
{*
Answer to questions about people
}
const
	s : array[0..6] of string = ('who is ','who is it ','do you know ','you know ','vies kto je ','kto je ','poznas ');
var
	i,a : integer;
	w,n : string;
begin
	result := '';
	w := AnsiReplaceText(sentence.words,'?','');
	// ask for name
	for i := 0 to high(s) do
	begin
		a := pos(s[i],w);
		if a > 0 then
		begin
			n := trim(copy(w,a+length(s[i]),maxint));
			result := inherited Answer(n);
		end;
		if result <> '' then
			break;
	end;
	// who do you know
	if (w = 'who do you know')
	or (w = 'koho poznas') then
	begin
		result := 'i know ';
		for i := 0 to Count-1 do
			if i mod 2 = 0 then
				result := result + Strings[i] + ' ';
	end;
	// who are your friends
	if (w = 'who are your friends')
	or (w = 'kto su tvoji priatelia') then
	begin
		result := 'my friends are ';
		for i := 0 to Count-1 do
			if (i mod 2 = 0)and(Strings[i+1]='friend') then
				result := result + Strings[i] + ' ';
	end;
end;

initialization

  People := TPeople.Create('people.dat');
  People.Enabled := true;

finalization

  People.Free;

end.
