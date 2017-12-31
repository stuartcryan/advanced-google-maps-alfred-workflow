#!/usr/bin/perl

use strict;
use warnings;

# Description of argument expectations:
# $ARGV[0] - entered string (i.e. encapsulate in quotes as a single arg)
# $ARGV[1] - modifier string direction (to/from)
# $ARGV[2] - modifier string location

my $rawQuery         = $ARGV[0];
my $direction        = $ARGV[1];
my $modifierLocation = $ARGV[2];
my $strippedQuery    = '';
my $transportQuery   = '';

#orderQuery will arrange the output in the order we need based on input modifiers
sub orderQuery {
	my $query          = shift;
	my $transportQuery = shift;

	if ( $direction eq 'to' ) {
		return "$transportQuery $query to $modifierLocation";
	}
	elsif ( $direction eq 'from' ) {
		return "$transportQuery $modifierLocation to $query";
	}

}

#search for type of transport modifier if any if none, order query based on raw input
if ( $rawQuery =~ m/^((walk|drive|pt|bike) )(.*)$/ ) {
	$strippedQuery  = $3;
	$transportQuery = $2;

	print orderQuery( $strippedQuery, $transportQuery )

}
else {
	#no transport modifier action based on raw input query
	print orderQuery( $rawQuery, $transportQuery );
}
