unit instructions;

{*
Ghost virtual machine instructions - not finished yet
}

interface

uses SysUtils, Classes, NilVMs;

var
  InOut : array of longint;

function GhostHalt(var code : array of longint; var pc : longint) : boolean;
function GhostNop(var code : array of longint; var pc : longint) : boolean;
function GhostIn(var code : array of longint; var pc : longint) : boolean;
function GhostOut(var code : array of longint; var pc : longint) : boolean;

implementation

function GhostHalt(var code : array of longint; var pc : longint) : boolean;
begin
  // halt program execution
  result := false;
end;

function GhostNop(var code : array of longint; var pc : longint) : boolean;
begin
  // no operation
  result := true;
end;

function GhostIn(var code : array of longint; var pc : longint) : boolean;
//var o : integer;
begin
  // input - any question is added to the end of bytecode cause there is nothing better to do with it
  result := false;
{  o :=                   FIXME: eeeeee fuj, asi by to chcelo objektovu pamat, jedno na otazky, jedno na odpovede, atd...
  SetLength(code,high(code)+1+high(inout));
  for i := 0 to High(InOut) do}


end;

function GhostOut(var code : array of longint; var pc : longint) : boolean;
begin
  // out
  result := false;
end;

initialization

finalization

end.
