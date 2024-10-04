// Header
#include "PCode.h"
int main() {
pcode_main();
return stack[sp-1].int_value;
}

void pcode_fact() {
// Argument x of function fact in TDS with offset -1
// entering function block
// Debut conditionelle 0
LOADP(bp+-1) // Loading x value in curent block
LOADI(1)
LTI
IFN(False_0)
// la condition 0 est vraie
LOADI(1)
return;
GOTO(End_0)
False_0:
// la condition 0 est fausse
LOADP(bp+-1) // Loading x value in curent block
// loading function fact arguments
LOADP(bp+-1) // Loading x value in curent block
LOADI(1)
SUBI
SAVEBP
CALL(pcode_fact)
RESTOREBP
ENDCALL(1) // unloading 1 args of function fact
MULTI
return;
End_0:
// Fin conditionelle 0
// Removing variable x at depth 1
// Exiting function block, removing loc var and arg from TDS
}
void pcode_main() {
// entering function block
// loading function fact arguments
LOADI(5)
SAVEBP
CALL(pcode_fact)
RESTOREBP
ENDCALL(1) // unloading 1 args of function fact
return;
// Exiting function block, removing loc var and arg from TDS
}
