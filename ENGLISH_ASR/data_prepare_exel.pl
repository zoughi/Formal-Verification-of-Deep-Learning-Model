#!/usr/bin/perl



# Copyright   2021   TOKTAM ZOUGHi 


# Usage: data_prep.pl /export/data/cv_corpus_v1/cv-valid-train valid_train

if (@ARGV != 4) {
  print STDERR "Usage: $0 <path-to-commonvoice-corpus> <dataset> <valid-train|valid-dev|valid-test>\n";
  print STDERR "e.g. $0 /export/data/cv_corpus_v1 cv-valid-train valid-train\n";
  exit(1);
}

($db_base, $dataset, $out_dir, $MyDataBase_path) = @ARGV;
mkdir data unless -d data;
mkdir $out_dir unless -d $out_dir;

open(CSV, "<", "$db_base/file.csv") or die "cannot open dataset CSV file";
open(SPKR,">", "$out_dir/$dataset.utt2spk") or die "Could not open the output file $out_dir/utt2spk";
open(SPKRG,">", "$out_dir/$dataset.spk2gender") or die "Could not open the output file $out_dir/utt2spk";
open(GNDR,">", "$out_dir/$dataset.utt2gender") or die "Could not open the output file $out_dir/utt2gender";
open(TEXT,">", "$out_dir/$dataset"."1.trans") or die "Could not open the output file $out_dir/text";
open(WAV,">", "$out_dir/$dataset"."_wav.scp") or die "Could not open the output file $out_dir/wav.scp";
our $uttId1=0;
our $uttId;

my $header = <CSV>;
while(<CSV>) {
  chomp;
  ($text, $gender, $spkr) = split(",", $_);
  if ("$gender" eq "female") {
    $gender = "f";
  } else {
    # Use male as default if not provided (no reason, just adopting the same default as in voxforge)
    $gender = "m";
  }
  $uttId1 = $uttId1+1;
  $uttId = $uttId1;
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS1" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS1" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS1" ){
      $uttId = "A"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS2" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS2" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS2" ){
      $uttId = "B"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS3" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS3" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS3" ){
      $uttId = "C"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS4" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS4" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS4" ){
      $uttId = "D"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS5" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS5" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS5" ){
      $uttId = "E"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS6" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS6" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS6" ){
      $uttId = "F"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS7" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS7" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS7" ){
      $uttId = "G"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS8" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS8" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS8" ){
      $uttId = "H"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS9" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS9" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS9" ){
      $uttId = "I"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS10" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS10" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS10" ){
      $uttId = "K"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS11" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS11" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS11" ){
      $uttId = "M"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS12" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS12" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS12" ){
      $uttId = "O"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS13" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS13" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS13" ){
      $uttId = "P"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS14" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS14" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS14" ){
      $uttId = "R"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS15" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS15" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS15" ){
      $uttId = "S"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS16" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS16" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS16" ){
      $uttId = "T"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS17" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS17" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS17" ){
      $uttId = "U"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/Speaker6_TTS18" || $db_base eq "$MyDataBase_path/devData1/Speaker6_TTS18" || $db_base eq "$MyDataBase_path/testData1/Speaker6_TTS18" ){
      $uttId = "X"."$uttId1";}



  if ( $db_base eq "$MyDataBase_path/EXCEL/IT_A" || $db_base eq "$MyDataBase_path/devData1/IT_A" || $db_base eq "$MyDataBase_path/testData1/IT_A" ){
      $uttId = "A"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/IT_B" || $db_base eq "$MyDataBase_path/devData1/IT_B" || $db_base eq "$MyDataBase_path/testData1/IT_B" ){
      $uttId = "B"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/EXCEL/IT_C" || $db_base eq "$MyDataBase_path/devData1/IT_C" || $db_base eq "$MyDataBase_path/testData1/IT_C" ){
      $uttId = "C"."$uttId1";}


  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1A_conv" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1A_conv" ){
      $uttId = "A"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1B_conv_kar" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1B_conv_kar" ){
      $uttId = "B"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1C_conv_li" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1C_conv_li" ){
      $uttId = "C"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1D_conv_motefaraqe" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1D_conv_motefaraqe" ){
      $uttId = "D"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1E_conv_kardanibekarshenasi" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1E_conv_kardanibekarshenasi" ){
      $uttId = "E"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1F_conv_doctorayebehdast" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1F_conv_doctorayebehdast" ){
      $uttId = "F"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1G_conv_dastyaripezeshki" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1G_conv_dastyaripezeshki" ){
      $uttId = "G"."$uttId1";}
   if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1H-arshad" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1H-arshad" ){
      $uttId = "H"."$uttId1";}
 if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1I-diverse" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1I-diverse" ){
      $uttId = "I"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1J-doktoryvezaratoloum" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1J-doktoryvezaratoloum" ){
      $uttId = "J"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1K_2021Feb15" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1K_2021Feb15" ){
      $uttId = "K"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1Lmohavereimotefareqe-part3" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1Lmohavereimotefareqe-part3" ){
      $uttId = "L"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker1Mmohavereimotefareqe-part4" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker1Mmohavereimotefareqe-part4" ){
      $uttId = "M"."$uttId1";}     
      
      
      
      
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-A" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-A" ){
      $uttId = "A"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-B" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-B" ){
      $uttId = "B"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-C" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-C" ){
      $uttId = "C"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-D" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-D" ){
      $uttId = "D"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-E" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-E" ){
      $uttId = "E"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-G" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-G" ){
      $uttId = "G"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-I" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-I" ){
      $uttId = "I"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-J" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-J" ){
      $uttId = "J"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-K" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-K" ){
      $uttId = "K"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-L" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-L" ){
      $uttId = "L"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-Z" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-Z" ){
      $uttId = "Z"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "S"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan0_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "M"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan1_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "N"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan2_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "O"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan3_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "P"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan4_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "Q"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan5_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "R"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan6_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "T"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan7_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "W"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan8_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "X"."$uttId1";}
  if ( $db_base eq "$MyDataBase_path/excel_conv/Speaker2-semnan9_118" || $db_base eq "$MyDataBase_path/Test_excel_conv/Speaker2-semnan_118" ){
      $uttId = "Y"."$uttId1";}

  print TEXT "$spkr","_","$uttId"," ","$text","\n";
  print GNDR "$spkr","_","$uttId"," ","$gender","\n";
  #print WAV "$db_base/$uttId".".wav\n";
  print WAV "$spkr","_","$uttId"," sox -v 0.7 $db_base/$uttId".".wav -t wav -r 16000 -c 1 - |\n";
  #print WAV "$spkr","_","$uttId"," sox $db_base/clips/$filepath -t wav -r 16k -b 16 -e signed - |\n";
  print SPKR "$spkr","_","$uttId"," $spkr","\n";
  print SPKRG "$spkr"," "," $gender","\n";
}
close(SPKR) || die;
close(SPKRG) || die;
close(TEXT) || die;
close(WAV) || die;
close(GNDR) || die;
close(WAVLIST);

if (system(
  "utt2spk_to_spk2utt.pl $out_dir/$dataset.utt2spk >$out_dir/$dataset.spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_dir";
}
#system("env LC_COLLATE=C fix_data_dir.sh $out_dir");
#if (system("env LC_COLLATE=C validate_data_dir.sh --no-feats $out_dir") != 0) {
#  die "Error validating directory $out_dir";
#}
