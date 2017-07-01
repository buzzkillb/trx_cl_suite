#!/bin/sh
##############################################################################
# Read the bitcoin script_SIG OPCODES from a transaction's TRX_IN 
# script by Sven-Volker Nowarra 
# 
# Version by	date	comment
# 0.1	  svn	21sep16 initial release, code from trx2txt (discontinued)
# 0.2	  svn	30mar17 added logic for TESTNET
# 0.3	  svn	27jun17 replace "echo xxx | cut -b ..." with ss_array
# 
# Copyright (c) 2015, 2016 Volker Nowarra 
# Complete rewrite of code in June 2016 from following reference:
#   https://en.bitcoin.it/wiki/Protocol_specification#tx
#   https://en.bitcoin.it/wiki/Script
# 
# Permission to use, copy, modify, and distribute this software for any 
# purpose with or without fee is hereby granted, provided that the above 
# copyright notice and this permission notice appear in all copies. 
# 
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES 
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY 
# SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER 
# RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, 
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE 
# USE OR PERFORMANCE OF THIS SOFTWARE. 
#
#
#  * See https://bitcointalk.org/index.php?topic=8392.0
#  ...
#  a valid bitcoin signature (r,s) is going to look like
#  <30><len><02><len><r bytes><02><len><s bytes><01>
#  where the r and s values are non-negative, and don't exceed 33 bytes 
#  including a possible padding zero byte.
#
# from: https://bitcointalk.org/index.php?topic=1383883.0
#  Unless the bottom 5 bits are 0x02 (SIGHASH_NONE) or 0x03 (SIGHASH_SINGLE), 
#  all the outputs are included.  If the bit for 0x20 is set, then all inputs 
#  are blanked except the current input (SIGHASH_ANYONE_CAN_PAY).
#  SIGHASH_ALL = 1,
#  SIGHASH_NONE = 2,
#  SIGHASH_SINGLE = 3,
#  SIGHASH_ANYONECANPAY = 0x80
# 

typeset -i ss_array_ptr=0
typeset -i sig_offset=0
typeset -i cur_opcode_dec
offset=1
msig_redeem_str=''
output=''
opcode=''
ret_string=''
sig_string=''

Quiet=0
Verbose=0
VVerbose=0
TESTNET=0
param=483045022100A428348FF55B2B59BC55DDACB1A00F4ECDABE282707BA5185D39FE9CDF05D7F0022074232DAE76965B6311CEA2D9E5708A0F137F4EA2B0E36D0818450C67C9BA259D0121025F95E8A33556E9D7311FA748E9434B333A4ECFB590C773480A196DEAB0DEDEE1

#################################
### Some procedures first ... ###
#################################

v_output() {
  if [ $Verbose -eq 1 ] ; then
    echo "$1"
  fi
}

vv_output() {
  if [ $VVerbose -eq 1 ] ; then
    echo "$1"
  fi
}

#####################
### rmd160_sha256 ###
#####################
# supporting web sites:
# https://en.bitcoin.it/wiki/
# Technical_background_of_version_1_Bitcoin_addresses#How_to_create_Bitcoin_Address
# http://gobittest.appspot.com/Address
rmd160_sha256() {
  result=$( echo $ret_string | sed 's/[[:xdigit:]]\{2\}/\\x&/g' )
  result=$( printf "$result" | openssl dgst -sha256 | cut -d " " -f 2 )
  result=$( echo $result | sed 's/[[:xdigit:]]\{2\}/\\x&/g' )
  result=$( printf "$result" | openssl dgst -rmd160 | cut -d " " -f 2 )
}

