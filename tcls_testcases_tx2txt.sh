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
chksum_ref="9f76adde3604e7062a8d400a167dd11ac5b27dc9fde0d25d2474eb52aa62fbb8"
cp tcls_tx2txt.sh tmpfile
chksum_prep
 
echo "=== TESTCASE 1b: $chksum_cmd trx_in_sig_script.sh" | tee -a $logfile
chksum_ref="27b1b46917938a4c4a427b3a3c7d2af5f76f1ab276f5ee9bd87cfa8febed822a" 
cp tcls_in_sig_script.sh tmpfile
chksum_prep

echo "=== TESTCASE 1c: $chksum_cmd trx_out_pk_script.sh" | tee -a $logfile
chksum_ref="d095117580dcfc3d62c94450ea2da83ea6b6c82f121d1cfd5415b5c6fe1dbae3" 
cp tcls_out_pk_script.sh tmpfile
chksum_prep

echo "=== TESTCASE 1d: $chksum_cmd tcls_base58check_enc.sh" | tee -a $logfile
chksum_ref="cbc1ce97e94e22d70aba81145f0dda80d9495428317b675bf078e14e6bffd33e" 
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

echo "=== TESTCASE 2a: wrong params, xyz unknown: ./tcls_tx2txt.sh xyz" | tee -a $logfile
./tcls_tx2txt.sh xyz > tmpfile
chksum_ref="584b2f70a2fe092553e319a0cd457e06698e7bba03ca0009802838c4793738b3" 
chksum_prep

echo "=== TESTCASE 2b: wrong params, -r witout param: ./tcls_tx2txt.sh -r" | tee -a $logfile
./tcls_tx2txt.sh -r > tmpfile
chksum_ref="6242596d0136fef2101d9566fc02dfa5ea9e63076af020742cd47038e5782945" 
chksum_prep

echo "=== TESTCASE 2c: wrong params, -t witout param: ./tcls_tx2txt.sh -t" | tee -a $logfile
./tcls_tx2txt.sh -t > tmpfile
chksum_ref="a548231d5bc61eea18f548d8b63ac4587b0384bc76405784bf9eb1b2c0437c71" 
chksum_prep

echo "=== TESTCASE 2d: wrong params, -u witout param: ./tcls_tx2txt.sh -u" | tee -a $logfile
./tcls_tx2txt.sh -u > tmpfile
chksum_ref="611685688881c2c83dee9910fbbf21e1eb7b90facf599b2e949bc1e339792a18" 
chksum_prep

echo "=== TESTCASE 2e: wrong params, param abc unknown: ./tcls_tx2txt.sh -r abc" | tee -a $logfile
./tcls_tx2txt.sh -r abc > tmpfile
chksum_ref="36b69f0e3ac344a7cc5f867dffa34ad4503789afb4837f4a9fdfa06050af1dbe"
chksum_prep

echo "=== TESTCASE 2f: wrong params, param abc unknown: ./tcls_tx2txt.sh -t abc" | tee -a $logfile
./tcls_tx2txt.sh -t abc > tmpfile
chksum_ref="a44863f60841dd5dcde406c6de79e83b7aa21ff902bfabe6e7f0f2391d2ef10c"
chksum_prep

echo "=== TESTCASE 2g: wrong params, param abc unknown: ./tcls_tx2txt.sh -u abc" | tee -a $logfile
./tcls_tx2txt.sh -u abc > tmpfile
chksum_ref="36b69f0e3ac344a7cc5f867dffa34ad4503789afb4837f4a9fdfa06050af1dbe" 
chksum_prep

echo "=== TESTCASE 2h: wrong params, -r and -u together: ..." | tee -a $logfile
./tcls_tx2txt.sh -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82 -u 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82  > tmpfile
chksum_ref="3cd1e95ea9a161ba8dee7fd957f6a283e1d95ad0f562ac8994d0bf0986219c3e" 
chksum_prep

echo "=== TESTCASE 2i: wrong params, -t and -u together: ..." | tee -a $logfile
./tcls_tx2txt.sh -t 7bec4d7ac4510c39e6845b18188f163718d279f69f832612a864dcfb167abc9c -u def > tmpfile
chksum_ref="3cd1e95ea9a161ba8dee7fd957f6a283e1d95ad0f562ac8994d0bf0986219c3e" 
chksum_prep

echo "=== TESTCASE 2j: wrong params, -f without param: ./tcls_tx2txt.sh -f " | tee -a $logfile
./tcls_tx2txt.sh -f > tmpfile
chksum_ref="35aebd5aff6c4aa9cc5b1510db7d403df0c4221eb58509f9f3576ce0c7503e1a" 
chksum_prep
 
echo "=== TESTCASE 2k: wrong params, file abc unknown: ./tcls_tx2txt.sh -f abc" | tee -a $logfile
./tcls_tx2txt.sh -f abc > tmpfile
chksum_ref="0414167aa53d245a7f3f58c990b87c419df4745095c87d02c0515cfe5ee03718"
chksum_prep
 
echo "=== TESTCASE 2l: show help: ./tcls_tx2txt.sh -h" | tee -a $logfile
./tcls_tx2txt.sh -h > tmpfile
chksum_ref="bbdf2304803a08246f53e62c78a05dde7d7acaac466faf8081bceccf4eceb0ef" 
chksum_prep

echo "=== TESTCASE 2m: show default: ./tcls_tx2txt.sh" | tee -a $logfile
./tcls_tx2txt.sh > tmpfile
chksum_ref="8303949886dfd92efbbdb6d80ed69d056984cce849f9723d45e50a20391998aa" 
chksum_prep

echo "=== TESTCASE 2n: show verbose default: ./tcls_tx2txt.sh -v" | tee -a $logfile
./tcls_tx2txt.sh -v > tmpfile
chksum_ref="557d9b5279bccdb937383e917bf5d72a5f07190652c4cdcc0c72b8b55e25019f" 
chksum_prep

echo "=== TESTCASE 2o: show very verbose default: ./tcls_tx2txt.sh -vv" | tee -a $logfile
./tcls_tx2txt.sh -vv > tmpfile
chksum_ref="15973747c4a7fe914039e4d4f5c9d3b7af76249a5a494c07b11e9704f57a608b" 
chksum_prep
echo " " | tee -a $logfile
}

testcase3() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 3: a fairly simple trx, 1 input, 1 output       ===" | tee -a $logfile
echo "===  we check functionality to load data via -t parameter    ===" | tee -a $logfile
echo "===  from https://blockchain.info ...                        ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6" >> $logfile

echo "=== TESTCASE 3a: ./tcls_tx2txt.sh -t 30375f40ad... " | tee -a $logfile
./tcls_tx2txt.sh -t 30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6 > tmpfile
chksum_ref="dd9f12ba7348e69ab1ebb52b480c332797ca4874e5403cd4ff3d8006d07ce4ba" 
chksum_prep

echo "=== TESTCASE 3b: ./tcls_tx2txt.sh -v -t 30375f40ad... " | tee -a $logfile
./tcls_tx2txt.sh -v -t 30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6 > tmpfile
chksum_ref="3698d8ef070ca1a284247b218983d907eeb8eaba99771757c9027c455e3d561c" 
chksum_prep

