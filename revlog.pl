# $Id: revlog.pl,v 0.1 2006/02/26 21:20:00 ddrp Exp $
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

# This script is used to change the order of releases in a changelog
# paragraphs orders are reversed.
# David Duncan Ross Palmer, Daybo Logic
# <daybologic.co.uk/mailddrp>

if ( $ARGV[0] ) {
  my @allfile;
  my @para;

  open(HANDL, "< $ARGV[0]");
  while ( <HANDL> ) {
    my $line;

    $line = $_;
    push @allfile, $line;
  }
  close(HANDL);

  # File is loaded.  Now we'll go through and split up the paragraphs
  @allfile = reverse @allfile; # Reverse entire file
  foreach ( @allfile ) {
    my $line = $_;

    if ( !($line =~ m/^\ *\n$/) ) {
      push @para, $line;
    }
    else { # Paragraph boundry
      @para = reverse @para;
      push @para, "\n";

      foreach ( @para ) {
        print;
      }
      # Clear paragraph
      while ( scalar(@para) ) {
        pop @para;
      }
    }
  }
}
else {
  print "ERROR: Need to specify filename\n";
}

exit 0;
