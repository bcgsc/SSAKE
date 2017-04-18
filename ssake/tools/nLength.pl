#!/usr/bin/perl
#Rene Warren 2002-2008

my $min = 200;


if ($#ARGV<1){
   die "$0 <fasta file> <minimum length>\n";
}  

if($ARGV[1]){
   $min = $ARGV[1];
}

if(! -e $ARGV[0]){
   die "$ARGV[0] doesn't exist -- fatal.\n";
}


open (OUT, $ARGV[0]) || die "can't open $ARGV[0] for reading -- fatal.\n";
my ($seq,$prev) = ("","");
my $bins;

while (<OUT>){
   chomp;
   if (/\>(\S+)/){
      my $tig = $1; 
      if ($prev ne $tig && $prev ne ""){
         $seq =~ s/N//i;  ### remove Ns
         $bins->{$prev}=length($seq) if(length($seq) >= $min);
      }
      $seq='';
      $prev=$tig;
   }elsif(/^([ACGNTX]*)$/){
      $seq .= $_; 
   }    
}  
$seq =~ s/N//i;  ### remove Ns
$bins->{$prev}=length($seq) if(length($seq) >= $min);
close OUT;

for(my $cn;$cn<=90;$cn+=10){
   my $n = &calculateN($bins,$cn,$min);
   print "N$cn = $n bp ($cn% of the bases in your assembly are in sequences of length $n bp or larger.)\n";
}
exit;

#------------------------------------------------------------------------
sub calculateN{
    # Ny length = the length L such that y% of all base-pairs are contained in contigs of this length or larger

    my ($bins,$portion,$min) = @_; # reference to an array of contig sizes

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

