set(DDR lmb_bram_0)
set(axi_bram_0 "0xc0000000;0x100000")
set(lmb_bram_0 "0x50;0x7fb0")
set(TOTAL_MEM_CONTROLLERS "lmb_bram_0;axi_bram_0")
set(MEMORY_SECTION "MEMORY
{
	axi_bram_0 : ORIGIN = 0xc0000000, LENGTH = 0x100000
	lmb_bram_0 : ORIGIN = 0x50, LENGTH = 0x7fb0
}")
set(STACK_SIZE 0x400)
set(HEAP_SIZE 0x800)
