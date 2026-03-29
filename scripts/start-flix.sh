#!/bin/bash

# --- DEĞİŞKENLER ---
CLUSTER_NAME="jelly-lab"
MANIFEST_DIR="/home/aytu/jellyfin_project/manifests"
CONFIG_PATH="/home/aytu/jellyfin_project/cluster/kind-config.yaml"

echo "🚀 Aytu-Flix Kontrol Kulesi başlatıldı..."

# 1. Cluster var mı kontrol et
if ! kind get clusters | grep -q "^$CLUSTER_NAME$"; then
    echo "🆕 Cluster bulunamadı! Yerel dosyalardan inşa ediliyor..."
    kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_PATH"

    # Ingress Controller yolunu BASE klasörü olarak güncelledik
    echo "🌐 Ingress Controller kuruluyor (Local)..."
    kubectl apply -f "$MANIFEST_DIR/BASE/nginx-ingress.yaml"

    # Nginx'in uyanmasını bekle
    echo "⏳ Ingress Controller'ın hazır olması bekleniyor (Bu işlem 1-2 dakika sürebilir)..."
    kubectl wait --namespace ingress-nginx \
      --for=condition=available deployment/ingress-nginx-controller \
      --timeout=120s

    # KÖKTEN ÇÖZÜM: O inatçı Webhook güvenlik duvarını anında yok ediyoruz
    echo "🛡️ Baş belası Webhook güvenlik duvarı devreden çıkarılıyor..."
    kubectl delete validatingwebhookconfiguration ingress-nginx-admission --ignore-not-found=true

    # Sistemin silme işlemini sindirmesi için çok ufak bir esneme payı
    sleep 2

    # 2. Şimdi Aytu-Flix Donanmasını Ateşle
    echo "📦 Tüm uygulamalar ve kurallar (PV, Master Ingress, Podlar) yükleniyor..."
    kubectl apply -f "$MANIFEST_DIR" --recursive
    
    # 3. Kustomize ile Dashboard'u özel olarak bas
    echo "📊 Dashboard Kustomize ile ayağa kaldırılıyor..."
    kubectl apply -k "$MANIFEST_DIR/dashboard/"

    echo "🎬 Aytu-Flix kurulumu tamamlandı ve yayına hazır!"
    exit 0
fi

# 2. Durmuşsa uyandır
STATUS=$(docker inspect -f '{{.State.Status}}' "${CLUSTER_NAME}-control-plane" 2>/dev/null)
if [ "$STATUS" != "running" ]; then
    echo "😴 Sistem uyuyordu, motorlar ateşleniyor..."
    docker start "${CLUSTER_NAME}-control-plane"
    echo "⏳ Sistem kendine geliyor, 10 saniye bekle..."
    sleep 10
else
    echo "✅ Sistem zaten ayakta. (Daha ne istiyon Aytu?)"
fi

echo "🎬 Aytu-Flix yayına hazır!"
