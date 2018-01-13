#!/usr/bin/perl

use Digest::MD5 qw(md5);

sub hash
{
	my $str = substr(md5($_[0]), 0, 4 );
	return unpack('L', $str);
}

my $nm = "nm";
my $leadingchar = "";
my $nmoptions = "";
my $way_suffix = "";
my $libsuffix = $ARGV[0];

if ($libsuffix eq "dylib" || $libsuffix eq "so") {
	$nmoptions = ($libsuffix eq "dylib") ? "-gU" : "-D";
	$way_suffix = "dyn_";
} else {
	$nmoptions = "-a";
}

if ($ARGV[1] eq "yes") {
	$leadingchar = "_";
}

my @packagesraw = `cat fixups/packages`;
my @packages=();
foreach $package(@packagesraw){
	chomp($package);
	if (length($package) == 0) {
		last;
	}
	my $fullpackage = `find inplace/lib/package.conf.d -type f -name "${package}*.conf"`;
	chomp($fullpackage);
	$fullpackage =~ s/inplace\/lib\/package.conf.d\///;
	$fullpackage =~ s/\-inplace\.conf//;
	push (@packages, $fullpackage);
}

my @symbol_suffixes=("_closure","_info","_tbl","_slow");
my @export_function_list=();
my @list;

foreach my $package(@packages) {
	my $packagename = substr($package,0,-8);
	my $prefix = $packagename . "_";
	$prefix =~ s/-/zm/;
	my $lib = `ls libraries/$packagename/dist-install/build/libHS*.$libsuffix`;
	chomp($lib);
	foreach $suffix(@symbol_suffixes) {
		@list = `$nm $nmoptions $lib | grep -o -e "[DT] $leadingchar$prefix.*$suffix\$"`;
#print "$nm $nmoptions $lib | grep -o -e \"[DT] $leadingchar$prefix.*$suffix\$\"";
		@export_function_list = (@export_function_list, @list);
	}
}

my $function;
my %function_map = ();

foreach $function(@export_function_list) {
	chomp($function);
	$function = substr $function, 2+length($leadingchar);
	my $hash = hash($function);
	if (exists $function_map{$hash}) {
		foreach $key (sort { $a <=> $b} keys %function_map) {
		    print "\{$key , $function_map{$key} \},\n";
		}

		die "Duplicate hash $hash found for $function\n";
	}
	$function_map{$hash} = $function;
}

my $key;
open (SYMTAB, ">fixups/symboltable.${way_suffix}inc");

print SYMTAB "\n";

foreach $function (sort (values %function_map)) {
	my @skiplist=("base_GHCziTopHandler_runIO_closure","base_GHCziTopHandler_runNonIO_closure");
	if (!grep(/^$function$/,@skiplist)) {
		print SYMTAB "extern void* $function;\n";
	}
}

print SYMTAB "\n";

print SYMTAB "static symbolTableEntry g_symbolTable[] = {\n";

foreach $key (sort { $a <=> $b} keys %function_map) {
	print SYMTAB sprintf("\{0x%08x , NULL \},\n",$key);
}

print SYMTAB "};\n";

print SYMTAB "\n";

print SYMTAB "void initSymbolTable()\n";
print SYMTAB "{\n";

my $nCount=0;

foreach $key (sort { $a <=> $b} keys %function_map) {
	print SYMTAB sprintf("	g_symbolTable[$nCount].fn=&$function_map{$key};\n",$key);
	$nCount = $nCount+1;
}

print SYMTAB "}\n";

print SYMTAB "\n";

close(SYMTAB);
#print @export_function_list;

