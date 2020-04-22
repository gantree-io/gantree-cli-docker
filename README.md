# Gantree-Cli-Docker #

This docker container is designed to simplify the setup and usage of gantree-cli

For deeper understanding of the items and concepts referenced in this document
please see the READMEs for [gantree-cli](https://github.com/flex-dapps/gantree-cli#gantree-cli)
and [gantree-lib](https://github.com/flex-dapps/gantree-lib-nodejs#gantree-library).

For information on setting up docker see [docs.docker.com/install](https://docs.docker.com/install)

## Setup ##

### Files ###

Various configuration files need to be passed to the docker container on running,
this is accomplised by mounting a host directory as the `/gantree` directory in the container.
The mounted directory should contain a structure that will be recognized by the container and is described below.

To mount a directory when running the container:

``` bash
docker run -v /home/myuser/work/gantree-working:/gantree gantree-cli-docker
```

Files you may wish to add to this directory:

- `{host-dir}/config/{your-gantree-configuration-file}.json`
- `{host-dir}/gcp/{your-google-application-credentials}.json`
- `{host-dir}/ssh/{your-ssh-private-key}`

Private keys should be RSA type, contain embedded PEM information, and not use a password  
Some versions of ssh-keygen will generate this key by default, for others versions you can force this behaviour:

`ssh-keygen -f ./ssh_id_rsa_validator -t rsa -m PEM -q -N ""`

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

`/home/myuser/my_gantree_workspace/config/myconfig.json`

the container could be run with

``` bash
docker run \
    -v /home/myuser/my_gantree_workspace:/gantree \
    -e GANTREE_CONFIG_PATH=/gantree/config/myconfig.json \
    -e HOST_USER=$(id -u) \
    --rm -ti
    gantree-cli-docker
```

Gantree config files support user defined environment variable lookup of the form

``` json
{
    "some_key": "$env:USER_DEFINED_ENV_VAR"
}
```

These can also be passed through using the above methods

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
           -e HOST_USER=$(id -u) \
           --rm -ti \
           {docker-image-name} [cli arguments]
```

eg.

``` bash
docker run -v /home/myuser/work/gantree_work:/gantree \
           --env-file /home/myuser/work/gantree_env/envfile \
           -e HOST_USER=$(id -u) \
           --rm -ti \
           gantree-cli-docker sync
```
