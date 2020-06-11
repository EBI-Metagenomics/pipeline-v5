#!/usr/bin/env perl
# 
# esl-ssplit.pl: split up an input sequence file into smaller files.
# EPN, Fri Jan 17 14:38:43 2014
# 
# This script uses BioEasel's SqFile module and will create a .ssi
# index file of the input fasta file and then delete it. It would be
# possible to modify the script to not require an .ssi file (and
# instead do 2 passes through the input file) but it would require
# adding code to the SqFile module for a probably negligible
# improvement in speed.

use strict;
use Getopt::Long;
use Bio::Easel::SqFile;
use Bio::Easel::Random;

my $in_sqfile    = "";    # name of input file to split up, 1st cmd line arg
my $do_nseq      = 1;     # true by default, output files should have a specified number of seqs each
my $nseq_per     = 0;     # number of seqs for each output file
my $do_nfiles    = 0;     # set to 1 if -n, output a specified number of files 
my $nfiles       = 0;     # number of output files, irrelevant unless -n is used
my $do_nres      = 0;     # set to 1 if -r, output files so they have roughly same # of residues
my $do_randomize = 0;     # set to 1 if -z, output in random order
my $do_verbose   = 0;     # set to 1 if -v, output some extra info to stdout
my $do_dirty     = 0;     # 'dirty' mode, don't clean up (e.g. .ssi file).
my $outfile_root = undef; # root for name of output file, default is $in_sqfile, changed if -oroot used
my $outfile_dir  = undef; # dir for output files, pwd unless -odir is used   
my $seed         = 1801;  # seed for RNG

&GetOptions( "oroot=s" => \$outfile_root, 
             "odir=s"  => \$outfile_dir,
             "n"       => \$do_nfiles, 
             "r"       => \$do_nres,
             "z"       => \$do_randomize, 
             "s=s"     => \$seed,
             "v"       => \$do_verbose, 
             "d"       => \$do_dirty);

my $usage;
$usage  = "# esl-ssplit.pl :: split up an input sequence file into smaller files\n";
$usage .= "# Bio-Easel 0.11 (December 2019)\n";
$usage .= "# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n";
$usage .= "\n";
$usage .= "Usage: esl-ssplit.pl [OPTIONS] <seqfile to split> <# seqs for each new file (or # new files if -n)>\n";
$usage .= "\tOPTIONS:\n";
$usage .= "\t\t-n        : 2nd cmd line arg specifies number of output files, not sequences per output file\n";
$usage .= "\t\t-r        : requires -n, split sequences so roughly same number of residues are in each output file\n";
$usage .= "\t\t-z        : requires -r and -n, randomize sequence order when outputting\n";
$usage .= "\t\t-s <n>    : requires -z, -r and -n, seed random number generator with <n> [1801]\n";
$usage .= "\t\t-v        : be verbose with output to stdout, default is to output nothing to stdout\n";
$usage .= "\t\t-d        : dirty mode: leave temporary files on disk (e.g. .ssi index file)\n";
$usage .= "\t\t-oroot <s>: name output files <s> with integer suffix, default is to use input seq file name\n";
$usage .= "\t\t-odir  <s>: output files go into dir <s>, default is pwd\n";
$usage .= "\n";
$usage .= "\tEXAMPLES:\n";
$usage .= "\t\t'esl-ssplit.pl input.fa 10':\n";
$usage .= "\t\t\tsplit input.fa into M files with 10 sequences; creates files input.fa.1 .. input.fa.N\n\n";
$usage .= "\t\t'esl-ssplit.pl -n input.fa 10':\n";
$usage .= "\t\t\tsplit input.fa into 10 files with N sequences; creates files input.fa.1 .. input.fa.10\n\n";
$usage .= "\t\t'esl-ssplit.pl -n -r input.fa 10':\n";
$usage .= "\t\t\tsplit input.fa into 10 files with roughly same number of residues/nucleotides\n\t\t\tper file; creates files input.fa.1 .. input.fa.10\n\n";
$usage .= "\t\t'esl-ssplit.pl -n -r -z input.fa 10':\n";
$usage .= "\t\t\t*randomize order of sequences* and split input.fa into 10 files with roughly same\n\t\t\tnumber of residues/nucleotides per file; creates files: input.fa.1 .. input.fa.10\n\n";
$usage .= "\tNOTE: unless -z is used, sequences will be output in the order they appear in the input file\n";

if(scalar(@ARGV) != 2) { die $usage; }
($in_sqfile, $nseq_per) = @ARGV;

# validate input args
if(! -e $in_sqfile) { die "ERROR $in_sqfile does not exist"; }
if($nseq_per <= 0)  { die "ERROR \# seqs for each new file must be positive int (got $nseq_per)"; }

# add '/' to $outfile_dir if nec
if((defined $outfile_dir) && ($outfile_dir !~ m/\/$/)) { $outfile_dir .= "/"; }
 
# make sure -n was used if -r used
if($do_nres && (! $do_nfiles)) { die "ERROR -r only works in combination with -n"; }

