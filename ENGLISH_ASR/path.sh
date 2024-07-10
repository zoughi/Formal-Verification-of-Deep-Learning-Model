
# Copyright   2021   TOKTAM ZOUGHi 


export KALDI_ROOT=/home/zoughi/kaldi # path to your kaldi 
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/irstlm/bin/:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C
export saved_run=/mnt/HDD2/zoughi/Running_applicationns #path to a folder which saved your run 
export Myscript_path=`pwd`/..
export MyDataBase_path=$Myscript_path/Alldata
export Pcommonvoice_path=$Myscript_path/Pcommonvoice_s5
export Timit_path=$Myscript_path/timit_s5
export utilsDir=$Timit_path/utils
export stepsDir=$Timit_path/steps
export MyDict_path=$Myscript_path/dict
export RIRS_NOISES_path=$Myscript_path/Alldata/RIRS_NOISES
export Musan_Noise_path=$Myscript_path/Alldata/musan
export Pcommonvoice_Data_path=$Myscript_path/Alldata/cv-corpus-6.1-2020-12-11/fa