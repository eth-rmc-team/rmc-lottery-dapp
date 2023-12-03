// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Librairies/LotteryDef.sol";

interface ILotteryGame {
    function getLotteryId() external view returns (uint8);

    function getCurrentPeriod() external view returns (LotteryDef.Period);

    function getCurrentStep() external view returns (uint256);

    function getWinningCombination() external view returns (uint256);

    function getIsCycleRunning() external view returns (bool);
}
