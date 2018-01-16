with FIO;
with text_IO;
with ansi;
pragma elaborate (ansi);

package body Monitor is


  task body Meter is
    Done  : Boolean := false;
    Old_Value : Float := -1.0;
    Value : Float := 0.0;
--    MiLabel : string (1..100);  -- Due to adacomp BUG
    MiLabel : foo;
    X     : ANSI.width;
    Y     : ANSI.Depth;
    Tau   : Duration;
    Fr_Attr : ANSI.Attribute;
    V_Attr  : ANSI.Attribute;

    procedure  Show is
    begin
      if Value /= Old_Value then
        Old_Value := Value;
        ANSI.Lock;
        ANSI.Set_Attribute (V_Attr);
        ANSI.Move_Cursor (Y,X);
        FIO.Put (Value,exp=>0, aft =>3);
        ANSI.Unlock;
      end if;
    exception
      when others => ANSI.Unlock;
    end Show;
  begin
    select 
      accept Init (     Label : string := "";
      	      	      	Row : ANSI.Depth; 
			Column : ANSI.Width ; 
			Wait : Duration;
			Frame  : ANSI.Attribute := ANSI.Normal;
			Val    : ANSI.Attribute := ANSI.Normal) do
-- adacomp 
-- chaos: dcl_put_vis found duplicate entryn0001
-- execution abandoned 
        MiLabel  (1..Label'last) := Label;
        X := Column;
        Y := Row;
        Tau := Wait;
        Fr_Attr := Frame;
        V_Attr  := Val;
      end Init;
    or
      accept Close;
      Done := true;
    end select;

    if Not Done then
      ANSI.Lock;
      begin
        ANSI.Set_Attribute (Fr_Attr);
        ANSI.Put_Box (Y-1,X-1,Y+1,X+12);
	ANSI.Move_Cursor (Y-1,X);
	Text_Io.Put (MiLabel);
        ANSI.Unlock;
      exception
        when others => ANSI.Unlock;
      end;
    end if;


    while not Done loop
      select
        accept Update (Data : Float) do
          Value := Data;
        end Update;
        Show;
      or
        accept Close;
        exit;
      or
        delay Tau;
        Show;
      end select;
    end loop;
  end Meter;


  task body Tank is
    Done  : Boolean := false;
    Old_Value : Float := -1.0;
    Value : Float := 0.0;
--    MiLabel : string (1..100);
    MiLabel : foo;
    X     : ANSI.width;
    Y     : ANSI.Depth;
    Tau   : Duration;
    Fr_Attr : ANSI.Attribute;
    V_Attr  : ANSI.Attribute;

    procedure  Show is
      Val : Float := Value - 100.0;
    begin
      If Old_Value /= Value then
        Old_Value := Value;
        ANSI.Lock;
        ANSI.Set_Attribute;
        for yy in y+1..y+11 loop
          ANSI.Move_Cursor (YY,X+1);
          if val > 0.0 then
            ANSI.Set_Attribute (V_Attr);
            text_IO.Put ("XXXXXXXXXXXXXXXXXXXXX");
          else
            text_IO.Put ("                     ");
          end if;
          val := Val + 10.0;
        end loop;
        ANSI.Unlock;
      end if;
    exception
      when others => ANSI.Unlock;
    end Show;
  begin
    select 
      accept Init (     Label : string := "";
      	      	      	Row : ANSI.Depth; 
			Column : ANSI.Width ; 
			Wait : Duration;
			Frame  : ANSI.Attribute := ANSI.Normal;
			Val    : ANSI.Attribute := ANSI.Normal) do
	Milabel (1..label'last):= Label;
        X := Column;
        Y := Row;
        Tau := Wait;
        Fr_Attr := Frame;
        V_Attr  := Val;
      end Init;
    or
      accept Close;
      Done := true;
    end select;

    if Not Done then
      ANSI.Lock;
      begin
        ANSI.Set_Attribute (Fr_Attr);
        ANSI.Put_Box (Y,X,Y+12,X+22);
	ANSI.Move_Cursor (Y,X+1);	-- Is different than for Meter
	Text_Io.Put (MiLabel);
        ANSI.Unlock;
      exception
        when others => ANSI.Unlock;
      end;
    end if;


    while not Done loop
      select
        accept Update (Data : Float) do
          Value := Data;
        end Update;
        Show;
      or
        accept Close;
        exit;
      or
        delay Tau;
        Show;
      end select;
    end loop;
  end Tank;


end Monitor;
