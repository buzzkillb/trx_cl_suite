#!/bin/sh
# some testcases for the shell script "tcls_tx2txt.sh" 
#
# Copyright (c) 2015, 2016 Volker Nowarra 
# Complete rewrite in Nov/Dec 2015 
# 
# Permission to use, copy, modify, and distribute this software for any 
# purpose with or without fee is hereby granted, provided that the above 
# copyright notice and this permission notice appear in all copies. 
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES 
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY 
# SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER 
# RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, 
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE 
# USE OR PERFORMANCE OF THIS SOFTWARE. 
# 

typeset -i LOG=0
logfile=$0.log

chksum_verify() {
if [ "$1" == "$2" ] ; then
  echo "ok"
else
  echo $1 | tee -a $logfile
  echo "*************** checksum  mismatch, ref is: ********************" | tee -a $logfile
  echo $2 | tee -a $logfile
  echo " " | tee -a $logfile
fi
}
 
to_logfile() {
  # echo $chksum_ref >> $logfile
  cat tmpfile >> $logfile
  echo " " >> $logfile
}

chksum_prep() {
  result=$( $chksum_cmd tmpfile | cut -d " " -f 2 )
  # echo $result | cut -d " " -f 2 >> $logfile
  chksum_verify "$result" "$chksum_ref" 
  if [ $LOG -eq 1 ] ; then to_logfile ; fi
}


testcase1() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 1: checksums of all necessary files             ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 1a: $chksum_cmd tcls_tx2txt.sh" | tee -a $logfile
echo "================================================================" | tee -a $logfile
chksum_ref="98ae6629db4c1cb5c56546d2803f21e47365c41b002bdf7bc92fbc8bacd3aa0a"
cp tcls_tx2txt.sh tmpfile
chksum_prep
 
echo "=== TESTCASE 1b: $chksum_cmd trx_in_sig_script.sh" | tee -a $logfile
echo "================================================================" | tee -a $logfile
chksum_ref="8ab7ce9f625e9b880f1840ca746e0a8b1eb27d25b971bef787d9e7e33f5eb9a2" 
cp tcls_in_sig_script.sh tmpfile
chksum_prep

echo "=== TESTCASE 1c: $chksum_cmd trx_out_pk_script.sh" | tee -a $logfile
echo "================================================================" | tee -a $logfile
chksum_ref="1e1e3c8464324c5d03280776b5c7efe6cab0933ef2e0e244d14c9f4e77532480" 
cp tcls_out_pk_script.sh tmpfile
chksum_prep

echo "=== TESTCASE 1d: $chksum_cmd tcls_base58check_enc.sh" | tee -a $logfile
echo "================================================================" | tee -a $logfile
chksum_ref="746615511af0567da9c213a774f5afead4a51b8f60550287c47e4eeb21b8dfca" 
cp tcls_base58check_enc.sh tmpfile
chksum_prep
echo " " | tee -a $logfile
}

testcase2() {
# do a testcase with the included example transaction
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 2: parameters testing                           ===" | tee -a $logfile
echo "=== do several testcases with parameters set incorrectly,    ===" | tee -a $logfile
echo "=== and at the end 3 correct settings. This just serves      ===" | tee -a $logfile
echo "=== to verify, that code is executing properly               ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile

echo "=== TESTCASE 2a: wrong parameter: ./tcls_tx2txt.sh xyz" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh xyz > tmpfile
chksum_ref="9d8a8a82d080bb7db07caef751e2d97db171c1e00ae03391c0d3d67ef42a0813" 
chksum_prep

echo "=== TESTCASE 2b: wrong parameter: ./tcls_tx2txt.sh -r" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -r > tmpfile
chksum_ref="6242596d0136fef2101d9566fc02dfa5ea9e63076af020742cd47038e5782945" 
chksum_prep

echo "=== TESTCASE 2c: wrong parameter: ./tcls_tx2txt.sh -t" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -t > tmpfile
chksum_ref="a548231d5bc61eea18f548d8b63ac4587b0384bc76405784bf9eb1b2c0437c71" 
chksum_prep

echo "=== TESTCASE 2d: wrong parameter: ./tcls_tx2txt.sh -r abc -t def" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -r abc -t def > tmpfile
chksum_ref="7bec4d7ac4510c39e6845b18188f163718d279f69f832612a864dcfb167abc9c" 
chksum_prep

echo "=== TESTCASE 2e: wrong parameter: ./tcls_tx2txt.sh -t abc" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -t abc > tmpfile
chksum_ref="a44863f60841dd5dcde406c6de79e83b7aa21ff902bfabe6e7f0f2391d2ef10c"
chksum_prep

echo "=== TESTCASE 2f: wrong parameter: ./tcls_tx2txt.sh -v abc" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -v abc > tmpfile
chksum_ref="fdb502a1781dba998239f22e2c7c2bad2445ecd8170d3a451ae2884340345f38" 
chksum_prep
 
echo "=== TESTCASE 2g: show help: ./tcls_tx2txt.sh -h" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -h > tmpfile
chksum_ref="35b93c340b080518a0ba42469195483ce1bf3a0b6e173385321de89f06e2831b" 
chksum_prep

echo "=== TESTCASE 2h: show default: ./tcls_tx2txt.sh" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh > tmpfile
chksum_ref="78241272d4657c65966eae49b8f245a20ba2a720ea5cf6c7238cda5b9067d7dd" 
chksum_prep

echo "=== TESTCASE 2i: show default: ./tcls_tx2txt.sh -v" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -v > tmpfile
chksum_ref="7d03bb39c4fa8fae31b4a59ab77f40ce92214ac3e90012096d3c9854a4bceba4" 
chksum_prep

echo "=== TESTCASE 2j: show default: ./tcls_tx2txt.sh -vv" | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -vv > tmpfile
chksum_ref="e007f8fa3a2ef358f5b9bca377a9f927e488f73ed5851bb220f71547b1920013" 
chksum_prep
echo " " | tee -a $logfile
}

testcase3() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 3: a fairly simple trx, 1 input, 1 output       ===" | tee -a $logfile
echo "===  we check functionality to load data via -t parameter    ===" | tee -a $logfile
echo "===  from https://blockchain.info ...                        ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6" | tee -a $logfile

