{   keyboard.pp

    Copyright (C) 2022 Tamerlan Bimzhanov

    This file is part of quetzalcoatl.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}

unit keyboard;

interface

const
    KeyErr       = 0;

    KeyDelete    = -83;
    KeyDown      = -80;
    KeyRight     = -77;
    KeyLeft      = -75;
    KeyUp        = -72;
    KeyBackspace = 8;
    KeyTab       = 9;
    KeyEnter     = 13;
    KeyEsc       = 27;

{ reads one key }
procedure GetKey(var key: integer);

{ waits for a key to be pressed,
  if a key has been pressed before, it immediately returns control }
procedure WaitForKey(timeout: word);

{ checks if there is key value in keys }
function KeysContain(var keys: array of integer; key: integer): boolean;

{ reads keys and puts in key those keys that are in keys
  until time in delay expires }
{ if no keys are read from keys or no keys are read, sets key to KeyErr }
procedure SelectKey(var key: integer; var keys: array of integer; delay: word);

implementation

uses
    sysutils, dateutils, BaseUnix, crt;

procedure GetKey(var key: integer);
var
    c: char;
begin
    c := ReadKey;
    if c = #0 then
    begin
        c := ReadKey;
        key := -ord(c)
    end
    else
        key := ord(c)
end;

procedure WaitForKey(timeout: word);
var
    istream: TFDSet;
begin
    fpFD_Zero(istream);
    fpFD_Set(0, istream);
    fpSelect(1, @istream, nil, nil, timeout)
end;

function KeysContain(var keys: array of integer; key: integer): boolean;
var
    tmp: integer;
begin
    for tmp in keys do
        if tmp = key then
            exit(true);
    exit(false)
end;

procedure SelectKey(var key: integer; var keys: array of integer; delay: word);
var
    start: TDateTime;
    tmp: integer;
begin
    start := now;
    key := KeyErr;
    repeat
        if KeyPressed then
        begin
            GetKey(tmp);
            if KeysContain(keys, tmp) then
                key := tmp
        end
        else if delay > MillisecondsBetween(now, start) then
            WaitForKey(delay - MillisecondsBetween(now, start))
    until MillisecondsBetween(now, start) >= delay
end;

end.
