#!/usr/bin/perl
#Rene Warren -April 2008
#rwarren at gmail dot com

use strict;


if($#ARGV<0){
   die "Usage: $0 <file with paired sequences arranged consecutively>\n";
}

my $file = $ARGV[0];

open(IN,$file) || die "Can't open $file -- fatal\n";

my $seq = {};
my $template;
my $read;
my $ptemplate = "";

open(PAIR, ">paired.fa");
open(UNPAIR, ">unpaired.fa");

while(<IN>){
   chomp;

   if(/^(\>\S+)([ab])$/i){

      $template = $1;
      $read = $1 . $2;

      print "$ptemplate $template .. $read\n";

      if($template ne $ptemplate && $ptemplate ne ""){

         my $rd_a = $ptemplate . "a";
         my $rd_b = $ptemplate . "b";

         if(defined $seq->{$ptemplate}{$rd_a} && defined $seq->{$ptemplate}{$rd_b}){
            print PAIR "$ptemplate\n$seq->{$ptemplate}{$rd_a}:$seq->{$ptemplate}{$rd_b}\n";
         }else{
            print UNPAIR "$ptemplate\n$seq->{$ptemplate}{$rd_a}\n" if (defined $seq->{$ptemplate}{$rd_a});
            print UNPAIR "$ptemplate\n$seq->{$ptemplate}{$rd_b}\n" if (defined $seq->{$ptemplate}{$rd_b});
         }
         $seq = {};
         

      }

   }elsif(/(\S+)/){
      
      $seq->{$template}{$read}=$1;
      $ptemplate = $template;
#      print "\t$1\n";

   }
}
close IN;
close PAIR;
close UNPAIR;


exit;
