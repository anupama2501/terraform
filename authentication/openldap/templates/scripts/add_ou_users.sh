# Base DN for your LDAP directory
ADMIN_DN=$(sudo slapcat | grep '^dn: ' | grep 'cn=admin' | sed "s/^dn: //")
BASE_DN=$(echo "$ADMIN_DN" | sed 's/^cn=admin,//')

if [[ -z "$BASE_DN" ]]; then
  echo "Error: BASE_DN is empty. Exiting add_ou_users.sh script"
  exit 1
fi

# Construct the DN for the new entry
NEW_DN="ou=users,$BASE_DN"

LDIF_FILE="/tmp/add_ou_user.ldif"


# Create the LDIF content
cat <<EOF > $LDIF_FILE
dn: $NEW_DN
objectClass: inetOrgPerson
sn: users
cn: users
ou: users

EOF

if [[ -f $LDIF_FILE ]]; then
  cp $LDIF_FILE $LDIF_FILE.bak
fi

echo "Creating ou for the groups"

ldapadd -x -D "$ADMIN_DN" -w "$LDAP_ADMIN_PASSWORD" -f $LDIF_FILE

unset NEW_DN 
unset BASE_DN