# make sure -r was used if -z used
if($do_randomize && (! $do_nres)) { die "ERROR -z only works in combination with -r"; }

# if -z was used make sure $nseq_per (which will become $nfiles) is at most 500
if($do_randomize && ($nseq_per > 500)) { die "ERROR, with -z, 2nd cmdline arg (# new files) must be <= 500"; }

# set output root if not set with -oroot
if(! defined $outfile_root) { 
  $outfile_root = $in_sqfile; 
}
if(defined $outfile_dir) { 
  $outfile_root =~ s/^.+\///; # remove path of outfile_root
  $outfile_root = $outfile_dir . $outfile_root;
}

# determine if we should remove .ssi file we're about to create at end of script, we do remove unless in dirty mode or .ssi file already exists.
my $cleanup_ssi = 1;
if($do_dirty || (-e $in_sqfile . ".ssi")) { $cleanup_ssi = 0; }

# initialize
my $fctr = 1;
my $sctr = 0;
my $cur_file = $outfile_root . "." . $fctr;
if($do_nfiles) { 
  $nfiles = $nseq_per; 
  $nseq_per = 0; 
  if($nfiles <= 1) { die "ERROR with -n, number of files must be > 1"; }
}

# open file 
my $sqfile = Bio::Easel::SqFile->new({ fileLocation => $in_sqfile });

# determine number of sequences or residues to output to each file, if nec
my $tot_nseq = $sqfile->nseq_ssi(); # this will create the .ssi index if necessary
my $tot_nres = 0; # we only need to know this if -r set at cmdline ($do_nres will be TRUE)
my $nres_per = 0; # we only need to know this if -r set at cmdline ($do_nres will be TRUE)
if($do_nfiles) { 
  $nseq_per = int($tot_nseq / $nfiles); 
  if($tot_nseq % $nfiles != 0) { $nseq_per++; }
}
if($do_nres) { 
  $tot_nres = $sqfile->nres_ssi();
  if($tot_nres == 0) { die "ERROR 0 residues read in sequence file."; }
  $nres_per = int($tot_nres / $nfiles);
  if($tot_nres % $nfiles != 0) { $nres_per++; }
}

# if $do_randomize, create RNG
my $rng = undef;
if($do_randomize) { 
  $rng = Bio::Easel::Random->new({ seed => $seed });
}

