#!/bin/bash

# Navigate to the ipfs directory
cd ipfs;
ls

# Navigate to the frontend directory


# echo "Starting private IPFS container...."
# cd ipfs;
# docker-compose up -d

# echo "Container running ...."
# echo "----------------------"

echo "Compiling smart contract..."
cd smartcontract;
truffle migrate --reset --compile-all

echo "Smart contract compiled ...."
echo "----------------------"

echo "Starting webapp server..."
cd ../frontend;
npm run compile

# echo "Starting webapp server..."
# cd ../frontend;
# npm run dev






