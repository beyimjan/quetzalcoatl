{   vidget_button.pp

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

unit vidget_button;

interface

type
    TButton = record
        x, y, width: integer;
        str: string;
    end;

procedure ButtonSelect(var button: TButton);

procedure ButtonUnselect(var button: TButton);

implementation

uses
    crt, vidget_rectangle, vidget_border, vidget_design;

const
    ButtonHeight = 1;

procedure ButtonShow(var button: TButton; border: TBorder);
begin
    RectangleHide(button.x, button.y, button.width, ButtonHeight);
    BorderShow(border,
        button.x - 1, button.y - 1, button.width + 2, ButtonHeight + 2);
    TextColor(border.fg);
    TextBackground(border.bg);
    GotoXY(button.x + (button.width - length(button.str)) div 2, button.y);
    write(button.str)
end;

procedure ButtonSelect(var button: TButton);
begin
    ButtonShow(button, ActiveVidgetBorder)
end;

procedure ButtonUnselect(var button: TButton);
begin
    ButtonShow(button, DefaultVidgetBorder)
end;

end.
