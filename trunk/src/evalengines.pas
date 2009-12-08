unit evalengines;

{*
Mathematical formula parser, based on XAEval, slightly modified to remove unnecessary dependencies and to simplify interface
It was modified to be compileable with linux
}

interface

uses SysUtils, Classes;

type
  TVariableType = (vtNone, vtBoolean, vtDateTime, vtFloat, vtInteger, vtString);

  TXAVariable = class(TObject)
    private      
      // Private declarations
      FItemID                : Integer;       // ID Number: Used in Paging
      FName                  : string;        // Name of Variable
      FType                  : TVariableType; // Type of Variable
      FValue                 : string;        // Value of Variable
      FValid                 : Boolean;       // Specifies whether VAR is Valid
      procedure SetName(Name : string);
    protected    
      // Protected declarations
      procedure SetAsBoolean(Value: Boolean);
      procedure SetAsFloat(Value: Double);
      procedure SetAsInteger(Value: Longint);
      procedure SetAsString(const Value: string);
      procedure SetAsDateTime(Value: TDateTime);
      function GetAsBoolean: Boolean;
      function GetAsFloat: Double;
      function GetAsInteger: Longint;
      function GetAsString: string;
      function GetAsDateTime: TDateTime;
    public       
      // Public declarations
      constructor Create(ItemID : Integer; Name : string; VType : TVariableType);
      destructor Destroy; override;
      property ItemID             : Integer      read FItemID         write FItemID;
      property Name               : string       read FName           write SetName;
      property AsBoolean          : Boolean      read GetAsBoolean    write SetAsBoolean;
      property AsFloat            : Double       read GetAsFloat      write SetAsFloat;
      property AsInteger          : LongInt      read GetAsInteger    write SetAsInteger;
      property AsString           : string       read GetAsString     write SetAsString;
      property AsDateTime         : TDateTime    read GetAsDateTime   write SetAsDateTime;
      property Valid              : Boolean      read FValid;
      property IsNull             : Boolean      read FValid;
   end;

  TXAVariableManager = class(TComponent)
    private      
      // Private declarations
      FGroup                 : TList;       // List of Variable Items
      FItemIndex             : Integer;     // Position within the FGroup List
      FBlankVariable         : TXAVariable; // BLANK Variable to prevent errors
      FSafety                : Boolean;     // FLAGS use of Blank Variable
    protected    
      // Protected declarations
      function GetIndex : Integer;
      procedure SetIndex(DIndex : Integer);
      function GetVariable(Index : Word): TXAVariable;
      function GetCount : Integer;
    public      
      // Public declarations
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      property Items[Index: Word] : TXAVariable  read GetVariable;                           default;
      property ItemIndex          : Integer      read GetIndex        write SetIndex;
    published    
      // Published declarations
      property Count              : Integer      read GetCount;
      property ErrorSafety        : Boolean      read FSafety         write FSafety;
      function AddVariable(Value : TXAVariable) : Integer;
      procedure RemoveVariable(Value : TXAVariable);
      procedure DeleteVariable(Index : Integer);
      function LocateVariable(Nam : string) : Integer;
      function VariableByName(Nam : string) : TXAVariable;
      procedure Clear;
      procedure CleanUp;
   end;

  TXAStackTerm = class(TObject)
    private      
      // Private declarations 
      FItemType     : Integer;
      FLevel        : Integer;
    public       
      // Public declarations
      FItem         : string;
      constructor Create(DItem : string; DItemType, DLevel: Integer);
      destructor Destroy; override;
      property Item          : string             read FItem          write FItem;
      property ItemType      : Integer            read FItemType      write FItemType;
      property Level         : Integer            read FLevel         write FLevel;
   end;

  TXAEvalEngine = class
    private      
      // Private declarations 
      FActiveVersion   : Double;
      FVariables       : TXAVariableManager; // Variable Source (Holder)
      FExpression      : string;             // Expression BEFORE Parsing
      FResult          : string;
      procedure SetExpression(dExpression: string);
    protected    
      // Protected declarations
      // -- SYSTEM LEVEL INTERACTIVE FUNCTION(S)
    private      
      // -- General Purpose Routines
      function ListFirst(dValue: string; dLimiter: Char) : string;
      function ListRest(dValue: string; dLimiter: Char) : string;
      // -- SPACE Specification Routines
      function GetElementType(dElement: Char) : Integer;
      function SpecSPACEs(dEquation: string) : string;
      // -- Expression Restructuring Routines
      function IsExtFunction(dItem: string) : Boolean;
      function GetItemType(dItem: string; dUnique: Integer) : Integer;
      procedure ItemAction(var dExpression: string; var dItem: string);
      procedure StackAction(var dStack: TList; var dExpression: string;
                            dItem: string; dLevel: Integer);
      function SpecStructure(dExpression: string) : string;
      // -- Generate Equation Evaluation Structure and Evaluate Variables
      procedure SpecEquation(var dEquationStack: TStringList; dExpression: string);
      procedure SpecExternalData(var dEquationStack: TStringList);
      // -- Resolve equation and return result
      function ConvertFloat(dValue: string) : Double;
      function ResolveAction(dItem, dValue1, dValue2: string): string;
      function ResolveEquation(var dEquationStack: TStringList): string;
    public       
      // Public declarations   
      constructor Create;
      destructor Destroy; override;
      function Prepare : Boolean;
      function PrepareExpression(dExpression: string): string;
      function Execute: Boolean;
      function Evaluate(dExpression: string): string;
      procedure Clear;
    published    
      // Published declarations
      property Expression    : string             read FExpression    write SetExpression;
      property Result        : string             read FResult        write FResult;
      property Variables     : TXAVariableManager read FVariables     write FVariables;
   end;

