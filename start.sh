#!/bin/sh

export GIT_URL="https://raw.githubusercontent.com/MrKsey/shapeshifter-dispatcher/main"
export USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0"

# Download configuration files
wget -q -nc --no-check-certificate --user-agent="$USER_AGENT" --content-disposition "$GIT_URL/ConfigFiles/obfs4_client.json" -O /state/obfs4_client.json
wget -q -nc --no-check-certificate --user-agent="$USER_AGENT" --content-disposition "$GIT_URL/ConfigFiles/shadow_client.json" -O /state/shadow_client.json
wget -q -nc --no-check-certificate --user-agent="$USER_AGENT" --content-disposition "$GIT_URL/ConfigFiles/shadow_server.json" -O /state/shadow_server.json

# Configuration file config.ini source.
if [ ! -s /state/config.ini ]; then
    wget -q --no-check-certificate --user-agent="$USER_AGENT" --content-disposition "$GIT_URL/config.ini" -O /state/config.ini
    if [ -e /state/config.ini ]; then
        echo "$(date): File config.ini downloaded from the github."
    fi
fi

if [ -s /state/config.ini ]; then
    chmod 644 /state/config.ini
    sed -i -e "s/\r//g" /state/config.ini
    . /state/config.ini && export $(grep --regexp ^[a-zA-Z] /state/config.ini | cut -d= -f1)
    echo "============================================="
    echo "$(date): Configuration settings from config.ini file:"
    echo " "
    echo "$(cat /state/config.ini | grep --regexp ^[a-zA-Z])"
    echo " "
    echo "============================================="
    echo " "
fi

if [ "$OS_UPDATE" = "true" ]; then
    echo "============================================="
    echo "$(date): Start checking for OS updates ..."
    apt-get update && apt-get upgrade -y
    echo "Finished checking for OS updates."
    echo "============================================="
fi

# Check vars
if [ -z "$MODE" ]; then
    export MODE=server
fi
if [ -z "$PROXY_MODE" ]; then
    export PROXY_MODE=transparent-TCP
fi
if [ -z "$TRANSPORT" ]; then
    export TRANSPORT=obfs2
fi
if [ -z "$LISTEN_IP" ]; then
    export LISTEN_IP=0.0.0.0
fi
if [ -z "$LISTEN_PORT" ]; then
    export LISTEN_PORT=443
fi
if [ -z "$FORWARD_IP" ]; then
    export FORWARD_IP=127.0.0.1
fi
if [ -z "$FORWARD_PORT" ]; then
    export FORWARD_PORT=1194
fi

# Set PROXY_MODE_PARAM
case $PROXY_MODE in
    transparent-TCP)
	    export PROXY_MODE_PARAM="-transparent"      
        ;;
    transparent-UDP)
        export PROXY_MODE_PARAM="-udp -transparent"
        ;;
    STUN)
        export PROXY_MODE_PARAM="-udp"
        ;; 
    *)
    export PROXY_MODE_PARAM="-transparent"
        ;;
esac

# Set OPTIONS_FILE_PARAM
if [ ! -z "$OPTIONS_FILE" ] && [ -s "/state/$OPTIONS_FILE" ]; then
    export OPTIONS_FILE_PARAM="-optionsFile /state/$OPTIONS_FILE"
else
    export OPTIONS_FILE_PARAM=""
fi

if [ "$MODE" = "server" ]; then
    # Get external IP address
    if [ "$LISTEN_IP" = "0.0.0.0" ]; then
        export LISTEN_IP=$(curl ifconfig.me)
        echo "$(date): LISTEN_IP changed from 0.0.0.0 to $LISTEN_IP"
        echo $LISTEN_IP > /state/_SERVER_PUBLIC_LISTEN_IP.txt
        echo "$(date): SERVER PUBLIC IP writed to _SERVER_PUBLIC_LISTEN_IP.txt"
    fi

    # Start proxy
    shapeshifter-dispatcher $PROXY_MODE_PARAM -server -state state -orport $FORWARD_IP:$FORWARD_PORT -transports $TRANSPORT -bindaddr $TRANSPORT-$LISTEN_IP:$LISTEN_PORT -logLevel DEBUG -enableLogging $OPTIONS_FILE_PARAM &
    
    # Set correct params in file obfs4_bridgeline.txt and obfs4_client.json
    if [ "$TRANSPORT" = "obfs4" ]; then
        sleep 3
        if [ -s /state/obfs4_bridgeline.txt ]; then
	    export FINGERPRINT=$(jq -r '."node-id"' /state/obfs4_state.json | tr 'a-z' 'A-Z')
            grep --regexp ^[a-zA-Z] /state/obfs4_bridgeline.txt | sed "s/<IP ADDRESS>/$LISTEN_IP/g" | sed "s/<PORT>/$LISTEN_PORT/g" | sed "s/<FINGERPRINT>/$FINGERPRINT/g" > /state/_OBFS4_BRIDGE.txt
	    echo "$(date): obfs4 brifge line writed to _OBFS4_BRIDGE.txt"
            sed "s/.*cert=//" /state/_OBFS4_BRIDGE.txt | cut -d " " -f 1 > /state/_OBFS4_CLIENT_CERT.txt
	    echo "$(date): obfs4 client cert writed to _OBFS4_CLIENT_CERT.txt"
        fi
    fi 
else
    shapeshifter-dispatcher $PROXY_MODE_PARAM -client -state state -target $FORWARD_IP:$FORWARD_PORT -transports $TRANSPORT -proxylistenaddr $LISTEN_IP:$LISTEN_PORT -logLevel DEBUG -enableLogging $OPTIONS_FILE_PARAM &
fi

tail -f /dev/null
