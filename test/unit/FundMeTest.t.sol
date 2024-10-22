// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 public constant MINIMUM_USD = 5e18;
    uint256 private constant VERSION_TEST_NUM = 4;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;

    FundMe fundMe;
    function setUp() external {
    //  fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();    

        vm.deal(USER, STARTING_BALANCE);    
    }

    function testMinimumDollarIsFive() public view {
        assert(fundMe.MINIMUM_USD() == MINIMUM_USD);
    }

    function testOwnerIsMsgSender() public view  {
        assert(fundMe.getOwner() == msg.sender);
    }

    function testPriceVersionIsCorrect() public view {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, VERSION_TEST_NUM);
    }


    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();

        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assert(amountFunded == SEND_VALUE);
    }

    function testAddFunderToArrayOfFunders() public funded {
        
        address funder = fundMe.getFunder(0);

        assert(funder == USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        
        vm.prank(USER);
        vm.expectRevert();
        
        fundMe.withdraw();

    }

    function testWithdrawalWithSingleFunder() public funded {
        // Arrange
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFunMeBalance = address(fundMe).balance;

        assert(endingFunMeBalance == 0);
        assertEq(startingFundMeBalance + ownerStartingBalance, endingOwnerBalance);
    }

    function testWithdrawalFromMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;


        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            // arrange

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        // Act

        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + ownerStartingBalance == fundMe.getOwner().balance);
    }

    function testWithdrawalFromMultipleFundersCheaper() public {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;


        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            // arrange

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        // Act

        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + ownerStartingBalance == fundMe.getOwner().balance);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    } 
  }