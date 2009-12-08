unit ghosts;

{*
Simplified interface to make more complex ghosts
}

interface

uses
  SysUtils, Classes, configs, sentences, dumbs, lurkers, indexes, drknows, evalengines, evals, sams, variations, typos, charsets, peoples, topics;

type
  TGhost = class
    Question: string;
    WhoAsk: string;
    Answer: string;
    NeedLearn: boolean;
    constructor Create; virtual;
    procedure Loop; virtual;
    procedure Ask; virtual;
    procedure Think; virtual;
    procedure Commands; virtual;
    procedure Reply; virtual;
  end;

implementation

constructor TGhost.Create;
{*
Remove in/out files, initialize variables
}
begin
  DeleteFile(GhostConfPath + 'in');
  DeleteFile(GhostConfPath + 'out');
  NeedLearn := false;
end;

procedure TGhost.Loop;
{*
Infinite main loop - ask and reply
}
begin
  repeat
    Ask;
    Think;
    Commands;
    Reply;
  until Question = '/quit';
end;

procedure TGhost.Ask;
{*
Get the question
}
begin
  Question := '';
  writeln('Waiting for question in ' + GhostConfPath + 'in');
  while not FileExists(GhostConfPath + 'in') do
    Sleep(200);
  with TStringList.Create do
  try
    LoadFromFile(GhostConfPath + 'in');
    if Count >= 1 then
      Question := trim(Strings[0]);
    WhoAsk := '';
    if Count >= 2 then
      WhoAsk := lowercase(trim(Strings[1]));
    writeln('  Question by ', WhoAsk, ' loaded: ', Question);
  finally
    Free;
  end;
  DeleteFile(GhostConfPath + 'in');
  Question := CP1250ToAscii(Question);
end;

procedure TGhost.Reply;
{*
Reply question back
}
begin
  writeln('Waiting for previous answer to be read from ' + GhostConfPath + 'out');
  while FileExists(GhostConfPath + 'out') do
    Sleep(500);
  with TStringList.Create do
  try
    Text := Answer;
    SaveToFile(GhostConfPath + 'out');
    writeln('  Answer saved: ', Answer);
  finally
    Free;
  end;
  // learn answer (add it to lurker for future use)
  if NeedLearn then
  begin
    write('suggest answer >>> ');
    readln(Answer);
    Lurker.Add('==QUESTION==' + Question);
    Lurker.Add('==ANSWER==' + Answer);
    Lurker.Save;
    NeedLearn := false;
  end;
end;

procedure TGhost.Think;
{*
Transfor Question into Answer using AI modules
}
begin
  // analyze sentence
  Sentence.Words := Question;
  Sentence.CleanUp;
  // index words
  Index.Parse(Sentence);

  // automatically add people to people list as talkers
  People.AddTalker(WhoAsk);

  // find reply
  Answer := '';
  // AI modules (reliable modules are first)
  if Answer = '' then
    Answer := Lurker.Answer(Question); // lurker
  if Answer = '' then
    Answer := People.Answer(Question); // drknow
  if Answer = '' then
    Answer := DrKnow.Answer(Question); // drknow
  if Answer = '' then
    Answer := Eval.Answer(Question); // eval
  if Answer = '' then
    Answer := Sam.Answer(Question); // sam
  if Answer = '' then
    Answer := Variation.Answer(Question); // variation of sam
  if Answer = '' then
    Answer := Topic.Answer(Question); // topic finder
  if (Answer <> '')and(Lurker.Count>0) then
  	Lurker[Lurker.Count-1] := '==='+Lurker[Lurker.Count-1];
  if (Answer = '') and (Attribute.Answer('$learn;') = 'enabled') then
    NeedLearn := true;
  if Answer = '' then
    Answer := Dumb.Answer(Question); // dumb reply
  Answer := Typo.Answer(Answer); // slightly modify answer
end;

procedure TGhost.Commands;
{*
Answer postprocessing
}
begin
  // disable people filter remotely
  if (People.Answer(WhoAsk)='friend')
  or (People.Answer(WhoAsk)='') then
  begin
    if Question = Attribute.Answer('$nick;')+' reply to all' then
    begin
      People.Enabled := false;
      Answer := 'I will reply to everybody now';
    end;
    if Question = Attribute.Answer('$nick;')+' reply only to friends' then
    begin
      People.Enabled := true;
      Answer := 'I will reply only to my friends and talkers now';
    end;
  end;
  // delete reply if the one who is asking is not in the people list
  if (WhoAsk <> '') and (People.IndexOf(WhoAsk) < 0) and (People.Enabled) then
    Answer := '';
  // once in a while try to change topic using fisher module
  if Attribute.Answer('$fisher;') = 'enabled' then
    if random(15) = 1 then
      writeln(Fisher.Answer('pokec'));
end;

end.