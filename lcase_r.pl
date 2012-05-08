#
# This program walks through an entire directory structure, starting
# with the current working directory.  It renames all files with lower-case
# lettering.  So Blah.JPG becomes blah.jpg.
#

sub Program($);

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
        print "Processing sub-directory ($dirname/$filename)\n";
        Program($dirname . '/' . $filename);
      }
      else {
        my $newfilename = lc($filename);
        if ( $newfilename ne $filename ) {
          print "Renaming $dirname/$filename -> $dirname/$newfilename\n";
          rename "$dirname/$filename", "$dirname/$newfilename";
        }
      }
    }
    closedir(dirHandle);
  }
  return;
}

