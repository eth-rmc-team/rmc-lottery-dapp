// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './LotteryManager.sol';
import './Interfaces/IRMCStaking.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

//Principal contract of the lottery game

contract LotteryGame is LotteryManager {

    address private owner;
    address payable winner;
    address private addrContractFeeManager;
    address private addrTicketStaking;

    uint public nbTicketsSold;
    
    uint private start;
    uint private currentDay;

    uint private caracNftGagnant;

    //Constructor
    constructor() payable {
        owner = msg.sender;

        nbTicketsSold = 0;
        cycleStarted = false;

        pricepool = address(this).balance;
        start = 0;
        currentDay = 0;

    }

    function setAddrTicketStakingContract(address _addrTicketStaking) public onlyOwner {
        addrTicketStaking = _addrTicketStaking;
    }

    //Function setting the price for a mint
    function setMintPrice(uint _price) public onlyOwner {
        mintPrice = _price * (10 ** 18); //todo: voir pour prend en compte les float (import math, mul etc)
    }

    function getMintPrice() external view returns (uint) {
        return (mintPrice * (10 ** 18));
    }

    function getIdTokenWinner() external view returns (uint) {
        return caracNftGagnant;
    }

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

    function buyTicket(uint amount) payable external{
        uint _price = amount * mintPrice * (10 ** 18);
        uint _tokenId;
        address staked = msg.sender;

        require(msg.value == _price, "ERROR :: You must pay the right amount of RMC");
        require(amount <= nbOfTicketsSalable - nbTicketsSold, "WARNING :: Not enough tickets left for your order");
        nbTicketsSold += amount;
        require(period == Period.Game , "ERROR :: You can't buy tickets during this period");
        require(cycleStarted == true, "ERROR :: You can't buy tickets while a game is running");
        
        payable(address(this)).transfer(msg.value);

        if(amount >= 1){
            for (uint i = 1; i <= amount; i++) {
                _tokenId = IRMCMinter(addrNormalNftContract).createTicket("todo", msg.sender, IRMCTicketInfo.NftType.Normal);
                IRMCStaking(addrTicketStaking).setTicketStaked(staked, _tokenId);

            }
        }

        if (cycleStarted == false && nbTicketsSold == nbOfTicketsSalable) {
            cycleStarted = true;
            startLottery();
        }

    }

    function startLottery() private {
        require(cycleStarted == true, "ERROR :: A game can't start if all tickets haven't been sold");
        require(period == Period.Game, "ERROR :: You can't start a game during this period");
        
        pricepool = nbTicketsSold * mintPrice * (10 ** 17);

        totalDay = totalDay;

        start = block.timestamp * 1 days;
        currentDay = start;

    }

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

    function claimRewardForWinner() external {
        require(period == Period.Claim, "ERROR :: You can't claim the winner if the game is not over");
        require(cycleStarted == false, "ERROR :: You can't claim the winner if the game is not over");
        require(currentDay == totalDay, "ERROR :: You can't claim the winner if the game is not over");
        require(winnerClaimed == false, "ERROR :: You can't claim twice the price pool");
       
        uint gainWinner = IRMCFeeInfo(addrFeeManager).computeGainForWinner(caracNftGagnant, msg.sender); 
        IRMCMinter(addrNormalNftContract).burn(caracNftGagnant);

        winnerClaimed = true;
        winner.transfer(gainWinner * 1 ether);

    }

    function claimRewardForAll() external {
        require(period == Period.Claim, "ERROR :: You can't claim the rewards if the game is not over");
        uint _totalGain;

        _totalGain = IRMCFeeInfo(addrFeeManager).computeGainForAdvantages(msg.sender);

        require(_totalGain > 0, "ERROR :: You don't have any rewards to claim");
        payable(msg.sender).transfer(_totalGain * 1 ether);

    }

    //Function ending the current cycle of the game
    function endCycle() external onlyOwner {
        period = Period.End;
    }

    function approveFeeManager(address _addrFeeManager) public onlyOwner {
        addrContractFeeManager = _addrFeeManager;
        
       //To avoid a mix with old and new approved amount, we set the allowance to 0 before setting the new allowance
        IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).approve(_addrFeeManager, 0);
        IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).approve(_addrFeeManager, 1000);

    }

    function getAllowance() public view returns(uint) {
        return IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).allowance(address(this), addrContractFeeManager);
    }

}