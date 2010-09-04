#include <StdIO.h>
#include <Stdlib.h>
#ifdef __WIN32__
#  include <Windows.H>
#else
#  include <DOS.h>
#endif
#pragma hdrstop

#include "DelayFor.h"

/* Simple delay program, takes one para., # ms to pause for, used in batch
programming and the like */


int main(int argc, char* argv[])
{
        unsigned int DelayTimeMs;


        if (argc != 2) /* 1 user parameter only */
        {
                ShowTitle();
                printf("Incorrect No. of parameters\n"); /* print appropriate error message */
                printf("\n");
                ShowSyntax();
                return 1; /* Not done correctly */
        }

        DelayTimeMs = atoi(argv[1]); /* cvt string time into usable integer */
        if (!DelayTimeMs)
        {
                ShowTitle();
                printf("No mate, parameter must be a positive integer\n");
                printf("\n");
                ShowSyntax();
                return 1;
        }
	#ifdef __WIN32__
	Sleep(DelayTimeMs);
	#else
        delay(DelayTimeMs); /* Delay for time user said */
	#endif
        return 0; /* success */
}

void ShowTitle(void)
{
        printf("DelayFor... suspend batchfile statement by Overlord D.D.R.Palmer\n");
        printf("----------------------------------------------------------------\n");
        printf("\n");
}

void ShowSyntax(void)
{
        printf("DelayFor [Milliseconds]\n");
}
