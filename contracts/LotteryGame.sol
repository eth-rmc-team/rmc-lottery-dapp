// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './Interfaces/IRMCTicketInfo.sol';
import './Interfaces/IRMCFeeInfo.sol';
import './Interfaces/IRMCMinter.sol';
import './LotteryManager.sol';

//Principal contract of the lottery game

contract LotteryGame is LotteryManager {

    address private owner;

    address private _addrN;
    address private _addrG;
    address private _addrSG;
    address private _addrM;
    address private _addrP;
    
    address payable winner;

    uint public nbTicketsSold;
    
    uint private start;
    uint private currentDay;

    uint private caracNftGagnant;

    event Received(address, uint);

    //Constructor
    constructor() payable {
        owner = msg.sender;

        nbTicketsSold = 0;
        cycleStarted = false;

        pricepool = address(this).balance;
        start = 0;
        currentDay = 0;

    }

    //Function to allow this contract to reveive value from other contracts
    receive() external payable  {
        emit Received(msg.sender, msg.value);
    }

    //Function settin a new lottery game
    function NewCycle() external onlyOwner {
        require(period == Period.End, "ERROR :: You can't init a new cycle during this period");
        period = Period.Game;
        cycleStarted == true;
        currentDay = 0;
        lotteryId += 1;
        caracNftGagnant = lotteryId * 100000;
        winnerClaimed = false;
        
        IRMCFeeInfo(addrFeeManager).resetClaimStatus();
    }

    //Function for tickets purchase and minting
    function buyTicket(uint amount) payable external{
        uint _price = amount * mintPrice * (10 ** 18);

        require(msg.value == _price, "ERROR :: You must pay the right amount of RMC");
        require(amount <= nbOfTicketsSalable - nbTicketsSold, "WARNING :: Not enough tickets left for your order");
        nbTicketsSold += amount;
        require(period == Period.Game , "ERROR :: You can't buy tickets during this period");
        require(cycleStarted == true, "ERROR :: You can't buy tickets while a game is running");
        
        payable(address(this)).transfer(msg.value);

        if(amount >= 1){
            for (uint i = 1; i <= amount; i++) {
                IRMCMinter(_addrN).createTicket("todo", msg.sender, IRMCTicketInfo.NftType.Normal);
            }
        }

        if (cycleStarted == false && nbTicketsSold == nbOfTicketsSalable) {
            cycleStarted = true;
            startLottery();
        }

    }

    //Function called when all the tickets have been sold, starting the game
    function startLottery() private {
        require(cycleStarted == true, "ERROR :: A game can't start if all tickets haven't been sold");
        require(period == Period.Game, "ERROR :: You can't start a game during this period");
        
        pricepool = nbTicketsSold * mintPrice * (10 ** 17);

        totalDay = totalDay;

        start = block.timestamp * 1 days;
        currentDay = start;

    }

    //Function callable by anyone every 24h to reveal one caracteristic of the winning NFT
    function GoToNnextDay() public {
        require(period == Period.Game, "ERROR :: You can't go to the next day if not in a running game");
        require(currentDay < totalDay + start + 1 days, "ERROR :: You can't go to the next day if the game is over");
        require(block.timestamp * 1 days > currentDay + 1 days, "WARNING :: You can't go to the next day if it's not the right time");

        if(currentDay < totalDay + start) {
            currentDay = block.timestamp + 1 days;
            //TODO: appel ChainLink
            //ajout le nombre alétoire dans le tableau des caractéristiques
            
            //Exemple de la construction de caracNftGagnant
            uint lsb = 1;
            uint nbCL;
            caracNftGagnant += nbCL * lsb;
            lsb *= 10;
        }
        else {
            endLottery();
        }
        
    }

    //Function called when all the caracteristics have been revealed (the winning NFT is known)
    function endLottery() private {
        require(period == Period.Claim, "ERROR :: You can't end the game if it's not over");
        require(currentDay >= totalDay + start, "ERROR :: You can't end the game if it's not over");
        require(cycleStarted == true, "ERROR :: You can't end the game if it's not started");
        
        period = Period.Claim;
        cycleStarted = false;
        currentDay = totalDay;
        
        //Claim all the fees from Marketplace
        IRMCFeeInfo(addrFeeManager).claimFees();

    }

    //Function to claim the price pool for the winner
    function claimRewardForWinner() external {
        require(period == Period.Claim, "ERROR :: You can't claim the winner if the game is not over");
        require(cycleStarted == false, "ERROR :: You can't claim the winner if the game is not over");
        require(currentDay == totalDay, "ERROR :: You can't claim the winner if the game is not over");
        require(winnerClaimed == false, "ERROR :: You can't claim twice the price pool");
       
        uint gainWinner = IRMCFeeInfo(addrFeeManager).computeGainForWinner(caracNftGagnant, msg.sender); 
        IRMCMinter(_addrN).burn(caracNftGagnant);

        winnerClaimed = true;
        winner.transfer(gainWinner * 1 ether);

    }

    //Function to claim rewards for "Special Tickets" holders
    function claimRewardForAll() external {
        require(period == Period.Claim, "ERROR :: You can't claim the rewards if the game is not over");
        uint _totalGain;

        _totalGain = IRMCFeeInfo(addrFeeManager).computeGainForAdvantages(msg.sender);

        require(_totalGain > 0, "ERROR :: You don't have any rewards to claim");
        payable(msg.sender).transfer(_totalGain * 1 ether);

    }

    //Function called by owner ending the current cycle of the game
    //Used to mark the end of the game and to allow the owner to start a new one
    function endCycle() external onlyOwner {
        period = Period.End;
    }

}