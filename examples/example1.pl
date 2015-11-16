#!/usr/bin/env perl

use common::sense;
use GD::Graph::Hooks;
use GD::Graph::lines;

my @data;
for( 0 .. 100 ) { push @{$data[0]}, $_; push @{$data[1]}, $_ + 3*(rand 5); }

my $graph = GD::Graph::lines->new(500,500);

my $gd = $graph->plot(\@data);

my $fname = "/tmp/example.png";
open my $img, '>', $fname or die $!;
binmode $img;
print $img $gd->png;
close $img;

print "example written to $fname\n";
