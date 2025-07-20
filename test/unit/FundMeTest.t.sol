//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

    FundMe fundMe;

    //Fake address simulation
    address USER = makeAddr("user");

    uint constant SEND_VALUE = 0.1 ether;
    uint constant STARTING_BALANCE = 10  ether;
    uint GAS_PRICE = 1;

    modifier funded{
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external{
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        uint minimumUsd = fundMe.MINIMUM_USD();
        console.log(minimumUsd);
        assertEq(minimumUsd, 5e18);
    }

    function testOwnerIsMsgSender() public {

        assertEq(fundMe.getOwner(), msg.sender);//Won't work cause msg.sender refers to the of the FundMeTest contract not the FundMe contract. Instead use the following below.

        // assertEq(fundMe.i_owner(), address(this)); //address(this) refers to the FundMeTest contract that called the FundMe contract.

    }

    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testEthAmountSentIsEnough() public{
        vm.expectRevert(); //This literally tells the next line to fail and for this specific test if the next line fail, then the test is passed.
        fundMe.fund();
    }


    function testFundUpdatesFundedDataStructure() public {

        //Fake address
        vm.prank(USER); //The next Transaction should be called by USER

        fundMe.fund{value: SEND_VALUE}();

        //For ths sake of confusion between address(this) / msg.sender, vm.pank is used to simulate a fake address
        uint amountFunded = fundMe.getAmountFunded(USER); 
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public {

        //Assign a new fake funder, and the next fuction call will be done by theis fake address/Funder
        vm.prank(USER);

        //Function to be called by the fake caller
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);
        
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function tesstWithdrawForASingleFunder() public funded{
        //Arrange
        uint startingOwnerBalance = fundMe.getOwner().balance;//Get balance of owner(in his wallet) before withdrawing
        uint startingFundMeBalance = address(fundMe).balance;//Get contract balance before withdrawing

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(startingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);

    } 

    function testWithdrawFromMutipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            //Hoax does vm.prank and vm.deal together
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        //Act

        // uint gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint gasEnd = gasleft();
        // uint gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, fundMe.getOwner().balance);
        
    }

    function testCheapWithdrawalForMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 funderIndex = 1;

        for(uint160 i = funderIndex; i < funderIndex; i++){
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint startingOwnersBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingOwnersBalance + startingFundMeBalance, fundMe.getOwner().balance);
    }

}