unit indexes;

{*
Dead simple word indexing engine
It is intended for use in nilwm which operato with integers rather then words
}

interface

uses
  SysUtils,
  Classes,
  configs;

type
  TIndex = class(TStringList)
  protected
    FLog: string;
    FCurrent: TStringList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Parse(AWords: TStrings); virtual;
    procedure DebugCurrent; virtual;
  published
    property Current: TStringList read FCurrent;
  end;

var
  Index: TIndex;

implementation

{ TIndex }

constructor TIndex.Create;
{*
Alocate list of currently indexed words, load all known words from file
}
begin
  FCurrent := TStringList.Create;
  FLog := GhostConfPath + GhostConfLang +PathDelim+ 'index.dat';
  if FileExists(FLog) then
    LoadFromFile(FLog);
end;

procedure TIndex.DebugCurrent;
{*
Print current indexes to stdout
}
var
  i: integer;
begin
  for i := 0 to FCurrent.Count - 1 do
    writeln('  index.current[', i: 2, '] = __', FCurrent[i], '__');
end;

destructor TIndex.Destroy;
{*
Save index
}
begin
  FCurrent.Free;
  SaveToFile(FLog);
  inherited;
end;

procedure TIndex.Parse(AWords: TStrings);
{*
Analyze words and give them index, add new words to index if they are not allready there, save index
}
var
  i, o, k: integer;
begin
  o := Count;
  FCurrent.Clear;
  for i := 0 to AWords.Count - 1 do
  begin
    k := IndexOf(AWords[i]);
    if k < 0 then
    begin
      Add(AWords[i]);
      k := Count;
    end;
    FCurrent.Add(IntToStr(k));
  end;
  if Count <> o then
    SaveToFile(FLog);
end;

initialization

  Index := TIndex.Create;

finalization

  Index.Free;

end.