implementation

constructor TXAVariable.Create(ItemID : Integer; Name : string; VType : TVariableType);
begin
  inherited Create;
  FItemID := ItemID;
  FName := '<#NONE#>';
  FType := vtNone;
  FValue := '';
  if ((Name <> '') and (VType <> vtNone)) then
  begin
    FName := UpperCase(Name);
    FType := VType;
    case FType of
    vtBoolean, vtInteger, vtFloat, vtDateTime : FValue := '0';
                                           else FValue := '';
    end;
  end;
  FValid := ((FName <> '<#NONE#>') and (FType <> vtNone));
end;

destructor TXAVariable.Destroy;
begin
  inherited Destroy;
end;

procedure TXAVariable.SetName(Name : string);
begin
  FName := UpperCase(Name);
end;

procedure TXAVariable.SetAsBoolean(Value: Boolean);
begin
  FType := vtBoolean;
  FValue := IntToStr(Trunc(Ord(Value)));
end;

procedure TXAVariable.SetAsFloat(Value: Double);
begin
  FType := vtFloat;
  FValue := FloatToStr(Value);
end;

procedure TXAVariable.SetAsInteger(Value: Longint);
begin
  FType := vtInteger;
  FValue := IntToStr(Trunc(Value));
end;

procedure TXAVariable.SetAsString(const Value: string);
begin
  FType := vtString;
  FValue := Value;
end;

procedure TXAVariable.SetAsDateTime(Value: TDateTime);
begin
  FType := vtDateTime;
  FValue := DateToStr(Value);
end;

function TXAVariable.GetAsBoolean: Boolean;
begin
  case FType of
  vtBoolean, vtInteger : Result := Boolean(StrToIntDef(FValue,0));
               vtFloat : Result := Boolean(Trunc(StrToFloat(FValue)));
                    else Result := False;
  end;
end;

function TXAVariable.GetAsFloat: Double;
begin
  case FType of
  vtBoolean, vtInteger : Result := StrToFloat(FValue);
   vtFloat, vtDateTime : Result := StrToFloat(FValue);
                    else Result := 0;
  end;
end;

function TXAVariable.GetAsInteger: Longint;
begin
  case FType of
  vtBoolean, vtInteger : Result := StrToIntDef(FValue,0);
   vtFloat, vtDateTime : Result := Trunc(StrToFloat(FValue));
                    else Result := 0;
  end;
end;

function TXAVariable.GetAsString: string;
begin
  Result := FValue;
end;

function TXAVariable.GetAsDateTime: TDateTime;
begin
  case FType of
  vtDateTime : Result := StrToDateTime(FValue);
          else Result := 0;
  end;
end;

constructor TXAVariableManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGroup := TList.Create;
  FGroup.Clear;
  FItemIndex := -1;
  FBlankVariable := TXAVariable.Create(0,'<#BLANK#>',vtString);
  FBlankVariable.AsString := '0';
  FSafety := True;
end;

destructor TXAVariableManager.Destroy;
var
  ovLoop                     : Integer;
begin
  FBlankVariable.Free;
  for ovLoop := (FGroup.Count - 1) downto 0 do
    TXAVariable(FGroup.Items[ovLoop]).Free;
  FGroup.Clear;
  FGroup.Free;
  inherited Destroy;
