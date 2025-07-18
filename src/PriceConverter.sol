//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//Library are special kind of smart contract that holds reusable code, like helper functions, 
//which don’t store state on their own and its function visibility is either internal or public.
library PriceConverter{

    //Using the decentralized oracle network(Chainlink) to get info about USD
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256){

        //Now I have imported the interface(AggregatorV3Interface), I can get the priceFeed of USD in 
        //relation to our native token ETH, by the 
        //1. Address - 0x694AA1769357215DE4FAC081bf1f309aDC325306 (gotten from Chainlink)
        //2. ABI - Since we imported the interface into the Fund Contract
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData(); // i.e 2000000000000(without decimals but we know its decimal is 8)
        
        //Expected value should be in uint256 but the price is in int256, then we typecast abd then convert
        //the price to the recognized 1e18 = 1000000000000000000 Wei.
        return uint256(price * 1e10);

    }

    //Converting the value send by user to USD
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
        ) internal view returns(uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18;
        return ethAmountInUsd;
    }

    // function getVersion() internal view returns(uint256){
    //     return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    // }

}