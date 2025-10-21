#!/bin/bash
set -e

IMG_XZ="haos_generic-x86-64.img.xz"
IMG="haos_generic-x86-64.img"
TARGET_PART="/dev/sda2"
MOUNT_POINT="/mnt/haos"
BOOT_DIR="/boot/haos"

echo "🔍 Verificando imagem HAOS..."

if [ ! -f "$IMG" ] && [ ! -f "$IMG_XZ" ]; then
  echo "🌐 Baixando imagem HAOS..."
  wget https://release-assets.githubusercontent.com/github-production-release-asset/115992009/c12f33a6-aef4-4cce-b7d6-81db082e66a8?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-10-21T21%3A51%3A09Z&rscd=attachment%3B+filename%3Dhaos_generic-x86-64-16.2.img.xz&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-10-21T20%3A50%3A38Z&ske=2025-10-21T21%3A51%3A09Z&sks=b&skv=2018-11-09&sig=lDDxGyvTqjkV%2BDmpxe4F%2Fk2kY%2FqYtd8uNLf5qHToFOk%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MTA4MzQzOCwibmJmIjoxNzYxMDc5ODM4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.mlN13_8Ro5VUcs8KiiJfrc_nLHZ9FFe-0pKNIX5laSk&response-content-disposition=attachment%3B%20filename%3Dhaos_generic-x86-64-16.2.img.xz&response-content-type=application%2Foctet-stream
fi

if [ ! -f "$IMG" ]; then
  echo "📦 Descompactando imagem..."
  xz -d "$IMG_XZ"
fi

echo "📏 Verificando tamanho da imagem..."
SIZE=$(du -m "$IMG" | cut -f1)
if [ "$SIZE" -lt 5000 ]; then
  echo "❌ Imagem parece incompleta (<5GB). Abortando."
  exit 1
fi

echo "💾 Gravando imagem em $TARGET_PART..."
sudo dd if="$IMG" of="$TARGET_PART" bs=4M status=progress conv=fsync
sync

echo "🔄 Atualizando mapeamentos com kpartx..."
sudo kpartx -d "$TARGET_PART" || true
sudo kpartx -av "$TARGET_PART"
sleep 2

echo "🔍 Buscando partição com kernel/initrd..."
FOUND=""
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
