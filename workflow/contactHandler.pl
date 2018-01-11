#!/usr/bin/perl

use strict;
use warnings;
use URI::Escape;
require "./functions.pl";

sub contactDirHandler {
	my $transportMode;
	my $rawQuery = shift;
	$rawQuery =~ s/\R/ /g; #strip any newlines and replace with spaces
	my $contactHandlerConfig =
	  getHostSpecificWorkflowEnvironmentVariableValue("contactHandler");
	my $errorCode = '';
	my $googleURL;
	my $orderedQuery;

	if ( $contactHandlerConfig =~ m/^((walk|drive|pt|bike) )?(to.*)$/ ) {
		$orderedQuery = "$1$rawQuery $3";

	}
	elsif ( $contactHandlerConfig =~ m/^((walk|drive|pt|bike) )?(.*to.*)$/ ) {
		$orderedQuery = "$1$3 $rawQuery";
	}

	return $orderedQuery;

}
1;
