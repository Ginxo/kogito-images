IMAGE_VERSION := $(shell cat image.yaml | egrep ^version  | cut -d"\"" -f2)
SHORTENED_LATEST_VERSION := $(shell echo $(IMAGE_VERSION) | awk -F. '{print $$1"."$$2}')
BUILD_ENGINE := docker
.DEFAULT_GOAL := build

# Build all images
.PHONY: build
build: kogito-quarkus-ubi8 kogito-quarkus-jvm-ubi8 kogito-quarkus-ubi8-s2i kogito-springboot-ubi8 kogito-springboot-ubi8-s2i kogito-data-index kogito-jobs-service kogito-management-console

kogito-quarkus-ubi8:
	cekit -v build --overrides-file kogito-quarkus-overrides.yaml ${BUILD_ENGINE}
ifneq ($(findstring "rc",$(IMAGE_VERSION)),"rc")
	${BUILD_ENGINE} tag quay.io/kiegroup/kogito-quarkus-ubi8:${IMAGE_VERSION} quay.io/kiegroup/kogito-quarkus-ubi8:${SHORTENED_LATEST_VERSION}
endif

kogito-quarkus-jvm-ubi8:
	cekit -v build --overrides-file kogito-quarkus-jvm-overrides.yaml ${BUILD_ENGINE}
ifneq ($(findstring "rc",$(IMAGE_VERSION)),"rc")
	${BUILD_ENGINE} tag quay.io/kiegroup/kogito-quarkus-jvm-ubi8:${IMAGE_VERSION} quay.io/kiegroup/kogito-quarkus-jvm-ubi8:${SHORTENED_LATEST_VERSION}
endif

kogito-quarkus-ubi8-s2i:
	cekit -v build --overrides-file kogito-quarkus-s2i-overrides.yaml ${BUILD_ENGINE}
ifneq ($(findstring "rc",$(IMAGE_VERSION)),"rc")
	${BUILD_ENGINE} tag quay.io/kiegroup/kogito-quarkus-ubi8-s2i:${IMAGE_VERSION} quay.io/kiegroup/kogito-quarkus-ubi8-s2i:${SHORTENED_LATEST_VERSION}
endif

kogito-springboot-ubi8:
	cekit -v build --overrides-file kogito-springboot-overrides.yaml ${BUILD_ENGINE}
ifneq ($(findstring "rc",$(IMAGE_VERSION)),"rc")
	${BUILD_ENGINE} tag quay.io/kiegroup/kogito-springboot-ubi8:${IMAGE_VERSION} quay.io/kiegroup/kogito-springboot-ubi8:${SHORTENED_LATEST_VERSION}
endif

kogito-springboot-ubi8-s2i:
	cekit -v build --overrides-file kogito-springboot-s2i-overrides.yaml ${BUILD_ENGINE}
ifneq ($(findstring "rc",$(IMAGE_VERSION)),"rc")
	${BUILD_ENGINE} tag quay.io/kiegroup/kogito-springboot-ubi8-s2i:${IMAGE_VERSION} quay.io/kiegroup/kogito-springboot-ubi8-s2i:${SHORTENED_LATEST_VERSION}
endif

kogito-data-index:
	cekit -v build --overrides-file kogito-data-index-overrides.yaml ${BUILD_ENGINE}
ifneq ($(findstring "rc",$(IMAGE_VERSION)),"rc")
	${BUILD_ENGINE} tag quay.io/kiegroup/kogito-data-index:${IMAGE_VERSION} quay.io/kiegroup/kogito-data-index:${SHORTENED_LATEST_VERSION}
endif

kogito-jobs-service:
	cekit -v build --overrides-file kogito-jobs-service-overrides.yaml ${BUILD_ENGINE}
ifneq ($(findstring "rc",$(IMAGE_VERSION)),"rc")
	${BUILD_ENGINE} tag quay.io/kiegroup/kogito-jobs-service:${IMAGE_VERSION} quay.io/kiegroup/kogito-jobs-service:${SHORTENED_LATEST_VERSION}
endif

