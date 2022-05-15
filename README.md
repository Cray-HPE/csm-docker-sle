# CSM Docker: SLE

A SLE Server Docker image used for RPM builds.

## Building

The provided `Makefile` adds Jenkins Pipeline variables to the `docker build` command. The commands below are for use outside of the CSM Jenkins Pipeline.

```bash
export DOCKER_BUILDKIT=1
export SLES_REGISTRATION_CODE=<registration_code>
docker build --secret id=SLES_REGISTRATION_CODE .
```

## Running

```bash
# Latest
docker run -it artifactory.algol60.net/csm-docker/stable/csm-docker-sle:latest

# SLES Version
docker run -it artifactory.algol60.net/csm-docker/stable/csm-docker-sle:15.3

# Git Hash
docker run -it artifactory.algol60.net/csm-docker/stable/csm-docker-sle:<hash>
```


## SLES Version(s)

The version is controlled by the `Dockerfile`. Each image built and pushed to Artifactory is tagged with:
- `latest`
- A short Git hash
- The SLES Version from the `Dockerfile`

Update the `Dockerfile` with a new tag provided from https://registry.suse.com/.

