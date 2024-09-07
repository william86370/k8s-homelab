#!/bin/bash

# Variables
NAMESPACE="semaphore-system"  # Set the namespace of your pod
SECRET_NAME="semaphore-admin"  # Set the name of the secret
DEPLOYMENT_NAME="semaphore-ansible-semaphore"  # Set the name of the pod to exec into
ADMIN_USER="admin"  # Admin username
PASSWORD_LENGTH=16  # Length of the password

# Generate a random password and save it in an environment variable
ADMIN_PASSWORD=$(openssl rand -base64 $PASSWORD_LENGTH)

# Command to create the user inside the pod (change the command as needed)
CREATE_USER_CMD="cd /etc/semaphore && semaphore user add --admin --login $ADMIN_USER --email $ADMIN_USER@example.com --name $ADMIN_USER  --password $ADMIN_PASSWORD"

# Exec into the pod to create the user
kubectl exec -n $NAMESPACE deployment/$DEPLOYMENT_NAME -- bash -c "$CREATE_USER_CMD"

# Check the result of the command
if [ $? -ne 0 ]; then
  echo "Failed to create the admin user in pod '$DEPLOYMENT_NAME'."
  exit 1
fi

# Create the Kubernetes secret with the admin username and password
kubectl create secret generic $SECRET_NAME \
  --from-literal=username=$ADMIN_USER \
  --from-literal=password=$ADMIN_PASSWORD \
  --namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Admin user '$ADMIN_USER' created in pod '$DEPLOYMENT_NAME' with the generated password."

# Output the password
echo "Username: admin"
echo "Password: $ADMIN_PASSWORD"
