[![CircleCI](https://circleci.com/gh/eclipse/che-plugin-broker.svg?style=svg)](https://circleci.com/gh/eclipse/che-plugin-broker)

# This repo contains implementations of several Che plugin brokers

## che-plugin-broker

Downloads tar.gz archive and:

- Evaluates Che workspace sidecars config from che-plugin.yaml located in a plugin archive and data from config.json that is placed in workdir or different path if a corresponding broker argument is used. It contains data about Che plugin or editor from meta.yaml
- Copies dependency file/folder specified in dependencies.yaml inside of a plugin archive

## theia-plugin-broker

Downloads .theia archive and:

- Unzip it to a temp folder
- Check content of package.json file in it. If it contains {"engines.cheRuntimeContainer"} then this value is taken as container image for sidecar of a remote plugin. If it is missing or empty plugin is considered non-remote
- Copies .theia file to /plugins/ for a non-remote plugin case
- Copies unzipped .theia to /plugins/ for a remote plugin case
- Evaluates Che workspace sidecar config for running Theia plugin as Che remote plugin in a sidecar:
  - adds an endpoint with random port between 4000 and 10000 and name `port<port>`
  - adds env var to workspace-wide env vars with name `THEIA_PLUGIN_REMOTE_ENDPOINT_<plugin_publisher_and_name from package.json>` and value
 `ws://port<port>:<port>`
  - adds env var to sidecar env vars with name
 `THEIA_PLUGIN_ENDPOINT_PORT` and value `port`
  - adds projects volume
  - adds plugin volume
- Sends sidecar config to Che workspace master

## init-plugin-broker

Cleanups content of /plugins/ folder.
Should be started before other brokers not to remove files they are adding to plugins folder.

## vscode-extension-broker

Downloads VS Code extension from marketplace and:

- Unzip it to a temp folder
- Check content of package.json file in it.
- Copies unzipped extension to /plugins/
- Evaluates Che workspace sidecar config for running VS Code extension as Che Theia remote plugin in a sidecar:
  - adds an endpoint with random port between 4000 and 10000 and name `port<port>`
  - adds env var to workspace-wide env vars with name
 `THEIA_PLUGIN_REMOTE_ENDPOINT_<plugin_publisher_and_name from package.json>` and value
 `ws://port<port>:<port>`
  - adds env var to sidecar env vars with name
 `THEIA_PLUGIN_ENDPOINT_PORT` and value `port`
  - with projects volume
  - with plugin volume
- Sends sidecar config to Che workspace master

## Development

Mocks are generated from interfaces using library [mockery](https://github.com/vektra/mockery)
To add new mock implementation for an interface or regenerate to an existing one use following
command when current dir is location of the folder containing the interface:

```shell
mockery -name=NameOfAnInterfaceToMock
```

### Build

- build all the code:

```shell
CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-w -s' -a -installsuffix cgo ./...
```

- build Che plugin broker binary:

```shell
CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-w -s' -a -installsuffix cgo -o che-plugin-broker brokers/che-plugin-broker/cmd/main.go
```

- build Che Theia plugin broker binary:

```shell
CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-w -s' -a -installsuffix cgo -o theia-plugin-broker brokers/theia/cmd/main.go
```

- build Init plugin broker binary:

```shell
CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-w -s' -a -installsuffix cgo -o init-plugin-broker brokers/init/cmd/main.go
```

- build VS Code extension broker binary:

```shell
CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-w -s' -a -installsuffix cgo -o vscode-extension-broker brokers/vscode/cmd/main.go
```

### Run checks

- run tests:

```shell
go test -v -race ./...
```

- run linters:

```shell
golangci-lint run -v
```

- run CI checks locally in Docker (includes build/test/linters):

```shell
docker build -f build/CI/Dockerfile .
```

### Check brokers locally

Prerequisites:

    - Folder /plugins exists on the host and writable for the user

- Go to a broker cmd directory, e.g. `brokers/vscode/cmd`
- Compile binaries `go build main.go`
- Run binary `./main -disable-push -runtime-id wsId:env:ownerId`
- Check JSON with sidecar configuration in the very bottom of the output
- Check that needed files are in `/plugins`
- To cleanup `/plugins` folder **init** broker can be used

### Dependencies

Dependencies in the project are managed by Go Dep.
After you added a dependency you need to run the following command to download dependencies to vendor repo and lock file and then commit changes:

```shell
dep ensure
```

`dep ensure` doesn't automatically change Gopkg.toml which contains dependencies constrants.
So, when a dependency is introduced or changed it should be reflected in Gopkg.toml.

### Build of Docker images

- build Che plugin broker

```shell
docker build -t eclipse/che-plugin-broker:latest -f build/che-plugin-broker/Dockerfile .
```

- build Theia plugin broker

```shell
docker build -t eclipse/che-theia-plugin-broker:latest -f build/theia/Dockerfile .
```

- build Init plugin broker

```shell
docker build -t eclipse/che-init-plugin-broker:latest -f build/init/Dockerfile .
```

- build VS Code extension broker

```shell
docker build -t eclipse/che-vscode-extension-broker:latest -f build/vscode/Dockerfile .
```
