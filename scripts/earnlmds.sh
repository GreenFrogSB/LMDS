#!/usr/bin/env bash
# LICENSE_CODE ZON ISC

PRODUCT=$2

LCONF="/etc/earnapp/ver_conf.json"
if [[ -z "$PRODUCT" ]]; then
  if [[ -f "$LCONF" ]]; then
    if (grep appid < "$LCONF" | grep "piggy" > /dev/null); then
      PRODUCT="piggybox"
    elif (grep appid < "$LCONF" | grep "measurement" > /dev/null); then
      PRODUCT="marconi"
    fi
  fi
fi
if [[ -z "$PRODUCT" ]]; then
  PRODUCT="earnapp"
fi

VERSION="1.340.81"
PRINT_PERR=0
PRINT_PERR_DATA=0
OS_NAME=$(uname -s)
OS_ARCH=$(uname -m)
PERR_ARCH=$(uname -m| tr '[:upper:]' '[:lower:]'| tr -d -c '[:alnum:]_')
OS_VER=$(uname -v)
APP_VER=$(earnapp --version 2>/dev/null)
VER="${APP_VER:-none}"
USER=$(whoami)
RHOST=$(hostname)
_LADDR=$(hostname -I | cut -d' ' -f1)
LADDR=${_LADDR:-unknown}
_IP=$(curl -q4 ifconfig.co 2>/dev/null)
IP=${_IP:-unknown}
NETWORK_RETRY=3
LOG_DIR="/etc/earnapp"
SERIAL="unknown"
SFILE="/sys/firmware/devicetree/base/serial-number"
if [ -f $SFILE ]; then
    SERIAL=$(sha1sum < "$SFILE" | awk '{print $1}')
fi
AUTO=0
if [[ $0 == '-y' ]] || [[ $1 == '-y' ]]; then
    AUTO=1