echo "=== TESTCASE 3c: ./tcls_tx2txt.sh -v -t 30375f40ad... " | tee -a $logfile
./tcls_tx2txt.sh -vv -t 30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6 > tmpfile
chksum_ref="1c75953e14cccb1531de71083d64ec139af17d63ab92721f048cb108d68bbb51" 
chksum_prep
echo " " | tee -a $logfile
}


testcase4() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 4: a fairly simple trx, 1 input, 2 outputs      ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/91c91f31b7586b807d0ddc7a1670d10cc34bdef326affc945d4987704c7eed62" >> $logfile

echo "=== TESTCASE 4a: ./tcls_tx2txt.sh -r 010000000117f83..." | tee -a $logfile
./tcls_tx2txt.sh -r 010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600 > tmpfile
chksum_ref="fa58bd83248575ca9cfc9ce1c2fab47996bfbb27ac946510f1dd6b41bc35d293"
chksum_prep

echo "=== TESTCASE 4b: same as 4a, reading from file (param -f)" | tee -a $logfile
echo "010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600" > tmpfile_4b
./tcls_tx2txt.sh -f tmpfile_4b > tmpfile
chksum_ref="fa58bd83248575ca9cfc9ce1c2fab47996bfbb27ac946510f1dd6b41bc35d293"
chksum_prep

echo "=== TESTCASE 4c: same as 4a, verbose (param -v)" | tee -a $logfile
./tcls_tx2txt.sh -v -r 010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600 > tmpfile
chksum_ref="296f44f0441d5cc36c1962d2e4a92f976d5c5596bdee53bf72a710c80f0515c4"
chksum_prep

echo "=== TESTCASE 4d: same as 4a, verbose (param -vv)" | tee -a $logfile
./tcls_tx2txt.sh -vv -r 010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600 > tmpfile
chksum_ref="4769e97784933f439fe4018298134a0e556d0bbc53c7c53ad09741a3feb571eb"
chksum_prep
echo " " | tee -a $logfile
}

testcase5() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 5: a fairly simple trx, 3 inputs, 1 P2SH output ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/4f292aeff2ad2da37b5d5719bf34846938cf96ea7e75c8715bc3edac01b39589" >> $logfile

echo "=== TESTCASE 5a: ./tcls_tx2txt.sh -r 010000000301de569ae..." | tee -a $logfile
./tcls_tx2txt.sh -r 010000000301de569ae0b3d49dff80f79f7953f87f17f61ca1f6d523e815a58e2b8863d098000000006a47304402203930d1ba339c9692367ae37836b1f21c1431ecb4522e7ce0caa356b9813722dc02204086f7ad81d5d656ab1b6d0fd4709b5759c22c44a0aeb1969c1cdb7c463912fa012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff97e60e0bec78cf5114238678f0b5eab617ca770752796b4c795c9d3ada772da5000000006a473044022046412e2b3f820f846a5e8f1cc92529cb694cf0d09d35cf0b5128cc7b9bf32a0802207f736b322727babd41793aeedfad41cc0541c0a1693e88b2a620bcd664da8551012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffffce559734242e6a6e0608caa07ee1178d5b9e53e0814d61f002930d78422e8402000000006b4830450221009fab428713fa76057e1bd87381614abc270089ddb23c345b0a56114db0fb8fd30220187a80bedfbb6b23bcf4eaf25017be2efdd64f02a732be9f4846142ad3408798012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff011005d0010000000017a91469545b58fd41a120da3f606be313e061ea818edf8700000000 > tmpfile
chksum_ref="590b15e1b348f2c71b1014a7851b9623160a3b838e3733dad75b6eb9c8ba6bc8"
chksum_prep

echo "=== TESTCASE 5b: ./tcls_tx2txt.sh -v -r 010000000301de569ae..." | tee -a $logfile
./tcls_tx2txt.sh -v -r 010000000301de569ae0b3d49dff80f79f7953f87f17f61ca1f6d523e815a58e2b8863d098000000006a47304402203930d1ba339c9692367ae37836b1f21c1431ecb4522e7ce0caa356b9813722dc02204086f7ad81d5d656ab1b6d0fd4709b5759c22c44a0aeb1969c1cdb7c463912fa012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff97e60e0bec78cf5114238678f0b5eab617ca770752796b4c795c9d3ada772da5000000006a473044022046412e2b3f820f846a5e8f1cc92529cb694cf0d09d35cf0b5128cc7b9bf32a0802207f736b322727babd41793aeedfad41cc0541c0a1693e88b2a620bcd664da8551012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffffce559734242e6a6e0608caa07ee1178d5b9e53e0814d61f002930d78422e8402000000006b4830450221009fab428713fa76057e1bd87381614abc270089ddb23c345b0a56114db0fb8fd30220187a80bedfbb6b23bcf4eaf25017be2efdd64f02a732be9f4846142ad3408798012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff011005d0010000000017a91469545b58fd41a120da3f606be313e061ea818edf8700000000 > tmpfile
chksum_ref="90f1a38c086d86a480de08e45e4159887208d3883bc4e39d886b8501e2c0c5cf"
chksum_prep

echo "=== TESTCASE 5c: ./tcls_tx2txt.sh -vv -r 010000000301de569ae..." | tee -a $logfile
./tcls_tx2txt.sh -vv -r 010000000301de569ae0b3d49dff80f79f7953f87f17f61ca1f6d523e815a58e2b8863d098000000006a47304402203930d1ba339c9692367ae37836b1f21c1431ecb4522e7ce0caa356b9813722dc02204086f7ad81d5d656ab1b6d0fd4709b5759c22c44a0aeb1969c1cdb7c463912fa012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff97e60e0bec78cf5114238678f0b5eab617ca770752796b4c795c9d3ada772da5000000006a473044022046412e2b3f820f846a5e8f1cc92529cb694cf0d09d35cf0b5128cc7b9bf32a0802207f736b322727babd41793aeedfad41cc0541c0a1693e88b2a620bcd664da8551012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffffce559734242e6a6e0608caa07ee1178d5b9e53e0814d61f002930d78422e8402000000006b4830450221009fab428713fa76057e1bd87381614abc270089ddb23c345b0a56114db0fb8fd30220187a80bedfbb6b23bcf4eaf25017be2efdd64f02a732be9f4846142ad3408798012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff011005d0010000000017a91469545b58fd41a120da3f606be313e061ea818edf8700000000 > tmpfile
chksum_ref="ed6f1526b2e3614d5c964784d2beeca9720734a46c4b438cf7beccfd1d1ceba5"
chksum_prep
echo " " | tee -a $logfile
}

testcase6() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 6: this trx has 1 input, and 4 outputs          ===" | tee -a $logfile
echo "=== trx-in sequence = feffffff - what does this mean?        ===" >> $logfile
echo "=== bitcoin.org: setting all sequence numbers to 0xffffffff  ===" >> $logfile
echo "=== (the default in Bitcoin Core) can still disable the time ===" >> $logfile
echo "=== lock, so if you want to use locktime, at least one input ===" >> $logfile
echo "=== must have a sequence number below the the maximum.       ===" >> $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/7264f8ba4a85a4780c549bf04a98e8de4c9cb1120cb1dfe8ab85ff6832eff864" >> $logfile

