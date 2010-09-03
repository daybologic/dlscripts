# $Id: libtool.pl,v 1.1 2006/02/28 11:33:00 ddrp Stab $
#
# Copyright (C) 2003-2006 Daybo Logic.
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

# libtool.pl is a portable version of ar.  ar is the UNIX archive utility.
# Rather than using "ar cru" to build a library, use this Perl program
# in this fashion:
#   perl ../scripts/libtool.pl [platform] [operation] [lib] [files ...]
#
# Supported platforms are:
# bor, gnu
#
# Supported operationd are:
# build, install
#
# This will allow us to use tlib in a loop, tlib only allows one file
# to be added at a time and is a nusiance, so this is why we use this script.
#
# We support both response files and wildcards in order to support
# annoying command line limits.
# Note: Response files may contain wildcards but
# wildcards cannot be response files.  You can not specify a
# response file as @*.list for example.
#
# Written by David Duncan Ross Palmer
# http://www.daybologic.co.uk/mailddrp/

use File::Copy;

my $i;
my $size = @ARGV;
my @files;
my $platform = $ARGV[0];
my $operation = $ARGV[1];

print "Daybo Logic LibTool 1.1 (20060228), (C)2003-2006 David Duncan Ross Palmer\n\n";

if ( !$platform ) {
  Fatal('You must specify the platform');
}

if ( !$operation ) {
  Fatal('You must specify the operation');
}

# Convert the arguments into the filenames
if ( $size >= 2 ) {
  for ( $i = 3; $i < $size; $i++ ) {
    $files[$i - 3] = $ARGV[$i];
  }
  # Resolve '@' response files
  @files = ResolveResp(@files);
  # Resolve all wildcards
  @files = MyGlob(@files)
}

if ( $platform eq 'bor' ) {
  CheckArgs();
  if ( $operation eq 'build' ) {
    BorlandBuild(@files);
  }
  else {
    BorlandInstall(@files);
  }
}
elsif ( $platform eq 'gnu' ) {
  CheckArgs();
  if ( $operation eq 'build' ) {
    GNUBuild(@files);
  }
  else {
    GNUInstall(@files);
  }
}
else {
  Fatal('Unknown platform specified: ' . $platform);
}

exit 0;
#----------------------------------------------------------------------------
sub Fatal
{
  my($msg)=@_;
  if ( $msg ) { print "Error: $msg\n"; }
  else { print "Fatal Error\n" };
  exit 1;
}
#----------------------------------------------------------------------------
sub CheckArgs
{
  if ( $ARGV[1] ) {
    if ( !($ARGV[1] eq 'build') && !($ARGV[1] eq 'install') ) {
      Fatal(
        "Unrecognised operation -  \'$ARGV[1]\'\n" .
        "If you are seeing this error after an upgrade of the Daybo Logic " .
        "supplementary scripts package, you need to fetch a more recent " .
        "version of the library you are trying to build.  The package you " .
        "are trying to build is out of date."
      );
    }
  }
  else {
    Fatal('No operation specified');
  }

  if ( !$ARGV[2] ) {
    if ( $operation eq 'build' ) {
      Fatal('Nothing to add to the library');
    }
    else {
      Fatal('You must specify the location in which to install the library');
    }
  }
}
#----------------------------------------------------------------------------
sub BorlandBuild
{
  my $i;
  my $execStr;
  my (@files)=@_;

  # Erase the old lib
  $execStr = "if exist $ARGV[2] erase $ARGV[2]";
  print("$execStr\n");
  system($execStr);

  # Start calling tlib to make the library
  for ( $i = 0; $i < @files; $i++ ) {
    if ( $files[$i] ne '' ) {
      $execStr = "tlib $ARGV[2] +$files[$i]";
      print("$execStr\n");
      system($execStr);
    }
  }
}
#----------------------------------------------------------------------------
sub BorlandInstall
{
  my $instPath = $_[0]; # We only use the first argument
  my $execStr;

  print "Copying $ARGV[2] to $instPath\n";
  copy($ARGV[2], $instPath) or Fatal("Cannot install to $instPath, $!");
}
#----------------------------------------------------------------------------
sub GNUBuild
{
  my $i;
  my $execStr;
  my (@files)=@_;

  for ( $i = 0; $i < @files; $i++ ) {
    if ( $files[$i] ne '' ) {
      $execStr = "ar cru $ARGV[2] " . $files[$i];
      print("$execStr\n");
     system($execStr);
    }
  }
  $execStr = "ranlib $ARGV[2]";
  print("$execStr\n");
  system($execStr);
}
#----------------------------------------------------------------------------
sub GNUInstall
{
  my $instPath = $_[0]; # We only use the first argument
  my $execStr;

  print "Copying $ARGV[2] to $instPath\n";
  copy($ARGV[2], $instPath) or Fatal("Cannot install to $instPath, $!");

  $execStr = "ranlib $instPath$ARGV[2]";
  print "$execStr\n";
  system($execStr);

  print "Setting permissions, -r--r--r-- on $instPath$ARGV[2]\n";
  chmod 0444, $instPath . $ARGV[2] or Fatal("Cannot set permissions, $!");
}
#----------------------------------------------------------------------------
sub MyGlob
{
  my (@unglobbed) = @_;
  my @globbed;
  my $si;
  my $di = 0;
  my $size_unglobbed = @unglobbed;

  for ( $si = 0; $si < $size_unglobbed; $si++ ) {
    $_ = $unglobbed[$si];
    if ( (m/\*/) or (m/\?/) ) { # Contains wildcards
      my @thisGlob = glob($unglobbed[$si]);
      foreach ( @thisGlob ) {
        $globbed[$di++] = $_;
      }
    }
    else {
      $globbed[$di++] = $_;
    }
  }
  return @globbed;
}
#----------------------------------------------------------------------------
sub ResolveResp
{
  my (@compactedFiles) = @_;
  my @expandedFiles;
  my $size = @compactedFiles;
  my $si;
  my $di = 0;

  for ( $si = 0; $si < $size; $si++ ) {
    if ( $compactedFiles[$si] =~ m/^\@/ ) {           # Response file?
      $_ = $compactedFiles[$si];
      s/^\@//; # Get rid of leading @
      open(RESPFILE, "< $_") or die "Cannot open responsefile for library content list, $_: $!";
      while ( <RESPFILE> ) {
        my $line = $_;

        chomp $line;
        $expandedFiles[$di++] = $line;
      }
      close RESPFILE;
    }
    else {                               # Normal file
      $expandedFiles[$di++] = $compactedFiles[$si];
    }
  }
  return @expandedFiles;
}
#----------------------------------------------------------------------------
