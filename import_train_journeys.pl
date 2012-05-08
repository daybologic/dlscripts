#!/usr/bin/perl
# This program imports a comma separated list of train journeys into
# the great database.

use DBI;
use DBD::mysql;
#----------------------------------------------------------------------------
my @arr_srcline = ( );
my @arr_date = ( );
my @arr_time = ( );
my @arr_price = ( );
my @arr_origin = ( );
my @arr_destination = ( );
my @arr_return = ( );

my @travel_location_id = ( );
my @travel_location_mnemonic = ( );
my @travel_company_id = ( );
my @travel_company_name = ( );

my $ret = 0;
my $lineNum = 0;
my $totalProcessedLines = 0;
my $began = 0;

my $db = 'daybologic';
my $dbhost = 'sql.daybologic.com';
my $dbuserid = 'ddrp_daybo';
my $dbpasswd = '???';
my $connectionInfo="dbi:mysql:$db;$dbhost";
my $dbh = undef; # Handle
my $query;
my $sth;
#----------------------------------------------------------------------------
sub GetTravelLocationMnemonics($$$);
sub GetTravelCompanyNames($$$);
sub PrepareDate($$);
sub PrepareTime($$);
sub PreparePrice($$);
sub PrepareOrigin($$$);
sub PrepareDestination($$$);
sub PrepareReturn($$);
#----------------------------------------------------------------------------
sub GetTravelLocationMnemonics($$$)
{
  my ( $dbh, $ids, $mnemonics ) = @_;
  my $ret = 0;
  $query = "SELECT \`id\`,\`mnemonic\` FROM \`travel_locations\`";
  $sth = $dbh->prepare($query);
  if ( $sth ) {
    my $numRows;
    my $i;

    $numRows = $sth->execute();
    $numRows = 0 if ( $numRows eq '0E0' );
    for ( $i = 1; $i <= $numRows; $i++ ) {
      my @row = $sth->fetchrow_array();
      push(@$ids, $row[0]) if ( $ids );
      push(@$mnemonics, $row[1]) if ( $mnemonics );
      $ret++;
    }
    $sth->finish();
  }
  return $ret;
}
#----------------------------------------------------------------------------
sub GetTravelCompanyNames($$$)
{
  my ( $dbh, $ids, $names) = @_;
  my $ret = 0;
  $query = "SELECT \`id\`,\`name\` FROM \`travel_companies\`";
  $sth = $dbh->prepare($query);
  if ( $sth ) {
    my $numRows;
    my $i;

    $numRows = $sth->execute();
    $numRows = 0 if ( $numRows eq '0E0' );
    for ( $i = 1; $i <= $numRows; $i++ ) {
      my @row = $sth->fetchrow_array();
      push(@$ids, $row[0]) if ( $ids );
      push(@$names, $row[1]) if ( $names );
      $ret++;
    }
    $sth->finish();
  }
  return $ret;
}
#----------------------------------------------------------------------------
sub PrepareDate($$)
{
  my $dbh = $_[0];
  my $userDate = $_[1];
  my $userDateReturn = 'NULL';

  if ( $dbh ) {
    if ( $userDate =~ m/\d{8}/ ) {
      $userDateReturn = substr($userDate, 0, 4);
      $userDateReturn = $userDateReturn . '-' . substr($userDate, 4, 2);
      $userDateReturn = $userDateReturn . '-' . substr($userDate, 6, 2);
      $userDateReturn = $dbh->quote($userDateReturn);
    }
  }
  return $userDateReturn;
}
#----------------------------------------------------------------------------
sub PrepareTime($$)
{
  my $dbh = $_[0];
  my $userTime = $_[1];
  my $userTimeReturn = 'NULL';

  if ( $dbh ) {
    if ( $userTime =~ m/\d{4}/ ) {
      $userTimeReturn = substr($userTime, 0, 2) . ':' . substr($userTime, 2) . ':00';
      $userTimeReturn = $dbh->quote($userTimeReturn);
    }
  }
  return $userTimeReturn;
}
#----------------------------------------------------------------------------
sub PreparePrice($$)
{
  my $dbh = $_[0];
  my $userPrice = $_[1];
  my $userPriceReturn = 'NULL';

  if ( $dbh ) {
    if ( $userPrice =~ m/\d{1,3}\.\d{2}/ ) {
      $userPriceReturn = $dbh->quote($userPrice);
    }
  }
  return $userPriceReturn;
}
#----------------------------------------------------------------------------
sub PrepareOrigin($$$)
{
  return PrepareDestination($_[0], $_[1], $_[2]);
}
#----------------------------------------------------------------------------
sub PrepareDestination($$$)
{
  my $dbh = $_[0];
  my $userDest = $_[1];
  my $line = $_[2];
  my $userDestReturn = 'NULL';
  my $retSet = 0;

  if ( $dbh ) {
    if ( $userDest =~ m/\C{1,6}/ ) {
      my $i = 0;
      foreach ( @travel_location_mnemonic ) {
        if ( $travel_location_mnemonic[$i] eq $userDest ) {
          $userDestReturn = $dbh->quote($travel_location_id[$i]);
          $retSet = 1;
        }
        $i++;
      }
      if ( $retSet != 1 ) {
        print "WARNING Unknown destination =( \'$userDest\' at line $arr_srcline[$line]\n";
      }
    }
  }

  #print "userDestReturn: $userDestReturn\n";
  return $userDestReturn;
}
#----------------------------------------------------------------------------
sub PrepareReturn($$)
{
  my $dbh = $_[0];
  my $userReturn = $_[1];
  my $userReturnReturn = 'NULL';

  if ( $dbh ) {
    if ( $userReturn eq 's' ) {
      $userReturnReturn = $dbh->quote('0');
    }
    elsif ( $userReturn eq 'r' ) {
      $userReturnReturn = $dbh->quote('1');
    }
    elsif ( $userReturn eq '?' ) {
      $userReturnReturn = 'NULL';
    }
  }
  return $userReturnReturn;
}
#----------------------------------------------------------------------------
foreach my $line ( <STDIN> ) {
  my $i;
  my $actualC;
  my $expectC;
  my @splitted;

  chomp $line;
  $lineNum++;
  if ( $line =~ m/^BEGIN$/ ) {
    if ( $began == 1 ) {
      print "ERROR: BEGIN block on line $line inside BEGIN block at line $beginLine\n";
      $ret = 1;
    } else {
      $began = 1;
      $beginLine = $lineNum;
    }
    next;
  }
  if ( $line =~ m/^END$/ ) {
    if ( $began == 0 ) {
      print "ERROR: END block without BEGIN at line $line\n";
    } else {
      $began = 0;
    }
    next;
  }

  if ( $began == 1 ) {
    @splitted = split(',', $line);
    $actualC = scalar(@splitted);
    $expectC = 6;
    $totalProcessedLines++;
    if ( $actualC == $expectC ) {
      push @arr_srcline, $lineNum;
      for ( $i = 0; $i < $actualC; $i++ ) {
        if ( $i == 0 ) {
          push @arr_date, $splitted[$i];
        } elsif ( $i == 1 ) {
          push @arr_time, $splitted[$i];
        } elsif ( $i == 2 ) {
          push @arr_price, $splitted[$i];
        } elsif ( $i == 3 ) {
          push @arr_origin, $splitted[$i];
        } elsif ( $i == 4 ) {
          push @arr_destination, $splitted[$i];
        } elsif ( $i == 5 ) {
          push @arr_return, $splitted[$i];
        }
      }
    } else {
      $ret = 1;
      print "ERROR: Incorrect number of columns in row ($actualC, expected $expectC) on line $lineNum.\n";
    }
  }
}

