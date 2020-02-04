#include "random.h"

#include <stdlib.h>

void srandom(unsigned short seed) {
	srand(seed);
}

unsigned long random() {
	return rand();
}