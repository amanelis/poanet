init:
	rm -rf .terraform
	terraform fmt
	terraform init -input=true \
				   -backend=true \
				   -backend-config="bucket=55nodes-terraform-state-$(ENV)" \
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
	terraform destroy -target aws_security_group.ethereum \
					  -target aws_instance.geth-master-full \
					  -target aws_instance.geth-master-fast \
					  -target aws_instance.geth-master-light \
					  -target aws_route53_record.geth-master-full \
					  -target aws_route53_record.geth-master-fast \
					  -target aws_route53_record.geth-master-light \
					  -var profile=$(AWS_PROFILE) \
					  -var region=$(AWS_DEFAULT_REGION) \
					  -var-file=environments/$(ENV).tfvars -lock=false
