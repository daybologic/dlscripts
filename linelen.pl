# $Id: linelen.pl,v 0.2 2005/09/21 22:31:00 ddrp Stab $
#
# Copyright (C) 2001-2005 Daybo Logic.
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

# This script can be used to confirm that a file is within line printer limits,
# the limit is hard coded at column 78, anything over this will give a warning.
# This is very useful for readable source code
# David Duncan Ross Palmer, Daybo Logic
# <daybologic.co.uk/mailddrp>

my $warnings = 0;

if ( $ARGV[0] ) {
  my $line = 1;

  open(HANDL, "< $ARGV[0]");
  while ( <HANDL> ) {
    my $len;

    chomp($_);
    $len = length($_);
    if ( $len > 78 ) {
      printf "$ARGV[0]:$line: Warning! line is $len characters long\n";
      $warnings++;
    }
    $line++;
  }
  close(HANDL);
}
else {
  print "ERROR: Need to specify filename\n";
}

# exit 1 if $warnings;
# Uncomment above if you want your compilation to bail out.
