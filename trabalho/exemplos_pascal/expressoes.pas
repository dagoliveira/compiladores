program expressoes (input, output);
var x,y,z: integer;
var a,b,c: real;
begin
    read(x);
    read(y);
    read(a);
    read(b);
    z := x + y * 2 - x div 3;
    c := 2*a + b/3 - a*(b+2);
    write(z);
    writeln();
    write(c)
end.