echo "=== TESTCASE 6a: ./tcls_tx2txt.sh -r 0100000001df64d3e79..." | tee -a $logfile
./tcls_tx2txt.sh -r 0100000001df64d3e790779777de937eea18884e9b131c9910bdb860b1a5cea225b61e3510020000006b48304502210082e594fdd17f4f2995edc180e5373a664eb56f56420f0c8761a27fa612db2a2b02206bcd4763303661c9ccaac3e4e7f6bfc062f17ce4b6b1b479ee067a05e5a578b10121036932969ec8c5cecebc1ff6fc07126f8cb5589ada69db8ca97a4f1291ead8c06bfeffffff04d130ab00000000001976a9141f59b78ccc26b6d84a65b0d362185ac4683197ed88acf0fcf300000000001976a914f12d85961d3a36119c2eaed5ad0e728a789ab59c88acb70aa700000000001976a9142baaf47baf1bd1e3dad3956db536c3f2e87c237b88ac94804707000000001976a914cb1b1d3c8be7db6416c16a1d29db170930970a3088acce3d0600 > tmpfile
chksum_ref="d73f48f73285db8e1d11331d7e3e0a6baada5b36718bf156f548bdcbfeb56da4"
chksum_prep

echo "=== TESTCASE 6b: ./tcls_tx2txt.sh -v -r 0100000001df64d3e79..." | tee -a $logfile
./tcls_tx2txt.sh -v -r 0100000001df64d3e790779777de937eea18884e9b131c9910bdb860b1a5cea225b61e3510020000006b48304502210082e594fdd17f4f2995edc180e5373a664eb56f56420f0c8761a27fa612db2a2b02206bcd4763303661c9ccaac3e4e7f6bfc062f17ce4b6b1b479ee067a05e5a578b10121036932969ec8c5cecebc1ff6fc07126f8cb5589ada69db8ca97a4f1291ead8c06bfeffffff04d130ab00000000001976a9141f59b78ccc26b6d84a65b0d362185ac4683197ed88acf0fcf300000000001976a914f12d85961d3a36119c2eaed5ad0e728a789ab59c88acb70aa700000000001976a9142baaf47baf1bd1e3dad3956db536c3f2e87c237b88ac94804707000000001976a914cb1b1d3c8be7db6416c16a1d29db170930970a3088acce3d0600 > tmpfile
chksum_ref="fb04bd9041fa52a44c6e432110bdc62a3f46281fb4990a4dff856ec13fbe91e7"
chksum_prep

echo "=== TESTCASE 6c: ./tcls_tx2txt.sh -vv -r 0100000001df64d3e79..." | tee -a $logfile
./tcls_tx2txt.sh -vv -r 0100000001df64d3e790779777de937eea18884e9b131c9910bdb860b1a5cea225b61e3510020000006b48304502210082e594fdd17f4f2995edc180e5373a664eb56f56420f0c8761a27fa612db2a2b02206bcd4763303661c9ccaac3e4e7f6bfc062f17ce4b6b1b479ee067a05e5a578b10121036932969ec8c5cecebc1ff6fc07126f8cb5589ada69db8ca97a4f1291ead8c06bfeffffff04d130ab00000000001976a9141f59b78ccc26b6d84a65b0d362185ac4683197ed88acf0fcf300000000001976a914f12d85961d3a36119c2eaed5ad0e728a789ab59c88acb70aa700000000001976a9142baaf47baf1bd1e3dad3956db536c3f2e87c237b88ac94804707000000001976a914cb1b1d3c8be7db6416c16a1d29db170930970a3088acce3d0600 > tmpfile
chksum_ref="da8159bd127ecfb62dc4f9f18b27714ff3ba17ea1fd62e5efb40631c9058634e"
chksum_prep
echo " " | tee -a $logfile
}


testcase7() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 7: this is a transaction to a multisig address  ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/51f7fc9899b068c4a501ffa9b37368fd7c09b3e72e893e989c40c89095f74b79" >> $logfile

echo "=== TESTCASE 7a: " | tee -a $logfile
./tcls_tx2txt.sh -r 010000000216f7342825c156476c430f3e2765e0c393283b08246a66d122a45c836554ef03010000006b483045022100dd55b040174c90e85f0d33417dfccd96fa4f6b5ef50c32a1b720c24efc097f73022018d8a6b003b46c578d42ff4221af46068b64dd4e55d2d074175038a6e620e66b012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffffe18f73b450139de5c7375dcd2bd249ef6a42ad19661104df796dccdc98d34722000000006a47304402202e733dd23eb16130c3aa705cd04ffa31928616f2558063281cf642d786bf3eef022010a4d48968c504391c19c1cf67163d5618809bacb644d797a24a05f2130aa9f7012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffff02a6ea17000000000017a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087413c0200000000001976a914ff57cb19528c04096067b8db38d18ecd0b37789388ac00000000 > tmpfile
chksum_ref="8817ffc6908e1323df63cb9cbb2fcfc2cc3ed782e6c3920d328c696300c4e2f3"
chksum_prep

echo "=== TESTCASE 7b: " | tee -a $logfile
./tcls_tx2txt.sh -v -r 010000000216f7342825c156476c430f3e2765e0c393283b08246a66d122a45c836554ef03010000006b483045022100dd55b040174c90e85f0d33417dfccd96fa4f6b5ef50c32a1b720c24efc097f73022018d8a6b003b46c578d42ff4221af46068b64dd4e55d2d074175038a6e620e66b012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffffe18f73b450139de5c7375dcd2bd249ef6a42ad19661104df796dccdc98d34722000000006a47304402202e733dd23eb16130c3aa705cd04ffa31928616f2558063281cf642d786bf3eef022010a4d48968c504391c19c1cf67163d5618809bacb644d797a24a05f2130aa9f7012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffff02a6ea17000000000017a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087413c0200000000001976a914ff57cb19528c04096067b8db38d18ecd0b37789388ac00000000 > tmpfile
chksum_ref="e2e53b0105b9659e8307f1b6b7f9898c5f310dad7b1d38d1719f238ca225cf9e"
chksum_prep

echo "=== TESTCASE 7c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -r 010000000216f7342825c156476c430f3e2765e0c393283b08246a66d122a45c836554ef03010000006b483045022100dd55b040174c90e85f0d33417dfccd96fa4f6b5ef50c32a1b720c24efc097f73022018d8a6b003b46c578d42ff4221af46068b64dd4e55d2d074175038a6e620e66b012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffffe18f73b450139de5c7375dcd2bd249ef6a42ad19661104df796dccdc98d34722000000006a47304402202e733dd23eb16130c3aa705cd04ffa31928616f2558063281cf642d786bf3eef022010a4d48968c504391c19c1cf67163d5618809bacb644d797a24a05f2130aa9f7012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffff02a6ea17000000000017a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087413c0200000000001976a914ff57cb19528c04096067b8db38d18ecd0b37789388ac00000000 > tmpfile
chksum_ref="a1e65864a1bd3c4604e21a1bc0fd2982c5eac69ff618b1e70f59c65891510740"
chksum_prep
echo " " | tee -a $logfile
}


testcase8() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 8: just another multisig trx                    ===" | tee -a $logfile
echo "===  Here we have a multisig in and out address ...          ===" >> $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/c0889855c93eed67d1f5a6b8a31e446e3327ce03bc267f2db958e79802941c73" >> $logfile

