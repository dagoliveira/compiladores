program whileLoopAninhado (input,output);
var
   a,b,c: integer;
begin
   c := 0;
   a := 10;
   while  a > 0  do
   begin
      c := a + c;
      a := a - 1;
      b := 5;
      while  b > 0  do
      begin
        c := c + b;
        b := b - 1
      end
   end;
   write(c)
end.
