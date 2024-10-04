// Header
#include "PCode.h"
int main() {
pcode_main();
return stack[sp-1].int_value;
}

void pcode_plus() {
// Argument y of function plus in TDS with offset -1
// Argument x of function plus in TDS with offset -2
// entering function block
LOADP(bp+-2) // Loading x value in curent block
LOADP(bp+-1) // Loading y value in curent block
ADDI
return;
// Removing variable x at depth 1
// Removing variable y at depth 1
// Exiting function block, removing loc var and arg from TDS
}
void pcode_main() {
// entering function block
// loading function plus arguments
LOADI(5)
LOADI(6)
SAVEBP
CALL(pcode_plus)
RESTOREBP
ENDCALL(2) // unloading 2 args of function plus
return;
// Exiting function block, removing loc var and arg from TDS
}