echo "=== TESTCASE 3a: ./tcls_tx2txt.sh -t 30375f40ad... " | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -t 30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6 > tmpfile
chksum_ref="c2f1b08e5fe9b18cd769083f5bc0236de5a0a5d31be1c9c4cc27b0b2b1eb25a4" 
chksum_prep

echo "=== TESTCASE 3b: ./tcls_tx2txt.sh -v -t 30375f40ad... " | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -v -t 30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6 > tmpfile
chksum_ref="923b00442a52845241015845e6edda3334305fbba46a34502d370fcc93fc1fb1" 
chksum_prep

echo "=== TESTCASE 3c: ./tcls_tx2txt.sh -v -t 30375f40ad... " | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -vv -t 30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6 > tmpfile
chksum_ref="3176aff236f7944ef7af518928826964777250c7e14f1fb74f58facda8c045d7" 
chksum_prep
echo " " | tee -a $logfile
}


testcase4() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 4: a fairly simple trx, 1 input, 2 outputs      ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/91c91f31b7586b807d0ddc7a1670d10cc34bdef326affc945d4987704c7eed62" | tee -a $logfile

echo "=== TESTCASE 4a: ./tcls_tx2txt.sh -r 010000000117f83..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -r 010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600 > tmpfile
chksum_ref="593defc3655a74744c7f0231ce1e219240b7179c054b3576993e4b6e128da46e"
chksum_prep

echo "=== TESTCASE 4b: ./tcls_tx2txt.sh -v -r 010000000117f83..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -v -r 010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600 > tmpfile
chksum_ref="5387f499a681f1db82c61d4a0bb5c02340e2942bbe81995fe22d0df895d18290"
chksum_prep

echo "=== TESTCASE 4c:./tcls_tx2txt.sh -vv -r 010000000117f83..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -vv -r 010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600 > tmpfile
chksum_ref="7b54694c8edac6ce8cfff7c7d03c770948f22ec545f054fe65ddd4d8d337d354"
chksum_prep
echo " " | tee -a $logfile
}

testcase5() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 5: a fairly simple trx, 3 inputs, 1 P2SH output ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/4f292aeff2ad2da37b5d5719bf34846938cf96ea7e75c8715bc3edac01b39589" | tee -a $logfile

echo "=== TESTCASE 5a: ./tcls_tx2txt.sh -r 010000000301de569ae..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -r 010000000301de569ae0b3d49dff80f79f7953f87f17f61ca1f6d523e815a58e2b8863d098000000006a47304402203930d1ba339c9692367ae37836b1f21c1431ecb4522e7ce0caa356b9813722dc02204086f7ad81d5d656ab1b6d0fd4709b5759c22c44a0aeb1969c1cdb7c463912fa012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff97e60e0bec78cf5114238678f0b5eab617ca770752796b4c795c9d3ada772da5000000006a473044022046412e2b3f820f846a5e8f1cc92529cb694cf0d09d35cf0b5128cc7b9bf32a0802207f736b322727babd41793aeedfad41cc0541c0a1693e88b2a620bcd664da8551012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffffce559734242e6a6e0608caa07ee1178d5b9e53e0814d61f002930d78422e8402000000006b4830450221009fab428713fa76057e1bd87381614abc270089ddb23c345b0a56114db0fb8fd30220187a80bedfbb6b23bcf4eaf25017be2efdd64f02a732be9f4846142ad3408798012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff011005d0010000000017a91469545b58fd41a120da3f606be313e061ea818edf8700000000 > tmpfile
chksum_ref="cc903e35b79e8d62bda8249557f1bffbb10ec5a1e490d45801d8a5b5d8e7dd02"
chksum_prep

echo "=== TESTCASE 5b: ./tcls_tx2txt.sh -v -r 010000000301de569ae..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -v -r 010000000301de569ae0b3d49dff80f79f7953f87f17f61ca1f6d523e815a58e2b8863d098000000006a47304402203930d1ba339c9692367ae37836b1f21c1431ecb4522e7ce0caa356b9813722dc02204086f7ad81d5d656ab1b6d0fd4709b5759c22c44a0aeb1969c1cdb7c463912fa012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff97e60e0bec78cf5114238678f0b5eab617ca770752796b4c795c9d3ada772da5000000006a473044022046412e2b3f820f846a5e8f1cc92529cb694cf0d09d35cf0b5128cc7b9bf32a0802207f736b322727babd41793aeedfad41cc0541c0a1693e88b2a620bcd664da8551012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffffce559734242e6a6e0608caa07ee1178d5b9e53e0814d61f002930d78422e8402000000006b4830450221009fab428713fa76057e1bd87381614abc270089ddb23c345b0a56114db0fb8fd30220187a80bedfbb6b23bcf4eaf25017be2efdd64f02a732be9f4846142ad3408798012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff011005d0010000000017a91469545b58fd41a120da3f606be313e061ea818edf8700000000 > tmpfile
chksum_ref="51796ad8c3205ff2feb36de7f218c8525b73523e4e7c6c62777649d2623521a4"
chksum_prep

echo "=== TESTCASE 5c: ./tcls_tx2txt.sh -vv -r 010000000301de569ae..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -vv -r 010000000301de569ae0b3d49dff80f79f7953f87f17f61ca1f6d523e815a58e2b8863d098000000006a47304402203930d1ba339c9692367ae37836b1f21c1431ecb4522e7ce0caa356b9813722dc02204086f7ad81d5d656ab1b6d0fd4709b5759c22c44a0aeb1969c1cdb7c463912fa012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff97e60e0bec78cf5114238678f0b5eab617ca770752796b4c795c9d3ada772da5000000006a473044022046412e2b3f820f846a5e8f1cc92529cb694cf0d09d35cf0b5128cc7b9bf32a0802207f736b322727babd41793aeedfad41cc0541c0a1693e88b2a620bcd664da8551012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffffce559734242e6a6e0608caa07ee1178d5b9e53e0814d61f002930d78422e8402000000006b4830450221009fab428713fa76057e1bd87381614abc270089ddb23c345b0a56114db0fb8fd30220187a80bedfbb6b23bcf4eaf25017be2efdd64f02a732be9f4846142ad3408798012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff011005d0010000000017a91469545b58fd41a120da3f606be313e061ea818edf8700000000 > tmpfile
chksum_ref="9438a07a85a4d0989c32d8478519bfb6f63114ca598c4cb5afeff2c03cc4fcad"
chksum_prep
echo " " | tee -a $logfile
}

