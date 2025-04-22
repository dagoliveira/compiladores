program ifSimples (input,output);
var
   a,b: integer;
begin
   read(a);
   if a > 0
   then
       a := a + 5
   else
       a := a + 50;
   write(a)
end.
