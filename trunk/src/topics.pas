unit topics;

{*
Topic search and answer AI module
}

interface

uses SysUtils, Classes, StrUtils, Sams;

type
  TTopic = class(TSam)
  protected
  public
    function Answer(AQuestion: String): String; override;
  end;

var
  Topic : TTopic;

implementation

{ TTopic }

function TTopic.Answer(AQuestion: String): String;
{*
Match all topic expressions against sentence
}
var i,j : integer;
    s : string;
    re : TStringList;
    c : char; // first character indicate match case, *=enywhere, ^=begin with, $=end with
begin
  i := 0;
  re := TStringList.Create;
  FCache.Clear;
  AQuestion := AnsiLowerCase(AQuestion);
  while i<Count-1 do
  begin
    if Strings[i] = '[TOPIC]' then
    begin
      inc(i);
      re.Clear;
      while Strings[i] <> '[TOPIC END]' do
      begin
        s := Strings[i];
        c := copy(s+'*',1,1)[1];
        case c of
          // matches
          '^': if pos(copy(s,2,maxint),AQuestion)=1 then for j := 0 to re.Count-1 do FCache.Add(AnsiReplaceStr(re[j],'#',copy(s,2,maxint)));
          '$': if (pos(copy(s,2,maxint),AQuestion)>0)and(pos(copy(s,2,maxint),AQuestion)=length(AQuestion)-length(s)+2) then for j := 0 to re.Count-1 do FCache.Add(AnsiReplaceStr(re[j],'#',copy(s,2,maxint)));
          '*': if pos(copy(s,2,maxint),AQuestion)>0 then for j := 0 to re.Count-1 do FCache.Add(AnsiReplaceStr(re[j],'#',copy(s,2,maxint)));
        else
          // add reply to re
          re.Add(s);
        end;
        // next line
        inc(i);
      end;
    end;
    inc(i);
  end;
  // return random line from cache
  result := '';
  if FCache.Count > 0 then
    result := FCache[random(FCache.Count)];
  re.Free;
end;

initialization

  Topic := TTopic.Create('topic.dat');

finalization

  Topic.Free;

end.
