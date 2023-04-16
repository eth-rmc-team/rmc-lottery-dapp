// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './Interfaces/IRMCTicketInfo.sol';
import './Interfaces/IRMCFeeInfo.sol';
import './LotteryManager.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

//Principal contract of the lottery game

contract LotteryGame is LotteryManager {

    address private owner;
    address private _addrTicketManager;
    address private _addrFeeManager;
    address private _addrMarketPlace;

    address private _addrN;
    address private _addrG;
    address private _addrSG;
    address private _addrM;
    address private _addrP;
    
    address payable winner;

    IRMCTicketInfo irmc;

    uint public nbTicketsSold;
    uint public _nbOfTicketsSalable;

    uint private _lotteryId;

    bool private cycleStarted;
    bool private winnerClaimed;
    
    uint public pricepool;

    uint private start;
    uint private currentDay;
    uint private _totalDay;

    uint private caracNftGagnant;

    Period private _period;

    event Received(address, uint);

    //Constructor
    constructor() payable {
        owner = msg.sender;
        _addrTicketManager = addrTicketManager;
        _addrFeeManager = addrFeeManager;
        _addrMarketPlace = addrMarketPlace;

        nbTicketsSold = 0;
        _lotteryId = lotteryId;
        cycleStarted = false;
        _period = period;
        _totalDay = totalDay;
        pricepool = address(this).balance;
        start = 0;
        currentDay = 0;
        _nbOfTicketsSalable = nbOfTicketsSalable;

    }

    //Function to allow this contract to reveive value from other contracts
    receive() external payable  {
        emit Received(msg.sender, msg.value);
    }

    //Function getter returnning the status of chasePeriod and gamePeriod
    //To use in FusionManager.sol
    function getPeriod () external view returns(Period){
        return (_period);
    } 

    function NewCycle() external onlyOwner {
        require(_period == Period.End, "ERROR :: You can't init a new cycle during this period");
        _period = Period.Game;
        currentDay = 0;
        lotteryId += 1;
        caracNftGagnant = lotteryId * 100000;
        winnerClaimed = false;
        irmc = IRMCTicketInfo(_addrTicketManager);

        //Reset of the claim status of all NFTs
        ( _addrN, _addrG, _addrSG, _addrM, _addrP) = irmc.getAddrTicketContracts();
        for(uint i= 0; i < IERC721Enumerable(_addrG).totalSupply(); i++){
            uint id;
            id = IERC721Enumerable(_addrG).tokenByIndex(i);
            irmc.setPPClaimStatus(false, id);
            irmc.setFeeClaimStatus(false, id);
        }

        for(uint i= 0; i < IERC721Enumerable(_addrSG).totalSupply(); i++){
            uint id;
            id = IERC721Enumerable(_addrSG).tokenByIndex(i);
            irmc.setPPClaimStatus(false, id);
            irmc.setFeeClaimStatus(false, id);
        }

        for(uint i= 0; i < IERC721Enumerable(_addrM).totalSupply(); i++){
            uint id;
            id = IERC721Enumerable(_addrM).tokenByIndex(i);
            irmc.setPPClaimStatus(false, id);
            irmc.setFeeClaimStatus(false, id);        
        }

        for(uint i= 0; i < IERC721Enumerable(_addrP).totalSupply(); i++){
            uint id;
            id = IERC721Enumerable(_addrP).tokenByIndex(i);
            irmc.setPPClaimStatus(false, id);
            irmc.setFeeClaimStatus(false, id);
        }
    }

    function buyTicket(uint amount) payable external{
        uint _price = amount * irmc.getMintPrice() * (10 ** 18);

        require(msg.value == _price, "ERROR :: You must pay the right amount of RMC");
        require(amount <= _nbOfTicketsSalable - nbTicketsSold, "WARNING :: Not enough tickets left for your order");
        nbTicketsSold += amount;
        require(_period == Period.Game , "ERROR :: You can't buy tickets during this period");
        require(cycleStarted == true, "ERROR :: You can't buy tickets while a game is running");
        
        payable(address(this)).transfer(msg.value);

        
        //TODO : add the minting of the tickets
        //TODO et renseigner: irmc.setNftInfo(_tokenId, _nftOwner, _nftState, _nftPrice);

        if (cycleStarted == false && nbTicketsSold == _nbOfTicketsSalable) {
            cycleStarted = true;
            startLottery();
        }

    }

    function startLottery() private {
        require(cycleStarted == true, "ERROR :: A game can't start if all tickets haven't been sold");
        require(_period == Period.Game, "ERROR :: You can't start a game during this period");
        
        pricepool = nbTicketsSold * irmc.getMintPrice() * (10 ** 17);

        _totalDay = totalDay;

        start = block.timestamp * 1 days;
        currentDay = start;

    }

    function GoToNnextDay() public {
        require(_period == Period.Game, "ERROR :: You can't go to the next day if not in a running game");
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
            _period = Period.Claim;
            endLottery();
        }
        
    }

    function endLottery() private {
        require(_period == Period.Claim, "ERROR :: You can't end the game if it's not over");
        require(currentDay >= totalDay + start, "ERROR :: You can't end the game if it's not over");
        require(cycleStarted == true, "ERROR :: You can't end the game if it's not started");
        
        cycleStarted = false;
        currentDay = _totalDay;
        
        (_addrN, _addrG, _addrSG, _addrM, _addrP) = irmc.getAddrTicketContracts();

        //Claim all the fees from Marketplace
        IRMCFeeInfo(_addrMarketPlace).claimFees();

    }

    function claimRewardForWinner() external {
        require(_period == Period.Claim, "ERROR :: You can't claim the winner if the game is not over");
        require(cycleStarted == false, "ERROR :: You can't claim the winner if the game is not over");
        require(currentDay == _totalDay, "ERROR :: You can't claim the winner if the game is not over");
        require(winnerClaimed == false, "ERROR :: You can't claim twice the price pool");

        uint _shareWinner;
        (, _shareWinner, , ,) = IRMCFeeInfo(_addrFeeManager).getShareOfPricePoolFor();
       
        winnerClaimed = true;
        address addrContr;
        
        (, addrContr,,,,,) = irmc.getNftInfo(caracNftGagnant);
        winner = payable(IERC721Enumerable(addrContr).ownerOf(caracNftGagnant));
        
        require(winner == payable(msg.sender), "ERROR :: You are not the winner of this game");
        IERC721Enumerable(addrContr).safeTransferFrom(msg.sender, address(0), caracNftGagnant);
        winner.transfer(_shareWinner * pricepool / 100);

    }

    function claimRewardsForAll(address _addrClaimer) external {
        require(_period == Period.Claim, "ERROR :: You can't claim the rewards if the game is not over");
        uint _totalGain;

        _addrClaimer = msg.sender;
        (_totalGain) = IRMCFeeInfo(addrFeeManager).computeGainForAdvantages(_addrClaimer);

        require(_totalGain > 0, "ERROR :: You don't have any rewards to claim");
        payable(_addrClaimer).transfer(_totalGain * 1 ether);

    }

    //Function ending the current cycle of the game
    function endCycle() external onlyOwner {
        _period = Period.End;
    }

}