#!/bin/bash
CUR_V="$(grep "Version" ${SERVER_DIR}/changelog.txt 2>/dev/null | head -1 | cut -d ' ' -f 2)"
CUR_V="${CUR_V//./}"

if [ "${ENABLE_AUTOUPDATE}" == "true" ]; then
    LAT_V="$(curl -s https://terraria.org/api/get/dedicated-servers-names | grep -o -E "[[:digit:]]+" | head -n 1)"
else
    LAT_V="${TERRARIA_SRV_V//./}"
fi

function download-terraria-server {
    cd ${SERVER_DIR}
   	if wget -q -nc --show-progress --progress=bar:force:noscroll -O terraria-server-$LAT_V.zip "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${LAT_V}.zip" ; then
		    echo "---Successfully downloaded Terraria---"
	  else
		    echo "------------------------------------------------------------------------------"
		    echo "------------Can't download Terraria, putting server into sleep mode-----------"
		    echo "------------------------------------------------------------------------------"
		    sleep infinity

	  fi
    unzip -qo ${SERVER_DIR}/terraria-server-$LAT_V.zip
    cp -R -f ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}/
    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip ${SERVER_DIR}/${LAT_V}

    if [ "$(uname -m)" == "aarch64" ]; then
        rm -f System*
        rm -f Mono*
        rm -f monoconfig
        rm -f mscorlib.dll
    fi
}

rm -rf ${SERVER_DIR}/terraria-server-*.zip

echo "---Version Check---"
if [ ! -d "${SERVER_DIR}/lib" ] && [ ! -d "${SERVER_DIR}/lib64" ]; then
   	echo "---Terraria not found, downloading!---"
   	download-terraria-server
elif [ "$LAT_V" != "$CUR_V" ]; then
    echo "---Newer version found, installing!---"
    download-terraria-server
elif [ "$LAT_V" == "$CUR_V" ]; then
    echo "---Terraria Server v$LAT_V up-to-date---"
	  echo "---If you want to change the version disable autoupdate and add a variable with the key: 'TERRARIA_SRV_V' and the value eg: '1.4.2.3'."
else
 	  echo "---Something went wrong, putting server in sleep mode---"
 	  sleep infinity
fi

echo "---Starting Server---"

if [ ! -f "${SERVER_DIR}/serverconfig.txt" ]; then
    echo "---No serverconfig.txt found, copying default...---"
    cp -f /config/serverconfig.txt ${SERVER_DIR}
fi

#---Checking for old logs---
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;
screen -wipe 2&>/dev/null

#---Start Server---
cd ${SERVER_DIR}

SCREEN_EXEC="screen -S Terraria -L -Logfile ${SERVER_DIR}/masterLog.0 -c /config/.screenrc -d -m"

if [ "$(uname -m)" == "aarch64" ]; then
    ${SCREEN_EXEC} mono --server --gc=sgen -O=all ${SERVER_DIR}/TerrariaServer.exe ${GAME_PARAMS}
else
    ${SCREEN_EXEC} ${SERVER_DIR}/TerrariaServer.bin.x86_64 ${GAME_PARAMS}
fi

sleep 2

killpid="$(pgrep 'screen')"

if [ "${ENABLE_WEBCONSOLE}" == "true" ]; then
    /opt/scripts/start-gotty.sh 2>/dev/null &
fi

tail --pid=$killpid -f ${SERVER_DIR}/masterLog.0
