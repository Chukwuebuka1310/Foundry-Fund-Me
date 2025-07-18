//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

    FundMe fundMe;

    function setUp() external{
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public{
        uint minimumUsd = fundMe.MINIMUM_USD();
        console.log(minimumUsd);
        assertEq(minimumUsd, 5e18);
    }

    function testOwnerIsMsgSender() public{

        assertEq(fundMe.i_owner(), msg.sender);//Won't work cause msg.sender refers to the of the FundMeTest contract not the FundMe contract. Instead use the following below.

        // assertEq(fundMe.i_owner(), address(this)); //address(this) refers to the FundMeTest contract that called the FundMe contract.

    }

    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

}