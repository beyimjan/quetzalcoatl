{   game.pp

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

unit game;

interface

uses
    main_state, controls;

procedure GameRun(var controls: TControls; var state: TState);

implementation

uses
    sysutils, dateutils, crt, keyboard,
    vidget_design,
    point, game_field, game_fruit, game_snake;

const
    SnakeInitLengthen = 2;

    FruitCountDivider = 40;

    GameDelay = 75;
    KeybDelay = 50;

type
    TGame = record
        state: TState;
        field: TField;
        snake: TSnake;
        snakeEatArea: integer;
        case magnetEnabled : boolean of
            true: (magnetActivated: TDateTime)
    end;

procedure MagnetOn(var game: TGame);
begin
    game.magnetEnabled := true;
    game.magnetActivated := now;
    if game.snakeEatArea < MagnetMaxArea then
        inc(game.snakeEatArea)
end;

procedure MagnetOff(var game: TGame);
begin
    game.magnetEnabled := false;
    game.snakeEatArea := 0
end;

function IsMagnetStillActive(var game: TGame): boolean;
begin
    exit((MillisecondsBetween(now, game.magnetActivated) > MagnetActive))
end;

procedure SnakeEatFruit(var game: TGame; fruit: TPoint);
var
    item: TItem;
    i: integer;
begin
    item := game.field[fruit.x - 1, fruit.y - 1];
    game.field[fruit.x - 1, fruit.y - 1] := ItemNone;
    TextColor(White);
    TextBackground(Black);
    GotoXY(fruit.x, fruit.y);
    write(' ');
    if item = ItemFruitMagnet then
        MagnetOn(game)
    else
    begin
        inc(game.snake.lengthen, FruitEffects[ord(item) - 1].snakeLengthen);
        for i := 1 to FruitEffects[ord(item) - 1].newFruits do
            FruitCreate(game.field)
    end
end;

procedure GameDraw(var game: TGame);
var
    i, j: integer;
    tmp: TPoint;
begin
    clrscr;
    TextBackground(Black);
    for i := 0 to length(game.field) - 1 do
    begin
        for j := 0 to length(game.field[0]) - 1 do
        begin
            if game.field[i, j] = ItemNone then
                continue;
            tmp := PointValue(i + 1, j + 1);
            GotoXY(i + 1, j + 1);
            if game.field[i, j] = ItemSnake then
            begin
                TextColor(SnakeColor);
                if PointEqual(SnakeGetCrd(game.snake), tmp) then
                    write(SnakeHead)
                else
                    write(SnakeTail)
            end
            else
                FruitShow(game.field[i, j], tmp)
        end
    end
end;

procedure GameStart(var game: TGame; state: TState);
var
    i: integer;
begin
    clrscr;
    game.state := state;
    FieldCreate(game.field, ScreenWidth, ScreenHeight - 1);
    game.snake.field := game.field;
    SnakeCreate(game.snake, game.field,
        PointValue(ScreenWidth div 2, ScreenHeight div 2), RandomCardinaldir);
    game.snake.lengthen := SnakeInitLengthen;
    game.snakeEatArea := 0;
    game.magnetEnabled := false;
    for i := 1 to
        length(game.field) * length(game.field[0]) div FruitCountDivider do
    begin
        FruitCreate(game.field)
    end
end;

procedure GameEnd(var game: TGame; var state: TState);
begin
    SnakeDelete(game.snake);
    state := game.state
end;

procedure MenuPauseShow;
const
    MenuX = 27;
    MenuY = 9;

    MenuPause: array of string = (
        '+----------------Paused-+',
        '| 1) Resume             |',
        '| 2) Restart            |',
        '| 3) Quit to Main Menu  |',
        '| 4) Quit Game          |',
        '+-----------------------+'
    );
var
    i: integer;
begin
    TextColor(DefaultElementColor);
    TextBackground(Black);
    for i := 0 to length(MenuPause) - 1 do
    begin
        GotoXY(MenuX, MenuY + i);
        write(MenuPause[i])
    end
end;

procedure MenuPause(var game: TGame);
const
    ToResume         = ord('1');
    ToRestart        = ord('2');
    ToQuitToMainMenu = ord('3');
    ToQuitGame       = ord('4');
var
    key: integer;
begin
    MenuPauseShow;
    GotoXY(1, ScreenHeight);
    repeat
        GetKey(key);
        if key = ToRestart then
            game.state := StateRetry
        else if key = ToQuitToMainMenu then
            game.state := StateMenu
        else if key = ToQuitGame then
            game.state := StateExit;
    until (key >= ToResume) and (key <= ToQuitGame)
end;

procedure GameHandleInput(var game: TGame; var controls: TControls);
var
    key: integer;
begin
    SelectKey(key, controls, KeybDelay);
    if key = controls[CtrlUp] then
        SnakeSetDir(game.snake, north)
    else if key = controls[CtrlDown] then
        SnakeSetDir(game.snake, south)
    else if key = controls[CtrlLeft] then
        SnakeSetDir(game.snake, west)
    else if key = controls[CtrlRight] then
        SnakeSetDir(game.snake, east)
    else if key = controls[CtrlPause] then
    begin
        MenuPause(game);
        if game.state = StateNewGame then
            GameDraw(game)
    end
end;

procedure MenuRetryShow(var menu: array of string);
const
    MenuColor = LightBlue;

    MenuX = 30;
    MenuY = 9;
var
    i: integer;
begin
    TextColor(MenuColor);
    TextBackground(Black);
    for i := 0 to length(menu) - 1 do
    begin
        GotoXY(MenuX, MenuY + i);
        write(menu[i])
    end
end;

procedure MenuRetry(var game: TGame);
const
    MenuYes: array of string = (
        ('+-Game Over--------+'),
        ('|                  |'),
        ('| Retry?     <Yes> |'),
        ('|                  |'),
        ('+------------------+')
    );
    MenuNo: array of string = (
        ('+-Game Over--------+'),
        ('|                  |'),
        ('| Retry?      <No> |'),
        ('|                  |'),
        ('+------------------+')
    );
var
    key: integer;
    retry: boolean = true;
begin
    MenuRetryShow(MenuYes);
    repeat
        GotoXY(1, ScreenHeight);
        GetKey(key);
        if (key = KeyLeft) or (key = KeyRight) then
        begin
            retry := not retry;
            if retry then
                MenuRetryShow(MenuYes)
            else
                MenuRetryShow(MenuNo)
        end
    until key = KeyEnter;
    if retry then
        game.state := StateRetry
    else
        game.state := StateMenu
end;

procedure GameUpdate(var game: TGame);
var
    tmp: TPoint;
    item: TItem;
    i, j: integer;
begin
    tmp := SnakeGetNextCrd(game.snake);
    if game.field[tmp.x - 1, tmp.y - 1] = ItemSnake then
    begin
        MenuRetry(game);
        exit
    end;
    if game.magnetEnabled and IsMagnetStillActive(game) then
        MagnetOff(game);
    for i := tmp.x - game.snakeEatArea to tmp.x + game.snakeEatArea do
        for j := tmp.y - game.snakeEatArea to tmp.y + game.snakeEatArea do
            if (i >= 1) and (i <= length(game.field)) and
                (j >= 1) and (j <= length(game.field[0])) then
            begin
                item := game.field[i - 1, j - 1];
                if (item >= ItemFruitSimple) and (item <= ItemFruitMagnet) then
                    SnakeEatFruit(game, PointValue(i, j))
            end;
    SnakeMove(game.snake)
end;

procedure GameRun(var controls: TControls; var state: TState);
var
    game: TGame;
    start: TDateTime;
begin
    start := now;
    GameStart(game, state);
    repeat
        GotoXY(1, ScreenHeight);
        if MillisecondsBetween(now, start) < GameDelay then
            delay(GameDelay - MillisecondsBetween(now, start));
        start := now;
        GameHandleInput(game, controls);
        if game.state = StateNewGame then
            GameUpdate(game)
    until game.state <> StateNewGame;
    GameEnd(game, state)
end;

end.