echo "=== TESTCASE 8a: " | tee -a $logfile
./tcls_tx2txt.sh -r 0100000001b9c6777f2d8d710f1e0e3bb5fbffa7cdfd6c814a2257a7cfced9a2205448dd0601000000da0048304502210083a93c7611f5aeee6b0b4d1cbff2d31556af4cd1f951de8341c768ae03f780730220063b5e6dfb461291b1fbd93d58a8111d04fd03c7098834bac5cdf1d3c5fa90d0014730440220137c7320e03b73da66e9cf89e5f5ed0d5743ebc65e776707b8385ff93039408802202c30bc57010b3dd20507393ebc79affc653473a7baf03c5abf19c14e2136c646014752210285cb139a82dd9062b9ac1091cb1f91a01c11ab9c6a46bd09d0754dab86a38cc9210328c37f938748dcbbf15a0e5a9d1ba20f93f2c2d0ead63c7c14a5a10959b5ce8952aeffffffff0280c42b03000000001976a914d199925b52d367220b1e2a2d8815e635b571512f88ac65a7b3010000000017a9145c4dd14b9df138840b34237fdbe9159c420edbbe8700000000 > tmpfile
chksum_ref="a14c0368e2a9f4d40e4ef5a04a893382794ba1b0bccbf5c39295b4a93a23301e"
chksum_prep

echo "=== TESTCASE 8b: " | tee -a $logfile
./tcls_tx2txt.sh -v -r 0100000001b9c6777f2d8d710f1e0e3bb5fbffa7cdfd6c814a2257a7cfced9a2205448dd0601000000da0048304502210083a93c7611f5aeee6b0b4d1cbff2d31556af4cd1f951de8341c768ae03f780730220063b5e6dfb461291b1fbd93d58a8111d04fd03c7098834bac5cdf1d3c5fa90d0014730440220137c7320e03b73da66e9cf89e5f5ed0d5743ebc65e776707b8385ff93039408802202c30bc57010b3dd20507393ebc79affc653473a7baf03c5abf19c14e2136c646014752210285cb139a82dd9062b9ac1091cb1f91a01c11ab9c6a46bd09d0754dab86a38cc9210328c37f938748dcbbf15a0e5a9d1ba20f93f2c2d0ead63c7c14a5a10959b5ce8952aeffffffff0280c42b03000000001976a914d199925b52d367220b1e2a2d8815e635b571512f88ac65a7b3010000000017a9145c4dd14b9df138840b34237fdbe9159c420edbbe8700000000 > tmpfile
chksum_ref="1473db5d9c0e18d1a07ac77dd9e3d92e7d2dfe618c137c9bd657097e32a6e6b5"
chksum_prep

echo "=== TESTCASE 8c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -r 0100000001b9c6777f2d8d710f1e0e3bb5fbffa7cdfd6c814a2257a7cfced9a2205448dd0601000000da0048304502210083a93c7611f5aeee6b0b4d1cbff2d31556af4cd1f951de8341c768ae03f780730220063b5e6dfb461291b1fbd93d58a8111d04fd03c7098834bac5cdf1d3c5fa90d0014730440220137c7320e03b73da66e9cf89e5f5ed0d5743ebc65e776707b8385ff93039408802202c30bc57010b3dd20507393ebc79affc653473a7baf03c5abf19c14e2136c646014752210285cb139a82dd9062b9ac1091cb1f91a01c11ab9c6a46bd09d0754dab86a38cc9210328c37f938748dcbbf15a0e5a9d1ba20f93f2c2d0ead63c7c14a5a10959b5ce8952aeffffffff0280c42b03000000001976a914d199925b52d367220b1e2a2d8815e635b571512f88ac65a7b3010000000017a9145c4dd14b9df138840b34237fdbe9159c420edbbe8700000000 > tmpfile
chksum_ref="3e923b92da53101eed1bad28a2a2bd2e7ea5f75beff22fe21bd0671b892d2c01"
chksum_prep
echo " " | tee -a $logfile
}


testcase9() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 9: 4 inputs and 2 outputs (P2SH multisig!)   ===" | tee -a $logfile
echo "===  This is a long transaction, which is fetched via     ===" >> $logfile
echo "===  the -t parameter.                                    ===" >> $logfile
echo "=============================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac" >> $logfile

echo "=== TESTCASE 9a: " | tee -a $logfile
./tcls_tx2txt.sh -t 734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac > tmpfile
chksum_ref="786fb01bd0974e5f8985f259cc07a9e8ed407dfdc982ce82184e5e9c4a98810a"
chksum_prep

echo "=== TESTCASE 9b: " | tee -a $logfile
./tcls_tx2txt.sh -v -t 734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac > tmpfile
chksum_ref="0ce8e7a82ad0890d1ccfe9ac8d1ecf367f700795c1c8d264eb0ce8bd7f27bb56"
chksum_prep

echo "=== TESTCASE 9c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -t 734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac > tmpfile
chksum_ref="a4618a68ab765fdba8fad4a7874225da783dc87cfcb29b6ded549b9d1e1073bd"
chksum_prep
echo " " | tee -a $logfile
}


testcase10() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 10: 1 input, 4 outputs (one is P2SH script)  ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/ea9462053d74024ec46dac07c450200194051020698e8640a5a024d8ac085590" >> $logfile

echo "=== TESTCASE 10a: " | tee -a $logfile
./tcls_tx2txt.sh -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82e9eebf2ae3de232202000000fc0047304402200c2f9e8805de97fa785b93dcc9072197bf5c1095ea536320ed26c645ec3bfafc02202882258f394449f1b1365ce80eed26fbe01217657729664af6827d041e7e98510147304402206d5cbef275b6972bd8cc00aff666a6ca18f09a5b1d1bf49e6966ad815db7119a0220340e49d4b747c9bd8ac80dbe073525c57da43dc4d2727b789be7e66bed9c6d02014c695221037b7c16024e2e6f6575b7a8c55c581dce7effcd6045bdf196461be8ff88db24f1210223eefa59f9b51ca96e1f4710df3639c58aae32c4cef1dd0333e7478de3dd4c6321034d03a7e6806e734c171be535999239aac76822427c217ee7564ab752cdc12dde53aeffffffff048d40ad120100000017a914fb8e0ce6d2f35c566908fd225b7f96e72df603d3872d5f0000000000001976a914768ac2a2530b2987d2e6506edc71dcf9f0a7b6e688ac00350c00000000001976a91452f28673c5aed9126b91d9eac5cbe1e02276a2cb88ac18b30700000000001976a914f3678c60ec389c7b132b5e5b0e1434b6dcd48f4188ac00000000 > tmpfile
chksum_ref="fb6b467c9fccf610be696cba76277d8b1a38289bbfeac001ce64bace57a67d20"
chksum_prep

