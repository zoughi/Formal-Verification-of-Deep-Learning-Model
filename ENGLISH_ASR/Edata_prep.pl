#!/usr/bin/perl
use strict;
our $b = "$MyDict_path/full.txt";
our $c = "$MyDict_path/lexicon.txt";
our $d = "$MyDict_path/lexiconp.txt";
open (INGROUP, "<$b") || die "cannot open $b";;
open (DUMP, ">$c") || die "cannot open $c"; 
open (DUMP1, ">$d") || die "cannot open $d"; 
while (<INGROUP>){ 
       our $in_line = $_; # using my in loop assures clean variable - no hanovers from previous loops
       chomp($in_line); 
#       my @inline = split(/~|,|,| |\?|\?|!|!|\t|:/,$in_line);
       my @inline = split(/\t/,$in_line);
	     my $tmp;
       my $tmp1;
       my $item1=$inline[1];
       $item1 =~ s/ //g;
       for(my $i = 1; $i <= $#inline; $i++){
           my $item=$inline[$i];
           $item =~ s/ //g;

           $item =~ s/'A/' A /g;
           $item =~ s/a/a /g;
           $item =~ s/s/s /g;
           $item =~ s/f/f /g;
           $item =~ s/d/d /g;
           $item =~ s/h/h /g;
           $item =~ s/j/j /g;
           $item =~ s/k/k /g;

           $item =~ s/l/l /g;
           $item =~ s/q/q /g;
           $item =~ s/w/w /g;
           $item =~ s/e/e /g;
           $item =~ s/r/r /g;
           $item =~ s/t/t /g;
           $item =~ s/y/y /g;

           $item =~ s/u/u /g;
           $item =~ s/i/i /g;
           $item =~ s/o/o /g;
           $item =~ s/p/p /g;
           $item =~ s/z/z /g;
           $item =~ s/x/x /g;
           $item =~ s/c/c /g;
           $item =~ s/'/' /g;

           $item =~ s/v/v /g;
           $item =~ s/b/b /g;
           $item =~ s/n/n /g;
           $item =~ s/m/m /g;
           $item =~ s/S/S /g;
           $item =~ s/A/A /g;
           $item =~ s/C/C /g;
           $item =~ s/"/" /g;
           $item =~ s/\'/\' /g;
           $item =~ s/\;/\; /g;
           $item =~ s/-/- /g;
           $item =~ s/\./\. /g;           
           $item =~ s/~/~ /g;
           $item =~ s/>/> /g;
           $item =~ s/</< /g;
           $item =~ s/,/, /g;
           $item =~ s/:/: /g;
           $item =~ s/\#/# /g;
           $item =~ s/\//\/ /g;

           $item =~ s/Z/Z /g;
           $item =~ s/g/g /g;
           $item =~ s/I/i /g;
           $item =~ s/!/! /g;
           $item =~ s/E/e /g;
           $item =~ s/R/r /g;
           $item =~ s/L/l /g;
           $item =~ s/T/t /g;
           $item =~ s/G/g /g;
           $item =~ s/M/m /g;
           $item =~ s/D/d /g;
           $item =~ s/K/k /g;
           $item =~ s/F/f /g;
           $item =~ s/U/u /g;
           $item =~ s/P/p /g;
           $item =~ s/O/p /g;
           $item =~ s/W/w /g;
           $item =~ s/H/h /g;

           $item =~ s/0/0 /g;
           $item =~ s/1/1 /g;
           $item =~ s/2/2 /g;
           $item =~ s/3/3 /g;
           $item =~ s/4/4 /g;
           $item =~ s/5/5 /g;
           $item =~ s/6/6 /g;
           $item =~ s/7/7 /g;
           $item =~ s/8/8 /g;
           $item =~ s/9/9 /g;
           

           $tmp="$item1"."\t"."$item";
           $tmp1="$item1"."\t"."1"."\t"."$item";
        }
       print DUMP "$tmp\n";
       print DUMP1 "$tmp1\n";
} #endwhile
close(INGROUP);
close DUMP;
close DUMP1;
