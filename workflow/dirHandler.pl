use strict;
use warnings;
use URI::Escape;
use MIME::Base64;

# Description of argument expectations:
# $ARGV[0] - location string (i.e. encapsulate in quotes as a single arg)
# $ARGV[1] - 'googleLocal' Alfred WorkflowENV variable
# $ARGV[2] - 'CoreLocationCLIBinary' Alfred WorkflowENV variable

my $url                   = '';
my $transportMode         = '';
my $rawQuery              = $ARGV[0];
my $googleEnv             = $ARGV[1];
my $coreLocationBinaryEnv = $ARGV[2];
my $strippedQuery;
my $modified = '';
my $origin;
my $destination;
my $middleStops    = '';
my $transportQuery;
my $errorCode      = '';
my $workAddress;
my $workAddressEncoded;
my $homeAddress;
my $homeAddressEncoded;
my $googleURL;

if ($googleEnv) {
	$googleURL = 'www.google.' . $googleEnv;
}
else {
	$googleURL = 'www.google.com';
}

#search for type of transport modifier
if ( $rawQuery =~ m/^((walk|drive|pt|bike) )?(.*)$/ ) {
	$strippedQuery  = $3;
	$transportQuery = $2;
	
	if ( defined $transportQuery ) {

		#check for type of transport requested
		if ( $transportQuery =~ m/^walk.*$/ ) {
			$transportMode = '&travelmode=walking';
		}
		elsif ( $transportQuery =~ m/^pt.*$/ ) {
			$transportMode = '&travelmode=transit';
		}
		elsif ( $transportQuery =~ m/^bike.*$/ ) {
			$transportMode = '&travelmode=bicycling';
		}
		elsif ( $transportQuery =~ m/^drive.*$/ ) {
			$transportMode = '&travelmode=driving';
		}
	}
}

#Get home and work addresses
$workAddress = `security find-generic-password -w -s "alfred-work-address"`;
$workAddress = decode_base64($workAddress);
chomp($workAddress);
$workAddressEncoded = uri_escape($workAddress);

$homeAddress = `security find-generic-password -w -s "alfred-home-address"`;
$homeAddress = decode_base64($homeAddress);
chomp($homeAddress);
$homeAddressEncoded = uri_escape($homeAddress);

#initialise the array after removing transport modifier
my @array       = split( /\sto\s/, $strippedQuery );
my $arraySize   = scalar(@array);
my $lastElement = $arraySize - 1;

$arraySize   = scalar(@array);    #reinitialise as array may have shrunk
$lastElement = $arraySize - 1;    #reinitialise as array may have shrunk

#check for only origin and destination
if ( $arraySize == 2 ) {
	$origin      = uri_escape( $array[0] );
	$destination = uri_escape( $array[1] );
}
else {
	#if we are here, we have some waypoints WOOO
	$origin      = uri_escape( $array[0] );
	$destination = uri_escape( $array[$lastElement] );

	#remove the origin and destination
	shift(@array);
	pop(@array);

	$arraySize   = scalar(@array);    #reinitialise as array may have shrunk
	$lastElement = $arraySize - 1;    #reinitialise as array may have shrunk

	# Google only supports 9 waypoints on Desktop
	if ( $arraySize > 9 ) {
		$errorCode = 'TOOMANYWAYPOINTS';
	}

	$middleStops = '&waypoints=';
	my $location;
	foreach (@array) {
		if ( lc($_) eq "here" ) {

			#check if we are using the here modifier for current coordinates
			$location = `$coreLocationBinaryEnv -format "%latitude,%longitude"`;
			if ( $? != 0 ) {
				$errorCode = 'CORELOCATIONFAILED';
			}
			else {
				chomp($location);
				$middleStops = $middleStops . uri_escape($location) . '|';
			}
		}
		elsif ( lc($_) eq "work" ) {
			$middleStops = $middleStops . $workAddressEncoded . '|';
		}
		elsif ( lc($_) eq "home" ) {
			$middleStops = $middleStops . $homeAddressEncoded . '|';
		}
		else {
			#use the provided value
			$middleStops = $middleStops . uri_escape($_) . '|';
		}
	}
	chop($middleStops);    #remove trailing pipe
}

if ( lc($origin) eq "here" ) {

	#check for 'here' location modifier and get GPS coordinates if possible
	my $location = `$coreLocationBinaryEnv -format "%latitude,%longitude"`;
	if ( $? != 0 ) {
		$errorCode = 'CORELOCATIONFAILED';
	}
	else {
		chomp($location);
		$origin = $location;
	}
}
elsif ( lc($origin) eq "work" ) {
	$origin = $workAddressEncoded;
}
elsif ( lc($origin) eq "home" ) {
	$origin = $homeAddressEncoded;
}

if ( lc($destination) eq "here" ) {

	#check for 'here' location modifier and get GPS coordinates if possible
	my $location = `$coreLocationBinaryEnv -format "%latitude,%longitude"`;
	if ( $? != 0 ) {
		$errorCode = 'CORELOCATIONFAILED';
	}
	else {
		chomp($location);
		$destination = $location;
	}
}
elsif ( lc($destination) eq "work" ) {
	$destination = $workAddressEncoded;
}
elsif ( lc($destination) eq "home" ) {
	$destination = $homeAddressEncoded;
}

if ( $errorCode eq 'TOOMANYWAYPOINTS' ) {
	print "ERROR: Too Many Waypoints";
}
elsif ( $errorCode eq 'CORELOCATIONFAILED' ) {
	print
"ERROR: CoreLocation could not get current location. Check if WiFi is on!";
}
else {
	print
"https://$googleURL/maps/dir/?api=1&origin=$origin&destination=$destination$transportMode$middleStops";
}