echo "=== TESTCASE 10b: " | tee -a $logfile
./tcls_tx2txt.sh -v -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82e9eebf2ae3de232202000000fc0047304402200c2f9e8805de97fa785b93dcc9072197bf5c1095ea536320ed26c645ec3bfafc02202882258f394449f1b1365ce80eed26fbe01217657729664af6827d041e7e98510147304402206d5cbef275b6972bd8cc00aff666a6ca18f09a5b1d1bf49e6966ad815db7119a0220340e49d4b747c9bd8ac80dbe073525c57da43dc4d2727b789be7e66bed9c6d02014c695221037b7c16024e2e6f6575b7a8c55c581dce7effcd6045bdf196461be8ff88db24f1210223eefa59f9b51ca96e1f4710df3639c58aae32c4cef1dd0333e7478de3dd4c6321034d03a7e6806e734c171be535999239aac76822427c217ee7564ab752cdc12dde53aeffffffff048d40ad120100000017a914fb8e0ce6d2f35c566908fd225b7f96e72df603d3872d5f0000000000001976a914768ac2a2530b2987d2e6506edc71dcf9f0a7b6e688ac00350c00000000001976a91452f28673c5aed9126b91d9eac5cbe1e02276a2cb88ac18b30700000000001976a914f3678c60ec389c7b132b5e5b0e1434b6dcd48f4188ac00000000 > tmpfile
chksum_ref="c831950d633d2ff49c2fb8ddc25ce8cb1902a9fa1c28d84ebe5e14cd54ca75f1"
chksum_prep

echo "=== TESTCASE 10c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82e9eebf2ae3de232202000000fc0047304402200c2f9e8805de97fa785b93dcc9072197bf5c1095ea536320ed26c645ec3bfafc02202882258f394449f1b1365ce80eed26fbe01217657729664af6827d041e7e98510147304402206d5cbef275b6972bd8cc00aff666a6ca18f09a5b1d1bf49e6966ad815db7119a0220340e49d4b747c9bd8ac80dbe073525c57da43dc4d2727b789be7e66bed9c6d02014c695221037b7c16024e2e6f6575b7a8c55c581dce7effcd6045bdf196461be8ff88db24f1210223eefa59f9b51ca96e1f4710df3639c58aae32c4cef1dd0333e7478de3dd4c6321034d03a7e6806e734c171be535999239aac76822427c217ee7564ab752cdc12dde53aeffffffff048d40ad120100000017a914fb8e0ce6d2f35c566908fd225b7f96e72df603d3872d5f0000000000001976a914768ac2a2530b2987d2e6506edc71dcf9f0a7b6e688ac00350c00000000001976a91452f28673c5aed9126b91d9eac5cbe1e02276a2cb88ac18b30700000000001976a914f3678c60ec389c7b132b5e5b0e1434b6dcd48f4188ac00000000 > tmpfile
chksum_ref="7f2cff5cfa42a8de99c37946de9bc20e9957d0be02ec4ccb70c405d23b8729c3"
chksum_prep
echo " " | tee -a $logfile
}

testcase11() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 11: *** my first cold storage test ! ***     ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 11a: " | tee -a $logfile
./tcls_tx2txt.sh -u 0100000001bc12683c21e46c380933e83c00ec3929453e3d11cc5a2db9f795372efe03e81d000000001976a914c2df275d78e506e17691fd6f0c63c43d15c897fc88acffffffff01d0a11000000000001976a9140de4457d577bb45dee513bb695bdfdc3b34d467d88ac0000000001000000 > tmpfile
chksum_ref="e9f53124d90f720f7a151b1c3fbb9aaaa6788c72528a12330511ad6a62836ffc"
chksum_prep

echo "=== TESTCASE 11b: " | tee -a $logfile
./tcls_tx2txt.sh -v -u 0100000001bc12683c21e46c380933e83c00ec3929453e3d11cc5a2db9f795372efe03e81d000000001976a914c2df275d78e506e17691fd6f0c63c43d15c897fc88acffffffff01d0a11000000000001976a9140de4457d577bb45dee513bb695bdfdc3b34d467d88ac0000000001000000 > tmpfile
chksum_ref="be31a17266e88cd2323c25a134750ae1430b340f92ebc62fa23c8b1c59ff9d4d"
chksum_prep

echo "=== TESTCASE 11c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -u 0100000001bc12683c21e46c380933e83c00ec3929453e3d11cc5a2db9f795372efe03e81d000000001976a914c2df275d78e506e17691fd6f0c63c43d15c897fc88acffffffff01d0a11000000000001976a9140de4457d577bb45dee513bb695bdfdc3b34d467d88ac0000000001000000 > tmpfile
chksum_ref="d109f2f5ed825dc0367885b4cac2eafaf4c12680145201ffd661352e2e7aeb56"
chksum_prep
echo " " | tee -a $logfile
}

testcase12() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 12: some special trx ...                     ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 12a: the pizza transaction:" | tee -a $logfile
echo "https://blockchain.info/tx/cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79" >> $logfile
echo "http://bitcoin.stackexchange.com/questions/32305/how-does-the-ecdsa-verification-algorithm-work-during-transaction/32308#32308" >> $logfile
echo "./tcls_tx2txt.sh -vv -r 01000000018dd4f5fbd5e980fc02f35c6ce145935b11e284605bf599a13c6d415db55d07a1000000008b4830450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e0141042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabbffffffff0200719a81860000001976a914df1bd49a6c9e34dfa8631f2c54cf39986027501b88ac009f0a5362000000434104cd5e9726e6afeae357b1806be25a4c3d3811775835d235417ea746b7db9eeab33cf01674b944c64561ce3388fa1abd0fa88b06c44ce81e2234aa70fe578d455dac00000000" >> $logfile
./tcls_tx2txt.sh -vv -r 01000000018dd4f5fbd5e980fc02f35c6ce145935b11e284605bf599a13c6d415db55d07a1000000008b4830450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e0141042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabbffffffff0200719a81860000001976a914df1bd49a6c9e34dfa8631f2c54cf39986027501b88ac009f0a5362000000434104cd5e9726e6afeae357b1806be25a4c3d3811775835d235417ea746b7db9eeab33cf01674b944c64561ce3388fa1abd0fa88b06c44ce81e2234aa70fe578d455dac00000000 > tmpfile
chksum_ref="684cd56904655b15e09c8f59c1f2c6b46579aa1780a9da6087674f73609502f6"
chksum_prep

echo "=== TESTCASE 12b: the same pizza tx, but fetched from network" | tee -a $logfile
echo "./tcls_tx2txt.sh -vv -t cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79" >> $logfile
./tcls_tx2txt.sh -vv -t cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79 > tmpfile
chksum_ref="3c95835be8f99784e3667a150c8ac28f24cbb73e4b617acc5b6b2787eca8d069"
chksum_prep

echo "=== TESTCASE 12c: nice tx_out script:" | tee -a $logfile
echo "http://bitcoin.stackexchange.com/questions/48673/confused-about-this-particular-multisig-transaction-with-a-maybe-invalid-scrip" >> $logfile
echo "./tcls_tx2txt.sh -vv -t c49b3c445c89d832289de0fd3b0281efdcce418333dacd028061e8de9f0a6f10" >> $logfile
./tcls_tx2txt.sh -vv -t c49b3c445c89d832289de0fd3b0281efdcce418333dacd028061e8de9f0a6f10 > tmpfile
chksum_ref="190d7a7738895175156337a1f057ca84f3d174cfbbe9c118c8540a7b25474135"
chksum_prep

