#!/bin/bash
# Tenants
export SERVICE_TOKEN=$SERVICE_TOKEN
export SERVICE_ENDPOINT=$SERVICE_ENDPOINT
export AUTH_ENDPOINT=$AUTH_ENDPOINT

function get_id () {
    echo `$@ | grep id | awk '{print $4}'`
}

ADMIN_PASS="AABBCC112233"
ADMIN_TENANT=`get_id keystone tenant-create --name=admin`
DEMO_TENANT=`get_id keystone tenant-create --name=demo`
INVIS_TENANT=`get_id keystone tenant-create --name=invisible_to_admin`

# Users
ADMIN_USER=`get_id keystone user-create \
                                 --name=admin \
                                 --pass="$ADMIN_PASS" \
                                 --email=admin@example.com`
DEMO_USER=`get_id keystone user-create \
                                 --name=demo \
                                 --pass="EEFFGG445566" \
                                 --email=admin@example.com`

# Roles
ADMIN_ROLE=`get_id keystone role-create --name=admin`
MEMBER_ROLE=`get_id keystone role-create --name=Member`
KEYSTONEADMIN_ROLE=`get_id keystone role-create --name=KeystoneAdmin`
KEYSTONESERVICE_ROLE=`get_id keystone role-create --name=KeystoneServiceAdmin`
SYSADMIN_ROLE=`get_id keystone role-create --name=sysadmin`
NETADMIN_ROLE=`get_id keystone role-create --name=netadmin`


# Add Roles to Users in Tenants

keystone user-role-add --user="$ADMIN_USER" \
                       --role="$ADMIN_ROLE" \
                       --tenant_id="$ADMIN_TENANT"
keystone user-role-add --user="$DEMO_USER" \
                       --role="$MEMBER_ROLE" \
                       --tenant_id="$DEMO_TENANT"
keystone user-role-add --user="$DEMO_USER" \
                       --role="$SYSADMIN_ROLE" \
                       --tenant_id="$DEMO_TENANT"
keystone user-role-add --user="$DEMO_USER" \
                       --role="$NETADMIN_ROLE" \
                       --tenant_id="$DEMO_TENANT"
keystone user-role-add --user="$DEMO_USER" \
                       --role="$MEMBER_ROLE" \
                       --tenant_id="$INVIS_TENANT"
keystone user-role-add --user="$ADMIN_USER" \
                       --role="$ADMIN_ROLE" \
                       --tenant_id="$DEMO_TENANT"

keystone user-role-add --user="$ADMIN_USER" \
                       --role="$KEYSTONEADMIN_ROLE" \
                       --tenant_id="$ADMIN_TENANT"
keystone user-role-add --user="$ADMIN_USER" \
                       --role="$KEYSTONESERVICE_ROLE" \
                       --tenant_id="$ADMIN_TENANT"

# Services
keystone service-create \
                                 --name=nova \
                                 --type=compute \
                                 --description="Nova Compute Service"

keystone service-create \
                                 --name=ec2 \
                                 --type=ec2 \
                                 --description="EC2 Compatibility Layer"

keystone service-create \
                                 --name=glance \
                                 --type=image \
                                 --description="Glance Image Service"

keystone service-create \
                                 --name=keystone \
                                 --type=identity \
                                 --description="Keystone Identity Service"
if [[ "$ENABLED_SERVICES" =~ "swift" ]]; then
    keystone service-create \
                                 --name=swift \
                                 --type="object-store" \
                                 --description="Swift Service"
fi

# create ec2 creds and parse the secret and access key returned
RESULT=`keystone ec2-credentials-create --tenant_id=$ADMIN_TENANT --user=$ADMIN_USER`
    echo `$@ | grep id | awk '{print $4}'`
ADMIN_ACCESS=`echo "$RESULT" | grep access | awk '{print $4}'`
ADMIN_SECRET=`echo "$RESULT" | grep secret | awk '{print $4}'`


RESULT=`keystone ec2-credentials-create --tenant_id=$DEMO_TENANT --user=$DEMO_USER`
DEMO_ACCESS=`echo "$RESULT" | grep access | awk '{print $4}'`
DEMO_SECRET=`echo "$RESULT" | grep secret | awk '{print $4}'`

cat > /root/openstackrc <<EOF
[ -f ~/novarc ] && source ~/novarc
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_TENANT_NAME=admin
export OS_AUTH_URL=$AUTH_ENDPOINT
export OS_AUTH_STRATEGY=keystone

# legacy options for novaclient
export NOVA_API_KEY="\$OS_PASSWORD"
export NOVA_USERNAME="\$OS_USERNAME"
export NOVA_PROJECT_ID="\$OS_TENANT_NAME"
export NOVA_URL="\$OS_AUTH_URL"
export NOVA_VERSION="1.1"
export EC2_ACCESS_KEY=$ADMIN_ACCESS
export EC2_SECRET_KEY=$ADMIN_SECRET
EOF