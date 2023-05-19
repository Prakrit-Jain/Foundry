// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20Factory.sol";
import "../src/ERC20Token.sol";
import "forge-std/console.sol";

contract Factory is Test {
    ERC20Factory public factory;
    ERC20Token public token;

    event Cloned(address, address);
    event ModeChanged(uint256 from, uint256 to);

    /// This setUp function run before each test, which deploys token contract as the implementation
    /// contract and factory contract passing tokenContract address in constructor.
    function setUp() public {
        token = new ERC20Token();
        factory = new ERC20Factory(address(token));
    }

    /// This check wheater minimal Proxy clone is successfully created
    /// Also checks for the Cloned Event emiited.
    function testDeployment() public {
        assertNotEq(factory.createERC20Proxy("MY-Token", "MKt", 10000), address(0));
        vm.startPrank(address(1));
        vm.expectEmit(true, false, false, false);
        emit Cloned(address(1), address(0));
        factory.createERC20Proxy("MY-Token", "MKt", 10000);
    }

    /// This tests the checkFeeRate functionality of the contract, Also the
    /// Mode changed Functiionality ehich emits event Modechanged.
    function testFeeRate() public {
        assertEq(factory.checkFeeRate(), 3);
        vm.expectEmit(true, true, false, false);
        emit ModeChanged(3, 2);
        factory.changeFeeMode();
        assertEq(factory.checkFeeRate(), 2);
    }

    ///This tests the access control functionality of the contract. Only the
    /// owner can change the feeMode, expects revert on another address trying to changeMode.
    function testAccessControl() public {
        vm.prank(address(1));
        vm.expectRevert(bytes("Not a owner"));
        factory.changeFeeMode();
    }

    ///This tests for balances of different addresses are correct according to
    ///totalSupply and Fees deduction. Also checks for the event emmited for Cloned.
    function testCreateERC20Proxy() external {
        vm.startPrank(address(1));
        vm.expectEmit(true, false, false, false);
        emit Cloned(address(1), address(0));
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
