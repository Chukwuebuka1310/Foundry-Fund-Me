//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionTest is Test{

    FundMe fundMe;

    address USER = makeAddr("user");

    uint constant SEND_VALUE = 0.1 ether;
    uint constant STARTING_BALANCE = 10  ether;
    uint GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }


    function testUserCanFundInteractions() public {

        //The imported contract is used to create a new instance of FundFundMe contract
        FundFundMe fundFundMe = new FundFundMe();

        //After the creation, the new intance(fundFundMe) is used to call the fundFundMe function.
        fundFundMe.fundFundMe(address(fundMe));
        
        //The imported contract is used to create a new instance of WithdrawFundMe contract
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        
        //After the creation, the new intance(withdrawFundMe) is used to call the withdrawFundMe function.
        withdrawFundMe.withdrawFundMe(address(fundMe));


        assert(address(fundMe).balance == 0);
    }
}