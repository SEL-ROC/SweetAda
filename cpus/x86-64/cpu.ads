-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ cpu.ads                                                                                                   --
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

with x86_64;

package CPU is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                               Public part                              --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- CPU helper subprograms
   ----------------------------------------------------------------------------

   procedure NOP renames x86_64.NOP;

   ----------------------------------------------------------------------------
   -- Exceptions and interrupts
   ----------------------------------------------------------------------------

   subtype Irq_State_Type is x86_64.Irq_State_Type;
   subtype Irq_Id_Type    is x86_64.Exception_Id_Type;

   procedure Irq_Enable                                    renames x86_64.Irq_Enable;
   procedure Irq_Disable                                   renames x86_64.Irq_Disable;
   function Irq_State_Get return Irq_State_Type            renames x86_64.Irq_State_Get;
   procedure Irq_State_Set (Irq_State : in Irq_State_Type) renames x86_64.Irq_State_Set;

   ----------------------------------------------------------------------------
   -- Locking
   ----------------------------------------------------------------------------

   subtype Lock_Type is x86_64.Lock_Type;

   procedure Lock_Try (Lock_Object : in out x86_64.Lock_Type; Success : out Boolean) renames x86_64.Lock_Try;
   procedure Lock (Lock_Object : in out x86_64.Lock_Type)                            renames x86_64.Lock;
   procedure Unlock (Lock_Object : out x86_64.Lock_Type)                             renames x86_64.Unlock;

end CPU;
