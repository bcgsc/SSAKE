#!/usr/bin/perl
#RLW 2010

use strict;

if($#ARGV<2){
   die "Usage: $0 <fasta file 1> <fasta file 2> <library insert size> --- ** Both files must have the same number of records & arranged in the same order\n";
}

my $file1=$ARGV[0];
my $file2=$ARGV[1];

open(IN1,$file1)||die "Can't open $file1 for reading -- fatal.\n";
open(IN2,$file2)||die "Can't open $file2 for reading -- fatal.\n";
open(PAIR,">paired.fa") || die "can't open file for writing -- fatal.\n";
open(UNP,">unpaired.fa") || die "can't open file for writing -- fatal.\n";

my @all2 = <IN2>;

close IN2;
my $ct=0;
my $template="";
while(<IN1>){
   chomp;
   if(/\>(\S+)[ab12]$/){
     $template=$1;
   }else{
     my $rev = $ct-1;
     chomp($all2[$rev]);
     if($all2[$rev]=~/$template/){
        chomp($all2[$ct]);

        my $rd1="";
        my $rd2="";

        while($_=~/([ACGT]{30,})/g){
           $rd1=$1 if($1 ne "" && length($1)>length($rd1));
        }
        while($all2[$ct] =~ /([ACGT]{30,})/g){
           $rd2=$1 if ($1 ne "" && length($1)>length($rd2));
        }

        if($rd1 ne "" && $rd2 ne ""){
           print PAIR ">$template:$ARGV[2]\n$rd1:$rd2\n";
        }else{
           if($rd1 ne ""){
              print UNP ">$template";
              print UNP "1\n$rd1\n";
           }
           if($rd2 ne ""){
              print UNP ">$template";
              print UNP "2\n$rd2\n";
           }
        }
     }
   }
   $ct++;
}
close IN1;
close PAIR;
close UNP;

exit;
