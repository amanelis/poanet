init:
	rm -rf .terraform
	terraform fmt
	terraform init -input=true \
				   -backend=true \
				   -backend-config="bucket=ticketing-terraform-state-$(ENV)" \
				   -backend-config="key=$(ENV).tfstate" \
				   -backend-config="region=$(AWS_DEFAULT_REGION)" \
				   -backend-config="dynamodb_table=terraform_locks" \
				   -get=true \
				   -get-plugins=true \
				   -verify-plugins=true

plan:
	terraform plan -var profile=$(AWS_PROFILE) \
				   -var region=$(AWS_DEFAULT_REGION) \
				   -var-file=environments/$(ENV).tfvars -lock=false

apply:
	terraform apply -var profile=$(AWS_PROFILE) \
					-var region=$(AWS_DEFAULT_REGION) \
					-var-file=environments/$(ENV).tfvars -lock=false

destroy:
	terraform destroy -var profile=$(AWS_PROFILE) \
					  -var region=$(AWS_DEFAULT_REGION) \
					  -var-file=environments/$(ENV).tfvars -lock=false

refresh:
	terraform refresh -var profile=$(AWS_PROFILE) \
					  -var region=$(AWS_DEFAULT_REGION) \
					  -var-file=environments/$(ENV).tfvars -lock=false

fmt:
	terraform fmt

kill:
	terraform destroy \
					  -target rancher_environment.demo \
					  -target rancher_registration_token.demo-token \
					  -var profile=$(AWS_PROFILE) \
					  -var region=$(AWS_DEFAULT_REGION) \
					  -var-file=environments/$(ENV).tfvars -lock=false
