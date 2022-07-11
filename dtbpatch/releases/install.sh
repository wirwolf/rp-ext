#!/usr/bin/env ash

if [ ! -f model_${PLATFORM_ID}.dtb ]; then
echo "dtb file not exists for this platform!!!, dtbpatch running..."

  # fix executable flag
  cp dtbpatch /usr/sbin/
  chmod +x /usr/sbin/dtbpatch

  # Dynamic generation
  /usr/sbin/dtbpatch /etc.defaults/model.dtb output.dtb
  if [ $? -ne 0 ]; then
    echo "auto generated dtb file is broken"
  else
    cp -vf output.dtb /etc.defaults/model.dtb
    cp -vf output.dtb /var/run/model.dtb
  fi
else
  cp -vf model_${PLATFORM_ID}.dtb /etc.defaults/model.dtb
  cp -vf model_${PLATFORM_ID}.dtb /var/run/model.dtb
fi
