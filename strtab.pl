# $Id: strtab.pl,v 0.7 2004/07/15 11:45:00 ddrp Stab $
#
# Copyright (C) 2004 Daybo Logic.
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

# This program is used to generate Win32 resource-compiler compatibile
# string tables with C compiler headers from lists of strings.
# -h or --help for usage.
#
# Written by David Duncan Ross Palmer
# <daybologic.co.uk/mailddrp>

my $argsOK = 1;
my $verbose = 0;
my $unicode = 0;
my @filenames;
my $i = 0;

my $symNext = 0;
my $symbol = 'IDS_STR_';

my $numBaseNext = 0;
my $numBase = 1001;

my $symBaseNext = 0;
my $symBase = 0;

my $ceilNext;
my $ceiling = 0;

# Statistics section (printed only if in verbose mode)
my $chars_in = 0;
my $chars_out = 0;
my $lines_in = 0;
my $lines_out = 0;

# Process options
foreach ( @ARGV ) {
  if ( $symNext ) { # Expecting symbol
    $symNext = 0; # Back to normal mode
    $symbol = $_;
  }
  elsif ( $numBaseNext ) { # Expecting -b base
    $numBaseNext = 0;
    $numBase = $_;
  }
  elsif ( $symBaseNext ) { # Expecting -m base
    $symBaseNext = 0;
    $symBase = $_;
  }
  elsif ( $ceilNext ) { # Expecting ceiling
    $ceilNext = 0;
    $ceiling = $_;
  }
  elsif ( ($argsOK) && ($_ =~ m/^\-/) ) { # This is an argument
    if ( $_ eq '--' ) { # No further arguments allowed
      $argsOK = 0;
    }
    elsif ( ($_ eq '-h') || ($_ eq '--help') ) {
      Help();
      exit 0;
    }
    elsif ( ($_ eq '-v') || ($_ eq '--verbose') ) {
      $verbose = 1;
    }
    elsif ( ($_ eq '-V') || ($_ eq '--version') ) {
      Version();
      exit 0;
    }
    elsif ( ($_ eq '-u') || ($_ eq '--unicode') ) {
      $unicode = 1;
    }
    elsif ( $_ eq '-s') {
      $symNext = 1;
    }
    elsif ( $_ eq '-b') {
      $numBaseNext = 1;
    }
    elsif ( $_ eq '-m' ) {
      $symBaseNext = 1;
    }
    elsif ( $_ eq '-c') {
      $ceilNext = 1;
    }
    else {
      print "WARNING: Unknown option: $_\n";
    }
  }
  else { # Must be a filename
    $filenames[$i++] = $_;
  }
}

# Check for some command line errors
if ( scalar(@filenames) > 3 ) {
  print "ERROR: Too many filenames - \"$filenames[3]\"\n";
  exit 1;
}
elsif ( scalar(@filenames) < 3 ) {
  print "ERROR: Not enough filenames specified, use -h for usage.\n";
  exit 1;
}

main();

sub Version
{
  print "Daybo Logic String Table Creation Script - Version 0.7 (20040715)\n";
  print "Copyright (c) 2004 Daybo Logic, all rights reserved.  See license\n";
  print "\n";
}

sub Help
{
  Version();
  print "strtab [options] <strings file input> <rc file output> <header file output>\n";
  print "-h or --help: This information\n";
  print "-v or --verbose: Display statistics after re-formatting\n";
  print "-V or --version: List version (above)\n";
  print "-u or --unicode: Output will be written in non-human readable Unicode\n";
  print "-s [symbol]: Used to set a symbol prefix, default is IDS_STR_\n";
  print "-b [nnn]: Used to set the numeric base for string IDs (default is 1001)\n";
  print "-m [nnn]: Used to set the symbolic (mnemonic) base (default is 0)\n";
  print "-c [nnn]: Used to set a ceiling on the string ID\n";
  print "\nVisit http://www.daybologic.co.uk/\n";
}

sub main
{
  my $lineNumber = 0;
  my $prnBuf;
  
  Version() if ( $verbose );
  open(TXT, "< $filenames[0]") || die;
  open(RC, "> $filenames[1]") || die;
  open(RH, "> $filenames[2]") || die;
  
  binmode(TXT, ':utf8'); # You need Perl 5.8 for this, certainly 5.6 doesn't support it
  
  $prnBuf = "#include \"$filenames[2]\"\n\n";
  printf RC $prnBuf;
  $chars_out += length $prnBuf;
  $lines_out = $lines_out + 2;
  
  $prnBuf = "STRINGTABLE DISCARDABLE {\n";
  printf RC $prnBuf;
  $chars_out += length $prnBuf;
  $lines_out++;
  
  while ( <TXT> ) {
    last if $_ eq '';
    $chars_in += length;
    chomp;

    if ( $ceiling ) {    
      if ( ($numBase+$lineNumber) > $ceiling ) {
        print "ERROR: String $lineNumber (" . (1+$lineNumber) . EnglishOrder(1+$lineNumber) . " string): Ceiling ($ceiling) exceeded.\n";
        print "Reduce the size of the string table, lower the base or raise the ceiling.\n";
        exit 1;
      }
    }
    
    s/\'/\\\'/g; # C-ify apostrophes
    s/\"/\\"\"/g; # C-ify quotations
    
    if ( $_ ) {
      $prnBuf = '#define ' . $symbol . ($symBase+$lineNumber) . ' (' . ($numBase+$lineNumber) . ")\n"; 
      print RH $prnBuf;
      $chars_out += length $prnBuf;
      $lines_out++;
      
      if ( $unicode ) {
        my $c;          # Character
        
        my @arrStr = split(//);
        $prnBuf = '  ' . $symbol . ($symBase+$lineNumber) . " L\"";
        foreach $c ( @arrStr ) {
          my $ordinal = ord($c);
          if ( $ordinal > 127 ) {
            my $prnHex = PalmerHex($ordinal);
            if ( $prnHex ) {
              $prnBuf = $prnBuf . '\\x' . $prnHex;
            }
          }
          else {
            $prnBuf = $prnBuf . $c;
          }
        }
        $prnBuf = $prnBuf . "\",\n"; # End the table
      }
      else {
        $prnBuf = '  ' . $symbol . ($symBase+$lineNumber) . " \"" . $_ . "\",\n";
      }
      
      print RC $prnBuf;
      $chars_out += length $prnBuf;
      $lines_out++;
    }
    $lineNumber++;
  }

  printf RC "}\n";
  $lines_out++;
  $lines_in = $lineNumber;
  
  Stats() if $verbose;
  close(TXT);
  close(RH);
  close(RC);
}

sub EnglishOrder
{
  my $n = $_[0];
  my $th = 'th';
  my $st = 'st';
  my $rd = 'rd';
  my $nd = 'nd';
  
  return $th if ( $n >= 4 and $n <= 20 );
  $n = $n % 10;
  return $st if ( $n == 1 );
  return $nd if ( $n == 2 );
  return $rd if ( $n == 3 );
  return $th; 
}

sub Stats
{
  print "Input: $lines_in lines ($chars_in characters)\n";
  print "Output: $lines_out lines ($chars_out characters)\n";
}

sub PalmerHex
{
  my $dene = $_[0];
  my $hexe = sprintf("%x", $dene); 
  return '' if ( $hexe eq 'feff' ); # Remove Microsoft magic
  return $hexe;
}
