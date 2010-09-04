bcc32 -3 -f- -k- -O1 -pr delayfor.c
@Echo off
rem Parameter listings for making of this app.
rem -3 -  80386 instructions
rem -f- - No floating point logic at all
rem -k- - Don't bother with stack frame
rem -O1 - Optimize for smallest possible code
rem -pr - Passing parameters to be done with registers