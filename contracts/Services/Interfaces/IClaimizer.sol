// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Librairies/LotteryDef.sol";

interface IClaimizer {
    function checkWinner(
        uint256 _winningCombination,
        uint256 _prizepool,
        bool _isWinnerClaimed,
        address caller,
        LotteryDef.Period _currentPeriod
    ) external returns (uint256);

    function checkGoldTicket(
        uint256 _winningCombination,
        uint256 tokenId,
        uint256 balanceOfGold,
        uint16 _mask,
        uint8 lotteryId,
        address caller,
        LotteryDef.Period _currentPeriod
    ) external;

    function checkAdvantages(
        uint256 _prizepool,
        address caller,
        LotteryDef.Period _currentPeriod
    ) external returns (uint256);

    function checkProtocol(
        uint256 _prizepool,
        LotteryDef.Period _currentPeriod
    ) external returns (uint256);
}
