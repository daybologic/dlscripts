# $Id: rcs/mandate.pl,v 0.1 2006/03/17 22:00:00 ddrp Exp $
#
# Copyright (C) 2001-2006 Daybo Logic.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the project nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

# This script is used to remove pre-processor definitions which may
# prevent RCS stamps being embedded in binaries.
# It removes _any_ line containing _RCS_STAMPS.
# Therefore, you should review your use of macros before using this
# script.  A brief run through of all instances with grep should be
# sufficient but please make backups first!
#
# Files are processed in-place from the command line, in-memory.
#
# David Duncan Ross Palmer, Daybo Logic
# <daybologic.co.uk/mailddrp>

my $argi = 0;

while ( $ARGV[$argi] ) {
  my $fn = $ARGV[$argi];
  my @filec; # File contents

  print "Processing \"$fn\"...\n";
  open(CODE, "< $fn") or die $!;
  @filec = <CODE>;
  close CODE;
  open(CODEOUT, "> $fn") or die;

  foreach my $line ( @filec ) {
    if ( $line ) {
      if ( !( $line =~ m/_RCS_STAMPS/ ) ) {
        print CODEOUT $line;
      }
    }
  }
  close CODEOUT;
  $argi++;
}
exit 0;

