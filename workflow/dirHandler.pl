#!/usr/bin/perl

use strict;
use warnings;
use URI::Escape;
use MIME::Base64;
require "./functions.pl";

sub dir {
	my $transportMode;
	my $rawQuery  = shift;
	my $googleEnv = getHostSpecificWorkflowEnvironmentVariableValue("googleLocal");
	my $defaultTransportationMode =
	  getHostSpecificWorkflowEnvironmentVariableValue("defaultTransportationMode");
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
			$transportMode = checkTransportMode($transportQuery);
		}
	}

	#Check for a default transport mode if none was specified
	if ( !defined $transportMode && defined $defaultTransportationMode ) {
		$transportMode = checkTransportMode($defaultTransportationMode);
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
		print "ERROR: Too Many Waypoints";
	}
	else {
		return
"https://$googleURL/maps/dir/?api=1&origin=$origin&destination=$destination$transportMode$middleStops";
	}

}
1;
