unit nilvms;

{*
Complete Virtual Machine for NIL (NonImplemented Language)

Features:
- loading bytecode from file, saving bytecode to file
- runtime adding of bytecode
- runtime adding of instructions
- step, run, stop
- simple infinite loop protection

TODO: something to indicate errorcode when wm is stoped by false instruction return
}

{$IFDEF FPC}
{$MODE objfpc}
{$ENDIF}


interface

{ NIL Instruction }
type TNilInst = function(var code : array of longint; var pc : longint) : boolean;

{ NIL Virtual Machine }
type
  TNilVM = class
    private
    public
      code : array of longint;    // program bytecode
      inst : array of TNilInst;   // instructions lookup table
      pc : longint;               // program counter
      limit : longint;            // limit of executing

      { constructors }
      constructor Create;
      destructor Destroy; override;
      procedure Clear;

      { code operations }
      function AddCode(value : longint) : longint;
      function InsertCode(index, value : longint) : boolean;
      function SetCodeCount(i : longint) : boolean;

      { instruction operations }
      function AddInst(opcode : longint; p : TNilInst; replace : boolean = false) : boolean;
      function SetInst(index : longint; p : TNilInst) : boolean;
      function SetInstCount(i : longint) : boolean;

      { execution }
      function Step : boolean;
      function Run(lim : longint) : boolean;
      function Stop : boolean;
      function Reset : boolean;

      { loading / saving code - only strict byte code nil for now and forever }
      function LoadCode(fname : string) : boolean;
      function SaveCode(fname : string) : boolean;
    end;

implementation

{ TNilVM }

constructor TNilVM.Create;
{*
Allocate virtual machine
}
begin
  setlength(code,0);
  setlength(inst,0);
  pc := 0;
end;

destructor TNilVM.Destroy;
{*
Free virtual machine
}
begin
  setlength(inst,0);
  setlength(code,0);
  inherited;
end;

function TNilVM.AddCode(value: longint): longint;
{*
Add new item to code
}
var m : longint;
begin
  m := high(code)+1;
  setlength(code,m+1);
  code[m]:=value;
  result := m;
end;

function TNilVM.InsertCode(index, value: longint): boolean;
{*
Insert new item to code
}
var m,i : longint;
begin
  m := high(code)+1;
  result := (index>0) and (index<m);
  if not result then exit;
  setlength(code,m+1);
  for i:=index to m-1 do
    code[i+1]:=code[i];
  code[index]:=value;
end;

function TNilVM.SetInst(index: longint; p: TNilInst): boolean;
{*
Add new instruction
}
begin
  result := (index >= 0)and(index <= high(inst));
  if result then
    inst[index] := p;
end;

function TNilVM.SetInstCount(i: longint): boolean;
{*
Set the count of implemented instruction
}
begin
  result := i >= 0;
  if result then
    setlength(inst,i);
end;

function TNilVM.Step: boolean;
{*
Execute next instruction
}
var i : longint;
begin
  result := false;
  if limit < 0 then exit;
  limit := limit - 1;
  if (pc>=0)and(pc<=high(code)) then
    begin
      i := code[pc];
      if (i>=0)and(i<=high(inst))and(assigned(inst[i])) then
        result := inst[i](code,pc);
      pc := pc + 1;
    end;
end;

function TNilVM.Run(lim : longint): boolean;
{*
Run the bytcode, but not more then [lim] count of instructions
}
begin
  Limit := lim;
  while step and (limit > 0) do
    limit := limit - 1;
  result := limit > 0;
end;

function TNilVM.LoadCode(fname: string): boolean;
{*
Load byte code from file
}
var f : file of longint;
    p : array[0..8191] of longint;
    i,r : longint;
begin
  result := false;
  assignfile(f,fname);
  {$I-}
  system.reset(f);
  {$I+}
  if IOResult<>0 then
    exit;
  i := FileSize(f);
  if i<=0 then
    begin
      closefile(f);
      exit;
    end;
  SetCodeCount(i);
  BlockRead(f,p,i,r);
  if r=i then
    begin
      for i:=0 to r-1 do
        code[i]:=p[i];
      result:=true;
    end;
  closefile(f);
end;

function TNilVM.SaveCode(fname: string): boolean;
{*
Save code
}
var f : file of longint;
    p : array[0..8191] of longint;
    i,r,k : longint;
begin
  assignfile(f,fname);
  {$I-}
  rewrite(f);
  {$I+}
  i := high(code)+1;
  for k:=0 to i-1 do
   p[k]:=code[k];
  blockwrite(f,p,i,r);
  result := r = i;
  closefile(f);
end;

function TNilVM.SetCodeCount(i: longint): boolean;
{*
Set code length
}
var oldlen, k : longint;
begin
  oldlen := high(code);
  setlength(code,i);
  for k:=oldlen+1 to i-1 do
    code[k] := 0;
  result := true;
end;

function TNilVM.AddInst(opcode: longint; p: TNilInst; replace : boolean): boolean;
{*
Add new instruction at specified position
}
var m : longint;
begin
  result := false;
  m := high(inst)+1;
  if opcode >= m then
    begin
      m := m + 1;
      if m<opcode then m := opcode;
      setlength(inst,m);
      inst[opcode]:=p;
      result := true;
    end else
      if replace {or (opcode=0)} then
        begin
          inst[opcode] := p;
          result := true;
        end;
end;

function TNilVM.Stop: boolean;
{*
Stop VM execution
}
begin
  limit := -1;
  result := true;
end;

procedure TNilVM.Clear;
{*
Clear VM
}
begin
  SetCodeCount(0);
  SetInstCount(0);
  pc := 0;
  limit := 1000;
end;

function TNilVM.Reset: boolean;
{*
Stop VM and reset PC
}
begin
  Stop;
  pc := 0;
  result := true;
  limit := 1000;
end;

end.
