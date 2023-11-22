// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Librairies/LotteryDef.sol";

interface ILotteryGame
{ 

    function getLotteryId() external view returns(uint8);
}