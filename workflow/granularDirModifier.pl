#!/usr/bin/perl

use strict;
use warnings;

#orderQuery will arrange the output in the order we need based on input modifiers
sub orderQuery {
	my $query            = shift;
	my $transportQuery   = shift;
	my $direction        = shift;
	my $modifierLocation = shift;

	if ( $direction eq 'to' && $transportQuery ne '' ) {
		return "$transportQuery $query to $modifierLocation";
	}
	elsif ( $direction eq 'to' && $transportQuery eq '' ) {
		return "$query to $modifierLocation";
	}
	elsif ( $direction eq 'from' && $transportQuery ne '' ) {
		return "$transportQuery $modifierLocation to $query";
	}
	elsif ( $direction eq 'from' && $transportQuery eq '' ) {
		return "$modifierLocation to $query";
	}

}

sub granularDir {

	# Description of argument expectations:
	# arg 1 - entered string (i.e. encapsulate in quotes as a single arg)
	# arg 2 - modifier string direction (to/from)
	# arg 3 - modifier string location
	my $rawQuery         = shift;
	my $direction        = shift;
	my $modifierLocation = shift;
	my $strippedQuery    = '';
	my $transportQuery   = '';

#search for type of transport modifier if any if none, order query based on raw input
	if ( $rawQuery =~ m/^((walk|drive|pt|bike) )(.*)$/ ) {
		$strippedQuery  = $3;
		$transportQuery = $2;

		return orderQuery( $strippedQuery, $transportQuery, $direction,
			$modifierLocation );

	}
	else {
		#no transport modifier action based on raw input query
		return orderQuery( $rawQuery, $transportQuery, $direction,
			$modifierLocation );
	}

}

1;
