TF_OUT := terraform.tfplan 

tf.init: ## Terraform init
	terraform init

tf.plan: ## Terraform plan
	terraform plan -out ${TF_OUT} 

tf.apply: ## Terraform apply
	terraform apply ${TF_OUT}

tf.destroy: ## Terraform destroy
	terraform destroy
