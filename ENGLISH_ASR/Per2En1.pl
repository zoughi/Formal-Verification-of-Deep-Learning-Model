#!/usr/bin/perl


# Copyright   2021   TOKTAM ZOUGHi 

use strict;
our $b = "$ARGV[0]2.trans";
our $combined = "$ARGV[0].trans";
open (INGROUP, "<$b") || die "cannot open $b";;
open (DUMP, ">$combined") || die "cannot open $combined"; 
while (<INGROUP>){ 
       our $in_line = $_; # using my in loop assures clean variable - no hanovers from previous loops
       chomp($in_line); 
       my @inline = split(/\t| /,$in_line);
       print DUMP "$inline[0]";
	     my $tmp;
       for(my $i = 1; $i <= $#inline; $i++){
           my $item=$inline[$i];
           $item =~ s/\ا/a/g;
           $item =~ s/\ی/i/g;
           $item =~ s/\أ/a/g;
           $item =~ s/\ء/e/g;
           $item =~ s/\أ/a/g;
           $item =~ s/\إ/e/g;
           $item =~ s/\ؤ/a/g;
           $item =~ s/\ژ/Z/g;
           $item =~ s/\ة/t/g;
#           $item =~ s/‌//g;


           $item =~ s/\َ/an/g;
           $item =~ s/\ُ/a/g;
           $item =~ s/\ِ/o/g;
           $item =~ s/\ّ/e/g;
           $item =~ s/\ـ/ /g;
           $item =~ s/\«/ /g;
           $item =~ s/\»/ /g;

           $item =~ s/\ً/an/g;
           $item =~ s/\ٌ/a/g;
           $item =~ s/\ٍ/o/g;
           $item =~ s/\،/ /g;
           $item =~ s/\؛/ /g;
           $item =~ s/\,/ /g;
           $item =~ s/\[/ /g;
           $item =~ s/\\/ /g;
           $item =~ s/\|/ /g;

           $item =~ s/\َ/an/g;
           $item =~ s/\آ/A/g;
           $item =~ s/\ِ/o/g;
           $item =~ s/\ّ/e/g;
           $item =~ s/\ا/a/g;
           $item =~ s/\ن/n/g;
           $item =~ s/\»/ /g;
           $item =~ s/\|/ /g;

           $item  =~ s/\,/ /g;
           $item =~ s/\ی/i/g;
           $item =~ s/\ش/S/g;
           $item  =~ s/\ب/b/g;
           $item =~ s/\چ/C/g;
           $item =~ s/\د/d/g;
           $item =~ s/\ا/e/g;
           $item =~ s/\ف/f/g;
           $item =~ s/\گ/g/g;
           $item  =~ s/\ه/h/g;
           $item  =~ s/\ح/h/g;
	   $item =~ s/\ي/i/g;
           $item =~ s/\ي/i/g;
           $item =~ s/\ئ/i/g;
           $item =~ s/\ج/j/g;
           $item =~ s/\ک/k/g;
           $item =~ s/\ل/l/g;
           $item =~ s/\م/m/g;
           $item  =~ s/\ن/n/g;
	   $item =~ s/\پ/p/g;
           $item =~ s/\ا/'/g;
           $item =~ s/\ق/q/g;
           $item =~ s/\غ/q/g;
           $item =~ s/\خ/x/g;
           $item =~ s/\ى/i/g;
           $item =~ s/\ي/y/g;
           $item  =~ s/\ت/t/g;
           $item  =~ s/\ط/t/g;
  	   $item =~ s/\ر/r/g;
           $item =~ s/\س/s/g;
           $item =~ s/\ث/s/g;
           $item =~ s/\ص/s/g;
           $item =~ s/\آ/A/g;
           $item =~ s/\و/v/g;
           $item =~ s/\ع/'a/g;
           $item =~ s/\ز/z/g;
           $item =~ s/\ذ/z/g;
           $item =~ s/\ض/z/g;
           $item =~ s/\ظ/z/g;
           $item =~ s/\ك/k/g;
           $item =~ s/\ژ/Z/g;

           $item =~ s/\"/ /g;
           $item =~ s/\(/ /g;
           $item =~ s/\)/ /g;
           $item =~ s/\%/ /g;
           $item =~ s/\-/ /g;
           $item =~ s/\_/ /g;

           $item =~ s/\،/ /g;
           $item =~ s/\./ /g;
           $item =~ s/\؟/ /g;
           $item =~ s/\!/ /g;
           $item =~ s/\:/ /g;
           $item =~ s/\،/ /g;
           $item =~ s/\؛/ /g;
           $item =~ s/~/ /g;

            if ($i==0){$tmp="$tmp"."$item";}
            else{$tmp="$tmp"." "."$item";}
        }
       print DUMP "$tmp\n";
} #endwhile
close(INGROUP);
close DUMP;
close OOV2;


