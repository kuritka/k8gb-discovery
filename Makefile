VERSION ?= 0.0.1
CLUSTER_NAME ?=k3s-k8gb-disco

.PHONY: lint
lint:
	$(call lint)

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: docker-build
docker-build:
	$(call docker-build)

.PHONY: check
check:
	goimports -l -w ./
	go generate ./...
	go mod tidy
	$(call lint)
	$(call docker-build)

.PHONY: redeploy
redeploy:
	docker build -t docker.io/kuritka/k8gb-discovery:0.0.1 .
	docker push docker.io/kuritka/k8gb-discovery:0.0.1
	kubectl delete ns k8gb-discovery
	kubectl apply -k ./deploy/k8gb-discovery

.PHONY: start
start:
	k3d cluster create $(CLUSTER_NAME) --api-port 6550 -p "8081:80@loadbalancer" --agents 3
	kubectl create ns k8gb-discovery

.PHONY: stop
stop:
	k3d cluster delete $(CLUSTER_NAME)

.PHONY: test-api
test-api:
	kubectl run -it --rm busybox --restart=Never --image=busybox -- sh -c \
	"wget -qO - k8gb-discovery.nonprod.bcp.absa.co.za/metrics"
#	"echo '172.17.0.9 k8gb-discovery.nonprod.bcp.absa.co.za' > /etc/hosts && \
#	wget -qO - k8gb-discovery.nonprod.bcp.absa.co.za/healthy"

define lint
	golangci-lint run
	go test  ./...
endef

define docker-build
	time docker build -t k8gb-discovery:$(VERSION) .
endef