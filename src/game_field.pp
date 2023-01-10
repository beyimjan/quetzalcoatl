{   game_field.pp

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

unit game_field;

interface

uses
    point;

type
    TItem = (
        ItemNone,
        ItemFruitSimple, ItemFruitDouble, ItemFruitMega, ItemFruitMagnet,
        ItemSnake
    );
    TField = array of array of TItem;

procedure FieldCreate(var field: TField; width, height: integer);

procedure FieldEmpty(var field: TField);

function FieldEmptyPoint(var field: TField): TPoint;

implementation

procedure FieldCreate(var field: TField; width, height: integer);
begin
    SetLength(field, width, height);
    FieldEmpty(field)
end;

procedure FieldEmpty(var field: TField);
var
    i, j: integer;
begin
    for j := 0 to length(field[0]) - 1 do
        for i := 0 to length(field) - 1 do
            field[i, j] := ItemNone
end;

function FieldEmptyPoint(var field: TField): TPoint;
var
    tmp, first: TPoint;
begin
    first := PointValue(random(length(field)), random(length(field[0])));
    if field[first.x, first.y] = ItemNone then
        exit(first);
    tmp := first;
    repeat
        if (tmp.x = length(field) - 1) and (tmp.y = length(field[0]) - 1) then
            tmp := PointZero
        else if tmp.x = length(field) - 1 then
            tmp := PointValue(0, tmp.y + 1)
        else
            inc(tmp.x);
        if field[tmp.x, tmp.y] = ItemNone then
            exit(tmp)
    until PointEqual(tmp, first);
    exit(PointMinusOne)
end;

end.
