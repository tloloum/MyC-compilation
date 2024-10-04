// Header
#include "PCode.h"
int main() {
pcode_main();
return stack[sp-1].int_value;
}

void pcode_castToFloat() {
// Argument x of function castToFloat in TDS with offset -1
// entering function block
LOADP(bp+-1) // Loading x value in curent block
return;
// Removing variable x at depth 1
// Exiting function block, removing loc var and arg from TDS
}
void pcode_main() {
// entering function block
// loading function castToFloat arguments
LOADI(1)
I2F  // Converting first arg
SAVEBP
CALL(pcode_castToFloat)
RESTOREBP
ENDCALL(1) // unloading 1 args of function castToFloat
return;
// Exiting function block, removing loc var and arg from TDS
}
