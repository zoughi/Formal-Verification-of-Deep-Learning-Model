#!/usr/bin/env bash




# Copyright   2021   TOKTAM ZOUGHi 



# This recipe prepare data, lang model and input to our models (eg. DNN, LSTM, ...)
# Data contain Standard Hiva corpus, Conversational Hiva corpus and common voice  
# see ../README.txt for more information

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
set -e
#**************** check if we have DATA_OK *******************
id=1 #here we detrmine where to save the output of this program (eg. /mnt/HDD2/zoughi/Running_applicationns/data$id)
stage=2 #
if [ $stage -le 0 ]; then
      # prepare Hiva corpus (Standard and conversational) to be as the input of the model 
      echo ============================================================================
      echo "        Data Preparation & Removing previously created data              "
      echo ============================================================================
      cd /home/zoughi/kaldi/egs/timit/s5/
      [ -d data_ok ] && rm -rf data_ok
      [ -d /mnt/HDD2/zoughi/Running_applicationns/data$id ] && rm -rf /mnt/HDD2/zoughi/Running_applicationns/data$id
      [ -d /mnt/HDD2/zoughi/Running_applicationns/mfcc$id ] && rm -rf /mnt/HDD2/zoughi/Running_applicationns/mfcc$id
      [ -d /mnt/HDD2/zoughi/Running_applicationns/exp$id ] && rm -rf /mnt/HDD2/zoughi/Running_applicationns/exp$id
      mkdir -p /home/zoughi/kaldi/egs/timit/s5/data_ok/local/data/
      cd /home/zoughi/hiva/for_Finglish/
      hiva=/home/zoughi/hiva
      echo ============================================================================
      echo "           Prepare test data which store on usual text files             "
      echo ============================================================================
      ./test_data_prep.sh $hiva || exit 1
      echo ============================================================================
      echo "           Prepare train/dev data which store on usual text files             "
      echo ============================================================================
     ./train_data_prep.sh $hiva true

      echo ============================================================================
      echo "         Prepare Train data which store on Excel files            "
      echo ============================================================================
      for x in /home/zoughi/hiva/EXCEL/*; do
         echo $x
         ssconvert "$x/lable.xlsx" "$x/file.csv"
         ./run1.sh $x train
      done
      
      echo ============================================================================
      echo "         Prepare CONVERSATIONAL Train data which store on Excel files            "
      echo ============================================================================
      for x in /home/zoughi/hiva/excel_conv/*; do
         echo $x
         
         ssconvert "$x/lable.xlsx" "$x/file.csv"
         ./run1.sh $x train
      done      
    echo ============================================================================
    echo "       Prepare CONVERSATIONAL Common Voice DataBase to append to Hiva data        "
    echo ============================================================================
    cd /home/zoughi/kaldi/egs/PersianEncommonvoice/s5/
    ./Newrun_saved.sh
fi
if [ $stage -le 1 ]; then
    # prepare Prepare CONVERSATIONAL Common Voice DataBase to be as the input of the model 

      echo ============================================================================
      echo "               lang model Preparation                 "
      echo ============================================================================
      perl /home/zoughi/hiva/for_Finglish/data_prep_persian.pl 
#      cat "/home/zoughi/kaldi/egs/timit/s5/backup_folder/dict/book.txt" >"/home/zoughi/kaldi/egs/timit/s5/data_ok/local/train_persianTMP.txt"

      cat "/home/zoughi/kaldi/egs/timit/s5/backup_folder/dict/persian_train_HivaQA.txt" "/home/zoughi/kaldi/egs/timit/s5/data_ok/local/train_persian.txt" >>"/home/zoughi/kaldi/egs/timit/s5/data_ok/local/train_persianTMP.txt"

      cat "/home/zoughi/kaldi/egs/timit/s5/backup_folder/dict/persian_train_IT.txt" "/home/zoughi/kaldi/egs/timit/s5/data_ok/local/train_persian.txt" >>"/home/zoughi/kaldi/egs/timit/s5/data_ok/local/train_persianTMP.txt"

      cat "/home/zoughi/kaldi/egs/timit/s5/backup_folder/dict/persian_train_Bank.txt" "/home/zoughi/kaldi/egs/timit/s5/data_ok/local/train_persian.txt" >>"/home/zoughi/kaldi/egs/timit/s5/data_ok/local/train_persianTMP.txt"



      mv "/home/zoughi/kaldi/egs/timit/s5/data_ok/local/train_persianTMP.txt" "/home/zoughi/kaldi/egs/timit/s5/data_ok/local/train_persian.txt"

    echo ============================================================================
    echo "               Lexicon Preparation                    "
    echo ============================================================================
    cd /home/zoughi/kaldi/egs/timit/s5/
    cp -r /home/zoughi/kaldi/egs/timit/s5/backup_folder/dict/ /home/zoughi/kaldi/egs/timit/s5/data_ok/local/

fi


if [ $stage -le 2 ]; then
    # In this stage we change directory to timit scripts directory, then run the GMM-HMM and deep models which can learn these data
    echo ============================================================================
    echo "               START train                     "
    echo ============================================================================
    cd /home/zoughi/kaldi/egs/timit/s5/
    #THE FIRST PARAMETER: #id the forlder number under witch you want to save your output
    #THE SECOND PARAMETER: #stage on which stage you want to start your work
    #THE THIRD PARAMETER: #num how much data you want to add to your data (data augment with noise)
    ./Run_MRes_Net.sh $id 0 100000
fi
exit
datadir=/home/zoughi/kaldi/egs/timit/s5/data_ok
local=$datadir/local
   mkdir -p $local/tmp 
   perl /home/zoughi/hiva/for_Finglish/data_prep_persian.pl 
   ngram-count -order 5 -write-vocab $local/tmp/vocab-full.txt -wbdiscount -text $local/train_persian.txt -lm $local/tmp/lm.arpa
exit
