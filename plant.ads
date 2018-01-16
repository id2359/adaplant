package Plant is                                        -- A Unit (= Tank) is an integer: 1, 2, 3 
  procedure Close;                                      -- Closes the factory
  Function  Temperature (Unit : Integer) Return Float;  -- Returns the temperature of a certain Unit 
  Function  Level       (Unit : Integer) Return Float;  -- Returns the level of a certain Unit
  procedure Heater      (Unit : Integer;                
                         On   : Boolean);               -- Turns on or off the heater for a certain Unit
  procedure In_Valve    (Unit : Integer;                
			 On   : Boolean);               -- Turns on or off the filling of a certain Unit
  Procedure Out_Valve   (Unit : Integer;                
			 On   : Boolean);               -- Turns on or off the emptying of a certain Unit
end Plant;


