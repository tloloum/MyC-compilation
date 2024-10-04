// Header
#include "PCode.h"
int main() {
pcode_main();
return stack[sp-1].int_value;
}

// Declare x of type float with offset 0 at depth 0
LOADF(0.0)

// Declare y of type float with offset 1 at depth 0
LOADF(0.0)

// Declare z of type int with offset 2 at depth 0
LOADI(0)

void pcode_main() {
// Debut conditionelle 0
LOADP(0) // Loading x value
LOADF(0.000000)
GTF
IFN(False_0)
// la condition 0 est vraie
SAVEBP // entering block
// Debut conditionelle 1
LOADP(1) // Loading y value
LOADF(0.000000)
GTF
IFN(False_1)
// la condition 1 est vraie
LOADI(1)
STOREP(2) // storing z value 
GOTO(End_1)
False_1:
// la condition 1 est fausse
LOADI(2)
STOREP(2) // storing z value 
End_1:
// Fin conditionelle 1
RESTOREBP // exiting block
GOTO(End_0)
False_0:
// la condition 0 est fausse
SAVEBP // entering block
// Debut conditionelle 2
LOADP(1) // Loading y value
LOADF(0.000000)
GTF
IFN(False_2)
// la condition 2 est vraie
LOADI(3)
STOREP(2) // storing z value 
GOTO(End_2)
False_2:
// la condition 2 est fausse
LOADI(4)
STOREP(2) // storing z value 
End_2:
// Fin conditionelle 2
RESTOREBP // exiting block
End_0:
// Fin conditionelle 0
LOADP(2) // Loading z value
return;
}
