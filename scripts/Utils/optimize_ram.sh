#!/bin/bash
echo "RAM Optimizasyonu Başlatılıyor..."

# 1. ZRAM Yapılandırması (zram-generator.conf)
# RAM'in tamamı kadar (zram-size = ram) alan ayırıyoruz.
# Algoritma olarak zstd kullanıyoruz.
echo "ZRAM yapılandırması güncelleniyor..."
sudo bash -c 'cat > /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ram
compression-algorithm = zstd
EOF'

# 2. Sysctl Ayarları (zram-optimized.conf)
# ZRAM kullanırken swappiness yüksek olmalı (varsayılan 60, biz 150-180 arası öneririz).
echo "Kernel (Sysctl) ayarları uygulanıyor..."
sudo bash -c 'cat > /etc/sysctl.d/99-zram-optimized.conf <<EOF
vm.swappiness = 160
vm.vfs_cache_pressure = 500
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
EOF'

# Ayarları hemen uygula
sudo sysctl --system

# 3. ZRAM servisini yeniden başlat
echo "ZRAM servisi yeniden başlatılıyor..."
sudo systemctl restart systemd-zram-setup@zram0.service

echo "------------------------------------------------"
echo "İŞLEM TAMAMLANDI."
echo "Yeni ZRAM durumunu görmek için 'zramctl' komutunu kullanabilirsiniz."
