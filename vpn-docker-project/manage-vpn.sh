#!/bin/bash
CONTAINER="wireguard-server"

case "$1" in
    start) docker compose start wireguard-vpn ;;
    stop) docker compose stop wireguard-vpn ;;
    restart) docker compose restart wireguard-vpn ;;
    status) 
        docker compose ps wireguard-vpn
        echo "🌐 IP: $(curl -s https://api.ipify.org)"
        docker exec $CONTAINER wg show 2>/dev/null || echo "Interface loading..."
        ;;
    logs) docker compose logs -f wireguard-vpn ;;
    add-client)
        docker exec -it $CONTAINER /app/scripts/client-manager.sh add "$2"
        docker cp $CONTAINER:/app/client-configs/$2.conf ./client-configs/ 2>/dev/null
        docker cp $CONTAINER:/app/client-configs/$2.png ./client-configs/ 2>/dev/null
        ;;
    remove-client)
        docker exec -it $CONTAINER /app/scripts/client-manager.sh remove "$2"
        rm -f ./client-configs/$2.conf ./client-configs/$2.png
        ;;
    list-clients) docker exec $CONTAINER /app/scripts/client-manager.sh list ;;
    show-client) docker exec $CONTAINER /app/scripts/client-manager.sh show "$2" ;;
    backup)
        mkdir -p backup
        tar -czf backup/vpn-backup-$(date +%Y%m%d_%H%M%S).tar.gz config/ client-configs/ logs/
        ;;
    shell) docker exec -it $CONTAINER /bin/bash ;;
    *) echo "Usage: $0 {start|stop|restart|status|logs|add-client|remove-client|list-clients|show-client|backup|shell} [nom]" ;;
esac
