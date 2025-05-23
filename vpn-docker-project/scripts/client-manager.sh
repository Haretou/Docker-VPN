#!/bin/bash
WG_DIR="/etc/wireguard"
CLIENTS_DIR="/app/client-configs"
SERVER_PUBLIC_KEY=$(cat $WG_DIR/server_public.key)
NETWORK="10.8.0"
mkdir -p $CLIENTS_DIR

add_client() {
    CLIENT_NAME=$1
    [ -z "$CLIENT_NAME" ] && { echo "❌ Usage: $0 add <nom>"; exit 1; }
    for i in {2..254}; do
        if ! grep -q "$NETWORK.$i" $WG_DIR/wg0.conf; then
            CLIENT_IP="$NETWORK.$i"; break
        fi
    done
    CLIENT_PRIVATE_KEY=$(wg genkey)
    CLIENT_PUBLIC_KEY=$(echo $CLIENT_PRIVATE_KEY | wg pubkey)
    cat >> $WG_DIR/wg0.conf << CLIENTEOF

[Peer]
# Client: $CLIENT_NAME
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP/32
CLIENTEOF
    cat > $CLIENTS_DIR/$CLIENT_NAME.conf << CONFIGEOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP/24
DNS = 8.8.8.8, 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $WG_HOST:$WG_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CONFIGEOF
    qrencode -t ansiutf8 < $CLIENTS_DIR/$CLIENT_NAME.conf
    qrencode -t png -o $CLIENTS_DIR/$CLIENT_NAME.png < $CLIENTS_DIR/$CLIENT_NAME.conf
    echo "✅ Client $CLIENT_NAME créé - IP: $CLIENT_IP"
    wg syncconf wg0 <(wg-quick strip wg0) 2>/dev/null || wg-quick down wg0 && wg-quick up wg0
}

case "$1" in
    add) add_client "$2" ;;
    remove) 
        sed -i "/# Client: $2/,/^$/d" $WG_DIR/wg0.conf
        rm -f $CLIENTS_DIR/$2.conf $CLIENTS_DIR/$2.png
        wg syncconf wg0 <(wg-quick strip wg0) 2>/dev/null || wg-quick down wg0 && wg-quick up wg0
        ;;
    list) grep "# Client:" $WG_DIR/wg0.conf | sed 's/# Client: /- /' ;;
    show) [ -f "$CLIENTS_DIR/$2.conf" ] && cat $CLIENTS_DIR/$2.conf && qrencode -t ansiutf8 < $CLIENTS_DIR/$2.conf ;;
    *) echo "Usage: $0 {add|remove|list|show} [nom]" ;;
esac
