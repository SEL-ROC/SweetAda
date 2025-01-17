
//
// startup.S - HiFive1 startup.
//
// Copyright (C) 2020, 2021, 2022 Gabriele Galeotti
//
// This work is licensed under the terms of the MIT License.
// Please consult the LICENSE.txt file located in the top-level directory.
//

#define __ASSEMBLER__ 1

////////////////////////////////////////////////////////////////////////////////

                .sect   .startup,"ax"

                .type   _start,@function
                .global _start
_start:

                //
                // Set Previous Privilege Mode.
                // S: 1 << 11
                // M: 3 << 11
                //
                li      t0,0x3<<11                      // "M" mode
                csrw    mstatus,t0
                //li      t0,0xFFFF
                //csrw    medeleg,t0
                //csrw    mideleg,t0
                la      t0,1f
                csrw    mepc,t0
                mret
1:

                //
                // Allow only hart #0.
                //
                csrr    t0,mhartid
                bnez    t0,hart_idle

                //
                // Setup stack pointer.
                //
                la      sp,kernel_stack

                //
                // Jump to high-level code.
                //
                .extern _ada_main
                call    _ada_main

dead:           j       .

hart_idle:
                wfi
                j       hart_idle

                .size   _start,.-_start

////////////////////////////////////////////////////////////////////////////////

                .sect   .bss

                .align  8
                .space  4096
kernel_stack:

