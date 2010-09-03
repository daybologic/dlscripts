#
# $Id: install.pl,v 0.2 2006/02/15 20:30:00 ddrp Stab $
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
#
#----------------------------------------------------------------------------
use strict;
use File::Copy;
#----------------------------------------------------------------------------
# Globals
my $ret; # Return value for caller (OS or script)
my $win32 = 0;
my $unix = 0;
#----------------------------------------------------------------------------
# Prototypes for functions
sub main;
sub Title;
sub Help;
sub Error($);
sub AskDir($);
sub CondAppendSeppo($);
sub DoInstall($);
sub MakeInstallDir($);
sub GetSeppo();
#----------------------------------------------------------------------------
# Entrypoint
$ret = main;
exit $ret;
#----------------------------------------------------------------------------
# Code
sub main
{
  my $interactive;
  my $help;
  my $dir = undef;

  foreach ( @ARGV ) {
    $unix = 1 if ( $_ eq '-u' );
    $win32 = 1 if ( $_ eq '-w' );
    $interactive = 1 if ( $_ eq '-i' );
    $help = 1 if ( $_ eq '-h' );
    $help = 1 if ( $_ eq '--help' );
  }
  Title;
  if ( $help ) {
    Help;
  }
  else {
    if ( !$win32 && !$unix ) {
      Error 'Must specify either -u or -w';
      Help;
      return 1;
    }
    $dir = AskDir($interactive);
    if ( $dir && $dir ne '' ) {
      print "Using directory \'$dir\'\n";
      if ( !DoInstall($dir) ) {
        Error 'The installation did not complete successfully';
        return 1;
      }
    }
    else {
      Error 'Directory has not been defined.';
      return 1;
    }
  }
  return 0;
}
#----------------------------------------------------------------------------
sub Title
{
  print "Installation script for dlscripts package (c)2006 Daybo logic,\n";
  print "Supplied under a BSD compatible license, see source for details.\n";
  print "\n";
  return;
}
#----------------------------------------------------------------------------
sub Help
{
  print "Syntax: install.pl [-i] [-u] [-w]\n";
  print "\n";
  print "-i: Interative, ask questions.\n";
  print "-u: UNIX-type host\n";
  print "-w: Win32-type host\n";
  print "-h or --help: This information\n";
  print "\n";
  print "Either -u or -w must be supplied.  Interactive mode is optional\n";
  print "in either case.\n";
  return;
}
#----------------------------------------------------------------------------
sub Error($)
{
  my $msg = $_[0];
  print "ERROR: $msg\n";
  return;
}
#----------------------------------------------------------------------------
sub AskDir($)
{
  my $dir = undef;
  my $interactive = $_[0];

  if ( !$win32 ) { # UNIX?
    $dir = "/usr/local/share/daybo_logic/scripts/";
    $dir = CondAppendSeppo($dir);
  }
  else {
    my $base = $ENV{'CommonProgramFiles'};
    if ( !$base || $base eq '' ) {
      Error 'Please set the environment variable CommonProgramFiles';
      return $dir;
    }
    $dir = $base;
    $dir = CondAppendSeppo($dir);
    $dir = $dir . 'Daybo Logic\\scripts';
    $dir = CondAppendSeppo($dir);
  }

  if ( $interactive ) {
    print "Specify the directory which will hold the scripts, if you just\n";
    print "want to accept the default, press enter and the default will\n";
    print "be used.\n\n";
    print "Script directory [$dir]: ";
    my $ask = <STDIN>;
    chomp $ask;
    if ( $ask ) {
      if ( $ask ne '' ) {
        $dir = $ask;
        $dir = CondAppendSeppo($dir);
      }
    }
  }
  return $dir;
}
#----------------------------------------------------------------------------
sub CondAppendSeppo($)
{
  my $dir = $_[0];
  my $seppo;

  $seppo = GetSeppo();

  if ( $dir ) {
    if ( rindex( $dir, $seppo ) != (length $dir)-1 ) {
      $dir = $dir . $seppo;
    }
  }

  return $dir;
}
#----------------------------------------------------------------------------
sub DoInstall($)
{
  my $tdir = $_[0];
  my $sdir;
  my $fileMode = 0755; # Only for UNIX
  my @scripts; # Initial list of scripts in source directory

  if ( !MakeInstallDir($tdir) ) {
    Error 'Cannot create directories';
    return 0;
  }

  print "Copying files...\n";
  $sdir = CondAppendSeppo('.');
  if ( opendir(SDIR, $sdir) ) {
    my $thisFile;

    do {
      $thisFile = readdir(SDIR);
      if ( $thisFile ) {
        if ( $thisFile =~ m/.pl$/ ) {
          push(@scripts, $thisFile);
        }
        if ( $thisFile =~ m/.sh$/ ) {
          push(@scripts, $thisFile);
        }
        if ( $thisFile =~ m/.bat$/ ) {
          push(@scripts, $thisFile);
        }
        if ( $thisFile =~ m/.cmd$/ ) {
          push(@scripts, $thisFile);
        }
      }
    } while ( $thisFile );
    closedir(SDIR);
  }
  else {
    Error 'Cannot open current directory';
    return 0;
  }

  # OK, now we have the scripts in @scripts,
  # let's iterate and copy, leaving out and install related scripts.

  foreach ( @scripts ) {
    if ( !(m/^install./) ) {
      my $notinstalled;
      my $installed;

      $notinstalled = $sdir . $_;
      $installed = $tdir . $_;
      print "Copying $notinstalled to $installed\n";
      if ( !(copy $notinstalled, $installed) ) {
        Error "Error during copy: $!\n";
        return 0;
      }
      if ( !$win32 ) {
        if ( !(chmod $fileMode, $installed) ) {
          Error("Cannot set permissions: $!\n");
          return 0;
        }
      }
    }
  }
  return 1;
}
#----------------------------------------------------------------------------
sub MakeInstallDir($)
{
  # This is a multi-stage process because we can't create more than
  # one sub-directory at a time.  So we must call mkdir for each
  # piece of the puzzle which doesn't exist.

  my $fulldir = $_[0]; # Entire name of full dir to create
  my $mode = 0755;     # Mode for any _new_ subdirectories
  my @parts;
  my $fromroot = 0;
  my $current = '';

  $fulldir = CondAppendSeppo($fulldir); # Ensure dir ends with '/'
  $fromroot = 1 if ( substr($fulldir, 0, 1) eq GetSeppo() );
  $_ = $fulldir;
  if ( $win32 ) {
    @parts = split(m$\\$, $fulldir);
  }
  else {
    @parts = split(m:/:, $fulldir);
  }

  $current = GetSeppo() if ( $fromroot );
  foreach ( @parts ) {
    $current = $current . $_;
    $current = CondAppendSeppo($current);
    if ( !(-e $current) ) {
      if ( !mkdir($current, $mode) ) {
        Error("Cannot create directory - \"$current\"");
        return 0;
      }
    }
  }

  return 1;
}
#----------------------------------------------------------------------------
sub GetSeppo()
{
  my $seppo;

  if ( $win32 ) {
    $seppo = '\\';
  }
  else {
    $seppo = '/';
  }
  return $seppo;
}
#----------------------------------------------------------------------------
