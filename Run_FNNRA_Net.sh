#!/usr/bin/env bash
. ./cmd.sh
[ -f path.sh ] && . ./path.sh
set -e
# Acoustic model parameters
numLeavesTri1=2500
numGaussTri1=15000
numLeavesMLLT=2500
numGaussMLLT=15000
numLeavesSAT=2500
numGaussSAT=15000
numGaussUBM=400
numLeavesSGMM=7000
numGaussSGMM=9000
id=$1
stage=$2
#########***************** BE CAREFULL ********************#################
if [ -d data_ok ]; then 
  mv data_ok /mnt/HDD2/zoughi/Running_applicationns/data$id
fi
#########***************** BE CAREFULL ********************#################
datadir=/mnt/HDD2/zoughi/Running_applicationns/data$id
expdir=/mnt/HDD2/zoughi/Running_applicationns/exp$id
mfccdir=/mnt/HDD2/zoughi/Running_applicationns/mfcc$id
local=$datadir/local
lm_order=3;

feats_nj=`cat $datadir/local/data/train.spk2gender|wc -l`
train_nj=`cat $datadir/local/data/train.spk2gender|wc -l`
if [ $train_nj -gt 20 ]; then
  train_nj=10
fi 
test_nj=1
dev_nj1=`cat $datadir/local/data/dev.spk2gender|wc -l`
dev_nj=15

if [ $stage -le 0 ]; then
   echo ============================================================================
   echo "                Prepare reco2dur                     "
   echo ============================================================================
   srcdir=$datadir/local/data
   for x in train dev test; do
     mkdir -p $datadir/$x
     cp $srcdir/${x}_wav.scp $datadir/$x/wav.scp || exit 1;
     cp $srcdir/${x}.trans $datadir/$x/text || exit 1;
     cp $srcdir/$x.spk2utt $datadir/$x/spk2utt || exit 1;
     cat $srcdir/$x.utt2spk | sort -u >$datadir/$x/utt2spk || exit 1;
     cat $datadir/$x/spk2utt | awk '{print $1}' | perl -ane 'chop; m:^.:; $g = lc($&); print "$_ $g\n";' > $datadir/$x/spk2gender
#   
    # utils/filter_scp.pl $datadir/$x/spk2utt $srcdir/$x.spk2gender > $datadir/$x/spk2gender || exit 1;
   #  cp $srcdir/${x}.stm $datadir/$x/stm
   #  cp $srcdir/${x}.glm $datadir/$x/glm
     utils/fix_data_dir.sh $datadir/$x
   done
   echo ============================================================================
   echo "                       parse_options                    "
   echo ============================================================================
   . utils/parse_options.sh || exit 1
   ##[[ $# -ge 2 ]] && { echo "Wrong arguments!"; exit 1; }
   echo ============================================================================
   echo "         MFCC Feature Extration & CMVN for Training and Test set          "
   echo ============================================================================
   for x in train dev test; do
     steps/make_mfcc.sh --nj $dev_nj --cmd "$train_cmd" $datadir/$x $expdir/make_mfcc/$x $mfccdir
#     steps/compute_cmvn_stats.sh $datadir/$x $expdir/make_mfcc/$x $mfccdir
   done
fi

