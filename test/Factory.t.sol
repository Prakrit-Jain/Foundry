// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20Factory.sol";
import "../src/ERC20Token.sol";
import "forge-std/console.sol";

contract Factory is Test {
    ERC20Factory public factory;
    ERC20Token public token;

    function setUp() public {
        token = new ERC20Token();
        factory = new ERC20Factory(address(token));
    }

    function testDeployment() public {
        assertNotEq(factory.createERC20Proxy("MY-Token", "MKt", 10000), address(0));
    }

    function testFeeRate() public {
        assertEq(factory.checkFeeRate(), 3);
        factory.changeFeeMode();
        assertEq(factory.checkFeeRate(), 2);
    }

    function testAccessControl() public {
        vm.prank(address(1));
        vm.expectRevert(bytes("Not a owner"));
        factory.changeFeeMode();
    }

    function testCreateERC20Proxy() external {
        vm.startPrank(address(1));
        address minimalClone = factory.createERC20Proxy("MY-Token", "MKt", 10000);
        console.logAddress(factory._owner());
        ERC20Token instance = ERC20Token(minimalClone);
        assertEq(instance.name(), "MY-Token");
        assertEq(instance.symbol(), "MKt");
        console.log(instance.balanceOf(minimalClone));
        assertEq(instance.balanceOf(address(1)), 10000 - (10000 * 3) / (10 ** 4));
        vm.stopPrank();
    }
}
