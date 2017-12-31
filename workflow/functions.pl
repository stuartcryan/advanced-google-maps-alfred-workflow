use strict;
use warnings;

#Checks for transportation mode based on input string and returns URL parameters in response
sub checkTransportMode {
	my $query = shift;

	#check for type of transport requested
	if ( $query =~ m/^walk.*$/ ) {
		return '&travelmode=walking';
	}
	elsif ( $query =~ m/^pt.*$/ ) {
		return '&travelmode=transit';
	}
	elsif ( $query =~ m/^bike.*$/ ) {
		return '&travelmode=bicycling';
	}
	elsif ( $query =~ m/^drive.*$/ ) {
		return '&travelmode=driving';
	}
	else {
		return "";
	}
}

#Get computer hostname for per-computer configurations
sub getHostname {
	my $hostname;
	$hostname = `hostname -s`;
	die "Unable to get hostname\n" unless $? == 0;
	chomp $hostname;
	return $hostname;
}

#Get general or computer specific workflow environment variable
sub getWorkflowEnvironmentVariable {
	my $variableName = shift;
	my $hostname;
	my @optionsArray;
	my $hostSpecificOptionValue;

#check if we match the required format eg "('StuartCRyan-MBP:pt','StuartCRyan-Air:drive')"
	if ( $ENV{$variableName} =~ m/^\((.*)\)$/ ) {
		@optionsArray =
		  split( ',', $1 );    #$1 being the first capture in the above regex

		$hostname = getHostname();    #get current computer hostname

		foreach (@optionsArray) {
			my $optionHostname;
			if ( $_ =~ m/^'(.*):(.*)'$/ ) {
				my $optionHostname = $1;
				my $optionValue    = $2;
				if ( lc($optionHostname) eq lc($hostname) ) {
					$hostSpecificOptionValue = $optionValue;
					last;
				}
				elsif ( lc($optionHostname) eq 'default' ) {

	 #If we have a default option and have reached here we haven't yet found
	 #specific option. Therefore store it in case we don't find anything better.
					$hostSpecificOptionValue = $optionValue;
				}
			}
		}
		die
"Host specific setting for workflow environment variable '$variableName' "
		  . "is malformed or no host specific option is defined for current host.\n"
		  unless defined $hostSpecificOptionValue;
		return $hostSpecificOptionValue;
	}
	else {
		return $ENV{$variableName};
	}

}

#Get current location as best as possible. Can be expanded in future, you know, if Macs get inbuilt GPS :D
sub getCurrentLocation {
	my $location;
	my $coreLocationBinary =
	  getWorkflowEnvironmentVariable("CoreLocationCLIBinary");
	my $errorCode;

	#test to see if CoreLocationCLI is at known location
	if ( -e getWorkflowEnvironmentVariable("CoreLocationCLIBinary") ) {

		#we have CoreLocationCLI get coordinates
		$location = `$coreLocationBinary -format "%latitude,%longitude"`;
		if ( $? != 0 ) {
			$errorCode = 'CORELOCATIONFAILED';
		}
		else {
			chomp($location);
			return $location;
		}
	}

#Test if Core Location Failed or if location is undefined CoreLocation does not exist.
	if ( $errorCode eq 'CORELOCATIONFAILED' || !defined $location ) {
		warn
		  "Something went wrong with CoreLocationCLI! Either WiFi is not on, "
		  . "is not defined, or doesn't exist. Configured value is: '$coreLocationBinary'\n";

		#fallback to specified location
		$location = getWorkflowEnvironmentVariable("currentLocationFallback");
		die "Unable to get any current location. Please specify a fallback "
		  . "under workflow environment variable 'currentLocationFallback' \n"
		  unless defined $location;
	}
	if ( $location eq 'here' ) {
		die "Current location fallback is set to here... that is bad mmmkay"
		  . " and if it wasn't for foresight would create an infinite loop. This death prevents such an infinite runaway. \n";
	}
	else {
		return getAddress($location)
		  ; #deliberately run the getAddress function even though we may be called from there. In case the default is set to home or work.
	}
}

#Convert location modifiers into actual addresses
#All addresses should be run through here as a standard, especially for URL escaping
sub getAddress {
	my $inputLocation = shift;
	my $workAddress;
	my $workAddressEncoded;
	my $homeAddress;
	my $homeAddressEncoded;
	my $outputLocation;

	#Get home and work addresses
	$workAddress = `security find-generic-password -w -s "alfred-work-address"`;
	$workAddress = decode_base64($workAddress);
	chomp($workAddress);
	$workAddressEncoded = uri_escape($workAddress);

	$homeAddress = `security find-generic-password -w -s "alfred-home-address"`;
	$homeAddress = decode_base64($homeAddress);
	chomp($homeAddress);
	$homeAddressEncoded = uri_escape($homeAddress);

	if ( lc($inputLocation) eq "here" ) {

		#check for 'here' location modifier and get GPS coordinates if possible
		$outputLocation = getCurrentLocation();
	}
	elsif ( lc($inputLocation) eq "work" ) {
		$outputLocation = $workAddressEncoded;
	}
	elsif ( lc($inputLocation) eq "home" ) {
		$outputLocation = $homeAddressEncoded;
	}
	else {
		$outputLocation = uri_escape($inputLocation);
	}

	return $outputLocation;
}

1;
