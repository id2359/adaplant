with Plant;use Plant;
procedure MySolution is

procedure Fill(Tank:Integer; L:Float) is
begin
     In_Valve(Tank, True);
  while Level(Tank) < L loop
     delay 1.0;
   end loop;
   In_Valve(Tank, False);
  
end Fill;

procedure Heat(Tank: Integer; Temp:Float) is
begin
   Heater(Tank, True);
   while Temperature(Tank) < Temp loop
     delay 1.0;
   end loop;
   Heater(Tank, False);
end Heat;

procedure Empty(Tank: Integer) is
begin
   Out_Valve(Tank, True);
   while Level(Tank) > 0.0 loop
      delay 1.0;
   end loop;
end Empty;


begin
   Fill(1, 40.0);
   Heat(1, 100.0);
   Fill(2, 40.0);
   Heat(2, 150.0);
   In_Valve(3, True);
   Empty(1);
   Empty(2);
   delay 10.0;
   Empty(3);
   delay 5.00;
   Close;
end MySolution;
