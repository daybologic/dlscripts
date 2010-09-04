bcc -1- -f- -k- -mt -O1 -pr -tDc delayfor.c
@Echo off
rem Parameter listings for making of this app.
rem -1- - 8086 instructions
rem -f- - No floating point logic at all
rem -k- - Don't bother with stack frame
rem -mt - Tiny memory model
rem -O1 - Optimize for smallest possible code
rem -pr - Passing parameters to be done with registers
rem -tDc - Make CP/M .COM program (1 segment for all segments)
           (image with no header).
