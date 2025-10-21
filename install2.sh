
#!/bin/bash
set -e

IMG_XZ="haos_generic-x86-64-16.2.img.xz"
IMG="haos_generic-x86-64-16.2.img"
MOUNT_POINT="/mnt/haos"
BOOT_DIR="/boot/haos"

echo "🔍 Verificando imagem HAOS..."


echo "🔄 Criando loop device..."
LOOP=$(sudo losetup --show -Pf "$IMG")
echo "🌀 Loop device criado: $LOOP"

echo "🔄 Mapeando partições internas..."
sudo kpartx -av "$LOOP"
sleep 2

echo "🔍 Buscando partição com kernel/initrd..."
FOUND=""
for i in $(ls /dev/mapper | grep "$(basename $LOOP)p"); do
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

echo "🧹 Limpando mapeamentos e loop..."
sudo kpartx -d "$LOOP"
sudo losetup -d "$LOOP"

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
