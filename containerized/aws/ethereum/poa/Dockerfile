FROM library/node:6.11.2

RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-setuptools \
        groff \
		jq \
        less \
		unzip \
    && pip3 install --upgrade pip \
    && apt-get clean

RUN pip3 --no-cache-dir install --upgrade awscli

RUN wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip && \
	unzip terraform_0.11.10_linux_amd64.zip && \
	mv terraform /usr/local/bin

CMD ["/bin/bash"]
