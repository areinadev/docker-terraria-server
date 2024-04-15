#!/bin/bash

echo "---Checking for optional scripts---"|

if [ -f /opt/scripts/user.sh ]; then
    echo "---Found optional script, executing---"
    /opt/scripts/user.sh || echo "---Optional Script has thrown an Error---"
else
    echo "---No optional script found, continuing---"
fi

term_handler() {
    echo "---Stopping server gracefully---"
    screen -S Terraria -X stuff 'exit^M' >/dev/null
    tail --pid="$killpid" -f 2>/dev/null
    exit 143
}

echo "---Starting...---"

/opt/scripts/start-server.sh &
killpid="$!"

trap 'term_handler' SIGTERM
trap 'ec=$?; echo "---Server Stopped---"; exit $ec' EXIT

wait $killpid
exit 0
