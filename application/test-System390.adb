
with X3270;

package body Application is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   procedure Run is
   begin
      -------------------------------------------------------------------------
      -- This fragment of code waits for "Attn" to be pressed on the X3270
      -- terminal keypad, then writes a message. Loops over 10 times.
      -------------------------------------------------------------------------
      X3270.Clear_Screen;
      for R in 1 .. 10 loop
         -- X3270.Write_Message ("Welcome to SweetAda S/390 ...", R, 0);
         X3270.Write_Message ("Welcome to SweetAda S/390 ...");
      end loop;
      -------------------------------------------------------------------------
      loop null; end loop;
      -------------------------------------------------------------------------
   end Run;

end Application;