####################################################################
### procedure to show redeem script properly separted with colon ###
####################################################################
show_redeem_script() {
  result=$( echo "00$1" | sed 's/[[:xdigit:]]\{2\}/& /g' )
  if [ "$shell_string" == "bash" ] ; then
    declare -a rs_array
    rs_array_ptr=0
    for TX_Char in $result; do rs_array[$rs_array_ptr]=$TX_Char; ((rs_array_ptr++)); done
  else 
    set -A rs_array $result
  fi
  rs_array_ptr=1 
  printf "        "
  while [ $rs_array_ptr -lt ${#rs_array[*]} ]
   do
    opcode=${rs_array[$rs_array_ptr]} 
    # modulus 8 and modulus 16 to beautify output:
    if [ $(( $rs_array_ptr % 16 )) -eq 0 ]; then
      printf "%s\n        " $opcode
    elif [ $(( $rs_array_ptr % 8 )) -eq 0 ]; then
      printf "%s:" $opcode
    else
      printf "%s" $opcode
    fi
    rs_array_ptr=$(( $rs_array_ptr + 1 ))
  done 
  printf "\n"
  # echo "*** rs_array_ptr=$rs_array_ptr"
}

############################################################
### procedure to show data separated by colon or newline ###
############################################################
op_data_show() {
  n=1
  output=
  while [ $n -le $cur_opcode_dec ]
   do
    opcode=${ss_array[$ss_array_ptr]} 
    ss_array_ptr=$(( $ss_array_ptr + 1 ))
    output=$output$opcode
    sig_string=$sig_string$opcode
    ret_string=$ret_string$opcode
    if [ $n -eq 8 ]  || [ $n -eq 24 ] || [ $n -eq 40 ] || \
       [ $n -eq 56 ] || [ $n -eq 72 ] || [ $n -eq 88 ] || [ $n -eq 104 ] ; then 
      output=$output":"
    elif [ $n -eq 16 ] || [ $n -eq 32 ] || [ $n -eq 48 ] || \
         [ $n -eq 64 ] || [ $n -eq 80 ] || [ $n -eq 96 ] || [ $n -eq 112 ] ; then 
      echo "        $output" 
      output=
      opcode=
    fi
    n=$(( n + 1 ))
    offset=$(( offset + 2 ))
  done 

  if [ $cur_opcode_dec -ne 32 ] ; then
    echo "        $opcode" 
  fi
}

#####################
### GET NEXT CODE ###
#####################
get_next_opcode() {
  cur_opcode=$( printf ${ss_array[$ss_array_ptr]} )
  ss_array_ptr=$(( $ss_array_ptr + 1 ))
  cur_hexcode="0x"$cur_opcode
  cur_opcode_dec=$( echo "ibase=16;$cur_opcode" | bc )
  sig_string=$sig_string$cur_opcode
}

#####################################
### STATUS 1 (S1_SIG_LEN_0x47)    ###
#####################################
S1_SIG_LEN_0x47() {
  vv_output "S1_SIG_LEN_0x47"
  get_next_opcode
  case $cur_opcode in
    30) echo "    $cur_opcode: OP_SEQUENCE_0x30: type tag indicating SEQUENCE, begin sigscript"
        sig_string=$cur_opcode
        S5_Sigtype
        ;;
    52) echo "    $cur_opcode: OP_2, we go multisig"
        # in case we go for msig, then length of msig is length of 
        # previous char - which was 0x47 Bytes (hex47=71dec, --> 142 chars)
        msig_len=142
        ret_string=''
        msig_redeem_str=$cur_opcode
        S30_MSIG2of2
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 2 (S2_SIG_LEN_0x48)    ###
#####################################
S2_SIG_LEN_0x48() {
  vv_output "S2_SIG_LEN_0x48" 
  get_next_opcode
  case $cur_opcode in
    30) echo "    $cur_opcode: OP_SEQUENCE_0x30: type tag indicating SEQUENCE, begin sigscript"
        sig_string=$cur_opcode
        S12_Sigtype
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 3 (S3_SIG_LEN_0x21)    ###
#####################################
S3_SIG_LEN_0x21() {
  vv_output "S3_SIG_LEN_0x21"
  get_next_opcode
  case $cur_opcode in
    02) echo "    $cur_opcode: OP_INT_0x02:      type tag indicating INTEGER"
        ret_string=02
        S19_PK   
        ;;
    03) echo "    $cur_opcode: OP_INT_0x03"
        ret_string=03
        S19_PK   
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 4 (S4_SIG_LEN_0x41)    ###
#####################################
S4_SIG_LEN_0x41() {
  vv_output "S4_SIG_LEN_0x41"
  get_next_opcode
  case $cur_opcode in
    04) echo "    $cur_opcode: OP_LENGTH_0X04"
        ret_string=04
        S20_PK 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 5 (S5_Sigtype)        ###
