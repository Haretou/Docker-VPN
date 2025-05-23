#!/bin/bash
set -e
echo "🚀 Démarrage VPN WireGuard Mac M2..."
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p 2>/dev/null || true
if [ ! -f /etc/wireguard/server_private.key ]; then
    wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
    chmod 600 /etc/wireguard/server_private.key
fi
if [ "$WG_HOST" = "auto" ]; then
    WG_HOST=$(curl -s https://api.ipify.org || echo "127.0.0.1")
fi
/app/scripts/generate-server-config.sh
touch /var/log/wireguard/server.log
wg-quick up wg0
/app/scripts/monitor.sh &
echo "✅ Serveur VPN prêt Mac M2 - IP: $WG_HOST - Port: $WG_PORT"
tail -f /var/log/wireguard/server.log
