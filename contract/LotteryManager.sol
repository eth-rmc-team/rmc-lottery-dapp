// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

//Contract managing lottery games
//Set the period (in chase or in a cycle)
//Set the rewards et permit their claims

contract LotteryManager is Ownable {
    
    address public addrLottery;
    address public addrFusionManager;
    address public addrMarketPlace;
    
    uint nbOfTicketsSalable;
    uint nbTicketsSold;

    uint lotteryId;

    //To be divided by 100 in the appropriated compute function
    //Every rewards are claim WHEN a game period is done (triggered by the winner claiming his gain
    //or the protocole after a delay).
    //It remains claimable UNTIL a new cycle begins.
    //NFT merged during chase period can't received rewards from previous cycles.

    uint shareOfPricePoolForWinner;
    uint shareOfPricePoolForGold;
    uint shareOfPricePoolForSuperGold;
    uint shareOfPricePoolForMythic;
    uint shareOfPricePoolForPlatin;
    uint shareOfPricePoolForProtocol;

    //Amount of RMC reward for minting NFTs
    uint tokenBuyReward; 
    uint feeByTrade;

    //Booleans parametring the game status
    bool chasePeriod;
    bool gamePeriod;
    bool winnerClaimed;

    uint ticketsFusionClaimedGains;

    //Time settings for a game period
    uint currentDay;
    uint totalDay;

    //Each NFT address is writen into claimedNftAddress and bool = true by default
    //When claimdReward() is triggered, bool = false and the Nft can't claim rewards again
    //When a new cycle is done, and claim period is open, all bool = true
    mapping (address => bool) public claimedNftAddress;
    
    constructor() {
        nbTicketsSold = 0;
        lotteryId = 0;
        totalDay = 5;
        currentDay = 0;

        shareOfPricePoolForWinner = 33;

        shareOfPricePoolForGold = 7;
        shareOfPricePoolForSuperGold = 7;
        shareOfPricePoolForPlatin = 5;
        shareOfPricePoolForMythic = 3;
        shareOfPricePoolForProtocol = 33;

        feeByTrade = 5;

        chasePeriod = false;
        gamePeriod = true;
        ticketsFusionClaimedGains = 0;
    }

    function setAddrLotteryContract(address _addrLottery) public onlyOwner {
        addrLottery = _addrLottery;
    }

    //Function getter returnning the status of chasePeriod and gamePeriod
    //To use in FusionManager.sol
    function getPeriod () public view returns(bool _chasePeriod, bool _gamePeriod, bool _winnerClaimed){
        return (chasePeriod, gamePeriod, winnerClaimed);
    } 

    //Prévoir fonction récupérant les nft encore en jeu durant le cycle courrant (dans TicketsManager)

    //Function setting the share of the winner
    function setShareOfPricePoolForWinner (uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForProtocol + 
        shareOfPricePoolForPlatin + 
        shareOfPricePoolForMythic +
        shareOfPricePoolForSuperGold +
        shareOfPricePoolForGold < 100, "WARNING :: the total share must be less than 100");

        require(_share > 15 && _share < 51, "WARNING :: the share must be between 15 and 51");
        shareOfPricePoolForWinner = _share;
    }

    //Same function but for the protocol
    function setShareOfPricePoolForProtocol(uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForWinner + 
        shareOfPricePoolForPlatin + 
        shareOfPricePoolForMythic +
        shareOfPricePoolForSuperGold +
        shareOfPricePoolForGold < 100, "WARNING :: the total share must be less than 100");
        
        require(_share > 15 && _share < 40, "WARNING :: the share must be between 15 and 40");
        shareOfPricePoolForProtocol = _share;
    }

    //Same function but for the Gold and SuperGold
    function setShareOfPricePoolForSuperGold(uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForWinner + 
        shareOfPricePoolForGold   +
        shareOfPricePoolForPlatin + 
        shareOfPricePoolForMythic +
        shareOfPricePoolForProtocol < 100, "WARNING :: the total share must be less than 100");
        
        require(_share > 5 && _share < 10, "WARNING :: the share must be between 5 and 10");
        shareOfPricePoolForSuperGold = _share;
    }

    //Same function but for the Gold and SuperGold
    function setShareOfPricePoolForGold(uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForWinner + 
        shareOfPricePoolForPlatin + 
        shareOfPricePoolForSuperGold +
        shareOfPricePoolForMythic +
        shareOfPricePoolForProtocol < 100, "WARNING :: the total share must be less than 100");
        
        require(_share > 5 && _share < 10, "WARNING :: the share must be between 5 and 10");
        shareOfPricePoolForGold = _share;
    }

    //Same function but for the Mythic
    function setShareOfPricePoolForMythic(uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForWinner + 
        shareOfPricePoolForPlatin + 
        shareOfPricePoolForGold +
        shareOfPricePoolForSuperGold +
        shareOfPricePoolForProtocol < 100, "WARNING :: the total share must be less than 100");
        
        require(_share > 1 && _share < 5, "WARNING :: the share must be between 2 and 5");
        shareOfPricePoolForMythic = _share;
    }

    //Same function but for the Platin
    function setShareOfPricePoolForPlatin(uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForWinner + 
        shareOfPricePoolForMythic + 
        shareOfPricePoolForGold +
        shareOfPricePoolForSuperGold +
        shareOfPricePoolForProtocol < 100, "WARNING :: the total share must be less than 100");
        
        require(_share > 1 && _share < 7, "WARNING :: the share must be between 1 and 5");
        shareOfPricePoolForPlatin = _share;
    }

    //Function to set the addres of Marketplace contract
    function setAddrMarketPlace(address _addrMarketPlace) public onlyOwner {
        addrMarketPlace = _addrMarketPlace;
    }

    //Function to set fee paying on every trade
    function setFeeByTrades(uint _fee) public onlyOwner {
        require(_fee > 1 && _fee < 10, "WARNING :: Fee must be between 1 and 10");
        feeByTrade = _fee;
    }

    //Fucntion getter returning the fee to apply on each trade
    function getFeeByTrades() public view returns(uint) {
        return feeByTrade;
    }

    //Function get for the different shares
    function getShareOfPricePoolFor() public view returns(
        uint _shareProt, 
        uint _shareWinner, 
        uint shareG, 
        uint shareSG, 
        uint _shareMyth, 
        uint _sharePlat
    ) {
        return (
            shareOfPricePoolForProtocol, 
            shareOfPricePoolForWinner, 
            shareOfPricePoolForGold, 
            shareOfPricePoolForSuperGold, 
            shareOfPricePoolForMythic, 
            shareOfPricePoolForPlatin
        );
    }
}