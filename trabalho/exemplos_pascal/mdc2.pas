program exemplo_mdc2 (input,output);
var x, y: integer; 
function modulo (a,b: integer): integer;
var i,k: real;
begin
    modulo := a mod b
end;
function mdc (a,b: integer): integer;
var l,m: real; 
var n: integer;
begin
    if b = 0 then mdc := a
    else mdc := mdc (b, modulo(a, b) )
end;

begin
    read (x,y);
    write ( mdc(x,y) )
end.
