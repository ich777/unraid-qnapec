# Create necessary directories, download source and patch files
cd ${DATA_DIR}
mkdir -p /QNAPEC/lib/modules/${UNAME}/kernel/extra /QNAPEC/usr/{lib,bin} /QNAPEC/usr/local/emhttp/plugins/qnap-ec/images
git clone https://github.com/Stonyx/QNAP-EC/

# Compile modules
cd ${DATA_DIR}/QNAP-EC
make -j${CPU_COUNT}

# Copy modules to destination
cp ${DATA_DIR}/QNAP-EC/qnap-ec /QNAPEC/usr/bin/
cp ${DATA_DIR}/QNAP-EC/libuLinux_hal.so /QNAPEC/usr/lib
cp ${DATA_DIR}/QNAP-EC/qnap-ec.ko /QNAPEC/lib/modules/${UNAME}/kernel/extra/

#Compress modules
while read -r line
do
  xz --check=crc32 --lzma2 $line
done < <(find /QNAPEC/lib/modules/${UNAME}/kernel/extra -name "*.ko")

# Download icon
cd ${DATA_DIR}
wget -O /QNAPEC/usr/local/emhttp/plugins/qnap-ec/images/qnap-ec.png https://raw.githubusercontent.com/ich777/docker-templates/master/ich777/images/qnap.png

# Create Slackware package
PLUGIN_NAME="qnapec"
BASE_DIR="/QNAPEC"
TMP_DIR="/tmp/${PLUGIN_NAME}_"$(echo $RANDOM)""
VERSION="$(date +'%Y.%m.%d')"
mkdir -p $TMP_DIR/$VERSION
cd $TMP_DIR/$VERSION
cp -R $BASE_DIR/* $TMP_DIR/$VERSION/
mkdir $TMP_DIR/$VERSION/install
tee $TMP_DIR/$VERSION/install/slack-desc <<EOF
       |-----handy-ruler------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME Package contents:
$PLUGIN_NAME:
$PLUGIN_NAME: Source: https://github.com/Stonyx/QNAP-EC
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME: Custom QNAP-EC package for Unraid Kernel v${UNAME%%-*} by ich777
$PLUGIN_NAME:
EOF
${DATA_DIR}/bzroot-extracted-$UNAME/sbin/makepkg -l n -c n $TMP_DIR/$PLUGIN_NAME-plugin-$UNAME-1.txz
md5sum $TMP_DIR/$PLUGIN_NAME-plugin-$UNAME-1.txz | awk '{print $1}' > $TMP_DIR/$PLUGIN_NAME-plugin-$UNAME-1.txz.md5