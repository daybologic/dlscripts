#!/usr/bin/perl -w
# $Id: maker.pl,v 0.6 2004/06/18 17:25:00 ddrp Exp $
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

# This program calls the relevant make program.
# It works on Borland and GNU.  Sometimes GNU's make is just called
# make, so we will try gmake and then make on GNU's platform.
# On FreeBSD, make is the BSD make, which is not compatible with
# these makefiles.  Therefore, if you get a lot of makefile complaints
# and nothing will build and you are using FreeBSD, you need to install
# the gmake port.
#
# Usage: perl maker.pl [platform] [options] ':' [arguments to make]
#
# Valid platforms:
#   bor - Borland C++ make
#   gnu - GNU make
#
# Written by David Duncan Ross Palmer
# <daybologic.co.uk/mailddrp>

#sub Version();
#sub Error($errno);

my $platform;    # Platform identifier

Version();

# Process options
if ( $ARGV[0] ) {
  if ( $ARGV[0] eq 'gnu' || $ARGV[0] eq 'bor' ) {
    $platform = $ARGV[0];
  }
  else {
    Error(1);
    die;
  }
}
else {
  Error(2);
  die;
}

if ( $platform eq 'bor' ) {
  my @arglist = @ARGV;

  shift @arglist;

  if ( exec("make @arglist") == -1 ) {
    Error(3);
    die;
  } 
}
elsif ( $platform eq 'gnu' ) {
  my @arglist = @ARGV;

  shift @arglist;

  if ( system("gmake @arglist") == -1 ) {
    if ( system("make @arglist") == -1 ) {
      Error(4);
      die;
    }
  }
}

sub Version
{
  print "Daybo Logic DayboCrypt Maker - Version 0.4 (20040617)\n";
}

sub Error
{
  my $errno = $_[0];
  print "Error! ($errno): ";

  my @errors = (
    "No error (success)",
    "Unknown platform",
    "No platform specified",
    "Cannot seem to execute make!",
    "gmake or make not found"
  );

  print $errors[$errno] . "\n";
}
