#!/usr/bin/env perl
#

use strict;
use warnings;
use Getopt::Long;

my($otuFile, $mFile, $outputFile, $label, $krona, $help, @fds, @new_tax);

GetOptions( "otuTable=s"  => \$otuFile, 
            "query=s"     => \$mFile,
            "outfile=s"   => \$outputFile,
            "krona=s"     => \$krona,
            "label=s"     => \$label,
            "h|help"      => \$help       ) or die "Unknown option.\n";

if($help){
  help();
}

#No help has been requested.  Sanity checks....
if(!$label){
  $label = "Unspecified";
}


#Check that the OTU table is defined and present.
if(!defined($otuFile)){
  die "The OTU table is not defined\n";
}elsif(!-e $otuFile){
  die "The OUT table, $otuFile, does not exist\n";
}

#Check that the query file is defined and present.
if(!defined($mFile)){
  die "The mapseq output file (query) file is not defined\n";
}elsif(!-e $mFile){
  die "The mapseq file, $mFile, does not exist\n";
}

#Check that the output file is defined.
if(!defined($outputFile)){
  die "The output file file is not defined\n";
}

#This gives us an idea about what the mapseq file format.

# mapseq v1.0 (Nov 13 2016)
#query	dbhit	bitscore	identity	matches	mismatches	gaps	query_start	query_end	dbhit_start	dbhit_end		SILVA
#contig--1213616/899-1048	AY664005.1.1223	141	0.98666668	148	1	1	0	150	170	319		D_0__Bacteria;D_1__Cyanobacteria;D_2__Cyanobacteria;D_3__SubsectionI;D_4__FamilyI;D_5__Synechococcus;D_6__uncultured Synechococcus sp.	
#contig--1126892/723-858	EU805193.1.1293	134	0.99264705	135	1	0	0	136	821	957		D_0__Bacteria	
#contig--243158/4-340	JQ611080.1.910	325	0.9910714	333	2	1	1	337	0	335		D_0__Archaea;D_1__Euryarchaeota;D_2__Thermoplasmata;D_3__Thermoplasmatales;D_4__Marine Group II;D_5__uncultured archaeon;D_6__uncultured archaeon	
#contig--1205795/1003-7	EU802400.1.1495	981	0.9939577	987	6	0	4	997	0	993		D_0__Bacteria;D_1__Proteobacteria;D_2__Gammaproteobacteria;D_3__Oceanospirillales;D_4__SAR86 clade	
#contig--1213616/623-456	EU802790.1.1266	141	0.94674557	160	6	3	1	168	146	314		D_0__Bacteria;D_1__Cyanobacteria;D_2__Cyanobacteria;D_3__SubsectionI;D_4__FamilyI	
#contig--2489731/672-501	LURT01000153.4866.6321	141	0.95061731	154	7	1	0	162	1295	1456		D_0__Archaea;D_1__Euryarchaeota;D_2__Thermoplasmata;D_3__Thermoplasmatales;D_4__Marine Group II	
#contig--151250/871-2	AACY020187844.576.1995	843	0.98504025	856	13	0	1	870	0	869		D_0__Archaea;D_1__Euryarchaeota;D_2__Thermoplasmata;D_3__Thermoplasmatales;D_4__Marine Group II	
#contig--1206060/3-639	EF574940.1.1450	608	0.99836063	609	1	0	0	610	840	1450		D_0__Bacteria;D_1__Cyanobacteria;D_2__Cyanobacteria;D_3__SubsectionI;D_4__FamilyI	

#Need to count up when we see a taxonomy string multiple times.
open(M, "<", $mFile) or die "Could not open mapseq results file $mFile:[$!]\n";
my $taxCount;
my $tax="";
while(<M>){
  if(/^#/){
    #Skip counts
    next;
  }else{
    #Pull out the fields that we need
    chomp;
    my @line = split(/\t/);
    if(!$line[13]){
      $tax = "Unclassified";
    } else {
    $tax= $line[13];
    until ($tax !~/\_\_$/) {
	@fds=split (/\;/, $tax);
	splice @fds, -1;
	$tax= join(";",@fds);
    }
    }
    $taxCount->{$tax}->{count}++;
  }
}
close(M) or die "Could not close filehandle on mapseq file\n.";



#Now we do not need to read the whole OTU table, just those that we have found
#in mapseq results.
#my $otuFile = "consensus_taxonomy_7_levels.otu";
open(O, "<", $otuFile) or die "Could not open OTU file $otuFile:[$!]\n";
while(<O>){
  chomp;
  #Simple two column table, OTU code and taxonomy string.
  my ($otu, $tax) = split(/\t/, $_, 2);
  #print "$otu | $tax";
  #Have we seen this tax string? Store the OTU
  if (defined($taxCount->{$tax})){
    $taxCount->{$tax}->{otu} = $otu;
  }
}
close(O) or die "Failed to close filehande on OTU table.\n";




#now check all taxonomy strings have an otu. If this fails,
#something is very wrong.
foreach my $tax (keys %{$taxCount}){
  if(!defined($taxCount->{$tax}->{otu})){
    die "Fatal, |$tax| has not got an OTU code assigned\n";
  }
}


open(R, ">", $outputFile ) or die "Could not open $outputFile:[$!]\n";
print R "# Constructed from biom file\n# OTU ID\t".$label."\ttaxonomy\n";
#Print the file out
foreach my $tax (sort{$a cmp $b} keys %{$taxCount}){
   print R $taxCount->{$tax}->{otu}."\t".sprintf("%.1f", $taxCount->{$tax}->{count})."\t".$tax."\n";
}
close(R) or die "Failed to close open filehandle on outputfile\n";

if($krona){
  open(K, ">", $krona ) or die "Could not open $krona:[$!]\n";
  foreach my $tax (sort{$a cmp $b} keys %{$taxCount}){
    my $taxMod = $tax;
    $taxMod =~ s/\D\_\d{1}\_\_//g;
    my @tax = split(/\;/, $taxMod);
    $taxMod = join("\t", @tax);
    print K $taxCount->{$tax}->{count}."\t".$taxMod."\n";
  }
  close(K) or die "Failed to close open filehandle on outputfile\n";
}



sub help {

print<<EOF;

$0 --otuTable onsensus_taxonomy_7_levels.otu --query ERR1234567.outfile --outfile ERR1234567.tsv

Options
-------
  otuTable : <string>, the OTU table produced for the taxonomies found in the reference databases that was used with MAPseq.
  query    : <string>, the output from the MAPseq that assigns a taxonomy to a sequence.
  outfile  : <string>, the file storing the tsv file.
  krona    : <string>, output file name for the Krona text. (Optional).
  label    : <string>, lable to add to the top of the outfile OTU table.
  h|help   : prints this message.

EOF

exit 1;
}