# do the work, fetch and output sequences to new files
my $nseq_remaining = $tot_nseq;
my $cur_nseq = 0;
my $cur_nres = 0;
if(! $do_nres) { 
  # simple case: fetch and output $nseq_per seqs at a time
  while($nseq_remaining > 0) { 
    my $cur_file = $outfile_root. "." . $fctr;
    $fctr++;
    $cur_nseq = ($nseq_remaining < $nseq_per) ? $nseq_remaining : $nseq_per;
    $sqfile->fetch_consecutive_seqs($cur_nseq, "", -1, $cur_file);
    $nseq_remaining -= $cur_nseq;
    if($do_verbose) { printf("$cur_file finished (%d seqs)\n", $cur_nseq); }
  }
}
else { 
  # less simple case: $do_nres is TRUE, we need to keep track of
  # sequence lengths output do a check to see if we can get the length
  # of all sequences, if not it's probably because there are some that
  # are length 0, which causes problems with the indexing...
  #
  # if $do_randomize is also TRUE we need to open up all output file
  # handles at once, we'll randomly choose which one to print each
  # sequence to. We need to keep track of total length of all
  # sequences output to each file so we know when to close them. Once
  # a file is closed, we won't choose to write to it anymore, using
  # the @map_A array as follows:
  #
  # We define an array @map_A with an element for each of the $nfiles
  # output files. For each sequence, we randomly choose a number
  # between 0 and $nfiles-1 to pick which output file to write the
  # sequence to. Initially $map_A[$i] == $i, but when if we close file
  # $i we set $map_A[$i] to $map_A[$nremaining-1], then choose a
  # random int between 0 and $nremaining-1. This gets us a random
  # sample without replacement.
  my @map_A = ();
  my @nres_per_out_A = ();
  my $nres_tot_out = 0;  # total number of sequences output thus far
  my @nseq_per_out_A = ();
  my @out_filename_A = (); # array of file names
  my @out_FH_A = ();
  my $nopen = 0; # number of files that are still open
  my $checkpoint_fraction_step = 0.05; # if($do_randomize) we will output update each time this fraction of total sequence has been output
  my $checkpoint_fraction = $checkpoint_fraction_step;
  my $checkpoint_nres = $checkpoint_fraction * $tot_nres;
  my $fidx; # file index of current file in @out_filename_A and file handle in @out_FH_A
  my $nres_this_seq = 0; # number of residues in current file
  
  # variables only used if $do_randomize
  my $ridx; # randomly selected index in @map_A for current sequence
  my $FH; # pointer to current file handle to print to

  for($fidx = 0; $fidx < $nfiles; $fidx++) { $map_A[$fidx] = $fidx; }
  for($fidx = 0; $fidx < $nfiles; $fidx++) { $nres_per_out_A[$fidx] = 0; }
  for($fidx = 0; $fidx < $nfiles; $fidx++) { $nseq_per_out_A[$fidx] = 0; }
  for($fidx = 0; $fidx < $nfiles; $fidx++) { $out_filename_A[$fidx] = $outfile_root. "." . ($fidx+1); } 

  # if $do_randomize, open up all output file handles, else open only the first
  if($do_randomize) { 
    for($fidx = 0; $fidx < $nfiles; $fidx++) { 
      open($out_FH_A[$fidx], ">", $out_filename_A[$fidx]) || die "ERROR, unable to open file $out_filename_A[$fidx] for writing";
    }
    $nopen = $nfiles; # will be decremented as we close files
  }
  else { 
    $fidx = 0;
    open(OUT, ">", $out_filename_A[$fidx]) || die "ERROR, unable to open file $out_filename_A[$fidx] for writing";
    $nopen = 1; # will not be changed
  }

  while($nseq_remaining > 0) { 

    # if $do_randomize, choose the file to output to
    if($do_randomize) { 
      $ridx = $rng->roll($nopen);
      $fidx = $map_A[$ridx];
      $FH = $out_FH_A[$fidx];
    }
    # else $fidx is not changed, only changed when we open a new file below

    # fetch sequence and output it to the appropriate file handle
    my $seqstring = $sqfile->fetch_consecutive_seqs(1, "", -1, undef);
    # $seqstring is in this format: "><seqname><description of any length>\n<actual sequence>\n"
    # with exactly two newlines, we want to know the length of actual sequence
    chomp $seqstring;
    if($seqstring =~ m/\n/g) { 
      $nres_this_seq = length($seqstring) - pos($seqstring);
      if($do_randomize) { 
        print $FH $seqstring . "\n"; # appending \n is nec b/c we chomped it above
      }
      else { 
        print OUT $seqstring . "\n"; # appending \n is nec b/c we chomped it above
      }
    }
    else { die "ERROR error reading sequence number $sctr\n"; }
    $nseq_remaining--;
    
    # update counts of sequences and residues for the file we just printed to
    $nres_per_out_A[$fidx] += $nres_this_seq;
    $nseq_per_out_A[$fidx]++;
    $nres_tot_out += $nres_this_seq;

    # if $do_randomize and we've reached our checkpoint output update
    if($do_verbose && $do_randomize && ($nres_tot_out > $checkpoint_nres)) { 
      my $nfiles_above_fract = 0;
      for($fidx = 0; $fidx < $nfiles; $fidx++) { 
        if($nres_per_out_A[$fidx] > ($checkpoint_fraction * $nres_per)) { $nfiles_above_fract++; }
      }
      printf("%.2f fraction of nucleotides output, %3d of %3d files are %.2f fraction complete.\n", $checkpoint_fraction, $nfiles_above_fract, $nfiles, $checkpoint_fraction);
      $checkpoint_fraction += $checkpoint_fraction_step;
      $checkpoint_nres = $checkpoint_fraction * $tot_nres;
    }

    # check if we need to close this file now, if so close it and open a new one (if nec)
    if(($nres_per_out_A[$fidx] >= $nres_per) || ($nseq_remaining == 0)) { 
      if($do_randomize) { 
        if(($nopen > 1) || ($nseq_remaining == 0)) { 
          # don't close the final file unless we have zero sequences left
          close($out_FH_A[$fidx]);
          if($do_verbose) { printf("$out_filename_A[$fidx] finished (%d seqs, %d residues)\n", $nseq_per_out_A[$fidx], $nres_per_out_A[$fidx]); }
          # update map_A so we can no longer choose the file handle we just closed
          if($ridx != ($nopen-1)) { # edge case
            $map_A[$ridx] = $map_A[($nopen-1)];
          }
          $nopen--;
        }
      }
      else { # $do_randomize is FALSE, need to open next file
        close OUT;
        if($do_verbose) { printf("$out_filename_A[$fidx] finished (%d seqs, %d residues)\n", $nseq_per_out_A[$fidx], $nres_per_out_A[$fidx]); }
        if($nseq_remaining > 0) { 
          $fidx++;
          open(OUT, ">", $out_filename_A[$fidx]) || die "ERROR, unable to open file $out_filename_A[$fidx] for writing";
        }
      }
    }
  }

  # go through and close any files that are still open
  if($do_randomize) { 
    for($fidx = 0; $fidx < $nfiles; $fidx++) { 
      if(! (tell($out_FH_A[$fidx]) == -1)) { 
        # file still open, close it
        close($out_FH_A[$fidx]);
        if($do_verbose) { printf("$out_filename_A[$fidx] finished (%d seqs, %d residues)\n", $nseq_per_out_A[$fidx], $nres_per_out_A[$fidx]); }
      }
    }
  }
}

# close sequence file and remove the ssi file if nec
$sqfile->close_sqfile;
if($cleanup_ssi) { 
  if(-e "$in_sqfile.ssi") { unlink "$in_sqfile.ssi"; }
}

exit 0;
