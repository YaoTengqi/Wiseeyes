#include "xil_printf.h"

#define INSTRUCTION_DATA_ADDR 0X01000000

int main()
{
	xil_printf("hello world!\n");
	return 0;
}
