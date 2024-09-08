#!/bin/bash

export GROUPNAME="plugdev"

# create the plugdev group
groupadd $GROUPNAME

# yubikey requires root access for the challenge/response to work correctly
# Allow the console user to access the Yubikey USB device node without root access
#99-hidraw-permissions.rules
cat << EOF > /etc/udev/rules.d/99-hidraw-permissions.rules
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="$GROUPNAME"
EOF

# Add the console user to the plugdev group
echo "Add yourself to the $GROUPNAME group"
echo "sudo usermod -a -G $GROUPNAME \$USER"
usermod -a -G $GROUPNAME $USER
