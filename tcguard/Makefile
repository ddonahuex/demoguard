REGISTRY   ?= localhost:5000
IMAGE_NAME ?= hello-melange-apko
IMAGE      ?= $(REGISTRY)/$(IMAGE_NAME)
TAG        ?= latest
SCAN_DIR   ?= ./scan
SBOM_DIR   ?= ./sbom

single-stage:
	@docker build --progress=plain -t $(IMAGE):single-stage-$(TAG) -f Dockerfile.single .
	@cosign sign --key cosign.key $(IMAGE):single-stage-$(TAG)
	@docker push $(IMAGE):single-stage-$(TAG)
	@echo "Generating SBOM (CycloneDX) ..."
	@syft docker:$(IMAGE):single-stage-$(TAG) -o cyclonedx-json | jq . > temp.json && mv temp.json $(SBOM_DIR)/$(IMAGE_NAME)-single-stage-$(TAG)-bom.json
	@echo "Generating Vulnerability Report ..."
	@grype docker:$(IMAGE):single-stage-$(TAG) -o json | jq . > temp.json && mv temp.json $(SCAN_DIR)/$(IMAGE_NAME)-single-stage-$(TAG)-vuln-report.json

multi-stage:
	@docker build --progress=plain -t $(IMAGE):multi-stage-$(TAG) -f Dockerfile.multi --push .
	@cosign sign --key cosign.key $(IMAGE):multi-stage-$(TAG)
	@docker push $(IMAGE):multi-stage-$(TAG)
	@echo "Generating SBOM (CycloneDX) ..."
	@syft docker:$(IMAGE):multi-stage-$(TAG) -o cyclonedx-json | jq . > temp.json && mv temp.json $(SBOM_DIR)/$(IMAGE_NAME)-multi-stage-$(TAG)-bom.json
	@echo "Generating Vulnerability Report ..."
	@grype docker:$(IMAGE):multi-stage-$(TAG) -o json | jq . > temp.json && mv temp.json $(SCAN_DIR)/$(IMAGE_NAME)-multi-stage-$(TAG)-vuln-report.json

wolfi:
	@docker build --progress=plain -t $(IMAGE):wolfi-$(TAG) -f Dockerfile.wolfi --push .
	@cosign sign --key cosign.key $(IMAGE):wolfi-$(TAG)
	@docker push $(IMAGE):wolfi-$(TAG)
	@echo "Generating SBOM (CycloneDX) ..."
	@syft docker:$(IMAGE):wolfi-$(TAG) -o cyclonedx-json | jq . > temp.json && mv temp.json $(SBOM_DIR)/$(IMAGE_NAME)-wolfi-$(TAG)-bom.json
	@echo "Generating Vulnerability Report ..."
	@grype docker:$(IMAGE):wolfi-$(TAG) -o json | jq . > temp.json && mv temp.json $(SCAN_DIR)/$(IMAGE_NAME)-wolfi-$(TAG)-vuln-report.json

melange:
	@docker run --rm --privileged \
		-v "$(PWD)/hello-melange-apko/go":/work \
		--entrypoint melange \
		--workdir /work \
		ghcr.io/wolfi-dev/sdk:latest \
		build melange.yaml.ori \
		--arch amd64 \
		--signing-key melange.rsa \
		--out-dir packages

help:
	@echo "Make targets:"
	@echo "  single-stage\t\tSingle-stage Docker build, SBOM generation, & Vulnerability report for $(REGISTRY)/$(IMAGE_NAME) Docker image"
	@echo "  multi-stage\t\tMulti-stage Docker build, SBOM generation, & Vulnerability report for $(REGISTRY)/$(IMAGE_NAME) Docker image"
	@echo "  wolfi\t\t\tMulti-stage Docker build, SBOM generation, & Vulnerability report for Wolfi-based $(REGISTRY)/$(IMAGE_NAME) Docker image"
	@echo "  melange\t\tBuilds a real production grade Wolfi package"
	@echo "  help\t\t\tPrint this help menu"  

.PHONE: single-stage multi-stage wolfi melange help