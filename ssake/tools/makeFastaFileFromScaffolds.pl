#!/usr/bin/perl
# Rene Warren, November 2007
# Uses SSAKE Scaffold instructions (.scaffolds) to organize contigs (fasta sequence) within a scaffold.

# e.g.  scaffold1,7484,f127Z7068k12r0.58m42_f3090z62k7r0.14m76_f1473z354

# Means: forward (f) contig#127 was the seed (Z) with length 7068 bp has 12 links [spanning pairs] (k) with a link ratio of 0.58 (r) [means that second-best contig pair considered for pairing contig#127 had 0.58 * 12 = 7 links] and a potential gap size of 42 bp (m) with forward contig#3090, size 62 bp ... 

#   LICENSE

#   SSAKE and makeFastaFileFromSC.pl Copyright (c) 2006-2007 Canada's Michael Smith Genome Science Centre.  All rights reserved.

#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.

#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.



if ($#ARGV < 0){
   die "Usage: $0 <.scaffolds csv file>\n";
}

if(! -e $ARGV[0]){
   die "$ARGV[0] doesn't exists -- fatal.\n";
}


my $core;
if($ARGV[0]=~ /(.*)\.scaffolds/){
  $core = $1;
}

my $file = $core . ".contigs";
my $scaffold_fasta = $ARGV[0] . ".fa";

#####
my $fh;
my $prev;
my $seq;

open(FA,$file);
while(<FA>){
   chomp;
   if (/\>(contig\d+)/){
      my $head=$1;
      $seq =~ s/[BDEFHIJKLMOPQRSUVWXYZ]/N/g;
      if($prev ne $head && $prev ne "NA"){
         $fh->{$prev} = $seq;
#print "$prev..$seq\n";
      }
      $prev = $head;
      $seq='';
   }elsif(/^(\S+)$/){
      $seq.=uc($1);
   }
}
$fh->{$prev} = $seq;
close FA;



#####

open(IN,$ARGV[0]);
open(OUT,">$scaffold_fasta") || die "can't write to $scaffold_fasta -- fatal\n";
my $tot=0;
my $ct=0;
my $sct=0;
while(<IN>){
   chomp;   
   my $sc="";;
   my @a = split(/\,/);
   my @tig;
   
   if($a[2]=~/\_/){
      @tig = split(/\_/,$a[2]);
   }else{
      push @tig, $a[2];
   }

   $sct++;
   my $tigsum=0;
   print OUT ">$_\n";
   foreach my $t (@tig){
      $ct++;
    
      if($t=~/([fr])(\d+)z(\d+)(\S+)?/i){

         my $orient = $1;
         my $tnum=$2;
         my $head = $orient . $tnum;
         my $search = "contig" . $tnum;
         my $other = $4;
         $tot+= $3;
         $tigsum +=$3;
   
         my $gap = "NA"; 
         my $gapseq = "";
         $gap = $1 if($other=~/m(\-?\d+)/);
 
         #print "\tSC $a[0] - TIG $ct.  pattern: $t search: $search totalTigSize: $tot Orientation: $orient Gap/Overlap: $gap\n";

         my $seq = $fh->{$search};
         #print "$seq..F\n";
         $seq = reverseComplement($seq) if($orient eq "r");
         #$seq = lc($seq) if($orient eq "r");
         #print "$seq..R\n" if($orient eq "r");

         $gapseq = "N" x $gap if($gap > 0);
         $gapseq = "n" if($gap ne "NA" && $gap <= 0 );
         $seq .= $gapseq;

         print OUT "$seq";         
                
      }#tig regex
   
   }#each tig
   print OUT "\n";
   #print "\nCummulative Sum: $tigsum\n";
}

close IN;
close OUT;

exit;

#-----------------------
sub reverseComplement {
        $_ = shift;
        $_ = uc();
        tr/ATGC/TACG/;
        return (reverse());
}

