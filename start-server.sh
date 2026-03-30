PATH_TO_ZROK="/Users/path/to/zrok/zrok.exe"
INITIAL_MEMORY_MB=1024
MAX_MEMORY_MB=1024
MINECRAFT_SERVER_IP="127.0.0.1"
MINECRAFT_SERVER_PORT="25565"

while [ ! -f "$PATH_TO_ZROK" ]; do
    echo "==== PATH_TO_ZROK incorrect! ===="
    echo "(Update PATH_TO_ZROK in this script to avoid seeing this message)"
    read -p "Enter the correct path to zrok: " PATH_TO_ZROK
done

if [ ! -f "$HOME/.zrok/environment.json" ]; then
    echo "zrok not enabled! Enable zrok before continuing!"
    exit 1
fi

ZID=$(jq -r '.ziti_identity' "$HOME/.zrok/environment.json")

RESERVED_SHARE=$(echo "$ZID" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')minecraft

ZROK_OVERVIEW=$("$PATH_TO_ZROK" overview)
TARGET_ENVIRONMENT=$(echo "$ZROK_OVERVIEW" | jq -r ".environments[] | select(.environment.zId == \"$ZID\")")

if [ -n "$TARGET_ENVIRONMENT" ]; then
    SHARES=$(echo "$TARGET_ENVIRONMENT" | jq -r ".shares[] | select(.token == \"$RESERVED_SHARE\")")
    if [ -n "$SHARES" ]; then
        echo "Found share with token $RESERVED_SHARE in environment $ZID. No need to reserve..."
    else
        echo "Reserving share: $RESERVED_SHARE"
        "$PATH_TO_ZROK" reserve private "${MINECRAFT_SERVER_IP}:${MINECRAFT_SERVER_PORT}" --backend-mode tcpTunnel --unique-name "$RESERVED_SHARE"
    fi
else
    echo "UNEXPECTED. Trying to reserve share: $RESERVED_SHARE"
    "$PATH_TO_ZROK" reserve private "${MINECRAFT_SERVER_IP}:${MINECRAFT_SERVER_PORT}" --backend-mode tcpTunnel --unique-name "$RESERVED_SHARE"
fi

while ! nc -z "$MINECRAFT_SERVER_IP" "$MINECRAFT_SERVER_PORT"; do
    echo "Waiting for port $MINECRAFT_SERVER_PORT to respond..."
    sleep 5
done

echo "Port $MINECRAFT_SERVER_PORT is now open. Starting zrok share"

"$PATH_TO_ZROK" share reserved "$RESERVED_SHARE"

echo ""
echo "To stop, click in the zrok window, press 'ctrl-c', and wait for the window to disappear"
echo ""
