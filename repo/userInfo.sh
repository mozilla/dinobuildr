#!/bin/sh

#
# Optional script by which you can control the user installation.
#
# Variables to set:
#   startDesktop: set to false if you don't want the desktop to start up immediately after installation 
#      CP_USER_HOME: Allows the app to start scanning the user's home folder immediately after installation
#      user:         Used to properly set file permissions
#      userGroup:    Also used for file permissions
#      CP_USER_NAME: This will become the unique ID for the user in the PROe Server database.
#                    Leave CP_USER_NAME blank to require the user to enter it.
#                    If set this value, you'll want to set the username="" attribute of <authority ... /> tag in default.service.xml to username="${username}"
#

#
# Set to false if you don't want the desktop UI to start up.
#
startDesktop=false

#
# When installing from the root account (for example) you will need to populate
# some or all of these variables differently than is done below. 
# Note: whoami *always* returns "root" for this package so we had to get creative to find the installing user.
# Also: You will want to populate CP_USER_NAME with the right email address unless you don't want your users or admins receiving reports and alerts. 
# 
CP_USER_HOME="$HOME"
user=`basename $CP_USER_HOME`
userGroup=`id -gn "$user"`
CP_USER_NAME="$user"


# 
# Users have suggested alternate ways of finding the user name and email address.
# The following examples may work better for your situation.
# 
#user=`last -1 | awk '{print $1}'`

# This assumes the username is the last part of the home folder name
#user=`basename "$CP_USER_HOME"`

# This parses the user from the computer hostname
# Because the APL naming convention uses the name of the owner in the computer name we will use this
# to derive the primary user name. So the primary user does not have to be logged in for this to work.
#computerName=`scutil --get ComputerName`
#user=${computerName%%-*}

# This finds the email address from AD or LDAP
#dsclEmail=`dscl /Search read /Users/$user mail`
#CP_USER_NAME=${dsclEmail##*mail: }

# Run As User
# Uncomment the following line if you want the service to run as user instead of root.
#touch "${TMPDIR}/.cpRunAsUser"
