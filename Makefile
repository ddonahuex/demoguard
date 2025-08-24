# Variables
BINARY_NAME = demoguard
MAIN_MODULE = ./src
REGISTRY = ddonahuex
IMAGE_NAME = demoguard
TYPE ?= standard
TAG = $(TYPE)
IMAGE = $(REGISTRY)/$(IMAGE_NAME):$(TAG)

# default
all: clean docker-prod

# Clean up
clean:
	@echo "Cleaning..."
	@rm -f $(MAIN_MODULE)/$(BINARY_NAME)
	@rm Dockerfile >/dev/null 2>&1 || true
	@rm *-bom.json >/dev/null 2>&1 || true
	@rm *-report.json >/dev/null 2>&1 || true
	@rm Dockerfile >/dev/null 2>&1 || true
	@for dir in $(MAIN_MODULE); do \
		cd $$dir && go clean && cd ..; \
	done

# Build Demoguard Docker image
docker-build:
	@echo "Setting build type to $(TYPE)"
	@ln -s Dockerfile-$(TYPE) Dockerfile
	@echo "Building Docker image ..."
	@docker build -t $(IMAGE) .
	@echo "Generating SBOM (CycloneDX) ..."
	@syft docker:$(IMAGE) -o cyclonedx-json | jq . > temp.json && mv temp.json $(IMAGE_NAME):$(TAG)-bom.json
	@echo "Generating Vulnerability Report ..."
	@grype docker:$(IMAGE) -o json | jq . > temp.json && mv temp.json $(IMAGE_NAME):$(TAG)-vuln-report.json
	@rm Dockerfile >/dev/null 2>&1 || true

docker-push:
	@echo "Running Docker push ..."
	@docker push $(IMAGE)

# Build & Push demoguard
docker-prod: docker-build docker-push

help:
	@echo "Make Targets:"
	@echo "  clean\t\tExecutes a Go clean for all modules"
	@echo "  docker-build\tDocker build, SBOM generation, & Vulnerability report for $(REGISTRY)/$(IMAGE_NAME) Docker image"
	@echo "  docker-push\tDocker push for of $(REGISTRY)/$(IMAGE_NAME) to the $(REGISTRY) Docker Hub namespace"
	@echo "  docker-prod\tExecutes docker-build and docker-push make targets"
	@echo "  help\t\tPrint this help menu"
	
.PHONY: clean docker-build docker-push docker-push help