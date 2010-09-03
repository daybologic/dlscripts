# $Id: borlandify.pl,v 0.1.2 2006/02/28 11:28:00 ddrp Exp
#
# Daybo Logic Run-Time TarBall Library And Tools
# Copyright (c) 2000-2006, David Duncan Ross Palmer, Daybo Logic
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#      
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#      
#   * Neither the name of the Daybo Logic nor the names of its contributors
#     may be used to endorse or promote products derived from this software
#     without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

my $config_old = 'config.h';
my $config_new = 'config.bor'; # Will be renamed afterwards

sub Error($);
sub FatalError($);
sub Parse();
sub DoSubs($);

print "Borlandify v0.1.2\n";
print "(c)Copyright 2006 Daybo Logic, BSD license.\n\n";

print "This is the Borlandify script.  We will parse the project's\n";
print "$config_old file and look for anything we can change to make it\n";
print "compatible with Borland C++\n\n";

if ( -e $config_old ) {
  if ( -d $config_old ) {
    FatalError("\"$config_old\" is a directory.  Cannot open\n");
  }
  if ( Parse() ) {
    print "Parsing completed.\n";
    unlink $config_old;
    rename $config_new, $config_old;
  }
}
else {
  FatalError(
    "\"$config_old\" cannot be found.  You need to run configure\n" .
    "first!"
  );
}

exit 0;

sub Error($)
{
  my $msg = $_[0];

  print "Error: $msg\n";
  return;
}

sub FatalError($)
{
  my $msg = $_[0];

  Error($msg);
  print "Fatal error(s) encountered.  Bailing out.\n";
  exit 1;
}

sub Parse()
{
  my $ret = 0; # Fail by default
  if ( open(CONFIGIN, "< $config_old") ) {
    my $line = '';
    if ( !open(CONFIGOUT, "> $config_new") ) {
      close(CONFIGIN);
      FatalError "Cannot write outfile file - \"$config_new\"";
    }
    do {
      $line = <CONFIGIN>;
      if ( $line ) {
        $line = DoSubs($line);
        print CONFIGOUT $line;
      }
    } while ( $line );
    close(CONFIGOUT);
    close(CONFIGIN);

    if ( -e $config_new ) {
      $ret = 1; # Caller will replace file
    }
  }
  return $ret;
}

sub DoSubs($)
{
  # Originals must match the beginning of the line

  my @originals = (
    '#define HAVE_STDBOOL_H',
    '#define HAVE_DLFCN_H',
    '#define HAVE_INTTYPES_H',
    '#define HAVE_STDINT_H',
    '#define HAVE_STRINGS_H',
    '#define HAVE_UNISTD_H',
    '#define RETSIGTYPE int',
    '#define __B_ENDIAN__',
    '#define __UNIX__',
    '/* #undef inline */'
  );

  my @replacements = (
    '/* #define HAVE_STDBOOL_H */',
    '/* #define HAVE_DLFCN_H */',
    '/* #define HAVE_INTTYPES_H */',
    '/* #define HAVE_STDINT_H */',
    '/* #define HAVE_STRINGS_H */',
    '/* #define HAVE_UNISTD_H */',
    '#define RETSIGTYPE void',
    '#define __L_ENDIAN__',
    "#ifndef __WIN32__\n# define __WIN32__\n#endif /*!__WIN32__*/\n",
    '#define inline'
  );

  my @messages = (
    'Removed HAVE_STDBOOL_H',
    'Removed HAVE_DLFCN_H',
    'Removed HAVE_INTTYPES_H',
    'Removed HAVE_STDINT_H',
    'Removed HAVE_STRINGS_H',
    'Removed HAVE_UNISTD_H',
    'Replaced RETSIGTYPE int with void',
    'Replaced __B_ENDIAN__ with __L_ENDIAN__',
    'Replaced __UNIX__ with __WIN32__',
    'Defining macro \'inline\' to nothing'
  );

  my $line = $_[0];
  my $i = 0;
  my $modified = 0;

  foreach ( @originals ) {
    if (
      ( $line eq "$originals[$i]\n" ) or
      ( $line eq $originals[$i] ) or
      ( $line =~ m/^$originals[$i]/ )
    ) {
      $line = $replacements[$i];
      print "NB. $messages[$i]\n";
      $modified = 1;
      last;
    }
    $i++;
  }

  if ( $modified ) {
    $line = "/* The following line has been modified by Borlandify */\n" .
      $line . "\n";
  }

  return $line;
}
