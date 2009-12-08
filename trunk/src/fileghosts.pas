unit fileghosts;

{*
Ghost which read questions from file (usualy lurker's log) and analyze it at once, or print only questions for which answer is unknown 
}

interface

uses SysUtils, Classes, ghosts, dumbs;

{$IFNDEF FPC}
{$APPTYPE CONSOLE}
{$ENDIF}

type
  TFileGhost = class(TGhost)
  	Position : integer;
  	Questions : TStringList;
    constructor Create; override;
    procedure Ask; override;
    procedure Reply; override;
    procedure Commands; override;
  end;

implementation

{ TConsoleGhost }

constructor TFileGhost.Create; 
{*
Load questions file from 'aaa'
}
begin
  inherited;
  Dumb.Enabled := false;
  Questions := TStringList.Create;
  Questions.LoadFromFile('aaa');
  Position := 0;  
end;

procedure TFileGhost.Ask;
{*
Read question from stdin
}
begin
  if Position > Questions.Count-1 then
  	halt;
  Question := Questions[Position];
  inc(Position);
  WhoAsk := '';
end;

procedure TFileGhost.Reply;
{*
Print the answer to stdout
}
begin
	if Answer <> '' then
	begin
		writeln('QQQ> ',Question);
		writeln('AAA> ',Answer);
	end else
	begin
		writeln(Question);
		writeln(Answer);
	end;
end;

procedure TFileGhost.Commands;
{*
Additional commands
}
begin
  inherited;
end;

end.
