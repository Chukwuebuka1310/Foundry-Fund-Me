//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

//Custom Error(Gas Efficiency)
error FundMe__NotOwner();

contract FundMe{

    

    //Using the library in the contract
    using PriceConverter for uint256;

    //For the aspect of gas saving efficiciency, we use two key words
    //1. Constant - Used when declaration and assignment happen on the same line and letter conversion for
    // variable with the constsnt key word is uppercase
    //2. Immutable - Used when delaration and assignnmet happe differently and it letter convention is i_

    //Set Minimum value to be sent in USD
    //But seeing that its a smart contract and it workas on blockchin the USD is not actually adopted here
    //rather the use of cryptocurrencies are used
    //Therefore, wee need some kind of offchain decentralized network to get the usd adopted here, thet where
    //Oracles steps in (Chainlink Oracle)
    uint256 public constant MINIMUM_USD = 5e18;

    //Array to store all funders(users) of the contract
    address[] public funders;

    //Mapping to check the amount funded by using the address of the funder
    mapping(address funder => uint256 amountFunded) public funderToAmountFunded;

    address public immutable i_owner;
    AggregatorV3Interface s_priceFeed;
    
    //Constructor run immediately the contract is deployed.
    constructor(address priceFeed){

        //Assing the sender of the contract to the owner
        //(Cause he/she is actually the owner since they diployed it)
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    //Fund the contract from users
    //Payable keyword ensures that the function can take a sort of money
    function Fund() public payable {

        //Sending money to a contract is possible using the msg.value snippet
        //Require keyword ensures that the conditions(First arg) in them is obeyed, 
        //if not, it reverts with a msg(2nd Arg) is send to the contract owner

        // require(getConversionRate(msg.value) >= minimumUsd, "You didn't send enough ETH");
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You didn't send enough ETH");

        //Revert means stopping the transaction immediately and undo all changes.
        //During this process the expected gas to be spent is sent back to the deployers acct
        //but not all the gas, if the function has a computational logic taht has passed before revert
        //happens than the amount of the successful computational logic is removed from the expected gas
        //while the remaining is sent back

        funders.push(msg.sender);
        funderToAmountFunded[msg.sender] = funderToAmountFunded[msg.sender] + msg.value;
        

    }

    //Withdraw contract funded by users

    function Withdraw() public OnlyOwner{

        //Ensures that the address withdrwing is the owner of the contract
        // require(msg.sender == owner, "You are not the owner of the contract");

        //For Loop
        //for(/* startingPoint; endingPoint; sequenceOfMovement*/)
        for(uint256 funderIndex = 0; funderIndex > funders.length; funderIndex++){
            address funder = funders[funderIndex];
            funderToAmountFunded[funder] = 0;
        }

        //After the loop of all address, we reset the funders array
        //We use the keyword new foe this purpose, just like we did when getting a new address for 
        //SimpleStorage contract
        funders = new address[](0);


        //Withdrawing the funds from users
        //We can withdraw using 3 ways

        //1. transfer(throws an error if transferfails)
        // payable(msg.sender).transfer(address(this).balance);

        //2. send(returns a boolean if transfer fails)
        // (bool sendSuccess) = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");

        //3. call(most used)(returns a boolean and a bytes(dataReturned)
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    function getVersion() public view returns(uint256){
        return s_priceFeed.version();
    }

    //Modifier in Solidity is like a rule or condition wrapper for a function. The enable us with DRY code
    modifier OnlyOwner{
        // require(msg.sender == i_owner, "You are not the owner of the contract");//Cost compared to next line
        if(msg.sender != i_owner){revert FundMe__NotOwner();}
        _; //After the check of the above line do the rest of what the code demands.
    }

    //In cases where money is sunt to thie contract but not by call the fund function
    receive() external payable { 
        Fund();
    }

    fallback() external payable {
        Fund();
    }

    
}