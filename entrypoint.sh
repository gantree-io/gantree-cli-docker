#!/bin/bash

echo -e ""

USAGE=$(cat <<-END
    Container Usage:\n
    docker run -v {host-config-directory}:/gantree \\ \n
        --env-file {env-file} \\ \n
        --user \$(id -u):\$(id -g) \\ \n
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

GCP_CREDENTIAL_NAME="google_application_credentials.json"

# check host folder mounted
if [ ! -d "/gantree" ]; then
    echo -e $USAGE
    exit 1
fi

# check host folder permissions
GANTREE_ROOT_OWNER=$(stat -c '%u' /gantree)
if [ $GANTREE_ROOT_OWNER -ne $(id -u) ]; then
    echo -e "\nPlease ensure docker user has ownership of mounted {host-folder} on host system"

    echo -e "\n{host-folder} owner: $GANTREE_ROOT_OWNER"
    echo -e "Docker user: $(id -u)"

    echo -e "\nYou can do this with:\nsudo chown $(id -u):$(id -g) {host-folder} on the host machine"
    echo -e "\nWhere {host-folder} is the absolute path to the host-folder you're mounting"
    exit 1
fi

# check sub folders
if [ ! -d "$CONFIG_FOLDER" ]; then
    echo -e "\nConfig directory not found, creating.."
    echo -e ""
    mkdir $CONFIG_FOLDER
fi

if [ ! -d "$GCP_FOLDER" ]; then
    echo -e "\nGCP directory not found, creating.."
    echo -e ""
    mkdir $GCP_FOLDER
fi

if [ ! -d "$SSH_FOLDER" ]; then
    echo -e "\nSSH directory not found, creating.."
    echo -e ""
    mkdir $SSH_FOLDER
fi
chmod 0700 $SSH_FOLDER

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

# setup ssh
eval $(ssh-agent) &>/dev/null
for private_key_file in $SSH_FOLDER/*; do
    ssh-add "$private_key_file"
done

echo -e "\n"

# run gantree-cli
gantree-cli "$@"
