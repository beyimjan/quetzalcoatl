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

unit point;

interface

type
    TPoint = record
        x, y: integer;
    end;

const
    PointZero:     TPoint = (x:  0; y:  0);
    PointOne:      TPoint = (x:  1; y:  1);
    PointMinusOne: TPoint = (x: -1; y: -1);

    north: TPoint = (x:  0; y: -1);
    south: TPoint = (x:  0; y:  1);
    west:  TPoint = (x: -1; y:  0);
    east:  TPoint = (x:  1; y:  0);

function RandomCardinalDir: TPoint;

function PointValue(x, y: integer): TPoint;

function PointMinus(point: TPoint): TPoint;

function PointEqual(lhs, rhs: TPoint): boolean;

function PointAdd(lhs, rhs: TPoint): TPoint;

implementation

function RandomCardinalDir: TPoint;
const
    AllCardinalDirs: array of TPoint = (
        (x:  0; y: -1),
        (x:  0; y:  1),
        (x: -1; y:  0),
        (x:  1; y:  0)
    );
begin
    exit(AllCardinalDirs[random(length(AllCardinalDirs))])
end;

function PointValue(x, y: integer): TPoint;
var
    res: TPoint;
begin
    res.x := x;
    res.y := y;
    exit(res)
end;

function PointMinus(point: TPoint): TPoint;
begin
    exit(PointValue(-point.x, -point.y))
end;

function PointEqual(lhs, rhs: TPoint): boolean;
begin
    exit((lhs.x = rhs.x) and (lhs.y = rhs.y))
end;

function PointAdd(lhs, rhs: TPoint): TPoint;
begin
    exit(PointValue(lhs.x + rhs.x, lhs.y + rhs.y))
end;

end.
