@echo off
rem $Id: install.bat,v 0.5 2006/02/13 09:58:00 ddrp Stab $
rem
rem Copyright (C) 2001-2006 Daybo Logic.
rem All rights reserved.
rem
rem Redistribution and use in source and binary forms, with or without
rem modification, are permitted provided that the following conditions
rem are met:
rem 1. Redistributions of source code must retain the above copyright
rem    notice, this list of conditions and the following disclaimer.
rem 2. Redistributions in binary form must reproduce the above copyright
rem    notice, this list of conditions and the following disclaimer in the
rem    documentation and/or other materials provided with the distribution.
rem 3. Neither the name of the project nor the names of its contributors
rem    may be used to endorse or promote products derived from this software
rem    without specific prior written permission.
rem
rem THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS'' AND
rem ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
rem IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
rem ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
rem FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
rem DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
rem OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
rem HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
rem LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
rem OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
rem SUCH DAMAGE.

perl install.pl -w %1 %2 %3 %4 %5 %6 %7 %8 %9

if %errorlevel% == 9009 goto noperl
if %errorlevel% == 255 goto badscript
if %errorlevel% == 2 goto noscript
goto leave

:noperl
echo ERROR: Perl is not installed or is not on your path
goto leave

:badscript
echo ERROR: The script contains errors, cannot continue
goto leave

:noscript
echo ERROR: The script is missing or you are not in the correct directory
goto leave

rem Last line in script follows, label leave
:leave