end;

procedure TXAVariableManager.SetIndex(DIndex : Integer);
begin
  if (FGroup.Count <> 0) and (DIndex >= -1) and (DIndex < (FGroup.Count)) then
       FItemIndex := DIndex
  else FItemIndex := -1;
end;

function TXAVariableManager.GetIndex : Integer;
begin
  Result := FItemIndex;
end;

function TXAVariableManager.GetVariable(Index : Word): TXAVariable;
begin
  if (Index < FGroup.Count) and (FGroup.Count <> 0) then
       Result := TXAVariable(FGroup.Items[Index])
  else if (FSafety) then Result := FBlankVariable
                    else Result := nil;
end;

function TXAVariableManager.GetCount : Integer;
begin
  Result := FGroup.Count;
end;

function TXAVariableManager.AddVariable(Value : TXAVariable) : Integer;
begin
  if (LocateVariable(Value.Name) = -1) then Result := FGroup.Add(Value)
                                       else Result := -1;
end;

procedure TXAVariableManager.RemoveVariable(Value : TXAVariable);
var
  ovLoop                     : Integer;
begin
  for ovLoop := 0 to (FGroup.Count - 1) do
  if (Value = TXAVariable(FGroup.Items[ovLoop])) then 
    FGroup.Remove(Value);
end;

procedure TXAVariableManager.DeleteVariable(Index : Integer);
begin
  if (FGroup.Count <> 0) and (Index > -1) and (Index < (FGroup.Count)) then
    FGroup.Delete(Index);
end;

function TXAVariableManager.LocateVariable(Nam : string) : Integer;
var
  ovLoop                     : Integer;
begin
  Result := -1;
  Nam := UpperCase(Nam);
  for ovLoop := 0 to (FGroup.Count - 1) do
  if (Nam = TXAVariable(FGroup.Items[ovLoop]).Name) then Result := ovLoop;
end;

function TXAVariableManager.VariableByName(Nam : string) : TXAVariable;
var
  ovLoop                     : Integer;
begin
  Result := nil;
  Name := UpperCase(Name);
  for ovLoop := 0 to (FGroup.Count - 1) do
  if (Name = TXAVariable(FGroup.Items[ovLoop]).Name) then
    Result := TXAVariable(FGroup.Items[ovLoop]);
  if FSafety and (Result = nil) then Result := FBlankVariable;
end;

procedure TXAVariableManager.Clear;
var
  ovLoop                     : Integer;
begin
  for ovLoop := (FGroup.Count - 1) downto 0 do
    TXAVariable(FGroup.Items[ovLoop]).Free;
  FGroup.Clear;
end;

procedure TXAVariableManager.CleanUp;
var
  ovLoop                     : Integer;
begin
  for ovLoop := (FGroup.Count - 1) downto 0 do
  if (not TXAVariable(FGroup.Items[ovLoop]).Valid) then
    TXAVariable(FGroup.Items[ovLoop]).Free;
end;

constructor TXAStackTerm.Create(dItem : string; dItemType, dLevel: Integer);
begin
  inherited Create;
  FItem := dItem;
  FItemType := dItemType;
  FLevel := dLevel;
end;

destructor TXAStackTerm.Destroy;
begin
  inherited Destroy;
end;

constructor TXAEvalEngine.Create;
begin
  inherited;
  FActiveVersion := 1.1;
  FExpression := '';
  FResult := '';
  FVariables := nil;
end;

destructor TXAEvalEngine.Destroy;
begin
  inherited Destroy;
end;

procedure TXAEvalEngine.SetExpression(dExpression: string);
begin
  FExpression := dExpression;
  FResult := '';
end;

function TXAEvalEngine.ListFirst(dValue: string; dLimiter: Char) : string;
var
  ovMark                     : Integer;
begin
  ovMark := pos(dLimiter,dValue);
  if (ovMark = 0) then ovMark := (length(dValue) + 1);
  Result := copy(dValue,1,ovMark-1);
end;

function TXAEvalEngine.ListRest(dValue: string; dLimiter: Char) : string;
var
  ovMark                     : Integer;
begin
  Result := '';
  ovMark := pos(dLimiter,dValue);
  if (ovMark = 0) then
       Result := ''
  else Result := copy(dValue,ovMark+1,(length(dValue)-ovMark));
end;

