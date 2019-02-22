DIMAGENAME = '55f/aws-ethereum-poa:develop'

build:
	docker build -t $(DIMAGENAME) .

run:
	# aws ec2 describe-images --filters "Name=tag:NodeService,Values=geth" --query 'sort_by(Images, &CreationDate)[]'
	docker run -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -it $(DIMAGENAME) '/bin/bash'