if [ $stage -le 1 ]; then
  echo ============================================================================
  echo "                Data Augmentation                    "
  echo ============================================================================
  musan_root=/mnt/HDD2/zoughi/Speaker_recognition/musan/
  frame_shift=0.01
  awk -v frame_shift=$frame_shift '{print $1, $2*frame_shift;}' $datadir/train/utt2num_frames > $datadir/train/reco2dur

  # Make a version with reverberated speech
  rvb_opts=()
  rvb_opts+=(--rir-set-parameters "0.5, /mnt/HDD2/zoughi/scripts/Alldata/RIRS_NOISES/simulated_rirs/smallroom/rir_list")
  rvb_opts+=(--rir-set-parameters "0.5, /mnt/HDD2/zoughi/scripts/Alldata/RIRS_NOISES/simulated_rirs/mediumroom/rir_list")

  # Make a reverberated version of the VoxCeleb2 list.  Note that we don't add any
  # additive noise here.
  for x in train dev; do
       steps/data/reverberate_data_dir.py \
         "${rvb_opts[@]}" \
         --speech-rvb-probability 1 \
         --pointsource-noise-addition-probability 0 \
         --isotropic-noise-addition-probability 0 \
         --num-replications 1 \
         --source-sampling-rate 16000 \
         $datadir/${x} $datadir/${x}_reverb
       #cp $datadir/train/vad.scp $datadir/train_reverb/
       utils/copy_data_dir.sh --utt-suffix "-reverb" $datadir/${x}_reverb $datadir/${x}_reverb.new
       rm -rf $datadir/${x}_reverb
       mv $datadir/${x}_reverb.new $datadir/${x}_reverb
     
       # Prepare the MUSAN corpus, which consists of music, speech, and noise suitable for augmentation.
       steps/data/make_musan.sh --sampling-rate 16000 $musan_root $datadir
     
       # Get the duration of the MUSAN recordings.  This will be used by the script augment_data_dir.py.
       for name in speech noise music; do
         utils/data/get_utt2dur.sh $datadir/musan_${name}
         mv $datadir/musan_${name}/utt2dur $datadir/musan_${name}/reco2dur
       done
     
       # Augment with musan_noise
       steps/data/augment_data_dir.py --utt-suffix "noise" --fg-interval 1 --fg-snrs "15:10:5:0" --fg-noise-dir "$datadir/musan_noise" $datadir/${x} $datadir/${x}_noise
       # Augment with musan_music
       steps/data/augment_data_dir.py --utt-suffix "music" --bg-snrs "15:10:8:5" --num-bg-noises "1" --bg-noise-dir "$datadir/musan_music" $datadir/${x} $datadir/${x}_music
       # Augment with musan_speech
       steps/data/augment_data_dir.py --utt-suffix "babble" --bg-snrs "20:17:15:13" --num-bg-noises "3:4:5:6:7" --bg-noise-dir "$datadir/musan_speech" $datadir/${x} $datadir/${x}_babble
     
       # Combine reverb, noise, music, and babble into one directory.
       utils/combine_data.sh $datadir/${x}_aug $datadir/${x}_reverb $datadir/${x}_noise $datadir/${x}_music $datadir/${x}_babble
  done
fi

if [ $stage -le 2 ]; then
  x=train
  # Take a random subset of the augmentations
  utils/subset_data_dir.sh $datadir/${x}_aug $3 $datadir/${x}_aug_1m
  utils/fix_data_dir.sh $datadir/${x}_aug_1m
  
  x=dev
  utils/subset_data_dir.sh $datadir/${x}_aug 2000 $datadir/${x}_aug_1m
  utils/fix_data_dir.sh $datadir/${x}_aug_1m
  for x in train dev; do
     
       # Make MFCCs for the augmented data.  Note that we do not compute a new
       # vad.scp file here.  Instead, we use the vad.scp from the clean version of
       # the list.
     #  steps/make_mfcc.sh --nj $numjob --cmd "$train_cmd" \
     #    $datadir/train_aug_1m $expdir/make_mfcc $mfccdir
     
       # Combine the clean and augmented VoxCeleb2 list.  This is now roughly
       # double the size of the original clean list.
       utils/combine_data.sh $datadir/${x}_combined $datadir/${x}_aug_1m $datadir/${x}
     
       # Combine the clean and augmented VoxCeleb2 list.  This is now roughly
       # double the size of the original clean list.
     #  utils/combine_data.sh $datadir/train_combined $datadir/train_aug $datadir/train
       rm -rf $datadir/${x} 
       mv $datadir/${x}_combined $datadir/${x}
  done
fi

