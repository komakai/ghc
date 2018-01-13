#!/usr/bin/perl

my $main_closure_symbol_name = `grep -o ghc.*Main_main_closure ghc/Main.hc`;
chomp $main_closure_symbol_name;

open(HEADER, ">ghc/nativeint/main_closure.h");
print HEADER "/****\n";
print HEADER " * This file is generated - editing it is futile\n";
print HEADER " ****/\n";
print HEADER "\n";
print HEADER "extern StgClosure $main_closure_symbol_name;\n";
print HEADER "StgClosure* main_closure = &$main_closure_symbol_name;\n";
close(HEADER);
