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

unit point_queue;

interface

uses
    point;

type
    TQueuePointPtr = ^TQueuePoint;
    TQueuePoint = record
        point: TPoint;
        next: TQueuePointPtr;
    end;

    TQueuePoints = record
        first, last: TQueuePointPtr;
    end;

procedure QPCreate(var queue: TQueuePoints);

procedure QPDelete(var queue: TQueuePoints);

procedure QPPut(var queue: TQueuePoints; point: TPoint);

procedure QPGet(var queue: TQueuePoints; var point: TPoint);

function QPFront(var queue: TQueuePoints): TPoint;

function QPBack(var queue: TQueuePoints): TPoint;

function QPIsEmpty(var queue: TQueuePoints): boolean;

implementation

procedure QPCreate(var queue: TQueuePoints);
begin
    queue.first := nil;
    queue.last := nil
end;

procedure QPDelete(var queue: TQueuePoints);
var
    tmp: TQueuePointPtr;
begin
    tmp := queue.first;
    while tmp <> nil do
    begin
        queue.first := queue.first^.next;
        dispose(tmp);
        tmp := queue.first
    end;
    queue.last := nil
end;

procedure QPPut(var queue: TQueuePoints; point: TPoint);
var
    tmp: TQueuePointPtr;
begin
    new(tmp);
    tmp^.point := point;
    tmp^.next := nil;
    if queue.first = nil then
    begin
        queue.first := tmp;
        queue.last := tmp
    end
    else
    begin
        queue.last^.next := tmp;
        queue.last := tmp
    end
end;

procedure QPGet(var queue: TQueuePoints; var point: TPoint);
var
    tmp: TQueuePointPtr;
begin
    tmp := queue.first;
    queue.first := queue.first^.next;
    point := tmp^.point;
    dispose(tmp);
    if queue.first = nil then
        queue.last := nil
end;

function QPFront(var queue: TQueuePoints): TPoint;
begin
    exit(queue.first^.point)
end;

function QPBack(var queue: TQueuePoints): TPoint;
begin
    exit(queue.last^.point)
end;

function QPIsEmpty(var queue: TQueuePoints): boolean;
begin
    exit((queue.first = nil) and (queue.last = nil))
end;

end.
