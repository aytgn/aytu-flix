#!/bin/bash

# --- TANIMLAMALAR ---
PROJECT_DIR="$HOME/aytu-flix"
MOUNT_POINT="$PROJECT_DIR/storage"
REMOTE_PATH="gdrive:AYTU-FLIX-DATA"
LOG_FILE="$PROJECT_DIR/rclone.log"
CLUSTER_NAME="jelly-lab"
CONTROL_PLANE="${CLUSTER_NAME}-control-plane"

echo "🛑 ADIM 1: Cluster güvenli bir şekilde durduruluyor..."
STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTROL_PLANE" 2>/dev/null)

if [ "$STATUS" == "running" ]; then
    echo "💤 KinD Cluster ($CLUSTER_NAME) uyku moduna alınıyor..."
    docker stop "$CONTROL_PLANE"
    echo "✅ Cluster durduruldu."
else
    echo "🥱 Cluster zaten çalışmıyor, temizlik adımına geçiliyor."
fi

# --- 2. ADIM: ESKİ BAĞLANTIYI TEMİZLE ---
if mountpoint -q "$MOUNT_POINT"; then
    echo "⚠️ Eski bağlantı sökülüyor..."
    fusermount -uz "$MOUNT_POINT"
    sleep 2
fi

# --- 3. ADIM: GÜVENLİK VE YETKİ ---
echo "🔓 Bağlantı noktası yetkileri açılıyor (chmod 755)..."
mkdir -p "$MOUNT_POINT"
chmod 755 "$MOUNT_POINT"

# Kazaara dosya yazıldıysa dur ve kilitle
if [ "$(ls -A "$MOUNT_POINT")" ]; then
    echo "❌ HATA: $MOUNT_POINT boş değil! Kaçak dosyalar var."
    echo "🔒 Güvenlik için klasör kilitleniyor (chmod 000)."
    chmod 000 "$MOUNT_POINT"
    exit 1
fi

# --- 4. ADIM: OPTİMİZE RCLONE MOUNT (Streaming & API Friendly) ---
echo "⏳ Google Drive bağlanıyor (Optimize ayarlarla)..."
rclone mount "$REMOTE_PATH" "$MOUNT_POINT" \
  --allow-other \
  --vfs-cache-mode full \
  --vfs-cache-max-size 20G \
  --vfs-cache-max-age 24h \
  --vfs-disk-space-total-size 1T \
  --buffer-size 128M \
  --vfs-read-chunk-size 128M \
  --vfs-read-chunk-size-limit off \
  --dir-cache-time 5m \
  --poll-interval 15s \
  --no-checksum \
  --no-modtime \
  --drive-chunk-size 64M \
  --log-level INFO \
  --log-file "$LOG_FILE" \
  --daemon \
  --allow-non-empty

# Bağlantının oturması için kısa bir bekleme
sleep 30s

# --- 5. ADIM: SON KONTROL VE CLUSTER'I UYANDIRMA ---
if mountpoint -q "$MOUNT_POINT"; then
    echo "🎉 Rclone başarıyla bağlandı!"
    echo "🚀 ADIM 6: Cluster ($CLUSTER_NAME) yeniden başlatılıyor..."
    docker start "$CONTROL_PLANE"
    echo "🌟 Aytu-Flix sistemi şimdi yayında!"
else
    echo "❌ HATA: Mount işlemi başarısız oldu!"
    echo "🔒 Klasör Radarr'a karşı kilitleniyor (chmod 000)..."
    chmod 000 "$MOUNT_POINT"
    tail -n 10 "$LOG_FILE"
    exit 1
fi
