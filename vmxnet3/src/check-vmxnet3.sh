#
# Checking modules is loaded
#

echo -n "Loading module vmxnet3 -> "

if [ `/sbin/lsmod |grep -i vmxnet3|wc -l` -gt 0 ] ; then
    echo "Module vmxnet3 loaded succesfully"
    modprobe -r vmxnet3
    modprobe vmxnet3 disable_lro=1
else echo "Module vmxnet3 is not loaded "
fi
