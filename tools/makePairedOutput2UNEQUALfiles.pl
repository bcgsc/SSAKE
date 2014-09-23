#!/usr/bin/perl
#RLW 2010

use strict;

if($#ARGV<2){
   die "Usage: $0 <fasta file 1> <fasta file 2> <library insert size> --- files could have different # of records & arranged in different order but template ids must match\n";
}

my $file1=$ARGV[0];
my $file2=$ARGV[1];

open(IN1,$file1)||die "Can't open $file1 for reading -- fatal.\n";
open(IN2,$file2)||die "Can't open $file2 for reading -- fatal.\n";
open(PAIR,">paired.fa") || die "can't open file for writing -- fatal.\n";
open(UNP,">unpaired.fa") || die "can't open file for writing -- fatal.\n";

my $template2 = "";
my $t2;
while(<IN2>){
   chomp;
   if(/\>(\S+)[ab12]$/){
     $template2=$1;
   }else{
     chomp($_);
     $t2->{$template2}=$_;
   }
}
close IN2;


my $ct=0;
my $template="";
while(<IN1>){
   chomp;
   if(/\>(\S+)[ab12]$/){
     $template=$1;
   }else{
     my $rev = $ct-1;

     my $rd1="";
     my $rd2="";

     while($_=~/([ACGT]{30,})/g){
        $rd1=$1 if($1 ne "" && length($1)>length($rd1));
     }
     while($t2->{$template} =~ /([ACGT]{30,})/g){
        $rd2=$1 if ($1 ne "" && length($1)>length($rd2));
     }

     if($rd1 ne "" && $rd2 ne ""){
        print PAIR ">$template:$ARGV[2]\n$rd1:$rd2\n";
        $t2->{$template}="";
     }else{
        if($rd1 ne ""){
           print UNP ">$template";
           print UNP "1\n$rd1\n";
        }
        if($rd2 ne ""){
           print UNP ">$template";
           print UNP "2\n$rd2\n";
           $t2->{$template}="";
        }
      }
   }
   $ct++;
}

foreach my $s2(keys %$t2){
   if($t2->{$s2} ne ""){
      my $rd2="";
      while($t2->{$s2} =~ /([ACGT]{30,})/g){
        $rd2=$1 if ($1 ne "" && length($1)>length($rd2));
     }
     if($rd2 ne ""){
        print UNP ">$s2";
        print UNP "2\n$rd2\n";
     }
   }
}


close IN1;
close PAIR;
close UNP;

exit;
