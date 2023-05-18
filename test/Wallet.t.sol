// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Wallet.sol";
import "forge-std/console.sol";

contract Utilities is Test {
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));

    function getNextUserAddress() external returns (address payable) {
        //bytes32 to address conversion
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    /// @notice create users with 100 ether balance
    function createUsers(uint256 userNum)
        external
        returns (address payable[] memory)
    {
        address payable[] memory users = new address payable[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            address payable user = this.getNextUserAddress();
            vm.deal(user, 100 ether);
            users[i] = user;
        }
        return users;
    }

    /// @notice move block.number forward by a given number of blocks
    function mineBlocks(uint256 numBlocks) external {
        uint256 targetBlock = block.number + numBlocks;
        vm.roll(targetBlock);
    }
}

contract WalletTest is Utilities {
    event OwnershipTransferred(address indexed from, address indexed to);

    Wallet public wallet;
    address payable[] users;

    function setUp() external {
        wallet = new Wallet();
        users = this.createUsers(3);
    }

    function _send(uint _amount) public {
        (bool ok, ) = address(wallet).call{value: _amount}("");
        require(ok, "Send Eth failed");
    }

    function testSetOwner() external {
        wallet.setOwner(users[0]);
        assertEq(wallet.owner(), users[0]);
    }

    function testFailSetOwner() external {
        vm.prank(users[1]);
        wallet.setOwner(users[1]);
    }

    function testSetOwnerAgain() external {
        wallet.setOwner(address(1));
        vm.startPrank(address(1));
        wallet.setOwner(address(1));
        wallet.setOwner(address(1));
        wallet.setOwner(address(1));
        vm.stopPrank();
        vm.expectRevert(bytes("Not a Owner"));
        wallet.setOwner(address(1));
    }

    function testEmitEvent() external {
        vm.expectEmit(true, true, false , false);
        emit OwnershipTransferred(address(this), address(12));
        wallet.setOwner(address(12));
    }

    function testEthBal() external {
        console.log(address(msg.sender));
        console.log("Eth balance", address(msg.sender).balance / 1e18);
        deal(address(this), 1e19);
        console.log("Eth balance", address(this).balance / 1e18);
        hoax(address(msg.sender), 1e19);
        console.log("Eth balance", address(msg.sender).balance / 1e18);

    }

    function testSignature() external {
        uint256 privateKey = 123;
        address publicKey = vm.addr(privateKey);
        bytes32 messageHash = keccak256("Secret-Message");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);
        address signer = ecrecover(messageHash, v, r, s);
        assertEq(signer, publicKey);
    }
}
