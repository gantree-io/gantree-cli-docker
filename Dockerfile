
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
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install gantree-cli
RUN npm install -g @flexdapps/gantree-cli

# Setup ansible role requirements
RUN ansible-galaxy install -r /usr/local/lib/node_modules/@flexdapps/gantree-cli/ansible/requirements/requirements.yml

# Setup entrypoint script
# See https://serverfault.com/a/940706 for why we can't chmod this in the dockerfile
COPY ./entrypoint.sh entrypoint.sh

# Run gantree-cli
ENTRYPOINT ["./entrypoint.sh"]
#ENTRYPOINT ["./e"]