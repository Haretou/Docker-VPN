#!/bin/bash
LOG_FILE="/var/log/wireguard/server.log"
log_message() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE; }
while true; do
    ! wg show wg0 > /dev/null 2>&1 && log_message "❌ Interface WG down" && wg-quick up wg0 2>/dev/null
    PEERS=$(wg show wg0 peers 2>/dev/null | wc -l)
    log_message "📊 Clients: $PEERS (Mac M2)"
    ! ping -c 1 8.8.8.8 > /dev/null 2>&1 && log_message "⚠️ No Internet"
    sleep 300
done
