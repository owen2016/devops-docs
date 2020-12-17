#!/usr/bin/env sh

#填写阿里云的AccessKey ID及AccessKey Secret
ALY_KEY=""
ALY_TOKEN=""

function acme_install () {
git clone https://github.com/acmesh-official/acme.sh.git
cd ./acme.sh
./acme.sh --install
}

function acme_check()
{
    acme.sh --version
}

function create_certs (){
export Ali_Key="LTAI4FyrEoJi8qEeKeRios2r"
export Ali_Secret="nIpymix0sYSj6a0bJNgERE0QzjSrkF"
acme.sh --issue --dns dns_ali -d *.devopsing.site --force
}

function install_certs (){

acme.sh --installcert -d <domain>.com \
--key-file /etc/nginx/ssl/<domain>.key \
--fullchain-file /etc/nginx/ssl/fullchain.cer 
}

read -p "you are sure you wang to xxxxxx?[y/n]" input
echo $input
if [ $input = "y" ];then
    echo "ok "
fi


