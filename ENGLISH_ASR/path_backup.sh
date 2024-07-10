
# Copyright   2021   TOKTAM ZOUGHi 


export KALDI_ROOT=/home/zoughi/kaldi
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/irstlm/bin/:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C
export saved_run=/mnt/HDD2/zoughi/Running_applicationns
export Myscript_path=/mnt/HDD2/zoughi/scripts
export MyDataBase_path=/mnt/HDD2/zoughi/scripts/Alldata
export Pcommonvoice_path=/mnt/HDD2/zoughi/scripts/Pcommonvoice_s5
export Timit_path=/mnt/HDD2/zoughi/scripts/timit_s5
export utilsDir=$Timit_path/utils
export stepsDir=$Timit_path/steps
export MyDict_path=/mnt/HDD2/zoughi/scripts/dict
export RIRS_NOISES_path=/mnt/HDD2/zoughi/scripts/Alldata/RIRS_NOISES
export Musan_Noise_path=/mnt/HDD2/zoughi/scripts/Alldata/musan
export Pcommonvoice_Data_path=/mnt/HDD2/zoughi/scripts/Alldata/cv-corpus-6.1-2020-12-11/fa