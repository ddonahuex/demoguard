# Demoguard
Demoguard provides example source code demonstrating the value of
Chainguard zero (or near-zero) CVE images.

It builds a single Go module containing a hello world program. The program
is run in an infinite loop in a Docker container printing "Hello world" and
then sleeping for 10 seconds.

This project is written in Go (version 1.24).

## License
This project is licensed under the MIT License. See the LICENSE file for details.

Copyright © 2025. All rights reserved.

# Building the Project
The demoguard project is built from the demoguard directory.

This directory includes a Makefile that supports building a Go executable and
creating and pushing a Docker image. The Makefile provides targets for building,
running, and pushing the Docker image to ddonahuex's namespace on Docker Hub.

In addition to building the Docker image, the build process generates an SBOM
and Vulnerability Report using syft and grype respectively.

For a complete list of build targets and their usage, refer to the Make Targets
section below.

There are two build options for demoguard: *standard* and *chainguard*. These build
types are detailed in following sub-sections.

## make
The table below lists and describes the build targets and variables.

To list build targets:
> $ make help

To build a target:
> $ make \<target\>

### Build Targets
| Target | Description |
| --------- | ------- |
| build | Executes a Go build for the demoguard executable |
| clean | Executes a Go clean for all modules |
| docker-build | Docker build, SBOM generation, & Vulnerability report for ddonahuex/demoguard Docker image |
| docker-prod | Executes docker-build and docker-push make targets |
| docker-push | Docker push for of ddonahuex/demoguard to the ddonahuex Docker Hub namespace |
| help | Print this help menu |

### Build types - Standard and Chainguard
The demoguard docker image can either be built using a standard Dockerfile or 
Chainguard Dockerfile. The make variable that controls the build type is **TYPE**.

Valid values for *TYPE* are *standard* and *chainguard*. When not specified the
build defaults to standard, so no need to TYPE for that build.

The standard image uses **Dockerfile-standard** for the build. It 
intentionally includes Golang version 1.20.5 because that version contains
multiple CVEs, which is evident in grype's output during the build.

The Docker image produced for the standard build TYPE is: 
**ddonahuex/demoguard:standard**

The Chainguard image uses **Dockerfile-chainguard** for the build. It uses a 
zero CVE Chainguard Go image, which is also evident by grype's output during
the build.

The Docker image produced for the chainguard build TYPE is: 
**ddonahuex/demoguard:chainguard**

The two build types are for demo purposes.

#### Chainguard Demo
The straightforward demo contains 2 steps:
1. Standard build, see multiple CVEs
2. Chainguard build, see 0 CVEs

Execute the followming commands to run a Chainguard demo.
Standard build: See multiple CVEs
> $ make clean && make docker-build

Chainguard: See 0 CVEs
> $ make clean && make TYPE=chainguard docker-build

# Run
Demoguard can be deployed on bare metal, in a Docker container, or within a
Kubernetes cluster. Detailed instructions for each deployment method are
provided in the subsections below.

# Software Bill of Materials (SBOM) & Vulnerability Report
The file demoguard-<build type>-bom.json is a CycloneDX-formatted SBOM generated using Syft 
for the demoguard project.

The file demoguard:<build type>-vuln-report.json is a vulnerability report generated
using grype.


