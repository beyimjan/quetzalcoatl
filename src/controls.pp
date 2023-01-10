{   controls.pp

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

unit controls;

interface

const
    CtrlCount = 5;

    CtrlUp    = 0;
    CtrlDown  = 1;
    CtrlLeft  = 2;
    CtrlRight = 3;
    CtrlPause = 4;

type
    TControls = array [0..CtrlPause] of integer;

procedure ControlsLoad(var controls: TControls);

procedure ControlsUpdate(var controls: TControls);

implementation

uses
    sysutils, crt, keyboard,
    vidget_rectangle, vidget_border, vidget_design, vidget_button;

const
    DefaultControls: TControls = (KeyUp, KeyDown, KeyLeft, KeyRight, KeyEsc);

function ControlsUpDir: string;
begin
    exit(GetUserDir + '/.quetzalcoatl')
end;

function ControlsFPath: string;
begin
    exit(ControlsUpDir + '/controls')
end;

procedure ControlsSave(var controls: TControls);
var
    ControlsFile: file of integer;
    i: integer;
begin
{$I-}
    if not DirectoryExists(ControlsUpDir) then
    begin
        Mkdir(ControlsUpDir);
        if IOResult <> 0 then
            exit;
    end;
    assign(ControlsFile, ControlsFPath);
    filemode := 1;
    rewrite(ControlsFile);
    if IOResult <> 0 then
        exit;
    for i := 0 to CtrlCount - 1 do
    begin
        write(ControlsFile, controls[i]);
        if IOResult <> 0 then
            break;
    end;
    close(ControlsFile)
end;

procedure ControlsLoad(var controls: TControls);
var
    ControlsFile: file of integer;
    key, KeysRead: integer;
    FileReadCompletely: boolean;
begin
{$I-}
    controls := DefaultControls;
    if not FileExists(ControlsFPath) or not DirectoryExists(ControlsUpDir) then
    begin
        ControlsSave(DefaultControls);
        exit
    end;
    assign(ControlsFile, ControlsFPath);
    filemode := 0;
    reset(ControlsFile);
    if IOResult <> 0 then
        exit;
    KeysRead := 0;
    repeat
        if eof(ControlsFile) then
            break;
        read(ControlsFile, key);
        if IOResult <> 0 then
            break;
        inc(KeysRead);
        controls[KeysRead - 1] := key
    until KeysRead = CtrlCount;
    FileReadCompletely := eof(ControlsFile) and (KeysRead = CtrlCount);
    close(ControlsFile);
    if not FileReadCompletely then
    begin
        controls := DefaultControls;
        ControlsSave(DefaultControls)
    end
end;

type
    TMenuElement = (
        MEMoveUp, MEMoveDown, MEMoveLeft, MEMoveRight, MEPause,
        MEResetToDefaults, MESave, MECancel
    );
    TMenu = record
        controls: TControls;
        case hovered : TMenuElement of
            MEMoveUp, MEMoveDown, MEMoveLeft, MEMoveRight, MEPause: (
                changingControl: boolean
            )
    end;

const
    MenuX      = 26;
    MenuY      = 8;
    MenuWidth  = 28;
    MenuHeight = 8;

    MenuTitle     = '----------Controls----------';
    MenuElements: array [MEMoveUp..MEResetToDefaults] of string[MenuWidth] = (
        ('  Move up                   '),
        ('  Move down                 '),
        ('  Move left                 '),
        ('  Move right                '),
        ('  Pause game                '),
        ('  Reset to defaults         ')
    );
    MenuButtons: array [MESave..MECancel] of TButton = (
        (x: 26; y: 18; width: 13; str: 'Save'),
        (x: 41; y: 18; width: 13; str: 'Cancel')
    );

function KeyToString(key: integer): string;
begin
    case key of
        KeyTab:
            exit('Tab');
        ord(' '):
            exit('Space');
        ord('!')..ord('~'):
            exit(chr(key));
        KeyUp:
            exit('Arrow up');
        KeyDown:
            exit('Arrow down');
        KeyLeft:
            exit('Arrow left');
        KeyRight:
            exit('Arrow right');
        KeyDelete:
            exit('Delete');
        KeyBackspace:
            exit('Backspace');
        KeyEsc:
            exit('Escape');
        else
            exit('Undefined')
    end
end;

procedure MenuElementShow(var menu: TMenu; element: TMenuElement);
var
    key: string;
begin
    if menu.hovered = element then
        TextColor(ActiveElementColor)
    else
        TextColor(DefaultElementColor);
    TextBackground(Black);
    GotoXY(MenuX, MenuY + ord(element) + 1);
    write(MenuElements[element]);

    if element = MEResetToDefaults then
        exit;
    if (menu.hovered = element) and menu.changingControl then
        TextColor(ActiveElementColor)
    else
        TextColor(DefaultElementColor);
    key := KeyToString(menu.controls[ord(element)]);
    GotoXY(MenuX + MenuWidth - length(key) - 1, MenuY + ord(element) + 1);
    write(key);
end;

procedure MenuShow(var menu: TMenu);
var
    tmp: TMenuElement;
begin
    RectangleHide(MenuX, MenuY, MenuWidth, MenuHeight);
    BorderShow(DefaultVidgetBorder,
        MenuX - 1, MenuY - 2, MenuWidth + 2, MenuHeight + 3);
    TextColor(DefaultElementColor);
    TextBackground(Black);
    GotoXY(MenuX, MenuY - 1);
    write(MenuTitle);
    for tmp := MEMoveUp to MEResetToDefaults do
        MenuElementShow(menu, tmp);
    for tmp := MESave to MECancel do
        if tmp = menu.hovered then
            ButtonSelect(MenuButtons[tmp])
        else
            ButtonUnselect(MenuButtons[tmp])
end;

procedure MenuCreate(var menu: TMenu; controls: TControls);
begin
    menu.controls := controls;
    menu.hovered := MEMoveUp;
    menu.changingControl := false;
    MenuShow(menu)
end;

procedure MenuEnterPressedHandler(var menu: TMenu);
begin
    if menu.hovered = MEResetToDefaults then
    begin
        menu.controls := DefaultControls;
        MenuShow(menu)
    end
    else
    begin
        menu.changingControl := not menu.changingControl;
        MenuElementShow(menu, menu.hovered)
    end
end;

procedure MenuChangeControl(var menu: TMenu; key: integer);
var
    control: integer;
begin
    for control in menu.controls do
        if key = control then
            exit;
    menu.controls[ord(menu.hovered)] := key;
    MenuElementShow(menu, menu.hovered)
end;

procedure MenuUpPressedHandler(var menu: TMenu);
begin
    if menu.hovered = MEMoveUp then
        exit;
    menu.hovered := pred(menu.hovered);
    MenuElementShow(menu, succ(menu.hovered));
    MenuElementShow(menu, menu.hovered)
end;

procedure MenuDownPressedHandler(var menu: TMenu);
begin
    menu.hovered := succ(menu.hovered);
    MenuElementShow(menu, pred(menu.hovered));
    if menu.hovered < MESave then
        MenuElementShow(menu, menu.hovered)
    else
        ButtonSelect(MenuButtons[MESave])
end;

procedure ControlsUpdate(var controls: TControls);
var
    menu: TMenu;
    key: integer;
begin
    MenuCreate(menu, controls);
    while true do
    begin
        GotoXY(1, ScreenHeight);
        GetKey(key);
        if ((menu.hovered = MESave) or (menu.hovered = MECancel)) and
            (key = KeyUp) then
        begin
            ButtonUnselect(MenuButtons[menu.hovered]);
            menu.hovered := MEResetToDefaults;
            MenuElementShow(menu, MEResetToDefaults)
        end
        else if menu.hovered = MESave then
        begin
            if key = KeyEnter then
            begin
                controls := menu.controls;
                ControlsSave(controls);
                break
            end
            else if key = KeyRight then
            begin
                ButtonUnselect(MenuButtons[MESave]);
                menu.hovered := MECancel;
                ButtonSelect(MenuButtons[MECancel])
            end
        end
        else if menu.hovered = MECancel then
        begin
            if key = KeyEnter then
                break
            else if key = KeyLeft then
            begin
                ButtonUnselect(MenuButtons[MECancel]);
                menu.hovered := MESave;
                ButtonSelect(MenuButtons[MESave])
            end
        end
        else if key = KeyEnter then
            MenuEnterPressedHandler(menu)
        else if menu.changingControl then
            MenuChangeControl(menu, key)
        else if key = KeyUp then
            MenuUpPressedHandler(menu)
        else if key = KeyDown then
            MenuDownPressedHandler(menu)
    end
end;

end.
