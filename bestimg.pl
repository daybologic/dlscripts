#!/usr/bin/perl
#
# Script to convert a given image into several trial images.
# The script will try gif, png, and jpg.
# It will choose to keep the image which is smallest and will discard
# the rest.  You should ensure that the image looks reasonable because
# we cannot "see" the image.  We are hardly that advanced!
#
# Written by David Duncan Ross Palmer, Daybo Logic
# (c) 2006, Daybo Logic.
# http://www.daybologic.co.uk/mailddrp/
#

my $convertapp = 'convert '; # Leave a space after app name.
my $original;
my $count;

my @exts = (
  'gif',
  'png',
  'jpg',
);

sub Error($);
sub Warning($);
sub BestImg($);
sub TrimAnyExt($);
sub PrintUnlink;

#----------------------------------------------------------------------

# Program entry point

$count = 0;
foreach $original ( @ARGV ) {
  if ( !BestImg($original) ) {
    $count++;
  }
}

if ( $count > 0 ) {
  print "$count file(s) converted.\n";
}
else {
  Error 'No file(s) successfully converted or specified.';
  exit 1;
}
exit 0;

sub Error($)
{
  my $msg = $_[0];

  if ( $msg ) {
    printf "Error: %s\n", $msg;
  }
  else {
    print "Error() called with no error message\n";
  }
  return;
}

sub Warning($)
{
  my $msg = $_[0];

  if ( $msg ) {
    printf "Error: %s\n", $msg;
  }
  else {
    print "Warning() called with no message\n";
  }
  return;
}

sub BestImg($)
{
  my $original = $_[0];
  my @newFiles; #Filenames of generated files
  my @newLens; #Length of generated files
  my $i;
  my $shortest = 0;
  my $shortestIdx;

  if ( !( -e $original ) ) {
    Error "$original does not exist.";
    return 1;
  }

  foreach my $ext ( @exts ) {
    my @fileStats;
    my $copyorig = TrimAnyExt($original);
    $copyorig = $copyorig . '.' . $ext;
    print "Converting $original to $copyorig\n";

    if ( !( -e $copyorig ) ) {
      system $convertapp . $original . ' ' . $copyorig;
    }
    else {
      Warning "Skipping $copyorig because it already exists"
    }

    push @newFiles, $copyorig;
    @fileStats = stat($copyorig);
    push @newLens, $fileStats[7];
  }

  $i = 0;
  foreach my $currLen ( @newLens ) {
    if ( ($currLen < $shortest) or ($i == 0) ) {
      $shortest = $currLen;
      $shortestIdx = $i;
    }
    $i++;
  }

  print "Shortest file is $newFiles[$shortestIdx] which " .
    "is $newLens[$shortestIdx] bytes long\n";

  # Now delete the other files
  PrintUnlink $original;
  $i = 0;
  foreach ( @newFiles ) {
    if ( $i != $shortestIdx ) {
      PrintUnlink $_;
    }
    $i++;
  }
}

sub TrimAnyExt($)
{
  my $fn = $_[0];
  my $i = rindex($fn, '.');
  if ( $i > -1 ) {
    $fn = substr($fn, 0, $i);
  }
  return $fn;
}

sub PrintUnlink
{
  foreach ( @_ ) {
    print "Deleting $_\n";
    unlink;
  }
}

