# README #

## Build the container
```
docker build -t {container-name} .
```

## Run gantree-cli-docker
```
docker run -v {host-config-directory}:/gantree --rm -ti {container-name} [cli arguments]
```