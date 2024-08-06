#!/bin/bash

# Export the environment variable
export LDAP_ADMIN_PASSWORD=$1
export USER_PASSWORD=$2

if [[ -z "$USER_PASSWORD" ]]; then
  echo "Error: USER_PASSWORD is empty. Exiting run_all.sh script"
  exit 1
fi

if [[ -z "$LDAP_ADMIN_PASSWORD" ]]; then
  echo "Error: LDAP_ADMIN_PASSWORD is empty. Exiting run_all.sh script"
  exit 1
fi

echo $LDAP_ADMIN_PASSWORD
echo $USER_PASSWORD

# Execute the other scripts
/tmp/add_ou_users.sh
/tmp/add_ou_groups.sh
/tmp/add_users.sh
/tmp/add_groups.sh