echo "=== TESTCASE 12d: a NullData (OP_RETURN) tx_out script:" | tee -a $logfile
echo "https://blockexplorer.com/api/rawtx/d29c9c0e8e4d2a9790922af73f0b8d51f0bd4bb19940d9cf910ead8fbe85bc9b" >> $logfile
echo "./tcls_tx2txt.sh -vv -r 01000000016ca9aad181967df29c02384f867ea09b90c41d7cee160bbd857d6a7520f45cb4000000006a473044022062ee7002c5483545b81623495e2fd04691fb7685dbc5251bff7581585037822502203df73a07c242cf0fa1611e4d99604801bf75a93c2fb02ac3defef4c369ea5f040121024ee119308c8a6f8a498e1b34bc9b73d91750a9eb4e749b3f45b34ea58f57de01ffffffff010000000000000000fddb036a4dd7035765277265206e6f20737472616e6765727320746f206c6f76650a596f75206b6e6f77207468652072756c657320616e6420736f20646f20490a412066756c6c20636f6d6d69746d656e74277320776861742049276d207468696e6b696e67206f660a596f7520776f756c646e27742067657420746869732066726f6d20616e79206f74686572206775790a49206a7573742077616e6e612074656c6c20796f7520686f772049276d206665656c696e670a476f747461206d616b6520796f7520756e6465727374616e640a0a43484f5255530a4e6576657220676f6e6e61206769766520796f752075702c0a4e6576657220676f6e6e61206c657420796f7520646f776e0a4e6576657220676f6e6e612072756e2061726f756e6420616e642064657365727420796f750a4e6576657220676f6e6e61206d616b6520796f75206372792c0a4e6576657220676f6e6e612073617920676f6f646279650a4e6576657220676f6e6e612074656c6c2061206c696520616e64206875727420796f750a0a5765277665206b6e6f776e2065616368206f7468657220666f7220736f206c6f6e670a596f75722068656172742773206265656e20616368696e672062757420796f7527726520746f6f2073687920746f207361792069740a496e7369646520776520626f7468206b6e6f7720776861742773206265656e20676f696e67206f6e0a5765206b6e6f77207468652067616d6520616e6420776527726520676f6e6e6120706c61792069740a416e6420696620796f752061736b206d6520686f772049276d206665656c696e670a446f6e27742074656c6c206d6520796f7527726520746f6f20626c696e6420746f20736565202843484f525553290a0a43484f52555343484f5255530a284f6f68206769766520796f75207570290a284f6f68206769766520796f75207570290a284f6f6829206e6576657220676f6e6e6120676976652c206e6576657220676f6e6e6120676976650a286769766520796f75207570290a284f6f6829206e6576657220676f6e6e6120676976652c206e6576657220676f6e6e6120676976650a286769766520796f75207570290a0a5765277665206b6e6f776e2065616368206f7468657220666f7220736f206c6f6e670a596f75722068656172742773206265656e20616368696e672062757420796f7527726520746f6f2073687920746f207361792069740a496e7369646520776520626f7468206b6e6f7720776861742773206265656e20676f696e67206f6e0a5765206b6e6f77207468652067616d6520616e6420776527726520676f6e6e6120706c61792069742028544f2046524f4e54290a0a00000000" >> $logfile
./tcls_tx2txt.sh -vv -r 01000000016ca9aad181967df29c02384f867ea09b90c41d7cee160bbd857d6a7520f45cb4000000006a473044022062ee7002c5483545b81623495e2fd04691fb7685dbc5251bff7581585037822502203df73a07c242cf0fa1611e4d99604801bf75a93c2fb02ac3defef4c369ea5f040121024ee119308c8a6f8a498e1b34bc9b73d91750a9eb4e749b3f45b34ea58f57de01ffffffff010000000000000000fddb036a4dd7035765277265206e6f20737472616e6765727320746f206c6f76650a596f75206b6e6f77207468652072756c657320616e6420736f20646f20490a412066756c6c20636f6d6d69746d656e74277320776861742049276d207468696e6b696e67206f660a596f7520776f756c646e27742067657420746869732066726f6d20616e79206f74686572206775790a49206a7573742077616e6e612074656c6c20796f7520686f772049276d206665656c696e670a476f747461206d616b6520796f7520756e6465727374616e640a0a43484f5255530a4e6576657220676f6e6e61206769766520796f752075702c0a4e6576657220676f6e6e61206c657420796f7520646f776e0a4e6576657220676f6e6e612072756e2061726f756e6420616e642064657365727420796f750a4e6576657220676f6e6e61206d616b6520796f75206372792c0a4e6576657220676f6e6e612073617920676f6f646279650a4e6576657220676f6e6e612074656c6c2061206c696520616e64206875727420796f750a0a5765277665206b6e6f776e2065616368206f7468657220666f7220736f206c6f6e670a596f75722068656172742773206265656e20616368696e672062757420796f7527726520746f6f2073687920746f207361792069740a496e7369646520776520626f7468206b6e6f7720776861742773206265656e20676f696e67206f6e0a5765206b6e6f77207468652067616d6520616e6420776527726520676f6e6e6120706c61792069740a416e6420696620796f752061736b206d6520686f772049276d206665656c696e670a446f6e27742074656c6c206d6520796f7527726520746f6f20626c696e6420746f20736565202843484f525553290a0a43484f52555343484f5255530a284f6f68206769766520796f75207570290a284f6f68206769766520796f75207570290a284f6f6829206e6576657220676f6e6e6120676976652c206e6576657220676f6e6e6120676976650a286769766520796f75207570290a284f6f6829206e6576657220676f6e6e6120676976652c206e6576657220676f6e6e6120676976650a286769766520796f75207570290a0a5765277665206b6e6f776e2065616368206f7468657220666f7220736f206c6f6e670a596f75722068656172742773206265656e20616368696e672062757420796f7527726520746f6f2073687920746f207361792069740a496e7369646520776520626f7468206b6e6f7720776861742773206265656e20676f696e67206f6e0a5765206b6e6f77207468652067616d6520616e6420776527726520676f6e6e6120706c61792069742028544f2046524f4e54290a0a00000000 > tmpfile
chksum_ref="dfbde3e34d329f429faa7d9bfebdfa0d83b23ebc3483a893a6d3c4fc135d8a53"
chksum_prep

echo " " | tee -a $logfile
}


