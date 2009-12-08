unit sentences;

{*
Conversion of sentence to words and back
Changes
    Sun Dec 28 13:01:13 2003 - zacaty vyvoj, uplne rozdelovanie slov
    Sun Dec 28 13:36:28 2003 - opravujem chybu "moja" "skol" "a"
    Sun Dec 28 14:07:35 2003 - delenie slov (extract) funguje
    Sun Dec 28 14:32:51 2003 - vynechanie prazdnych slov a tvorba viet
    Sun Dec 28 14:39:46 2003 - vynechanie znakov >127
    Sun Dec 28 15:00:31 2003 - vynechanie opakujucich sa specialnych znakov
    Sun Dec 28 15:00:54 2003 - mazanie smajlov
    Sun Dec 28 15:44:50 2003 - mazanie zlych zaciatkov a koncov viet (.,!)
    Sun Dec 28 15:53:56 2003 - oprava mensej chyby v odstranovani prazdnych slov (zacinalo od i=1)
    Sun Dec 28 16:01:08 2003 - optimalizacia vynechania slov
    Sun Dec 28 16:48:50 2003 - oprava chyby v optimalizacii (ked nepresuvam, i=j, tak nemazat [i])
    Sun Dec 28 16:53:52 2003 - oddelovanie spojenych spec. znakov (ahoj,... --> ahoj,. --> ahoj, )
    Sun Dec 28 17:10:32 2003 - upravy v tvorbe viet ( 3 (zzz), 7:30, 10-tich, tak-tak )
    Sun Dec 28 17:15:32 2003 - automaticke volanie uprav_vetu a vytvor_vetu v extract
    Sun Dec 28 17:40:04 2003 - (veta) --> veta
    Sun Dec 28 17:58:06 2003 - rovnitko bez medzier
    Sun Dec 28 17:59:09 2003 - ",-" s medzerou za tym
    Sun Dec 28 18:02:14 2003 - : a nie cislo s medzerou medzi tym
    Sun Dec 28 18:13:51 2003 - zakladna uroven dialektu
    Sun Dec 28 23:44:09 2003 - moznost uprav z vonka (vynechavanie '' slov, atd...)
    Sun Dec 28 23:48:49 2003 - oprava nazvu premennej, a oprava mensej chyby
    Tue Dec 30 18:17:51 2003 - posledne_slovo
    Thu Apr  1 20:56:40 2004 - pridavam dncasestr do extractu
    2.apr.2007 21:09:00 CEST - kompletne prepisanie kodu
    16.11.2007 11:56:32 - mierne upravy pre ghost 3.0, ztrojene znaky, podpora diakritiky
    14.10.2009 8:40:25 - komentare zmenene na fpdocp, poanglictene
}

interface

uses SysUtils, Classes, StrUtils;

type
  TSentence = class(TStringList)
  protected
    procedure SetWords(s: string);
    function GetWords: string;
  public
    function IsSplitChar(c: char): boolean; virtual;
    procedure Debug;
    procedure RemoveSmileys;
    procedure RemoveDoubledChars;
    procedure RemoveTripledChars;
    procedure RemoveEmptyWords;
    procedure CleanUp;

    function Part(AFrom, ATo: integer): string;

  published
    property Words: string read GetWords write SetWords;
  end;

var
  sentence: TSentence;

implementation

{ TSentence }

