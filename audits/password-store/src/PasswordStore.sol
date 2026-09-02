// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PasswordStore
 * @notice This contract allows users to store a password on-chain.
 * @dev VULNERABILITY: Developers often mistake `private` visibility for confidentiality. 
 * Everything on the blockchain is public and can be read by anyone (using RPC or storage slot reading).
 */
contract PasswordStore {
    address private s_owner;
    // Vulnerability: Even with 'private', all state variables on-chain are publicly readable.
    string private s_password;

    constructor() {
        s_owner = msg.sender;
    }

    function setPassword(string memory newPassword) external {
        require(msg.sender == s_owner, "Not owner");
        s_password = newPassword;
        emit PasswordUpdated();
    }

    function getPassword() external view returns (string memory) {
        require(msg.sender == s_owner, "Not owner");
        return s_password;
    }

    event PasswordUpdated();
}