program procedimento (input, output);
var x,y: integer;
procedure plus (a,b: integer);
var c: integer;
begin
    c := a + b;
    write(c)
end;
begin
    read(x);
    read(y);
    plus(x,y)
end.
