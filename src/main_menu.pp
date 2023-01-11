{   Copyright (C) 2022, 2023 Tamerlan Bimzhanov

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

unit main_menu;

interface

uses
    vidget_button, main_state, controls;

type
    TMenuButton = (
        MBNewGame,
        MBSelectLevel,
        MBControls,
        MBLeaderboards,
        MBExit
    );

procedure GameMenu(
    var SelectedButton: TMenuButton;
    var controls: TControls;
    var state: TState
);

implementation

uses
    sysutils, dateutils, crt, keyboard, vidget_design;

const
    MenuButtonX     = 30;
    MenuButtonWidth = 20;
    MenuButtons: array [TMenuButton] of TButton = (
        (x: MenuButtonX; y: 8;  width: MenuButtonWidth; str: 'New Game'),
        (x: MenuButtonX; y: 11; width: MenuButtonWidth; str: 'Select Level'),
        (x: MenuButtonX; y: 14; width: MenuButtonWidth; str: 'Controls'),
        (x: MenuButtonX; y: 17; width: MenuButtonWidth; str: 'Leaderboard'),
        (x: MenuButtonX; y: 20; width: MenuButtonWidth; str: 'Exit')
    );

    MenuDelay = 100;

procedure MenuArtShow;
const
    art: array of string = (
        ',---.          |              |                   |    |   ',
        '|   |.   .,---.|--- ,---,,---.|    ,---.,---.,---.|--- |   ',
        '|   ||   ||---''|     .-'' ,---||    |    |   |,---||    |   ',
        '`---\`---''`---''`---''''---''`---^`---''`---''`---''`---^`---''`---'
    );
    ArtX = 10;
    ArtY = 2;
var
    i: integer;
begin
    TextColor(DefaultElementColor);
    TextBackground(Black);
    for i := 0 to length(art) - 1 do
    begin
        GotoXY(ArtX, ArtY + i);
        write(art[i])
    end
end;

procedure MenuCopyrightShow;
const
    copyright = '(c) Tamerlan Bimzhanov, 2022';
    CopyrightX = 26;
    CopyrightY = 23;
begin
    TextColor(DefaultElementColor);
    TextBackground(Black);
    GotoXY(CopyrightX, CopyrightY);
    writeln(copyright)
end;

procedure MenuShow(SelectedButton: TMenuButton);
var
    i: TMenuButton;
begin
    clrscr;
    MenuArtShow;
    MenuCopyrightShow;
    for i := MBNewGame to MBExit do
        if i = SelectedButton then
            ButtonSelect(MenuButtons[i])
        else
            ButtonUnselect(MenuButtons[i])
end;

procedure MenuButtonSelect(
    var SelectedButton: TMenuButton;
    button: TMenuButton
);
begin
    ButtonUnselect(MenuButtons[SelectedButton]);
    SelectedButton := button;
    ButtonSelect(MenuButtons[button])
end;

procedure MenuHandlerUpDownPressed(
    var SelectedButton: TMenuButton;
    key: integer
);
begin
    if key = KeyUp then
    begin
        if SelectedButton = MBNewGame then
            MenuButtonSelect(SelectedButton, MBExit)
        else
            MenuButtonSelect(SelectedButton, pred(SelectedButton))
    end
    else if key = KeyDown then
    begin
        if SelectedButton = MBExit then
            MenuButtonSelect(SelectedButton, MBNewGame)
        else
            MenuButtonSelect(SelectedButton, succ(SelectedButton))
    end
end;

procedure MenuHandlerEnterPressed(
    var SelectedButton: TMenuButton;
    var controls: TControls;
    var state: TState
);
begin
    if SelectedButton = MBNewGame then
        state := StateNewGame
    else if SelectedButton = MBControls then
    begin
        ControlsUpdate(controls);
        MenuShow(SelectedButton)
    end
    else if SelectedButton = MBExit then
        state := StateExit
end;

procedure GameMenu(
    var SelectedButton: TMenuButton;
    var controls: TControls;
    var state: TState
);
var
    key: integer;
begin
    MenuShow(SelectedButton);
    repeat
        GotoXY(1, ScreenHeight);
        WaitForKey(MenuDelay);
        if not KeyPressed then
            continue;
        GetKey(key);
        if (key = KeyUp) or (key = KeyDown) then
            MenuHandlerUpDownPressed(SelectedButton, key)
        else if key = KeyEnter then
            MenuHandlerEnterPressed(SelectedButton, controls, state)
    until state <> StateMenu
end;

end.
