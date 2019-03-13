# Introduction

This repository consistes of Terraform scripts to build and launch Ethereum Proof-of-authority networks. 

## Requirements:
- [AWS cli](https://aws.amazon.com/cli/)
- [Terraform](https://www.terraform.io/downloads.html)

## Getting Started
Configure your `aws cli` with your credentials:
```bash
$ aws configure
```

# Deploying
To deploy, you must ensure your S3 buckets and `$ENV` var is configured. Please start by running in development environment, you can do this by passing `ENV=dev` in front of all your commands.

##### Initialize
You must initialize the Terraform backend by running:

```
ENV=dev make init
```

##### Plan
Plan your environment before applying the changes to a live environment, this will also lint:

```
ENV=dev make plan
```

##### Apply
Apply will make physical changes to your infrastructure:

```
ENV=dev make apply
```

##### Destroy
Just don't run this unless you know what you're doing, it will destroy an environment:

```
ENV=dev make destroy
```

# Configuration
This next step was primarly going to be automated using the [poagod](https://aws.amazon.com/cli/) framework, but work was not continued. Follow steps below:

### Controller Setup
	
1. ssh-keygen -t rsa, copy the public key to all nodes.
2. Create accounts: 
	* `for ((n=0;n<10;n++)); do geth account new --password ~.passfile >> addresses.txt; done`
3. Create gensis: 
	* `puppeth --network $ACCOUNT_ID`
4. Record all keys from `~/.ethereum/keystore` and create an API Password for steps below.

### Node Setup

1. Create Ethstats
	
	* run on node0

2. Create Bootnode

	* run on node0
	* Location for datadir: `/home/ubuntu/poanet/bootnode`
	* TCP/IP port: `30305`
	* name: `bootnode`

3. Create Sealnode

	* run on node0, node1, node2
	* Location for datadir: `/home/ubuntu/poanet/sealernode`
	* TCP/IP port: `default`
	* name: `node{n}.sealer`
	* gas limit: `94000000`
	* gwei: `0.0001`

4. Get all Sealnode's enode uri

	* ssh into each node
	* attach: `docker exec -it <container_id> geth attach ipc:/root/.ethereum/geth.ipc`
	* geth: `admin.nodeInfo.enode`

5. Add peering to each node

	* login to each node and add each other node's enode uri to `admin.addPeer(" .... ")`

6. Add Wallet / Faucet

Source: [Puppeth PoA guide](https://medium.com/@collin.cusce/using-puppeth-to-manually-create-an-ethereum-proof-of-authority-clique-network-on-aws-ae0d7c906cce)