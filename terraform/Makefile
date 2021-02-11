##@ Terraform

# Common variables
TF_OUT := terraform.tfplan

.PHONY: init
init: ## Terraform init
	terraform init

.PHONY: plan
plan: ## Terraform plan
	terraform plan -out ${TF_OUT}

.PHONY: apply
apply: ## Terraform apply
	terraform apply ${TF_OUT}

.PHONY: destroy
destroy: ## Terraform destroy
	terraform destroy
