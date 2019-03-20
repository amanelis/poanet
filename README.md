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
	* `for ((n=0;n<10;n++)); do geth account new --password ~/.passfile >> addresses.txt; done`
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
	* attach: `docker exec -it $(docker ps -a -q --filter "name=sealnode") geth attach ipc:/root/.ethereum/geth.ipc`
	* geth: `admin.nodeInfo.enode`

5. Add peering to each node

	* login to each node and add each other node's enode uri to `admin.addPeer(" .... ")`

6. Add Wallet / Faucet

Source: [Puppeth PoA guide](https://medium.com/@collin.cusce/using-puppeth-to-manually-create-an-ethereum-proof-of-authority-clique-network-on-aws-ae0d7c906cce)

# Manual Setup

## Setup initial PoA network

1. Install Geth (https://github.com/ethereum/go-ethereum/wiki/Installing-Geth)
2. Create node directory: 
```
mkdir node
```
3. Create account(s) as block sealer: `geth --datadir node/ acccount new`. Save
   address and password in node folder: `echo "password" >> node/pwd`, `echo
   "0x0" >> node/address`
4. Start node creation tool:
```
puppeth
```
5. The process should look something like this (for PoA):
```
  Please specify a network name to administer (no spaces, please)
> devnet
What would you like to do? (default = stats)
 1. Show network stats
 2. Configure new genesis
 3. Track new remote server
 4. Deploy network components
> 2
Which consensus engine to use? (default = clique)
 1. Ethash - proof-of-work
 2. Clique - proof-of-authority
> 2
How many seconds should blocks take? (default = 15)
> 5 // for example
Which accounts are allowed to seal? (mandatory at least one)
> 0x87366ef81db496edd0ea2055ca605e8686eec1e6 //copy paste from account.txt :)
> 0x08a58f09194e403d02a1928a7bf78646cfc260b0
Which accounts should be pre-funded? (advisable at least one)
> 0x87366ef81db496edd0ea2055ca605e8686eec1e6 // free ethers !
> 0x08a58f09194e403d02a1928a7bf78646cfc260b0
Specify your chain/network ID if you want an explicit one (default = random)
> 1515 // for example. Do not use anything from 1 to 10
Anything fun to embed into the genesis block? (max 32 bytes)
>
What would you like to do? (default = stats)
 1. Show network stats
 2. Manage existing genesis
 3. Track new remote server
 4. Deploy network components
> 2
1. Modify existing fork rules
 2. Export genesis configuration
> 2
Which file to save the genesis into? (default = devnet.json)
> genesis.json
INFO [01-23|15:16:17] Exported existing genesis block
What would you like to do? (default = stats)
 1. Show network stats
 2. Manage existing genesis
 3. Track new remote server
 4. Deploy network components
> ^C // ctrl+C to quit puppeth
```
6. Initialize nodes using our `genesis.json` file:
```
geth --datadir node/ init genesis.json
```
7. Create and start bootnode (helps nodes discover eachother)
```
bootnode -genkey boot.key
bootnode -nodekey boot.key -verbosity 9 -addr :30310 # More verbose so we can see connections
```
8. Start node:

```
geth
--datadir   node/ # Custom data directory for our node
--syncmode  'full' # Sync a fullnode (i.e. sync all blocks)
--port      30312 # Port for other to connect to your node
--rpc       # Enable RPC
--rpcaddr   'localhost' # RPC Address
--rpcport   8502 # RPC Port
--rpcapi    'personal,db,eth,net,web3,txpool,miner' # APIs to expose on RPC
--bootnodes 'enode://c6259d9360b25cd94a11e584e01812d2b37c3481ba858cdd656acc3686ada0c0f6fead3b3d8c38a97358d718fff1e5f959528eba50e3b2b2a679c2014e70ede0@35.236.87.113:30311' # As outputted by bootnode
--networkid 42 # As defined in genesis.json
--gasprice  '1' # Min gas for mining a transaction
--unlock '0xYourAddress' # The address inputted that is allowed to seal blocks
--password node/pwd # Password of the account above
--mine # Mine blocks!
```


## Connecting to a node
1. Install Geth (https://github.com/ethereum/go-ethereum/wiki/Installing-Geth)
2. Retrieve data from node provider (please ask someone currently running a node): genesis.json (from current nodes),
   networkid, bootnode enode address
3. Create a working directory: `mkdir node`
4. Create an account (optional): `geth --datadir node/ account new`. Make sure
   to save your address and password.
5. Initialize Geth node with genesis file: `geth --datadir node/ init genesis.json`
6. Start Geth node:
```
geth
--datadir   node/ # Custom data directory for our node
--syncmode  'full' # Sync a fullnode (i.e. sync all blocks)
--port      30312 # Port for other to connect to your node
--rpc       # Enable RPC
--rpcaddr   'localhost' # RPC Address
--rpcport   8502 # RPC Port
--rpcapi    'personal,db,eth,net,web3,txpool,miner' # APIs to expose on RPC
--bootnodes 'enode://c6259d9360b25cd94a11e584e01812d2b37c3481ba858cdd656acc3686ada0c0f6fead3b3d8c38a97358d718fff1e5f959528eba50e3b2b2a679c2014e70ede0@35.236.87.113:30311' # Get from node provider
--networkid 42 # Get from node provider
--gasprice  '1' # Min gas for mining a transaction
```

## Other node options

For full documentation, check here: https://github.com/ethereum/go-ethereum/wiki/Command-Line-Options

Opening ports for RPC:
```
--rpcaddr       '0.0.0.0' # Listen to itself
--rpccorsdomain "*" # Anyone CORS can connect
--rpcvhosts     "*" # Any vhosts can connect
```