testcase6() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 6: this trx has 1 input, and 4 outputs          ===" | tee -a $logfile
echo "===  trx-in sequence = feffffff - what does this mean?       ===" | tee -a $logfile
echo "=== bitcoin.org: setting all sequence numbers to 0xffffffff  ===" | tee -a $logfile
echo "=== (the default in Bitcoin Core) can still disable the time ===" | tee -a $logfile
echo "=== lock, so if you want to use locktime, at least one input ===" | tee -a $logfile
echo "=== must have a sequence number below the the maximum.       ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/7264f8ba4a85a4780c549bf04a98e8de4c9cb1120cb1dfe8ab85ff6832eff864" | tee -a $logfile

echo "=== TESTCASE 6a: ./tcls_tx2txt.sh -r 0100000001df64d3e79..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -r 0100000001df64d3e790779777de937eea18884e9b131c9910bdb860b1a5cea225b61e3510020000006b48304502210082e594fdd17f4f2995edc180e5373a664eb56f56420f0c8761a27fa612db2a2b02206bcd4763303661c9ccaac3e4e7f6bfc062f17ce4b6b1b479ee067a05e5a578b10121036932969ec8c5cecebc1ff6fc07126f8cb5589ada69db8ca97a4f1291ead8c06bfeffffff04d130ab00000000001976a9141f59b78ccc26b6d84a65b0d362185ac4683197ed88acf0fcf300000000001976a914f12d85961d3a36119c2eaed5ad0e728a789ab59c88acb70aa700000000001976a9142baaf47baf1bd1e3dad3956db536c3f2e87c237b88ac94804707000000001976a914cb1b1d3c8be7db6416c16a1d29db170930970a3088acce3d0600 > tmpfile
chksum_ref="f660d573d5b8103e9254eefe5e69cb4ef52c28f351657e81f2b31464c30164db"
chksum_prep

echo "=== TESTCASE 6b: ./tcls_tx2txt.sh -v -r 0100000001df64d3e79..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -v -r 0100000001df64d3e790779777de937eea18884e9b131c9910bdb860b1a5cea225b61e3510020000006b48304502210082e594fdd17f4f2995edc180e5373a664eb56f56420f0c8761a27fa612db2a2b02206bcd4763303661c9ccaac3e4e7f6bfc062f17ce4b6b1b479ee067a05e5a578b10121036932969ec8c5cecebc1ff6fc07126f8cb5589ada69db8ca97a4f1291ead8c06bfeffffff04d130ab00000000001976a9141f59b78ccc26b6d84a65b0d362185ac4683197ed88acf0fcf300000000001976a914f12d85961d3a36119c2eaed5ad0e728a789ab59c88acb70aa700000000001976a9142baaf47baf1bd1e3dad3956db536c3f2e87c237b88ac94804707000000001976a914cb1b1d3c8be7db6416c16a1d29db170930970a3088acce3d0600 > tmpfile
chksum_ref="c6108160fd923ea68b85167e6856e96834812af43c47ad158c427d6c0b9e3e73"
chksum_prep

echo "=== TESTCASE 6c: ./tcls_tx2txt.sh -vv -r 0100000001df64d3e79..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -vv -r 0100000001df64d3e790779777de937eea18884e9b131c9910bdb860b1a5cea225b61e3510020000006b48304502210082e594fdd17f4f2995edc180e5373a664eb56f56420f0c8761a27fa612db2a2b02206bcd4763303661c9ccaac3e4e7f6bfc062f17ce4b6b1b479ee067a05e5a578b10121036932969ec8c5cecebc1ff6fc07126f8cb5589ada69db8ca97a4f1291ead8c06bfeffffff04d130ab00000000001976a9141f59b78ccc26b6d84a65b0d362185ac4683197ed88acf0fcf300000000001976a914f12d85961d3a36119c2eaed5ad0e728a789ab59c88acb70aa700000000001976a9142baaf47baf1bd1e3dad3956db536c3f2e87c237b88ac94804707000000001976a914cb1b1d3c8be7db6416c16a1d29db170930970a3088acce3d0600 > tmpfile
chksum_ref="662a1f1a0370392ba66de624d8b5bcca1a6f44bea1fb35b8644c7277f781bdae"
chksum_prep
echo " " | tee -a $logfile
}


testcase7() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 7: this is a transaction to a multisig address  ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/51f7fc9899b068c4a501ffa9b37368fd7c09b3e72e893e989c40c89095f74b79" | tee -a $logfile

echo "=== TESTCASE 7a: " | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -r 010000000216f7342825c156476c430f3e2765e0c393283b08246a66d122a45c836554ef03010000006b483045022100dd55b040174c90e85f0d33417dfccd96fa4f6b5ef50c32a1b720c24efc097f73022018d8a6b003b46c578d42ff4221af46068b64dd4e55d2d074175038a6e620e66b012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffffe18f73b450139de5c7375dcd2bd249ef6a42ad19661104df796dccdc98d34722000000006a47304402202e733dd23eb16130c3aa705cd04ffa31928616f2558063281cf642d786bf3eef022010a4d48968c504391c19c1cf67163d5618809bacb644d797a24a05f2130aa9f7012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffff02a6ea17000000000017a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087413c0200000000001976a914ff57cb19528c04096067b8db38d18ecd0b37789388ac00000000 > tmpfile
chksum_ref="3dd5bf5b82de43691fae6578672a7625741150a6088caa76acf049a469f648de"
chksum_prep

echo "=== TESTCASE 7b: " | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -v -r 010000000216f7342825c156476c430f3e2765e0c393283b08246a66d122a45c836554ef03010000006b483045022100dd55b040174c90e85f0d33417dfccd96fa4f6b5ef50c32a1b720c24efc097f73022018d8a6b003b46c578d42ff4221af46068b64dd4e55d2d074175038a6e620e66b012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffffe18f73b450139de5c7375dcd2bd249ef6a42ad19661104df796dccdc98d34722000000006a47304402202e733dd23eb16130c3aa705cd04ffa31928616f2558063281cf642d786bf3eef022010a4d48968c504391c19c1cf67163d5618809bacb644d797a24a05f2130aa9f7012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffff02a6ea17000000000017a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087413c0200000000001976a914ff57cb19528c04096067b8db38d18ecd0b37789388ac00000000 > tmpfile
chksum_ref="81de161023723c4fc925a6bbfafed79e973541f956ed9b157309a91fe10c243c"
chksum_prep

