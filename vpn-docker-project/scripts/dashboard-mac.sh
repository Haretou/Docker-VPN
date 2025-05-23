#!/bin/bash
while true; do
    clear
    echo "🍎 VPN DASHBOARD MAC M2 - $(date)"
    echo "================================"
    docker ps --filter "name=wireguard-server" --format "{{.Names}} | {{.Status}}"
    echo "🌐 IP: $(curl -s --connect-timeout 3 https://api.ipify.org || echo 'N/A')"
    PEERS=$(docker exec wireguard-server wg show wg0 peers 2>/dev/null | wc -l)
    echo "👥 Clients connectés: $PEERS"
    echo "📁 Configs locales: $(ls ./client-configs/*.conf 2>/dev/null | wc -l)"
    docker stats wireguard-server --no-stream --format "💻 CPU: {{.CPUPerc}} | RAM: {{.MemUsage}}" 2>/dev/null
    echo -e "\n🔧 Commandes: ./manage-vpn.sh {start|stop|add-client|logs}"
    echo "Ctrl+C pour quitter"
    sleep 5
done
