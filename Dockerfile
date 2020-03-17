
# Base alpine image with node and npm preinstalled
FROM node:10.19-alpine3.11

# Get packages
RUN apk update && \
    apk add --update curl jq bash ca-certificates git openssl \
    unzip wget build-base jpeg-dev zlib-dev libffi-dev \
    openssl-dev git openssh-client sshpass python3 python3-dev

RUN ln -s /usr/bin/python3 /usr/bin/python

# Install ansible
RUN pip3 install --upgrade pip
ENV LIBRARY_PATH=/lib:/usr/lib
WORKDIR /ansible
VOLUME [ "/ansible" ]
ARG ANSIBLE_VERSION=2.9
RUN pip install ansible==$ANSIBLE_VERSION
WORKDIR /home

RUN npm install -g gantree-cli@0.4.0-b3

#RUN mkdir /usr/local/lib/node_modules/gantree-cli/node_modules/gantree-lib/inventory/active
RUN chmod 777 /usr/local/lib/node_modules/gantree-cli/node_modules/gantree-lib/inventory/active

# Setup python requirements
COPY ./python_requirements.txt python_requirements.txt
RUN pip3 install -r ./python_requirements.txt

# Setup ansible role requirements
RUN ansible-galaxy install \
    -p /usr/share/ansible/roles \
    -r /usr/local/lib/node_modules/gantree-cli/node_modules/gantree-lib/ansible/requirements/requirements.yml

# Start ssh-agent
RUN eval $(ssh-agent)

# Setup entrypoint script
# See https://serverfault.com/a/940706 for why we can't chmod this in the dockerfile
COPY ./entrypoint.sh entrypoint.sh

# Run gantree-cli
ENTRYPOINT ["./entrypoint.sh"]