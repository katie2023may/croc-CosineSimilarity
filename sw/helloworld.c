#include "uart.h"
#include "print.h"
#include "timer.h"
#include "gpio.h"
#include "util.h"


#define COSINE_BASE 0x20001000
volatile int *cosine = (int *) COSINE_BASE;

// cosine[0] == AVEC
// cosine[1] == BVEC
// cosine[2] == START
// cosine[3] == COS
// cosine[4] == DONE


int main(void) {
    uart_init();
    printf("At UART INIT");
    int counter = 0;
    int stop = 0;
    //uint32_t start, end;
    cosine[2] = 0;    
    cosine[0] = 0x04030201;
    cosine[1] = 0x08070605;  // example angle
    cosine[2] = 1;
    cosine[2] = 0;
   // start = get_mcycle(); 
   // end = get_mcycle();
    while (!(cosine[4] & 1)) {
	counter++;
    }
    int result = cosine[3];   // read
    printf("\nCosine Similarity Calculation Result -> %x\n", result);
    uart_write_flush();
    return 1;
}

