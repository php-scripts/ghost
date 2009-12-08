unit lurkers;

{*
This AI module never know the answer, but he remember every question and store it to log
}

interface

uses
  SysUtils,
  Classes,
  configs;

type
  TLurker = class(TStringList)
  protected
    FLogName: string;
    FLogSavedAt: TDateTime;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Answer(AQuestion: string): string;
    procedure Save;
  end;

var
  Lurker: TLurker;

implementation

uses DateUtils;

{ TDumb }

function TLurker.Answer(AQuestion: string): string;
{*
Log question, but never answer
}
begin
  Add(AQuestion);
  // kazdych niekolko sekund zapiseme log
  if SecondsBetween(now, FLogSavedAt) > 10 then
  begin
    if Count > 0 then
      SaveToFile(FLogName);
    FLogSavedAt := now;
  end;
  result := '';
end;

constructor TLurker.Create;
{*
Prepare log
}
begin
  ForceDirectories(GhostConfPath + 'lurker');
  FLogName := GhostConfPath + 'lurker'+PathDelim+'lurker_' + FormatDateTime('yyyymmdd_HHMMSS', now) + '.dat';
end;

destructor TLurker.Destroy;
{*
When application ends, save the log
}
begin
  if Count > 0 then
    SaveToFile(FLogName);
  inherited;
end;

procedure TLurker.Save;
{^
Save lurker log imediately, used externally for logging learned answers or other important stuff
}
begin
  SaveToFile(FLogName);
end;

initialization

  Lurker := TLurker.Create;

finalization

  Lurker.Free;

end.

