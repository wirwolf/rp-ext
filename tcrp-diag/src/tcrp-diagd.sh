#!/bin/sh

# You can force junior by adding force_junior in the linux cmdline 

function preparediag(){

echo "Copying tcrp auxiliary files to /sbin/"
/bin/cp -v lsscsi /usr/sbin/ ; chmod 700 /usr/sbin/lsscsi
/bin/cp -v lspci  /usr/sbin/  ; chmod 700 /usr/sbin/lspci
/bin/cp -v lsusb  /usr/sbin/  ; chmod 700 /usr/sbin/lsusb
/bin/cp -v dmidecode /usr/sbin/  ; chmod 700 /usr/sbin/dmidecode
/bin/cp -v dtc /usr/sbin/  ; chmod 700 /usr/sbin/dtc
/bin/cp -v ethtool /usr/sbin/  ; chmod 700 /usr/sbin/ethtool
/bin/cp -v tcrp-diag.sh /usr/sbin/  ; chmod 700 /usr/sbin/tcrp-diag.sh

echo "Copying tcrp libraries to /lib/"
/bin/cp -v libpci.so.3 /lib ; chmod 644 /lib/libpci.so.3
/bin/cp -v libusb-1.0.so.0 /lib  ; chmod 644 /lib/libusb-1.0.so.0
/bin/cp -v libz.so.1      /lib  ; chmod 644 /lib/libz.so.1     
/bin/cp -v libudev.so.1   /lib  ; chmod 644 /lib/libudev.so.1  
/bin/cp -v libkmod.so.2   /lib  ; chmod 644 /lib/libkmod.so.2  
/bin/cp -v libresolv.so.2 /lib  ; chmod 644 /lib/libresolv.so.2
/bin/mkdir /var/lib/usbutils ; /bin/cp usb.ids /var/lib/usbutils/usb.ids ;  chmod 644 /var/lib/usbutils/usb.ids

}


function getvars(){

    let HEAD=1

    #if [ -n "$(grep tcrpdiag /proc/cmdline)" ]; then
    #TCRPDIAG="enabled"
    #else 
    #TCRPDIAG=""
    #fi

    ### USUALLY SCEMD is the last process run in init, so when scemd is running we are most 
    # probably certain that system has finish init process 
    #

    if [ `ps -ef |grep -i scemd |grep -v grep | wc -l` -gt 0 ] ; then 
        HASBOOTED="yes"
        echo "System has completed init process"
    else 
        echo "System is booting"
        HASBOOTED="no"
    fi

}


############ START RUN ############
getvars
echo "TCRP DIAGD START !!!!!!" 	

#wait_time=5 # maximum wait time in seconds
#time_counter=0
#while [ $(ifconfig eth0 | grep inet | wc -l) -eq 0 ] && [ $time_counter -lt $wait_time ]; do
#  sleep 1
#  echo "Still waiting for the eth0 device to get an IP (waited $((time_counter=time_counter+1)) of ${wait_time} seconds)"
#done

#if [ $(ifconfig eth0 | grep inet | wc -l) -eq 0 ]; then

    if  [ "$HASBOOTED" = "no" ] ; then
        preparediag       
    fi
    
 #   wait_time=50 # maximum wait time in seconds
 #   time_counter=0
 #   while [ $time_counter -lt $wait_time ]; do
 #     sleep 1
 #     echo "Still waiting for all devices to write logs (waited $((time_counter=time_counter+1)) of ${wait_time} seconds)"
 #   done

    /usr/sbin/tcrp-diag.sh 

#    if [ "$HASBOOTED" = "yes" ] ; then
        startcollection
#    fi
#fi    

exit 0
