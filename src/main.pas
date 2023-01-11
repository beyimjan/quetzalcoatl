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

program quetzalcoatl;

uses
    math, crt,
    main_state, controls, main_menu, game;

procedure MainLoop;
var
    SaveTextAttr: integer;
    controls: TControls;
    MenuButtonSelected: TMenuButton = MBNewGame;
    state: TState = StateInit;
begin
    while true do
    begin
        while KeyPressed do
            ReadKey;
        case state of
            StateInit: begin
                SaveTextAttr := TextAttr;
                ControlsLoad(controls);
                randomize;
                state := StateMenu
            end;
            StateMenu:
                GameMenu(MenuButtonSelected, controls, state);
            StateNewGame:
                GameRun(controls, state);
            StateRetry:
                state := StateNewGame;
            StateExit: begin
                TextAttr := SaveTextAttr;
                clrscr;
                break
            end
        end
    end
end;

const
    MinScreenWidth  = 80;
    MinScreenHeight = 24;
    MaxScreenSize   = 255;
begin
    if (ScreenWidth < MinScreenWidth) or (ScreenHeight < MinScreenHeight) or
        (max(ScreenWidth, ScreenHeight) > MaxScreenSize) then
    begin
        writeln('Please resize your window and try again!');
        halt(1)
    end;
    MainLoop
end.
