-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ bsp.adb                                                                                                   --
-- __DSC__                                                                                                           --
-- __HSH__ e69de29bb2d1d6434b8b29ae775ad8c2e48c5391                                                                  --
-- __HDE__                                                                                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Copyright (C) 2020, 2021 Gabriele Galeotti                                                                        --
--                                                                                                                   --
-- SweetAda web page: http://sweetada.org                                                                            --
-- contact address: gabriele.galeotti@sweetada.org                                                                   --
-- This work is licensed under the terms of the MIT License.                                                         --
-- Please consult the LICENSE.txt file located in the top-level directory.                                           --
-----------------------------------------------------------------------------------------------------------------------

with System;
with System.Storage_Elements;
with MMIO;
with GEMI;

package body BSP is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System;
   use System.Storage_Elements;

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
      -- UART -----------------------------------------------------------------
      UART_Descriptor.Base_Address  := To_Address (GEMI.UART_BASEADDRESS);
      UART_Descriptor.Scale_Address := 4;
      UART_Descriptor.Baud_Clock    := 1_843_200;
      UART_Descriptor.Read_8        := MMIO.Read'Access;
      UART_Descriptor.Write_8       := MMIO.Write'Access;
      UART_Descriptor.Data_Queue    := ((others => 0), 0, 0, 0);
      UART16x50.Init (UART_Descriptor);
      -------------------------------------------------------------------------
   end BSP_Setup;

end BSP;
