// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRMCLotteryInfo {
    
    // Enum from LotteryManager.sol
    enum Period { Game, Claim, Chase, End }

    //Functions from LotteryManager.sol
    
    function getTotalDay() external view returns(uint _totalDay);
    
    function getTicketsSalable() external view returns(uint _nbOfTicketsSalable);
    
    function getLotteryId() external view returns(uint _lotteryId);

    //Function from LotteryGame.sol
    function getPeriod () external view returns(Period _period);


}