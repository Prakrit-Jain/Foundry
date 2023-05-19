// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ERC20Factory.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address token = 0x7cBAdf5667123352155Cf0006E6aE8AD999B0667;
        ERC20Factory factory = new ERC20Factory(token);
        vm.stopBroadcast();
    }
}