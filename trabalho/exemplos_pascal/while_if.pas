program whileLoop (input,output);
var
   i, num, maior: integer;
begin
   read(maior);
   i := 1;
   while  i < 10  do
   begin
      read(num);
      if num > maior
      then
          maior := num
      else
          maior := maior;
      i := i + 1
  end;
  write(maior)
end.
