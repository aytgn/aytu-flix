#!/bin/bash

# --- DEĞİŞKENLER ---
CLUSTER_NAME="jelly-lab"

echo "🛑 Aytu-Flix Kontrol Kulesi kapatılıyor..."

# Container durumunu kontrol et
STATUS=$(docker inspect -f '{{.State.Status}}' "${CLUSTER_NAME}-control-plane" 2>/dev/null)

# Cluster hiç yoksa
if [ -z "$STATUS" ]; then
    echo "❓ Cluster bulunamadı! Ortada durdurulacak bir Aytu-Flix yok."
    exit 1
fi

# Sistem çalışıyorsa durdur
if [ "$STATUS" == "running" ]; then
    echo "💤 Motorlar soğutuluyor, podlar uyku moduna alınıyor..."
    docker stop "${CLUSTER_NAME}-control-plane"
    echo "✅ Aytu-Flix başarıyla durduruldu. Kaynaklar serbest bırakıldı."
else
    echo "🥱 Sistem zaten uykuda. Daha ne kadar durdurayım Aytu?"
fi
