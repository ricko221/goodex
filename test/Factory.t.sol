// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/Factory.sol";
import "../src/Exchange.sol";
import "../src/ERC20.sol";

contract FactoryTest is Test {
    Factory public factory;
    MyToken public token;

    address tokenOwner = makeAddr("owner");

    function setUp() public {
        token = new MyToken(tokenOwner);
        factory = new Factory();
    }

    function testCreateNewExchange() public {
        address tokenExchangeAddress = factory.createNewExchange(address(token));
        assertEq(factory.getExchange(address(token)), tokenExchangeAddress, "Exchange address does not match");
        assertTrue(tokenExchangeAddress != address(0), "Exchange address should not be 0x0");
    }

    function testFailCreateExchangeForExistingToken() public {
        factory.createNewExchange(address(token));
        factory.createNewExchange(address(token));
    }
}