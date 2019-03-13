DIMAGENAME = '55f/aws-ethereum-poa:develop'

build:
	docker build -t $(DIMAGENAME) .

run:
	docker run -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
			   -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
			   -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
			   -e "ACCOUNT_ID=${customer_account_id}" \
			   -it $(DIMAGENAME) '/bin/bash'
