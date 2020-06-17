#!/usr/bin/perl

use strict;
use warnings;

if ($#ARGV != 0) {
    print "Usage: $0 dyliblocation\n";
    exit;
}

my $bss_start = 0;
my $bss_end = 0;
my $fh;
my $line;

# Work out start/end of BSS section
open($fh, '-|', "objdump -h $ARGV[0]") or die $!;
while ($line = <$fh>) {
	if ($line =~ /\s([0-9A-Fa-f]+)\s([0-9A-Fa-f]+)\sBSS$/) {
		if ($bss_start == 0) {
			$bss_start = hex($2);
		}
		$bss_end = hex($1) + hex($2);
	}
}
close $fh;

my $store_bss_start = 0;
my $store_bss_end = 0;

# Work out where to store the values
open($fh, '-|', "nm -A $ARGV[0]") or die $!;
while ($line = <$fh>) {
	if ($line =~ /\s([0-9A-Fa-f]+)\sD ___bss_start$/) {
		$store_bss_start = hex($1);
	} elsif ($line =~ /\s([0-9A-Fa-f]+)\sD __end$/) {
		$store_bss_end = hex($1);
	}
	if ($store_bss_start != 0 && $store_bss_end != 0) {
		last;
	}
}
close $fh;

# Overwrite the dummy values in the dynamic library with the real ones
open($fh, '+<', $ARGV[0]) or die "Unable to open: $!";
binmode($fh);
seek($fh, $store_bss_start, 0);
print $fh pack('I<', $bss_start);
seek($fh, $store_bss_end, 0);
print $fh pack('I<', $bss_end);
close($fh);
