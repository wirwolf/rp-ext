#!/usr/bin/env ash

echo "${1}"

if [ "${1}" = "on_boot" ]; then
  echo "dtbpatch - on_boot"
  # fix executable flag
  cp dtbpatch /usr/sbin/
  chmod +x /usr/sbin/dtbpatch

  # Dynamic generation
  /usr/bin/dtbpatch /etc.defaults/model.dtb output.dtb
  if [ $? -ne 0 ]; then
    echo "Error patching dtb"
  else
    cp -vf output.dtb /etc.defaults/model.dtb
    cp -vf output.dtb /var/run/model.dtb
  fi
elif [ "${1}" = "on_os_load" ]; then
  echo "dtbpatch - on_os_load"
  # copy file
  cp -vf /etc.defaults/model.dtb /tmpRoot/etc.defaults/model.dtb
fi
