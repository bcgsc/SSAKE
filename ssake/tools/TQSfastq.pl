#!/usr/bin/perl


#AUTHOR
#   Rene Warren (c) 2006-2013
#   rwarren at bcgsc.ca

#NAME
#   TQSfasta.pl Rene Warren, November 2010

#SYNOPSIS
#   Targeted, de novo, assembly of next generation sequence reads 

#DOCUMENTATION
#   TASR.readme distributed with this software @ www.bcgsc.ca
#   http://www.bcgsc.ca/platform/bioinfo/software/tasr
#   Warren RL, Sutton GG, Jones SJM, Holt RA.  2007.  Assembling millions of short DNA sequences using SSAKE.  Bioinformatics. 23(4):500-501
#   http://www.bcgsc.ca/platform/bioinfo/software/ssake
#   We hope this code is useful to you -- Please send comments & suggestions to rwarren * bcgsc.ca
#   If you use TASR or SSAKE, the code or ideas, please cite our work

#LICENSE
#   TASR Copyright (c) 2010-2013 Canada's Michael Smith Genome Science Centre.  All rights reserved.
#   SSAKE Copyright (c) 2006-2013 Canada's Michael Smith Genome Science Centre.  All rights reserved.

#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.

#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.



use strict;
#use Data::Dumper;
#require "getopts.pl";
use Getopt::Std;
use vars qw($opt_f $opt_q $opt_n $opt_e);
#&Getopts('f:q:n:e:');
getopts('f:q:n:e:');
my ($base_overlap,$min_overlap,$verbose,$MIN_READ_LENGTH,$SEQ_SLIDE,$min_base_ratio,$max_trim,$base_name,$max_count_trim,$min_tig_overlap,$space_restriction,$r_clip,$q_clip,$c_clip,$e_ascii)=(2,20,0,21,1,0.7,0,"",10,20,1,0,10,30,33);

my $version = "[v1.2]";
my $per;
my $MAX = 0;
my $MAX_TOP = 1500; # this is the very maximum anchoring edge sequence that will be searched (designed for use with -s to prevent long searches)
my $TRACK_COUNT = 1;
my $illuminaLengthCutoff = 300; ### means all sequence reads greater than this are not illumina sequences

#-------------------------------------------------

if(! $opt_f){
   print "Usage: $0 $version\n";
   print "-f  File of filenames corresponding to fasta/fastq files with reads to interrogate\n";
   print " -q Phred quality score threshold (bases less than -q XX will be clipped, default -q $q_clip, optional)\n";
   print " -n Number of consecutive -q $q_clip bases (default -n $c_clip, optional)\n";
   print "-e  ASCII offset (33=standard 64=illumina, default -n $e_ascii, optional)\n";
   die "-v  Runs in verbose mode (-v 1 = yes, default = no, optional)\n";
}

my $file = $opt_f;

$q_clip = $opt_q if($opt_q);
$c_clip = $opt_n if($opt_n);
$e_ascii = $opt_e if($opt_e);





#-------------------------------------------------
my $file_message = "";
my $ct_fof_line = 0;

if(! -e $file){
   $file_message = "Invalid file of filenames: $file -- fatal\n";
   exit;
}else{
   open(FOF,$file) || die "Can't open file of filenames $file for reading -- fatal.\n";
   while(<FOF>){
      chomp;
      $ct_fof_line++;
      $file_message = "Checking $_...";

      if(! -e $_){
         $file_message = "na\n*** File does not exist -- fatal (check the path/file and try again)\n";
         if(/^\>/){
         }elsif(/^\@/){
         }
         exit;
      }else{
      }
   }
   close FOF;
}



#-------------------------------------------------
### Allow user to specify a fasta file containing sequences to use as seeds, exclusively

my $file_ct = 0;

open(FOF,$file) || die "Can't open file of filenames $file for reading -- fatal\n";
while(<FOF>){
   chomp;
   $file_ct++;
   &readFastaFastq($_,$q_clip,$c_clip,$e_ascii,$file_ct,$ct_fof_line);
}
close FOF;

exit;




#-----------------
sub readFastaFastq{
   my ($file,$q_clip,$c_clip,$e_ascii,$file_ct,$ct_fof_line) = @_;
   my $ctrd = 0;
 
   my $head = "";
   my $prev = "";
   my $quad = 0;
   my ($seq,$qual) = ("","");

   open(IN,$file) || die "Can't open $file -- fatal\n";

   my $outfile = $file . "c" . $c_clip . "q" . $q_clip . "e" . $e_ascii . ".fa";  
   open(OUT,">$outfile");
   my $readinput_message = "\nProcessing file $file_ct/$ct_fof_line, $file...\n";
   print $readinput_message;
   
   LINE:
   while(<IN>){
      chomp;
      $quad++;
      #print "$quad\n";
      if($quad==1 || $quad==3){
         #print "1||3 $_\n";
         next LINE if($_ eq "+"); 
         $head = $1 if(/^\S{1}(\S+)/);
         my $rl = length($seq);
         if($prev ne "" && $head ne $prev && $rl>=$c_clip){
            my $qclipflag = 0;
            if($qual ne ""){$qclipflag = $r_clip;}
#####
            my $concat = "";
            my @quaarray = split(//,$qual);

            foreach my $q_ascii (@quaarray){
               my $phred = ord($q_ascii) - $e_ascii;
               if($phred < $q_clip){
                  $concat .= "x";
               }else{
                  $concat .= "-";
               }
            }

            if($concat=~ /(\-{$c_clip,$rl})/g){
               my $coo = 0;
               $coo = pos $concat;
               my $length=length($1);
               my $start = $coo-$length;
               $seq = substr($seq,$start,$length);
               print OUT ">$prev\n$seq\n";
               $qual = substr($qual,$start,$length);
            }


#----



            #print "loadSeq: $prev with $seq and $qual\n";
            #($set,$bin,$ctrd) = &loadSequence($set,$bin,$ctrd,$seq,$encoded,$prev,$qual,$qclipflag,$q_clip,$c_clip,$e_ascii) if($seq=~/^[ACGT]*$/);
            ($seq,$qual) = ("","");
            $quad=1;
         }
         $prev = $head;
      }elsif($quad==2){
         #print "SEQ $_\n";
         $seq = $_;
      }elsif($quad==4){
         #print "QUA $_\n";
         $qual = $_;
         $quad=0;
      }
   }
   if($prev ne ""){
#####
           my $rl=length($seq);
            my $concat = "";
            my @quaarray = split(//,$qual);

            foreach my $q_ascii (@quaarray){
               my $phred = ord($q_ascii) - $e_ascii;
               if($phred < $q_clip){
                  $concat .= "x";
               }else{                  $concat .= "-";
               }
            }

            if($concat=~ /(\-{$c_clip,$rl})/g){
               my $coo = 0;
               $coo = pos $concat;
               my $length=length($1);
               my $start = $coo-$length;
               $seq = substr($seq,$start,$length);
               print OUT ">$prev\n$seq\n";
               $qual = substr($qual,$start,$length);
            }

#####
   }

   close OUT;
   close IN;

   print "done.\n";
}



