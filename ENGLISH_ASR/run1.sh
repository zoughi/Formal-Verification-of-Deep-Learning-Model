#!/usr/bin/env bash



# Copyright   2021   TOKTAM ZOUGHi 



if [ $# -ne 2 ]; then
   echo "Argument should be the Timit directory, see ../run.sh for example."
   exit 1;
fi

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
set -e

echo $1;
echo $2;
rm -rf $saved_run/tmp
[ -d $saved_run/tmp ] && rm -rf $saved_run/tmp
mkdir  $saved_run/tmp
tmpdir=$saved_run/tmp

perl data_prepare_exel.pl $1 $2 $tmpdir $MyDataBase_path

part=tmp
datadir=data_ok
dir=$saved_run/tmp/

cd $dir
x=$2
echo $MyDict_path
  # Do normalization steps.
  perl $Myscript_path/for_Finglish/Per2En2.pl $x $MyDict_path $saved_run
  perl $Myscript_path/for_Finglish/Per2En1.pl ${x}

  cat ${x}.trans | sort > ${x}.text || exit 1;
  cat ${x}.trans > ${x}.text || exit 1;

      cat $saved_run/tmp/${x}.utt2spk $saved_run/$datadir/local/data/${x}.utt2spk | sort -u >$saved_run/$datadir/local/data/utt2spk
      mv $saved_run/$datadir/local/data/utt2spk $saved_run/$datadir/local/data/${x}.utt2spk
       
      cat $saved_run/tmp/${x}_wav.scp $saved_run/$datadir/local/data/${x}_wav.scp | sort -u >$saved_run/$datadir/local/data/wav.scp 
      mv $saved_run/$datadir/local/data/wav.scp $saved_run/$datadir/local/data/${x}_wav.scp 
      
      cat $saved_run/tmp/${x}.spk2utt $saved_run/$datadir/local/data/${x}.spk2utt | sort -u >$saved_run/$datadir/local/data/spk2utt
      mv $saved_run/$datadir/local/data/spk2utt $saved_run/$datadir/local/data/${x}.spk2utt
       
      cat $saved_run/tmp/${x}.spk2gender $saved_run/$datadir/local/data/${x}.spk2gender | sort -u >$saved_run/$datadir/local/data/spk2gender
      mv $saved_run/$datadir/local/data/spk2gender $saved_run/$datadir/local/data/${x}.spk2gender
       
      cat $saved_run/tmp/${x}.trans $saved_run/$datadir/local/data/${x}.trans | sort -u >$saved_run/$datadir/local/data/trans
      mv $saved_run/$datadir/local/data/trans $saved_run/$datadir/local/data/${x}.trans 

      cat $saved_run/tmp/${x}.text $saved_run/$datadir/local/data/${x}.text | sort -u >$saved_run/$datadir/local/data/text
      mv $saved_run/$datadir/local/data/text $saved_run/$datadir/local/data/${x}.text 
trap 'rm -rf "$tmpdir"' EXIT
echo "Data preparation succeeded"








#  # Prepare gender mapping
#  cat ${x}.spk2utt | awk '{print $1}' | perl -ane 'chop; m:^.:; $g = "f"; print "$_ $g\n";' > ${x}.spk2gender
#
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
#
#  echo "Create dummy GLM file for sclite"
#  echo ';; empty.glm
#  [FAKE]     =>  %HESITATION     / [ ] __ [ ] ;; hesitation token
#  ' > ${x}.glm
#

       
#      cat $saved_run/tmp/${x}.stm $saved_run/$datadir/local/data/${x}.stm | sort -u >$saved_run/$datadir/local/data/stm
#      mv $saved_run/$datadir/local/data/stm $saved_run/$datadir/local/data/${x}.stm
#       
#      cat $saved_run/tmp/${x}.glm $saved_run/$datadir/local/data/${x}.glm | sort -u >$saved_run/$datadir/local/data/glm
#      mv $saved_run/$datadir/local/data/glm $saved_run/$datadir/local/data/${x}.glm
