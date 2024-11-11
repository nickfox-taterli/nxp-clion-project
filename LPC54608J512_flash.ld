/* 入口点 */
ENTRY(Reset_Handler)  /* 设置程序的入口点为 Reset_Handler 函数 */

/* 堆区大小和栈区大小的定义 */
HEAP_SIZE  = DEFINED(__heap_size__)  ? __heap_size__  : 0x0400;  /* 堆区大小,默认为 1KB */
STACK_SIZE = DEFINED(__stack_size__) ? __stack_size__ : 0x0;     /* 栈区大小,默认为 0 */

/* 指定内存区域 */
MEMORY
{
  NVIC_VECTOR (RX)  : ORIGIN = 0x00000000, LENGTH = 0x00000400  /* NVIC 向量表,起始地址 0x00000000,大小 1KB */
  ONCHIP_FLASH  (RX)  : ORIGIN = 0x00000400, LENGTH = 0x0007FC00  /* 内部 Flash 存储器,起始地址 0x00000400,大小 511KB */
  OFFCHIP_FLASH (RX)  : ORIGIN = 0x10000000, LENGTH = 0x1000000  /* 外部 Flash 存储器,起始地址 0x10000000,大小 16MB */
  SRAM_UPPER  (RW)  : ORIGIN = 0x20000000, LENGTH = 0x00028000  /* 上层 SRAM,起始地址 0x20000000,大小 160KB */
  SRAMX (RW)  : ORIGIN = 0x04000000, LENGTH = 0x00008000  /* SRAMX 存储器,起始地址 0x04000000,大小 32KB */
  USB_RAM (RW)  : ORIGIN = 0x40100000, LENGTH = 0x00002000  /* USB 数据 RAM,起始地址 0x40100000,大小 8KB */
  SDRAM (RW)  : ORIGIN = 0xa0000000, LENGTH = 0x1000000  /* SDRAM,起始地址 0xA0000000,大小 16MB */
}