echo "=== TESTCASE 7c: " | tee -a $logfile
echo "================================================================" | tee -a $logfile
./tcls_tx2txt.sh -vv -r 010000000216f7342825c156476c430f3e2765e0c393283b08246a66d122a45c836554ef03010000006b483045022100dd55b040174c90e85f0d33417dfccd96fa4f6b5ef50c32a1b720c24efc097f73022018d8a6b003b46c578d42ff4221af46068b64dd4e55d2d074175038a6e620e66b012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffffe18f73b450139de5c7375dcd2bd249ef6a42ad19661104df796dccdc98d34722000000006a47304402202e733dd23eb16130c3aa705cd04ffa31928616f2558063281cf642d786bf3eef022010a4d48968c504391c19c1cf67163d5618809bacb644d797a24a05f2130aa9f7012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffff02a6ea17000000000017a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087413c0200000000001976a914ff57cb19528c04096067b8db38d18ecd0b37789388ac00000000 > tmpfile
chksum_ref="ab2486b94351706a99202f16cebff8430d2ff999d5a0ef729adced88ec8b2934"
chksum_prep
echo " " | tee -a $logfile
}


testcase8() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 8: just another multisig trx                    ===" | tee -a $logfile
echo "===  Here we have a multisig in and out address ...          ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/c0889855c93eed67d1f5a6b8a31e446e3327ce03bc267f2db958e79802941c73" | tee -a $logfile

echo "=== TESTCASE 8a: " | tee -a $logfile
./tcls_tx2txt.sh -r 0100000001b9c6777f2d8d710f1e0e3bb5fbffa7cdfd6c814a2257a7cfced9a2205448dd0601000000da0048304502210083a93c7611f5aeee6b0b4d1cbff2d31556af4cd1f951de8341c768ae03f780730220063b5e6dfb461291b1fbd93d58a8111d04fd03c7098834bac5cdf1d3c5fa90d0014730440220137c7320e03b73da66e9cf89e5f5ed0d5743ebc65e776707b8385ff93039408802202c30bc57010b3dd20507393ebc79affc653473a7baf03c5abf19c14e2136c646014752210285cb139a82dd9062b9ac1091cb1f91a01c11ab9c6a46bd09d0754dab86a38cc9210328c37f938748dcbbf15a0e5a9d1ba20f93f2c2d0ead63c7c14a5a10959b5ce8952aeffffffff0280c42b03000000001976a914d199925b52d367220b1e2a2d8815e635b571512f88ac65a7b3010000000017a9145c4dd14b9df138840b34237fdbe9159c420edbbe8700000000 > tmpfile
chksum_ref="4ec287beb077254801219521cc050d52dd3e4b15c0d89fc86060bf94f676ba2b"
chksum_prep

echo "=== TESTCASE 8b: " | tee -a $logfile
./tcls_tx2txt.sh -v -r 0100000001b9c6777f2d8d710f1e0e3bb5fbffa7cdfd6c814a2257a7cfced9a2205448dd0601000000da0048304502210083a93c7611f5aeee6b0b4d1cbff2d31556af4cd1f951de8341c768ae03f780730220063b5e6dfb461291b1fbd93d58a8111d04fd03c7098834bac5cdf1d3c5fa90d0014730440220137c7320e03b73da66e9cf89e5f5ed0d5743ebc65e776707b8385ff93039408802202c30bc57010b3dd20507393ebc79affc653473a7baf03c5abf19c14e2136c646014752210285cb139a82dd9062b9ac1091cb1f91a01c11ab9c6a46bd09d0754dab86a38cc9210328c37f938748dcbbf15a0e5a9d1ba20f93f2c2d0ead63c7c14a5a10959b5ce8952aeffffffff0280c42b03000000001976a914d199925b52d367220b1e2a2d8815e635b571512f88ac65a7b3010000000017a9145c4dd14b9df138840b34237fdbe9159c420edbbe8700000000 > tmpfile
chksum_ref="aa968060b590c3cfbe3e6d4284135b757e6d9709724908e5091c4a3175a9a4b4"
chksum_prep

echo "=== TESTCASE 8c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -r 0100000001b9c6777f2d8d710f1e0e3bb5fbffa7cdfd6c814a2257a7cfced9a2205448dd0601000000da0048304502210083a93c7611f5aeee6b0b4d1cbff2d31556af4cd1f951de8341c768ae03f780730220063b5e6dfb461291b1fbd93d58a8111d04fd03c7098834bac5cdf1d3c5fa90d0014730440220137c7320e03b73da66e9cf89e5f5ed0d5743ebc65e776707b8385ff93039408802202c30bc57010b3dd20507393ebc79affc653473a7baf03c5abf19c14e2136c646014752210285cb139a82dd9062b9ac1091cb1f91a01c11ab9c6a46bd09d0754dab86a38cc9210328c37f938748dcbbf15a0e5a9d1ba20f93f2c2d0ead63c7c14a5a10959b5ce8952aeffffffff0280c42b03000000001976a914d199925b52d367220b1e2a2d8815e635b571512f88ac65a7b3010000000017a9145c4dd14b9df138840b34237fdbe9159c420edbbe8700000000 > tmpfile
chksum_ref="ddb6c235ec45bc7adbcff344b2cd5cfd51b637aa787a359d9556f86074b0adf4"
chksum_prep
echo " " | tee -a $logfile
}


testcase9() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 9: 4 inputs and 2 outputs (P2SH multisig!)   ===" | tee -a $logfile
echo "===  This is a long transaction, which is fetched via     ===" | tee -a $logfile
echo "===  the -t parameter.                                    ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac" | tee -a $logfile

echo "=== TESTCASE 9a: " | tee -a $logfile
echo "=============================================================" | tee -a $logfile
./tcls_tx2txt.sh -t 734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac > tmpfile
chksum_ref="ffb61ed2c40debfa12bc40c33a2870fd1f47171f9f29e13c32fa196861a922ea"
chksum_prep