function TXAEvalEngine.GetElementType(dElement: Char) : Integer;
begin
  case dElement of    ' ' : Result := 1;
                      '(' : Result := 2;
                      ')' : Result := 3;
                      ',' : Result := 4;
                  '+','-' : Result := 5;
  '<','=','>','^','*','/' : Result := 6;
                      '"' : Result := 7;
                       else Result := 8;
  end;
end;

function TXAEvalEngine.SpecSPACEs(dEquation: string) : string;
var
  ovMark                     : Integer;
  ovOItem, ovPItem, ovCItem  : Integer;    // [O]ld  [P]revious  [C]urrent
  ovEquation                 : string;
  ovQuote, ovSpace           : Boolean;
begin
  ovEquation := '';
  ovMark := 0;
  ovQuote := False;
  repeat
    Inc(ovMark);
    ovOItem := -1;
    ovPItem := -1;
    if (dEquation[ovMark] = '"') then ovQuote := not ovQuote;
    if (ovMark > 2) then ovOItem := GetElementType(dEquation[(ovMark-2)]);
    if (ovMark > 1) then ovPItem := GetElementType(dEquation[(ovMark-1)]);
    ovCItem := GetElementType(dEquation[ovMark]);
    ovSpace := (ovPItem in [5,6]) and (ovCItem in [3,5]);
    ovSpace := ovSpace or ((ovPItem in [3,8]) and (ovCItem in [2,8]) and (ovPItem <> ovCItem));
    ovSpace := ovSpace or ((ovPItem = 8) and (ovCItem in [4,5,6]));
    ovSpace := ovSpace or ((ovPItem in [4,6]) and (ovCItem = 8));
    ovSpace := ovSpace or ((ovOItem in [1,8]) and (ovPItem = 5) and (ovCItem = 8));
    ovSpace := (ovSpace and (not ovQuote));
    ovSpace := ovSpace or (ovQuote and (ovPItem = 4) and (dEquation[ovMark]='"'));
    if (ovSpace) then ovEquation := (ovEquation + ' ');
    ovEquation := (ovEquation + dEquation[ovMark]);
  until (ovMark >= Length(dEquation));
  Result := ovEquation;
end;

function TXAEvalEngine.IsExtFunction(dItem: string) : Boolean;
begin
  dItem := UpperCase(dItem);
  Result := (Pos(dItem,'EXPXY SQR SQRT FACT') > 0);
  Result := (Result and (dItem <> ' '));
  // External Function DLL access code removed due to Contractual Restrictions
end;

function TXAEvalEngine.GetItemType(dItem: string; dUnique: Integer) : Integer;
var
  ovMark                     : Integer;
  ovActions                  : string;
begin
  Result := -1;
  dItem := UpperCase(dItem);
  ovActions := 'NOT OR  AND =   <   <=  >   >=  <>  +   -   *   /   MOD DIV ^   ';
  ovMark := pos(dItem,ovActions);
  case ovMark of
      01 : Result := 2;
      05 : Result := 4;
      09 : Result := 6;
  13..33 : Result := (10 + (Trunc((ovMark-13)/4) * dUnique));
  37..41 : Result := (20 + (Trunc((ovMark-37)/4) * dUnique));
  45..57 : Result := (30 + (Trunc((ovMark-45)/4) * dUnique));
      61 : Result := (40 + (Trunc((ovMark-61)/4) * dUnique));
      else if (Result =-1) then
           begin
             if (Pos(dItem,'<CLEAR>') > 0) then Result := 0;
             if IsExtFunction(dItem) then Result := 50;
           end;
  end;
end;

procedure TXAEvalEngine.ItemAction(var dExpression: string; var dItem: string);
begin
  if (dItem <> '') and (dItem <> ',') then
    dExpression := (dItem + chr(13) + dExpression);
  dItem := '';
end;

procedure TXAEvalEngine.StackAction(var dStack: TList; var dExpression: string;
                                    dItem: string; dLevel: Integer);
var
  ovStackTerm                : TXASTackTerm;
  ovLoop, ovLevel            : Integer;
  oviType, ovpType           : Integer;    // [i]tem  [p]arameter
