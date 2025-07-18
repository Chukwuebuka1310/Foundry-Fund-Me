// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    int256 public number;

    function setNumber(int256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    function subtract() public {
        number--;
    }
}
