//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{

    uint constant SEND_VALUE = 0.01 ether;

    function run() external {

        // Use the DevOpsTools library to get the address of the most recently deployed FundMe contract
        // for the current network (identified by block.chainid).
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        // Call the helper function fundFundMe() with that address.
        fundFundMe(mostRecentlyDeployed);
    }


    // This function actually performs the funding.
    // It takes the deployed FundMe contract address as input.
    function fundFundMe(address mostRecentlyDeployed) public {

        // Start a broadcast — this means Foundry will send real transactions
        // to the network from your private key.
        vm.startBroadcast();

        // Call the FundMe contract's fund() function, sending SEND_VALUE of ETH.
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();

        // Stop broadcasting — this ends the broadcast session.
        vm.stopBroadcast();
        
        // Log to the console that funding happened, showing the ETH amount.
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    
}

contract WithdrawFundMe is Script{
    uint constant SEND_VALUE = 0.01 ether;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }

    // This function actually performs the withdrawing.
    // It takes the deployed FundMe contract address as input.
    function withdrawFundMe(address mostRecentlyDeployed) public {

        // Start a broadcast — this means Foundry will send real transactions
        // to the network from your private key.
        vm.startBroadcast();

         // Call the FundMe contract's withdraw() function, transfers the ETH in the FundMe contract.
        FundMe(payable(mostRecentlyDeployed)).withdraw();

        // Stop a broadcast
        vm.stopBroadcast();
        
        console.log("Withdraw FundMe balance");
    }

    

}