echo "=== TESTCASE 9b: " | tee -a $logfile
echo "=============================================================" | tee -a $logfile
./tcls_tx2txt.sh -v -t 734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac > tmpfile
chksum_ref="8d700b1754d6a82206456082206c50cdd0d25757c29bc0dc1294700cb5bd1347"
chksum_prep

echo "=== TESTCASE 9c: " | tee -a $logfile
echo "=============================================================" | tee -a $logfile
./tcls_tx2txt.sh -vv -t 734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac > tmpfile
chksum_ref="86aaf9824e4e753d7c6ccf8002784823df6565d1b55ff3f0ac0a1bb47a096618"
chksum_prep
echo " " | tee -a $logfile
}


testcase10() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 10: 1 input, 4 outputs (one is P2SH script)  ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/ea9462053d74024ec46dac07c450200194051020698e8640a5a024d8ac085590" | tee -a $logfile

echo "=== TESTCASE 10a: " | tee -a $logfile
echo "=============================================================" | tee -a $logfile
./tcls_tx2txt.sh -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82e9eebf2ae3de232202000000fc0047304402200c2f9e8805de97fa785b93dcc9072197bf5c1095ea536320ed26c645ec3bfafc02202882258f394449f1b1365ce80eed26fbe01217657729664af6827d041e7e98510147304402206d5cbef275b6972bd8cc00aff666a6ca18f09a5b1d1bf49e6966ad815db7119a0220340e49d4b747c9bd8ac80dbe073525c57da43dc4d2727b789be7e66bed9c6d02014c695221037b7c16024e2e6f6575b7a8c55c581dce7effcd6045bdf196461be8ff88db24f1210223eefa59f9b51ca96e1f4710df3639c58aae32c4cef1dd0333e7478de3dd4c6321034d03a7e6806e734c171be535999239aac76822427c217ee7564ab752cdc12dde53aeffffffff048d40ad120100000017a914fb8e0ce6d2f35c566908fd225b7f96e72df603d3872d5f0000000000001976a914768ac2a2530b2987d2e6506edc71dcf9f0a7b6e688ac00350c00000000001976a91452f28673c5aed9126b91d9eac5cbe1e02276a2cb88ac18b30700000000001976a914f3678c60ec389c7b132b5e5b0e1434b6dcd48f4188ac00000000 > tmpfile
chksum_ref="9bd3e8ba86a0f40d3053362987f24b366f53e5a020a0ccfa30baa1ef42023291"
chksum_prep

echo "=== TESTCASE 10b: " | tee -a $logfile
echo "=============================================================" | tee -a $logfile
./tcls_tx2txt.sh -v -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82e9eebf2ae3de232202000000fc0047304402200c2f9e8805de97fa785b93dcc9072197bf5c1095ea536320ed26c645ec3bfafc02202882258f394449f1b1365ce80eed26fbe01217657729664af6827d041e7e98510147304402206d5cbef275b6972bd8cc00aff666a6ca18f09a5b1d1bf49e6966ad815db7119a0220340e49d4b747c9bd8ac80dbe073525c57da43dc4d2727b789be7e66bed9c6d02014c695221037b7c16024e2e6f6575b7a8c55c581dce7effcd6045bdf196461be8ff88db24f1210223eefa59f9b51ca96e1f4710df3639c58aae32c4cef1dd0333e7478de3dd4c6321034d03a7e6806e734c171be535999239aac76822427c217ee7564ab752cdc12dde53aeffffffff048d40ad120100000017a914fb8e0ce6d2f35c566908fd225b7f96e72df603d3872d5f0000000000001976a914768ac2a2530b2987d2e6506edc71dcf9f0a7b6e688ac00350c00000000001976a91452f28673c5aed9126b91d9eac5cbe1e02276a2cb88ac18b30700000000001976a914f3678c60ec389c7b132b5e5b0e1434b6dcd48f4188ac00000000 > tmpfile
chksum_ref="d0232f662c47b27160c23a841311c0e8ae0637b8584dbb41d582c02532385be8"
chksum_prep

echo "=== TESTCASE 10c: " | tee -a $logfile
echo "=============================================================" | tee -a $logfile
./tcls_tx2txt.sh -vv -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82e9eebf2ae3de232202000000fc0047304402200c2f9e8805de97fa785b93dcc9072197bf5c1095ea536320ed26c645ec3bfafc02202882258f394449f1b1365ce80eed26fbe01217657729664af6827d041e7e98510147304402206d5cbef275b6972bd8cc00aff666a6ca18f09a5b1d1bf49e6966ad815db7119a0220340e49d4b747c9bd8ac80dbe073525c57da43dc4d2727b789be7e66bed9c6d02014c695221037b7c16024e2e6f6575b7a8c55c581dce7effcd6045bdf196461be8ff88db24f1210223eefa59f9b51ca96e1f4710df3639c58aae32c4cef1dd0333e7478de3dd4c6321034d03a7e6806e734c171be535999239aac76822427c217ee7564ab752cdc12dde53aeffffffff048d40ad120100000017a914fb8e0ce6d2f35c566908fd225b7f96e72df603d3872d5f0000000000001976a914768ac2a2530b2987d2e6506edc71dcf9f0a7b6e688ac00350c00000000001976a91452f28673c5aed9126b91d9eac5cbe1e02276a2cb88ac18b30700000000001976a914f3678c60ec389c7b132b5e5b0e1434b6dcd48f4188ac00000000 > tmpfile
chksum_ref="67275c6c21d9e301369c58ff84fd598dca7658200eb8c6a1d104f0dd28205355"
chksum_prep
echo " " | tee -a $logfile
}

testcase11() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 11: *** my first cold storage test ! ***     ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 11a: " | tee -a $logfile
echo "=============================================================" | tee -a $logfile
./tcls_tx2txt.sh -u 0100000001bc12683c21e46c380933e83c00ec3929453e3d11cc5a2db9f795372efe03e81d000000001976a914c2df275d78e506e17691fd6f0c63c43d15c897fc88acffffffff01d0a11000000000001976a9140de4457d577bb45dee513bb695bdfdc3b34d467d88ac0000000001000000 > tmpfile
chksum_ref="991460a177a696c201044940b7dd87509f96d4c8494622525473f6c829c17efd"
chksum_prep