testcase13() {
# this trx has a complicated input script (PK script?)
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 13:                                          ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "===  this trx has 35 output scripts ...                   ===" >> $logfile
echo "=============================================================" >> $logfile
echo "https://blockchain.info/de/rawtx/7c83fe5ba301e655973e9de8eb9fb5e20ef3a6dd9b46c503679c858399eda50f" >> $logfile

echo "=== TESTCASE 13a: 35 outputs" | tee -a $logfile
  ./tcls_tx2txt.sh -r 01000000014675ab74e5c496c8eecaaa87c6136bc68ebaaac7a25e70ee29b7bbaffad6810f000000008b4830450220296d4f4869a63efdee4c5ea31dcad559b4e03332462ba5442bfdf00a662cb77102210088a7f10361eae3e159ae6a8b5b7a569bf6bfa2de64fb3f5d0552f8be568ba6f50141042a9a97b2109ef496ffb1033576a5635cecc6ab679ad0b7c43d33ddf38b1f44c22ea42d5c01ac2752094ff81e79dda77d8b501a64102207c45fb89ea1ad9229ddffffffff23e8030000000000001976a914801314cd462b98c64dd4c3f4d6474cad11ea39d588ace8030000000000001976a9145bb7d22851413e1d61e8db5395a8c7c537256ea088ace8030000000000001976a914371f197d5ba5e32bd98260eec7f0e51227b6969088ace8030000000000001976a9143e546d0acc0de5aa3d66d7a920900ecbc66c203188ace8030000000000001976a9140337e0710056f114c9c469a68775498df9f9fa1688ace8030000000000001976a9149c628c82aa7b81da7c6a235049eb2979c4a65cfc88ace8030000000000001976a914cd1d7e863f891c493e093ada840ef5a67ad2d6cc88ace8030000000000001976a91476f074340381e6f8a40aec4a6e2d92485679412c88ace8030000000000001976a9140fb87a5071385b6976397d1c53ee16f09139a33488ace8030000000000001976a9143d37873ffd2964a1a4c8bade4852020ec5426d3688ace8030000000000001976a9145d14a857fce8da8edfb8f7d1c4bbc316622b722788ace8030000000000001976a9140a77fdb4cc81631b6ea2991ff60b47d57812d8e788ace8030000000000001976a91454514fe9251b5e381d13171cd6fca63f61d8b72688ace8030000000000001976a914cffe3e032a686cc3f2c9e417865afa8a52ed962b88ace8030000000000001976a914fd9dc3525076c1ffe9c33389ea157d07af2e41d488ace8030000000000001976a9143bedfe927d55a8c8adfe5e4b5dddd4ea3487b4c988ace8030000000000001976a914e49275e86ece605f271f26a9559520eb9c0ae8d888ace8030000000000001976a91469256ba90b0d7e406d86a51d343d157ff0aab7bd88ace8030000000000001976a9148ab0cb809cd893cb0cb16f647d024db94f09d76588ace8030000000000001976a9140688e383f02b528c92e25caae5785ffaa81a26aa88ace8030000000000001976a914d959be6c92037995558f43a55b1c271628f96e8d88ac8038f240000000001976a914d15e54e341d538ce3e9e7596e0dbcda8c12cc08988ace8030000000000001976a91495019a8168e8dcd2ef2d47ca57c1bf49358eb6fe88ace8030000000000001976a914caf67cfe28b511498b0d1792bedeec6b6e8a3c8d88ace8030000000000001976a914082a3adf4c8497fbd7d90f21cbec318b0dfdd2b288ace8030000000000001976a9144c53722fd5b0bc8a5b23ae4efc6233142b69d8ee88ace8030000000000001976a9146abd1edce61a7fdd2d134e8468560ecffb45334e88ace8030000000000001976a914dc3343b674cf2016b8968e6146ba5cc9228f14a488ace8030000000000001976a9145f395a91d07712604d7cd6fabd685b9bfd3900dd88ace8030000000000001976a914fc35239072cd5c19d9f761996951679fb03bb43188ace8030000000000001976a914b1ec1d5e0591abbbe3134c94c37e74d034b9312288ace8030000000000001976a9142d6351944aa38af6aa46d4a74cbb9016cf19ee7e88ace8030000000000001976a914879a49b3822806e0322565d457ce2b5989adaa6188ace8030000000000001976a9145ff26e3f8d542c5bb612e539649eaec0222afc3c88ace8030000000000001976a914105d54a4edcbe114a50bb01c79d230b7ed74a3e488ac00000000 > tmpfile
chksum_ref="954fe43bcd26eed94eca2b51a8639beaa4f2f9cb77c7c3ce83fe03864a8b53c9"
chksum_prep

echo "=== TESTCASE 13b: 35 outputs, verbose" | tee -a $logfile
  ./tcls_tx2txt.sh -v -r 01000000014675ab74e5c496c8eecaaa87c6136bc68ebaaac7a25e70ee29b7bbaffad6810f000000008b4830450220296d4f4869a63efdee4c5ea31dcad559b4e03332462ba5442bfdf00a662cb77102210088a7f10361eae3e159ae6a8b5b7a569bf6bfa2de64fb3f5d0552f8be568ba6f50141042a9a97b2109ef496ffb1033576a5635cecc6ab679ad0b7c43d33ddf38b1f44c22ea42d5c01ac2752094ff81e79dda77d8b501a64102207c45fb89ea1ad9229ddffffffff23e8030000000000001976a914801314cd462b98c64dd4c3f4d6474cad11ea39d588ace8030000000000001976a9145bb7d22851413e1d61e8db5395a8c7c537256ea088ace8030000000000001976a914371f197d5ba5e32bd98260eec7f0e51227b6969088ace8030000000000001976a9143e546d0acc0de5aa3d66d7a920900ecbc66c203188ace8030000000000001976a9140337e0710056f114c9c469a68775498df9f9fa1688ace8030000000000001976a9149c628c82aa7b81da7c6a235049eb2979c4a65cfc88ace8030000000000001976a914cd1d7e863f891c493e093ada840ef5a67ad2d6cc88ace8030000000000001976a91476f074340381e6f8a40aec4a6e2d92485679412c88ace8030000000000001976a9140fb87a5071385b6976397d1c53ee16f09139a33488ace8030000000000001976a9143d37873ffd2964a1a4c8bade4852020ec5426d3688ace8030000000000001976a9145d14a857fce8da8edfb8f7d1c4bbc316622b722788ace8030000000000001976a9140a77fdb4cc81631b6ea2991ff60b47d57812d8e788ace8030000000000001976a91454514fe9251b5e381d13171cd6fca63f61d8b72688ace8030000000000001976a914cffe3e032a686cc3f2c9e417865afa8a52ed962b88ace8030000000000001976a914fd9dc3525076c1ffe9c33389ea157d07af2e41d488ace8030000000000001976a9143bedfe927d55a8c8adfe5e4b5dddd4ea3487b4c988ace8030000000000001976a914e49275e86ece605f271f26a9559520eb9c0ae8d888ace8030000000000001976a91469256ba90b0d7e406d86a51d343d157ff0aab7bd88ace8030000000000001976a9148ab0cb809cd893cb0cb16f647d024db94f09d76588ace8030000000000001976a9140688e383f02b528c92e25caae5785ffaa81a26aa88ace8030000000000001976a914d959be6c92037995558f43a55b1c271628f96e8d88ac8038f240000000001976a914d15e54e341d538ce3e9e7596e0dbcda8c12cc08988ace8030000000000001976a91495019a8168e8dcd2ef2d47ca57c1bf49358eb6fe88ace8030000000000001976a914caf67cfe28b511498b0d1792bedeec6b6e8a3c8d88ace8030000000000001976a914082a3adf4c8497fbd7d90f21cbec318b0dfdd2b288ace8030000000000001976a9144c53722fd5b0bc8a5b23ae4efc6233142b69d8ee88ace8030000000000001976a9146abd1edce61a7fdd2d134e8468560ecffb45334e88ace8030000000000001976a914dc3343b674cf2016b8968e6146ba5cc9228f14a488ace8030000000000001976a9145f395a91d07712604d7cd6fabd685b9bfd3900dd88ace8030000000000001976a914fc35239072cd5c19d9f761996951679fb03bb43188ace8030000000000001976a914b1ec1d5e0591abbbe3134c94c37e74d034b9312288ace8030000000000001976a9142d6351944aa38af6aa46d4a74cbb9016cf19ee7e88ace8030000000000001976a914879a49b3822806e0322565d457ce2b5989adaa6188ace8030000000000001976a9145ff26e3f8d542c5bb612e539649eaec0222afc3c88ace8030000000000001976a914105d54a4edcbe114a50bb01c79d230b7ed74a3e488ac00000000 > tmpfile
chksum_ref="048985009675a347422d281dbcc25197605dfd16d819e20003bd7db3d214066b"
chksum_prep

echo "=== TESTCASE 13c: 35 outputs, very verbose" | tee -a $logfile
  ./tcls_tx2txt.sh -vv -r 01000000014675ab74e5c496c8eecaaa87c6136bc68ebaaac7a25e70ee29b7bbaffad6810f000000008b4830450220296d4f4869a63efdee4c5ea31dcad559b4e03332462ba5442bfdf00a662cb77102210088a7f10361eae3e159ae6a8b5b7a569bf6bfa2de64fb3f5d0552f8be568ba6f50141042a9a97b2109ef496ffb1033576a5635cecc6ab679ad0b7c43d33ddf38b1f44c22ea42d5c01ac2752094ff81e79dda77d8b501a64102207c45fb89ea1ad9229ddffffffff23e8030000000000001976a914801314cd462b98c64dd4c3f4d6474cad11ea39d588ace8030000000000001976a9145bb7d22851413e1d61e8db5395a8c7c537256ea088ace8030000000000001976a914371f197d5ba5e32bd98260eec7f0e51227b6969088ace8030000000000001976a9143e546d0acc0de5aa3d66d7a920900ecbc66c203188ace8030000000000001976a9140337e0710056f114c9c469a68775498df9f9fa1688ace8030000000000001976a9149c628c82aa7b81da7c6a235049eb2979c4a65cfc88ace8030000000000001976a914cd1d7e863f891c493e093ada840ef5a67ad2d6cc88ace8030000000000001976a91476f074340381e6f8a40aec4a6e2d92485679412c88ace8030000000000001976a9140fb87a5071385b6976397d1c53ee16f09139a33488ace8030000000000001976a9143d37873ffd2964a1a4c8bade4852020ec5426d3688ace8030000000000001976a9145d14a857fce8da8edfb8f7d1c4bbc316622b722788ace8030000000000001976a9140a77fdb4cc81631b6ea2991ff60b47d57812d8e788ace8030000000000001976a91454514fe9251b5e381d13171cd6fca63f61d8b72688ace8030000000000001976a914cffe3e032a686cc3f2c9e417865afa8a52ed962b88ace8030000000000001976a914fd9dc3525076c1ffe9c33389ea157d07af2e41d488ace8030000000000001976a9143bedfe927d55a8c8adfe5e4b5dddd4ea3487b4c988ace8030000000000001976a914e49275e86ece605f271f26a9559520eb9c0ae8d888ace8030000000000001976a91469256ba90b0d7e406d86a51d343d157ff0aab7bd88ace8030000000000001976a9148ab0cb809cd893cb0cb16f647d024db94f09d76588ace8030000000000001976a9140688e383f02b528c92e25caae5785ffaa81a26aa88ace8030000000000001976a914d959be6c92037995558f43a55b1c271628f96e8d88ac8038f240000000001976a914d15e54e341d538ce3e9e7596e0dbcda8c12cc08988ace8030000000000001976a91495019a8168e8dcd2ef2d47ca57c1bf49358eb6fe88ace8030000000000001976a914caf67cfe28b511498b0d1792bedeec6b6e8a3c8d88ace8030000000000001976a914082a3adf4c8497fbd7d90f21cbec318b0dfdd2b288ace8030000000000001976a9144c53722fd5b0bc8a5b23ae4efc6233142b69d8ee88ace8030000000000001976a9146abd1edce61a7fdd2d134e8468560ecffb45334e88ace8030000000000001976a914dc3343b674cf2016b8968e6146ba5cc9228f14a488ace8030000000000001976a9145f395a91d07712604d7cd6fabd685b9bfd3900dd88ace8030000000000001976a914fc35239072cd5c19d9f761996951679fb03bb43188ace8030000000000001976a914b1ec1d5e0591abbbe3134c94c37e74d034b9312288ace8030000000000001976a9142d6351944aa38af6aa46d4a74cbb9016cf19ee7e88ace8030000000000001976a914879a49b3822806e0322565d457ce2b5989adaa6188ace8030000000000001976a9145ff26e3f8d542c5bb612e539649eaec0222afc3c88ace8030000000000001976a914105d54a4edcbe114a50bb01c79d230b7ed74a3e488ac00000000 > tmpfile
chksum_ref="0d7706c6db370f43d590806fa4a5e4e53fe293dfdd1d5b720fd3b269d2421bea"
chksum_prep
echo " " | tee -a $logfile
}

