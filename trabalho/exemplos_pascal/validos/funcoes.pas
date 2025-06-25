program funcoes (input, output);
var x,y,a,b,z,w: integer;
function maior (a,b: integer): integer;
begin
    if a >b then
        maior := a
    else
        maior := b
end;
function menor (a,b: integer): integer;
begin
    if a >b then
        menor := b
    else
        menor := a
end;
begin
    read(x);
    read(y);
    read(a);
    read(b);
    z := maior(x,y);
    z := maior(z,a);
    z := maior(z,b);
    w := menor(x,y);
    w := menor(w,a);
    w := menor(w,b);
    z := z + w;
    write(z)
end.
