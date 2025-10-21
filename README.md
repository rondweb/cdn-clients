# cdn-clients

#!/bin/bash

set -e

IMG="haos_generic-x86-64.img"
TARGET_PART="/dev/sda2"
MOUNT_POINT="/mnt/haos"
BOOT_DIR="/boot/haos"

echo "🔍 Verificando imagem..."
if [ ! -f "$IMG" ]; then
  echo "❌ Imagem $IMG não encontrada. Certifique-se de descompactar o .img.xz antes."
  exit 1
fi

echo "💾 Gravando imagem em $TARGET_PART..."
sudo dd if="$IMG" of="$TARGET_PART" bs=4M status=progress conv=fsync

echo "🔄 Atualizando mapeamentos com kpartx..."
sudo kpartx -d "$TARGET_PART" || true
sudo kpartx -av "$TARGET_PART"

echo "⏳ Aguardando dispositivos /dev/mapper..."
sleep 2

echo "🔍 Buscando partição com kernel/initrd..."
for i in $(ls /dev/mapper | grep "$(basename $TARGET_PART)p"); do
  echo "📦 Testando /dev/mapper/$i..."
  sudo mkdir -p "$MOUNT_POINT"
  if sudo mount "/dev/mapper/$i" "$MOUNT_POINT" 2>/dev/null; then
    if [ -f "$MOUNT_POINT/kernel" ] && [ -f "$MOUNT_POINT/initrd" ]; then
      echo "✅ Encontrado: kernel e initrd em /dev/mapper/$i"
      sudo mkdir -p "$BOOT_DIR"
      sudo cp "$MOUNT_POINT/kernel" "$BOOT_DIR/vmlinuz"
      sudo cp "$MOUNT_POINT/initrd" "$BOOT_DIR/initrd.img"
      sudo umount "$MOUNT_POINT"
      FOUND=1
      break
    else
      sudo umount "$MOUNT_POINT"
    fi
  fi
done

if [ -z "$FOUND" ]; then
  echo "❌ Nenhuma partição com kernel/initrd encontrada."
  exit 1
fi

echo "✅ Arquivos copiados para $BOOT_DIR"
echo "🧠 Adicione a seguinte entrada ao seu /etc/grub.d/40_custom:"
echo
echo 'menuentry "Home Assistant OS" {'
echo '    set root=(hd0,2)'
echo '    linux /boot/haos/vmlinuz root=/dev/sda2'
echo '    initrd /boot/haos/initrd.img'
echo '}'
echo
echo "⚙️ Depois execute: sudo update-grub"
