#!/bin/bash

# ==============================================================================
# ADIM 1 (HAZIRLIK - FUSE İŞLEMİ):
# Bu scriptin Docker/Kind içinde düzgün çalışması için şu işlemi yapmış olmalısın:
# 1. 'sudo nano /etc/fuse.conf' komutunu çalıştır.
# 2. '#user_allow_other' satırının başındaki '#' işaretini kaldır ve kaydet.
# ==============================================================================


# 1. Değişkenleri tanımla ve script sonrasında da kullanılabilmesi için 'export' et
export REMOTE_NAME="gdrive"  # Kendi rclone remote ismin neyse onu yaz
export MOUNT_PATH="/home/aytu/jellyfin_project/storage"
export CONFIG_PATH="/home/aytu/.config/rclone/rclone.conf" # Kendi config yolunu yaz

echo "🔄 Rclone mount işlemi başlatılıyor..."

# 3. Takılı varsa çıkar ve temizle
echo "🧹 Eski bağlantılar kontrol ediliyor ve temizleniyor..."

# Eğer mount path doluysa/takılıysa zorla unmount et (hata verirse yoksay)
fusermount -uz "$MOUNT_PATH" 2>/dev/null

# Arka planda bu yola takılı kalmış rclone süreçleri varsa sadece onları öldür
pkill -f "rclone mount.*$MOUNT_PATH" 2>/dev/null

# Sistemin unmount işlemini sindirmesi için ufak bir bekleme
sleep 2

# Mount klasörü yoksa oluştur
if [ ! -d "$MOUNT_PATH" ]; then
    echo "📁 Mount klasörü oluşturuluyor: $MOUNT_PATH"
    mkdir -p "$MOUNT_PATH"
fi

# 2. Yeni ve güvenli (API & SSD dostu) ayarlarla mount et
echo "🚀 Yeni Rclone zırhıyla Google Drive bağlanıyor..."

rclone mount "$REMOTE_NAME:AYTU-FLIX-DATA" "$MOUNT_PATH" \
  --config "$CONFIG_PATH" \
  --allow-other \
  --vfs-cache-mode full \
  --vfs-cache-max-size 50G \
  --vfs-cache-max-age 24h \
  --vfs-read-chunk-size 128M \
  --vfs-read-chunk-size-limit 2G \
  --buffer-size 64M \
  --dir-cache-time 1000h \
  --drive-chunk-size 128M \
  --umask 002 \
  --daemon

echo "✅ İşlem tamam! Google Drive başarıyla $MOUNT_PATH adresine bağlandı."
