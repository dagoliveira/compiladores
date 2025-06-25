program ifAninhado (input,output);
var
   a,b,c: integer;
begin
   read(a);
   read(b);
   read(c);
   if a > b
   then
       if a > c
	then
		write(a)
	else
		write(c)
   else
       write(b)
end.
