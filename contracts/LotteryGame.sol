// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './IRMC.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//Principal contract of the lottery game

contract LotteryGame {

    address private owner;
    address public addrLotteryManager;

    address _addrN;
    address _addrG;
    address _addrSG;
    address _addrM;
    address _addrP;
    
    address payable winner;

    IRMC irmc;

    uint public nbTicketsSold;
    uint public _nbOfTicketsSalable;

    uint lotteryId;

    bool private cycleStarted;
    bool private winnerClaimed;
    
    uint public pricepool;
    uint public balanceFeesDeals;
    uint private _shareProt;
    uint private _shareWinner;
    uint private _shareSGG;
    uint private _shareMyth;
    uint private _sharePlat;

    uint private start;
    uint private currentDay;
    uint private totalDay;

    uint private caracNftGagnant;

    IRMC.Period private _period;

    event Received(address, uint);

    //Constructor
    constructor(address _addrLotMan) payable {
        owner = msg.sender;
        nbTicketsSold = 0;
        lotteryId = 0;
        cycleStarted = false;
        start = 0;
        currentDay = 0;
        irmc = IRMC(_addrLotMan);
        _nbOfTicketsSalable = irmc.getTicketsSalable();
        _period = irmc.getPeriod();

    }

    modifier onlyOwner {
        require(msg.sender == owner, "ERROR :: You are not the owner of this contract");
        _;
    }

    //Function to allow this contract to reveive value from other contracts
    receive() external payable  {
        emit Received(msg.sender, msg.value);
    }

    function setAddrLotteryManager(address _addrLotMan) external onlyOwner {
        addrLotteryManager = _addrLotMan;
        irmc = IRMC(addrLotteryManager);
    }

    function NewCycle() external onlyOwner {
        require(_period == IRMC.Period.End, "ERROR :: You can't init a new cycle during this period");
        _period = IRMC.Period.Game;
        currentDay = 0;
        lotteryId += 1;
        caracNftGagnant = lotteryId * 100000;
        irmc.setLotteryId(lotteryId);
        winnerClaimed = false;
        balanceFeesDeals = 0;
    }

    function buyTicket(uint amount) payable external{
        uint _price = amount * irmc.getMintPrice() * (10 ** 17);

        require(msg.value == _price, "ERROR :: You must pay the right amount of RMC");
        amount = 0;
        require(amount <= _nbOfTicketsSalable - nbTicketsSold, "WARNING :: Not enough tickets left for your order");
        nbTicketsSold += amount;
        require(_period == IRMC.Period.Game , "ERROR :: You can't buy tickets during this period");
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
        require(_period == IRMC.Period.Game, "ERROR :: You can't start a game during this period");
        
        pricepool = nbTicketsSold * irmc.getMintPrice() * (10 ** 17);

        irmc.setLotteryId(lotteryId);
        totalDay = irmc.getTotalDay();

        start = block.timestamp * 1 days;
        currentDay = start;

    }

    function GoToNnextDay() public {
        require(_period == IRMC.Period.Game, "ERROR :: You can't go to the next day if not in a running game");
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
            _period = IRMC.Period.Claim;
            irmc.setPeriod(_period);
            endLottery();
        }
        
    }

    function endLottery() private {
        require(_period == IRMC.Period.Claim, "ERROR :: You can't end the game if it's not over");
        require(currentDay >= totalDay + start, "ERROR :: You can't end the game if it's not over");
        require(cycleStarted == true, "ERROR :: You can't end the game if it's not started");
        
        cycleStarted = false;
        currentDay = totalDay;

        balanceFeesDeals = address(this).balance - pricepool;

        (_shareProt, _shareWinner, _shareSGG, _shareMyth, _sharePlat) = irmc.getShareOfPricePoolFor();
        (_addrN, _addrG, _addrSG, _addrM, _addrP) = irmc.getAddrTicketContracts();
    }

    function claimReward() external {
        require(_period == IRMC.Period.Claim, "ERROR :: You can't claim the winner if the game is not over");
        require(cycleStarted == false, "ERROR :: You can't claim the winner if the game is not over");
        require(currentDay == totalDay, "ERROR :: You can't claim the winner if the game is not over");
        require(winnerClaimed == false, "ERROR :: You can't claim twice the price pool");

        //Claim all the fees from Marketplace
        irmc.claimFees();

        winnerClaimed = true;
        address addrContr;
        (, addrContr,,,,,) = irmc.getNftInfo(caracNftGagnant);
        winner = payable(IERC721Enumerable(addrContr).ownerOf(caracNftGagnant));
        
        require(winner == payable(msg.sender), "ERROR :: You are not the winner of this game");
        IERC721Enumerable(addrContr).safeTransferFrom(msg.sender, address(0), caracNftGagnant);
        winner.transfer(_shareWinner * pricepool / 100);

    }

    function computeGainForAdvantages_PP() private returns (uint _totalReward) {
        require(_period == IRMC.Period.Claim, "ERROR :: You can't claim the winner if the game is not over");

        uint cptG = 0;
        uint cptSG = 0;
        uint cptM = 0;
        uint cptP = 0;
        
        uint gain = 0;
        uint gain_PP = 0;
        uint gain_D = 0;
        uint id = 0;

        if (IERC721Enumerable(_addrG).balanceOf(msg.sender) > 0 ){
            for (uint i = 0; i < IERC721Enumerable(_addrG).balanceOf(msg.sender); i++){
                
                id = IERC721Enumerable(_addrG).tokenOfOwnerByIndex(msg.sender, i);
                if(irmc.getClaimedRewardStatus(id) == false) {
                    irmc.setClaimRewardStatus(true, id);
                    cptG ++;

                }

            }
            cptG = cptG / IERC721Enumerable(_addrG).totalSupply();
        }

        if (IERC721Enumerable(_addrSG).balanceOf(msg.sender) > 0 ){
            for (uint i = 0; i < IERC721Enumerable(_addrSG).balanceOf(msg.sender); i++){
                
                id = IERC721Enumerable(_addrSG).tokenOfOwnerByIndex(msg.sender, i);
                if(irmc.getClaimedRewardStatus(id) == false){
                    irmc.setClaimRewardStatus(true, id);
                    cptSG ++;
                }
            }
            cptSG = cptSG / IERC721Enumerable(_addrSG).totalSupply();
        }

        if (IERC721Enumerable(_addrM).balanceOf(msg.sender) > 0 ){
            for (uint i = 0; i < IERC721Enumerable(_addrM).balanceOf(msg.sender); i++){
                
                id = IERC721Enumerable(_addrM).tokenOfOwnerByIndex(msg.sender, i);
                if(irmc.getClaimedRewardStatus(id) == false){
                    irmc.setClaimRewardStatus(true, id);
                    cptM ++;
                }
            }
            cptM = cptM / IERC721Enumerable(_addrM).totalSupply();
        }

        if (IERC721Enumerable(_addrP).balanceOf(msg.sender) > 0 ){
            for (uint i = 0; i < IERC721Enumerable(_addrP).balanceOf(msg.sender); i++){
                
                id = IERC721Enumerable(_addrP).tokenOfOwnerByIndex(msg.sender, i);
                if(irmc.getClaimedRewardStatus(id) == false){
                    irmc.setClaimRewardStatus(true, id);
                    cptP ++;
                }
            }
            cptP = cptP / IERC721Enumerable(_addrP).totalSupply();
        }


        gain_PP = (cptG * _shareSGG + cptSG * _shareSGG + cptM * _shareMyth + cptP * _sharePlat) * pricepool / 100;
        //Todo: Partade des fees mis en brute, à mettre plus tard dans LotteryManager.
        gain_D = (cptG * 20 + cptSG * 20 + cptM * 0 + cptP * 20);
        gain = gain_PP + gain_D;
        
        return (gain);

    }

    function computeGainForAdvantages_D() private returns(uint _gain_D){
        

    }

    //Function ending the current cycle of the game
    function endCycle() external onlyOwner {
        _period = IRMC.Period.End;
        irmc.setPeriod(_period);

    }

}