# Jenkins in Kubernetes

This repository has a `Dockerfile` and a `helm` chart for setting up a simple Jenkins master for running in Kubernetes.

This Jenkins has the required tools to work in and with Kubernetes
- Jenkins application with pre-loaded plugins (see [plugins.txt](plugins.txt))
- Skipped setup wizard
- You can add and remove plugins by editing the [plugins.txt](plugins.txt) file
- Docker for managing a Docker CI lifecycle
- `kubectl` command line client for working with the Kubernetes API


## Build jenkins docker image
```
$ export DOCKER_REG=SET_YOUR_DOCKER_REGISTRY_HERE

$ Login
$ docker login --username=<username> ${DOCKER_REG}

# Build the image
$ docker build -t jenkins:lts-k8s .

# Push the image
$ docker tag jenkins:lts-k8s ${DOCKER_REG}/jenkins:lts-k8s
$ docker push ${DOCKER_REG}/jenkins:lts-k8s

```

## Test image

```
# Local
$ docker run -d --name jenkins -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock jenkins:lts-k8s


# Remote
$ docker run -d --name jenkins -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock ${DOCKER_REG}/jenkins:lts-k8s
```

Browse to http://localhost:8080 on your local browser

## Deploy Jenkins helm chart to Kubernetes

If you are using the pre-built image, you can install the helm chart with

```
$ helm init

# Deploy the Jenkins helm chart
# (same command for install and upgrade)
$ helm upgrade --install jenkins ./charts/jenkins

```

If you are building your own version of Jenkins, you need your Kubernetes cluster to be able to pull the Docker image. You have to create a Docker registry secret and reference to it in your helm install command.

```
# Create a Docker registry secret
$ export DOCKER_REG=SET_YOUR_DOCKER_REGISTRY_HERE
$ export DOCKER_USR=SET_YOUR_DOCKER_USERNAME_HERE
$ export DOCKER_PWD=SET_YOUR_DOCKER_PASSWORD_HERE
$ export DOCKER_EML=SET_YOUR_DOCKER_EMAIL_HERE

$ kubectl create secret docker-registry docker-reg-secret \
        --docker-server=${DOCKER_REG} \
        --docker-username=${DOCKER_USR} \
        --docker-password=${DOCKER_PWD} \
        --docker-email=${DOCKER_EML}


# Deploy the Jenkins helm chart
# (same command for install and upgrade)
$ helm upgrade --install jenkins \
        --set imagePullSecrets=docker-reg-secret \
        --set image.repository=${DOCKER_REG}/jenkins \
        --set image.tag='lts-k8s' \
        ./charts/jenkins
```

## Data persistence
By default, in Kubernetes, the Jenkins deployment uses a persistent volume claim that is mounted to /var/jenkins_home. This assures your data is saved across crashes, restarts and upgrades.