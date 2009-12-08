unit variations;

{*
AI module which make small variations in question and try search again in SAM
}

interface

uses Classes, SysUtils, StrUtils, sentences, sams;

type
	TVariation = class(TStringList)
	protected
		procedure preloz_znaky_wx;
		procedure preloz_dialekt;
		procedure pridaj_uber_otaznik;
		procedure vynechaj_zbytocny_uvod;
		procedure vynechaj_zbytocne_slova;
		procedure uber_bodku_a_vykricnik;
	public
        function Answer(AQuestion : string) : string;
    end;
    
var 
	Variation : TVariation;

implementation

function TVariation.Answer(AQuestion : string) : string;
{*
Use all combinations of particular small modifications and search it in the sam
}
var i : integer;
    ss : string;
begin
	result := '';
  // lowercase is first modification
	AQuestion := AnsiLowerCase(AQuestion);
	// vytvaranie kombinacii uprav otazok (i := 0 .. 2^pocet_uprav )
	i:=0;
	Clear;
	Add(AQuestion); // direct question was already asked so we don't need to search it again
  result := sam.Answer(AQuestion);
  if result = '' then
	repeat
		inc(i);
		// parse again cause it might change each turn
		Sentence.words := AQuestion;
		// uprava otazky
		if (i and 1) > 0 then vynechaj_zbytocne_slova;
		if (i and 2) > 0 then vynechaj_zbytocny_uvod;
		if (i and 4) > 0 then pridaj_uber_otaznik;
		if (i and 8) > 0 then preloz_dialekt;
		if (i and 16)> 0 then preloz_znaky_wx;
		if (i and 32)> 0 then uber_bodku_a_vykricnik;
		// if sentence actually modified, ask it to sam
		ss := Sentence.Words;
		if IndexOf(ss) < 0 then
		begin
			// remember sentence being asked to sam so we dont ask it again in this turn
      Add(ss);
			result := sam.Answer(ss);
		end;
	until (i>=63)or(result<>'');
	Clear;
end;

procedure TVariation.preloz_znaky_wx;
{*
Convert slang characters w->v, x->ch
}
var s : string;
begin
	// toto prelozi niektore dialektove znaky v celej vete (x->ch,w->v)
	s := Sentence.Words;
	s := AnsiReplaceText(s,'x','ch');
	s := AnsiReplaceText(s,'w','v');
	Sentence.Words := s;
end;

procedure TVariation.preloz_dialekt;
{*
Translate dialect words, this can also be used to fix typos
}
var i : integer;
	s : string;
begin
	// toto prelozi niektore dialektove znaky v celej vete (x->ch,w->v)
	for i:=0 to Sentence.Count-1 do
	begin
		s := Dialect.Answer(Sentence[i]);
		if s <> '' then
			Sentence[i] := s;
	end;
end;

procedure TVariation.pridaj_uber_otaznik;
{*
Add or remove question mark to the end
}
begin
  if Sentence.Count > 0 then 
    if Sentence[Sentence.Count-1] = '?' then
      Sentence.Delete(Sentence.Count-1)
    else
      Sentence.Add('?');
  Sentence.CleanUp;
end;

procedure TVariation.uber_bodku_a_vykricnik;
{*
Remove dot or exclamation mark from the end
}
begin
  if Sentence.Count > 0 then 
  begin
    if Sentence[Sentence.Count-1] = '.' then
      Sentence.Delete(Sentence.Count-1);
    if Sentence[Sentence.Count-1] = '!' then
      Sentence.Delete(Sentence.Count-1);
  end;
  Sentence.CleanUp;
end;

procedure TVariation.vynechaj_zbytocny_uvod;
{*
Ommit unnecessary words from begining
}
begin
	if Sentence.Count <= 0 then 
		exit;
	if (Sentence[0]='a')
	or (Sentence[0]='ale')
	or (Sentence[0]='hm') then
		Sentence.delete(0);
	Sentence.CleanUp;
end;
	       
procedure TVariation.vynechaj_zbytocne_slova;
{*
Ommit unnecessary words from middle
}
var i : integer;
begin
  for i:=Sentence.count-1 downto 0 do
    if (Sentence[i] = ',')
    or (Sentence[i] = '.') then
      Sentence.delete(i);
  Sentence.CleanUp;
end;

initialization

  Variation := TVariation.Create;

finalization

  Variation.Free;

end.
    
    
    
