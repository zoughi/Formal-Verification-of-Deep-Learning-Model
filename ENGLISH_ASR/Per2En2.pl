#!/usr/bin/perl 
use strict;
our $OOV1 = "$ARGV[2]/data_ok/local/data/oov.txt";
open (OOV2, ">>$OOV1") || die "cannot open $OOV1"; 

#our $a = "/home/zoughi/full-1400-03-11.txt";
our $a = "$ARGV[1]/full.txt";
our $b = "$ARGV[0]1.trans";
our $combined = "$ARGV[0]2.trans";
open (INDUMP, "<$a")  || die "cannot open $a";  
our %companyid=();
while (<INDUMP>){ 
       my $in_line1 = $_; # using my in loop assures clean variable - no hanovers from previous loops
       chomp($in_line1); 
       my @data1=split(/\t| /,$in_line1);
       $companyid{$data1[0]} = $data1[1];
}
close INDUMP;

open (INGROUP, "<$b") || die "cannot open $b";;
open (DUMP, ">$combined") || die "cannot open $combined"; 
while (<INGROUP>){ 
       my $in_line = $_; # using my in loop assures clean variable - no hanovers from previous loops
       chomp($in_line);
       #my @inline = split(/‌| |~|,|,|؛|«|»|=|\/| |\?|\?|!|!|\)|\(|-|\t||,|\?|“|”|،|"|\r|\؟|؟/,$in_line);
       #my @inline = split(/‌| |~|,|,|؛|«|»|$|=|\/| |\?|\?|!|!|\)|\(|-|\t||,|\?|â$
       my @inline = split(/​​|\t|​|"| |  |  |  | |~| |,| |؛|:|:|:|«|»|=|\?|“|”|،|!|\)|\(|\r|\؟|\//,$in_line);
       print DUMP "$inline[0] ";
	     my $tmp;
       our $j=0;
       if ($inline[1]){$j=1;}
       else{$j=2;}
       #print "$j";
       for(my $i = $j; $i <= $#inline; $i++){
          my $item=$inline[$i];
#	  $item =~ tr/a-z/A-Z/;
          $item =~ s/ی/ي/g;
	  $item =~ s/‌/ /g;
#          $item =~ s/ي/ی/g;
          $item =~ s/ / /g;
          $item =~ s/\.//g;
          $item =~ s/ٔ//g;
          $item =~ s/  / /g;

          $item =~ s/   / /g;
          $item =~ s/ / /g;
          $item =~ s/    / /g;

          $item =~ s/و/و/g;
          $item =~ s/ک/ک/g;

          if ($inline[$i]){
              if (($companyid{$item})) {$tmp="$tmp"."$companyid{$item} ";}
              else{
#                 $item =~ s/ی/ي/g;
          $item =~ s/ي/ی/g;

		 $item =~ tr/A-Z/a-z/;
       		      if ($companyid{$item}) {$tmp="$tmp"."$companyid{$item} ";}
       	        else{print OOV2 "$item\n"; $tmp="$tmp"."$item ";}
              }
          }#endif
	    }#endfor
	print DUMP "$tmp\n";
} #endwhile
close(INGROUP);
close DUMP;
close OOV2;
#              for(my $i = $j; $i <= $#inline; $i++){
#                 my $item=$inline[$i];
#                 $item =~ s/  / /g;
#                 $item =~ s/   / /g;
#                 $item =~ s/ / /g;
#                 $item =~ s/    / /g;
#                 $item =~ s/و/و/g;
#                 $item =~ s/ک/ک/g;
#                 my $a3 = substr $item, -1, 1; 
#                 my $d3 = substr $item, 0, 1; 
#                   
#                 if(($a3 eq "\?") || ($a3 eq "\!") || ($a3 eq "\.") || ($a3 eq "\:")|| ($a3 eq "\,")|| ($a3 eq "\?")|| ($d3 eq " ")|| ($d3 eq "؟") || ($a3 eq "\(")|| ($a3 eq "\)")|| ($a3 eq " ")|| ($a3 eq "\"")|| ($a3 eq "\?")|| ($a3 eq "\?"))
#                     {
#                       $item = substr $item, -1, 1;
#                     }
#          
#                  if(($d3 eq "\?") || ($d3 eq "\!") || ($d3 eq "\.") || ($d3 eq "\:")|| ($d3 eq "\,")|| ($d3 eq "\?")|| ($d3 eq " ")|| ($d3 eq "\?") ||($d3 eq "\(")|| ($d3 eq "\)")|| ($d3 eq " ") || ($d3 eq "\"")|| ($d3 eq "؟")|| ($d3 eq "\?"))
#                     {
#                       $item = substr $item, 0, 1;
#                     }
