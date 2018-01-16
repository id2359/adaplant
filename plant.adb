with Monitor, ANSI, System, Calendar;
with Text_IO, FIO;
use ANSI;
pragma elaborate (Monitor);
package body Plant is
--  DBG : Text_IO.File_Type;
  Frames : ANSI.Attribute := (  Bold => false,
                                Blink => false,
                                foreground =>red,
                                background =>red);
  meters : ANSI.Attribute := (  Bold => false, -- don't leave bold on after exit
                                Blink => false,
                                foreground =>yellow,
                                background =>blue);
  tanks : ANSI.Attribute := (   Bold => false,
                                Blink => false,
                                foreground =>Red,
                                background =>blue);

  Task type tube is
    entry In_Flow ( Flow : in out Float; Temp :  in Float);
    entry Out_Flow (Flow : in out Float; Temp : out Float);
  end tube;

Tubes : array (1..5) of tube;
Nr_Of_Temps : Integer := 0;
Nr_Of_Levels : Integer := 0;

  type UCB is record
    X     : ANSI.Width;
    Y     : ANSI.Depth;
    Power : Float := 100.0;
    Level : Float := 50.0;
    From1,
    From2  : Integer := 0;
    Next  : Integer := 1;
  end record;


  task type Unit is
    entry Init      (Data : UCB);
    entry Temp      (Data : out Float);
    entry Level     (Data : out Float);
    entry Heater    (On   : Boolean);
    entry In_Valve  (On   : Boolean);
    entry Out_Valve (On   : Boolean);
    entry Close;
  end Unit;

Units : array (1..3) of Unit;
-- internal subprograms:
  Function Check (Nr: Integer) return Boolean is
  begin
    return Nr in 1..3;
  end Check;

  task body Unit is
    D          : UCB;
    Done       : Boolean := false;
    In_Flow    : Float := 0.0;
    Out_Flow   : Float := 0.0;
    Power      : Float := 0.0;
    Curr_Level : Float := 0.0;
    Temperature  : Float := 0.0;
  begin
    select
      accept Init (Data :UCB) do
        D := Data;
      end Init;
    or
      Accept Close;
      Done := true;
    or 
      terminate;
    end select;

    if not Done then
      declare
        use Calendar;
        Next : Time := Clock + 1.0;
        ClockT : Time;
        Next_Event : Duration := 1.0;
        TT : Monitor.Tank;
        T  : Monitor.Meter;
        V  : Monitor.Meter;
      begin
        TT.Init (	"",		-- should add "Tank ID"
	      	      	D.Y,
                        D.X,
                        5.0,
                        Frames,
                        Tanks);

        T.Init  (       "Temp",
	      	      	D.Y+5,
                        D.X+24,
                        5.0,
                        Frames,
                        Meters);
        V.Init  (       "Heater",
	      	      	D.Y+8,
                        D.X+24,
                        5.0,
                        Frames,
                        Meters);

        loop
          ClockT := Clock;
          if ClockT > Next then
            Next_Event := 0.0;
          else
            Next_Event := Next - ClockT;
          end if;
          select
            accept Temp (Data : out Float) do
              Data := Temperature;
            end Temp;
          or
            accept Level (Data : out Float) do
              Data := Curr_Level;
            end Level;
          or
            accept Heater (On : Boolean) do
              If On then
                Power := D.Power;
              else
--                Power := -D.Power*0.5;
                Power := 0.0;
              end if;
            end Heater;
            V.Update (Power);
