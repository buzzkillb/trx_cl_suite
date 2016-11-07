#!/bin/sh
# some testcases for the shell script "trx_verify_sig.sh" 
#
# Copyright (c) 2015, 2016 Volker Nowarra 
# initial release in Nov 2016
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
  cat tmp_trx_cfile >> $logfile
  echo " " >> $logfile
}

chksum_prep() {
result=$( $chksum_cmd tmp_trx_cfile | cut -d " " -f 2 )
# echo $result | cut -d " " -f 2 >> $logfile
chksum_verify "$result" "$chksum_ref" 
if [ $LOG -eq 1 ] ; then to_logfile ; fi
}

testcase1() {
# first get the checksums of all necessary files
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 1: get the checksums of all necessary files     ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile

echo "   " | tee -a $logfile
echo "=== TESTCASE 1a: $chksum_cmd tcls_verify_sig.sh" | tee -a $logfile
echo "================================================================" | tee -a $logfile
cp tcls_verify_sig.sh tmp_trx_cfile
chksum_ref="9471debb4d64d3b62a8d0baf72c53a9ad5e256b63f7765dfeacd513171a9911c" 
chksum_prep

echo "   " | tee -a $logfile
echo "=== TESTCASE 1b: $chksum_cmd trx_key2pem.sh" | tee -a $logfile
echo "================================================================" | tee -a $logfile
cp tcls_key2pem.sh tmp_trx_cfile
chksum_ref="8dca870afad8078744bd22e8dfa73ff79009b03960bf2a756ee45b580c03f2a6" 
chksum_prep

echo "   " | tee -a $logfile
echo "=== TESTCASE 1c: $chksum_cmd trx_strict_sig_verify.sh" | tee -a $logfile
echo "================================================================" | tee -a $logfile
cp tcls_strict_sig_verify.sh tmp_trx_cfile
chksum_ref="78126a731aa727bf9a3b9168d686192ed9e8561a511586bfbc9518e04439ce1b"
chksum_prep

echo " " | tee -a $logfile
}

testcase2() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 2: parameters testing ...                       ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 2a: check -p, -s and -d params"                      | tee -a $logfile
echo "================================================================" | tee -a $logfile

echo " " | tee -a $logfile
}

testcase3() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 3: the pizza transaction ...                    ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 3a: pizza, quiet operation..."                       | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "http://bitcoin.stackexchange.com/questions/32305/how-does-the-ecdsa-verification-algorithm-work-during-transaction/32308#32308"
echo "./tcls_verify_sig.sh -d c2d48f45d7fbeff644ddb72b0f60df6c275f0943444d7df8cc851b3d55782669 -p 042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabb -s 30450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e" >> $logfile
./tcls_verify_sig.sh -d c2d48f45d7fbeff644ddb72b0f60df6c275f0943444d7df8cc851b3d55782669  -p 042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabb -s 30450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e > tmp_trx_cfile
chksum_ref="0bd65ea014d3210c1b9a7d7d5af78bc4e4b4384b4f3f7f5674e8d6447e4112c3"
chksum_prep

echo "=== TESTCASE 3b: pizza, be a bit more verbose..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "./tcls_verify_sig.sh -v -d c2d48f45d7fbeff644ddb72b0f60df6c275f0943444d7df8cc851b3d55782669 -p 042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabb -s 30450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e" >> $logfile
./tcls_verify_sig.sh -v -d c2d48f45d7fbeff644ddb72b0f60df6c275f0943444d7df8cc851b3d55782669  -p 042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabb -s 30450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e > tmp_trx_cfile 
chksum_ref="89fda5b2d0d818c65b39f9790af4076235ee62b58282a6e704750ac63d9809d7" 
chksum_prep

echo "=== TESTCASE 3c: pizza, be very verbose..." | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "./tcls_verify_sig.sh -vv -d c2d48f45d7fbeff644ddb72b0f60df6c275f0943444d7df8cc851b3d55782669 -p 042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabb -s 30450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e" >> $logfile
./tcls_verify_sig.sh -vv -d c2d48f45d7fbeff644ddb72b0f60df6c275f0943444d7df8cc851b3d55782669  -p 042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabb -s 30450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e > tmp_trx_cfile 
chksum_ref="a5db7b8376f7f5d341d11545f7958ab6f24e560765a03b5d124d785665fad745" 
chksum_prep

echo " " | tee -a $logfile
}

testcase4() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 4: the 4inputs transaction ...                  ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 4a: quiet operation..."                              | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "./tcls_verify_sig.sh -p 03cc5debc62369bd861900b167bc6add5f1a6249bdab4146d5ce698879988dced0 -s 3045022100f7efb33524d389dbecae54ba0d6555503eaeb5d6b0e6b4e20b5fcbaa92e8edd202203d6867c0fcf8586c6f3837d3ef0016318a3776792d132e6ac3e8874f58dcc2da -d 22d7437e4646e67ec050d59128a5eb713bca8b4d6d2d7bdfbab43f6140e2360b" >> $logfile
./tcls_verify_sig.sh -p 03cc5debc62369bd861900b167bc6add5f1a6249bdab4146d5ce698879988dced0 -s 3045022100f7efb33524d389dbecae54ba0d6555503eaeb5d6b0e6b4e20b5fcbaa92e8edd202203d6867c0fcf8586c6f3837d3ef0016318a3776792d132e6ac3e8874f58dcc2da -d 22d7437e4646e67ec050d59128a5eb713bca8b4d6d2d7bdfbab43f6140e2360b > tmp_trx_cfile
chksum_ref="1c7b9b16cd50e9a66f69fadb455273e7a361a370b21eff99bccb96b80b7c2818" 
chksum_prep

echo " " | tee -a $logfile
}



all_testcases() {
  testcase1 
  testcase2 
  testcase3 
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
  chksum_cmd="openssl dgst -sha256"
fi

################################
# command line params handling #
################################

if [ $# -eq 0 ] ; then
  all_testcases
fi

if [ $# -eq 1 ] && [ "$1" == "-l" ] ; then
  LOG=1
  shift
  all_testcases
fi

while [ $# -ge 1 ] 
 do
  case "$1" in
  -h)
     echo "usage: $0 -h|-l [1-9]"
     echo "  "
     echo "script does several testcases, mostly with checksums for verification"
     echo "  "
     exit 0
     ;;
  -l)
     LOG=1
     shift
     ;;
  1|2|3|4|5|6|7|8|9)
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

