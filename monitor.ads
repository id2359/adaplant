with ANSI;
with system;
package Monitor is

-- Workaround 2:  Uncomment subtype definition!
  subtype foo is string (1..100);


  task type Meter is
    pragma priority (4);
    entry Init (     	Label  : string := "";
      	      	      	Row    : ANSI.Depth; 
			Column : ANSI.Width; 
			Wait   : Duration;
			Frame  : ANSI.Attribute := ANSI.Normal;
			Val    : ANSI.Attribute := ANSI.Normal);
    entry Update (Data : Float);
    entry Close;
  end Meter;

  task type Tank is
    pragma priority (4);
    entry Init (     	Label  : string := "";
      	      	     	Row    : ANSI.Depth; 
			Column : ANSI.Width; 
			Wait   : Duration;
			Frame  : ANSI.Attribute := ANSI.Normal;
			Val    : ANSI.Attribute := ANSI.Normal);
    entry Update (Data : Float);
    entry Close;
  end Tank;
end Monitor;