kogito-management-console:
	cekit -v build --overrides-file kogito-management-console-overrides.yaml ${BUILD_ENGINE}
ifneq ($(findstring "rc",$(IMAGE_VERSION)),"rc")
	${BUILD_ENGINE} tag quay.io/kiegroup/kogito-management-console:${IMAGE_VERSION} quay.io/kiegroup/kogito-management-console:${SHORTENED_LATEST_VERSION}
endif


# Build and test all images
.PHONY: test
test:
	cd tests/test-apps && sh clone-repo.sh
	cekit -v test --overrides-file kogito-quarkus-overrides.yaml behave
	cekit -v test --overrides-file kogito-quarkus-jvm-overrides.yaml behave
	cekit -v test --overrides-file kogito-quarkus-s2i-overrides.yaml behave
	cekit -v test --overrides-file kogito-springboot-overrides.yaml behave
	cekit -v test --overrides-file kogito-springboot-s2i-overrides.yaml behave
	cekit -v test --overrides-file kogito-data-index-overrides.yaml behave
	cekit -v test --overrides-file kogito-jobs-service-overrides.yaml behave
	cekit -v test --overrides-file kogito-management-console-overrides.yaml behave


# push images to quay.io, this requires permissions under kiegroup organization
.PHONY: push
push: build _push
_push:
	docker push quay.io/kiegroup/kogito-quarkus-ubi8:${IMAGE_VERSION}
	docker push quay.io/kiegroup/kogito-quarkus-ubi8:latest
	docker push quay.io/kiegroup/kogito-quarkus-jvm-ubi8:${IMAGE_VERSION}
	docker push quay.io/kiegroup/kogito-quarkus-jvm-ubi8:latest
	docker push quay.io/kiegroup/kogito-quarkus-ubi8-s2i:${IMAGE_VERSION}
	docker push quay.io/kiegroup/kogito-quarkus-ubi8-s2i:latest
	docker push quay.io/kiegroup/kogito-springboot-ubi8:${IMAGE_VERSION}
	docker push quay.io/kiegroup/kogito-springboot-ubi8:latest
	docker push quay.io/kiegroup/kogito-springboot-ubi8-s2i:${IMAGE_VERSION}
	docker push quay.io/kiegroup/kogito-springboot-ubi8-s2i:latest
	docker push quay.io/kiegroup/kogito-data-index:${IMAGE_VERSION}
	docker push quay.io/kiegroup/kogito-data-index:latest
	docker push quay.io/kiegroup/kogito-jobs-service:${IMAGE_VERSION}
	docker push quay.io/kiegroup/kogito-jobs-service:latest
	docker push quay.io/kiegroup/kogito-management-console:${IMAGE_VERSION}
	docker push quay.io/kiegroup/kogito-management-console:latest
ifneq ($(findstring "rc",$(IMAGE_VERSION)),"rc")
	@echo "${SHORTENED_LATEST_VERSION} will be pushed"
	docker push quay.io/kiegroup/kogito-quarkus-ubi8:${SHORTENED_LATEST_VERSION}
	docker push quay.io/kiegroup/kogito-quarkus-jvm-ubi8:${SHORTENED_LATEST_VERSION}
	docker push quay.io/kiegroup/kogito-quarkus-ubi8-s2i:${SHORTENED_LATEST_VERSION}
	docker push quay.io/kiegroup/kogito-springboot-ubi8:${SHORTENED_LATEST_VERSION}
	docker push quay.io/kiegroup/kogito-springboot-ubi8-s2i:${SHORTENED_LATEST_VERSION}
	docker push quay.io/kiegroup/kogito-data-index:${SHORTENED_LATEST_VERSION}
	docker push quay.io/kiegroup/kogito-jobs-service:${SHORTENED_LATEST_VERSION}
	docker push quay.io/kiegroup/kogito-management-console:${SHORTENED_LATEST_VERSION}
endif


# push staging images to quay.io, done before release, this requires permissions under kiegroup organization
.PHONY: push-staging
push-staging: build _push-staging
_push-staging:
	python3 push-staging.py