#####################################
S5_Sigtype() {
  get_next_opcode
  case $cur_opcode in
    44) echo "    $cur_opcode: OP_LENGTH_0x44:   length of R + S"
        S6_Length 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 6 (S6_Length)          ###
#####################################
S6_Length() {
  get_next_opcode
  case $cur_opcode in
    01) echo "    $cur_opcode: OP_SIGHASHALL:    this terminates the ECDSA signature (ASN1-DER structure)"
        S11_SIG 
        ;;
    02) echo "    $cur_opcode: OP_INT_0x02:      type tag indicating INTEGER"
        S7_R_Length 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 7 (S7_R_Length)        ###
#####################################
S7_R_Length() {
  get_next_opcode
  case $cur_opcode in
    20) echo "    $cur_opcode: OP_LENGTH_0x20:   this is SIG R"
        op_data_show
        S8_SIG_R
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        if [ $cur_opcode_dec -eq 0 ] ; then 
          echo "*** Zero-length integers are not allowed for R."
        fi
#     // Negative numbers are not allowed for R.
#     if (sig[lenR + 6] & 0x80) return false;
        ;;
  esac
}
#####################################
### STATUS 8 (S8_SIG_R)           ###
#####################################
S8_SIG_R() {
  get_next_opcode
  case $cur_opcode in
    02) echo "    $cur_opcode: OP_S_INT_0x02"
        S9_S_Length 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 9 (S9_S_Length)        ###
#####################################
S9_S_Length() {
  get_next_opcode
  case $cur_opcode in
    20) echo "    $cur_opcode: OP_LENGTH_0x20:   this is SIG S"
        op_data_show 
        S10_SIG_S
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        if [ $cur_opcode_dec -eq 0 ] ; then 
          echo "*** Zero-length integers are not allowed for S."
        fi
#     // Negative numbers are not allowed for S.
#     if (sig[lenR + 6] & 0x80) return false;
        ;;
  esac
}
#####################################
### STATUS 10 (S10_SIG_S)         ###
#####################################
S10_SIG_S() {
  get_next_opcode
  case $cur_opcode in
    01) echo "    $cur_opcode: OP_SIGHASHALL:    this terminates the ECDSA signature (ASN1-DER structure)"
        S11_SIG 
        ;;
    02) echo "    $cur_opcode: OP_SIGHASHNONE:   this terminates the ECDSA signature (ASN1-DER structure)"
        S11_SIG 
        ;;
    03) echo "    $cur_opcode: OP_SIGHASHSINGLE: this terminates the ECDSA signature (ASN1-DER structure)"
        S11_SIG 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 11 (S11_SIG)           ###
#####################################
S11_SIG() {
    if [ $Verbose -eq 1 ] ; then
      ./tcls_strict_sig_verify.sh -v $sig_string
    else
      ./tcls_strict_sig_verify.sh -q $sig_string
    fi
}
#####################################
### STATUS 12 (S12_Sigtype)      ###
#####################################
S12_Sigtype () {
  get_next_opcode
  case $cur_opcode in
    44) echo "    $cur_opcode: OP_LENGTH_0x44:   length of R + S"
        S13_Length
        ;;
    45) echo "    $cur_opcode: OP_LENGTH_0x45:   length of R + S"
        S13_Length
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 13 (S13_Length)        ###
#####################################
S13_Length() {
  get_next_opcode
  case $cur_opcode in
    02) echo "    $cur_opcode: OP_INT_0x02:      type tag indicating INTEGER"
        S14_R_Length 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 14 ()                  ###
#####################################
S14_R_Length() {
  get_next_opcode
  case $cur_opcode in
    20) echo "    $cur_opcode: OP_LENGTH_0x20:   this is SIG R"
        op_data_show
        S15_SIG_R 
        ;;
    21) echo "    $cur_opcode: OP_LENGTH_0x21:   this is SIG R"
        op_data_show
        S15_SIG_R 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        if [ $cur_opcode_dec -eq 0 ] ; then 
          echo "*** Zero-length integers are not allowed for R."
        fi
