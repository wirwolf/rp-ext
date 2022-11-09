#!/bin/bash
#
# Checking modules is loaded
#

function listextension() {

    if [ ! -z $1 ]; then
        echo "Searching for matching extension for $1"
        tar xvfzp ${TARGET_PLATFORM}-${LINUX_VER}.tgz ${1}.ko
        insmod ${1}.ko
    else
        echo "No matching extension"
    fi

}

function matchpciidmodule() {

    vendor="$(echo $1 | sed 's/[a-z]/\U&/g')"
    device="$(echo $2 | sed 's/[a-z]/\U&/g')"
    
    pciid="${vendor}d0000${device}"

    matchedmodule=$(jq -e -r ".modules[] | select(.alias | contains(\"${pciid}\")?) | .name " $MODULE_ALIAS_FILE)

    # Call listextensions for extention matching

    listextension $matchedmodule

}

function listpci() {

#None DTC Platform in junior it appears after 5 bytes.

    lspci -n | while read line; do

        case $TARGET_PLATFORM in

        geminilake | v1000 )
            bus="$(echo $line | cut -c 1-7)"
            class="$(echo $line | cut -c 9-12)"
            vendor="$(echo $line | cut -c 15-18)"
            device="$(echo $line | cut -c 20-23)"        
            ;;
        bromolow | apollolake | broadwell | broadwellnk | denverton | *)
            bus="$(echo $line | cut -c 6-12)"
            class="$(echo $line | cut -c 14-17)"
            vendor="$(echo $line | cut -c 20-23)"
            device="$(echo $line | cut -c 25-28)"
            ;;
        esac


        echo "PCI : $bus Class : $class Vendor: $vendor Device: $device"
        case $class in
        0100)
            echo "Found SCSI Controller : pciid ${vendor}d0000${device}  Required Extension : $(matchpciidmodule ${vendor} ${device})"
            ;;
        0106)
            echo "Found SATA Controller : pciid ${vendor}d0000${device}  Required Extension : $(matchpciidmodule ${vendor} ${device})"
            ;;
        0101)
            echo "Found IDE Controller : pciid ${vendor}d0000${device}  Required Extension : $(matchpciidmodule ${vendor} ${device})"
            ;;
        0107)
            echo "Found SAS Controller : pciid ${vendor}d0000${device}  Required Extension : $(matchpciidmodule ${vendor} ${device})"
            ;;
        0200)
            echo "Found Ethernet Interface : pciid ${vendor}d0000${device} Required Extension : $(matchpciidmodule ${vendor} ${device})"
            ;;
        0300)
            echo "Found VGA Controller : pciid ${vendor}d0000${device}  Required Extension : $(matchpciidmodule ${vendor} ${device})"
            ;;
        0c04)
            echo "Found Fibre Channel Controller : pciid ${vendor}d0000${device}  Required Extension : $(matchpciidmodule ${vendor} ${device})"
            ;;
        esac
    done

}

function getvars() {

    TARGET_PLATFORM="$(uname -u | cut -d '_' -f2)"
    LINUX_VER="$(uname -r | cut -d '+' -f1)"
    
    echo $TARGET_PLATFORM
    echo $LINUX_VER

    case $TARGET_PLATFORM in

    bromolow)
        KERNEL_MAJOR="3"
        MODULE_ALIAS_FILE="modules.alias.3.json"
        ;;
    apollolake | broadwell | broadwellnk | v1000 | denverton | geminilake | *)
        KERNEL_MAJOR="4"
        MODULE_ALIAS_FILE="modules.alias.4.json"
        ;;
    esac
    
    echo $MODULE_ALIAS_FILE
}

function preparedetect() {

echo "Copying sed,jq,lspci files to /sbin/"
/bin/cp -v sed    /usr/sbin/  ; chmod 700 /usr/sbin/sed
/bin/cp -v jq    /usr/sbin/  ; chmod 700 /usr/sbin/jq
/bin/cp -v lspci /usr/sbin/  ; chmod 700 /usr/sbin/lspci

echo "Copying lspci libraries to /lib/"
/bin/cp -v libz.so.1      /lib  ; chmod 644 /lib/libz.so.1     
/bin/cp -v libudev.so.1   /lib  ; chmod 644 /lib/libudev.so.1  
/bin/cp -v libattr.so.1   /lib  ; chmod 644 /lib/libattr.so.1  
/bin/cp -v libcap.so.2    /lib  ; chmod 644 /lib/libcap.so.2

}

getvars
preparedetect
listpci

#echo -n "Loading module igc -> "

#if [ `/sbin/lsmod |grep -i igc|wc -l` -gt 0 ] ; then
#        echo "Module igc loaded succesfully"
#        else echo "Module igc is not loaded "
#fi
