
# Base alpine image with node and npm preinstalled
FROM node:lts-alpine3.11

# Get packages
RUN apk update && \
    apk add --update curl jq bash ca-certificates git openssl \
    unzip wget build-base jpeg-dev zlib-dev libffi-dev \
    openssl-dev git openssh-client sshpass python3 python3-dev

# alias python3 as python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install ansible
RUN pip3 install --upgrade pip
ENV LIBRARY_PATH=/lib:/usr/lib
WORKDIR /ansible
VOLUME [ "/ansible" ]
ARG ANSIBLE_VERSION=2.9
RUN pip install ansible==$ANSIBLE_VERSION
WORKDIR /home

# Setup python requirements
COPY ./include/python_requirements.txt python_requirements.txt
RUN pip3 install -r ./python_requirements.txt

# Install gantree-cli
ARG GANTREE_CLI_VERSION=0.8.0
RUN npm install -g gantree-cli@$GANTREE_CLI_VERSION

# Setup ansible role requirements
COPY ./include/ansible_requirements.yml /ansible_requirements.yml
RUN ansible-galaxy install \
    -p /usr/share/ansible/roles \
    -r /ansible_requirements.yml

# Add ansible cfg
COPY ./include/ansible.cfg ansible.cfg
ENV ANSIBLE_CONFIG=ansible.cfg

# Set inventory path (where inventory data is stored)
ENV GANTREE_OVERRIDE_INVENTORY_PATH=/gantree/inventory

# Setup entrypoint script
# See https://serverfault.com/a/940706 for why we can't chmod this in the dockerfile
COPY ./include/entrypoint.sh entrypoint.sh

# Run gantree-cli
ENTRYPOINT ["./entrypoint.sh"]