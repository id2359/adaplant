
WITH Text_IO;
WITH Calendar;   -- standard Ada Package
USE  Calendar;
WITH IIO;

PACKAGE BODY ANSI is

  task sema is
    entry seize;
    entry Release;
  end sema;

  Task body sema is
  begin
    loop
      select
        accept Seize;
      or
        terminate;
      end select;
      accept Release;
    end loop;
  end sema;
--
  Procedure Lock is
  begin
    Sema.Seize;
  end Lock;

  Procedure Unlock is
  begin
    Sema.Release;
  end Unlock;


  PROCEDURE Move_Cursor (Row : Depth;Column : Width) is
  -- Move the cursor to a particular row and column on the screen.
  BEGIN
    Text_IO.Put (Item => ASCII.ESC);
    Text_IO.Put ("[");
    IIO.Put (Item => Row, Width => 1);
    Text_IO.Put (Item => ';');
    IIO.Put (Item => Column, Width => 1);
    Text_IO.Put (Item => 'f');
  END Move_Cursor;  

PROCEDURE Reset  IS
--  Draw the Spider's room (fixed size).
  BEGIN
    Text_IO.PUT (ASCII.ESC);
    Text_IO.Put (Item => "[2J"); -- clear screen
    Move_Cursor (1,1);
  END Reset;


  FUNCTION Random RETURN Integer IS 
  -- RAndom number generator based on clock time.
  Now: Time;
  Yr: Year_Number;
  Mo: Month_Number;
  Dy: Day_Number;
  Seconds: Day_Duration;       -- seconds past midnight
  BEGIN
     Now := Clock;
     Split (Now, Yr, Mo, Dy, Seconds);
     Return ( ABS INTEGER(Seconds) mod 1000) ;
  END Random;

  Procedure Set_Attribute (To : Attribute := Normal) is
    Color_Table : constant array (Color) of Character :=
        ('0','1','2','3','4','5','6','7');
    Semi : Boolean := false;
    Procedure Test_and_Write (Test : Boolean; Text: String) is
    begin
      if Test then
        if Semi then
          Text_IO.Put (';');
        end if;
        Text_IO.Put (Text);
        Semi := true;
      end if;
    end Test_And_Write;
  begin
    Text_IO.Put (Item => ASCII.ESC);
    Text_IO.Put ("[");
    if To = Normal then
      Text_IO.Put ('0');
    else
      Test_And_Write (To.Bold, "1");
      Test_And_Write (To.Blink,"5");
      Test_And_Write (true,"4"&Color_Table(To.Background));
      Test_And_Write (true,"3"&Color_Table(To.Foreground));
    end if;
    Text_IO.Put ('m');
  end Set_Attribute;

  Procedure Put_Box (Row : Depth; Column : Width;
                     Size1: Depth; Size2 : Width) is
  begin
    Move_Cursor (Row,Column);
    Text_IO.Put ('+');
    For i in 1..Size2-Column-1 loop
     Text_IO.Put ('-');
    end loop;
    Move_Cursor (Row,Size2);
    Text_IO.Put ('+');

    Move_Cursor (Size1,Column);
    Text_IO.Put ('+');
    For i in 1..Size2-Column-1 loop
     Text_IO.Put ('-');
    end loop;
    Move_Cursor (Size1,Size2);
    Text_IO.Put ('+');

    for y in Row+1..Size1-1 loop
      Move_Cursor (y,Column);
      Text_IO.Put ('!');
      Move_Cursor (y,Size2);
      Text_IO.Put ('!');
    end loop;
  end Put_Box;



PROCEDURE Quit IS
-- Quit command.
BEGIN
    Move_Cursor(24,1);
END Quit;

END ANSI;

