#!/bin/bash

USAGE=$(cat <<-END
    Container Usage:
    docker run -v {host-folder}:/gantree --rm -ti gantree-cli [arguments]"

    Where:
    {host-folder} = absolute path to host working folder

    Useful places to put files:
    {host-folder}/credentials/google_application_credentials.json

    {host-folder}/credentials/ssh_id_rsa_validator
    {host-folder}/credentials/ssh_id_rsa_validator.pub

    {host-folder}/config/main.config.json

END
)

GANTREE_ROOT="/gantree"
STATE_FOLDER="${GANTREE_ROOT}/state"
TF_PLUGIN_CACHE_FOLDER="${GANTREE_ROOT}/tf-plugin-cache"
CONFIG_FOLDER="${GANTREE_ROOT}/config"
CRED_FOLDER="${GANTREE_ROOT}/credentials"

GCP_CREDENTIAL_NAME="google_application_credentials.json"

VALIDATOR_PRIVATE_KEY_NAME="ssh_id_rsa_validator"

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
if [ ! -d "$STATE_FOLDER" ]; then
    echo -e "\nState directory not found, creating.."
    mkdir $STATE_FOLDER
fi

if [ ! -d "$TF_PLUGIN_CACHE_FOLDER" ]; then
    echo -e "\nTerraform plugin cache directory not found, creating.."
    mkdir $TF_PLUGIN_CACHE_FOLDER
fi
export TF_PLUGIN_CACHE_DIR=$TF_PLUGIN_CACHE_FOLDER

if [ ! -d "$CONFIG_FOLDER" ]; then
    echo -e "\nConfig directory not found, creating.."
    mkdir $CONFIG_FOLDER
fi

if [ ! -d "$CRED_FOLDER" ]; then
    echo -e "\nCredentials directory not found, creating.."
    mkdir $CRED_FOLDER
fi
chmod 0700 $CRED_FOLDER

# check credentials
echo "$CRED_FOLDER/$GCP_CREDENTIAL_NAME"
if [ -f "$CRED_FOLDER/$GCP_CREDENTIAL_NAME" ]; then
    export GOOGLE_APPLICATION_CREDENTIALS="$CRED_FOLDER/$GCP_CREDENTIAL_NAME"
fi

# check ssh keys
if [ ! -f "$CRED_FOLDER/$VALIDATOR_PRIVATE_KEY_NAME" ]; then
    ssh-keygen -t rsa -b 2048 -m PEM -f $CRED_FOLDER/$VALIDATOR_PRIVATE_KEY_NAME -q -N ""

    echo -e "\nNo validator ssh key found at: {host-folder}/credentials/$VALIDATOR_PRIVATE_KEY_NAME"
    echo -e "Generating.."
fi

# setup ssh
export SSH_ID_RSA_VALIDATOR="$CRED_FOLDER/$VALIDATOR_PRIVATE_KEY_NAME"
eval $(ssh-agent) &>/dev/null
ssh-add "$CRED_FOLDER/$VALIDATOR_PRIVATE_KEY_NAME" # &>/dev/null

echo -e "\n"

# run gantree-cli
gantree-cli "$@"
