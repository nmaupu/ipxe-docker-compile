#!/bin/bash

set -eEuo pipefail

: "${BUILD:=make -j4 everything}"
: "${EMBED:=}"
: "${DEBUG:=}"

DIR_IPXE=/compile/ipxe
DIR_WIMBOOT=/compile/wimboot
DIR_LOGS=/compile/logs

mkdir -p "$DIR_IPXE" "$DIR_LOGS" "$DIR_WIMBOOT"

CMD_BUILD="$BUILD"
CMD_EMBED="EMBED=$EMBED"
CMD_DEBUG="DEBUG=$DEBUG"

# Write log to file
exec | tee &>"$DIR_LOGS/build.log"

start=$(date +%s)

if [ ! -d "$DIR_WIMBOOT" ]; then mkdir -p "$DIR_WIMBOOT"; fi
if [ ! -d "$DIR_LOGS" ]; then mkdir -p "$DIR_LOGS"; fi

# Download and compile ipxe
if [ -d "$DIR_IPXE"/.git ]; then
	echo "Updating ipxe repository..."
	cd "$DIR_IPXE" || exit
	git pull
	echo
else
	echo "Cloning ipxe repository..."
	git clone git://git.ipxe.org/ipxe.git "$DIR_IPXE"
	echo
fi
if [ "$(ls -A /opt/ipxe.local)" != "" ]; then echo "Copying custom configuration..."; echo; cp /opt/ipxe.local/* "$DIR_IPXE"/src/config/local/; fi
cd "$DIR_IPXE"/src || exit
echo "Building ipxe..."
make clean && \
	echo "Building with: $CMD_BUILD $CMD_EMBED $CMD_DEBUG" && \
	sleep 3 && \
	eval "$CMD_BUILD" "$CMD_EMBED" "$CMD_DEBUG"

echo

# Download and extract latest wimboot
echo "Downloading and extracting latest wimboot..."
cd "$DIR_WIMBOOT" || exit
rm -rf ./wimboot-latest.zip
wget http://git.ipxe.org/releases/wimboot/wimboot-latest.zip
unzip -o wimboot-latest.zip

end=$(($(date +%s) - $start))
runtime=$(date -u -d @"$end" +"%T")

echo
echo "****** BUILD FINISHED ******"
echo "Build runtime: $runtime"
