#!/bin/bash
set -e

WORKDIR='/home/aytu/jellyfin_project'

echo "🚀 Kind kümesi oluşturuluyor..."
kind create cluster --name jelly-flex --config ${WORKDIR}/cluster/kind-config.yaml

echo "📂 Base storage katmanı uygulanıyor..."
kubectl apply -f ${WORKDIR}/manifests/base/

echo "✅ Küme hazır! Servisleri kurmaya başlayabiliriz."
