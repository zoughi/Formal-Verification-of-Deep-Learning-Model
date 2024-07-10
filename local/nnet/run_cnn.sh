#!/usr/bin/env bash

# Copyright 2012-2015  Brno University of Technology (Author: Karel Vesely)
# Apache 2.0

# This example shows how to build CNN with convolution along frequency axis.
# First we train CNN, then build RBMs on top, then do train per-frame training 
# and sequence-discriminative training.

# Note: With DNNs in RM, the optimal LMWT is 2-6. Don't be tempted to try acwt's like 0.2, 
# the value 0.1 is better both for decoding and sMBR.

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.

. ./path.sh ## Source the tools/utils (import the queue.pl)
id=3
num_threads=20
dev=data$id-fbank/test
train=data$id-fbank/train
datadir=data$id
expdir=exp$id
dev_original=$datadir/test
train_original=$datadir/train
test_nj=1
dev_nj=2
tr_nj=14
gmm=$expdir/tri3

  echo "=============== utils/parse_options.sh ================="
stage=0
. utils/parse_options.sh
  echo "=============== set -euxo pipefail ================="

#set -euxo pipefail

# Make the FBANK features,
echo "===============  set ================="
echo "=============== copy_data_dir.sh ================="
  utils/copy_data_dir.sh $dev_original $dev;
  rm $dev/{cmvn,feats}.scp
 echo "=============== make_fbank_pitch.sh ================="
  steps/make_fbank_pitch.sh --nj $test_nj --cmd "$train_cmd" \
     $dev $dev/log $dev/data || exit 1;
 echo "=============== compute_cmvn_stats.sh ================="
  steps/compute_cmvn_stats.sh $dev $dev/log $dev/data || exit 1;
echo "=============== Training set ================="
  # Training set
  utils/copy_data_dir.sh $train_original $train; 
echo "=============== Training1 set ================="
  rm $train/{cmvn,feats}.scp
echo "=============== Training2 set ================="
  steps/make_fbank_pitch.sh --nj $tr_nj --cmd "$train_cmd" \
     $train $train/log $train/data || exit 1;
echo "=============== Training3 set ================="
  steps/compute_cmvn_stats.sh $train $train/log $train/data || exit 1;
echo "=============== Split the training set ================="
  # Split the training set
  utils/subset_data_dir_tr_cv.sh --cv-spk-percent 40 $train ${train}_tr90 ${train}_cv10

 #Run the CNN pre-training,
hid_layers=2
if [ $stage -le 1 ]; then
echo "=============== Run the CNN pre-training ================="
  dir=$expdir/cnn4c
  ali=${gmm}_ali
  # Train
 echo "=============== Train ================="
 $cuda_cmd $dir/log/train_nnet.log \
    steps/nnet/train.sh \
      --cmvn-opts "--norm-means=true --norm-vars=true" \
      --delta-opts "--delta-order=2" --splice 5 \
      --network-type cnn1d \
      --hid-layers $hid_layers --learn-rate 0.008 \
      ${train}_tr90 ${train}_cv10 $datadir/lang $ali $ali $dir || exit 1;
echo "=============== Decode ================="
  # Decode,
  steps/nnet/decode.sh --nj $test_nj --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt 0.1 \
    $gmm/graph $dev $dir/decode_test || exit 1;
fi

if [ $stage -le 2 ]; then
  # Concat 'feature_transform' with convolutional layers,
echo "=============== Concat 'feature_transform' with convolutional layers ================="
  dir=$expdir/cnn4c
  nnet-concat $dir/final.feature_transform \
    "nnet-copy --remove-last-components=$(((hid_layers+1)*2)) $dir/final.nnet - |" \
    $dir/final.feature_transform_cnn
fi

# Pre-train stack of RBMs on top of the convolutional layers (4 layers, 1024 units),
echo "=============== Pre-train stack of RBMs ================="
if [ $stage -le 3 ]; then
  dir=$expdir/cnn4c_pretrain-dbn
  transf_cnn=$expdir/cnn4c/final.feature_transform_cnn # transform with convolutional layers
