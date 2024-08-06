#!/bin/bash
ADMIN_DN=$(sudo slapcat | grep '^dn: ' | grep 'cn=admin' | sed "s/^dn: //")
BASE_DN=$(echo "$ADMIN_DN" | sed 's/^cn=admin,//')

if [[ -z "$BASE_DN" ]]; then
  echo "Error: BASE_DN is empty. Exiting add_user.sh script"
  exit 1
fi

if [[ -z "$ADMIN_DN" ]]; then
  echo "Error: BASE_DN is empty. Exiting add_user.sh script"
  exit 1
fi

echo "This is the user base dn $BASE_DN"
echo "This is the service account distinguished name: $ADMIN_DN"


# Function to generate a user entry
generate_user_entry() {
  local username="testauto$1"

  cat <<EOF
dn: cn=$username,ou=users,$BASE_DN
cn: $username
sn: $username
uid: $username
objectClass: inetOrgPerson
userPassword: $USER_PASSWORD

EOF

}

LDIF_FILE="/tmp/add_user.ldif"

# Backup existing LDIF file if it exists
if [[ -f $LDIF_FILE ]]; then
  cp $LDIF_FILE $LDIF_FILE.bak
fi

# Generate user entries and append to the LDIF file
for i in {1..10}; do
  generate_user_entry $i >> $LDIF_FILE
done

echo "Starting user creation"

# Add users to LDAP
ldapadd -x -D "$ADMIN_DN" -w "$LDAP_ADMIN_PASSWORD" -f $LDIF_FILE