/* 定义输出节区 */
SECTIONS
{
  /* 中断向量表,存放在内部 Flash */
  .interrupts :
  {
    . = ALIGN(4);  /* 4 字节对齐 */
    KEEP(*(.isr_vector))  /* 保留中断向量表 */
    . = ALIGN(4);  /* 4 字节对齐 */
  } > NVIC_VECTOR  /* 存储在 NVIC_VECTOR 区域 */

  /* 程序代码和只读数据,存放在内部 Flash */
  .text :
  {
    . = ALIGN(4);  /* 4 字节对齐 */
    *(.text)  /* 存放代码 */
    *(.text*)  /* 存放代码扩展 */
    *(.rodata)  /* 存放只读数据（常量、字符串等） */
    *(.rodata*)  /* 存放只读数据扩展 */
    *(.glue_7)  /* ARM 转 Thumb 代码 */
    *(.glue_7t)  /* Thumb 转 ARM 代码 */
    *(.eh_frame)  /* 异常处理框架 */
    KEEP (*(.init))  /* 保留初始化代码 */
    KEEP (*(.fini))  /* 保留终结代码 */
    . = ALIGN(4);  /* 4 字节对齐 */
  } > ONCHIP_FLASH  /* 存储在 ONCHIP_FLASH 区域 */

  /* ARM 异常表,存放在内部 Flash */
  .ARM.extab :
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*)
  } > ONCHIP_FLASH

  /* ARM 异常索引表,存放在内部 Flash */
  .ARM :
  {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } > ONCHIP_FLASH

  /* 构造函数（ctors）,存放在内部 Flash */
  .ctors :
  {
    __CTOR_LIST__ = .;
    KEEP (*crtbegin.o(.ctors))  /* 保留 crtbegin.o 中的构造函数 */
    KEEP (*crtbegin?.o(.ctors))  /* 保留 crtbegin?.o 中的构造函数 */
    KEEP (*(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors))  /* 排除 crtend.o 中的构造函数 */
    KEEP (*(SORT(.ctors.*)))  /* 排序所有构造函数 */
    KEEP (*(.ctors))  /* 保留其他构造函数 */
    __CTOR_END__ = .;
  } > ONCHIP_FLASH

  /* 析构函数（dtors）,存放在内部 Flash */
  .dtors :
  {
    __DTOR_LIST__ = .;
    KEEP (*crtbegin.o(.dtors))  /* 保留 crtbegin.o 中的析构函数 */
    KEEP (*crtbegin?.o(.dtors))  /* 保留 crtbegin?.o 中的析构函数 */
    KEEP (*(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors))  /* 排除 crtend.o 中的析构函数 */
    KEEP (*(SORT(.dtors.*)))  /* 排序所有析构函数 */
    KEEP (*(.dtors))  /* 保留其他析构函数 */
    __DTOR_END__ = .;
  } > ONCHIP_FLASH

  /* 预初始化数组（preinit_array）,存放在内部 Flash */
  .preinit_array :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);  /* 定义预初始化数组起始符号 */
    KEEP (*(.preinit_array*))  /* 保留所有预初始化数组 */
    PROVIDE_HIDDEN (__preinit_array_end = .);  /* 定义预初始化数组结束符号 */
  } > ONCHIP_FLASH

  /* 初始化数组（init_array）,存放在内部 Flash */
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);  /* 定义初始化数组起始符号 */
    KEEP (*(SORT(.init_array.*)))  /* 排序初始化数组 */
    KEEP (*(.init_array*))  /* 保留所有初始化数组 */
    PROVIDE_HIDDEN (__init_array_end = .);  /* 定义初始化数组结束符号 */
  } > ONCHIP_FLASH

  /* 结束数组（fini_array）,存放在内部 Flash */
  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);  /* 定义结束数组起始符号 */
    KEEP (*(SORT(.fini_array.*)))  /* 排序结束数组 */
    KEEP (*(.fini_array*))  /* 保留所有结束数组 */
    PROVIDE_HIDDEN (__fini_array_end = .);  /* 定义结束数组结束符号 */
  } > ONCHIP_FLASH

  __etext = .;  /* 定义代码结束符号 */
  __DATA_ROM = .;  /* 定义数据初始化符号 */

  /* 数据区,存放已初始化的数据 */
  .data : AT(__DATA_ROM)
  {
    . = ALIGN(4);  /* 4 字节对齐 */
    __DATA_RAM = .;
    __data_start__ = .;  /* 数据区起始符号 */
    *(.ramfunc*)  /* 存放函数数据 */
    *(.data)  /* 存放初始化数据 */
    *(.data*)  /* 存放初始化数据扩展 */
    KEEP(*(.jcr*))  /* 保留 JCR 数据 */
    . = ALIGN(4);  /* 4 字节对齐 */
    __data_end__ = .;  /* 数据区结束符号 */
  } > SRAM_UPPER  /* 存储在 SRAM_UPPER 区域 */

  __DATA_END = __DATA_ROM + (__data_end__ - __data_start__);
  text_end = ORIGIN(ONCHIP_FLASH) + LENGTH(ONCHIP_FLASH);
  ASSERT(__DATA_END <= text_end, "region ONCHIP_FLASH overflowed with text and data")  /* 检查数据区是否溢出 */

  /* 未初始化数据区（BSS）,存放未初始化的全局变量 */
  .bss :
  {
    . = ALIGN(4);  /* 4 字节对齐 */
    __START_BSS = .;  /* BSS 区起始符号 */
    __bss_start__ = .;
    *(.bss)  /* 存放未初始化数据 */
    *(.bss*)  /* 存放未初始化数据扩展 */
    *(COMMON)  /* 存放公共 BSS 数据 */
    . = ALIGN(4);  /* 4 字节对齐 */
    __bss_end__ = .;  /* BSS 区结束符号 */
    __END_BSS = .;
  } > SRAM_UPPER  /* 存储在 SRAM_UPPER 区域 */

  /* 堆区,动态分配内存 */
  .heap :
  {
    . = ALIGN(8);  /* 8 字节对齐 */
    __end__ = .;  /* 堆区结束符号 */
    PROVIDE(end = .);  /* 提供堆结束符号 */
    __HeapBase = .;  /* 堆区起始符号 */
    . += HEAP_SIZE;  /* 堆区大小 */
    __HeapLimit = .;  /* 堆区结束符号 */
    __heap_limit = .;  /* 为 _sbrk 添加堆限制 */
  } > SRAM_UPPER  /* 存储在 SRAM_UPPER 区域 */

  /* 栈区,存放局部变量 */
  .stack :
  {
    . = ALIGN(8);  /* 8 字节对齐 */
    . += STACK_SIZE;  /* 栈区大小 */
  } > SRAM_UPPER  /* 存储在 SRAM_UPPER 区域 */

  /* USB BDT (Buffer Descriptor Table) 区 */
  m_usb_bdt (NOLOAD) :
  {
    . = ALIGN(512);  /* 512 字节对齐 */
    *(m_usb_bdt)
  } > USB_RAM  /* 存储在 USB_RAM 区域 */

  /* USB 全局变量区 */
  m_usb_global (NOLOAD) :
  {
    *(m_usb_global)
  } > USB_RAM  /* 存储在 USB_RAM 区域 */

  /* 初始化栈指针,栈指针初始化为 SRAM_UPPER 区的末尾 */
  __StackTop   = ORIGIN(SRAM_UPPER) + LENGTH(SRAM_UPPER);
  __StackLimit = __StackTop - STACK_SIZE;
  PROVIDE(__stack = __StackTop);  /* 提供栈指针 */

  .ARM.attributes 0 : { *(.ARM.attributes) }  /* ARM 架构属性 */

  ASSERT(__StackLimit >= __HeapLimit, "region SRAM_UPPER overflowed with stack and heap")  /* 检查栈区和堆区是否重叠 */
}
