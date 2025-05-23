#!/bin/bash
echo "🍎 DÉPLOIEMENT RAPIDE MAC M2"
! docker --version && { echo "❌ Installez Docker Desktop"; exit 1; }
! docker ps && { echo "❌ Démarrez Docker Desktop"; exit 1; }
echo "✅ Docker OK - Architecture: $(uname -m)"
chmod +x *.sh scripts/*.sh
docker compose build --no-cache
docker compose up -d
sleep 30
if docker ps | grep -q wireguard-server; then
    echo "🎉 DÉPLOIEMENT RÉUSSI!"
    echo "🔧 Première commande: ./manage-vpn.sh add-client mon-client"
    echo "📊 Dashboard: ./scripts/dashboard-mac.sh"
else
    echo "❌ Erreur - Logs:"
    docker compose logs
fi
