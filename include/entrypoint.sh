#!/bin/bash

echo -e ""

USAGE=$(cat <<-END
    Container Usage:\n
    docker run -v {host-config-directory}:/gantree \\ \n
        --env-file {env-file} \\ \n
        -e HOST_USER=$(id -u) \\ \n
        --rm -ti \\ \n
        {docker-image-name} [cli arguments]\n
    \n
    Where:\n
    {host-folder} = absolute path to host working folder\n
    \n
    Useful places to put files:\n
    {host-folder}/gcp/google_application_credentials.json\n
    \n
    {host-folder}/ssh/ssh_id_rsa_validator\n
    \n
    {host-folder}/config/main.config.json\n

END
)

GANTREE_ROOT="/gantree"
CONFIG_FOLDER="${GANTREE_ROOT}/config"
GCP_FOLDER="${GANTREE_ROOT}/gcp"
SSH_FOLDER="${GANTREE_ROOT}/ssh"
INVENTORY_FOLDER="${GANTREE_ROOT}/inventory"
CONTROL_FOLDER="${GANTREE_ROOT}/control"

GCP_CREDENTIAL_NAME="google_application_credentials.json"

# check host folder mounted
if [ ! -d "/gantree" ]; then
    echo -e $USAGE
    exit 1
fi

chown $HOST_USER /gantree

# check sub folders
if [ ! -d "$CONFIG_FOLDER" ]; then
    echo -e "\nConfig directory not found, creating.."
    echo -e ""
    mkdir $CONFIG_FOLDER && chown $HOST_USER $CONFIG_FOLDER
fi

if [ ! -d "$GCP_FOLDER" ]; then
    echo -e "\nGCP directory not found, creating.."
    echo -e ""
    mkdir $GCP_FOLDER && chown $HOST_USER $GCP_FOLDER
fi

if [ ! -d "$SSH_FOLDER" ]; then
    echo -e "\nSSH directory not found, creating.."
    echo -e ""
    mkdir $SSH_FOLDER && chown $HOST_USER $SSH_FOLDER
fi
chmod 0700 $SSH_FOLDER

if [ ! -d "$INVENTORY_FOLDER" ]; then
    echo -e "\nInventory directory not found, creating.."
    echo -e ""
    mkdir $INVENTORY_FOLDER && chown $HOST_USER $INVENTORY_FOLDER
fi

if [ ! -d "$CONTROL_FOLDER" ]; then
    echo -e "\nControl directory not found, creating.."
    echo -e ""
    mkdir $CONTROL_FOLDER && chown $HOST_USER $CONTROL_FOLDER
fi

# check credentials
if [ ! -z "$GCP_SERVICE_ACCOUNT_FILE" ]; then
    if [ ! -f "$GCP_SERVICE_ACCOUNT_FILE" ]; then
        echo -e "Warning: GCP service account file specified at '$GCP_SERVICE_ACCOUNT_FILE' but file not found mapped on the container"
        echo -e "Remember the {host-folder} on your machine should be mapped to the /gantree folder on the docker container"
        echo -e "See README for more info"
        echo -e ""
    fi
fi

# warn ssh keys
if [ -z "$(ls -A $SSH_FOLDER)" ]; then
    echo -e "Warning: No private ssh keys found in $SSH_FOLDER"
    echo -e "These are needed to connect nodes for provisioning"
    echo -e "See README for more info"
    echo -e ""
fi

# check config
if [ -z "$GANTREE_CONFIG_PATH" ]; then
    echo -e "Error: required environment variable GANTREE_CONFIG_PATH not set"
    echo -e ""
    exit 1
fi

if [ ! -f "$GANTREE_CONFIG_PATH" ]; then
    echo -e "Error: config file GANTREE_CONFIG_PATH=$GANTREE_CONFIG_PATH does not exist on the container"
    echo -e "Remember the {host-folder} on your machine should be mapped to the /gantree folder on the docker container"
    echo -e "See README for more info"
    echo -e ""
    exit 1
fi

gantree-cli "$@"

chown -R $HOST_USER /gantree