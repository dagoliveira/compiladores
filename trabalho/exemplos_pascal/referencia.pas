program passagemReferencia (input, output);
var r,x,y: integer;
procedure maior(a,b: integer; var c: integer);
begin
    if a > b 
    then 
        c := a
    else
        c := b
end;
begin
    read(x);
    read(y);
    maior(x,y,r);
    write(r);
end.
