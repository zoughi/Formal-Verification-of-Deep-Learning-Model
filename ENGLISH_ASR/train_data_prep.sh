#!/usr/bin/env bash



# Copyright   2021   TOKTAM ZOUGHi 



if [ $# -ne 2 ]; then
   echo "Argument should be the Timit directory, see ../run.sh for example."
   exit 1;
fi

dir=$saved_run/data_ok/local/data/

mkdir -p $dir
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

# Now check what case the directory structure is

rm -rf $saved_run/tmp/
mkdir $saved_run/tmp/
tmpdir=$saved_run/tmp/

ls -d "$1"/trainData1/* | sed -e "s:^.*/::" > $tmpdir/train_spk
ls -d "$1"/trainData1/d* | sed -e "s:^.*/::" > $tmpdir/dev_spk
text_dir=$MyDataBase_path/trainData1/
wav_dir=$MyDataBase_path/trainData1/

use_dev=$2
if [ $use_dev == "true" ]; then
  declare -a arr=("train" "dev")
  echo "${arr[@]}"
else
  declare -a arr=("train")
   echo "${arr[@]}"
fi

cd $dir
for x in  "${arr[@]}"; do
  find $wav_dir -iname '*.wav' \
    | grep -f $tmpdir/${x}_spk > ${x}_sph.flist

  sed -e 's:.*/\(.*\)/\(.*\).\(WAV\|wav\)$:\1_\2:' ${x}_sph.flist \
    > $tmpdir/${x}_sph.uttids
  paste $tmpdir/${x}_sph.uttids ${x}_sph.flist \
    | sort -k1,1 > ${x}_sph.scp

  cat ${x}_sph.scp | awk '{print $1}' > ${x}.uttids

  find $text_dir -iname '*.txt' \
    | grep -f $tmpdir/${x}_spk > $tmpdir/${x}_phn.flist
  sed -e 's:.*/\(.*\)/\(.*\).\(TXT\|txt\)$:\1_\2:' $tmpdir/${x}_phn.flist \
    > $tmpdir/${x}_phn.uttids
  while read line; do
    #[ -f $line ] || error_exit "Cannot find transcription file '$line'";
    cut -f 20 "$line" | tr '\n' ' ' | perl -ape 's: *$:\n:;'
#    cut -f3 -d' ' "$line" | tr '\n' ' ' | perl -ape 's: *$:\n:;'
  done < $tmpdir/${x}_phn.flist > $tmpdir/${x}_phn.trans
  paste $tmpdir/${x}_phn.uttids $tmpdir/${x}_phn.trans \
    | sort -k1,1 > ${x}1.trans
  sed -i '/^ *$/d' ${x}1.trans
  
  # Do normalization steps.
  perl $Myscript_path/for_Finglish/Per2En2.pl $x $MyDict_path $saved_run
  perl $Myscript_path/for_Finglish/Per2En1.pl $x
  cat ${x}.trans | sort > $x.text || exit 1;
  # Create wav.scp
  awk '{printf("%s sox -v 0.7 %s -t wav -r 16000 -c 1 - |\n", $1, $2);}' < ${x}_sph.scp > ${x}_wav.scp

  # Make the utt2spk and spk2utt files.
  cut -f1 -d'_'  $x.uttids | paste -d' ' $x.uttids - > $x.utt2spk
  cat $x.utt2spk | utt2spk_to_spk2utt.pl > $x.spk2utt || exit 1;

  # Prepare gender mapping
  cat $x.spk2utt | awk '{print $1}' | perl -ane 'chop; m:^.:; $g = "f"; print "$_ $g\n";' > $x.spk2gender

#  echo " Prepare STM file for sclite"
# wav-to-duration --read-entire-file=true scp:${x}_wav.scp ark,t:${x}_dur.ark || exit 1
#  awk -v dur=${x}_dur.ark \
#  'BEGIN{
#     while(getline < dur) { durH[$1]=$2; }
#     print ";; LABEL \"O\" \"Overall\" \"Overall\"";
#     print ";; LABEL \"F\" \"Female\" \"Female speakers\"";
#     print ";; LABEL \"M\" \"Male\" \"Male speakers\"";
#   }
#   { wav=$1; spk=wav; sub(/_.*/,"",spk); $1=""; ref=$0;
#     gender=(substr(spk,0,1) == "f" ? "F" : "M");
#     printf("%s 1 %s 0.0 %f <O,%s> %s\n", wav, spk, durH[wav], gender, ref);
#   }
#  ' ${x}.text >${x}.stm || exit 1

  echo "Create dummy GLM file for sclite"
  echo ';; empty.glm
  [FAKE]     =>  %HESITATION     / [ ] __ [ ] ;; hesitation token
  ' > ${x}.glm
done
trap 'rm -rf "$tmpdir"' EXIT
echo "Data preparation succeeded"
