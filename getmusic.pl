# $Id: getmusic.pl,v 0.3 2006/02/22 10:38:00 ddrp Stab $
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
# This script reads from the standard input, every time it sees a
# URL which looks like it is music, it downloads it.  It will only
# see one URL per line, however.
# Requires: wget version 1.9.1 or later.
#

# Extensions for music files.
my @exts = (
  '.mp2',
  '.mp3',
  '.ogg',
  '.wma',
  '.asx',
  '.flac',
  '.wav',
  '.raw',
  '.cdda',
  '.mod',
  '.mid',
  '.it',
  '.au',
  '.aiff'
);

# Function prototypes
sub IsMusic($);
sub Rape($$);
sub RetryRape($);
sub RandomSleep();
#----------------------------------------------------------------------------
# Program entry point
my $line = 0;
while ( <STDIN> ) {
  $line++;
  if ( m/http:\/\// or m/ftp:\/\// ) {
    my $url;

    $url = index($_, 'http://', 0);
    if ( $url == -1 ) {
      $url = index($_, 'ftp://', 0);
    }
    if ( $url == -1 ) {
      print STDERR "Cannot re-locate URL found at line $line\n";
    }
    else {
      # Process URL
      $url = substr($_, $url, length($_));
      my $space = index($url, ' ', 0);
      if ( $space > 0 ) {
        $url = substr($url, 0, $space);
      }
      else {
        chomp $url;
      }
      if ( IsMusic($url) ) {
        print "Attemping to download $url using wget\n";
        if ( !Rape($url, 50) ) {
          print "Giving up download of $url, retries exceeded\n";
          exit 1;
        }
        RandomSleep;
      }
      else {
        print "Ignoring $url because it is not music.\n";
      }
    }
  }
}

exit 0;
#----------------------------------------------------------------------------
sub IsMusic($)
{
  my $url;
  my $urlLen;

  $url = $_[0];

  foreach ( @exts ) { # Check all the extensions
    my $urlExt;
    my $thisExt;

    my $urlLen;
    my $thisLen;

    $thisExt = $_;

    $urlLen = length($url);
    $thisLen = length($thisExt);

    return 0 if ( $urlLen < $thisLen ); # URL shorter than extension
    $urlExt = substr($url, length($url) - $thisLen, $thisLen);
    if ( $urlExt eq $thisExt ) {
      return 1;
    }
  }

  return 0;
}
#----------------------------------------------------------------------------
sub Rape($$)
{
  my $url;
  my $retries;

  $url = $_[0];
  $retries = $_[1];
  $retries++;

  while ( $retries ) {
    return 1 if ( RetryRape($url) );
    $retries--;
    sleep 1;
  }
  return 0;
}
#----------------------------------------------------------------------------
sub RetryRape($)
{
  my $ret = 0;
  my $url = $_[0];

  system "wget -r --retry-connrefused --no-host-directories --user-agent=\"Daybo Logic Commodore 16\" -c --progress=dot:mega --timeout=40 --waitretry=30 --random-wait --limit-rate=16k \"$url\"";
  if ( $? == -1 ) {
    print "Failed to execute: $!\n";
  }
  elsif ( $? & 127 ) {
    printf
      "child died with signal %d, %s coredump\n",
      ($? & 127),
      ($? & 128) ? 'with' : 'without'
    ;
  }
  else {
    my $value = $? >> 8;
    printf "child exited with value %d\n", $value;
    if ( $value == 0 ) {
      $ret = 1;
    }
  }

  return $ret;
}
#----------------------------------------------------------------------------
sub RandomSleep()
{
  my $secs = int(rand(10));
  print "Pausing for $secs seconds to prevent log file analysis.\n";
  sleep $secs;
  return;
}
#----------------------------------------------------------------------------
