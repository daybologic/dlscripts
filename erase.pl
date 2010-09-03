# $Id: erase.pl,v 0.6 2004/06/18 16:35:00 ddrp Stab $
#
# Copyright (C) 2001-2004 Daybo Logic.
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

# This is probally the most simple program in the world,
# all I need to do is delete all filenames passed in the command line.
# The reason this exists at all it, although rm -f suffices under UNIX,
# under some versions of Windows, erase/del will only take one argument.
# I'm not sure this is the case under NT 5 anymore but to keep things
# compatible we should use this.  There are other problems under Windows
# like command line lengths, these are dealt with in similar ways with
# other Perl scripts.  Originally this program was written in C,
# but relying on a program which might already have been cleaned back to
# source is annoying.  All of the tool used for the primary boot process
# will eventually be converted to Perl.
#
# Written by David Duncan Ross Palmer
# <daybologic.co.uk/mailddrp>

my $argsOK = 1;
my $verbose = 0;
my @filenames;
my $i = 0;

# Process options
foreach ( @ARGV ) {
  if ( ($argsOK) && ($_ =~ m/^\-/) ) { # This is an argument
    if ( $_ eq '--' ) { # No further arguments allowed
      $argsOK = 0;
    }
    elsif ( ($_ eq '-h') || ($_ eq '--help') ) {
      Help();
    }
    elsif ( ($_ eq '-v') || ($_ eq '--verbose') ) {
      $verbose = 1;
    }
    elsif ( ($_ eq '-V') || ($_ eq '--version') ) {
      Version();
    }
    else {
      print "WARNING: Unknown option: $_\n";
    }
  }
  else { # Must be a filename
    $filenames[$i++] = $_;
  }
}

foreach (@filenames) {
  my @expfns = glob($_);
  foreach ( @expfns ) {
    print "Deleting " . $_ . "..." if ($verbose);
    unlink($_);
    print "Deleted\n" if ($verbose);
  }
}

sub Version
{
  print "Daybo Logic Erase - Version 0.5 (20040116)\n\n";
}

sub Help
{
  Version();
  print "-h or --help: This information\n";
  print "-v or --verbose: List files deleted\n";
  print "-V or --version: List version (above)\n";
  print "\nVisit http://www.daybologic.co.uk/\n";
}
