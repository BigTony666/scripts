#!/bin/bash
#
# This script creates a new user on the local system
# You can supply a username as an argument to the script, optionally you can also provide a comment for the account as an argument.
# If arguments are ignored, you will be prompted to enter the username(login) and the person name.
# A password will automatically generated for the account.
# The username, password, and host for the account will be displayed

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
  echo "Please run with as root, probably you forget sudo?" >&2
  exit 1
fi

if [[ "${#}" == 0 ]]; then
  # Get the username(login)
  read -p "Enter the username to create: " USER_NAME

  # Get the real name(contents for the description field)
  read -p "Enter the name of the person or application that will be using this account:" COMMENT

else
  if [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]]; then
    echo "Usage: ${0} [USER_NAME] [COMMENT...]"
    echo "Create an account on the local system with the name of USER_NAME and a comments field of COMMENT"
    exit 1
  else
    # The first parameter is the user name
    USER_NAME="${1}"

    # The rest of the parameters are for the account comments.
    shift
    COMMENT="${@}"
  fi
fi

# Generate a password
PASSWORD=$(date +%s%N | sha256sum | head -c10)

# Create the account, redirect the output and error to null(discard the message)
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null

# Check to see if the useradd command succeeded
if [[ "${?}" -ne 0 ]]
then
  echo "The account could not be created." >&2
  exit 1
fi

# Set the password
echo ${PASSWORD} | passwd --stdin ${USER_NAME} &> /dev/null

if [[ "${?}" -ne 0 ]]
then
  echo "The password for the account could not be set." >&2
  exit 1
fi

# Force password change on first login.
passwd -e ${USER_NAME} &> /dev/null

# Display the username, password, and the host where the user was created
echo "username:"
echo "${USER_NAME}"
echo
echo "password:"
echo "${PASSWORD}"
echo
echo "host:"
echo "${HOSTNAME}"
exit 0