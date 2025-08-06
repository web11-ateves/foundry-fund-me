//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

// What can we do to work with addresses outside our system?
// 1. Unit - Testing a specific part of our code
// 2. Integration - Testing how our code works with other parts of our code
// 3. Forked - Testing our code on a simulated real environment (chain forks)
// 4. Staging - Testing our code in a real environment that is not prod

// Foundry Cheatcodes Reference:
// https://getfoundry.sh/reference/cheatcodes/overview

// Proposed Solidity best practice: Organize your unit tests by using a state tree.
// https://x.com/PaulRBerg/status/1624763320539525121

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1e9; // 1 gwei

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether); // another Foundry cheatcode to give USER 10 ETH
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18); // 5e18
    }

    function testOwnerIsMsgSender() public view {
        // console.log(fundMe.i_owner()); // owner is the deployer of the contract
        // console.log(address(this)); // this is the test contract (FundMeTest contract)
        // console.log(msg.sender); // msg.sender is the account that called the function (us or the DeployFundMe contract)
        // see prank cheatcode in Foundry: https://getfoundry.sh/reference/cheatcodes/prank
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // Forked test (#3):
    // forge test -vvv --fork-url $SEPOLIA_RPC_URL
    // forge coverage --fork-url $SEPOLIA_RPC_URL
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //the next line should revert
        fundMe.fund(); // send 0 ETH
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // set the next transaction to be from USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 fundedAmount = fundMe.getAddressToAmountFunded(USER);
        assertEq(fundedAmount, SEND_VALUE);

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // 1. Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // should have spent gas?

        // 3. Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        ); // what about gas? Since we are working with Anvil, the gas price defaults to zero, so we don't have to worry about it here.
    }

    function testWithDrawWithMultipleFunders() public funded {
        // Here we will use gas price to simulate a real environment

        // 1. Arrange
        uint256 numberOfFunders = 10;
        uint256 startingFunderIndex = 1;
        for (uint256 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(address(uint160(i + 1)));
            // vm.deal(address(uint160(i + 1)), SEND_VALUE);
            hoax(address(uint160(i))); // does both prank and deal
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act
        uint256 gasStart = gasleft(); // `gasleft` is a built-in function in Solidity that returns the amount of gas left in the current tx call.
        vm.txGasPrice(GAS_PRICE);

        // vm.prank(fundMe.getOwner());
        // fundMe.withdraw();
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // another built-in variable in Solidity.
        console.log("Gas used: %s", gasUsed);

        // 3. Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithDrawWithMultipleFundersCheaper() public funded {
        // `cheaperWithdraw` is aprox. 900 gas cheaper than `withdraw`
        // 1. Arrange
        uint256 numberOfFunders = 10;
        uint256 startingFunderIndex = 1;
        for (uint256 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(address(uint160(i + 1)));
            // vm.deal(address(uint160(i + 1)), SEND_VALUE);
            hoax(address(uint160(i))); // does both prank and deal
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act
        uint256 gasStart = gasleft(); // `gasleft` is a built-in function in Solidity that returns the amount of gas left in the current tx call.
        vm.txGasPrice(GAS_PRICE);

        // vm.prank(fundMe.getOwner());
        // fundMe.withdraw();
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // another built-in variable in Solidity.
        console.log("Gas used: %s", gasUsed);

        // 3. Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
}
