
//
// startup.S - x86-64 startup.
//
// Copyright (C) 2020, 2021, 2022 Gabriele Galeotti
//
// This work is licensed under the terms of the MIT License.
// Please consult the LICENSE.txt file located in the top-level directory.
//

#define __ASSEMBLER__ 1

#include <x86-64.h>
#include <selectors.h>

////////////////////////////////////////////////////////////////////////////////

                // macros for calling code without using the stack (which will
                // be trashed by the memory wipeout performed by zerobss)

                .macro  fcall address
                movq    $Lfcall\@,%rsp
                jmp     \address
Lfcall\@:       // next instruction
                .endm

                .macro  fret
                jmp     *%rsp
                .endm

////////////////////////////////////////////////////////////////////////////////

#include "startup-pmdriver.S"

////////////////////////////////////////////////////////////////////////////////

                .code64

                .sect   .startup,"ax"

                .type   _start,@function
                .global _start
_start:

////////////////////////////////////////////////////////////////////////////////

#include "startup-mode64.S"

////////////////////////////////////////////////////////////////////////////////

                cli
                cld
                xorq    %rax,%rax
                xorq    %rbx,%rbx
                xorq    %rcx,%rcx
                xorq    %rdx,%rdx
                xorq    %rbp,%rbp
                xorq    %rsi,%rsi
                xorq    %rdi,%rdi

                //
                // Setup segments. In 64-bit Long Mode DS,ES,SS are not used.
                //
                movw    $SELECTOR_KDATA_64,%ax
                movw    %ax,%fs
                movw    %ax,%gs

                //
                // Turn off PC speaker and enable GATE on timer counter 2.
                //
                inb     $0x61,%al               // get PORT_B settings
                andb    $0b11111101,%al         // turn off PC speaker
                orb     $0b00000001,%al         // turn on GATE2 input
                outb    %al,$0x61               // output new settings

#if 0
                //
                // Enable A20 line.
                // __REF__ http://stanislavs.org/helppc/8042.html
                //
                fcall   reset_8042
                movb    $0xD1,%al               // Write Output Port: next byte written to port 60h is placed in the 8042 output port
                outb    %al,$0x64
                fcall   reset_8042
                movb    $0xDF,%al               // A20 line on
                outb    %al,$0x60
                fcall   reset_8042
                // check if enabled
                xorl    %eax,%eax
1:              movl    %eax,%ebx               // save EAX
                movl    $100,%ecx               // 10 ms delay
                fcall   delay
                movl    %ebx,%eax               // restore EAX
                incl    %eax
                movl    %eax,0x000000
                cmpl    %eax,0x100000
                je      1b
#endif

////////////////////////////////////////////////////////////////////////////////

#include "startup-memory.S"

////////////////////////////////////////////////////////////////////////////////

                // perform code relocation
                //fcall   movcode
                // perform static data relocation
                fcall   movdata
                // zero the bss section
                fcall   zerobss

                //
                // Setup stack pointer.
                //
                movq    $kernel_stack,%rsp
                movq    %rsp,%rbp

                //
                // FPU initialization.
                //
                finit

                //
                // Jump to high-level code.
                //
                .extern _ada_main
                call    _ada_main

dead:           jmp     .

                .size   _start,.-_start

////////////////////////////////////////////////////////////////////////////////
// movcode                                                                    //
//                                                                            //
// Perform code relocation.                                                   //
// This function does not need a stack.                                       //
////////////////////////////////////////////////////////////////////////////////

movcode:
#if 0
                .extern _text_start
                .extern _stext
                .extern _etext
                movl    $_stext,%edi
                movl    $_etext,%ecx
                subl    %edi,%ecx
                movl    $_text_start,%esi
            rep movsb
#endif
                fret

////////////////////////////////////////////////////////////////////////////////
// movdata                                                                    //
//                                                                            //
// Perform high-level language data relocation.                               //
// This function does not need a stack.                                       //
////////////////////////////////////////////////////////////////////////////////

movdata:
                .extern _etext
                .extern _sdata
                .extern _edata
                movl    $_sdata,%edi
                movl    $_edata,%ecx
                subl    %edi,%ecx
                movl    $_etext,%esi
            rep movsb
                fret

////////////////////////////////////////////////////////////////////////////////
// zerobss                                                                    //
//                                                                            //
// Perform a cleanup of the .bss area.                                        //
// This function does not need a stack.                                       //
////////////////////////////////////////////////////////////////////////////////

zerobss:
                .extern _sbss
                .extern _ebss
                xorb    %al,%al
                movl    $_sbss,%edi
                movl    $_ebss,%ecx
                subl    %edi,%ecx
            rep stosb
                fret

////////////////////////////////////////////////////////////////////////////////
// reset_8042                                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

reset_8042:     movl    %esp,%ebp               // save return address
1:              movl    $10,%ecx                // 1 ms delay
                fcall   delay
                inb     $0x64,%al               // status port
                testb   $1,%al                  // data present?
                jz      2f
                movl    $10,%ecx                // 1 ms delay
                fcall   delay
                inb     $0x60,%al               // flush data
                jmp     1b
2:              testb   $2,%al                  // is input buffer full?
                jnz     1b                      // yes, loop again
                movl    %ebp,%esp
                fret

////////////////////////////////////////////////////////////////////////////////
// delay                                                                      //
//                                                                            //
// 100 us delay * ECX                                                         //
// PIT timer input frequency: 1.193182 MHz, t = 0.838 us                      //
// 100 us --> count = 119.33 = 0x77 (0x76 because the timer counts N + 1)     //
// MODE 0, INTERRUPT ON TERMINAL COUNT, monitor OUT pin                       //
// if COUNTER2 should be used, enable GATE via KBD port 0x61 bit 0            //
////////////////////////////////////////////////////////////////////////////////

delay:          movw    $0x43,%dx               // CONTROL_WORD_REGISTER
                movb    $30,%al                 // COUNTER0, CNT_BOTH_BYTE, MODE0, COUNT_BINARY
                outb    %al,%dx
                // 100 us timing
                movw    $0x40,%dx
                movb    $0x76,%al
                outb    %al,%dx
                movb    $0x00,%al
                outb    %al,%dx
                // read-back OUT state
1:              movw    $0x43,%dx               // CONTROL_WORD_REGISTER
                movb    $0xE2,%al               // LATCH STATUS
                outb    %al,%dx
                movw    $0x40,%dx               // read STATUS from COUNTER0
                inb     %dx,%al
                testb   $0x80,%al               // OUT is active?
                jne     1b
                loop    delay
                fret

////////////////////////////////////////////////////////////////////////////////

                .sect   .data

////////////////////////////////////////////////////////////////////////////////

                .sect   .bss

                .align  8
                .space  4096
kernel_stack:

