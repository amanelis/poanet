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
				   -var-file=environments/$(ENV).tfvars -lock=false | /usr/local/bin/landscape

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


kill:
	terraform destroy \
					  -target aws_instance.geth4 \
					  -target aws_route53_record.geth4 \
					  -var profile=$(AWS_PROFILE) \
					  -var region=$(AWS_DEFAULT_REGION) \
					  -var-file=environments/$(ENV).tfvars -lock=false