#     // Negative numbers are not allowed for R.
#     if (sig[lenR + 6] & 0x80) return false;
        ;;
  esac
}
#####################################
### STATUS 15 (S15_SIG_R)         ###
#####################################
S15_SIG_R() {
  get_next_opcode
  case $cur_opcode in
    02) echo "    $cur_opcode: OP_INT_0x02:      type tag indicating INTEGER"
        S16_S_Length 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 16 (S16_S_Length)      ###
#####################################
S16_S_Length() {
  get_next_opcode
  case $cur_opcode in
    20) echo "    $cur_opcode: OP_LENGTH_0x20:   this is SIG S"
        op_data_show
        S17_SIG_S
        ;;
    21) echo "    $cur_opcode: OP_LENGTH_0x20:   this is SIG S"
        op_data_show
        S17_SIG_S
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        if [ $cur_opcode_dec -eq 0 ] ; then 
          echo "*** Zero-length integers are not allowed for S."
        fi
#     // Negative numbers are not allowed for S.
#     if (sig[lenR + 6] & 0x80) return false;
        ;;
  esac
}
#####################################
### STATUS 17 (S17_SIG_S)         ###
#####################################
S17_SIG_S() {
  get_next_opcode
  case $cur_opcode in
    01) echo "    $cur_opcode: OP_SIGHASHALL:    this terminates the ECDSA signature (ASN1-DER structure)"
        S18_SIG 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 18 (S18_SIG)           ###
