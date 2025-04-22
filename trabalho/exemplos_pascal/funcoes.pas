program funcao (input, output);
var x,y,z,w: integer;
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
    z := maior(x,y);
    write(z);
    w := menor(x,y);
    write(w)
end.
