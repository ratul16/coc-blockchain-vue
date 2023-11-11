// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract UserAuth {
    enum Roles {
        Investigator,
        ForensicAnalyst,
        Judge,
        Jury,
        Admin
    }

    struct UserProfile {
        string name;
        string email;
        string password;
        Roles role;
        string publicKey;
    }

    mapping(address => UserProfile) private users;
    mapping(string => bool) private userExists;
    address[] private allUsers;

    modifier onlyNewUser(string memory _email) {
        require(!userExists[_email], "Email address is already registered");
        _;
    }

    function registerUser(
        string memory _name,
        string memory _email,
        string memory _password,
        Roles _role
    ) external onlyNewUser(_email) {
        users[msg.sender] = UserProfile(_name, _email, _password, _role, "");
        userExists[_email] = true;
        allUsers.push(msg.sender);
    }

    function getUserInfo(
        address userAddress
    )
        external
        view
        returns (string memory, string memory, Roles, string memory)
    {
        UserProfile storage userInfo = users[userAddress];
        return (
            userInfo.name,
            userInfo.email,
            userInfo.role,
            userInfo.publicKey
        );
    }

    function isValidUser(
        string memory _email,
        string memory _password
    ) external view returns (bool) {
        UserProfile storage currentUser = users[msg.sender];
        return (keccak256(abi.encodePacked(currentUser.email)) ==
            keccak256(abi.encodePacked(_email)) &&
            keccak256(abi.encodePacked(currentUser.password)) ==
            keccak256(abi.encodePacked(_password)));
    }

    function updatePublicKey(string memory _publicKey) external {
        UserProfile storage currentUser = users[msg.sender];
        currentUser.publicKey = _publicKey;
    }

    function getAllUsers() external view returns (address[] memory) {
        return allUsers;
    }
}
