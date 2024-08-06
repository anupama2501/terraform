# Base DN for your LDAP directory
ADMIN_DN=$(sudo slapcat | grep '^dn: ' | grep 'cn=admin' | sed "s/^dn: //")
BASE_DN=$(echo "$ADMIN_DN" | sed 's/^cn=admin,//')

LDIF_FILE="/tmp/add_ou_group.ldif"

if [[ -f $LDIF_FILE ]]; then
  cp $LDIF_FILE $LDIF_FILE.bak
fi

if [[ -z "$BASE_DN" ]]; then
  echo "Error: BASE_DN is empty. Exiting add_ou_groups.sh script"
  exit 1
fi

# Construct the DN for the new entry
NEW_DN="ou=groups,$BASE_DN"

# Create the LDIF content
cat <<EOF > $LDIF_FILE
dn: $NEW_DN
objectClass: organizationalUnit
ou: groups

EOF

echo "Creating ou for the groups"


ldapadd -x -D "$ADMIN_DN" -w "$LDAP_ADMIN_PASSWORD" -f $LDIF_FILE

unset NEW_DN 
unset BASE_DN