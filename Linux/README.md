
Using the PQLaserDrv Software under Linux
=========================================

The PQLaserDrv software can also be used under Linux (x86 platform only). 
This requires that Wine is installed (see http://www.winehq.org). We have 
successfully tested with Wine 1.7.11. You can run the regular software setup. 
Instead of installing a device driver, running under Linux with Wine requires 
that you have Libusb 0.1, or even better the combination of Libusb 1.0 and 
Libusb-Compat installed (see http://libusb.sourceforge.net/).


Libusb Access Permissions
=========================

For device access through libusb, your kernel needs support for the USB file-
system (usbfs) and that filesystem must be mounted. This is done automatically, 
if /etc/fstab contains a line like this:

    usbfs /proc/bus/usb usbfs defaults 0 0

This should routinely be the case if you installed any of the mainstream Linux 
distributions. The permissions for the device files used by libusb must be 
adjusted for user access. Otherwise only root can use the device(s). The device 
files are located in /proc/bus/usb/. Any manual change would not be permanent, 
however. The permissions will be reset after reboot or replugging the device. 
The proper way of setting the suitable permissions is by means of udev.


Udev
====

For automated setting of the device file permissions with udev you have to add 
an entry to the set of rules files that are contained in /etc/udev/rules.d. 
Udev processes these files in alphabetical order. The default file is usually 
called 50-udev.rules. Don't change this file as it could be overwritten when 
you upgrade udev. Instead, put your custom rule for PQLaserDrv in a separate 
file. The contents of this file for the handling of the current PQLaserDrv 
models should be:

    ATTR{idVendor}=="0d0e", ATTR{idProduct}=="0007", MODE="666"

A suitable rules file PicoQuantLaser.rules is provided in the folder Linux/udev 
on the distribution media. You can simply copy it to the /etc/udev/rules.d 
folder. The install script in the same distribution media folder does just this. 
Note that the name of the rules file is important. Each time a device is 
detected by the udev system, the files are read in alphabetical order, line by 
line, until a match is found. Note that different distributions may use 
different rule file names for various categories. For instance, Ubuntu organizes 
the rules into further files: 20-names.rules, 40-permissions.rules, and 
60-symlinks.rules. In Fedora they are not separated by those categories, as you 
can see by studying 50-udev.rules. Instead of editing the existing files, it is 
therefore usually recommended to put all of your modifications in a separate 
file like 10-udev.rules or 10-local.rules. The low number at the beginning of 
the file name ensures it will be processed before the default file. However, 
later rules that are more general (applying to a whole class of devices) may 
later override the desired acecss rights. This is the case for USB devices 
handled through Libusb. It is therefore important that you use a rules file for 
the PQLaserDrv that gets evaluated after the general case. The default naming 
PicoQuantLaser.rules most likely ensures this but if you see problems you may 
want to check.
Note that there are different udev implementations with different command sets. 
On some distributions you must reboot to activate changes, on others you can 
reload rule changes and restart udev with these commands:
    # udevcontrol reload_rules
    # udevstart


Limitations
===========

Please note that running the PQLaserDrv software under Linux with Wine is an 
experimental feature that cannot be covered by regular product support.


Known Issues
============

The PQLaserDrv software uses standard calls to the Windows API, that may
be functionally restricted by implementation flaws in Wine. Later versions 
of Wine may cover implementations closer to the expected behaviour.

E.g. with the version tested, the implementation of combo boxes results in 
apparently empty lists if the list opener is activated. In fact, the lists are 
properly populated, but the visualization is not correct. So - compared to a 
run under Windows - you can not select items from a combo box list. As a work-
around, you might select the edit box of the combo and change the item selected 
by use of the <CursorUp>, <CursorDown> keys.