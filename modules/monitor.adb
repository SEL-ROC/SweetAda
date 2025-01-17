-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ monitor.adb                                                                                               --
-- __DSC__                                                                                                           --
-- __HSH__ e69de29bb2d1d6434b8b29ae775ad8c2e48c5391                                                                  --
-- __HDE__                                                                                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Copyright (C) 2020, 2021, 2022 Gabriele Galeotti                                                                  --
--                                                                                                                   --
-- SweetAda web page: http://sweetada.org                                                                            --
-- contact address: gabriele.galeotti@sweetada.org                                                                   --
-- This work is licensed under the terms of the MIT License.                                                         --
-- Please consult the LICENSE.txt file located in the top-level directory.                                           --
-----------------------------------------------------------------------------------------------------------------------

with Ada.Characters.Latin_1;
with BSP;
with Console;
with Core;
with Srecord;

package body Monitor is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   package ISO88591 renames Ada.Characters.Latin_1;

   Banner      : constant String := "SweetAda monitor";
   Buffer_Size : constant Positive := 32;
   Buffer      : String (1 .. Buffer_Size);
   Buffer_Idx  : Positive;

   procedure Getline;
   procedure Help;

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- Getline
   ----------------------------------------------------------------------------
   procedure Getline is
      C : Character;
   begin
      Buffer_Idx := 1;
      loop
         BSP.Console_Getchar (C);
         case C is
            when ISO88591.BS | ISO88591.DEL =>
               if Buffer_Idx > 1 then
                  Buffer_Idx := @ - 1;
                  BSP.Console_Putchar (ISO88591.BS);
                  BSP.Console_Putchar (ISO88591.Space);
                  BSP.Console_Putchar (ISO88591.BS);
               end if;
            when ISO88591.CR =>
                  BSP.Console_Putchar (ISO88591.CR);
                  BSP.Console_Putchar (ISO88591.LF);
                  exit;
            when '0' .. '9' | 'A' .. 'Z' | 'a' .. 'z' =>
               if Buffer_Idx <= Buffer'Last then
                  BSP.Console_Putchar (C);
                  if C in 'A' .. 'Z' then
                     C := Character'Val (Character'Pos (C) + 32);
                  end if;
                  Buffer (Buffer_Idx) := C;
                  Buffer_Idx := @ + 1;
               end if;
            when others =>
               null;
         end case;
      end loop;
   end Getline;

   ----------------------------------------------------------------------------
   -- Help
   ----------------------------------------------------------------------------
   procedure Help is
   begin
      Console.Print ("help    - this help",        NL => True);
      Console.Print ("srecord - Srecord download", NL => True);
      Console.Print ("tick    - print Tick_Count", NL => True);
   end Help;

   ----------------------------------------------------------------------------
   -- Monitor
   ----------------------------------------------------------------------------
   procedure Monitor is
   begin
      Console.Print (Banner, NL => True);
      loop
         Console.Print ("# ");
         Getline;
         if Buffer_Idx > 1 then
            if    Buffer (1 .. 4) = "help" then
               Help;
            elsif Buffer (1 .. 7) = "srecord" then
               Srecord.Init (
                             BSP.Console_Getchar'Access,
                             BSP.Console_Putchar'Access,
                             False
                            );
               Srecord.Receive;
            elsif Buffer (1 .. 4) = "tick" then
               Console.Print (Core.Tick_Count, NL => True);
            else
               Console.Print ("*** Error: unrecognized command.", NL => True);
            end if;
         end if;
      end loop;
   end Monitor;

end Monitor;