echo "=== TESTCASE 11b: " | tee -a $logfile
echo "=============================================================" | tee -a $logfile
./tcls_tx2txt.sh -v -u 0100000001bc12683c21e46c380933e83c00ec3929453e3d11cc5a2db9f795372efe03e81d000000001976a914c2df275d78e506e17691fd6f0c63c43d15c897fc88acffffffff01d0a11000000000001976a9140de4457d577bb45dee513bb695bdfdc3b34d467d88ac0000000001000000 > tmpfile
chksum_ref="0251c337dbd0afa7e52f13729c590317e60d03b430fbe50ef9841e44a21679f1"
chksum_prep

echo "=== TESTCASE 11c: " | tee -a $logfile
echo "=============================================================" | tee -a $logfile
./tcls_tx2txt.sh -vv -u 0100000001bc12683c21e46c380933e83c00ec3929453e3d11cc5a2db9f795372efe03e81d000000001976a914c2df275d78e506e17691fd6f0c63c43d15c897fc88acffffffff01d0a11000000000001976a9140de4457d577bb45dee513bb695bdfdc3b34d467d88ac0000000001000000 > tmpfile
chksum_ref="5c570c53b444c1abb63cdc270e4f1f01f8a83680defce3dad2afba6347e87eef"
chksum_prep
echo " " | tee -a $logfile
}

testcase12() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 12: some special trx ...                     ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 12a: the pizza transaction:" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "https://blockchain.info/tx/cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79"
echo "http://bitcoin.stackexchange.com/questions/32305/how-does-the-ecdsa-verification-algorithm-work-during-transaction/32308#32308"
echo "./tcls_tx2txt.sh -vv -r 01000000018dd4f5fbd5e980fc02f35c6ce145935b11e284605bf599a13c6d415db55d07a1000000008b4830450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e0141042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabbffffffff0200719a81860000001976a914df1bd49a6c9e34dfa8631f2c54cf39986027501b88ac009f0a5362000000434104cd5e9726e6afeae357b1806be25a4c3d3811775835d235417ea746b7db9eeab33cf01674b944c64561ce3388fa1abd0fa88b06c44ce81e2234aa70fe578d455dac00000000" >> $logfile
./tcls_tx2txt.sh -vv -r 01000000018dd4f5fbd5e980fc02f35c6ce145935b11e284605bf599a13c6d415db55d07a1000000008b4830450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e0141042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabbffffffff0200719a81860000001976a914df1bd49a6c9e34dfa8631f2c54cf39986027501b88ac009f0a5362000000434104cd5e9726e6afeae357b1806be25a4c3d3811775835d235417ea746b7db9eeab33cf01674b944c64561ce3388fa1abd0fa88b06c44ce81e2234aa70fe578d455dac00000000 > tmpfile
chksum_ref="22b929c817a9630b4a05063ec63c79d032807fe16b35659d3e264a780850f857"
chksum_prep

echo " " | tee -a $logfile
echo "=== TESTCASE 12b: the same pizza tx, but fetched from network" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "./tcls_tx2txt.sh -vv -t cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79" >> $logfile
./tcls_tx2txt.sh -vv -t cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79 > tmpfile
chksum_ref="240b6d677f0a9a4c2a2259d170c486a06be6c693aaac91091afe07add0a5ce37"
chksum_prep

echo " " | tee -a $logfile
echo "=== TESTCASE 12c: nice tx_out script:" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "http://bitcoin.stackexchange.com/questions/48673/confused-about-this-particular-multisig-transaction-with-a-maybe-invalid-scrip"  | tee -a $logfile
echo "./tcls_tx2txt.sh -vv -t c49b3c445c89d832289de0fd3b0281efdcce418333dacd028061e8de9f0a6f10" >> $logfile
./tcls_tx2txt.sh -vv -t c49b3c445c89d832289de0fd3b0281efdcce418333dacd028061e8de9f0a6f10 > tmpfile
chksum_ref="5759eabe85dd2828a3d781991c95b5d83ec0b79762c5d86404c25daf5ba7c6c6"
chksum_prep

echo " " | tee -a $logfile
}

