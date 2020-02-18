# Gantree-Cli-Docker #

This docker container is designed to simplify the setup and usage of gantree-cli

For more information about the items and concepts contained in this document
please see the README for gantree-cli.

TODO(ryan): LINK

## Setup

### Files
Various files need to be passed to the docker container on running, this is accomplised by mounting a host directory to the `/gantree` folder in the container. This folder should use a structure that will be recognized by the container.

For example (when running the container):
```
docker run -v /home/myuser/work/gantree-working:/gantree gantree-cli-docker
```

Files you may wish to add to this folder:
- `./config/{your-gantree-configuration-file}.json`
- `./credentials/google_application_credentials.json`
- `./credentials/ssh_id_rsa_validator` and `./credentials/ssh_id_rsa_validator.pub`

### Environment Variables
Some credentials can be passed directly to the docker container as environment variables

These include:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- DIGITALOCEAN_TOKEN

For example (when running the container):
```
docker run -e DIGITALOCEAN_TOKEN=XXXXXXXXX gantree-cli-docker
```
or
```
docker run --env-file myenvfile gantree-cli-docker
```
where myenvfile contains
```
DIGITALOCEAN_TOKEN=XXXXXXXXX
```

## Usage

### Build the container
```
docker build -t {container-name} .
```

eg.
```
docker build -t gantree-cli-docker .
```

### Run gantree-cli-docker
```
docker run -v {host-config-directory}:/gantree \
           --env-file {env-file} \
           --user $(id -u):$(id -g) \
           --rm -ti \
           {container-name} [cli arguments]
```

eg.
```
docker run -v /home/myuser/work/gantree_work:/gantree \
           --env-file /home/myuser/work/gantree_env/envfile \
           --user $(id -u):$(id -g) \
           --rm -ti \
           gantree-cli-docker sync --config /gantree/config/main.conf
```


