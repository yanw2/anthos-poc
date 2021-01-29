TF_OUT := terraform.tfplan 

tf.init: ## Terraform init
	cd terraform && terraform init

tf.plan: ## Terraform plan
	cd terraform && terraform plan -out ${TF_OUT} 

tf.apply: ## Terraform apply
	cd terraform && terraform apply ${TF_OUT}

tf.destroy: ## Terraform destroy
	cd terraform && terraform destroy
