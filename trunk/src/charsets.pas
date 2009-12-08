unit charsets;

{*
Very simple charset conversion tools
}

interface

function CP1250ToAscii(s : string) : string;
function SimpleCharsetConversion(s : string; orig, reco : string) : string;

implementation

function SimpleCharsetConversion(s : string; orig, reco : string) : string;
{*
Convert string from original to new charset
}
var i,a : integer;
begin
  if length(orig)<>length(reco) then exit;
  for i := 1 to length(s) do
    begin
      a := pos(s[i],orig);
      if a > 0 then s[i] := reco[a];
    end;
  result := s;
end;

function CP1250ToAscii(s : string) : string;
{*
Convert CP1250 to ASCII
}
const ORIG = 'áÁäÄèÈïÏéÉìÌíÍ¾¼òÒóÓôÔàÀøØšŠúÚùÙıİ';
      RECO = 'aAaAcCdDeEeEiIlLnNoOoOrRrRsStTuUuUyYzZ';
begin
  result := SimpleCharsetConversion(s,ORIG,RECO);
end;

end.
    
    
