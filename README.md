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
- `{host-dir}/gcp/my_google_application_credentials.json`
- `{host-dir}/ssh/my_ssh_id_rsa_validator_key`

Private ssh keys mounted to /gantree/ssh/* will be automatically detected and made available to gantree-cli

Because of the current architecture (using ssh-agent) there is likely a practical limit of around 4 ssh keys in use before
instance connections will start to be rejected for too many failed attempts, this is something we are working to improve.

For more information about these files see the [gantree-cli](https://github.com/flex-dapps/gantree-cli) documentation.

### Environment Variables ###

Some credentials can be passed directly to the docker container as environment variables.

These include:

- GANTREE_CONFIG_PATH
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- DO_API_TOKEN
- GCP_AUTH_KIND
- GCP_SERVICE_ACCOUNT_FILE

To pass environment variables when running the container:

``` bash
docker run -e DO_API_TOKEN=XXXXXXXXX gantree-cli-docker
```

or

``` bash
docker run --env-file myenvfile gantree-cli-docker
```

where myenvfile contains

``` bash
DO_API_TOKEN=XXXXXXXXX
```

Note: Environment variables that contain paths should point to the file location mounted inside the container

For example, if a config file is located on the host at

`/home/myuser/Work/my_gantree_workspace/config/myconfig.json`

the container could be run with

``` bash
docker run \
    -v /home/myuser/Work/my_gantree_workspace:/gantree \
    -e GANTREE_CONFIG_PATH=/gantree/config/myconfig.json \
    --user $(id -u):$(id -g) \
    --rm -ti
    gantree-cli-docker
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
docker run -v {host-directory}:/gantree \
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
           gantree-cli-docker sync
```