testcase14() {
# this trx has a complicated input script (PK script?)
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 14:                                          ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "===  working with the TESTNET                             ===" >> $logfile
echo "=============================================================" >> $logfile
echo "=== TESTCASE 14a: TESTNET addresses" | tee -a $logfile

./tcls_tx2txt.sh -T -vv -r 0100000001fc93e12cfbabe8383eba3c8c22d26c8ee941e9d1d98da0cf4f213e62e1ead47500000000fdfd0000473044022041ffcc40daaa2376a505132c63a1df4ea636650facbc870df460625c0661c62802202a03ac32d8bd8c67474c522245a06a79ced9e326e1266b914d2bcacaaa24860e01483045022100ffb0117cf0e8d0d0689f5adf6c5006212728901c07405dfa0cafcc42c9cbe7d6022044d168e217dc50f148ae3aee632e246554d2f9b57b53a2f18e8a68a3036e5a78014c69522103834bd129bf0a2e03d53b74bc2eef8d9a5faed93f37b4938ae7127d430804a3cf2103fae2fa202fbfd9d0a8650f537df154158761ce9ad2460793aed74b946babb9f421038cbc733032dcbed878c727840bef9c2aeb01447e1701c372c46a2ef00f48e02c53aeffffffff01638e582e000000001976a914431c4b76510347bb5f12907a819365f5e2834a1188ac00000000 > tmpfile
chksum_ref="76d6f7568f76213f63e9376a7d9d5612da9d8344a0c59b9866078a4d7d4d3456"
chksum_prep
echo " " | tee -a $logfile
} 

testcase20() {
# this trx has +50 P2SH signatures and takes a long time to decode
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 20: check very long tx                       ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== trx 20a has +117 txin                                 ===" >> $logfile
echo "=== trx 20a has +50 P2SH signatures                       ===" >> $logfile
echo "=============================================================" >> $logfile
echo "=== TESTCASE 20a: +117 txin ... " | tee -a $logfile
./tcls_tx2txt.sh -vv -t 19312fd6b177257bbc90187040066c3b1e2a398dfa953658d5d068f2119ad45f > tmpfile
chksum_ref="0d596da80b23c0f9db53ee1ab7fb7e28938be8cd6526598caaa8797fb58707a8"
chksum_prep

echo "=== TESTCASE 20b: +50 P2SH addresses" | tee -a $logfile
./tcls_tx2txt.sh -vv -t 1a96838d65a724bee4addcd74b5cef8102fa6e4f5058f73f53c8134021db407a > tmpfile
chksum_ref="0d596da80b23c0f9db53ee1ab7fb7e28938be8cd6526598caaa8797fb58707a8"
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
  testcase13
  testcase14
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
  1|2|3|4|5|6|7|8|9|10|11|12|13|14|20)
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

