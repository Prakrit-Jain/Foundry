// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Wallet {
    event OwnershipTransferred(address indexed from, address indexed to);

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not a Owner");
        _;
    }

    function withdraw(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function setOwner(address _newOwner) external onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner = payable(_newOwner);
    }
}
