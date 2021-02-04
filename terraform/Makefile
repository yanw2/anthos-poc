TF_OUT := terraform.tfplan

init: ## Terraform init
	terraform init

plan: ## Terraform plan
	terraform plan -out ${TF_OUT} 

apply: ## Terraform apply
	terraform apply ${TF_OUT}

destroy: ## Terraform destroy
	terraform destroy
