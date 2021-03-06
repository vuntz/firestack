#!/bin/bash
# Tenants
export SERVICE_TOKEN=$SERVICE_TOKEN
export SERVICE_ENDPOINT=$SERVICE_ENDPOINT
export AUTH_ENDPOINT=$AUTH_ENDPOINT
export OS_NO_CACHE=1

function get_id () {
    echo `$@ | awk '/ id / { print $4 }'`
}

ADMIN_PASSWORD="AABBCC112233"
USER1_PASSWORD="DDEEFF445566"
USER2_PASSWORD="GGHHII778899"
SERVICE_PASSWORD="SERVICE_PASSWORD"
ADMIN_TENANT=`get_id keystone tenant-create --name=admin`
SERVICE_TENANT=$(get_id keystone tenant-create --name=service)
USER1_TENANT=`get_id keystone tenant-create --name=user1`
USER2_TENANT=`get_id keystone tenant-create --name=user2`
INVIS_TENANT=`get_id keystone tenant-create --name=invisible_to_admin`

# Users
ADMIN_USER=`get_id keystone user-create \
                                 --name=admin \
                                 --pass="$ADMIN_PASSWORD" \
                                 --email=admin@example.com`
USER1_USER=`get_id keystone user-create \
                                 --name=user1 \
                                 --pass="$USER1_PASSWORD" \
                                 --email=user1@example.com`
USER2_USER=`get_id keystone user-create \
                                 --name=user2 \
                                 --pass="GGHHII778899" \
                                 --pass="$USER2_PASSWORD" \
                                 --email=user2@example.com`

# Roles
ADMIN_ROLE=`get_id keystone role-create --name=admin`
MEMBER_ROLE=`get_id keystone role-create --name=Member`
KEYSTONEADMIN_ROLE=`get_id keystone role-create --name=KeystoneAdmin`
KEYSTONESERVICE_ROLE=`get_id keystone role-create --name=KeystoneServiceAdmin`
SYSADMIN_ROLE=`get_id keystone role-create --name=sysadmin`
NETADMIN_ROLE=`get_id keystone role-create --name=netadmin`


# Add Roles to Users in Tenants

keystone user-role-add --user_id="$ADMIN_USER" \
                       --role_id="$ADMIN_ROLE" \
                       --tenant_id="$ADMIN_TENANT"

#user1
keystone user-role-add --user_id="$USER1_USER" \
                       --role_id="$MEMBER_ROLE" \
                       --tenant_id="$USER1_TENANT"
keystone user-role-add --user_id="$USER1_USER" \
                       --role_id="$SYSADMIN_ROLE" \
                       --tenant_id="$USER1_TENANT"
keystone user-role-add --user_id="$USER1_USER" \
                       --role_id="$NETADMIN_ROLE" \
                       --tenant_id="$USER1_TENANT"
keystone user-role-add --user_id="$USER1_USER" \
                       --role_id="$MEMBER_ROLE" \
                       --tenant_id="$INVIS_TENANT"
keystone user-role-add --user_id="$ADMIN_USER" \
                       --role_id="$ADMIN_ROLE" \
                       --tenant_id="$USER1_TENANT"

#user2
keystone user-role-add --user_id="$USER2_USER" \
                       --role_id="$MEMBER_ROLE" \
                       --tenant_id="$USER2_TENANT"
keystone user-role-add --user_id="$USER2_USER" \
                       --role_id="$SYSADMIN_ROLE" \
                       --tenant_id="$USER2_TENANT"
keystone user-role-add --user_id="$USER2_USER" \
                       --role_id="$NETADMIN_ROLE" \
                       --tenant_id="$USER2_TENANT"
keystone user-role-add --user_id="$USER2_USER" \
                       --role_id="$MEMBER_ROLE" \
                       --tenant_id="$INVIS_TENANT"
keystone user-role-add --user_id="$ADMIN_USER" \
                       --role_id="$ADMIN_ROLE" \
                       --tenant_id="$USER2_TENANT"

#keystone admin
keystone user-role-add --user_id="$ADMIN_USER" \
                       --role_id="$KEYSTONEADMIN_ROLE" \
                       --tenant_id="$ADMIN_TENANT"
keystone user-role-add --user_id="$ADMIN_USER" \
                       --role_id="$KEYSTONESERVICE_ROLE" \
                       --tenant_id="$ADMIN_TENANT"

# Nova Service
keystone service-create \
                                 --name=nova \
                                 --type=compute \
                                 --description="Nova Compute Service"
NOVA_USER=`get_id keystone user-create \
                                 --name=nova \
                                 --pass="$SERVICE_PASSWORD" \
                                 --email=nova@example.com`
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user_id $NOVA_USER \
                       --role_id $ADMIN_ROLE

# EC2 Service (no user required)
keystone service-create \
                                 --name=ec2 \
                                 --type=ec2 \
                                 --description="EC2 Compatibility Layer"

# Glance Service
keystone service-create \
                                 --name=glance \
                                 --type=image \
                                 --description="Glance Image Service"
GLANCE_USER=`get_id keystone user-create \
                                 --name=glance \
                                 --pass="$SERVICE_PASSWORD" \
                                 --email=glance@example.com`
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user_id $GLANCE_USER \
                       --role_id $ADMIN_ROLE

# Cinder Service
keystone service-create \
                                 --name=cinder \
                                 --type=image \
                                 --description="Glance Image Service"
