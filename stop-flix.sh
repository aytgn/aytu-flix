#!/bin/bash
echo "🛑 Aytu-Flix uyku moduna alınıyor..."

# 1. Arka planda çalışan port-forward işlemlerini bul ve öldür
pkill -f "kubectl port-forward" 2>/dev/null
echo "🔌 Port tünelleri kapatıldı."

# 2. Kind cluster konteynerlerini durdur (Küme adın jelly-lab ise)
docker stop $(docker ps -q --filter "label=io.x-k8s.kind.cluster=jelly-lab") > /dev/null
echo "💤 Sistem başarıyla uyutuldu."
