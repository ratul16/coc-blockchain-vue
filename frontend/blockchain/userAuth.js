// This file is to export the smart contract locally for the vue app to use
import Web3 from 'web3';

const contractAddress = import.meta.env.VITE_USER_AUTH;

//http provider shows vue which blockchain to target
const provider = new Web3.providers.HttpProvider('http://127.0.0.1:7545');

// passing provider to web3
const web3 = new Web3(provider);

// abi(Application Binary Interface) connects smart contract with the vue app

const abi = [{ "inputs": [], "name": "getAllUsers", "outputs": [{ "internalType": "address[]", "name": "", "type": "address[]" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "address", "name": "userAddress", "type": "address" }], "name": "getUserInfo", "outputs": [{ "internalType": "string", "name": "", "type": "string" }, { "internalType": "string", "name": "", "type": "string" }, { "internalType": "enum UserAuth.Roles", "name": "", "type": "uint8" }, { "internalType": "string", "name": "", "type": "string" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "string", "name": "_email", "type": "string" }, { "internalType": "string", "name": "_password", "type": "string" }], "name": "isValidUser", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "string", "name": "_name", "type": "string" }, { "internalType": "string", "name": "_email", "type": "string" }, { "internalType": "string", "name": "_password", "type": "string" }, { "internalType": "enum UserAuth.Roles", "name": "_role", "type": "uint8" }], "name": "registerUser", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [{ "internalType": "string", "name": "_publicKey", "type": "string" }], "name": "updatePublicKey", "outputs": [], "stateMutability": "nonpayable", "type": "function" }];


//local copy of the contract
const lcContract = new web3.eth.Contract(abi, contractAddress);

export default lcContract;