#!/usr/bin/perl
#
# Script to convert all mp3 files in a directory to raw files and then
# burn them with the FreeBSD burncd utility.
#
# Written by David Duncan Ross Palmer, Daybo Logic
# (c) 2006, Daybo Logic.
# http://www.daybologic.co.uk/mailddrp/
#

my $conv = 'mpg321 --stdout';
my @burnList;
my $burnCount = 0;

if ( !opendir(HDIR, '.') ) {
  die $!;
}

foreach ( readdir(HDIR) ) {
  my $fn = $_;

  if ( $fn =~ m/.mp3$/ ) {
    if ( length($fn) > 4 ) {
      my $newfn = substr($fn, 0, -4);
      $newfn = $newfn . '.raw';
      if ( -e $newfn ) {
        print "$newfn already exists.\n";
      }
      else {
        system("$conv $fn > $newfn");
      }
      $burnList[$burnCount] = $newfn;
      $burnCount++;
    }
  }
}
closedir HDIR;

if ( $burnCount ) {
  my $burnFileNames = '';
  foreach ( @burnList ) {
    $burnFileNames .= $_ . ' ';
  }
  system 'sudo burncd -f /dev/acd0 audio ' . $burnFileNames . 'fixate';
}
else {
  print "Nothing to burn\n";
}

exit 0;
