{   game_fruit.pp

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

unit game_fruit;

interface

uses
    point, game_field;

type
    TFruitEffect = record
        snakeLengthen, newFruits: integer;
    end;

const
    FruitSimple = 0;
    FruitDouble = 1;
    FruitMega   = 2;

    FruitEffects: array [0..FruitMega] of TFruitEffect = (
        (snakeLengthen: 1; newFruits: 1),
        (snakeLengthen: 1; newFruits: 2),
        (snakeLengthen: 5; newFruits: 3)
    );

    MagnetMaxArea = 5;
    MagnetActive  = 7 * 1000; { milliseconds }

procedure FruitShow(kind: Titem; crd: TPoint);

procedure FruitCreate(field: TField);

implementation

uses
    crt;

const
    ChanceMagnet = 0.03;
    ChanceMega   = 0.08;
    ChanceDouble = 0.18;
    ChanceSimple = 1.0;

procedure FruitShow(kind: Titem; crd: TPoint);
begin
    GotoXY(crd.x, crd.y);
    TextBackground(Black);
    case kind of
        ItemFruitSimple: begin
            TextColor(Brown);
            write('+')
        end;
        ItemFruitDouble: begin
            TextColor(Magenta);
            write('$')
        end;
        ItemFruitMega: begin
            TextColor(Red);
            write('@')
        end;
        ItemFruitMagnet: begin
            TextColor(LightBlue);
            write('%')
        end
    end
end;

procedure FruitPut(field: TField; crd: TPoint; kind: TItem);
begin
    field[crd.x - 1, crd.y - 1] := kind;
    FruitShow(kind, crd)
end;

procedure FruitCreate(field: TField);
var
    tmp: TPoint;
    chance: real;
begin
    tmp := FieldEmptyPoint(field);
    if PointEqual(tmp, PointMinusOne) then
        exit;
    tmp := PointAdd(tmp, PointOne);
    chance := random;
    if chance <= ChanceMagnet then
        FruitPut(field, tmp, ItemFruitMagnet)
    else if chance <= ChanceMega then
        FruitPut(field, tmp, ItemFruitMega)
    else if chance <= ChanceDouble then
        FruitPut(field, tmp, ItemFruitDouble)
    else if chance <= ChanceSimple then
        FruitPut(field, tmp, ItemFruitSimple)
end;

end.
