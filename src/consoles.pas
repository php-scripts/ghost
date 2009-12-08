unit consoles;

{*
Console version of ghost
}

interface

uses SysUtils, Classes, ghosts;

{$IFNDEF FPC}
{$APPTYPE CONSOLE}
{$ENDIF}

type
  TConsoleGhost = class(TGhost)
    procedure Ask; override;
    procedure Reply; override;
    procedure Commands; override;
  end;

implementation

{ TConsoleGhost }

procedure TConsoleGhost.Ask;
{*
Read question from stdin
}
begin
  write('you> ');
  readln(Question);
  WhoAsk := '';
end;

procedure TConsoleGhost.Reply;
{*
Print the answer to stdout
}
begin
  writeln('him> ',Answer);
end;

procedure TConsoleGhost.Commands;
{*
Additional commands
}
begin
  inherited;
end;

end.
