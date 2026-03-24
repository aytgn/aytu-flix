#!/bin/bash
echo "🚀 Aytu-Flix motorları ateşleniyor..."

# 1. Uyuyan konteynerleri uyandır
docker start $(docker ps -a -q --filter "label=io.x-k8s.kind.cluster=jelly-lab") > /dev/null

echo "⏳ Ingress ve Podların toparlanması bekleniyor (15 saniye)..."
sleep 15

echo "🎬 Sistem hazır, localhost üzerinden yayındayız!"