begin
  ovLoop := 0;
  ovpType := GetItemType(dItem,0);
  if (dStack.Count > 0) then
  repeat
    ovStackTerm := TXAStackTerm(dStack.Items[ovLoop]);
    oviType := ovStackTerm.ItemType;
    ovLevel := ovStackTerm.Level;
    if (oviType >= ovpType) and (ovLevel >= dLevel) then
    begin
      ItemAction(dExpression,ovStackTerm.FItem);
      dStack.Delete(ovLoop);
    end;
  until (oviType < ovpType) or (ovLevel < dLevel) or (dStack.Count = 0);
 if (dItem <> '') and (dItem <> '<clear>') then
   dStack.Insert(0,TXAStackTerm.Create(dItem,ovpType,dLevel));
end;

function TXAEvalEngine.SpecStructure(dExpression: string) : string;
var
  ovStack                    : TList;
  ovLoop, ovLevel            : Integer;
  ovItem, ovStackItems       : string;
  ovElement                  : Char;
  ovQuote                    : Boolean;
begin
  ovStackItems := 'AND OR NOT > < >= <= <> = ^ + - / * MOD DIV';
  Result := '';
  ovLevel := 0;
  ovItem := '';
  ovQuote := False;
  try
    ovStack := TList.Create;
    for ovLoop := 1 to Length(dExpression) do
    begin
      ovElement := copy(dExpression,ovLoop,1)[1];
      if (ovElement = '"') then ovQuote := (not ovQuote);
      if (ovQuote) then
           ovItem := (ovItem + ovElement)
      else case ovElement of
           '(' : Inc(ovLevel);
           ')' : begin
                   ItemAction(Result,ovItem);
                   StackAction(ovStack, Result, '', ovLevel);
                   Dec(ovLevel);
                 end;
           ' ' : begin
                   if (Pos(Uppercase(ovItem),ovStackItems) > 0) then
                          StackAction(ovStack, Result, ovItem, ovLevel)
                   else if (not IsExtFunction(ovItem)) then
                             ItemAction(Result,ovItem)
                        else StackAction(ovStack, Result, ovItem, ovLevel);
                   ovItem := '';
                 end;
            else ovItem := (ovItem + ovElement);
           end;
    end;
    ItemAction(Result,ovItem);
    StackAction(ovStack, Result, '<clear>', ovLevel);
  finally
    ovStack.Clear;
    ovStack.Free;
  end;
end;

procedure TXAEvalEngine.SpecEquation(var dEquationStack: TStringList; dExpression: string);
begin
  dEquationStack.Clear;
  while (dExpression <> '') do
  begin
    dEquationStack.Add(ListFirst(dExpression,chr(13)));
    dExpression := ListRest(dExpression,chr(13));
  end;
end;

procedure TXAEvalEngine.SpecExternalData(var dEquationStack: TStringList);
var
  ovLoop                     : Integer;
  ovVarValue, ovItem         : string;
begin
  for ovLoop := 0 to (dEquationStack.Count-1) do
  if (dEquationStack.Strings[ovLoop][1] = ':') then
  begin
    ovItem := dEquationStack.Strings[ovLoop];
    Delete(ovItem,1,1);
    ovVarValue := FVariables.VariableByName(ovItem).AsString;
    dEquationStack.Strings[ovLoop] := ovVarValue;
  end;
end;

function TXAEvalEngine.ConvertFloat(dValue: string) : Double;
var
  ovError                    : Integer;
begin
  VAL(dValue, Result, ovError);
  if (ovError <> 0) then Result := 0;
end;

function FACT(A: real) : real;
begin
	A := round(a);
	result := A;
	while A>2 do
	begin
		a := a-1;
		result := result * A;
	end;
	result := round(result);
end;

function TXAEvalEngine.ResolveAction(dItem, dValue1, dValue2: string): string;
var
  ovParam1, ovParam2         : Double;
