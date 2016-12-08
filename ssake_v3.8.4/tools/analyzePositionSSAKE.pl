#!/usr/bin/perl
# Rene Warren, October 2010

use strict;
use Data::Dumper;

if($#ARGV<2){
   die "Usage: $0 <ssake base name> <contig number> <position of interest in seed (e.g. for a snp at the 15th base, just type 15)>\n";
}

my $file = $ARGV[0] . ".readposition";
my $tf = $ARGV[0] . ".contigs";
my $tig = $ARGV[1];
my $eventcoord = $ARGV[2];
my $coord = 0;

my $flag=0;
my $seed = "";
my $track;
my($ct_fwd,$ct_rev,$ct_tot)=(0,0,0,);
my @base;
my $tigseq="";

open(TIG,$tf) || die "Can't open $file for reading -- fatal.\n";
LINE:
while(<TIG>){
   chomp;
   if(/^\>contig(\d+)/){
      if($1 == $tig){
         $flag=1;
      }else{
         $flag=0;
      }
   }else{
      if($flag){
         @base=split(//,$_);
         $tigseq = $_;
         last LINE;
      }
   }
}
close TIG;

print "$tigseq\n";
$flag=0;

###FIRST PASS
open(IN,$file) || die "Can't open $file for reading -- fatal.\n";
while(<IN>){
   chomp;
   if(/^\>contig(\d+).*seed\:(\S+)/){
      if($1 == $tig){
         $flag=1;
         $seed=$2;
      }else{
         $flag=0;
      }

   }else{
      if($flag){
        my @a=split(/\,/);
        if($seed eq $a[0]){
           if($a[1] < $a[2]){
              $coord = $a[1] + $eventcoord - 1;
           }else{
              $coord = $a[2] + $eventcoord - 1;
           }
        }
      }
   }
}
close IN;

my $mem="";
###SECOND PASS

open(IN,$file) || die "Can't open $file for reading -- fatal.\n";
while(<IN>){
   chomp;
   if(/^\>contig(\d+).*seed\:(\S+)/){
      if($1 == $tig){
         $flag=1;
         $seed=$2;
         $mem=$_;
      }else{
         $flag=0;
      }
      
   }else{
      if($flag){
         my @a=split(/\,/);
         if($a[1]<$a[2] && $seed ne $a[0] && ($coord >=$a[1] && $coord<=$a[2])){
            $track->{'fwd'}{$a[0]}{'start'}=$a[1];
            $track->{'fwd'}{$a[0]}{'end'}=$a[2];
            $ct_fwd++;
            $ct_tot++;
         }elsif($a[1]>$a[2] && $seed ne $a[0] && ($coord >=$a[2] && $coord<=$a[1])){
            $track->{'rev'}{$a[0]}{'start'}=$a[2];
            $track->{'rev'}{$a[0]}{'end'}=$a[1];
            $ct_rev++;
            $ct_tot++;
         }
      }
   }
}
close IN;

my $tenup = substr($tigseq,$coord-11,10);
my $tendown = substr($tigseq,$coord,10);

print "There are $ct_tot reads overlapping the base [$tenup $base[$coord-1] $tendown] at position $coord ($ct_fwd on plus and $ct_rev on reverse) on $mem .\nDETAILS:\n";
print Dumper($track);
 
exit;
