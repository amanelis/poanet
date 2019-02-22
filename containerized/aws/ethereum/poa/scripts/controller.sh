# Make accounts
for ((n=0;n<10;n++)); do /usr/local/bin/geth account new --password /home/ubuntu/passfile >> addresses.txt; done

# Start network configuration
/usr/local/bin/puppeth --network $ACCOUNT_ID
