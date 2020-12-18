#!/usr/bin/env bash

PROJECT_NAME="lets-encrypt.sh"
DOMAIN_NAME=""

function check_command() {
  command -v "$1" >/dev/null 2>&1
}


function acme_check() {

source ~/.bashrc 

acme.sh --version

if [ -e ~/.acme.sh ] && [ $? -ne 127 ]; then
    echo "acme.sh is installed already..."
else
  if [ -e acme.sh ]; then 
     echo "acme.sh --install"
  else
    git clone https://github.com/acmesh-official/acme.sh.git
    cd ./acme.sh
    ./acme.sh --install
   fi
fi

acme.sh --version

echo $?
if [ -e ~/.acme.sh ] && [ $? -ne 127 ]; then
  echo "acme.sh is installed successfully..."
else
  echo "acme.sh is NOT installed, please check it..."
  exit 1;
fi

}

function generate_certs() {
echo -e "issue certificate support the dns providers below."
echo -e "1. Aliyun"
echo -e "2. DnsPod"
echo -e "0. Exit\n\n"

read -p "Input No. to Select DNS Provider " provider
echo $provider

case $provider in
0)
    exit ;;
1)
    issue_certs_aliyun ;;
2)
    issue_certs_dnspod  ;;
*)
   echo "sorry,wrong selection" ;;

esac
}

function issue_certs_aliyun(){
#填写阿里云的AccessKey ID及AccessKey Secret
echo "Coming in dns provider 'aliyun'... " 
read -p "Input AccessKey ID: " ALY_KEY
echo $ALY_KEY
read -p "Input AccessKey Secret: " ALY_SECRET
echo $ALY_SECRET
read -p "Input DOMAIN_NAME (e.g *.domain.cn): " DOMAIN_NAME
echo $DOMAIN_NAME

export Ali_Key="$ALY_KEY"
export Ali_Secret="$ALY_SECRET"

echo "Run_Command: acme.sh --issue --dns dns_ali -d "$DOMAIN_NAME" --force"

acme.sh --issue --dns dns_ali -d "$DOMAIN_NAME" --force
}

function issue_certs_dnspod() {

#填写阿里云的AccessKey ID及AccessKey Secret
echo "Coming in dns provider 'dnspod'... " 
read -p "Input AccessKey ID: " DPI_Id
echo $DPI_Id
read -p "Input AccessKey KEY: " DPI_Key
echo $DPI_Key
read -p "Input DOMAIN_NAME (e.g *.domain.cn): " DOMAIN_NAME
echo $DOMAIN_NAME

export DPI_Id="$DPI_Id"
export DPI_Key="$DPI_Key"

echo "Run_Command: acme.sh --issue --dns dns_dpi  -d "$DOMAIN_NAME" --force"
acme.sh --issue --dns dns_dpi  -d "$DOMAIN_NAME" --force

}

function install_certs(){

if [ -z $DOMAIN_NAME ] ; then
    read -p "Input Domain_Name: (e.g *.domain.cn): " DOMAIN_NAME
    echo $DOMAIN_NAME
fi

mkdir -p /etc/nginx/ssl/

echo "Install certs of Domain:[$DOMAIN_NAME] to /etc/nginx/ssl/ "
acme.sh --installcert -d "$DOMAIN_NAME" \
--key-file /etc/nginx/ssl/"$DOMAIN_NAME".key \
--fullchain-file /etc/nginx/ssl/fullchain.cer 
}

function showhelp() {
    echo "
     ## This shell will generate ssl certifacates for the specific domain (e.g. *.domain.com.cn)
     ## It will use 'DNS API' mode to automatically issue cert, so must get API key from your DNS provider(e.g. aliyun, dncspod)
     ## Usage: $PROJECT_ENTRY <command> ... [parameters ...]
        Commands:
        -h, --help               Show this help message.
        -v, --version            Show version info.
        -a, --all                All_In-One install which install 'check','generate','install' action.
        -c, --check              Check if acme.sh is installed in current machine; if not, install it directly
        -i, --install            Install issued certs to the specific path
        -g, --generate           Generate issued certs based on Domain_Name (e.g. *.domain.com)
    "
}

_startswith() {
  _str="$1"
  _sub="$2"
  echo "$_str" | grep "^$_sub" >/dev/null 2>&1
}

function _process (){
while [ ${#} -gt 0 ]; do
    case "${1}" in  
    --help | -h)
        showhelp
        return
        ;;
    --check | -c)
        acme_check
        return
        ;;
    --install | -i)
        install_certs
        return
        ;; 
    --generate | -g)
        generate_certs
        return
        ;; 
    --all | -a)
        acme_check
        generate_certs
        install_certs
        return
        ;; 
    *)
      _err "Unknown parameter : $1"
      return 1
      ;;
    esac
done
}

function main() {
  [ -z "$1" ] && showhelp && return
  if _startswith "$1" '-'; then _process "$@"; else "$@"; fi
}

main "$@"






