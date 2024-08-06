# Open LDAP server

Deploys an openldap server on ubuntu. [Openldap docs](https://www.openldap.org/doc/admin24/index.html)

## Requirements

You must have an AWS access key, secret key, existing public key in AWS, and access to the corresponding private key.  

## Quickstart

To get everything set up

```
terraform init
terraform apply
```

The above will:
1. Deploy a LDAP server
2. Start the server.
3. Adds 10 users users and 5 groups/nested groups

### Server Start

Once you run terraform apply, you will be prompted to input AWS access key, secret key, subnet id, vpc id, instance name by which a tag will be added to the instance, domain name of the hosted zone and a few other values needed for the script to run.


### Auto-generated structure

You can choose to add users/groups as desired, outside of the scripts provided. However, if you choose to use the scripts approach, the following items will be added:

The main DIT will have the following structure (example users/groups are added for demo purposes)

```
dc=example,dc=me,dc=com
    cn=Manager
    ou=groups
        cn=myGroup
    ou=users
        uid=myUser
```

### Users and nested groups:

Following is the structure of nested groups and groups that will be created. users/groups are for demo purposes:
```
group1:
  user1
  user3
  group2:
    user2
    user4
group7:
   test1
```
      