testcase20() {
# this trx has a complicated input script (PK script?)
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 20:                                          ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "===  this trx has 35 output scripts ...                   ===" >> $logfile
echo "=============================================================" >> $logfile
echo "https://blockchain.info/de/rawtx/7c83fe5ba301e655973e9de8eb9fb5e20ef3a6dd9b46c503679c858399eda50f" | tee -a $logfile

echo "=== TESTCASE 20a: " | tee -a $logfile
chksum_verify "$result" "SHA256(tmpfile)= 0a1f0b6c5dce37e107665674fdc38eb786f7b1c434989ea1ce8b0c4658240fc7"
  ./tcls_tx2txt.sh -r 01000000014675ab74e5c496c8eecaaa87c6136bc68ebaaac7a25e70ee29b7bbaffad6810f000000008b4830450220296d4f4869a63efdee4c5ea31dcad559b4e03332462ba5442bfdf00a662cb77102210088a7f10361eae3e159ae6a8b5b7a569bf6bfa2de64fb3f5d0552f8be568ba6f50141042a9a97b2109ef496ffb1033576a5635cecc6ab679ad0b7c43d33ddf38b1f44c22ea42d5c01ac2752094ff81e79dda77d8b501a64102207c45fb89ea1ad9229ddffffffff23e8030000000000001976a914801314cd462b98c64dd4c3f4d6474cad11ea39d588ace8030000000000001976a9145bb7d22851413e1d61e8db5395a8c7c537256ea088ace8030000000000001976a914371f197d5ba5e32bd98260eec7f0e51227b6969088ace8030000000000001976a9143e546d0acc0de5aa3d66d7a920900ecbc66c203188ace8030000000000001976a9140337e0710056f114c9c469a68775498df9f9fa1688ace8030000000000001976a9149c628c82aa7b81da7c6a235049eb2979c4a65cfc88ace8030000000000001976a914cd1d7e863f891c493e093ada840ef5a67ad2d6cc88ace8030000000000001976a91476f074340381e6f8a40aec4a6e2d92485679412c88ace8030000000000001976a9140fb87a5071385b6976397d1c53ee16f09139a33488ace8030000000000001976a9143d37873ffd2964a1a4c8bade4852020ec5426d3688ace8030000000000001976a9145d14a857fce8da8edfb8f7d1c4bbc316622b722788ace8030000000000001976a9140a77fdb4cc81631b6ea2991ff60b47d57812d8e788ace8030000000000001976a91454514fe9251b5e381d13171cd6fca63f61d8b72688ace8030000000000001976a914cffe3e032a686cc3f2c9e417865afa8a52ed962b88ace8030000000000001976a914fd9dc3525076c1ffe9c33389ea157d07af2e41d488ace8030000000000001976a9143bedfe927d55a8c8adfe5e4b5dddd4ea3487b4c988ace8030000000000001976a914e49275e86ece605f271f26a9559520eb9c0ae8d888ace8030000000000001976a91469256ba90b0d7e406d86a51d343d157ff0aab7bd88ace8030000000000001976a9148ab0cb809cd893cb0cb16f647d024db94f09d76588ace8030000000000001976a9140688e383f02b528c92e25caae5785ffaa81a26aa88ace8030000000000001976a914d959be6c92037995558f43a55b1c271628f96e8d88ac8038f240000000001976a914d15e54e341d538ce3e9e7596e0dbcda8c12cc08988ace8030000000000001976a91495019a8168e8dcd2ef2d47ca57c1bf49358eb6fe88ace8030000000000001976a914caf67cfe28b511498b0d1792bedeec6b6e8a3c8d88ace8030000000000001976a914082a3adf4c8497fbd7d90f21cbec318b0dfdd2b288ace8030000000000001976a9144c53722fd5b0bc8a5b23ae4efc6233142b69d8ee88ace8030000000000001976a9146abd1edce61a7fdd2d134e8468560ecffb45334e88ace8030000000000001976a914dc3343b674cf2016b8968e6146ba5cc9228f14a488ace8030000000000001976a9145f395a91d07712604d7cd6fabd685b9bfd3900dd88ace8030000000000001976a914fc35239072cd5c19d9f761996951679fb03bb43188ace8030000000000001976a914b1ec1d5e0591abbbe3134c94c37e74d034b9312288ace8030000000000001976a9142d6351944aa38af6aa46d4a74cbb9016cf19ee7e88ace8030000000000001976a914879a49b3822806e0322565d457ce2b5989adaa6188ace8030000000000001976a9145ff26e3f8d542c5bb612e539649eaec0222afc3c88ace8030000000000001976a914105d54a4edcbe114a50bb01c79d230b7ed74a3e488ac00000000 > tmpfile
chksum_prep

echo "=== TESTCASE 20b: " | tee -a $logfile
chksum_ref="27cdb3f64ffe133ddb80602efb9f53c2369cde8a25aa8d4b22d33643388cd4c1"
  ./tcls_tx2txt.sh -v -r 01000000014675ab74e5c496c8eecaaa87c6136bc68ebaaac7a25e70ee29b7bbaffad6810f000000008b4830450220296d4f4869a63efdee4c5ea31dcad559b4e03332462ba5442bfdf00a662cb77102210088a7f10361eae3e159ae6a8b5b7a569bf6bfa2de64fb3f5d0552f8be568ba6f50141042a9a97b2109ef496ffb1033576a5635cecc6ab679ad0b7c43d33ddf38b1f44c22ea42d5c01ac2752094ff81e79dda77d8b501a64102207c45fb89ea1ad9229ddffffffff23e8030000000000001976a914801314cd462b98c64dd4c3f4d6474cad11ea39d588ace8030000000000001976a9145bb7d22851413e1d61e8db5395a8c7c537256ea088ace8030000000000001976a914371f197d5ba5e32bd98260eec7f0e51227b6969088ace8030000000000001976a9143e546d0acc0de5aa3d66d7a920900ecbc66c203188ace8030000000000001976a9140337e0710056f114c9c469a68775498df9f9fa1688ace8030000000000001976a9149c628c82aa7b81da7c6a235049eb2979c4a65cfc88ace8030000000000001976a914cd1d7e863f891c493e093ada840ef5a67ad2d6cc88ace8030000000000001976a91476f074340381e6f8a40aec4a6e2d92485679412c88ace8030000000000001976a9140fb87a5071385b6976397d1c53ee16f09139a33488ace8030000000000001976a9143d37873ffd2964a1a4c8bade4852020ec5426d3688ace8030000000000001976a9145d14a857fce8da8edfb8f7d1c4bbc316622b722788ace8030000000000001976a9140a77fdb4cc81631b6ea2991ff60b47d57812d8e788ace8030000000000001976a91454514fe9251b5e381d13171cd6fca63f61d8b72688ace8030000000000001976a914cffe3e032a686cc3f2c9e417865afa8a52ed962b88ace8030000000000001976a914fd9dc3525076c1ffe9c33389ea157d07af2e41d488ace8030000000000001976a9143bedfe927d55a8c8adfe5e4b5dddd4ea3487b4c988ace8030000000000001976a914e49275e86ece605f271f26a9559520eb9c0ae8d888ace8030000000000001976a91469256ba90b0d7e406d86a51d343d157ff0aab7bd88ace8030000000000001976a9148ab0cb809cd893cb0cb16f647d024db94f09d76588ace8030000000000001976a9140688e383f02b528c92e25caae5785ffaa81a26aa88ace8030000000000001976a914d959be6c92037995558f43a55b1c271628f96e8d88ac8038f240000000001976a914d15e54e341d538ce3e9e7596e0dbcda8c12cc08988ace8030000000000001976a91495019a8168e8dcd2ef2d47ca57c1bf49358eb6fe88ace8030000000000001976a914caf67cfe28b511498b0d1792bedeec6b6e8a3c8d88ace8030000000000001976a914082a3adf4c8497fbd7d90f21cbec318b0dfdd2b288ace8030000000000001976a9144c53722fd5b0bc8a5b23ae4efc6233142b69d8ee88ace8030000000000001976a9146abd1edce61a7fdd2d134e8468560ecffb45334e88ace8030000000000001976a914dc3343b674cf2016b8968e6146ba5cc9228f14a488ace8030000000000001976a9145f395a91d07712604d7cd6fabd685b9bfd3900dd88ace8030000000000001976a914fc35239072cd5c19d9f761996951679fb03bb43188ace8030000000000001976a914b1ec1d5e0591abbbe3134c94c37e74d034b9312288ace8030000000000001976a9142d6351944aa38af6aa46d4a74cbb9016cf19ee7e88ace8030000000000001976a914879a49b3822806e0322565d457ce2b5989adaa6188ace8030000000000001976a9145ff26e3f8d542c5bb612e539649eaec0222afc3c88ace8030000000000001976a914105d54a4edcbe114a50bb01c79d230b7ed74a3e488ac00000000 > tmpfile
chksum_prep

echo "=== TESTCASE 20c: " | tee -a $logfile
chksum_ref="df9fe79f8380e40d083766f7f0e754d5eb9af5ea910fc33e7ff1597f543263a7"
  ./tcls_tx2txt.sh -vv -r 01000000014675ab74e5c496c8eecaaa87c6136bc68ebaaac7a25e70ee29b7bbaffad6810f000000008b4830450220296d4f4869a63efdee4c5ea31dcad559b4e03332462ba5442bfdf00a662cb77102210088a7f10361eae3e159ae6a8b5b7a569bf6bfa2de64fb3f5d0552f8be568ba6f50141042a9a97b2109ef496ffb1033576a5635cecc6ab679ad0b7c43d33ddf38b1f44c22ea42d5c01ac2752094ff81e79dda77d8b501a64102207c45fb89ea1ad9229ddffffffff23e8030000000000001976a914801314cd462b98c64dd4c3f4d6474cad11ea39d588ace8030000000000001976a9145bb7d22851413e1d61e8db5395a8c7c537256ea088ace8030000000000001976a914371f197d5ba5e32bd98260eec7f0e51227b6969088ace8030000000000001976a9143e546d0acc0de5aa3d66d7a920900ecbc66c203188ace8030000000000001976a9140337e0710056f114c9c469a68775498df9f9fa1688ace8030000000000001976a9149c628c82aa7b81da7c6a235049eb2979c4a65cfc88ace8030000000000001976a914cd1d7e863f891c493e093ada840ef5a67ad2d6cc88ace8030000000000001976a91476f074340381e6f8a40aec4a6e2d92485679412c88ace8030000000000001976a9140fb87a5071385b6976397d1c53ee16f09139a33488ace8030000000000001976a9143d37873ffd2964a1a4c8bade4852020ec5426d3688ace8030000000000001976a9145d14a857fce8da8edfb8f7d1c4bbc316622b722788ace8030000000000001976a9140a77fdb4cc81631b6ea2991ff60b47d57812d8e788ace8030000000000001976a91454514fe9251b5e381d13171cd6fca63f61d8b72688ace8030000000000001976a914cffe3e032a686cc3f2c9e417865afa8a52ed962b88ace8030000000000001976a914fd9dc3525076c1ffe9c33389ea157d07af2e41d488ace8030000000000001976a9143bedfe927d55a8c8adfe5e4b5dddd4ea3487b4c988ace8030000000000001976a914e49275e86ece605f271f26a9559520eb9c0ae8d888ace8030000000000001976a91469256ba90b0d7e406d86a51d343d157ff0aab7bd88ace8030000000000001976a9148ab0cb809cd893cb0cb16f647d024db94f09d76588ace8030000000000001976a9140688e383f02b528c92e25caae5785ffaa81a26aa88ace8030000000000001976a914d959be6c92037995558f43a55b1c271628f96e8d88ac8038f240000000001976a914d15e54e341d538ce3e9e7596e0dbcda8c12cc08988ace8030000000000001976a91495019a8168e8dcd2ef2d47ca57c1bf49358eb6fe88ace8030000000000001976a914caf67cfe28b511498b0d1792bedeec6b6e8a3c8d88ace8030000000000001976a914082a3adf4c8497fbd7d90f21cbec318b0dfdd2b288ace8030000000000001976a9144c53722fd5b0bc8a5b23ae4efc6233142b69d8ee88ace8030000000000001976a9146abd1edce61a7fdd2d134e8468560ecffb45334e88ace8030000000000001976a914dc3343b674cf2016b8968e6146ba5cc9228f14a488ace8030000000000001976a9145f395a91d07712604d7cd6fabd685b9bfd3900dd88ace8030000000000001976a914fc35239072cd5c19d9f761996951679fb03bb43188ace8030000000000001976a914b1ec1d5e0591abbbe3134c94c37e74d034b9312288ace8030000000000001976a9142d6351944aa38af6aa46d4a74cbb9016cf19ee7e88ace8030000000000001976a914879a49b3822806e0322565d457ce2b5989adaa6188ace8030000000000001976a9145ff26e3f8d542c5bb612e539649eaec0222afc3c88ace8030000000000001976a914105d54a4edcbe114a50bb01c79d230b7ed74a3e488ac00000000 > tmpfile
chksum_prep
echo " " | tee -a $logfile
}




