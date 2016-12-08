#!/usr/bin/perl
#Rene Warren 2008
#rwarren at bcgsc dot ca

use strict;


if($#ARGV<1){
   die "Usage: $0 <directory where all _seq and _prb are> <# Illumina cycles (read length)>\n";
}

my @seq = <$ARGV[0]/*seq.txt>;
my @qua = <$ARGV[0]/*prb.txt>;
my $rl = $ARGV[1];

#---------------------
foreach my $s (@seq){
   my $new = $s . ".new";
   open(IN,$s);
   open(OUT, ">$new");

   while(<IN>){
      chomp;
      my @a=split(/\t+/);
      my ($s1,$s2)= ($1,$2) if ($a[4]=~/(\D{$rl})(\D{$rl})/);
      print OUT "$a[0]\t$a[1]\t$a[2]\t$a[3]a\t$s1\n$a[0]\t$a[1]\t$a[2]\t$a[3]b\t$s2\n";
   }
   close IN;
   close OUT;
}

#---------------------
foreach my $q (@qua){
   my $new = $q . ".new";
   open(IN, $q);
   open(OUT, ">$new");

   my $rl_m1 = $rl - 1;
   my $rl_d2_m1 = (2 * $rl) - 1;

   my @s1=(0..$rl_m1);
   my @s2=($rl..$rl_d2_m1);

   while (<IN>){
      chomp;

      my @arr=split(/\t/,$_);


      my $flag=0;
      foreach my $n (@s1){
         print OUT "\t" if ($flag);
         print OUT "$arr[$n]";
         $flag++; 
      }
      print OUT "\n";
      $flag=0;
      foreach my $n (@s2){
         print OUT "\t" if ($flag);
         print OUT "$arr[$n]";
         $flag++;
      }
      print OUT "\n";
   }
   close IN;
   close OUT;
}

