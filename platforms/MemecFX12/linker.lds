
ENTRY(_start)

MEMORY
{
        SDRAM : ORIGIN = 0x00000000, LENGTH = 64M
        BRAM  : ORIGIN = 0xFFFFE000, LENGTH = 8K /* xps_bram_if_cntlr_1 */
}

PROVIDE(_brk_end = 16K) ;

SECTIONS
{
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
        .text :
        {
                _stext = .;
                *(.text)
                *(.text.*)
                *(.rodata)
                *(.rodata.*)
                *(.sdata*)
                _etext = .;
                . = 0x1FFC;
                *(.reset)
                . = ALIGN(0x10);
        } > SDRAM
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
        .data (NOLOAD) :
        {
                _sdata = .;
                *(.data)
                *(.data.*)
                . = ALIGN(0x10);
                _edata = .;
        } > SDRAM
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
        } > SDRAM
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
/*
        .rela.dyn (NOLOAD) :
        {
                *(.rela.init)
                . = ALIGN(0x10);
        }
*/
/*
        .text :
        {
                _stext = .;
                *(.text)
                *(.text.*)
                *(.rodata)
                *(.rodata.*)
                *(.sdata*)
                _etext = .;
                . = 0x1FFC;
                *(.reset)
                . = ALIGN(0x10);
        } > BRAM
*/
/*
        .reset 0xFFFFFFFC :
        {
                *(.reset)
        }
*/
        /**********************************************************************
         *                                                                    *
         **********************************************************************/
        /DISCARD/ :
        {
                *(.comment)
        }

}