if [ $stage -le 3 ]; then
   srcdir=$datadir/local/data
   for x in train dev test; do
        mkdir -p $datadir/$x
        cat $datadir/$x/spk2utt | awk '{print $1}' | perl -ane 'chop; m:^.:; $g = lc($&); print "$_ $g\n";' > $srcdir/$x.spk2gender
        utils/filter_scp.pl $datadir/$x/spk2utt $srcdir/$x.spk2gender > $datadir/$x/spk2gender || exit 1;
      
        echo " Prepare STM file for sclite"
        x=train
        wav-to-duration --read-entire-file=true scp:$datadir/${x}/wav.scp ark,t:$datadir/${x}/dur.ark || exit 1
        awk -v dur=$datadir/${x}_dur.ark \
        'BEGIN{
           while(getline < dur) { durH[$1]=$2; }
           print ";; LABEL \"O\" \"Overall\" \"Overall\"";
           print ";; LABEL \"F\" \"Female\" \"Female speakers\"";
           print ";; LABEL \"M\" \"Male\" \"Male speakers\"";
         }
         { wav=$1; spk=wav; sub(/_.*/,"",spk); $1=""; ref=$0;
           gender=(substr(spk,0,1) == "f" ? "F" : "M");
           printf("%s 1 %s 0.0 %f <O,%s> %s\n", wav, spk, durH[wav], gender, ref);
         }
        ' $datadir/${x}/text >$datadir/${x}/stm || exit 1
          utils/fix_data_dir.sh $datadir/$x
   done
fi

if [ $stage -le 4 ]; then
   echo ============================================================================
   echo "                       parse_options                    "
   echo ============================================================================
   . utils/parse_options.sh || exit 1
   ##[[ $# -ge 2 ]] && { echo "Wrong arguments!"; exit 1; }
   echo ============================================================================
   echo "         MFCC Feature Extration & CMVN for Training and Test set          "
   echo ============================================================================
   for x in train dev test; do
     steps/make_mfcc.sh --nj $dev_nj --cmd "$train_cmd" $datadir/$x $expdir/make_mfcc/$x $mfccdir
     steps/compute_cmvn_stats.sh $datadir/$x $expdir/make_mfcc/$x $mfccdir
   done
fi

if [ $stage -le 5 ]; then
   echo ============================================================================
   echo "                     MonoPhone Preparing language data                    "
   echo ============================================================================
   cp /home/zoughi/kaldi/egs/timit/s5/backup_folder/dict/lexicon.txt $datadir/local/dict/lexicon.txt
   cp /home/zoughi/kaldi/egs/timit/s5/backup_folder/dict/lexiconp.txt $datadir/local/dict/lexiconp.txt
   
   utils/prepare_lang.sh $datadir/local/dict "<UNK>" $datadir/local/lang $datadir/lang
   loc=`which ngram-count`;
   echo ============================================================================
   echo "===== MAKING G.fst ====="
   echo ============================================================================
   if [ -z $loc ]; then
           if uname -a | grep 64 >/dev/null; then
                   sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
           else
                           sdir=$KALDI_ROOT/tools/srilm/bin/i686
           fi
           if [ -f $sdir/ngram-count ]; then
                           echo "Using SRILM language modelling tool from $sdir"
                           export PATH=$PATH:$sdir
           else
                           echo "SRILM toolkit is probably not installed.
                                   Instructions: tools/install_srilm.sh"
                           exit 1
           fi
   fi
   mkdir -p $local/tmp 
   echo ============================================================================
   echo "===== MAKING G.fst ====="
   echo ============================================================================
   ngram-count -order $lm_order -write-vocab $local/tmp/vocab-full.txt -wbdiscount -text $local/train_persian.txt -lm $local/tmp/lm.arpa
   echo ============================================================================
   echo "===== MAKING G.fst ====="
   echo ============================================================================
   lang=$datadir/lang
   arpa2fst --disambig-symbol=#0 --read-symbol-table=$lang/words.txt $local/tmp/lm.arpa $lang/G.fst

   echo ============================================================================
   echo "===== MONO TRAINING ====="
   echo ============================================================================
   steps/train_mono.sh --nj "$train_nj" --cmd "$train_cmd" $datadir/train $datadir/lang $expdir/mono  || exit 1
   echo ============================================================================
   echo "===== MONO DECODING ====="
   echo ============================================================================
   utils/mkgraph.sh --mono $datadir/lang $expdir/mono $expdir/mono/graph || exit 1
   steps/decode.sh --nj "$test_nj" --cmd "$decode_cmd" $expdir/mono/graph $datadir/test $expdir/mono/decode_test
   echo ============================================================================
   echo "===== MONO ALIGNMENT ====="
   echo ============================================================================
   steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" $datadir/train $datadir/lang $expdir/mono $expdir/mono_ali || exit 1
fi

