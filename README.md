# README #

## Notes

### Files
Various files need to be passed to the docker container on run, this is accomplised by mounting a host directory containing these files to the `/gantree` folder in the container. This folder should use a structure that will be recognized by the container.

For example:
`-v /home/myuser/work/gantree-working:/gantree`

Folder may contain:
- `./credentials/google_application_credentials.json`
- `./credentials/ssh_id_rsa_validator` and `./credentials/ssh_id_rsa_validator.pub`
- `./config/main.conf`

### Environment Variables
TODO

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
docker run -v {host-config-directory}:/gantree --user $(id -u):$(id -g) --rm -ti {container-name} [cli arguments]
```

eg.
```
docker run -v /home/myuser/work/gantree_work:/gantree --user $(id -u):$(id -g) --rm -ti gantree-cli-docker sync --config /gantree/config/main.conf
```


