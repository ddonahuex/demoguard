# tcguard - Technical Challenge for Chainguard
My take on the *Chainguard Solutions Engineer Technical Challenge*

## Executive Summary
This technical challenge was both challenging and fun. Part 1 of the challenge straightforward and inline with my experience. In Part 2 I was able to build a production grade Wolfi package, but I stalled at the apko build. The lesson for me is I need to spend time in Chainguard Academy in order to better understand the process. This is something I am willing to do.

That said, learning new things like melange Dockerfile-less builds was enjoyable! I look forward to learning more about melange and apko builds.

# Project Contents

| Name | Description |
| :--------- | :------- | 
| deploy | Directory containing Kubernetes manifests for all TC images |
| hello-melange-apko | Forked version of a Chainguard demo repository |
| sbom | Directory containing build generated SBOMS for all TC images/artifacts |
| scan | Directory containing build generated Grype scan results for all TC images |
| cosign.pub | My public key used to sign all TC images |
| Docker.single | Single-stage Dockerfile for building hello-melange-apko |
| Docker.multi | Multi-stage Dockerfile for building hello-melange-apko |
| Docker.wolfi | Dockerfile for Wolfi-based hello-melange-apko |
| Makefile | Top-level GNU makefile for all TC builds |
| RESULTS.md | TC Results log |
| sbom | SBOMS for all TC images/artifacts |
| scan | Grype scan results for all TC images |

# Environment Setup
| Component | Description | Notes |
| :--------- | :------- | :------- |
| Container Engine | Docker 28.0.1 | [Install Instructions](https://docs.docker.com/engine/install/) |
| Kubernetes Cluster | Minikube v1.35.0 | [Install Instructions](https://minikube.sigs.k8s.io/docs/start)  |
| Linux OS | Ubuntu 20.04.6 LTS | [Install Instructions](https://ubuntu.com/tutorials/install-ubuntu-desktop) |
| Local Registry | registry:2 on localhost:5000 | docker run -d -p 5000:5000 --restart=always --name local-registry registry:2 |
| Build tools | make 4.2.1 | [GNU Documentation](https://www.gnu.org/s/make/manual/make.html) |
| CVE Scanner | Grype 0.104.1 | [Chainguard Academy Tutorial](https://edu.chainguard.dev/chainguard/chainguard-images/staying-secure/working-with-scanners/grype-tutorial/) |
| SBOM Generator | Syft 1.38.0 | [GitHub README](https://github.com/anchore/syft/blob/main/README.md) |
| Grok | AI Paired Programming | grok.com |

## Reasoning
I chose the components for this environment due to my familiarity with them and because I have three instances running in my home lab. I have used this environment for several years to develop and deploy containerized workloads in software development and customer demo scenarios.

Docker is the industry standard for running containerized workloads.

Minikube is a great choice for dev and demo environments because it runs a real, single-node Kubernetes cluster locally using Docker. [Minikube addons](https://minikube.sigs.k8s.io/docs/handbook/addons/)  delivery prod quality K8s features like ingress controller, metrics server, container registry, etc.

Ubuntu 20.04 and GNU Make are old and familiar "friends" for software development. They enable me to rapidly spin up and configure a development environment that works for me.

I learned about *grype* and *syft* when researching Chainguard and have include them based on their value and ease of use in a CI/CD pipeline.

I use Grok as a pair programmer on technical projects—treating its output as high-quality prototypes that I then refine, test, and reshape to match my own coding style and standards. This collaboration dramatically accelerates my workflow, letting me explore more approaches, catch blind spots early, and deliver polished, production-grade solutions faster than working solo (as in years past).

# Building & Deploying Technical Challenge (TC) Artifacts
All TC build targets are built from a single toplevel Makefile.

The Go version of the Chainguard [hello-melange-apko](https://github.com/chainguard-dev/hello-melange-apko) application used in all the build targets.

For a complete list of build targets and their usage, refer to the Make Targets section below.

## make
The table below lists and describes the build targets and variables.

To list build targets:
> $ make help

To build a target:
> $ make \<target\>

### Build Targets
See referenced Dockerfiles for build details
| Target | Description | TC Notes |
| :--------- | :------- | :------- |
| single-stage | Executes a Go build using Dockerfile.single | Single stage build of hello-melange-apko |
| multi-stage | Executes a Go build using Dockerfile.multi  | Multi-stage build of hello-melange-apko |
| wolfi | Executes a Go build using Dockerfile.wolfi  | Wolfi-based build of hello-melange-apko |
| melange | Builds a real production grade Wolfi package |
| help | Print this help menu |

## Deployment

### minikube
Minikube in this challenge is started using the **--driver=docker**, which means minikube will create a Docker container that hosts and acts as a single-node K8s cluster. This presented a couple of issues that must be addressed if we are to deploy and verify the docker images created in this project.

There are two noteworthy issues that need to be addressed to deploy in minikube using the local registry and accessing endpoints. They are both detailed below.

#### Registry Addon Workaround
As of this writing the *registry* addon in minikube is not working. Normally I would store images in Dockerhub, to which this would not be relevant, but the tech challenge calls for using a local registry.

The workaround to use a local registry is to load the image into minikube's containter runtime with the following command.

Multi-stage example:
```
$ minikube image load localhost:5000/hello-melange-apko:multi-stage-latest
```

#### Accessing Service Endpoints
The NodePorts services used to access endpoints inside minikube are, by default, not accessible via *localhost* on the host machine because they are running inside a Docker container. The container localhost and host machine localhost are not the same. 

To access a service running in minikube, you need to take an additional step in order to curl to the hello-melange-apko endpoint. There are two options: **minikube service** command or **kubectl port-forward**.

##### minikube service (Recommended)
```
ddonahue@kube-ai$ minikube service multistage-svc -n chainguard-demo --url
http://192.168.49.2:30080

ddonahue@kube-ai$ curl http://192.168.49.2:30080
Hello World!
```
##### port-forward
The following command must be executed in a seperate terminal and left running.
```
kubectl port-forward svc/multistage-svc -n chainguard-demo 8080:8080
```
Back in original terminal:
```
curl http://localhost:8080
Hello World!
```
# Part 1: Container Security Fundamentals

# Part 2: Advanced Builds with Wolfi