if [ $stage -le 6 ]; then
   echo ============================================================================
   echo "===== TRI1 (first triphone pass) TRAINING ====="
   echo ============================================================================
   steps/train_deltas.sh --cmd "$train_cmd" 2000 11000 $datadir/train $datadir/lang $expdir/mono_ali $expdir/tri1 || exit 1

   echo ============================================================================
   echo "===== TRI1 (first triphone pass) DECODING ====="
   echo ============================================================================
   utils/mkgraph.sh $datadir/lang $expdir/tri1 $expdir/tri1/graph || exit 1
   steps/decode.sh --nj "$test_nj" --cmd "$decode_cmd" $expdir/tri1/graph $datadir/test $expdir/tri1/decode_test
fi
if [ $stage -le 7 ]; then
   echo ============================================================================
   echo "                 tri2 : LDA + MLLT Training & Decoding                    "
   echo ============================================================================
   steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" \
     $datadir/train $datadir/lang $expdir/tri1 $expdir/tri1_ali
   
   steps/train_lda_mllt.sh --cmd "$train_cmd" \
    --splice-opts "--left-context=3 --right-context=3" \
    $numLeavesMLLT $numGaussMLLT $datadir/train $datadir/lang $expdir/tri1_ali $expdir/tri2
   utils/mkgraph.sh $datadir/lang $expdir/tri2 $expdir/tri2/graph
   
   steps/decode.sh --nj "$test_nj" --cmd "$decode_cmd" \
    $expdir/tri2/graph $datadir/dev $expdir/tri2/decode_dev
   
   steps/decode.sh --nj "$test_nj" --cmd "$decode_cmd" \
    $expdir/tri2/graph $datadir/test $expdir/tri2/decode_test
fi

if [ $stage -le 8 ]; then
   echo ============================================================================
   echo "              tri3 : LDA + MLLT + SAT Training & Decoding                 "
   echo ============================================================================
   
   # Align tri2 system with train data.
   steps/align_si.sh --nj 1 --cmd "$train_cmd" \
    --use-graphs true $datadir/train $datadir/lang $expdir/tri2 $expdir/tri2_ali
   
   # From tri2 system, train tri3 which is LDA + MLLT + SAT.
   steps/train_sat.sh --cmd "$train_cmd" \
    $numLeavesSAT $numGaussSAT $datadir/train $datadir/lang $expdir/tri2_ali $expdir/tri3
   
   utils/mkgraph.sh $datadir/lang $expdir/tri3 $expdir/tri3/graph
   
   steps/decode_fmllr.sh --nj "$test_nj" --cmd "$decode_cmd" \
    $expdir/tri3/graph $datadir/dev $expdir/tri3/decode_dev
   
   steps/decode_fmllr.sh --nj "$test_nj" --cmd "$decode_cmd" \
    $expdir/tri3/graph $datadir/test $expdir/tri3/decode_test
   
   steps/align_fmllr.sh --nj "$train_nj" --cmd "$train_cmd" \
    $datadir/train $datadir/lang $expdir/tri3 $expdir/tri3_ali
fi
if [ $stage -le 9 ]; then
  echo =====================================================================
  echo "                          MRes Fine-tuning                          "
  echo =====================================================================
  if [ ! -f $working_dir/cnn.fine.done ]; then
    echo "Fine-tuning CNN"
    $cmd $working_dir/log/cnn.fine.log \
      export PYTHONPATH=$PYTHONPATH:`pwd`/pdnn/ \; \
      export THEANO_FLAGS=mode=FAST_RUN,device=$gpu,floatX=float32 \; \
      $pythonCMD local/nnet4/cmds/run_MRes.py --train-data "$working_dir/train.pfile.gz,partition=1000m,random=true,stream=false" \
                            --valid-data "$working_dir/valid.pfile.gz,partition=400m,random=true,stream=false" \
  			  --conv-nnet-spec "3x11x40:75,5x5,s1x1,p1x3:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1:75,3x3,s1x1,p1x1,f" \
                            --nnet-spec "1024:1024:1024:$num_pdfs" \
  			  --lrate "D:0.08:0.5:0.2,0.01:8" \
                            --wdir $working_dir --param-output-file $working_dir/nnet.param \
                            --cfg-output-file $working_dir/nnet.cfg --kaldi-output-file $working_dir/dnn.nnet || exit 1;
    touch $working_dir/cnn.fine.done
  fi
fi

