#!/usr/bin/perl
use strict;
our $b = "$ARGV[0]/data_ok/local/data/train.trans";
our $c = "$ARGV[0]/data_ok/local/train_persian.txt";

open (INGROUP, "<$b") || die "cannot open $b";;
open (DUMP, ">$c") || die "cannot open $c"; 
while (<INGROUP>){ 
       my $in_line = $_; # using my in loop assures clean variable - no hanovers from previous loops
       chomp($in_line); 
       my @inline = split(/ /,$in_line);
       my $tmp;
       my $item=$inline[1];           
       $tmp="$tmp"."$item";
       print DUMP "$item ";
       for(my $i = 2; $i <= $#inline; $i++)
       { 
         my $item=$inline[$i];           
         $tmp="$tmp"." "."$item";
         print DUMP "$item ";
       }
       print DUMP "\n";
} #endwhile
close(INGROUP);
close DUMP;
