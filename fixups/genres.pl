#!/usr/bin/perl

my @packages;
my $package;
my @files;
my $file;
my $filecount;
my $initres;
my $i=0;
my $way_suffix = "";
my $cpcreatecmd;
my $nobackup_directive;

if ( $ARGV[0] eq "dyn" ) {
	$way_suffix = "dyn_";
}

if ($^O eq "linux") {
	$cpcreatecmd = "install -D";
	$nobackup_directive = "";
} elsif ($^O eq "darwin") {
	$cpcreatecmd = "ditto";
	$nobackup_directive = "''";
}

system("mkdir -p fixups/resources/package.conf.d");
system("cp inplace/lib/package.conf.d/package.cache fixups/resources/package.conf.d");
system("cp fixups/builtin_rts.conf fixups/resources/package.conf.d");
system("cp inplace/lib/platformConstants.stage2 fixups/resources");

@packages = `cat fixups/packages`;
foreach $package(@packages){
	chomp($package);
	if (length($package) == 0) {
		last;
	}
	my $fullpackage = `find inplace/lib/package.conf.d -type f -name "${package}*.conf"`;
	chomp($fullpackage);
	system("cp $fullpackage fixups/resources/package.conf.d");
	$fullpackage = `find fixups/resources/package.conf.d -type f -name "${package}*.conf"`;
	chomp($fullpackage);
	system("sed -i ${nobackup_directive} -e 's/import-dirs: .*/import-dirs: ${package}/;s/library-dirs: .*/library-dirs: ${package}/;s/include-dirs: .*/include-dirs:/;s/haddock-interfaces: .*/haddock-interfaces:/' ${fullpackage}" );
	system("find libraries/${package}/dist-install/build -name \"*.${way_suffix}hi\" -exec ${cpcreatecmd} {} fixups/tmp/{} \\;");
	system("rm -r fixups/resources/${package}");
	system("mv fixups/tmp/libraries/${package}/dist-install/build fixups/resources/${package}");
}

system("inplace/bin/ghc-pkg recache --force -f fixups/resources/package.conf.d");
open (RESINC, ">fixups/resfiles.${way_suffix}inc");

@files = `find fixups/resources -type f -name "*" | sed 's/fixups\\/resources\\///g' | grep -v -e "\.conf\$" | LC_ALL="C" sort`;
$filecount=$#files+1;

print RESINC "\n";
print RESINC "#define FILENUM $filecount\n\n";
print RESINC "static resTableEntry g_resources[FILENUM];\n\n";

$initres = "void initResTable()\n{\n";

foreach $file(@files){
	chomp($file);
	open my $fh, '<', "fixups/resources/$file" or die($!);
	binmode($fh);
	my $buffer;
	my $len;

	my $varnamebase = $file;
	$varnamebase =~ s/[\/\.-]/_/g;
	my $filenamevarname = "str_" . $varnamebase . "_filename";
	my $resvarname = "res_" . $varnamebase . "_data";
	print RESINC "char* $filenamevarname = \"$file\";\n";
	print RESINC "char $resvarname\[\] = {\n";

	while(my $len = read($fh, $buffer, 32)) {
		print RESINC "\t'\\x";
		print RESINC join("','\\x", map {unpack('H*', $_)} split //, $buffer) . "',\n";
	}
	print RESINC "};\n\n";

	$initres .= "\tg_resources[$i].filename=$filenamevarname;\n";
	$initres .= "\tg_resources[$i].resource=$resvarname;\n";
	$initres .= "\tg_resources[$i].size=sizeof($resvarname);\n";
	$i++;

	close $fh;
}

$initres .= "}\n";

print RESINC "\n";
print RESINC $initres;

close (RESINC);

