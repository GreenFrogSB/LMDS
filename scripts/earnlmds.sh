#!/usr/bin/env bash
# LICENSE_CODE ZON ISC
PRINT_PERR=0
OS_NAME=$(uname -s)
OS_ARCH=$(uname -m)
OS_VER=$(uname -v)
NETWORK_RETRY=3
RID=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 32 |\
    head -n 1)
RS=""
TS_START=$(date +"%s000")
PERR_URL="https://perr.luminati.io/client_cgi/perr"

is_cmd_defined()
{
    local cmd=$1
    type -P "$cmd" > /dev/null
    return $?
}

escape_json()
{
    local strip_nl=${1//$'\n'/\\n}
    local strip_tabs=${strip_nl//$'\t'/\ }
    local strip_quotes=${strip_tabs//$'"'/\ }
    RS=$strip_quotes
}

perr()
{
    local name=$1 note="$2" ts=$(date +"%s") ret=0
    escape_json "$note"
    local note=$RS url="${PERR_URL}/?id=earnapp_sh_${name}"
    local data="{\"uuid\": \"$RID\", \"timestamp\": \"$ts\", \"ver\": \"1.263.380\", \"info\": {\"platform\": \"$OS_NAME\", \"c_ts\": \"$ts\", \"c_up_ts\": \"$TS_START\", \"note\": \"$note\", \"os_ver\": \"$OS_VER\", \"os_arch\": \"$OS_ARCH\"}}"
    if ((PRINT_PERR)); then
        echo "perr $url $data"
    fi
    for ((i=0; i<NETWORK_RETRY; i++)); do
        if is_cmd_defined "curl"; then
            curl -s -X POST "$url" --data "$data" \
                -H "Content-Type: application/json" > /dev/null
        elif is_cmd_defined "wget"; then
            wget -S --header "Content-Type: application/json" \
                 -O /dev/null -o /dev/null --post-data="$data" \
                 --quiet $url > /dev/null
        else
            echo "no transport to send perr"
        fi
        ret=$?
        if ((!ret)); then break; fi
    done
}

welcome_text(){
    echo -e "\e[32m==============================================================================================================================\e[0m"
    echo
    echo -e "\e[36;1m                                        Installing EarnApp CLI\e[0m"
    echo -e "\e[36;1m                            Welcome to EarnApp for Linux and Raspberry Pi.\e[0m"
    echo -e "\e[36;1m                        EarnApp makes you money by sharing your spare bandwidth.\e[0m"
    echo -e "\e[36;1m Visit \e[32;1mhttps://earnapp.com/i/snq8y4m\e[0m\e[36;1m and create your account firts if you don't have one already.\e[0m"
    echo -e "\e[36;1m         After installation is completed you should register this node under your account.\e[0m"
    echo
    echo -e "\e[32m==============================================================================================================================\e[0m"
    echo
    echo "To use EarnApp, allow BrightData to occasionally access websites through your device." 
    echo "BrightData will only access public Internet web pages, not slow down your device or Internet" 
    echo "and never access personal information, except IP address - see privacy policy and full terms of service on https://earnapp.com/i/snq8y4m."
    echo
}

ask_consent(){
    read -p  "Do you agree to EarnApp's terms? (Write 'yes' to continue):" \
        consent
}

perr "start"
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
welcome_text
if [[ $0 == '-y' ]] || [[ $1 == '-y' ]]; then
    consent='yes'
fi
while [[ ${consent,,} != 'yes' ]] && [[ ${consent,,} != 'no' ]]; do
    ask_consent
done
if [ ${consent,,} == 'yes' ]; then
    echo "Installing..."
    perr "consent_yes"
elif [ ${consent,,} == 'no' ]; then
    echo "Sorry, you must accept these terms to use EarnApp."
    echo "If you decided not to use EarnApp, enter 'No'"
    perr "consent_no"
    exit 1
fi
if [ ! -d "/etc/earnapp" ]; then
    perr "dir_create"
    echo "Creating directory /etc/earnapp"
    mkdir /etc/earnapp
    chmod a+wr /etc/earnapp/
    touch /etc/earnapp/status
    chmod a+wr /etc/earnapp/status
else
    perr "dir_existed"
    echo "System directory already exists"
fi
archs=`uname -m`
if [ $archs = "x86_64" ]; then
    perr "arch_x86_64"
    file=bin_64
elif [ $archs = "amd64" ]; then
    perr "arch_amd64"
    file=bin_64
elif [ $archs = "armv7l" ]; then
    perr "arch_armv7l"
    file=armv7
elif [ $archs = "armv6l" ]; then
    perr "arch_armv6l"
    file=armv7
elif [ $archs = "aarch64" ]; then
    perr "arch_aarch64"
    file=aarch64
elif [ $archs = "arm64" ]; then
    perr "arch_arm64"
    file=aarch64
else
    perr "arch_other"
    file=armv7
fi
echo "Fetching $file"
perr "fetch_start"
wget -c https://brightdata.com/static/earnapp/$file -O /tmp/earnapp
perr "fetch_finished"
echo | md5sum /tmp/earnapp
chmod +x /tmp/earnapp
echo "running /tmp/earnapp install"
perr "install_run"
/tmp/earnapp install
perr "install_finished"