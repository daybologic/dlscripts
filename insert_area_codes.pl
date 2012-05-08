#
# This script parses a simple text file full of area codes for the UK
# and inserts them into Daybo Logic's database (area_codes table).
# It does not currently check whether there are any duplicates.
#

use DBI;

my $db = 'ddrp_daybo';
my $dbhost = 'sql.daybologic.com';
my $dbuserid = 'overlord';
my $dbpasswd = '???';
my $connectionInfo="dbi:mysql:$db;$dbhost";
my $dbh; # Handle
my $query;
my $sth;

my $acode;
my $ccode = '44';

# Initiate connection to database
$dbh = DBI->connect($connectionInfo, $dbuserid, $dbpasswd);

foreach ( <STDIN> ) {
  $acode = $_;
  chomp $acode;
  if ( !IsNumeric($acode) and $acode ne '' ) {
    print STDERR "Skipping area code: \'$acode\' (not numeric)\n";
    next;
  }

  print "Inserting area code: $acode\n";
  # Prepare and execute query
  $query = 'INSERT INTO area_codes (country_tel, area_tel, addtime, modtime)' .
    "VALUES('$ccode', '$acode', NOW(), NOW())";

  $sth = $dbh->prepare($query);
  $sth->execute();
  $sth->finish();
}

$dbh->disconnect();

exit 0;
#----------------------------------------------------------------------------
sub IsNumeric {
  my $InputString = shift;

  if ($InputString !~ /^[0-9|.|,]*$/) {
    return 0;
  }
  return 1;
}
#----------------------------------------------------------------------------
