-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ bsp.adb                                                                                                   --
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

with MPC8306;
with Switch;

package body BSP is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- Console wrappers
   ----------------------------------------------------------------------------

   -- procedure Console_Putchar (C : in Character) is null;
   -- procedure Console_Getchar (C : out Character) is null;

   ----------------------------------------------------------------------------
   -- BSP_Setup
   ----------------------------------------------------------------------------
   procedure BSP_Setup is
   begin
      -- 6.3.2.6 System I/O Configuration Register 2 (SICR_2)
      MPC8306.SICR_1 := 16#0001_165F#; -- UART1A mapped on I/O pads
      MPC8306.SICR_2 := 16#A005_0475#; -- GPIO22 function
      MPC8306.GP1DIR := 16#0000_0200#; -- GPIO22 = output
      MPC8306.GP1ODR := 16#FFFF_FDFF#; -- GPIO22 = actively driven
   end BSP_Setup;

end BSP;
