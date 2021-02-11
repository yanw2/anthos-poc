##@ Terraform

# Common variables
TF_DIR := terraform
TF_OUT := terraform.tfplan

.PHONY: init
init: ## Terraform init
	cd ${TF_DIR} && terraform init

.PHONY: plan
plan: ## Terraform plan
	cd ${TF_DIR} && terraform plan -out ${TF_OUT}

.PHONY: apply
apply: ## Terraform apply
	cd ${TF_DIR} && terraform apply ${TF_OUT}

.PHONY: destroy
destroy: ## Terraform destroy
	cd ${TF_DIR} && terraform destroy