begin
  Result := dValue1;
  ovParam1 := ConvertFloat(dValue1);
  ovParam2 := ConvertFloat(dValue2);
  try
    case GetItemType(dItem,1) of
     2 : Result := FloatToStr(Ord(not Boolean(Trunc(ovParam1))));
     4 : Result := IntToStr(Ord(Boolean(Trunc(ovParam1)) or Boolean(Trunc(ovParam2))));
     6 : Result := IntToStr(Ord(Boolean(Trunc(ovParam1)) and Boolean(Trunc(ovParam2))));
    10 : Result := IntToStr(Ord(ovParam1 = ovParam2));
    11 : Result := IntToStr(Ord(ovParam1 < ovParam2));
    12 : Result := IntToStr(Ord(ovParam1 <= ovParam2));
    13 : Result := IntToStr(Ord(ovParam1 > ovParam2));
    14 : Result := IntToStr(Ord(ovParam1 >= ovParam2));
    15 : Result := IntToStr(Ord(ovParam1 <> ovParam2));
    20 : Result := FloatToStr(ovParam1 + ovParam2);
    21 : Result := FloatToStr(ovParam1 - ovParam2);
    30 : Result := FloatToStr(ovParam1 * ovParam2);
    31 : Result := FloatToStr(ovParam1 / ovParam2);
    32 : Result := IntToStr(Trunc(ovParam1) MOD Trunc(ovParam2));
    33 : Result := IntToStr(Trunc(ovParam1) DIV Trunc(ovParam2));
    40 : if (ovParam1 <= 0) then
              Result := '0'
         else Result := FloatToStr(Exp(ovParam2 * Ln(ovParam1)));
    else begin
           if (dItem = 'EXPXY') then
             if (ovParam1 <= 0) then
                  Result := '0'
             else Result := FloatToStr(Exp(ovParam2 * Ln(ovParam1)));
           if (dItem = 'SQR') then Result := FloatToStr(SQR(ovParam1));
           if (dItem = 'SQRT') then Result := FloatToStr(SQRT(ovParam1));
           if (dItem = 'FACT') then Result := FloatToStr(FACT(ovParam1));
           // ***** Other External Function Calls *****
           // External Function DLL operation code removed due to Contractual
           //   Restrictions
         end;
    end;
  finally
  end;
end;

function TXAEvalEngine.ResolveEquation(var dEquationStack: TStringList): string;
var
  ovCount, ovActualCount     : Integer;
  ovParam1, ovParam2, ovData : string;
begin
  Result := '';
  ovCount := dEquationStack.Count;
  try
    while ((dEquationStack.Count > 1) and (ovCount > 0)) do
    begin
      Dec(ovCount);
      ovActualCount := (dEquationStack.Count - 1);
      ovData := UpperCase(dEquationStack.Strings[ovCount]);
      if (pos(ovData, 'AND OR > < >= <= <> = ^ + - / * MOD DIV EXPXY') > 0) then
        if ((ovCount+2) <= ovActualCount) then
        begin
          ovParam1 := dEquationStack.Strings[(ovCount+2)];
          ovParam2 := dEquationStack.Strings[(ovCount+1)];
          dEquationStack.Delete((ovCount+2));
          dEquationStack.Delete((ovCount+1));
          dEquationStack.Delete(ovCount);
          dEquationStack.Insert(ovCount,ResolveAction(ovData, ovParam1, ovParam2));
        end;
      if (pos(ovData, 'NOT SQR SQRT FACT') > 0) then
        if ((ovCount+1) <= ovActualCount) then
        begin
          ovParam1 := dEquationStack.Strings[(ovCount+1)];
          dEquationStack.Delete((ovCount+1));
          dEquationStack.Delete(ovCount);
          dEquationStack.Insert(ovCount,ResolveAction(ovData, ovParam1, '0'));
        end;
    end;
  if (dEquationStack.Count > 0) then Result := dEquationStack.Strings[0];
  finally
  end;
end;

function TXAEvalEngine.Prepare : Boolean;
begin
  if (FExpression <> '') and (pos(Chr(13),FExpression) = 0) then
    FExpression := SpecStructure(SpecSPACEs(FExpression));
  Result := (FExpression <> '');
end;

function TXAEvalEngine.PrepareExpression(dExpression: string): string;
begin
  Result := '';
  if (dExpression <> '') and (Pos(Chr(13),dExpression) = 0) then
    Result := SpecStructure(SpecSPACEs(dExpression));
end;

function TXAEvalEngine.Execute: Boolean;
var
  ovEquation                 : TStringList;
begin
  FResult := '';
  Result := False;
  if (FExpression <> '') then
  try
    ovEquation := TStringList.Create;
    if (pos(Chr(13),FExpression) = 0) then
      FExpression := SpecStructure(SpecSPACEs(FExpression));
    if (pos(Chr(13),FExpression) > 0) then
      SpecEquation(ovEquation,FExpression);
    SpecExternalData(ovEquation);
    FResult := ResolveEquation(ovEquation);
    Result := True;
  finally
    ovEquation.Clear;
    ovEquation.Free;
  end;
end;

function TXAEvalEngine.Evaluate(dExpression: string): string;
begin
  FExpression := dExpression;
  Execute;
  Result := FResult;
end;

procedure TXAEvalEngine.Clear;
begin
  FExpression := '';
  FResult := '';
end;

initialization

finalization

end.
