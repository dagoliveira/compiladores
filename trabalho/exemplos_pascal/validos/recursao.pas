program recursao (input, output);
var x, y, a: integer;
function mdc (a,b: integer): integer;
begin
    if b = 0 then mdc := a
    else mdc := mdc (b, a mod b)
end;

begin
    read (x,y);
    a := mdc(x,y);
    write ( a )
end.