#####################################
S18_SIG() {
    if [ $Verbose -eq 1 ] ; then
      ./tcls_strict_sig_verify.sh -v $sig_string
    else
      ./tcls_strict_sig_verify.sh -q $sig_string
    fi
}
#####################################
### STATUS 19 (S19_PK)            ###
#####################################
S19_PK() {
    vv_output "S19_PK"
    cur_opcode_dec=33
    op_data_show
    echo "    * This terminates the Public Key (X9.63 COMPRESSED form)"
    echo "    * corresponding bitcoin address is:"
    rmd160_sha256
    if [ $TESTNET -eq 1 ] ; then
      ./tcls_base58check_enc.sh -T -q -p2pkh $result
    else
      ./tcls_base58check_enc.sh -q -p2pkh $result
    fi
    ret_string=''
}
#####################################
### STATUS 20 ()                  ###
#####################################
S20_PK() {
    vv_output S20_PK
    cur_opcode_dec=65
    op_data_show
    echo "    * This terminates the Public Key (X9.63 UNCOMPRESSED form)"
    echo "    * corresponding bitcoin address is:"
    rmd160_sha256
    if [ $TESTNET -eq 1 ] ; then
      ./tcls_base58check_enc.sh -T -q -p2pkh $result
    else
      ./tcls_base58check_enc.sh -q -p2pkh $result
    fi
    ret_string=''
}
#####################################
### STATUS 21 (S21_SIG_LEN_0x49)  ###
#####################################
S21_SIG_LEN_0x49() {
  # if [ $Quiet -eq 0 ] ; then echo "S21_SIG_LEN_0x49"; fi
  get_next_opcode
  case $cur_opcode in
    30) echo "    $cur_opcode: OP_SEQUENCE_0x30: type tag indicating SEQUENCE, begin sigscript"
        sig_string=$cur_opcode
        S22_Sigtype
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 22 (S22_Sigtype)       ###
#####################################
S22_Sigtype () {
  get_next_opcode
  case $cur_opcode in
    46) echo "    $cur_opcode: OP_LENGTH_0x46:   length of R + S"
        S23_Length
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 23 (S23_Length)        ###
#####################################
S23_Length() {
  get_next_opcode
  case $cur_opcode in
    02) echo "    $cur_opcode: OP_INT_0x02:      type tag indicating INTEGER"
        S14_R_Length 
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 24 (S24_SIG_LEN_0x3C)  ###
#####################################
S24_SIG_LEN_0x3C() {
  # if [ $Quiet -eq 0 ] ; then echo "S21_SIG_LEN_0x49"; fi
  get_next_opcode
  case $cur_opcode in
    30) echo "    $cur_opcode: OP_SEQUENCE_0x30: type tag indicating SEQUENCE, begin sigscript"
        sig_string=$cur_opcode
        S25_Sigtype
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 25 (S25_Sigtype)       ###
#####################################
S25_Sigtype () {
  get_next_opcode
  case $cur_opcode in
    39) echo "    $cur_opcode: OP_LENGTH_0x39:   length of R + S"
        S26_Length
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 26 (S26_Length)        ###
#####################################
S26_Length() {
  get_next_opcode
  case $cur_opcode in
    02) echo "    $cur_opcode: OP_INT_0x02:      type tag indicating INTEGER"
        S27_X_Length
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 27 (S27_SIG_X)         ###
#####################################
S27_X_Length() {
  get_next_opcode
  case $cur_opcode in
    15) echo "    $cur_opcode: OP_INT_0x15:   this is SIG X"
        op_data_show 
        S28_SIG_X
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 28 (S28_Y_Length)      ###
#####################################
S28_SIG_X() {
  get_next_opcode
  case $cur_opcode in
    02) echo "    $cur_opcode: OP_LENGTH_0x02"
        S16_S_Length
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
#####################################
### STATUS 30 (S30_MSIG2of2)      ###
#####################################
S30_MSIG2of2() {
  vv_output "S30_MSIG2of2()"
  rs_loopcounter=1
  # two of two msig, expecting 2 pubkeys, OP_2 and OP_CHECKMULTISIG
  while [ $rs_loopcounter -le 4 ]  
   do
    get_next_opcode
    msig_redeem_str=$msig_redeem_str$cur_opcode
    case $cur_opcode in
      21) echo "    $cur_opcode: OP_DATA_0x21: compressed pub key"
          op_data_show
          echo "        This is MultiSig's Public Key (X9.63 COMPRESSED form)"
          printf "        corresponding bitcoin address is: "
          rmd160_sha256
          if [ $TESTNET -eq 1 ] ; then
            ./tcls_base58check_enc.sh -T -q -p2pkh $result
          else
            ./tcls_base58check_enc.sh -q -p2pkh $result
          fi
          msig_redeem_str=$msig_redeem_str$ret_string
          # vv_output "        msig_redeem_str=$msig_redeem_str"
          ret_string=''
          ;;
      41) echo "    $cur_opcode: OP_DATA_0x41: uncompressed pub key"
          op_data_show
          echo "        This is MultiSig's Public Key (X9.63 UNCOMPRESSED form)"
          printf "        corresponding bitcoin address is: "
          rmd160_sha256
          if [ $TESTNET -eq 1 ] ; then
            ./tcls_base58check_enc.sh -T -q -p2pkh $result
          else
            ./tcls_base58check_enc.sh -q -p2pkh $result
          fi
          msig_redeem_str=$msig_redeem_str$ret_string
          # vv_output "        msig_redeem_str=$msig_redeem_str"
          ret_string=''
          ;;
      52) echo "    $cur_opcode: OP_2: push 2 Bytes onto stack"
          echo "        Multisig needs 2 pubkeys"
          ;;
      AE) echo "    $cur_opcode: OP_CHECKMULTISIG, terminating multisig, REDEEM Script:"
          show_redeem_script $msig_redeem_str
          ret_string=$msig_redeem_str
          printf "        corresponding bitcoin address is: "
          rmd160_sha256
          if [ $TESTNET -eq 1 ] ; then
            ./tcls_base58check_enc.sh -T -q -p2sh $result
          else
            ./tcls_base58check_enc.sh -q -p2sh $result
          fi
          ret_string=''
          msig_redeem_str=''
          break
          ;;
      *)  echo "    $cur_opcode: unknown OpCode"
          ;;
    esac
    rs_loopcounter=$(( rs_loopcounter + 1 ))
  done
}
############################
### STATUS 35 (MSIG ...) ###
############################
S35_MSIG2of3() {
  vv_output "S35_MSIG2of3()"
  get_next_opcode
  msig_redeem_str=$msig_redeem_str$cur_opcode
  case $cur_opcode in
    *)  echo "    $cur_opcode: OP_INTEGER $cur_opcode_dec Bytes (0x$cur_opcode) go to stack"
        msig_len=$(( $cur_opcode_dec * 2 ))
        S36_LENGTH
        ;;
  esac
}
##########################
### STATUS 36 (length) ###
##########################
S36_LENGTH() {
  vv_output "S36_LENGTH()"
  get_next_opcode
  case $cur_opcode in
    52) echo "    $cur_opcode: OP_2: push 2 Bytes onto stack"
        echo "        ######## we go multisig ########"
        ret_string=''
        msig_redeem_str=$cur_opcode
        S37_OP2
        ;;
    *)  echo "    $cur_opcode: unknown opcode "
        ;;
  esac
}
##########################
### STATUS 37 (length) ###
##########################
S37_OP2() {
  vv_output "S37_OP2()"
  S37_to=$(( $offset + msig_len ))
  if [ $S37_to -gt $opcodes_len ] ; then
    S37_to=$opcodes_len 
  fi
  vv_output "S37_OP2, offset=$offset, S37_to=$S37_to, opcodes_len=$opcodes_len"
  while [ $offset -le $S37_to ]  
   do
    get_next_opcode
    msig_redeem_str=$msig_redeem_str$cur_opcode
    case $cur_opcode in
      21) echo "    $cur_opcode: OP_DATA_0x21: compressed pub key"
          op_data_show
          echo "        This is MultiSig's Public Key (X9.63 COMPRESSED form)"
          printf "        corresponding bitcoin address is: "
          rmd160_sha256
          if [ $TESTNET -eq 1 ] ; then
            ./tcls_base58check_enc.sh -T -q -p2pkh $result
          else
            ./tcls_base58check_enc.sh -q -p2pkh $result
          fi
          msig_redeem_str=$msig_redeem_str$ret_string
          vv_output "        msig_redeem_str=$msig_redeem_str"
          ret_string=''
          ;;
      41) echo "    $cur_opcode: OP_DATA_0x41: uncompressed pub key"
          op_data_show
          echo "        This is MultiSig's Public Key (X9.63 UNCOMPRESSED form)"
          printf "        corresponding bitcoin address is: "
          rmd160_sha256
          if [ $TESTNET -eq 1 ] ; then
            ./tcls_base58check_enc.sh -T -q -p2pkh $result
          else
            ./tcls_base58check_enc.sh -q -p2pkh $result
          fi
          msig_redeem_str=$msig_redeem_str$ret_string
          vv_output "       msig_redeem_str=$msig_redeem_str"
          ret_string=''
          ;;
      53) echo "    $cur_opcode: OP_3: push 3 Bytes onto stack"
          echo "        Multisig needs 3 pubkeys"
          ;;
      AE) echo "    $cur_opcode: OP_CHECKMULTISIG, terminating multisig"
          echo "        ####### Multisignature end ######"
          vv_output "    $msig_redeem_str"
          show_redeem_script $msig_redeem_str
          ret_string=$msig_redeem_str
          printf "        corresponding bitcoin address is: "
          rmd160_sha256
          if [ $TESTNET -eq 1 ] ; then
            ./tcls_base58check_enc.sh -T -q -p2sh $result
          else
            ./tcls_base58check_enc.sh -q -p2sh $result
          fi
          ret_string=''
          msig_redeem_str=''
          break
          ;;
      *)  echo "    $cur_opcode: unknown OpCode"
          ;;
    esac
  done
  vv_output "    S37_OP2, offset=$offset, S37_to=$S37_to, opcodes_len=$opcodes_len"
}

