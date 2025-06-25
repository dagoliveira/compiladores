program expressoes (input, output);
var x,y: integer;
var a,b,c: real;
begin
    read(x);
    read(y);
    read(a);
    read(b);
    c := 2*a + b / 3 - a*(b+2) + x - y;
    write(c)
end.
