program ghost;

{*
Tiny AI chat bot
CHANGES
	Ghost 2.4
	TODO:
	- pridat realtimovu zmenu jazyka
	- spracovat logy

	--- variations: ---
	odstranit uvodne "so " v MAS
	nevie odpovedat na "heal please." lebo na konci je bodka
	ok... thx  <-- co s tym? variations by to mohol vediet odstranit
	odstranovat uvodne "well,"
	thx :) <-- variants by mal vediet odpovedat
	nevie odpovedat na hello ? lebo je tam medzera a otaznik
	whisper
	yeah, but <--- variants prec

	--- smaily ---
	XD
	x))
	:)
	:D
	O_o
	
	
	DONE
	- modify lurker not to log questions to whom I know the answer or mark them somehow so they can be filtered out
	- eval factorial workaround
	- fix division by zero error
	- localized eval
	- if somebody say hello to me, add it to people as talker (if he isn't already there)
	- added support to be run from command line throught fifo file
	- added support for modifying attributes from command line: -a fisher disabled
	- added basic support for multiple data versions (-m <language>)
	- added english data
	- second line in "in" file is nick
	- do not respond to all, just importat people
	- remote enable/disable of people module
		$nick; reply to all
		$nick; reply only to friends

	Ghost 2.3 (2009/10/14)
	- major code cleanup and rewrite, 40% code reduction
	- configuration moved to ~/.ghost
	- hosting moved from sourceforge.net to googlecode
	- simpler and better maintainable code  
	- removed 3000 lines of network and pokecbridge code

    Ghost 2.2 (2007/06/30)
    - fixed segfault in TYPO subsystem
    - corrected version string

    Ghost 2.1 (2007/06/29)
    - licence changed to GNU GPL 3
	- removed "access violation" bug
	- removed "list index out of bounds" bug
    - added demo and doc for PWF
    - spammers alert system (/notify miestnost spammer)
    - play track.au just once
    - improved network code (PWF)
    - shorter output of tracked users + number of found users

    Ghost 2.0 (2007/04/17)
    - uploaded on sourceforge.net
    - added config to disable sounds
    - added config to disable loging .recv and .send files

    Ghost 2.0 - RC2 (2007/04/15)
    - added control of TYPO and FISHER via /mod
    - added /track command
    - fixed IFL bug
    - fixed TAbst.Command for disabling modules

    Ghost 2.0 - RC1 (2007/04/14)
    - hosted on sourceforge.net
    - first web release (before SF)

    Ghost 1.0 (2003/08/25)
    - begined development of ghost
    - coding at home, debuging on net at school
}

{$ifndef FPC}
{$apptype CONSOLE}
{$endif}

uses
  SysUtils, Classes, configs, ghosts, consoles, fileghosts;

var g : TGhost;
	s : string;

begin
	s := CmdLineSwitchValue('-g','c');
	if s = 'g' then
		g := TGhost.Create;
  if s = 'c' then
		g := TConsoleGhost.Create;
  if s = 'f' then
		g := TFileGhost.Create;
	writeln('ghost type is ',s);
	writeln('ghost lang is ',GhostConfLang);
	g.Loop;
	g.Free; 
end.