fi
RID=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)
UUID=$(cat /etc/earnapp/uuid 2>/dev/null)
UUID_HASH=$(md5sum <<< "$UUID")
UUID_I=$((0x${UUID_HASH%% *}))
UUID_N=$((${UUID_I#-}%100))
INSTALL=0
# INSTALL_PERCENT=5
# if [ -z "$UUID" ] || [ "$UUID_N" -lt "$INSTALL_PERCENT" ]; then
#    INSTALL=1
# fi
RS=""
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

LOG=""
LOG_FILENAME=""
read_log()
{
    if [ -f "$LOG_FILENAME" ]; then
        LOG=$(tail -50 "$LOG_FILENAME") # | tr -dc '[:print:]')
        # restore after debug
        # rm -f "$LOG_FILENAME"
    fi
}

print()
{
    STR=$1
    if [ $AUTO = 1 ]; then
        STR="$(date -u +'%F %T') $STR"
    fi
    echo "$STR"
}

perr()
{
    local name=$1
    local note="$2"
    local filehead="$3"
    local ts
    ts=$(date +"%s")
    local ret=0
    escape_json "$note"
    local note=$RS
    escape_json "$filehead"
    local filehead=$RS
    local url_glob="${PERR_URL}/?id=earnapp_cli_sh_${name}"
    local url_arch="${PERR_URL}/?id=earnapp_cli_sh_${PERR_ARCH}_${name}"
    local build="Version: $VERSION\nOS Version: $OS_VER\nCPU ABI: $OS_ARCH\nProduct: $PRODUCT\nInstall ID: $RID\nPublic IP: $IP\nLocal IP: $LADDR\nHost: $RHOST\nUser: $USER\nPlatform: $OS_NAME\nSerial: $SERIAL\n"
    local data="{
        \"uuid\": \"$UUID\",
        \"client_ts\": \"$ts\",
        \"ver\": \"$VER\",
        \"filehead\": \"$filehead\",
        \"build\": \"$build\",
        \"info\": \"$note\"
    }"
    if ((PRINT_PERR)); then
        if ((PRINT_PERR_DATA)); then
            print "📧 $url_glob $data"
        else
            print "📧 $url_glob $note"
        fi
    fi
    for ((i=0; i<NETWORK_RETRY; i++)); do
        if is_cmd_defined "curl"; then
            curl -s -X POST "$url_glob" --data "$data" \
                -H "Content-Type: application/json" > /dev/null
            curl -s -X POST "$url_arch" --data "$data" \
                -H "Content-Type: application/json" > /dev/null
        elif is_cmd_defined "wget"; then
            wget -S --header "Content-Type: application/json" \
                 -O /dev/null -o /dev/null --post-data="$data" \
                 --quiet "$url_glob" > /dev/null
            wget -S --header "Content-Type: application/json" \
                 -O /dev/null -o /dev/null --post-data="$data" \
                 --quiet "$url_arch" > /dev/null
        else
            print "⚠ No transport to send perr"
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
    read -rp "Do you agree to EarnApp's terms? (Write 'yes' to continue): " \
        consent
}

if [[ $EUID -ne 0 ]]; then
   print "⚠ This script must be run as root"
   exit 1
fi

mkdir -p "$LOG_DIR"

if [[ "$VER" == "$VERSION" ]]; then
   perr "00_same_ver"
   print "✔ The application of the same version is already installed"
   LOG_FILENAME="$LOG_DIR/earnapp_services_restart.log"
   {
       service earnapp restart;
       service earnapp_upgrader restart;
       service earnapp status;
       service earnapp_upgrader status
   } >> "$LOG_FILENAME"
   read_log
   perr "00_services_restart" "$VER" "$LOG"
   exit 0
fi

LOG_FILENAME="$LOG_DIR/cleanup.log"
find /tmp -name "earnapp_*" | grep -v $VERSION > "$LOG_FILENAME"
echo "$CLEANUP_CMD"
if [ -s $LOG_FILENAME ]; then
    print "✔ Cleaning up..."
    xargs rm -f < "$LOG_FILENAME"
    read_log
    perr "00_cleanup" "$VER" "$LOG"
fi
# 200MB
FREE_SPACE_MIN=$((2*100*1024*1024))
FREE_SPACE_BLOCKS=$(df --total | grep total | awk '{print $2}')
FREE_SPACE_BYTES=$((FREE_SPACE_BLOCKS*1000))
FREE_SPACE_PRETTY=$(numfmt --to iec --format "%8.4f" "$FREE_SPACE_BYTES" | awk '{print $1}')

echo "✔ Checking prerequisites..."
if ((FREE_SPACE_BYTES < FREE_SPACE_MIN)); then
    FREE_SPACE_MIN_PRETTY=$(numfmt --to iec --format "%8.4f" "$FREE_SPACE_MIN" | awk '{print $1}')
    perr "00_disk_full" "$FREE_SPACE_PRETTY/$FREE_SPACE_MIN_PRETTY"
    FREE_SPACE_DIFF=$((FREE_SPACE_MIN-FREE_SPACE_BYTES))
    FREE_SPACE_DIFF_PRETTY=$(numfmt --to iec --format "%8.4f" "$FREE_SPACE_DIFF" | awk '{print $1}')
    echo "⚠ Not enough space to install."
    echo "⚠ Please free up at least $FREE_SPACE_DIFF_PRETTY and try again."
    exit 1
fi

if ((INSTALL)); then
    perr "00_sh_install" "$VERSION" "$UUID_N"
fi

perr "01_start" "$VERSION" "available: $FREE_SPACE_PRETTY"
if ((AUTO)); then
    consent='yes'
else
    welcome_text
fi

while [[ ${consent,,} != 'yes' ]] && [[ ${consent,,} != 'no' ]]; do
    ask_consent
done
if [ ${consent,,} == 'yes' ]; then
    print "✔ Installing..."
    perr "03_consent_yes"
elif [ ${consent,,} == 'no' ]; then
    echo "Sorry, you must accept these terms to use EarnApp."
    echo "If you decided not to use EarnApp, enter 'No'"
    perr "02_consent_no"
    exit 1
fi
STATUS_FILE="/etc/earnapp/status"
if [ ! -f $STATUS_FILE ]; then
    perr "04_dir_create"
    print "✔ Creating directory /etc/earnapp"
    mkdir -p /etc/earnapp
    chmod a+wr /etc/earnapp/
    touch "$STATUS_FILE"
    chmod a+wr "$STATUS_FILE"
else
    LOG_FILENAME="$LOG_DIR/dir.log"
    ls -al /etc/earnapp -I "*.sent" > "$LOG_FILENAME"
    read_log
    perr "04_dir_existed" "$STATUS_FILE" "$LOG"
    print "✔ System directory already exists"
fi
if [ "$OS_ARCH" = "x86_64" ]; then
    file=$PRODUCT-x64-$VERSION
elif [ "$OS_ARCH" = "amd64" ]; then
    file=$PRODUCT-x64-$VERSION
elif [ "$OS_ARCH" = "armv7l" ]; then
    file=$PRODUCT-arm7l-$VERSION
elif [ "$OS_ARCH" = "armv6l" ]; then
    file=$PRODUCT-arm7l-$VERSION
elif [ "$OS_ARCH" = "aarch64" ]; then
    file=$PRODUCT-aarch64-$VERSION
elif [ "$OS_ARCH" = "arm64" ]; then
    file=$PRODUCT-aarch64-$VERSION
else
    perr "10_arch_other" "$OS_ARCH"
    file=$PRODUCT-arm7l-$VERSION
fi
print "✔ Fetching $file"
perr "15_fetch_start" "$file"
FILENAME="/tmp/earnapp_$VERSION"
LOG_FILENAME="$LOG_DIR/earnapp_fetch.log"
BASE_URL="${BASE_URL:-https://cdn.brightdata.com/static}"
if wget -c "$BASE_URL/$file" \
    -O "$FILENAME" 2>$LOG_FILENAME; then
    read_log
    perr "17_fetch_finished" "$file" "$LOG"
else
    read_log
    perr "16_fetch_failed" "$file" "$LOG"
    print "⚠ Failed"
    exit 1
fi
echo | md5sum $FILENAME
chmod +x $FILENAME
INSTALL_CMD="$FILENAME install"
MAIN_EXE="/usr/bin/earnapp"
MAIN_EXE_BAK="/usr/bin/earnapp_bak"
if ((INSTALL)); then
    if [ -f "$MAIN_EXE" ]; then
        mv -f "$MAIN_EXE" "$MAIN_EXE_BAK"
    fi
    mv -f "$FILENAME" "$MAIN_EXE"
    INSTALL_CMD="$MAIN_EXE finish_install"
fi
if ((AUTO)); then
    INSTALL_CMD="$INSTALL_CMD --auto"
fi
LOG=""
LOG_FILENAME="$LOG_DIR/earnapp_install.log"
if ((AUTO)); then
    INSTALL_CMD="$INSTALL_CMD 2>$LOG_FILENAME"
fi
print "✔ Running $INSTALL_CMD"
perr "20_install_run" "$INSTALL_CMD"
$INSTALL_CMD
read_log
perr "25_install_finished" "$INSTALL_CMD" "$LOG"
INSTALLED_VER=$(cat /etc/earnapp/ver 2>/dev/null)
if [[ "$INSTALLED_VER" == "$VERSION" ]]; then
    if [ -f "$MAIN_EXE_BAK" ]; then
        rm -f "$MAIN_EXE_BAK"
    fi
    print "✔ Installation complete"
    echo
    perr "30_install_success" "$VERSION" "$LOG"
    exit 0
else
    LOG_FILENAME="$LOG_DIR/install_bash.log"
    if [ -f $LOG_FILENAME ]; then
        read_log
    fi
    print "⚠ Installation failed"
    echo
    perr "29_install_fail" "$INSTALLED_VER" "$LOG"
    if [ -f "$MAIN_EXE_BAK" ]; then
        mv -f "$MAIN_EXE_BAK" "$MAIN_EXE"
    fi
    exit 1
fi
