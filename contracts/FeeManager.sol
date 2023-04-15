// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './IRMC.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract FeeManager {

    address private owner;
    address public addrContractTicketManager;

    address _addrG;
    address _addrSG;
    address _addrM;
    address _addrP;

    IRMC irmc;
    IRMC.Period _period;
    
    //To be divided by 100 in the appropriated compute function
    //Every rewards are claim WHEN a game period is done (triggered by the winner claiming his gain
    //or the protocole after a delay).
    //It remains claimable UNTIL a new cycle begins.
    //NFT merged during chase period can't received rewards from previous cycles.

    uint shareOfPricePoolForWinner;
    uint shareOfPricePoolForGoldAndSuperGold;
    uint shareOfPricePoolForMythic;
    uint shareOfPricePoolForPlatin;
    uint shareOfPricePoolForProtocol;

    constructor() {
        owner = msg.sender;
        
        shareOfPricePoolForWinner = 33;
        //todo: les deux reçoivent bien 7% ? Pas de distinguo
        shareOfPricePoolForGoldAndSuperGold = 7;
        shareOfPricePoolForPlatin = 5;
        shareOfPricePoolForMythic = 3;
        shareOfPricePoolForProtocol = 33;
        
    }

    modifier onlyOwner {
        require(msg.sender == owner, "WARNING :: Only owner can call this function");
        _;
    }

    function setAddr(address _addr)  external onlyOwner {
        addrContractTicketManager = _addr;
        (,_addrG, _addrSG, _addrM, _addrP) = IRMC(addrContractTicketManager).getAddrTicketContracts();

        
    }

    function setAddrContract(address _addrContractLotteryManager) external onlyOwner {
        irmc = IRMC(_addrContractLotteryManager);
    }

    //Function setting the share of the winner
    function setShareOfPricePoolForWinner (uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForProtocol + 
                shareOfPricePoolForPlatin + 
                shareOfPricePoolForMythic +
                shareOfPricePoolForGoldAndSuperGold < 100, "WARNING :: the total share must be less than 100");

        require(_share > 15 && _share < 51, "WARNING :: the share must be between 15 and 51");
            shareOfPricePoolForWinner = _share;
    }

    //Same function but for the protocol
    function setShareOfPricePoolForProtocol(uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForWinner + 
                shareOfPricePoolForPlatin + 
                shareOfPricePoolForMythic +
                shareOfPricePoolForGoldAndSuperGold < 100, "WARNING :: the total share must be less than 100");
        
        require(_share > 15 && _share < 40, "WARNING :: the share must be between 15 and 40");
                shareOfPricePoolForProtocol = _share;
    }

    //Same function but for the Gold and SuperGold
    function setShareOfPricePoolForGoldAndSuperGold(uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForWinner + 
                shareOfPricePoolForPlatin + 
                shareOfPricePoolForMythic +
                shareOfPricePoolForProtocol < 100, "WARNING :: the total share must be less than 100");
            
        require(_share > 5 && _share < 10, "WARNING :: the share must be between 5 and 10");
            shareOfPricePoolForGoldAndSuperGold = _share;
    }

    //Same function but for the Mythic
    function setShareOfPricePoolForMythic(uint _share) public onlyOwner {
        require(_share + shareOfPricePoolForWinner + 
                shareOfPricePoolForPlatin + 
                shareOfPricePoolForGoldAndSuperGold +
                shareOfPricePoolForProtocol < 100, "WARNING :: the total share must be less than 100");
            
        require(_share > 1 && _share < 5, "WARNING :: the share must be between 2 and 5");
            shareOfPricePoolForGoldAndSuperGold = _share;
    }

    //Same function but for the Platin
    function setShareOfPricePoolForPlatin(uint _share) public onlyOwner {            
        require(_share + shareOfPricePoolForWinner + 
                shareOfPricePoolForMythic + 
                shareOfPricePoolForGoldAndSuperGold +
                shareOfPricePoolForProtocol < 100, "WARNING :: the total share must be less than 100");
            
        require(_share > 1 && _share < 7, "WARNING :: the share must be between 1 and 5");
            shareOfPricePoolForGoldAndSuperGold = _share;
    }

    //Function get for the different shares
    function getShareOfPricePoolFor() external view returns(uint _shareProt, uint _shareWinner, uint shareSGG, uint _shareMyth, uint _sharePlat) {
            
        return (shareOfPricePoolForProtocol, 
        shareOfPricePoolForWinner, 
        shareOfPricePoolForGoldAndSuperGold, 
        shareOfPricePoolForMythic, 
        shareOfPricePoolForPlatin);
    }

    function computeGainForAdvantages(address _addrClaimer) external returns (uint _totalGain) {
        require(_period == IRMC.Period.Claim, "ERROR :: You can't claim the winner if the game is not over");

        uint cptG = 0;
        uint cptSG = 0;
        uint cptM = 0;
        uint cptP = 0;
        
        uint gain_PP = 0;
        uint gain_D = 0;
        uint id = 0;

        uint _balanceDealsFees;
        uint _pricepool;
        
        bool _claimed;

        (_pricepool, _balanceDealsFees) = irmc.getPricepoolAndDealFees();
        uint supplySGG = IERC721Enumerable(_addrSG).totalSupply() + IERC721Enumerable(_addrG).totalSupply();

        if (IERC721Enumerable(_addrG).balanceOf(_addrClaimer) > 0 ){
            for (uint i = 0; i < IERC721Enumerable(_addrG).balanceOf(_addrClaimer); i++){
                
                id = IERC721Enumerable(_addrG).tokenOfOwnerByIndex(_addrClaimer, i);
                (_claimed, ) = irmc.getClaimedRewardStatus(id);
                if(_claimed == false) {
                    irmc.setPPClaimStatus(true, id);
                    irmc.setFeeClaimStatus(true, id);
                    cptG ++;

                }

            }
            gain_PP += (cptG / supplySGG) * shareOfPricePoolForGoldAndSuperGold;
            gain_D += (cptG / IERC721Enumerable(_addrG).totalSupply()) * 20;
        }

        if (IERC721Enumerable(_addrSG).balanceOf(_addrClaimer) > 0 ){
            for (uint i = 0; i < IERC721Enumerable(_addrSG).balanceOf(_addrClaimer); i++){
                
                id = IERC721Enumerable(_addrSG).tokenOfOwnerByIndex(_addrClaimer, i);
                (_claimed, ) = irmc.getClaimedRewardStatus(id);

                if(_claimed == false){
                    irmc.setPPClaimStatus(true, id);
                    irmc.setFeeClaimStatus(true, id);
                    cptSG ++;
                }
            }
            gain_PP += (cptSG / supplySGG) * shareOfPricePoolForGoldAndSuperGold;
            gain_D += (cptSG / IERC721Enumerable(_addrSG).totalSupply()) * 20;
        }

        if (IERC721Enumerable(_addrM).balanceOf(_addrClaimer) > 0 ){
            for (uint i = 0; i < IERC721Enumerable(_addrM).balanceOf(_addrClaimer); i++){
                
                id = IERC721Enumerable(_addrM).tokenOfOwnerByIndex(_addrClaimer, i);
                (_claimed, ) = irmc.getClaimedRewardStatus(id);

                if(_claimed == false){
                    irmc.setPPClaimStatus(true, id);
                    irmc.setFeeClaimStatus(true, id);
                    cptM ++;
                }
            }
            gain_PP += (cptM / IERC721Enumerable(_addrM).totalSupply()) * shareOfPricePoolForMythic;
            gain_D += (cptM / IERC721Enumerable(_addrM).totalSupply()) * 0;
        }

        if (IERC721Enumerable(_addrP).balanceOf(_addrClaimer) > 0 ){
            for (uint i = 0; i < IERC721Enumerable(_addrP).balanceOf(_addrClaimer); i++){
                
                id = IERC721Enumerable(_addrP).tokenOfOwnerByIndex(_addrClaimer, i);
                (_claimed, ) = irmc.getClaimedRewardStatus(id);

                if(_claimed == false){
                    irmc.setPPClaimStatus(true, id);
                    irmc.setFeeClaimStatus(true, id);
                    cptP ++;
                }
            }
            gain_PP += (cptP / IERC721Enumerable(_addrP).totalSupply()) * shareOfPricePoolForPlatin;
            gain_D += (cptP / IERC721Enumerable(_addrP).totalSupply()) * 20;
        }


        gain_PP = gain_PP * _pricepool / 100;
        //Todo: Partade des fees mis en brute, à mettre plus tard dans LotteryManager.
        gain_D = gain_D * _balanceDealsFees / 100;
        uint totalGain;
        totalGain = gain_PP + gain_D;
        return (totalGain);

    }
 
} 