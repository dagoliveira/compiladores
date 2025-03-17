program simples (input, output);
var x,y: integer;
var z: real;
function plus (a,b: integer): integer;
begin
    plus := a + b
end;
begin
    read(x);
    y := 3;
    z := 4;
    x := x + 1;
    x := y * x;
    z := 2 * z;
    x := plus(x,y);
    write(x);
    write(y);
    write(z)
end.
