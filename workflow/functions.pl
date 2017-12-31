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
			}
		}
		 die "Host specific setting for workflow environment variable '$variableName' is malformed or no host specific option is defined for current host.\n" unless defined $hostSpecificOptionValue;
		return $hostSpecificOptionValue;
	}
	else {
		return $ENV{$variableName};
	}

}

1;
