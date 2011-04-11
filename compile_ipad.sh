#!/bin/sh
# Written by Maxime CHAPELET, 2011

# The path where you put your certificates and provisioning profiles
DEV_IOS_PATH="/Users/umxprime/Dev\ iOS";

# The path to the packager for iOS root
PFI_PATH="${DEV_IOS_PATH}/packagerforiphone_v2_mac_101110/";

# The pfi bin
PFI_BIN="bin/pfi";
PFI=$PFI_PATH$PFI_BIN;

# The MXMLC compiler
MXMLC="amxmlc";

# The iOS target type
TARGET="ipa-test";

# The p12 certificate path and properties
STORETYPE="pkcs12";
KEYSTORE="${DEV_IOS_PATH}/Certificats.p12";
STOREPASS="testing";

# The provisioning profile path
PROVISIONING_PROFILE="${DEV_IOS_PATH}/Team_Provisioning_Profile_.mobileprovision";

# The app name
APPNAME="Reactive1";

# The dir where the mxml file is
SRC_DIR="src";

APPLICATION_DESCRIPTOR="${APPNAME}-app.xml";
SWF="${APPNAME}.swf";

# The icons files used by the app descriptor
ICONS="default29.png default48.png default57.png default72.png default512.png";

COMPILE_SWF="${MXMLC} ${SRC_DIR}/${APPNAME}.mxml -output ${SWF}";
COMPILE_IPA="${PFI} -package -target ${TARGET} -provisioning-profile ${PROVISIONING_PROFILE} -storetype ${STORETYPE}";
COMPILE_IPA="${COMPILE_IPA} -keystore ${KEYSTORE} -storepass ${STOREPASS} ${APPNAME}.ipa ${APPLICATION_DESCRIPTOR} ${ICONS} ${SWF}";

eval "$COMPILE_SWF";
eval "$COMPILE_IPA"