-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ arm.adb                                                                                                   --
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

with System.Machine_Code;
with Definitions;

package body ARM is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System.Machine_Code;

   CRLF : String renames Definitions.CRLF;

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- NOP
   ----------------------------------------------------------------------------
   procedure NOP is
   begin
      Asm (
           Template => ""            & CRLF &
                       "        nop" & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => No_Input_Operands,
           Clobber  => "",
           Volatile => True
          );
   end NOP;

   ----------------------------------------------------------------------------
   -- BREAKPOINT
   ----------------------------------------------------------------------------
   procedure BREAKPOINT is
   begin
      Asm (
           Template => ""                                 & CRLF &
                       "        " & BREAKPOINT_Asm_String & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => No_Input_Operands,
           Clobber  => "",
           Volatile => True
          );
   end BREAKPOINT;

   ----------------------------------------------------------------------------
   -- Irq_Enable (IRQ)
   ----------------------------------------------------------------------------
   procedure Irq_Enable is
   begin
      Asm (
           Template => ""                            & CRLF &
                       "        mrs     r1,cpsr"     & CRLF &
                       "        bic     r1,r1,#0x80" & CRLF &
                       "        msr     cpsr_c,r1"   & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => No_Input_Operands,
           Clobber  => "",
           Volatile => True
          );
   end Irq_Enable;

   ----------------------------------------------------------------------------
   -- Irq_Disable (IRQ)
   ----------------------------------------------------------------------------
   procedure Irq_Disable is
   begin
      Asm (
           Template => ""                            & CRLF &
                       "        mrs     r1,cpsr"     & CRLF &
                       "        orr     r1,r1,#0x80" & CRLF &
                       "        msr     cpsr_c,r1"   & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => No_Input_Operands,
           Clobber  => "",
           Volatile => True
          );
   end Irq_Disable;

   ----------------------------------------------------------------------------
   -- Memory synchronization
   ----------------------------------------------------------------------------
   -- __REF__ libgcc/config/arm/freebsd-atomic.c
   -- __REF__ libgcc/config/arm/linux-atomic.c
   ----------------------------------------------------------------------------
   procedure Memory_Synchronization is
   begin
      Asm (
           -- __TBD__
           Template => ""            & CRLF &
                       "        nop" & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => No_Input_Operands,
           Clobber  => "memory",
           Volatile => True
          );
   end Memory_Synchronization;

end ARM;
