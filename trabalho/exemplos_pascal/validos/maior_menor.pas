program passagemReferencia (input, output);
var x,y,ma,me: integer;
procedure maiormenor(a,b: integer; var maior, menor: integer);
begin
    if a > b then
    begin
        maior := a;
        menor := b
    end
    else
    begin
        maior := b;
        menor := a
    end
end;
begin
    read(x);
    read(y);
    maiormenor(x,y,ma,me);
    write(me)
end.
