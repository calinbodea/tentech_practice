#!/bin/bash
#
#this script creates a new user on a local system.
#you must supply a username as an argument to the script.
#optionally, you can provide a comment for the account as an argument.
# a password will be automatically generated for the account.
# the username, password and host for the account will be displayed.


# make sure the script is being executed with sudo privileges.
if [[ "${UID}" -ne 0 ]]
then
echo "please run with sudo or as root!" >&2
exit 1
fi

#if the user doesn't provide at least one argument, then give them help.
if [[ "${#}" -lt 1 ]]
then
	echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
	echo "Create an account on the local system of USER_NAME and the comments field of COMMENT." >&2
	exit 1
fi

# The first parameter is the user name.
USER_NAME="${1}"

# the rest of the parameters are fro the account comments.
shift
COMMENT="${@}"

#generate a password.
PASSWORD=$(date +%s%N | sha256sum | head -c48)

# create the user with the password.
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null

# check to see if the username command succeded.
#  we don't want to tell the user an account was created when it hasn't been.
if [[ "${?}" -ne 0 ]]
then
	echo "An account culd not be created." >&2
	exit 1
fi

#set the password.
echo ${PASSWORD} | passwd --stdin ${USER_NAME} &> /dev/null

# check to see if the passwd command has succeeded.
if [[ "${?}" -ne 0 ]]
then
	echo "The password for account could not be set." >&2
	exit 1
fi

#force password change on first login.
passwd -e ${USER_NAME} &> /dev/null

# display the username and the host where the user was created.
echo
echo "username:"
echo "${USER_NAME}"
echo
echo "password:"
echo "${PASSWORD}"
echo
echo "host:"
echo "${HOSTNAME}"
exit 0

