# Common variables
PROJECT_ID 				:= $(shell gcloud config list project --format='value(core.project)')
TF_DIR 						:= terraform
TF_OUT 						:= terraform.tfplan
TF_SA_ID 					:= terraform
TF_STATE_BUCKET 	:= wenjing-poc-terraform-state

##@ Terraform
.PHONY: init
init: ## Terraform init
	cd ${TF_DIR} && terraform init

.PHONY: plan
plan: ## Terraform plan
	gcloud auth activate-service-account --key-file="/Users/wenjing/.gcp/${PROJECT_ID}.json"
	cd ${TF_DIR} && terraform plan -out ${TF_OUT}

.PHONY: apply
apply: ## Terraform apply
	gcloud auth activate-service-account --key-file="/Users/wenjing/.gcp/${PROJECT_ID}.json"
	cd ${TF_DIR} && terraform apply ${TF_OUT}

.PHONY: destroy
destroy: ## Terraform destroy
	cd ${TF_DIR} && terraform destroy

##@ Operations
.PHONY: create-tf-state
create-tf-state: ## Create Terraform state file storage bucket on GCS 
	gsutil mb -p ${PROJECT_ID} gs://${TF_STATE_BUCKET}
	gsutil versioning set on gs://${TF_STATE_BUCKET}

.PHONY: create-tf-sa
create-tf-sa: ## Create Terraform service account and assign sufficient permissions
	gcloud iam service-accounts create ${TF_SA_ID} --display-name="Terraform default service account"
	gcloud projects add-iam-policy-binding ${PROJECT_ID} \
		--member="serviceAccount:${TF_SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com" \
		--role="roles/compute.instanceAdmin.v1"
	gcloud projects add-iam-policy-binding ${PROJECT_ID} \
		--member="serviceAccount:${TF_SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com" \
		--role="roles/storage.objectAdmin"
	gcloud projects add-iam-policy-binding ${PROJECT_ID} \
		--member="serviceAccount:${TF_SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com" \
		--role="roles/container.clusterAdmin"
	gcloud projects add-iam-policy-binding ${PROJECT_ID} \
		--member="serviceAccount:${TF_SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com" \
		--role="roles/iam.serviceAccountUser"
	gcloud iam service-accounts keys create ~/.gcp/${PROJECT_ID}.json \
		--iam-account ${TF_SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com

.PHONY: check-tf-sa
check-tf-sa: ## Verify Terraform service account roles
	gcloud projects get-iam-policy ${PROJECT_ID} \
		--flatten="bindings[].members" \
		--format='table(bindings.role)' \
		--filter="bindings.members:${TF_SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

.PHONY: get-credentials
get-credentials: ## Get GKE cluster login credentials
	cd ${TF_DIR} && echo $(terraform output get_credentials) && terraform output get_credentials