CINDER_USER=`get_id keystone user-create \
                                 --name=cinder \
                                 --pass="$SERVICE_PASSWORD" \
                                 --email=cinder@example.com`
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user_id $CINDER_USER \
                       --role_id $ADMIN_ROLE

# Quantum Service
keystone service-create \
                                 --name=quantum \
                                 --type=network \
                                 --description="Quantum Service"
QUANTUM_USER=`get_id keystone user-create \
                                 --name=quantum \
                                 --pass="$SERVICE_PASSWORD" \
                                 --email=quantum@example.com`
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user_id $QUANTUM_USER \
                       --role_id $ADMIN_ROLE

# Keystone Service
keystone service-create \
                                 --name=keystone \
                                 --type=identity \
                                 --description="Keystone Identity Service"

# Swift Service
keystone service-create \
                             --name=swift \
                             --type="object-store" \
                             --description="Swift Service"
SWIFT_USER=`get_id keystone user-create \
                             --name=swift \
                             --pass="$SERVICE_PASSWORD" \
                             --email=swift@example.com`
keystone user-role-add --tenant_id $SERVICE_TENANT \
                             --user_id $SWIFT_USER \
                             --role_id $ADMIN_ROLE

# create ec2 creds and parse the secret and access key returned
RESULT=`keystone ec2-credentials-create --tenant_id=$ADMIN_TENANT --user_id=$ADMIN_USER`
    echo `$@ | grep id | awk '{print $4}'`
ADMIN_ACCESS=`echo "$RESULT" | grep access | awk '{print $4}'`
ADMIN_SECRET=`echo "$RESULT" | grep secret | awk '{print $4}'`


RESULT=`keystone ec2-credentials-create --tenant_id=$USER1_TENANT --user_id=$USER1_USER`
USER1_ACCESS=`echo "$RESULT" | grep access | awk '{print $4}'`
USER1_SECRET=`echo "$RESULT" | grep secret | awk '{print $4}'`

RESULT=`keystone ec2-credentials-create --tenant_id=$USER2_TENANT --user_id=$USER2_USER`
USER2_ACCESS=`echo "$RESULT" | grep access | awk '{print $4}'`
USER2_SECRET=`echo "$RESULT" | grep secret | awk '{print $4}'`

cat > /root/.openstackrc <<EOF
#COMMON ENV OPTIONS FOR FIRESTACK INIT SCRIPTS

# disable keyring caching in python-keystoneclient
export OS_NO_CACHE=\${OS_NO_CACHE:-1}

# legacy options for novaclient
export NOVA_API_KEY="\$OS_PASSWORD"
export NOVA_USERNAME="\$OS_USERNAME"
export NOVA_PROJECT_ID="\$OS_TENANT_NAME"
export NOVA_URL="\$OS_AUTH_URL"
export NOVA_VERSION="1.1"

# Set the ec2 url so euca2ools works
export EC2_URL=\$(keystone catalog --service ec2 | awk '/ publicURL / { print \$4 }')

NOVA_KEY_DIR=\${NOVA_KEY_DIR:-\$HOME}
export S3_URL=\$(keystone catalog --service s3 | awk '/ publicURL / { print \$4 }')
export EC2_USER_ID=42 # nova does not use user id, but bundling requires it
export EC2_PRIVATE_KEY=\${NOVA_KEY_DIR}/pk.pem
export EC2_CERT=\${NOVA_KEY_DIR}/cert.pem
export NOVA_CERT=\${NOVA_KEY_DIR}/cacert.pem
export EUCALYPTUS_CERT=\${NOVA_CERT} # euca-bundle-image seems to require this set
alias ec2-bundle-image="ec2-bundle-image --cert \${EC2_CERT} --privatekey \${EC2_PRIVATE_KEY} --user \${EC2_USER_ID} --ec2cert \${NOVA_CERT}"
alias ec2-upload-bundle="ec2-upload-bundle -a \${EC2_ACCESS_KEY} -s \${EC2_SECRET_KEY} --url \${S3_URL} --ec2cert \${NOVA_CERT}"
EOF

#admin (openstackrc)
cat > /root/openstackrc <<EOF
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASSWORD
export OS_TENANT_NAME=admin
export OS_AUTH_URL=$AUTH_ENDPOINT
export OS_AUTH_STRATEGY=keystone

export EC2_ACCESS_KEY=$ADMIN_ACCESS
export EC2_SECRET_KEY=$ADMIN_SECRET

source .openstackrc
EOF

#user1
cat > /root/user1rc <<EOF
export OS_USERNAME=user1
export OS_PASSWORD=$USER1_PASSWORD
export OS_TENANT_NAME=user1
export OS_AUTH_URL=$AUTH_ENDPOINT
export OS_AUTH_STRATEGY=keystone

export EC2_ACCESS_KEY=$USER1_ACCESS
export EC2_SECRET_KEY=$USER1_SECRET

source .openstackrc
EOF

#user2
cat > /root/user2rc <<EOF
export OS_USERNAME=user2
export OS_PASSWORD=$USER2_PASSWORD
export OS_TENANT_NAME=user2
export OS_AUTH_URL=$AUTH_ENDPOINT
export OS_AUTH_STRATEGY=keystone

export EC2_ACCESS_KEY=$USER2_ACCESS
export EC2_SECRET_KEY=$USER2_SECRET

source .openstackrc
EOF
