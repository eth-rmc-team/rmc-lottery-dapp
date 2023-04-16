// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//Contract managing lottery games
//Set the period (in chase or in a cycle)
//Set the rewards et permit their claims

contract LotteryManager {
    
    address private owner;
    address public addrLotteryGame;
    address public addrFeeManager;
    address public addrMarketPlace;
    address public addrTicketManager;
    
    uint nbOfTicketsSalable;
    
    uint lotteryId;

    //Amount of RMC reward for minting NFTs
    uint tokenBuyReward; 

    //Booleans parametring the game status
    enum Period { Game, Claim, Chase, End }
    Period public period;

    uint ticketsFusionClaimedGains;

    //Time settings for a game period
    uint totalDay;
    
    constructor() {
        owner = msg.sender;

        lotteryId = 0;
        totalDay = 5;

        period = Period.Game;

        ticketsFusionClaimedGains = 0;
    }

    //todo: mettre à terme une whiteList, plutot qu'une adresse unique
    modifier onlyOwner {
        require(msg.sender == owner, "WARNING :: only the owner can have access");
        _;
    }

    modifier onlyLotteryGameContract {
        require(msg.sender == addrLotteryGame, "WARNING :: only the LotteryGame contract can have access");
        _;
    }

    //Function setting  the address of the lottery game contract
    function setAddrLotteryGameContract(address _addrLotteryGame) public onlyOwner {
        addrLotteryGame = _addrLotteryGame;
    }

    //Function to set the addres of Marketplace contract
    function setAddrMarketPlace(address _addrMarketPlace) public onlyOwner {
        addrMarketPlace = _addrMarketPlace;
    }

    function setAddrTicketManager(address _addrTicketManager) public onlyOwner {
        addrTicketManager = _addrTicketManager;
    }

    function setAddrFeeManager(address _addrFeeManager) public onlyOwner {
        addrFeeManager = _addrFeeManager;
    }

    //Prévoir fonction récupérant les nft encore en jeu durant le cycle courrant (dans TicketsManager)

    //Function setting the number of tickets salable for a game
    function setNbOfTicketsSalable(uint _nbOfTicketsSalable) public onlyOwner {
        nbOfTicketsSalable = _nbOfTicketsSalable;
    }

    //Function setting the total day number for a game
    function setTotalDay(uint _totalDay) public onlyOwner {
        totalDay = _totalDay;
    }

    //Function setting the lottery id
    function setLotteryId (uint _id) external onlyLotteryGameContract {
        lotteryId = _id;
    }

    //Function setting the period
    function setPeriod(Period _period) external onlyLotteryGameContract {
        period = _period;
    }

    function getTotalDay() external view returns(uint _totalDay) {
        return (totalDay);
    }

    function getTicketsSalable() external view returns(uint _nbOfTicketsSalable) {
        return (nbOfTicketsSalable);
    }

    function getLotteryId() external view returns(uint _lotteryId) {
        return (lotteryId);
    }
                
}
