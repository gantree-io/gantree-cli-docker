
# Base alpine image with node and npm preinstalled
FROM node:10.19-alpine3.11

# Get packages
RUN apk update && \
    apk add --update curl jq python bash ca-certificates git openssl \
    unzip wget build-base python-dev py-pip jpeg-dev zlib-dev libffi-dev \
    openssl-dev git openssh-client sshpass

# Install ansible
RUN pip install --upgrade pip
ENV LIBRARY_PATH=/lib:/usr/lib
WORKDIR /ansible
VOLUME [ "/ansible" ]
ARG ANSIBLE_VERSION=2.9
RUN pip install ansible==$ANSIBLE_VERSION
WORKDIR /home

# Install terraform
ARG TERRAFORM_VERSION=0.12.20
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin
ENV TERRAFORM_STATEFILE_PATH=/gantree/state

# install from tgz for the moment
ARG GANTREE_CLI_PKG=flexdapps-gantree-cli-0.1.0-rc3.tgz
COPY ./pkg/$GANTREE_CLI_PKG $GANTREE_CLI_PKG
RUN npm install -g $GANTREE_CLI_PKG

# TODO(ryan): Switch back to this when we have the cli on public npm
# RUN npm install -g @flexdapps/gantree-cli

# Setup ansible role requirements
RUN ansible-galaxy install \
    -p /usr/share/ansible/roles \
    -r /usr/local/lib/node_modules/@flexdapps/gantree-cli/ansible/requirements/requirements.yml

# Start ssh-agent
RUN eval $(ssh-agent)

# Setup entrypoint script
# See https://serverfault.com/a/940706 for why we can't chmod this in the dockerfile
COPY ./entrypoint.sh entrypoint.sh

# Run gantree-cli
ENTRYPOINT ["./entrypoint.sh"]
#ENTRYPOINT ["ls"]