--          Text_IO.Put_Line (dbg,Integer'Image (D.From2)&" Heater ");
          or
            accept In_Valve (On:Boolean) do
              If On then
                In_Flow := 10.0;
              else
                In_Flow := 0.0;
              end if;
            end In_Valve;
--          Text_IO.Put_Line (dbg,Integer'Image (D.From2)&" In_Valve ");
          or
            accept Out_Valve (On : Boolean) do
              If On then
                Out_Flow := 10.0;
              else
                Out_Flow := 0.0;
              end if;
            end Out_Valve;
--          Text_IO.Put_Line (dbg,Integer'Image (D.From2)&" Out_Valve ");
          or
            accept Close;
            exit;
          or
            delay Next_Event;
            Next := Next + 1.0;
----------------------------------------------------------------------
  declare
    Old_Level : Float := Curr_Level;
    In_F1,
    In_F2     : Float := In_Flow;
    Out_F     : Float := Out_Flow;
    In_T1,
    In_T2     : Float := 0.0;
  begin
    If D.From1 /= 0 then
      Tubes(D.From1).Out_Flow (In_F1,In_T1);
    else
      In_F1 := 0.0;
    end if;
    Tubes(D.From2).Out_Flow (In_F2,In_T2);

    if Out_F > Curr_Level then
      Out_F := Curr_Level;
    end if;

    Tubes(D.Next).In_Flow (Out_F,Temperature);
    Curr_Level := Curr_Level + In_F1 + In_F2 - Out_F;
    If Curr_Level <= 0.0 then
      Curr_Level := 0.0;
    else
--       Temperature := (Old_Level * Temperature +
--                           In_F1 * In_T1 + 
--                           In_F2 * In_T2) / Curr_Level;
      Temperature := (Curr_Level * Temperature +
                           In_F1 * In_T1 + 
                           In_F2 * In_T2) / (Curr_Level + In_F1 + In_F2);
    end if;

--    Temperature := Temperature + (Power*Curr_Level)*2.0E-3;
-- smaller amount takes shorter time to heat.
-- cooling to room temperature when heater power = 0.0
    Temperature := Temperature		-- ideal thermo 
      + (Power/(1.0 + Curr_Level)) * 2.0 -- heating
      - (Temperature - 20.0) * 0.01; -- cool to room temperature

    TT.Update (Curr_Level);
    T.Update  (Temperature);
    V.Update  (Power);
--    Text_IO.Put_Line (dbg,Integer'Image (D.From2)&" STATUS:  ");
--    Fl_IO.Put (dbg, Curr_Level, exp => 0, aft => 3);
--    Text_IO.Set_Col (Dbg,10);
--    Fl_IO.Put (dbg, Temperature, exp => 0, aft => 3);
--    Text_IO.Set_Col (Dbg,20);
--    Fl_IO.Put (dbg, Power, exp => 0, aft => 3);
--    Text_IO.Set_Col (Dbg,30);
--    Fl_IO.Put (dbg, In_Flow, exp => 0, aft => 3);
--    Text_IO.Set_Col (Dbg,40);
--    Fl_IO.Put (dbg, Out_Flow, exp => 0, aft => 3);
--    Text_IO.Set_Col (Dbg,50);
--    Fl_IO.Put (dbg, In_F1, exp => 0, aft => 3);
--    Text_IO.Set_Col (Dbg,60);
--    Fl_IO.Put (dbg, In_F2, exp => 0, aft => 3);
--    Text_IO.New_Line (Dbg);

--    ANSI.Set_Attribute;
--    Text_IO.Put ('*');
  end;
----------------------------------------------------------------------

          end select;
        end loop;
        TT.Close;
        T.Close;
        V.Close;
      end;  
    end if;
  exception
    when others => ANSI.Set_Attribute;
                   Text_IO.Put ("Exception in UNIT!!!");
  end Unit;
----------------------------------------------------------------------
----------------------------------------------------------------------
  task body tube is
    T     : Float := 20.0;
    In_F  : Float := 3.0;
    Out_F : Float := 3.0;
  begin
    loop
      select
        accept In_Flow (Flow : in out Float; Temp : in Float) do
          In_F := Flow;
          If Flow > Out_F then
            Flow := Out_F;
          end if;
          T := Temp;
        end In_Flow;
      or
        accept Out_Flow (Flow : in out Float; Temp : out Float) do
          Out_F := Flow;
          if Flow > In_F then
            Flow := In_F;
          end if;
          Temp := T;
        end Out_Flow;
      or
        terminate;
      end select;
    end loop;
  end Tube;

-- external subprograms:
  procedure Close is
  begin
    for i in units'range loop
      Units(i).Close;
    end loop;
  end;

  procedure warning (s : string) is
    bold : constant string := (ascii.esc, '[', '1', 'm');
    normal : constant string := (ascii.esc, '[', '0', 'm');
  begin
    ansi.lock;
    ansi.move_cursor (row => 24, column => 1);
    text_io.put (bold & "Warning: " & s & normal);
    ansi.unlock;
  end;


  Function  Temperature (Unit : Integer) Return Float is
    Val : Float := 0.0;
  begin
    if Check (Unit) then
      Units (Unit).Temp (Val);
    end if;
    Nr_Of_Temps := Nr_Of_Temps + 1;
    If Nr_Of_Temps /= 1 then
      Val := Float (ANSI.Random) / 5.0;
      warning ("Temperature reading error");
    end if;
    delay 0.1;
    Nr_Of_Temps := Nr_Of_Temps  - 1;

    Return Val;
  end Temperature;

  Function  Level       (Unit : Integer) Return Float is
    Val : Float := 0.0;
  begin
    if Check (Unit) then
      Units (Unit).Level (Val);
    end if;
    Nr_Of_Levels := Nr_Of_Levels + 1;
    If Nr_Of_Levels /= 1 then
      Val := Float (ANSI.Random) / 5.0;
      warning ("Level reading error");
    end if;
    delay 0.1;
    Nr_Of_Levels := Nr_Of_Levels  - 1;

    Return Val;
  end Level;

  procedure Heater      (Unit : Integer; 
                         On   : Boolean) is
  begin
    if Check (Unit) then
      Units (Unit).Heater (On);
    end if;
  end  Heater;

  procedure In_Valve    (Unit : Integer; 
                         On   : Boolean) is
  begin
    if Check (Unit) then
      Units (Unit).In_Valve (On);
    end if;
  end  In_Valve;
  Procedure Out_Valve   (Unit : Integer; 
                         On   : Boolean)  is
  begin
    if Check (Unit) then
      Units (Unit).Out_Valve (On);
    end if;
  end  Out_Valve;


begin
  ANSI.Reset;
  Units(1).Init (( 1, 1,100.0,40.0,0,1,3));
  Units(2).Init ((44, 1,100.0,40.0,0,2,4));
  Units(3).Init ((22,12,240.0,80.0,3,4,5));
  declare
    F : Float := 0.0;
    T : Float := 20.0;
  begin
    Tubes(3).In_Flow (F,T);
    Tubes(4).In_Flow (F,T);
  end;
--  Text_IO.Create (DBG,Text_IO.Out_File, "TP.dbg");
end Plant;
