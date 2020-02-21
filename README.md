# Gantree-Cli-Docker #

This docker container is designed to simplify the setup and usage of gantree-cli

For more information about the items and concepts referenced in this document
please see the README for [gantree-cli](https://github.com/flex-dapps/gantree-cli).

For information on setting up docker see [docs.docker.com/install](https://docs.docker.com/install)

## Setup ##

### Files ###

Various configuration files need to be passed to the docker container on running, this is accomplised by mounting a host directory to the `/gantree` directory in the container. The mounted directory should contain a structure that will be recognized by the container and is described below.

To mount a directory when running the container:

``` bash
docker run -v /home/myuser/work/gantree-working:/gantree gantree-cli-docker
```

Files you may wish to add to this directory:

- `{host-dir}/config/{your-gantree-configuration-file}.json`
- `{host-dir}/credentials/google_application_credentials.json`
- `{host-dir}/credentials/ssh_id_rsa_validator`

For more information about these files see the [gantree-cli](https://github.com/flex-dapps/gantree-cli) documentation.

The container may add other files and directories to the mounted directory to persist state between invocations.

### Environment Variables ###

Some credentials can be passed directly to the docker container as environment variables.

These include:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- DIGITALOCEAN_TOKEN

The gropius-cli environment variables `ID_RSA_SSH_VALIDATOR` and `GOOGLE_APPLICATION_CREDENTIALS` should not be passed through to docker. Instead if the files are mounted (as shown above), the respective environment variables will be automatically populated.

To pass environment variables when running the container:

``` bash
docker run -e DIGITALOCEAN_TOKEN=XXXXXXXXX gantree-cli-docker
```

or

``` bash
docker run --env-file myenvfile gantree-cli-docker
```

where myenvfile contains

``` bash
DIGITALOCEAN_TOKEN=XXXXXXXXX
```

## Usage ##

### Build the container ###

``` bash
docker build -t {docker-image-name} .
```

eg.

``` bash
docker build -t gantree-cli-docker .
```

### Run gantree-cli-docker ###

``` bash
docker run -v {host-config-directory}:/gantree \
           --env-file {env-file} \
           --user $(id -u):$(id -g) \
           --rm -ti \
           {docker-image-name} [cli arguments]
```

eg.

``` bash
docker run -v /home/myuser/work/gantree_work:/gantree \
           --env-file /home/myuser/work/gantree_env/envfile \
           --user $(id -u):$(id -g) \
           --rm -ti \
           gantree-cli-docker sync --config /gantree/config/main.conf
```
