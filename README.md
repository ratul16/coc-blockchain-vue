# Digital Chain of Custody using Blockchain

## Project Overview

In the contemporary digital era, the significance of data cannot be overstated. Data permeates every aspect of people's lives, from everyday activities to critical criminal investigations. As data volumes continue to expand exponentially, effective data management becomes increasingly challenging, particularly when handling digital evidence in the context of cyber-crime investigations. This project delves into the intricacies of managing data integrity and ensuring secure distribution of digital evidence by leveraging blockchain technology.

## Project Requirements
1. Node
2. Ganache : https://trufflesuite.com/ganache/
3. Truffle
4. IPFS (To easily access the uploaded files)
5. Docker (To host a private IPFS)

## Project Setup

### Deploy Smart Contract
Navigate to directory `/smartcontract`

Change the port number to the port number of the Ganache Suite, which can found in the `truffle-config.js` file under **development**.

Run truffle migrate command
```sh 
truffle migrate --reset --compile-all 
```
The migrate command will deploy the smart contracts to the ganache suite and will display the address of both smart contracts in the terminal.

#### **Important Note**
To run ganache network in terminal run command: 

```sh
truffle console --network ganache
```

Create a `.env` file and paste in the variables from `.env.local` file located in directory `/frontend/.env.local`

Copy & paste the addresses of the smart contract to the respected environment variable in the `.env` file. Additionally, add a salt value which is needed for encryption.

```js
  VITE_USER_AUTH = 
  VITE_MANAGEMENT = 
  VITE_SALT =
```

### Host Private IPFS

Open a terminal and navigate to the directory `/ipfs`, where `docker-compose.yml` file is located. To start the services defined in the Docker Compose file, run the following command:

```sh
docker-compose up
```

If you want to run the services in the background (detached mode), you can use the -d option:
```sh
docker-compose up -d
```

### Project Installation
Open terminal on directory `/frontend` and enter to install necessary packages.

```sh
npm install
```
To Compile and Hot-Reload for Development

```sh
npm run dev
```
Compile and Minify for Production

```sh
npm run build
```
Run Unit Tests with [Vitest](https://vitest.dev/)

```sh
npm run test:unit
```
Lint with [ESLint](https://eslint.org/)

```sh
npm run lint
```
