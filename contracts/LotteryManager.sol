// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";


//Contract managing lottery games
//Set the period (in chase or in a cycle)
//Set the rewards et permit their claims

contract LotteryManager is Ownable
{
    //Booleans parametring the game status
    enum Period { GAME, CLAIM, CHASE, END }

    address public addrNormalTicket;
    address public addrLotteryGame;
    address public addrFeeManager;
    address public addrMarketPlace;
    address public addrTicketInformationController;
    
    uint public pricepool;
    uint public mintPrice;

    //Amount of RMC reward for minting NFTs
    uint tokenBuyReward; 
    uint ticketsFusionClaimedGains;

    Period public period;
    uint8 lotteryId;
    //Time settings for a game period
    uint8 totalDay;
    uint16 nbOfTicketsSalable;
    bool public cycleStarted;
    bool public winnerClaimed;
    
    constructor() 
    {
        lotteryId = 0;
        totalDay = 3;

        period = Period.GAME;
        mintPrice = 2500000000000000000 wei;

        ticketsFusionClaimedGains = 0;
        nbOfTicketsSalable = 27; //todo: a changer, pour l'instant on met pour les tests
    }

    modifier onlyLotteryGameContract
    {
        require(
            msg.sender == addrLotteryGame, 
            "WARNING :: only the LotteryGame contract can have access"
        );
        _;
    }

    //Function setting  the address of the lottery game contract
    function setAddrLotteryGameContract(address _addrLotteryGame) public onlyOwner 
    {
        addrLotteryGame = _addrLotteryGame;
    }

    //Function to set the addres of Marketplace contract
    function setAddrMarketPlace(address _addrMarketPlace) public onlyOwner 
    {
        addrMarketPlace = _addrMarketPlace;
    }

    function setAddrTicketInformationController(address _addrTicketInformationController) 
    public onlyOwner
    {
        addrTicketInformationController = _addrTicketInformationController;
    }

    function setAddrFeeManager(address _addrFeeManager) public onlyOwner 
    {
        addrFeeManager = _addrFeeManager;
    }

    function setAddrNormalTicket(address _addrNormalTicket) public onlyOwner
    {
        addrNormalTicket = _addrNormalTicket;
    }

    //Function setting the price for a mint
    function setMintPrice(uint _price) public onlyOwner 
    {
        mintPrice = _price; //todo: voir pour prend en compte les float (import math, mul etc)
    }

    //Prévoir fonction récupérant les nft encore en jeu durant le cycle courrant (dans TicketsManager)

    //Function setting the number of tickets salable for a game
    function setNbOfTicketsSalable(uint16 _nbOfTicketsSalable) public onlyOwner 
    {
        nbOfTicketsSalable = _nbOfTicketsSalable;
    }

    //Function setting the total day number for a game
    function setTotalDay(uint8 _totalDay) public onlyOwner 
    {
        totalDay = _totalDay;
    }

    function getTotalDay() external view returns(uint8 _totalDay) 
    {
        return (totalDay);
    }

    //Function getter returning the price for a mint
    function getMintPrice() external view returns(uint)
    {
        return mintPrice;
    }
    
    function getTicketsSalable() external view returns(uint16 _nbOfTicketsSalable) 
    {
        return (nbOfTicketsSalable);
    }

    //Function getter returnning the status of chasePeriod and gamePeriod
    //To use in FusionManager.sol
    function getPeriod() external view returns(Period) 
    {
        return (period);
    } 

    function getLotteryId() external view returns(uint8 _lotteryId) 
    {
        return (lotteryId);
    }
}
