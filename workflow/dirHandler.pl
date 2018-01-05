#!/usr/bin/perl

use strict;
use warnings;
use URI::Escape;
use MIME::Base64;
require "./functions.pl";

sub dir {
	my $transportMode;
	my $rawQuery = shift;
	my $googleEnv =
	  getHostSpecificWorkflowEnvironmentVariableValue("googleLocal");
	my $defaultTransportationMode =
	  getHostSpecificWorkflowEnvironmentVariableValue(
		"defaultTransportationMode");
	my $mapsProvider =
	  lc( getHostSpecificWorkflowEnvironmentVariableValue('mapsHandler') );
	my $strippedQuery;
	my $origin;
	my $destination;
	my $middleStops = '';
	my $transportQuery;
	my $errorCode = '';
	my $googleURL;

	#Set up Google URL based on configured workflow environment variable
	if ($googleEnv) {
		$googleURL = 'www.google.' . $googleEnv;
	}
	else {
		$googleURL = 'www.google.com';
	}

	#Search for type of transport modifier
	if ( $rawQuery =~ m/^((walk|drive|pt|bike) )?(.*)$/ ) {
		$strippedQuery  = $3;
		$transportQuery = $2;

		if ( defined $transportQuery ) {
			$transportMode =
			  checkTransportMode( $transportQuery, $mapsProvider );

			if ( $transportMode =~ m/^ERROR:(.*)$/ ) {
				$errorCode = $1;
			}
		}
	}

	#Check for a default transport mode if none was specified
	if ( !defined $transportMode && defined $defaultTransportationMode ) {
		$transportMode =
		  checkTransportMode( $defaultTransportationMode, $mapsProvider );
	}
	elsif ( !defined $transportMode ) {
		$transportMode =
		  '';    #deliberately initialise to a blank string as this is valid
	}

	#Initialise the array of locations after removing transport modifier
	my @array       = split( /\sto\s/, $strippedQuery );
	my $arraySize   = scalar(@array);
	my $lastElement = $arraySize - 1;

	#Check for only origin and destination
	if ( $arraySize == 2 ) {

		#Process origin and destination for any location modifiers
		$origin      = getAddress( $array[0] );
		$destination = getAddress( $array[1] );
	}
	elsif ( $arraySize < 2 ) {

		#We expect two or more values passed for directions
		$errorCode = 'NOTENOUGHLOCATIONS';
	}
	else {
		#If we are here, we have some waypoints WOOO
		#Process origin and destination for any location modifiers
		$origin      = getAddress( $array[0] );
		$destination = getAddress( $array[$lastElement] );

		#Remove the origin and destination
		shift(@array);
		pop(@array);

		$arraySize   = scalar(@array);    #reinitialise as array may have shrunk
		$lastElement = $arraySize - 1;    #reinitialise as array may have shrunk

		#Google only supports 9 waypoints on Desktop
		if ( $arraySize > 9 ) {
			$errorCode = 'TOOMANYWAYPOINTS';
		}
		else {
			#We have 9 or less, this is OK
			$middleStops = '&waypoints=';
			my $location;
			foreach (@array) {

				#process waypoint for any location modifiers
				my $waypointLocation = getAddress($_);
				$middleStops = $middleStops . $waypointLocation . '|';

			}
			chop($middleStops);    #remove trailing pipe
		}
	}

	if ( $errorCode eq 'TOOMANYWAYPOINTS' ) {
		return "ERROR: Too Many Waypoints";
	}
	elsif ( $errorCode eq 'NOTENOUGHLOCATIONS' ) {
		warn
"Not enough locations entered. We expect two at a minimum, origin and destination. Input query '$rawQuery'.\n";
		return
"ERROR: Not enough locations entered. We expect two at a minimum, origin and destination.";
	}
	elsif ( $errorCode eq 'APPLTRANSPORTNOTSUPPORTED' ) {
		warn
"Apple Maps does not support the '$transportQuery' mode of transportation and it was attempted.\n";
		return
"ERROR: Apple Maps does not support the '$transportQuery' mode of transportation.";
	}
	elsif ( $mapsProvider eq "apple" && $middleStops ne "" )
	{    #test if we have more than 0 waypoints on Apple Maps
		    #Apple Maps doesn't do waypoints, notify user gracefully
		warn
"Apple Maps does not support waypoints and waypoints were entered '$middleStops'.\n";
		return
"ERROR: Apple maps doesn't support waypoints between origin and destination.";
	}
	else {
		#No major errors encountered test for maps provider
		if ( $mapsProvider eq "apple" ) {
			return
"https://maps.apple.com/?saddr=$origin&daddr=$destination$transportMode";
		}
		else {
			#Assume the fallback to be Google!
			return
"https://$googleURL/maps/dir/?api=1&origin=$origin&destination=$destination$transportMode$middleStops";
		}
	}
}
1;