all_testcases() {
  testcase1 
  testcase2 
  testcase3 
  testcase4 
  testcase5 
  testcase6 
  testcase7 
  testcase8 
  testcase9 
  testcase10
  testcase11
  testcase12
}

#####################
### here we start ###
#####################
logfile=$0.log
if [ -f "$logfile" ] ; then rm $logfile; fi
echo $date > $logfile

###################################################################
# verify our operating system, cause checksum commands differ ... #
###################################################################
OS=$(uname) 
if [ OS="OpenBSD" ] ; then
  chksum_cmd=sha256
fi
if [ OS="Linux" ] ; then
  chksum_cmd="openssl sha256"
fi
if [ OS="Darwin" ] ; then
  chksum_cmd="openssl sha256"
fi

################################
# command line params handling #
################################

if [ $# -eq 0 ] ; then
  all_testcases
fi

while [ $# -ge 1 ] 
 do
  case "$1" in
  -h)
     echo "usage: trx_testcases.sh -h|-l [1-9]"
     echo "  "
     echo "script does several testcases, mostly with checksums for verification"
     echo "  "
     exit 0
     ;;
  -l)
     LOG=1
     shift
     if [ $# -eq 0 ] ; then
       all_testcases
     fi
     ;;
  1|2|3|4|5|6|7|8|9|10|11|12)
     testcase$1 
     shift
     ;;
  *)
     echo "unknown parameter(s), try -h, exiting gracefully ..."
     exit 0
     ;;
  esac
done

# clean up
for i in tmp*; do
  if [ -f "$i" ]; then rm $i ; fi
done
for i in *hex; do
  if [ -f "$i" ]; then rm $i ; fi
done
for i in *pem; do
  if [ -f "$i" ]; then rm $i ; fi
done