function TSentence.IsSplitChar(c: char): boolean;
{*
Return true if c is special char which can split words
}
begin
  result := c in [
    ',', '.', ' ', ';', ':', '(', ')', '[', ']', '/', '\', '''', '"', '`', '{', '}', '~', '!',
    '@', '#', '$', '%', '^', '&', '*', '_', '+', '-', '=', '|', '<', '>', '?'
    ];
end;

function TSentence.GetWords: string;
{*
Construct sentence from words
}
var
  i: integer;
  c: char;
begin
  result := '';
  for i := 0 to count - 1 do
  begin
    c := copy(strings[i] + 'a', 1, 1)[1];
    {      if (c in ['a'..'z'])
          or (c in ['_'])
          or (c in ['A'..'Z'])
          or (c in ['0'..'9']) then}
    if not IsSplitChar(c) then
    begin
      if i > 0 then
        result := result + ' ';
    end;
    result := result + strings[i];
  end;
end;

procedure TSentence.SetWords(s: string);
{*
Separate sentence to words
}
var
  i: integer;
  poms: string;
begin
  Clear;
  poms := '';
  for i := 1 to length(s) do
    if not IsSplitChar(s[i]) then
      poms := poms + s[i]
    else
    begin
      poms := trim(poms);
      if poms <> '' then
        Add(poms);
      poms := '';
      if s[i] <> #32 then
        Add(s[i]);
    end;
  if poms <> '' then
    Add(poms);
end;

procedure TSentence.CleanUp;
{*
Tune sentence to be more readable
}
begin
  //RemoveDoubledChars; // this is not good for english
  RemoveTripledChars;
  RemoveSmileys;
  RemoveEmptyWords;
end;

procedure TSentence.RemoveEmptyWords;
{*
Remove all empty words
}
var
  i: integer;
begin
  for i := count - 1 downto 0 do
    if strings[i] = '' then
      delete(i);
end;

procedure TSentence.RemoveSmileys;
{*
Remove most smilies ;)
}
var
  i: integer;
  s0, s1, s2: string;
begin
  for i := 0 to count - 1 do
  begin
    // next 3 words
    s0 := strings[i];
    if i + 1 < count then
      s1 := strings[i + 1]
    else
      s1 := '';
    if i + 2 < count then
      s2 := strings[i + 2]
    else
      s2 := '';
    // valid eyes
    if pos(s0, ':;=8B') > 0 then
    begin
      // mouth
      if pos(s1, ')(|PD') > 0 then
      begin
        Strings[i] := '';
        Strings[i + 1] := '';
      end;
      // nose
      if pos(s1, '-oO*+') > 0 then
      begin
        // mounth
        if pos(s2, ')(|PD') > 0 then
        begin
          Strings[i] := '';
          Strings[i + 1] := '';
          Strings[i + 2] := '';
        end;
      end;
    end;
  end;
  RemoveEmptyWords;
end;

procedure TSentence.RemoveDoubledChars;
{*
Remove duplicate characters (nice book --> nice bok ?)
}
var
  i: integer;
  s: string;
  c, oc: char;
begin
  s := Words;
  for i := 2 to length(s) do
    if s[i - 1] = s[i] then
      s[i - 1] := #250;
  Words := AnsiReplaceText(s, #250, '');
  RemoveEmptyWords;
  oc := ' ';
  for i := count - 1 downto 0 do
  begin
    c := copy(strings[i] + ' ', 1, 1)[1];
    if (strings[i] = oc)
      and (
      (c < #48) or
      ((c > #57) and (c < #65)) or
      ((c > #90) and (c < #97)) or
      (c > #122)
      ) then
      strings[i] := '';
    oc := copy(strings[i] + ' ', 1, 1)[1];
  end;
  RemoveEmptyWords;
end;

procedure TSentence.RemoveTripledChars;
{*
Remove three or more same characters in a row
}
var
  i: integer;
  c1, c2, c3: char;
  s: string;
begin
  s := Words;
  c2 := #1;
  c3 := #1;
  for i := 1 to Length(s) do
  begin
    c1 := c2;
    c2 := c3;
    c3 := s[i];
    if (c3 = c1) and (c3 = c2) then
      s[i] := #1
  end;
  Words := AnsiReplaceStr(s, #1, '');
end;

function TSentence.Part(AFrom, ATo: integer): string;
{*
Merge words #a to #b into sub sentence
}
var
  i: integer;
begin
  result := '';
  if AFrom < 0 then
    AFrom := 0;
  if ATo = -1 then
  	ATo := Count-1;
  if AFrom > ATo then
    exit;
  if ATo > Count - 1 then
    ATo := Count - 1;
  for i := AFrom to ATo do
    result := result + ' ' + strings[i];
  if result <> '' then
    result := copy(result, 2, length(result));
end;

procedure TSentence.Debug;
{*
Debug print sentence
}
var
  i: integer;
begin
  for i := 0 to count - 1 do
    writeln('  veta[', i: 2, '] = __', strings[i], '__');
end;

initialization

  sentence := TSentence.Create;

finalization

  sentence.free;

end.

