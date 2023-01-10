  echo "Installing NVMe cache enabler tools"
  cp -vf nvme-cache.sh /tmpRoot/usr/sbin/nvme-cache.sh
  chmod 755 /tmpRoot/usr/sbin/nvme-cache.sh
  cp -vf nvme-cache.service /tmpRoot/etc/systemd/system/nvme-cache.service
  chmod 755 /tmpRoot/etc/systemd/system/nvme-cache.service
  mkdir -p /tmpRoot/etc/systemd/system/multi-user.target.wants
  ln -sf /etc/systemd/system/nvme-cache.service /tmpRoot/etc/systemd/system/multi-user.target.wants/nvme-cache.service