{   Copyright (C) 2022 Tamerlan Bimzhanov

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

unit vidget_border;

interface

type
    TBorderStyle = (BorderNone, BorderBasic, BorderUnix);
    TBorder = record
        style: TBorderStyle;
        case TBorderStyle of
            BorderBasic, BorderUnix: (
                fg, bg: integer; { text and background colors from crt module }
                case TBorderStyle of
                    BorderBasic: (
                        c: char
                    )
            )
    end;

{ if border.style = BorderNone does nothing
  If border.style = BorderBasic shows border filled with the chars in border.c
  If border.style = BorderUnix shows border like this
  +--------------+
  |              |
  |              |
  |              |
  +--------------+
}
procedure BorderShow(border: TBorder; x, y, width, height: integer);

implementation

uses
    crt;

{ shows ver. part of border given in line without last 2 points }
procedure BorderVerLineWrite(border: TBorder; line, y, height: integer);
var
    j: integer;
begin
    for j := y + 1 to y + height - 2 do
    begin
        GotoXY(line, j);
        if border.style = BorderBasic then
            write(border.c)
        else if border.style = BorderUnix then
            write('|')
    end
end;

{ shows hor. part of border given in line }
procedure BorderHorLineWrite(border: TBorder; line, x, width: integer);
var
    i: integer;
begin
    GotoXY(x, line);
    for i := 1 to width do
    begin
        if border.style = BorderBasic then
            write(border.c)
        else if border.style = BorderUnix then
        begin
            if (i = 1) or (i = width) then
                write('+')
            else
                write('-')
        end
    end
end;

procedure BorderShow(border: TBorder; x, y, width, height: integer);
begin
    if border.style = BorderNone then
        exit;
    TextColor(border.fg);
    TextBackground(border.bg);
    BorderHorLineWrite(border, y, x, width);
    BorderHorLineWrite(border, y + height - 1, x, width);
    BorderVerLineWrite(border, x, y, height);
    BorderVerLineWrite(border, x + width - 1, y, height)
end;

end.