###########################
### STATUS 99 (unknown) ###
###########################
S99_Unknown() {
  vv_output "S99_Unknown()"
  cur_opcode_dec=$opcodes_len
  op_data_show
}
	  
####################
### LET'S GO ... ###
####################

while [ $# -ge 1 ] 
 do
  case "$1" in
    -q)
       Quiet=1
       shift
       ;;
    -T)
       TESTNET=1
       shift
       ;;
    -v)
       Verbose=1
       shift
       ;;
    -vv)
       Verbose=1
       VVerbose=1
       shift
       ;;
    -?|-h|--help)
       echo "usage: tcls_in_sig_script.sh [-?|-h|--help|-q|-T|-v|-vv] hex_string"
       echo "  "
       echo "convert a raw hex string from a bitcoin tx-out into it's OpCodes. "
       echo "if no hex string is given, the data from a demo tx is used. "
       echo "  "
       exit 0
       ;;
    *)
       param=$( echo $1 | tr "[:lower:]" "[:upper:]" )
       shift
       ;;
  esac
done

if [ $Quiet -eq 0 ] ; then 
  echo "  ##################################################################"
  echo "  ### tcls_in_sig_script.sh: decode SIG_script OPCODES from a TX ###"
  echo "  ##################################################################"
fi

if [ $VVerbose -eq 1 ] ; then 
  echo "  a valid bitcoin signature (r,s) is going to look like:"
  echo "  <30><len><02><len><r bytes><02><len><s bytes><01>"
  echo "  with 9 <= length(sig) <= 73 (18-146 chars)"
  echo "  Multisig is much more complicated :-)"
