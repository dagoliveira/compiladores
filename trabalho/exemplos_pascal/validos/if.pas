program ifSimples (input,output);
var
   a,b: integer;
begin
   read(a);
   if a > 0
   then
       b := a + 5
   else
       b := a + 50;
   write(b)
end.
