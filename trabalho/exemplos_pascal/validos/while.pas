program whileLoop (input,output);
var
   a,b: integer;
begin
   a := 10;
   b := 1;
   while  a > 0  do
   begin
      b := b - 1 + a;
      a := a - 1
   end;
   write(b)
end.
