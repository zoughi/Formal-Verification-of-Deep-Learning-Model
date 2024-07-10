 Author: Toktam Zoughi<br />
 DATE: 2024-7-10<br />

Running ASR (Automatic Speech Recognition) step by step:

   1.	Go to the this link and follow INSTALL instructions there:
      https://github.com/kaldi-asr/kaldi 
   2.	Git clone "take clone address from gitlab site(Press the clone button)"
   3.	Cd full_asr folder (the downloaded directory)
   4.	To have DataBase files run "dvc pull"
   5.	Cd to "for_Finglish" directory
   6.	Set the paths located at the "for_Finglish/path.sh" script
   7.	Run "NewRun_conv.sh" script (like:    ./NewRun_conv.sh)
   8.	If you run this script successfully, it will create the following directory: 
           "$saved_run/exp$id/nnet3/tdnn_lstm_lfr1a_sp_online" 
           where "$saved_run" is the variable which is set on "for_Finglish/path.sh" script
           and "$id" is the variable which is set on "timit_s5/NewRun_Hiva.sh" script (This step may be completed in 6 days).<br />
           
   # **Notice: If you don't need to test the online model do not proceed the following steps.**
                   
   9.	Copy the "tdnn_lstm_lfr1a_sp_online" from the previous step and paste it to the "6service/exp"
   10.	You should have a wave file on 6service file named "mytest.wav"
   11.	Open two screen on your "Mobaxterm"
   12.	Run the following command on the first screen:
            
           #Now, we can compile the decoding graph with the new language model, using the following command
           model_dir=/mnt/HDD2/zoughi/scripts/6service/exp/tdnn_lstm_lfr1a_sp_online/
           
           #Now, we can compile the decoding graph with the new language model, using the following command
           model_dir=/mnt/HDD2/zoughi/scripts/6service/exp/tdnn_lstm_lfr1a_sp_online/
           graph_own_dir=$model_dir/graph
           
           #online2-tcp-nnet3-decode-faster <nnet3-in> <fst-in> <word-symbol-table>
           /mnt/HDD2/zoughi/scripts/6service/utils2/online2-tcp-nnet3-decode-faster --samp-freq=16000 --frames-per-chunk=20 --extra-left-context-initial=0 \
               --frame-subsampling-factor=3 --config=$model_dir/conf/online.conf --min-active=200 --max-active=7000 \
               --beam=15.0 --lattice-beam=6.0 --acoustic-scale=1.0 --port-num=5065 $model_dir/final.mdl $graph_own_dir/HCLG.fst $graph_own_dir/words.txt
           
           
           
           
   13.	Run the following commands on the second screen:
     
           #/mnt/HDD2/zoughi/scripts/6service/utils2/sox mytest.wav -t raw -c 1 -b 16 -r 16k -e signed-integer - | nc -N localhost 5065 
           /mnt/HDD2/zoughi/scripts/6service/utils2/sox mytest.wav -t raw -c 1 -b 16 -r 16k -e signed-integer - | nc -N localhost 5065 > /mnt/HDD2/zoughi/scripts/6service/data/out1.txt
           
           
           #**********************       THIS is python code        ****************************
           python3.7
           import sys, subprocess
           subprocess.call(['/usr/bin/perl', '/mnt/HDD2/zoughi/scripts/6service/utils2/En2Per2.pl'])
     
     
     
     
           
   14.	If you run all of this steps successfully, you should see the corresponding text of "mytest.wav" on the second screen. 
          
           
By: Toktam Zoughi
