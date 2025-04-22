program whileLoopAninhado (input,output);
var
   a,b: integer;
begin
   a := 10;
   while  a > 0  do
   begin
      write(a);
      a := a - 1;
      b := 5;
      while  b > 0  do
      begin
        write(b);
        b := b - 1
      end
   end
end.
