#!/usr/bin/env perl

use common::sense;
use GD::Graph::Hooks;
use GD::Graph::lines;

my @data;
for( 0 .. 100 ) { push @data, [ $_, $_ + 5*(rand 7) ]; }

my $graph = GD::Graph::lines->new(500,500);

my $gd = $graph->plot(\@data);

my $fname = "/tmp/example.png";
open my $img, '>', $fname or die $!;
binmode $img;
print $img $gd->png;
close $img;

print "example written to $fname\n";
