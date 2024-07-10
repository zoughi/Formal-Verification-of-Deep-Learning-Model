#!/usr/bin/env bash



# Copyright   2021   TOKTAM ZOUGHi 



# This recipe prepare data, lang model and input to our models (eg. DNN, LSTM, ...)
# Data contain Standard Hiva corpus, Conversational Hiva corpus and common voice  
# see ../README.txt for more information

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
    echo ============================================================================
    echo "               START train                     "
    echo ============================================================================
set -e
#**************** check if we have DATA_OK *******************
id=5 #here we detrmine where to save the output of this program (eg. $saved_run/data$id)
stage=0 #
stage_NewRun_Hiva=0 #9
stage_run_tdnn_lstm_lfr_1a=0 #15
if [ $stage -le 0 ]; then
      # prepare Hiva corpus (Standard and conversational) to be as the input of the model 
      echo ============================================================================
      echo "        Data Preparation & Removing previously created data              "
      echo ============================================================================
      [ -d $saved_run/data_ok ] && rm -rf $saved_run/data_ok
      [ -d $saved_run/data$id ] && rm -rf $saved_run/data$id
      [ -d $saved_run/mfcc$id ] && rm -rf $saved_run/mfcc$id
      [ -d $saved_run/exp$id ] && rm -rf $saved_run/exp$id
      mkdir -p $saved_run/data_ok/local/data/
      cd $Myscript_path/for_Finglish/
      hiva=$MyDataBase_path
      echo ============================================================================
      echo "            Prepare test data which store on usual text files             "
      echo ============================================================================
      for x in $MyDataBase_path/excel_conv/Speaker2-semnan0_118; do
         echo $x
         ssconvert $x/lable.xlsx $x/file.csv
         ./run1.sh $x test
      done      
      #./test_data_prep.sh $hiva || exit 1

      echo ============================================================================
      echo "         Prepare train/dev data which store on usual text files           "
      echo ============================================================================
      ./train_data_prep.sh $hiva true

      echo ============================================================================
      echo "         Prepare Train data which store on Excel files            "
      echo ============================================================================
      for x in $MyDataBase_path/EXCEL/*; do
         echo $x
         ssconvert $x/lable.xlsx $x/file.csv
         ./run1.sh $x train
      done

      echo ============================================================================
      echo "         Prepare CONVERSATIONAL Train data which store on Excel files            "
      echo ============================================================================
      for x in $MyDataBase_path/excel_conv/*; do
         echo $x
         ssconvert $x/lable.xlsx $x/file.csv
         ./run1.sh $x train
      done      
    # prepare Prepare CONVERSATIONAL Common Voice DataBase to be as the input of the model 
    echo ============================================================================
    echo "       Prepare CONVERSATIONAL Common Voice DataBase to append to Hiva data        "
    echo ============================================================================
    cd $Pcommonvoice_path
    echo $Pcommonvoice_path
    . Newrun_saved.sh

fi 

if [ $stage -le 1 ]; then

      echo ============================================================================
      echo "               lang model Preparation                 "
      echo ============================================================================
      perl $Myscript_path/for_Finglish/data_prep_persian.pl $saved_run
      cat "$saved_run/data_ok/local/train_persian.txt" > "$saved_run/data_ok/local/train_persianTMP.txt"
#     cat "$Myscript_path/dict/train_persianQ_A.txt" "$saved_run/data_ok/local/train_persian.txt" >"$saved_run/data_ok/local/train_persianTMP.txt"
##      cat "$Myscript_path/dict/book.txt" >"$saved_run/data_ok/local/train_persianTMP.txt"
#      cat "$Myscript_path/dict/118_semnan.txt" >>"$saved_run/data_ok/local/train_persianTMP.txt"

#      cat "$Myscript_path/dict/persian_train_HivaQA.txt" >>"$saved_run/data_ok/local/train_persianTMP.txt"
#
#      cat "$Myscript_path/dict/persian_train_IT.txt" >>"$saved_run/data_ok/local/train_persianTMP.txt"

#      cat "$Myscript_path/dict/persian_train_Bank.txt" >>"$saved_run/data_ok/local/train_persianTMP.txt"


      mv "$saved_run/data_ok/local/train_persianTMP.txt" "$saved_run/data_ok/local/train_persian.txt"
fi 

if [ $stage -le 2 ]; then
    echo ============================================================================
    echo "               Lexicon Preparation                    "
    echo ============================================================================
    cd $Timit_path
    cp -r $MyDict_path $saved_run/data_ok/local
fi


if [ $stage -le 3 ]; then
    echo "stage_NewRun_Hiva=$stage_NewRun_Hiva"
    echo "stage_run_tdnn_lstm_lfr_1a=$stage_run_tdnn_lstm_lfr_1a"
    echo "id=$id"
    # In this stage we change directory to timit scripts directory, then run the GMM-HMM and deep models which can learn these data
    echo ============================================================================
    echo "               START train                     "
    echo ============================================================================
    cd $Timit_path
    #THE FIRST PARAMETER: #id the forlder number under witch you want to save your output
    #THE SECOND PARAMETER: #stage on which stage you want to start your work
    #THE THIRD PARAMETER: #num how much data you want to add to your data (data augment with noise)
    #./NewRun_Hiva2.sh $id 9 100000 $Myscript_path/for_Finglish    #run this script for the previous ddata
    ./NewRun_Hiva.sh $id $stage_NewRun_Hiva 100000 $Myscript_path/for_Finglish $stage_run_tdnn_lstm_lfr_1a  #run this line for new data
fi


