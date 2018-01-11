use strict;
use warnings;
use MIME::Base64;
use URI::Escape;

#Checks for transportation mode based on input string and returns URL parameters in response
sub checkTransportMode {
	my $query = shift;
	my $mapsProvider = shift;

	#check for type of transport requested
	if ($mapsProvider eq "apple"){
	if ( $query =~ m/^walk.*$/ ) {
		return '&dirflg=w';
	}
	elsif ( $query =~ m/^pt.*$/ ) {
		return '&dirflg=r';
	}
	elsif ( $query =~ m/^bike.*$/ ) {
		return "ERROR:APPLTRANSPORTNOTSUPPORTED";
	}
	elsif ( $query =~ m/^drive.*$/ ) {
		return '&dirflg=d';
	}
	else {
		return "";
	}
	}else {
		#for the time being, assume Google
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

}

#Get computer hostname for per-computer configurations
sub getHostname {
	my $hostname;
	$hostname = `hostname -s`;
	die "Unable to get hostname\n" unless $? == 0;
	chomp $hostname;
	return $hostname;
}

#Get workflow environment variable list
sub getWorkflowEnvironmentVariableList {
	my $variableName = shift;
	my @optionsArray;
	my $environmentVariableValue = $ENV{$variableName};
	my $regexReturn;

#check if we match the required format eg "('something:value','something:value')"
	if ( defined $environmentVariableValue
		&& $environmentVariableValue =~ m/^\((.*)\)$/ )
	{
		$regexReturn = $1;

		#strip out spaces in between options otherwise the split will not work
		$regexReturn =~ s/'\s?,\s?'/','/g;

		@optionsArray =
		  split( "','", $regexReturn )
		  ;    #$1 being the first capture in the above regex

		for (@optionsArray) {

			#strip out any remaining ' characters
			s/'//g;
		}

		return @optionsArray;
	}
	else {
		@optionsArray = ();
		return
		  @optionsArray;  #deliberately return a null array, no list is defined.
	}

}

#Get host specific workflow environment variable value
sub getHostSpecificWorkflowEnvironmentVariableValue {
	my $variableName = shift;
	my $hostname;
	my $hostSpecificOptionValue;

	#if this returns a blank array we have a standard option not a list
	my @optionsArray = getWorkflowEnvironmentVariableList($variableName);

	if ( scalar(@optionsArray) != 0 ) {

		$hostname = getHostname();    #get current computer hostname

		foreach (@optionsArray) {
			my $optionHostname;
			if ( $_ =~ m/^(.*):(.*)$/ ) {
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
		if ( defined $ENV{$variableName} ) {

			#if no list, just return the straight up value
			return $ENV{$variableName};
		}
		else {
			return "";    #return blank, no value defined
		}
	}
}

#Get current location as best as possible. Can be expanded in future, you know, if Macs get inbuilt GPS :D
sub getCurrentLocation {
	my $location;
	my $coreLocationBinary =
	  getHostSpecificWorkflowEnvironmentVariableValue("CoreLocationCLIBinary");
	my $errorCode;

	#test to see if CoreLocationCLI is at known location
	if (
		-e getHostSpecificWorkflowEnvironmentVariableValue(
			"CoreLocationCLIBinary")
	  )
	{

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
		$location = getHostSpecificWorkflowEnvironmentVariableValue(
			"currentLocationFallback");
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
	my $workAddressNew;
	my $workAddressEncoded;
	my $homeAddress;
	my $homeAddressNew;
	my $homeAddressEncoded;
	my $outputLocation;

	#If this returns a blank array we have a standard option not a list
	my @customLocations = getWorkflowEnvironmentVariableList('customLocations');

	#Get home and work addresses from the legacy location if they still exist
	#Note this will be removed in a future version, but is included here
	#to ensure we won't have a major break in this twice in several releases.
	$workAddress = `security find-generic-password -w -s "alfred-work-address"`;
	if ( defined $workAddress ) {
		$workAddress = decode_base64($workAddress);
		chomp($workAddress);
		$workAddressEncoded = uri_escape($workAddress);
	}

	$homeAddress = `security find-generic-password -w -s "alfred-home-address"`;
	if ( defined $homeAddress ) {
		$homeAddress = decode_base64($homeAddress);
		chomp($homeAddress);
		$homeAddressEncoded = uri_escape($homeAddress);
	}

#Now deliberately try to get the addresses from Newer Alfred Workflow Env Variables and supersede previous values

	$workAddressNew =
	  getHostSpecificWorkflowEnvironmentVariableValue('workAddress');

	if ( $workAddressNew ne "") {
		$workAddressEncoded = uri_escape($workAddressNew);
	}

	$homeAddressNew =
	  getHostSpecificWorkflowEnvironmentVariableValue('homeAddress');

	if ( $homeAddressNew ne "" ) {
		$homeAddressEncoded = uri_escape($homeAddressNew);
	}

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
	elsif ( scalar(@customLocations) != 0 ) {

		#oooh we have some custom locations defined, check if we have a match
		foreach (@customLocations) {
			my $optionName;
			if ( $_ =~ m/^(.*):(.*)$/ ) {
				my $optionName  = $1;
				my $optionValue = $2;

	  #if the optionName = the inputted location text we have a match to convert
				if ( lc($optionName) eq lc($inputLocation) ) {
					$outputLocation = uri_escape($optionValue);
					last;
				}
			}
		}
		if ( !defined $outputLocation ) {

			#no match in list
			$outputLocation = uri_escape($inputLocation);
		}
	}
	else {
		#no list exists
		$outputLocation = uri_escape($inputLocation);
	}
	return $outputLocation;
}

1;
