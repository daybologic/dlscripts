#!/usr/bin/perl

# Converts all files in current directory from .xcf to .png

$conv = 'convert';

if ( !opendir(HDIR, '.') ) {
  die $!;
}

foreach ( readdir(HDIR) ) {
  my $fn = $_;

  if ( $fn =~ m/.xcf$/ ) {
    if ( length($fn) > 4 ) {
      my $newfn = substr($fn, 0, -4);
      $newfn = $newfn . '.png';
      if ( -e $newfn ) {
        print "$newfn already exists.\n";
      }
      else {
        system("$conv $fn $newfn");
      }
    }
  }
}
closedir HDIR;
exit 0;