fi

#################################################################
### set -A or declare ss_array - bash and ksh are different ! ###
#################################################################
result=$( echo "$param" | sed 's/[[:xdigit:]]\{2\}/& /g' )
shell_string=$( echo $SHELL | cut -d / -f 3 )
if [ "$shell_string" == "bash" ] ; then
  declare -a ss_array
  # running this on OpenBSD creates errors, hence a for loop...
  # ss_array=($result)
  # IFS=' ' read -a ss_array <<< "${result}"
  for TX_Char in $result; do ss_array[$n]=$TX_Char; ((n++)); done
elif [ "$shell_string" == "ksh" ] ; then 
  set -A ss_array $result
else
  echo "*** ERROR: could not identify shell, exiting gracefully..."
  echo " "
  exit 1
fi

#####################################
### STATUS 0 - INIT               ###
#####################################
  opcodes_len=${#param}
  # echo "array length= ${#ss_array[*]}"
  while [ $ss_array_ptr -lt ${#ss_array[*]} ]
   do
    get_next_opcode
    # vv_output "S0_INIT, opcode=$cur_opcode, ss_array_ptr=$ss_array_ptr "
    vv_output "S0_INIT, opcode=$cur_opcode" 
    
    case $cur_opcode in
      00) echo "    $cur_opcode: OP_DATA_0x00:     unknown data code - ignore"
          sig_offset=$(( $sig_offset + 2 ))
          ;;
      21) echo "    $cur_opcode: OP_DATA_0x21:     type tag indicating LENGTH"
	  S3_SIG_LEN_0x21
          ;;
      3C) echo "    $cur_opcode: OP_DATA_0x3C:     type tag indicating LENGTH"
	  S24_SIG_LEN_0x3C
          ;;
      4C) echo "    $cur_opcode: OP_PUSHDATA1:     (next byte is number of bytes that go to stack)" 
	  S35_MSIG2of3
          ;;
      41) echo "    $cur_opcode: OP_DATA_0x41:     push hex 41 (decimal 65) bytes as data"
	  S4_SIG_LEN_0x41
          ;;
      47) echo "    $cur_opcode: OP_DATA_0x47:     push hex 47 (decimal 71) bytes as data"
          S1_SIG_LEN_0x47
          ;;
      48) echo "    $cur_opcode: OP_DATA_0x48:     push hex 48 (decimal 72) bytes as data"
	  S2_SIG_LEN_0x48
          ;;
      49) echo "    $cur_opcode: OP_DATA_0x49:     push hex 49 (decimal 73) bytes as data"
	  S21_SIG_LEN_0x49
          ;;
      *)  echo "    $cur_opcode: unknown OpCode"
	  S99_Unknown
          ;;
    esac

    # https://bitcointalk.org/index.php?topic=585639.0
    # A tx is invalid if any of the following are true
    # Block Size is >1,000 KB (this is a block level check but obviously a tx 
    # which can't fit into a block <=1MB could never be confirmed at least not 
    # until the 1MB limit is raised).
    # A script is >10KB (this is per script so tx can be larger if it contains 
    # multiple scripts each less than 10KB).
    # The size of the value being pushed in a script is >520 bytes (effectively 
    # limits P2SH scripts to 520 bytes as the redeemScript is pushed to the stack).
    #
  done