echo "=============== Train2 ================="
  # Train
  $cuda_cmd $dir/log/pretrain_dbn.log \
    steps/nnet/pretrain_dbn.sh --nn-depth 4 --hid-dim 1024 --rbm-iter 20 \
    --feature-transform $transf_cnn --input-vis-type bern \
    --param-stddev-first 0.05 --param-stddev 0.05 \
    $train $dir || exit 1
fi
# Re-align using CNN,
echo "===============  Re-align using CNN ================="
if [ $stage -le 4 ]; then
  dir=$expdir/cnn4c
  steps/nnet/align.sh --nj $tr_nj --cmd "$train_cmd" \
    $train $datadir/lang $dir ${dir}_ali || exit 1
fi
# Train the DNN optimizing cross-entropy,
echo -e "=============== Train the DNN optimizing cross-entropy ================="
if [ $stage -le 5 ]; then
  dir=$expdir/cnn4c_pretrain-dbn_dnn; [ ! -d $dir ] && mkdir -p $dir/log;
  ali=$expdir/cnn4c_ali
  feature_transform=$expdir/cnn4c/final.feature_transform
  feature_transform_dbn=$expdir/cnn4c_pretrain-dbn/final.feature_transform
  dbn=$expdir/cnn4c_pretrain-dbn/4.dbn
  cnn_dbn=$dir/cnn_dbn.nnet
  { # Concatenate CNN layers and DBN,
    num_components=$(nnet-info $feature_transform | grep -m1 num-components | awk '{print $2;}')
    cnn="nnet-copy --remove-first-components=$num_components $feature_transform_dbn - |"
    nnet-concat "$cnn" $dbn $cnn_dbn 2>$dir/log/concat_cnn_dbn.log || exit 1 
  }
  # Train
echo "=============== Train3 ================="
  $cuda_cmd $dir/log/train_nnet.log \
    steps/nnet/train.sh --feature-transform $feature_transform --dbn $cnn_dbn --hid-layers 0 \
    ${train}_tr90 ${train}_cv10 $datadir/lang $ali $ali $dir || exit 1;
echo "=============== Decode (reuse HCLG graph) ================="
  steps/nnet/decode.sh --nj $test_nj --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt 0.1 \
    $gmm/graph $dev $dir/decode_test || exit 1;
fi


# Sequence training using sMBR criterion, we do Stochastic-GD with per-utterance updates.
# Note: With DNNs in RM, the optimal LMWT is 2-6. Don't be tempted to try acwt's like 0.2, 
# the value 0.1 is better both for decoding and sMBR.
dir=$expdir/cnn4c_pretrain-dbn_dnn_smbr
srcdir=$expdir/cnn4c_pretrain-dbn_dnn
acwt=0.1

echo "=============== First we generate lattices and alignments ================="
# First we generate lattices and alignments,
if [ $stage -le 6 ]; then
  steps/nnet/align.sh --nj $tr_nj --cmd "$train_cmd" \
    $train $datadir/lang $srcdir ${srcdir}_ali || exit 1;
  steps/nnet/make_denlats.sh --nj $tr_nj --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt $acwt \
    $train $datadir/lang $srcdir ${srcdir}_denlats || exit 1;
fi

echo "=============== Re-train the DNN by 6 iterations of sMBR ================="
# Re-train the DNN by 6 iterations of sMBR,
if [ $stage -le 7 ]; then
  steps/nnet/train_mpe.sh --cmd "$cuda_cmd" --num-iters 6 --acwt $acwt --do-smbr true \
    $train $datadir/lang $srcdir ${srcdir}_ali ${srcdir}_denlats $dir || exit 1
echo "=============== Decode================="
  # Decode
  for ITER in 1 3 6; do
    steps/nnet/decode.sh --nj $test_nj --cmd "$decode_cmd" --config conf/decode_dnn.config \
      --nnet $dir/${ITER}.nnet --acwt $acwt \
      $gmm/graph $dev $dir/decode_test_it${ITER} || exit 1
  done 
fi
echo Success
exit 0


