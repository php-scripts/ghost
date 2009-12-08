unit readlines;

{*
libreadline wrapper - more user friendly console input and history support
Usage: 
      
  var s : string;
  begin
    readlines.readln('>> ',s);
    writeln(s);
  end;
}

{$ifdef FPC}
{$MODE objfpc}
{$H+}
{$LINKLIB ncurses}
{$LINKLIB readline}
{$LINKLIB history}
{$LINKLIB c}
{$endif}

interface

{$ifdef FPC}
uses Strings;
{$endif}

procedure ReadLn(var ss : string; prefix : string = '');

implementation

{$ifdef FPC}
function readline(prompt: pchar):pchar; cdecl; external 'readline' name 'readline';
procedure using_history(); cdecl; external 'history' name 'using_history';
procedure add_history(s:pChar); cdecl; external 'history' name 'add_history';

var
  s : pChar;

procedure ReadLn(var ss : string; prefix : string);
begin
  s := readline(pchar(prefix));
  add_history(s);
  ss := string(s);
end;
{$else}
procedure ReadLn(var ss : string; prefix : string);
begin
	write(prefix);
	system.readln(ss);	
end;
{$endif}

initialization

{$ifdef FPC}
  s := nil;
  using_history();
{$endif}

finalization

end.
