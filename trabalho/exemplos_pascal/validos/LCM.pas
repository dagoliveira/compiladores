program LCM (input, output);
var x,y,res: integer;
function LCM(a,b: integer): integer;
var maior, menor: integer;
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
    end;
    LCM := maior;
    while ( LCM mod menor ) <> 0 do
    begin
        LCM := LCM + maior
    end
end;
begin
    read(x);
    read(y);
    res := LCM(x,y);
    write(res)
end.
