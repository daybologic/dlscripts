#
# This program iterates through a directory tree and converts
# bz2 files to lzma format.  It uses /tmp for temporary storage,
# so be sure to have a lot of space in there.  Only enough for
# one decompressed file at a time will suffice.  If you need to
# use a different directory for temporary storage, please change
# $tmpdir.
#

my $tmpdir = '/tmp';
my $tmpfna;
my $tmpfnb;

sub GetExt($);
sub Program($);
sub MakeTemps();
sub CmdExecute($);
sub DebugCmdExecute($$$);

# Program entry point
Program('.');
exit 0;

sub Program($)
{
  my $filename;
  my $dirname = $_[0];
  local *dirHandle;
  if ( opendir(dirHandle, $dirname) ) {
    while ( $filename = readdir(dirHandle) ) {
      if ( ($filename eq '.') or ($filename eq '..') ) { next; }
      if ( -d ( $dirname . '/' . $filename ) ) {
        print "Recalling Program($dirname/$filename)\n";
        Program($dirname . '/' . $filename);
      }
      else {
        if ( open(FILEHANDLE, '<' . $dirname . '/' . $filename) ) { # Ensure I have read perms
          my $ext;

          $ext = GetExt($filename);
          close(FILEHANDLE);

          if ( ($ext eq 'bz2') or ($ext eq 'tgz') or ($ext eq 'gz') or ($ext eq 'bz') or ($ext eq 'Z') ) {
            MakeTemps();
            if ( $ext eq 'bz2' ) { # Currently bzip2'ed
              $cmdstr = "bunzip2 -c \"$dirname/$filename\" > \"$main::tmpfna\"";
              CmdExecute($cmdstr);
            } elsif ( $ext eq 'bz' ) { # Legacy bzip program
            } elsif ( $ext eq 'Z' ) { # Legacy compress program
            } else { # gzip
            }
          }
        }
      }
    }
    closedir(dirHandle);
  }
  return;
}

sub GetExt($)
{
  my $fn = $_[0];
  my @arr;
  my $ext;

  @arr = split(m/\./, $fn);
  $ext = $arr[scalar(@arr)-1];
  if ( $fn eq $ext ) { return undef; }
  return $ext;
}

sub MakeTemps()
{
  $main::tmpfna = "$main::tmpdir/__lzma_workingfile_a";
  $main::tmpfnb = "$main::tmpdir/__lzma_workingfile_b";

  CmdExecute("touch $main::tmpfna");
  CmdExecute("touch $main::tmpfnb");

  chmod 0600, $main::tmpfna;
  chmod 0600, $main::tmpfnb;

  return;
}

sub CmdExecute($)
{
  DebugCmdExecute($_[0], 1, 0);
  return;
}

sub DebugCmdExecute($$$)
{
  my ( $cmdstr, $verbose, $orly ) = @_;

  print $cmdstr if ( $verbose == 1 );
  system $cmdstr if ( $orly == 1 );
  return;
}
