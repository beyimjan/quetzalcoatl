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

unit game_snake;

interface

uses
    crt, point, point_queue, game_field;

type
    TSnake = record
        field: TField;
        body: TQueuePoints;
        dir: TPoint;
        length, lengthen: integer;
    end;

const
    SnakeColor = Green;
    SnakeHead  = '@';
    SnakeTail  = 'o';

procedure SnakeCreate(var snake: TSnake; field: TField; crd, dir: TPoint);

procedure SnakeDelete(var snake: TSnake);

procedure SnakeSetDir(var snake: TSnake; dir: TPoint);

function SnakeGetCrd(var snake: TSnake): TPoint;

function SnakeGetNextCrd(var snake: TSnake): TPoint;

procedure SnakeMove(var snake: TSnake);

implementation

procedure SnakeCreate(var snake: TSnake; field: TField; crd, dir: TPoint);
begin
    snake.field := field;
    QPCreate(snake.body);
    QPPut(snake.body, crd);
    snake.field[crd.x - 1, crd.y - 1] := ItemSnake;
    snake.dir :=  dir;
    snake.length := 1;
    snake.lengthen := 0;
    TextColor(SnakeColor);
    TextBackground(Black);
    GotoXY(crd.x, crd.y);
    write(SnakeHead)
end;

procedure SnakeDelete(var snake: TSnake);
begin
    QPDelete(snake.body)
end;

procedure SnakeSetDir(var snake: TSnake; dir: TPoint);
begin
    if not PointEqual(snake.dir, PointMinus(dir)) then
        snake.dir := dir
end;

function SnakeGetCrd(var snake: TSnake): TPoint;
begin
    exit(QPBack(snake.body))
end;

function SnakeGetNextCrd(var snake: TSnake): TPoint;
var
    res: TPoint;
begin
    res := PointAdd(SnakeGetCrd(snake), snake.dir);
    if res.x < 1 then
        res.x := length(snake.field)
    else if res.x > length(snake.field) then
        res.x := 1
    else if res.y < 1 then
        res.y := length(snake.field[0])
    else if res.y > length(snake.field[0]) then
        res.y := 1;
    exit(res)
end;

procedure SnakeMove(var snake: TSnake);
var
    OldHead, NewHead, OldTail: TPoint;
begin
    OldHead := SnakeGetCrd(snake);
    NewHead := SnakeGetNextCrd(snake);
    TextColor(SnakeColor);
    TextBackground(Black);
    GotoXY(OldHead.x, OldHead.y);
    write(SnakeTail);
    if snake.lengthen = 0 then
    begin
        QPGet(snake.body, OldTail);
        snake.field[OldTail.x - 1, OldTail.y - 1] := ItemNone;
        GotoXY(OldTail.x, OldTail.y);
        write(' ')
    end
    else
    begin
        inc(snake.length);
        dec(snake.lengthen)
    end;
    QPPut(snake.body, NewHead);
    snake.field[NewHead.x - 1, NewHead.y - 1] := ItemSnake;
    GotoXY(NewHead.x, NewHead.y);
    write(SnakeHead)
end;

end.
