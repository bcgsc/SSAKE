#!/home/martink/bin/perl
##Rene Warren 2002-2014

use Statistics::Descriptive;
use strict;
my $verbose = 0;
my $min = 200;

if ($#ARGV<0){
   die "$0 <.fa fasta file> <minimum sequence size to consider>\n";
}

$min = $ARGV[1] if($ARGV[1]);
$verbose = $ARGV[2] if ($ARGV[2]);

open (OUT, $ARGV[0]) || die "Can't open $ARGV[0].\n";;

my ($seq,$tig, $contig,$prev,$tiglength,@alllength);
my $ct=0;
my $ck=0;
while (<OUT>){
   chomp;
   if (/\>(\S+)/){
      $tig=$1;
      $ck++;
      #print "$ck..\n";      
      if($tig ne $prev && $seq ne ''){
         $ct++;
	 print "$ct. $prev\n" if ($verbose);
         $seq =~ s/N//i;  ### remove Ns
         if(length($seq) >= $min){
            $contig->{$prev}=uc($seq);
            $tiglength->{$prev}=length($seq);
            push @alllength, length($seq) if(length($seq) > 0);
         }
      }
      $seq='';
      $prev=$tig;

   }elsif(/^(\S+)$/i){
      #print "$1\n";
      $seq.= $1;
   }
}
$ct++;
print "$ct. $prev\n" if ($verbose);
$seq =~ s/N//i;  ### remove Ns
if(length($seq) >= $min){
   push @alllength, length($seq) if(length($seq) > 0);
   $contig->{$prev}=uc($seq);
   $tiglength->{$prev}=length($seq);
}
close OUT;


my ($cnt_tig, $cnt_gc,$cnt_at, $cnt_consensus,$max)=(0,0,0,0,0);
my (@gc,@at);
my $info = "";

my ($range, $bases);

print "SEQUENCE,CONSENSUS LENGTH, %GC\n" if ($verbose);

foreach my $ct (sort keys %$contig){

   print "*$ct..$tiglength->{$ct}*\n" if ($verbose);

   $cnt_tig++;
   my ($consensus, $base)=countBase($contig->{$ct});
   $max = $consensus if ($consensus>$max);
   my $tig_count_gc=$base->[2]+$base->[3];
   my $tig_count_at=$base->[0]+$base->[1];

   my $tig_percent_gc=$tig_count_gc/$consensus*100 if ($consensus >0);
   my $tig_percent_at=$tig_count_at/$consensus*100 if ($consensus >0);

   push @gc, $tig_percent_gc;
   push @at, $tig_percent_at;

   #$cnt_gc+=$tig_count_gc;
   #$cnt_at+=$tig_count_at;

   #$cnt_consensus+=$consensus;
   #$tig_percent_gc=$format->format_number($tig_percent_gc,2,2);
   #$tig_percent_at=$format->format_number($tig_percent_at,2,2);

   ###range
   if ($consensus<1000){
      my $tmp = "$min-1000";
      $range->{$tmp}++;
      $bases->{$tmp}+=$consensus;
   }elsif($consensus<10000 && $consensus>=1000){
      $range->{'1000-10000'}++;
      $bases->{'1000-10000'}+=$consensus;
   }elsif($consensus<100000 && $consensus>=10000){
      $range->{'10000-100000'}++;
      $bases->{'10000-100000'}+=$consensus;
   }elsif($consensus>=100000){
      $range->{'>=100000'}++;
      $bases->{'>=100000'}+=$consensus;
      if($consensus>=1000000){
         #print "$ct**$consensus**\n";
         $range->{'>=1Mb'}++;
         $bases->{'>=1Mb'}+=$consensus;
      }
   }

   print "\t$ct, $consensus, $tig_percent_gc\n" if ($verbose);

}

print "=" x 80, "\n";
print "Reporting on sequences >= $min nt\n";
print "=" x 80, "\n";
$info = "SEQUENCE";
my $desc = "(nt)";
printStat($info,\@alllength,$desc);

my $bins = $tiglength;
my $n20 = &calculateN($bins,20);
my $n50 = &calculateN($bins,50);
my $n80 = &calculateN($bins,80);
print "N20,$n20\nN50,$n50\nN80,$n80\n";
print "Size Range,#bases,#sequences\n";
foreach my $val(keys %$range){
   print "$val,$bases->{$val},$range->{$val}\n";
}

print "-" x 80, "\n";
$info = "G+C content ";
$desc = "(GC%%)";
printStat($info,\@gc,$desc);
print "-" x 80, "\n";

#print "-" x 80, "\n";
#$info = "A+T content ";
$desc = "(AT%%)";
#printStat($info,\@at,$desc);


exit;

#-----------------------------
sub printStat{

   my ($info,$tmp,$desc) = @_;
   my @all = @$tmp;

   my $stat=Statistics::Descriptive::Full->new();
   my $s;

   $stat->add_data(@all);
   $s->{'mean'}=$stat->mean();
   $s->{'max'}=$stat->max();
   $s->{'min'}=$stat->min();
   $s->{'count'}=$stat->count();
   $s->{'stdev'}=$stat->standard_deviation();
   $s->{'variance'} = $stat->variance();
   $s->{'trimmed_mean'} = $stat->trimmed_mean(.25);
   $s->{'median'} = $stat->median();
   $s->{'sum'} = $stat->sum();
   print "$info STATS\n";
   print "-" x 80, "\n";
   printf "Mean $desc,%.2f\nMax $desc,%i\nMin $desc,%i\nn,%i\nStdev $desc,%.2f\nVariance $desc,%.2f\nTrimmedMean $desc,%.2f\nMedian $desc,%.2f\nSum $desc,%.2f\n", ($s->{'mean'},$s->{'max'},$s->{'min'},$s->{'count'}, $s->{'stdev'},$s->{'variance'},$s->{'trimmed_mean'}, $s->{'median'}, $s->{'sum'}); 
}


#------------------------------------------------------------------------
sub calculateN{
    # Ny length = the length L such that y% of all base-pairs are contained in contigs of this length or larger

    my ($bins,$portion) = @_; # reference to an array of contig sizes

    my ($n,$total_size, $contig_number, $tig_size); # total_size = total bases in assembly

    # get total size
    foreach my $tig (sort {$bins->{$a}<=>$bins->{$b}} keys %$bins){
        $total_size += $bins->{$tig};
    }

    my $size_subset = $total_size * ($portion / 100);

    my $running_count=0;

    # look for largest size contig containing size_subset% of bases

    foreach my $tig (sort {$bins->{$b}<=>$bins->{$a}} keys %$bins){
        $tig_size=$bins->{$tig};

        $running_count+=$tig_size;
        if ($running_count >= $size_subset){
            $n=$tig_size;
            last;
        }
    }

    return $n;
}#end sub

#---------------------------------------------------
sub countBase{

   #simply counts number of each bases in a sequence and consensus if sequence
   #bases are in caps
   my $dna_sequence=shift;

   my @base;
   my $consensus;
   my ($counta, $countt, $countg, $countc);

   while ($dna_sequence =~ /(a|c|g|t|x|k|y|w|r|n|m|s)/gi){
        $consensus++ if ($1 eq 'A' or $1 eq 'T' or $1 eq 'G' or $1 eq 'C');

        my $single_base=lc($1);

        $counta++ if ($single_base eq 'a');
        $countt++ if ($single_base eq 't');
        $countg++ if ($single_base eq 'g');
        $countc++ if ($single_base eq 'c');
   }

  @base=($counta,$countt,$countg,$countc);

  return $consensus, \@base;
}

