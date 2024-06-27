#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 /dev/sdX"
  exit 1
fi

DEVICE=$1

# Check if the provided device is a valid disk
if ! lsblk -dn -o TYPE "$DEVICE" | grep -q "disk"; then
  echo "Error: $DEVICE is not a valid disk device."
  exit 1
fi

# List all partitions of the given disk
PARTITIONS=$(lsblk -ln -o NAME "$DEVICE" | grep -v "^$(basename $DEVICE)$")

# Check if any partitions are found
if [ -z "$PARTITIONS" ]; then
  echo "No partitions found on $DEVICE."
fi

# Unmount all partitions
for PARTITION in $PARTITIONS; do
  PARTITION_PATH="/dev/$PARTITION"
  MOUNTPOINT=$(lsblk -ln -o MOUNTPOINT "$PARTITION_PATH" | grep -v "^$")
  if [ -n "$MOUNTPOINT" ]; then
    echo "Unmounting $PARTITION_PATH from $MOUNTPOINT"
    sudo umount "$PARTITION_PATH"
    if [ $? -ne 0 ]; then
      echo "Failed to unmount $PARTITION_PATH"
      exit 1
    fi
  else
    echo "$PARTITION_PATH is not mounted."
  fi
done

echo "All mounted partitions on $DEVICE have been unmounted."

sleep 2

sudo fdisk $DEVICE <<EOF &>> out.log
o
w
EOF

sleep 2

echo "Creating Partitions..."
sudo fdisk $DEVICE <<EOF &>> out.log
n
p
1
32768
237567
n
p
2
247808
346111
n
p
3
346112
3622911

n
e
3622912
7837695
n
3624960
3829759

n
3831808
7837695
t
1
b
t
2
b
w
EOF

for i in 1 2; do
 sudo mkfs.vfat -F 32 "${DEVICE}${i}" &>> out.log
done

for i in 3 5 6; do
 sudo mkfs.ext4 -F "${DEVICE}${i}" &>> out.log
done

mkdir -p mount
sudo mount "${DEVICE}2" ./mount
# ls ./mount
sudo rm -rf ./mount/*

echo "Flashing Device Tree and Kernel..."
sudo cp zImage.bin ./mount
sudo cp tempus.dtb ./mount
sudo sync "${DEVICE}2"
# ls mount
sleep 2
sudo umount "${DEVICE}2"

sudo mount "${DEVICE}3" ./mount
# ls ./mount
sudo rm -rf ./mount/*

echo "Flashing RootFS..."
pushd ./mount > /dev/null
sudo tar -xjf $OLDPWD/rootfs.tar.bz2
popd  > /dev/null
sudo sync "${DEVICE}3"
# ls mount
sleep 2
sudo umount "${DEVICE}3"

echo "Flashing U-Boot Bootloader..."
sudo dd if=u-boot.imx of="${DEVICE}" seek=1 skip=1 bs=1k &>> out.log
echo "Syncing $DEVICE"
sudo sync $DEVICE

echo "Flashing Complete"


