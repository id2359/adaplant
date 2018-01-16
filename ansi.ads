
PACKAGE ANSI is

  Type Color is (Black, Red, Green, Yellow, Blue, Magenta, Cyan, White);

  type Attribute is record
    Bold        : Boolean       := false;
    Blink       : Boolean       := false;
    Background  : Color         := black;
    Foreground  : Color         := white;
  end record;

  Normal : constant Attribute := (false,false,black,white);

  Screen_Depth : CONSTANT Integer := 24;
  Screen_Width : CONSTANT Integer := 80;

  SUBTYPE Depth IS Integer RANGE 1..Screen_Depth;
  SUBTYPE Width IS Integer RANGE 1..Screen_Width;

  Procedure Set_Attribute (To : Attribute := Normal);

  Procedure Put_Box (Row : Depth; Column : Width;
                     Size1: Depth; Size2 : Width);

  PROCEDURE Move_Cursor (Row : Depth;Column : Width);

  FUNCTION Random RETURN Integer;

  PROCEDURE Reset;

  PROCEDURE Quit;

  Procedure Lock;

  Procedure UnLock;

END ANSI;
