#!/usr/bin/env bash

# Copyright 2013   (Authors: Bagher BabaAli, Daniel Povey, Arnab Ghoshal)
#           2014   Brno University of Technology (Author: Karel Vesely)
# Apache 2.0.

if [ $# -ne 1 ]; then
   echo "Argument should be the Timit directory, see ../run.sh for example."
   exit 1;
fi

dir=`pwd`/home/zoughi/hiva/data/local/data/
lmdir=`pwd`/data/local/nist_lm
mkdir -p $dir $lmdir
local=`pwd`/local
utils=`pwd`/utils
conf=`pwd`/conf

. ./path.sh # Needed for KALDI_ROOT
export PATH=$PATH:$KALDI_ROOT/tools/irstlm/bin
sph2pipe=$KALDI_ROOT/tools/sph2pipe_v2.5/sph2pipe
if [ ! -x $sph2pipe ]; then
   echo "Could not find (or execute) the sph2pipe program at $sph2pipe";
   exit 1;
fi

#[ -f $conf/test_spk.list ] || error_exit "$PROG: Eval-set speaker list not found.";
#[ -f $conf/dev_spk.list ] || error_exit "$PROG: dev-set speaker list not found.";

# First check if the train & test directories exist (these can either be upper-
# or lower-cased
if [ ! -d $*/TRAIN -o ! -d $*/TEST -o ! -d $*/DEV ] && [ ! -d $*/train -o ! -d $*/test -o ! -d $*/dev ]; then
  echo "timit_data_prep.sh: Spot check of command line argument failed"
  echo "Command line argument must be absolute pathname to TIMIT directory"
  echo "with name like /export/corpora5/LDC/LDC93S1/timit/TIMIT"
  exit 1;
fi

# Now check what case the directory structure is
uppercased=false
train_dir=train/Samadi
test_dir=test/Samadi
dev_dir=dev/Samadi
if [ -d $*/TRAIN ]; then
  uppercased=true
  train_dir=TRAIN/Samadi
  test_dir=TEST/Samadi
  dev_dir=DEV/Samadi

fi

rm -rf /home/zoughi/hiva/kaldi
mkdir /home/zoughi/hiva/kaldi
tmpdir=/home/zoughi/hiva/kaldi
#trap 'rm -rf "$tmpdir"' EXIT

# Get the list of speakers. The list of speakers in the 24-speaker core test
# set and the 50-speaker development set must be supplied to the script. All
# speakers in the 'train' directory are used for training.
if $uppercased; then
#  tr '[:lower:]' '[:upper:]' < $conf/dev_spk.list > $tmpdir/dev_spk
#  tr '[:lower:]' '[:upper:]' < $conf/test_spk.list > $tmpdir/test_spk
  ls -d "$*"/TAIN/Samadi | sed -e "s:^.*/::" > $tmpdir/train_spk
  ls -d "$*"/TEST/Samadi | sed -e "s:^.*/::" > $tmpdir/test_spk
  ls -d "$*"/DEV/Samadi | sed -e "s:^.*/::" > $tmpdir/dev_spk
else
#  tr '[:upper:]' '[:lower:]' < $conf/dev_spk.list > $tmpdir/dev_spk
#  tr '[:upper:]' '[:lower:]' < $conf/test_spk.list > $tmpdir/test_spk
  ls -d "$*"/train/Samadi | sed -e "s:^.*/::" > $tmpdir/train_spk
  ls -d "$*"/test/Samadi | sed -e "s:^.*/::" > $tmpdir/test_spk
  ls -d "$*"/dev/Samadi | sed -e "s:^.*/::" > $tmpdir/dev_spk
fi

cd $dir
for x in train dev test; do
  # First, find the list of audio files (use only si & sx utterances).
  # Note: train & test sets are under different directories, but doing find on
  # both and grepping for the speakers will work correctly.
  find $*/{$train_dir,$test_dir} -iname '*.wav' \
    | grep -f $tmpdir/${x}_spk > ${x}_sph.flist

  sed -e 's:.*/\(.*\)/\(.*\).\(WAV\|wav\)$:\1_\2:' ${x}_sph.flist \
    > $tmpdir/${x}_sph.uttids
  paste $tmpdir/${x}_sph.uttids ${x}_sph.flist \
    | sort -k1,1 > ${x}_sph.scp

  cat ${x}_sph.scp | awk '{print $1}' > ${x}.uttids

  # Now, Convert the transcripts into our format (no normalization yet)
  # Get the transcripts: each line of the output contains an utterance
  # ID followed by the transcript.
  find $*/{$train_dir,$test_dir} -iname '*.txt' \
    | grep -f $tmpdir/${x}_spk > $tmpdir/${x}_phn.flist
  sed -e 's:.*/\(.*\)/\(.*\).\(TXT\|txt\)$:\1_\2:' $tmpdir/${x}_phn.flist \
    > $tmpdir/${x}_phn.uttids
  while read line; do
    [ -f $line ] || error_exit "Cannot find transcription file '$line'";
    cut -f 20 "$line" | tr '\n' ' ' | perl -ape 's: *$:\n:;'
#    cut -f3 -d' ' "$line" | tr '\n' ' ' | perl -ape 's: *$:\n:;'
  done < $tmpdir/${x}_phn.flist > $tmpdir/${x}_phn.trans
  paste $tmpdir/${x}_phn.uttids $tmpdir/${x}_phn.trans \
    | sort -k1,1 > ${x}1.trans

  # Do normalization steps.
  cat ${x}1.trans |  sort > $x.text || exit 1;

  # Create wav.scp
  awk '{printf("%s '$sph2pipe' -f wav %s |\n", $1, $2);}' < ${x}_sph.scp > ${x}_wav.scp

  # Make the utt2spk and spk2utt files.
  cut -f1 -d'_'  $x.uttids | paste -d' ' $x.uttids - > $x.utt2spk
  cat $x.utt2spk | utt2spk_to_spk2utt.pl > $x.spk2utt || exit 1;

  # Prepare gender mapping
  cat $x.spk2utt | awk '{print $1}' | perl -ane 'chop; m:^.:; $g = lc($&); print "$_ $g\n";' > $x.spk2gender

  # Prepare STM file for sclite:
## wav-to-duration --read-entire-file=true scp:${x}_wav.scp ark,t:${x}_dur.ark || exit 1
##  awk -v dur=${x}_dur.ark \
##  'BEGIN{
##     while(getline < dur) { durH[$1]=$2; }
##     print ";; LABEL \"O\" \"Overall\" \"Overall\"";
##     print ";; LABEL \"F\" \"Female\" \"Female speakers\"";
##     print ";; LABEL \"M\" \"Male\" \"Male speakers\"";
##   }
##   { wav=$1; spk=wav; sub(/_.*/,"",spk); $1=""; ref=$0;
##     gender=(substr(spk,0,1) == "f" ? "F" : "M");
##     printf("%s 1 %s 0.0 %f <O,%s> %s\n", wav, spk, 5.523250 , gender, ref);
##   }
##  ' ${x}.text >${x}.stm || exit 1
##
##  # Create dummy GLM file for sclite:
##  echo ';; empty.glm
##  [FAKE]     =>  %HESITATION     / [ ] __ [ ] ;; hesitation token
##  ' > ${x}.glm
done

echo "Data preparation succeeded"
