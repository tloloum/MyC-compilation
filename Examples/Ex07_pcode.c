// Header
#include "PCode.h"
int main() {
pcode_main();
return stack[sp-1].int_value;
}

// Declare x of type float with offset 0 at depth 0
LOADF(0.0)

// Declare y of type int with offset 1 at depth 0
LOADI(0)

void pcode_main() {
// Debut conditionelle 0
LOADP(0) // Loading x value
LOADF(0.000000)
GTF
IFN(False_0)
// la condition 0 est vraie
LOADI(1)
STOREP(1) // storing y value 
GOTO(End_0)
False_0:
// la condition 0 est fausse
LOADI(0)
STOREP(1) // storing y value 
End_0:
// Fin conditionelle 0
LOADP(1) // Loading y value
return;
}
