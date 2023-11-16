AZR_LOCATION ?= eastus
ARO_CLUSTER_NAME ?= example
ARO_VNET_RESOURCE_GROUP ?= $(ARO_CLUSTER_NAME)-vnet-rg
ARO_VNET_CIDR ?= 10.0.0.0/22
ARO_VNET_CONTROL_CIDR ?= 10.0.0.0/23
ARO_VNET_WORKER_CIDR ?= 10.0.2.0/23
ARO_PULL_SECRET ?= ~/.azure/aro-pull-secret.txt

setup-test:
	az group create \
		--name $(ARO_VNET_RESOURCE_GROUP) \
		--location $(AZR_LOCATION)

	az network vnet create \
		--address-prefixes $(ARO_VNET_CIDR) \
		--name "$(ARO_CLUSTER_NAME)-aro-vnet-$(AZR_LOCATION)" \
		--resource-group $(ARO_VNET_RESOURCE_GROUP)

	az network vnet subnet create \
		--resource-group $(ARO_VNET_RESOURCE_GROUP) \
		--vnet-name "$(ARO_CLUSTER_NAME)-aro-vnet-$(AZR_LOCATION)" \
		--name "$(ARO_CLUSTER_NAME)-aro-control-subnet-$(AZR_LOCATION)" \
		--address-prefixes "$(ARO_VNET_CONTROL_CIDR)"

	az network vnet subnet create \
		--resource-group $(ARO_VNET_RESOURCE_GROUP) \
		--vnet-name "$(ARO_CLUSTER_NAME)-aro-vnet-$(AZR_LOCATION)" \
		--name "$(ARO_CLUSTER_NAME)-aro-worker-subnet-$(AZR_LOCATION)" \
		--address-prefixes "$(ARO_VNET_WORKER_CIDR)"

	az network vnet subnet update \
		--name "$(ARO_CLUSTER_NAME)-aro-control-subnet-$(AZR_LOCATION)" \
		--resource-group $(ARO_VNET_RESOURCE_GROUP) \
		--vnet-name "$(ARO_CLUSTER_NAME)-aro-vnet-$(AZR_LOCATION)" \
		--disable-private-link-service-network-policies true

teardown-test:
	az network subnet delete \
		--name "$(ARO_CLUSTER_NAME)-aro-worker-subnet-$(AZR_LOCATION)" \
		--resource-group $(ARO_VNET_RESOURCE_GROUP) \
		--vnet-name "$(ARO_CLUSTER_NAME)-aro-vnet-$(AZR_LOCATION)" \
		--yes

	az network subnet delete \
		--name "$(ARO_CLUSTER_NAME)-aro-control-subnet-$(AZR_LOCATION)" \
		--resource-group $(ARO_VNET_RESOURCE_GROUP) \
		--vnet-name "$(ARO_CLUSTER_NAME)-aro-vnet-$(AZR_LOCATION)" \
		--yes

	az network vnet delete \
		--name "$(ARO_CLUSTER_NAME)-aro-vnet-$(AZR_LOCATION)" \
		--resource-group $(ARO_VNET_RESOURCE_GROUP) \
		--yes

	az group delete --name $(ARO_VNET_RESOURCE_GROUP) --yes