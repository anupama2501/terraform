# Base DN for your LDAP directory
ADMIN_DN=$(sudo slapcat | grep '^dn: ' | grep 'cn=admin' | sed "s/^dn: //")
BASE_DN=$(echo "$ADMIN_DN" | sed 's/^cn=admin,//')
LDIF_FILE="/tmp/add_group.ldif"


if [[ -z "$BASE_DN" ]]; then
  echo "Error: BASE_DN is empty. Exiting add_groups.sh script."
  exit 1
fi

# Construct the DN for the new entry
NEW_DN="ou=groups,$BASE_DN"
LAST_GROUP="testautogroup"

created_groups=()

# Create the LDIF content
generate_user_entry() {
  local i=$1
  local j=$2
  local username="testautogroup$i"

cat <<EOF >> $LDIF_FILE
dn: cn=$username,ou=groups,$BASE_DN
cn: $username
objectClass: groupOfNames
member: cn=testauto$i,ou=users,$BASE_DN
member: cn=testauto$j,ou=users,$BASE_DN
member: cn=testautogroup$j,$NEW_DN

EOF

}


for i in {1..4}; do
  j=$((i + 2))
  generate_user_entry $i $j

  LAST_GROUP="testautogroup$j"
done

#creating a user for the final group. 
newuser="testuser1"

cat <<EOF >> $LDIF_FILE
dn: cn=testuser1,ou=users,$BASE_DN
cn: $newuser
sn: $newuser
uid: $newuser
objectClass: inetOrgPerson
userPassword: $USER_PASSWORD

EOF

cat <<EOF >> $LDIF_FILE
dn: cn=$LAST_GROUP,ou=groups,$BASE_DN
cn: $LAST_GROUP
objectClass: groupOfNames
member: cn=$newuser,ou=users,$BASE_DN

EOF

echo "Starting groups creation"

# Add groups to LDAP
ldapadd -x -D "$ADMIN_DN" -w "$LDAP_ADMIN_PASSWORD" -f $LDIF_FILE