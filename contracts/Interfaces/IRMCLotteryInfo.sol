// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IRMCLotteryInfo {
    
    //From LotteryGame.sol
    enum Period { GAME, CLAIM, CHASE, END }
    
    function getTotalDay() external view returns(uint _totalDay);
    
    function getTicketsSalable() external view returns(uint _nbOfTicketsSalable);
    
    function getPeriod () external view returns(Period _period);

    function getLotteryId() external view returns(uint _lotteryId);



}