
ENTRY(_start)

MEMORY
{
        ROM : ORIGIN = 0x02000000, LENGTH = 2M
        RAM : ORIGIN = 0x00000000, LENGTH = 8M
}

SECTIONS
{
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
        .text :
        {
                _stext = .;
                KEEP(*(.vectors))
                *(.startup)
                *(.text)
                *(.text.*)
                *(.rodata)
                *(.rodata.*)
                . = ALIGN(0x10);
                *(.glue_7)      /* __FIX__ */
                *(.glue_7t)     /* __FIX__ */
                . = ALIGN(0x10);
                _etext = .;
        } > RAM
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
        .ARM.exidx :
        {
                . = ALIGN(4);
                __exidx_start = .;
                *(.ARM.exidx* .gnu.linkonce.armexidx.*)
                . = ALIGN(4);
                __exidx_end = .;
        } > RAM
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
        .ARM.extab :
        {
                . = ALIGN(4);
                *(.ARM.extab* .gnu.linkonce.armextab.*)
                . = ALIGN(4);
        } > RAM
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
                . = ALIGN(0x10);
        .data :
        {
                _sdata = .;
                *(.data)
                . = ALIGN(8);
                *(.data.*)
                . = ALIGN(0x10);
                _edata = .;
        } > RAM
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
        .bss ADDR(.data) + SIZEOF(.data) (NOLOAD) :
        {
                _sbss = .;
                *(.bss)
                *(.bss.*)
                *(COMMON)
                . = ALIGN(0x10);
                _ebss = .;
        } > RAM
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
        /DISCARD/ :
        {
                *(.comment)
        }
}

