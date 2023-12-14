// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IRandomizer {
    function getRandomNumber() external returns (bytes32 requestId);

    function setRandomDigit(uint256 randomNumber) external;
}