if ( $began == 1 ) {
  print "ERROR: EOF after BEGIN without END (started line $beginLine)\n";
  $ret = 2;
}
if ( $totalProcessedLines == 0 ) {
  print "WARNING: No lines to process, ensure BEGIN and END lines are set.\n";
}

if ( $ret == 0 ) {
  $dbh = DBI->connect($connectionInfo, $dbuserid, $dbpasswd);
  if ( $dbh ) {
    my $locationI;
    my $locationC = GetTravelLocationMnemonics($dbh, \@travel_location_id, \@travel_location_mnemonic);
    if ( $locationC ) {
      my $companyI;
      my $companyC = GetTravelCompanyNames($dbh, \@travel_company_id, \@travel_company_name);
      if ( $companyC ) {
        my $i = 0;
        foreach ( @arr_date ) {
          $arr_date[$i] = PrepareDate($dbh, $arr_date[$i]);
          $arr_time[$i] = PrepareTime($dbh, $arr_time[$i]);
          $arr_price[$i] = PreparePrice($dbh, $arr_price[$i]);
          $arr_origin[$i] = PrepareOrigin($dbh, $arr_origin[$i], $i);
          $arr_destination[$i] = PrepareDestination($dbh, $arr_destination[$i], $i);
          $arr_return[$i] = PrepareReturn($dbh, $arr_return[$i]);

          $query = "INSERT INTO \`travel_ticket_detail\` (" .
            "\`travel_company_id\`," .
            "\`ticket_date\`," .
            "\`ticket_time\`," .
            "\`price\`," .
            "\`class\`," .
            "\`return\`," .
            "\`origin\`," .
            "\`destination\`) VALUES(" .
            "\'10\'," .
            $arr_date[$i] . ',' .
            $arr_time[$i] . ',' .
            $arr_price[$i] . ',' .
            "\'std\'," .
            $arr_return[$i] . ',' .
            $arr_origin[$i] . ',' .
            $arr_destination[$i] . ')';

          print "$query\n";
          $sth = $dbh->prepare($query);
          if ( $sth ) {
            $sth->execute();
            $sth->finish();
          }
          $i++;
        }
      } else {
        print "ERROR: Sorry, there are known known travel companies.\n";
        $ret = 1;
      }
    } else {
      print "ERROR: Sorry, no known locations, the script will not be processed.\n";
      $ret = 1;
    }
  }
}

if ( $dbh ) {
  $dbh->disconnect();
  $dbh = undef;
}

exit $ret;

