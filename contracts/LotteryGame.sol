// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './Interfaces/IRMCTicketInfo.sol';
import './Interfaces/IRMCFeeInfo.sol';
import './Interfaces/IRMCMinter.sol';
import './LotteryManager.sol';

import "hardhat/console.sol";


//Principal contract of the lottery game

contract LotteryGame is LotteryManager 
{
    address private owner;

    address private _addrG;
    address private _addrSG;
    address private _addrM;
    address private _addrP;
    
    address payable winner;


    bool private startLotteryFunc;
    bool private endLotteryFunc;
    uint16 public nbTicketsSold;
    uint256 private winningCombination;
    uint256 private nonce;

    uint256 private nbStep;
    uint256 private currentStep;
    uint256 private lastStepTime;
    uint256 private constant MIN_TIME_STEP = 1 seconds;

    event Received(address, uint);

    //Constructor
    constructor() 
    {
        owner = msg.sender;

        period = Period.GAME;
        cycleStarted = false;
        lotteryId = 1;
        winningCombination = 1;
        currentStep = 1;
        pricepool = address(this).balance;
    }

    //Function to allow this contract to reveive value from other contracts
    receive() external payable  
    {
        emit Received(msg.sender, msg.value);
    }

    //Function setting a new lottery game
    function initializeNewCycle() external onlyOwner 
    {
        //Check that the previous game is over
        require(
            period == Period.END, 
            "ERROR :: You can't init a new cycle during this period"
        );
        //Resset all the necessary variables
        period = Period.GAME;
        cycleStarted == true;
        startLotteryFunc = false;
        endLotteryFunc = false;
        currentStep = 1;
        lotteryId += 1;
        winningCombination = lotteryId;
        winnerClaimed = false;
        
        IRMCMinter(addrNormalTicket).setLotteryId(lotteryId);
        IRMCFeeInfo(addrFeeManager).resetClaimStatus();
    }

    //Function for tickets purchase and minting
    function buyTicket(string[] memory uris) payable external 
    {
        //Calculate the price for the given amount of NFTs to buy
        uint _price = uris.length * mintPrice * (10 ** 18);

        //Check the buyer has paid the right amount, that there are enough tickets left, that the game is running and that the game has started
        require(
            msg.value == _price, 
            "ERROR :: You must pay the right amount of RMC"
        );
        require(
            uris.length <= nbOfTicketsSalable - nbTicketsSold, 
            "WARNING :: Not enough tickets left for your order"
        );
        require(
            period == Period.GAME , 
            "ERROR :: You can't buy tickets during this period"
        );
        require(
            cycleStarted == false, 
            "ERROR :: You can't buy tickets while a game is running"
        );
        
        //Transfer the funds to this contract and mint the NFTs using the "NormalTicketMinter" contract
        nbTicketsSold += uint16(uris.length);
        payable(address(this)).transfer(msg.value);

        if(uris.length >= 1) {
            for (uint i = 0; i < uris.length; i++) {
                IRMCMinter(addrNormalTicket).createTicket(
                    uris[i], 
                    msg.sender, 
                    IRMCTicketInfo.NftType.NORMAL
                );
            }
        }

        //If it's sold out, we start the game by calling the "startLottery" function
        if (cycleStarted == false && nbTicketsSold == nbOfTicketsSalable) {
            cycleStarted = true;
            startLottery();
        }
    }

    function setNbStep(uint256 _nbStep) external onlyOwner 
    {
        nbStep = _nbStep;
    }

    function isStartLotteryFunc () public view returns(bool) 
    {
        return startLotteryFunc;     
    }

    function isCycleStarted() public view returns(bool) 
    {
        return cycleStarted;
    }

    function getTicketsSold() external view returns(uint16 _nbOfTicketsSold) 
    {
        return nbTicketsSold;
    }

    function isEndLotteryFunc() public view returns(bool) 
    {
        return endLotteryFunc;
    }

    function getCurrentStep() public view returns(uint256) 
    {
        return currentStep;
    }
        
    function getWinningCombination() public view returns(uint256) 
    {
        return winningCombination;
    }

    //Function called when all the tickets have been sold, starting the game
    function startLottery() private 
    {
        //Check that the game has started and that the game is running. 
        //Bool "StartLotteryFunc" is used to prevent the function from being called twice
        require(
            cycleStarted == true, 
            "ERROR :: A game can't start if all tickets haven't been sold"
        );
        require(
            period == Period.GAME, 
            "ERROR :: You can't start a game during this period"
        );
        require(
            startLotteryFunc == false, 
            "ERROR :: You can't start a game twice"
        );
        startLotteryFunc = true;
        
        pricepool = nbTicketsSold * mintPrice * (10 ** 17);

        lastStepTime = block.timestamp;     
    }

    //Function callable by anyone every 24h to reveal one caracteristic of the winning NFT
    function goToNextDay() public 
    {
        //Check that a game is running, that the game is not over and that it's the right time to go to the next day
        require(
            period == Period.GAME, 
            "ERROR :: You can't go to the next day if not in a running game"
        );
        require(
            block.timestamp >= lastStepTime + MIN_TIME_STEP, 
            "WARNING :: You can't go to the next day if it's not the right time"
        );
            
        unchecked {
            winningCombination += (getRandomDigit()*10) * (10**currentStep);
        }

        if(currentStep < nbStep) {
            currentStep++;
            lastStepTime = block.timestamp;
        } else {
            period = Period.CLAIM;
            endLottery();
        }
    }

    //Function called when all the caracteristics have been revealed (the winning NFT is known)
    function endLottery() private 
    {
        //Check that a game is running, the day is after the last day and that this is the claim period
        //Bool "endLotteryFUnc" is used to prevent the function from being called twice
        require(
            period == Period.CLAIM, 
            "ERROR :: You can't end the game if it's not over"
        );
        require(
            currentStep >= nbStep, 
            "ERROR :: You can't end the game if it's not over"
        );
        require(
            cycleStarted == true, 
            "ERROR :: You can't end the game if it's not started"
        );
        require(
            endLotteryFunc == false, 
            "ERROR :: You can't end the game twice"
        );
        endLotteryFunc = true;
        
        period = Period.CLAIM;
        cycleStarted = false;
        
        //Claim all the fees from "Marketplace" contract, using "FeeManager" contract, and send them to this contract
        IRMCFeeInfo(addrFeeManager).claimFees();
    }

    //Function to claim the price pool for the winner
    function claimRewardForWinner() external 
    {
        //Check that the game is in claim period, that the game is over, that the winner hasn't claimed the price pool yet
        require(
            period == Period.CLAIM, 
            "ERROR :: You can't claim the winner if the game is not over"
        );
        require(
            cycleStarted == false, 
            "ERROR :: You can't claim the winner if the game is not over"
        );
        require(
            currentStep == nbStep, 
            "ERROR :: You can't claim the winner if the game is not over"
        );
        require(
            winnerClaimed == false, 
            "ERROR :: You can't claim twice the price pool"
        );
       
       //"FeeManager" contract compute the gain of the winner and check his NFT
        uint gainWinner = IRMCFeeInfo(addrFeeManager).computeGainForWinner(
            winningCombination, 
            msg.sender
        ); 
        //Burn the NFT of the winner
        IRMCTicketInfo(addrNormalTicket).approve(address(this), winningCombination);
        IRMCMinter(addrNormalTicket).burn(winningCombination);

        //Change the state of "winnerCLaimed" and transfer reward to the winner
        winnerClaimed = true;
        winner.transfer(gainWinner * 1 ether);
    }

    //Function to claim rewards for "Special Tickets" holders
    function claimRewardForAll() external 
    {
        //Basically the same as "claimRewardForWinner" but for "Special Tickets" holders
        require(
            period == Period.CLAIM, 
            "ERROR :: You can't claim the rewards if the game is not over"
        );
        uint _totalGain;

        _totalGain = IRMCFeeInfo(addrFeeManager).computeGainForAdvantages(msg.sender);

        //Check that the gain is more than before transfer
        require(
            _totalGain > 0, 
            "ERROR :: You don't have any rewards to claim"
        );
        payable(msg.sender).transfer(_totalGain * (10 ** 18));
    }

    //Function called by owner ending the current cycle of the game
    //Used to mark the end of the game and to allow the owner to start a new one
    function endCycle() external onlyOwner 
    {
        period = Period.END;
    }

    function getRandomDigit() private returns (uint8) {
        nonce++;
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(
            block.timestamp, 
            block.difficulty, 
            msg.sender, 
            nonce
        )));
        return uint8((randomNumber % 9) + 1);
    }
}