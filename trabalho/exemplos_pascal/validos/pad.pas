program Padovan (input, output);
var pad: integer;
procedure padovan(n: integer; var nElem: integer);
var prevprev, prev, curr, next, i: integer;
begin
    prevprev := 1;
    prev := 1;
    curr := 1;
    next := 1;
    i := 3;
    while i <= n do
    begin
        next := prevprev + prev;
        prevprev := prev;
        prev := curr;
        curr := next;
        i := i + 1
    end;
    nElem := next
end;
begin
    padovan(15, pad);
    write(pad)
end.

