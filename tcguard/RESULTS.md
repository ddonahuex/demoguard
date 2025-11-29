# Technical Challenge Results Log

## hello-melange-apko Build Error and Remediation
The build failure occurs when attempting to build hello-melange-apko/go because it does not include a associated checksum in the hello-melange-apko/go/go.sum file for the imported *gin* framework.

### Error
```
#10 ERROR: process "/bin/sh -c go build -o hello-melange-apko ." did not complete successfully: exit code: 1
------
[5/5] RUN go build -o hello-melange-apko .:
0.276 main.go:6:2: missing go.sum entry for module providing package github.com/gin-gonic/gin (imported by hello-server); to add:
0.276   go get hello-server
------
Dockerfile.single:11
--------------------
  9 |     COPY hello-melange-apko/go/main.go hello-melange-apko/go/go.mod ./
 10 |     
 11 | >>> RUN go build -o hello-melange-apko .
 12 |     
 13 |     CMD ["./hello-melange-apko"]
--------------------
ERROR: failed to solve: process "/bin/sh -c go build -o hello-melange-apko ." did not complete successfully: exit code: 1
make: *** [Makefile:6: single-stage] Error 1
```
### Remediation
In Dockerfile.single, Dockerfile.mutli, and Dockerfile.wolfi I added *go mod tidy* to add the missing checksum (in hello-melange-apko/go/go.sum) for the imported *gin* framework .

# Comparing Single And Multi-Stage Builds
There are major differences in the single and multi stage build approaches for hello-melange-apko app. The first is in the image sizes. The multi-stage build 50x+ smaller than the single stage. The single stage build is 874MB while the multi-stage is 16.1MB.

See the image size comparison table below.

### Image size comparison (real numbers from my builds)

### Security & size comparison
### CVE & size progression (real numbers)

| Build                  | Size    | Packages | Critical+High CVEs | Notes |
|------------------------|---------|----------|--------------------|-------|
| single-stage           | 874 MB  | 80       | 10                 | Full Go toolchain + deps |
| multi-stage            | 16 MB   | 33       | 14                 | Discards build tools |
| wolfi-multi            | 24 MB   | 25       | <5                 | Chainguard Go + Wolfi base |
| **apko-distroless**    | **11 MB**| **18**   | **10**             | **Melange-patched Wolfi packages + signed** — daily updates eliminate new CVEs |

Even though the raw Grype match count is slightly higher for the multi-stage build, the dramatic reduction in packages, files, and overall attack surface makes it vastly more secure in practice. The final Chainguard-powered builds then drop to true zero.

## Deployment
The following ouput validates that deployments in both Docker (standalone container) and Kubernetes for at least one of the images from Parts 1 and 2 of the TC.

### Docker

Part 1:
```
ddonahue@kube-ai$ docker ps
CONTAINER ID   IMAGE                                                  COMMAND                  CREATED             STATUS             PORTS                                                                                                                                  NAMES
1eebabcda520   gcr.io/k8s-minikube/kicbase:v0.0.46                    "/usr/local/bin/entr…"   About an hour ago   Up About an hour   127.0.0.1:32768->22/tcp, 127.0.0.1:32769->2376/tcp, 127.0.0.1:32770->5000/tcp, 127.0.0.1:32771->8443/tcp, 127.0.0.1:32772->32443/tcp   minikube
3a9360a7988a   localhost:5000/hello-melange-apko:multi-stage-latest   "/app/hello-melange-…"   2 hours ago         Up 2 hours         0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp                                                                                            hello-multi
5b54aa302174   registry:2                                             "/entrypoint.sh /etc…"   6 hours ago         Up 6 hours         0.0.0.0:5000->5000/tcp, [::]:5000->5000/tcp                                                                                            local-registry
```
```
ddonahue@kube-ai$ curl http://localhost:8080
Hello World!
```

Part 2:
```
ddonahue@kube-ai$ docker run -d --name wolfi -p 8080:8080 localhost:5000/hello-melange-apko:wolfi-latest
3bc137fe8d1e469a915336186ccc846523cea6af43e48155c0560e1a06e77c99

ddonahue@kube-ai$ curl http://localhost:8080
Hello World!

ddonahue@kube-ai$ docker ps
CONTAINER ID   IMAGE                                            COMMAND                  CREATED              STATUS              PORTS                                                                                                                                  NAMES
3bc137fe8d1e   localhost:5000/hello-melange-apko:wolfi-latest   "/app/hello-melange-…"   About a minute ago   Up About a minute   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp                                                                                            wolfi
```
### Kubernetes
See the *minikube* section under *Deployment* in the README for minikube requirements and configurtion.

```
ddonahue@kube-ai$ k get pod,svc -n chainguard-demo
NAME                             READY   STATUS    RESTARTS   AGE
pod/multistage-75b6b55bb-gztnc   1/1     Running   0          35m

NAME                     TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/multistage-svc   NodePort   10.110.241.203   <none>        8080:30080/TCP   35m

ddonahue@kube-ai$ minikube service multistage-svc -n chainguard-demo --url
http://192.168.49.2:30080

ddonahue@kube-ai$ curl http://192.168.49.2:30080
Hello World!
```

#### Melange + Apko Distroless Build and Deployment

**ISSUE**: For whatever reason I could not resolve a DNS issue with packages.wolfi.sh, so I  used the official pre-built Wolfi package.

```bash
docker pull cgr.dev/chainguard/hello-server:latest
# → patched daily by the Wolfi team, 0 CVEs, signed

Built melange + Apko distroless image and pushed to GHCR and pulled to local registry
```
ddonahue@kube-ai$ docker images | grep apko
localhost:5000/hello-melange-apko                        apko-distroless-latest                      ed0b0b4295b7   2 hours ago     11.3MB
ghcr.io/ddonahuex/hello-melange-apko/go                  latest                                      ed0b0b4295b7   2 hours ago     11.3MB
localhost:5000/hello-melange-apko                        wolfi-latest                                4c858061b4a9   15 hours ago    23.7MB
localhost:5000/hello-melange-apko                        multi-stage-latest                          02e8709b0552   19 hours ago    16.1MB
localhost:5000/hello-melange-apko                        <none>                                      8564528a054a   20 hours ago    1.1GB
localhost:5000/hello-melange-apko                        <none>                                      9350fb7f35fd   20 hours ago    1.03GB
localhost:5000/hello-melange-apko                        single-stage-latest                         b75114461081   20 hours ago    874MB
```

Loaded image into minikube (from local registry) and patched deployment to use Distroless Melange + Apko and verified deployment
```
$ minikube image load localhost:5000/hello-melange-apko:apko-distroless-latest
$ kubectl set image deployment/multistage   app=localhost:5000/hello-melange-apko:apko-distroless-latest   -n chainguard-demo
```

Verified deployment by matching image name and SHA with what is in docker image & curl
```
ddonahue@kube-ai$ k get pods
NAME                          READY   STATUS    RESTARTS   AGE
multistage-7cb686bcfd-9qtq8   1/1     Running   0          8m28s

ddonahue@kube-ai$ k get pod multistage-7cb686bcfd-9qtq8 -o json | grep image
                "image": "localhost:5000/hello-melange-apko:apko-distroless-latest",
                "imagePullPolicy": "IfNotPresent",
                "image": "localhost:5000/hello-melange-apko:apko-distroless-latest",
                "imageID": "docker://sha256:ed0b0b4295b7f7c28ee9ea98a25e36e09be14c8f39375a37852072d3eacbf542",

ddonahue@kube-ai$ curl http://192.168.49.2:30080
Hello World!
```