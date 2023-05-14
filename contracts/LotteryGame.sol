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

    bool private startLotteryFunc;
    bool private endLotteryFunc;

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

    //Function setting a new lottery game
    function NewCycle() external onlyOwner {
        //Check that the previous game is over
        require(period == Period.End, "ERROR :: You can't init a new cycle during this period");
        //Resset all the necessary variables
        period = Period.Game;
        cycleStarted == true;
        startLotteryFunc = false;
        endLotteryFunc = false;
        currentDay = 0;
        lotteryId += 1;
        caracNftGagnant = lotteryId * 100000;
        winnerClaimed = false;
        
        IRMCFeeInfo(addrFeeManager).resetClaimStatus();
    }

    //Function for tickets purchase and minting
    function buyTicket(uint amount) payable external{
        //Calculate the price for the given amount of NFTs to buy
        uint _price = amount * mintPrice * (10 ** 18);

        //Check the buyer has paid the right amount, that there are enough tickets left, that the game is running and that the game has started
        require(msg.value == _price, "ERROR :: You must pay the right amount of RMC");
        require(amount <= nbOfTicketsSalable - nbTicketsSold, "WARNING :: Not enough tickets left for your order");
        nbTicketsSold += amount;
        require(period == Period.Game , "ERROR :: You can't buy tickets during this period");
        require(cycleStarted == true, "ERROR :: You can't buy tickets while a game is running");
        
        //Transfer the funds to this contract and mint the NFTs using the "NormalTicketMinter" contract
        payable(address(this)).transfer(msg.value);

        if(amount >= 1){
            for (uint i = 1; i <= amount; i++) {
                IRMCMinter(_addrN).createTicket("todo", msg.sender, IRMCTicketInfo.NftType.Normal);
            }
        }

        //If it's sold out, we start the game by calling the "startLottery" function
        if (cycleStarted == false && nbTicketsSold == nbOfTicketsSalable) {
            cycleStarted = true;
            startLottery();
        }

    }

    //Function called when all the tickets have been sold, starting the game
    function startLottery() private {
        //Check that the game has started and that the game is running. 
        //Bool "StartLotteryFunc" is used to prevent the function from being called twice
        require(cycleStarted == true, "ERROR :: A game can't start if all tickets haven't been sold");
        require(period == Period.Game, "ERROR :: You can't start a game during this period");
        require(startLotteryFunc == false, "ERROR :: You can't start a game twice");
        startLotteryFunc = true;
        
        pricepool = nbTicketsSold * mintPrice * (10 ** 17);

        totalDay = totalDay;

        //"start" is the timestamp of the start of the game
        start = block.timestamp * 1 days;
        currentDay = start;

    }

    //Function callable by anyone every 24h to reveal one caracteristic of the winning NFT
    function GoToNnextDay() public {
        //Check that a game is running, that the game is not over and that it's the right time to go to the next day
        require(period == Period.Game, "ERROR :: You can't go to the next day if not in a running game");
        require(currentDay < totalDay + start + 1 days, "ERROR :: You can't go to the next day if the game is over");
        require(block.timestamp * 1 days > currentDay + 1 days, "WARNING :: You can't go to the next day if it's not the right time");

        //If it's not the last day, we reveal a caracteristic of the winning NFT, 
        //add it to the "caracNftGagnant" variable and go to the next day
        //and increase "currentDay" by 1 day
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
        //Else, we end the game and start the claim period
        else {
            period = Period.Claim;
            endLottery();
        }
        
    }

    //Function called when all the caracteristics have been revealed (the winning NFT is known)
    function endLottery() private {
        //Check that a game is running, the day is after the last day and that this is the claim period
        //Bool "endLotteryFUnc" is used to prevent the function from being called twice
        require(period == Period.Claim, "ERROR :: You can't end the game if it's not over");
        require(currentDay >= totalDay + start, "ERROR :: You can't end the game if it's not over");
        require(cycleStarted == true, "ERROR :: You can't end the game if it's not started");
        require(endLotteryFunc == false, "ERROR :: You can't end the game twice");
        endLotteryFunc = true;
        
        period = Period.Claim;
        cycleStarted = false;
        currentDay = totalDay;
        
        //Claim all the fees from "Marketplace" contract, using "FeeManager" contract, and send them to this contract
        IRMCFeeInfo(addrFeeManager).claimFees();

    }

    //Function to claim the price pool for the winner
    function claimRewardForWinner() external {
        //Check that the game is in claim period, that the game is over, that the winner hasn't claimed the price pool yet
        require(period == Period.Claim, "ERROR :: You can't claim the winner if the game is not over");
        require(cycleStarted == false, "ERROR :: You can't claim the winner if the game is not over");
        require(currentDay == totalDay, "ERROR :: You can't claim the winner if the game is not over");
        require(winnerClaimed == false, "ERROR :: You can't claim twice the price pool");
       
       //"FeeManager" contract compute the gain of the winner and check his NFT
        uint gainWinner = IRMCFeeInfo(addrFeeManager).computeGainForWinner(caracNftGagnant, msg.sender); 
        //Burn the NFT of the winner
        IRMCTicketInfo(_addrN).approve(address(this), caracNftGagnant);
        IRMCMinter(_addrN).burn(caracNftGagnant);

        //Change the state of "winnerCLaimed" and transfer reward to the winner
        winnerClaimed = true;
        winner.transfer(gainWinner * 1 ether);

    }

    //Function to claim rewards for "Special Tickets" holders
    function claimRewardForAll() external {
        //Basically the same as "claimRewardForWinner" but for "Special Tickets" holders
        require(period == Period.Claim, "ERROR :: You can't claim the rewards if the game is not over");
        uint _totalGain;

        _totalGain = IRMCFeeInfo(addrFeeManager).computeGainForAdvantages(msg.sender);

        //Check that the gain is more than before transfer
        require(_totalGain > 0, "ERROR :: You don't have any rewards to claim");
        payable(msg.sender).transfer(_totalGain * (10 ** 18));

    }

    //Function called by owner ending the current cycle of the game
    //Used to mark the end of the game and to allow the owner to start a new one
    function endCycle() external onlyOwner {
        period = Period.End;
    }

}