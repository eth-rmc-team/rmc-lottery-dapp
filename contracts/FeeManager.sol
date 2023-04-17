// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './Interfaces/IRMCTicketInfo.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract FeeManager {

    address private owner;
    address private addrContractLotteryGame;
    address private addrContractMarketplace;

    address private addrN;
    address private addrG;
    address private addrSG;
    address private addrM;
    address private addrP;

    bool private _claimed;
    
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
        require(msg.sender == owner, "ERROR :: Only owner can call this function");
        _;
    }

    modifier onlyLotteryGame {
        require(msg.sender == addrContractLotteryGame, "ERROR :: Only LotteryGame contract can call this function");
        _;
    }

    function setAddrGame(address _addrLG, address _addrMP)  external onlyOwner {
        addrContractLotteryGame = _addrLG;
        addrContractMarketplace = _addrMP;

    }

    function setAddrTicketContract(address _addrN, 
                                   address _addrG, 
                                   address _addrSG, 
                                   address _addrM, 
                                   address _addrP) external onlyOwner {
        addrN = _addrN;
        addrG = _addrG;
        addrSG = _addrSG;
        addrM = _addrM;
        addrP = _addrP;
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
    function getShareOfPricePoolFor() external view returns(uint _shareProt, 
                                                            uint _shareWinner, 
                                                            uint shareSGG, 
                                                            uint _shareMyth, 
                                                            uint _sharePlat) {
            
        return (shareOfPricePoolForProtocol, 
        shareOfPricePoolForWinner, 
        shareOfPricePoolForGoldAndSuperGold, 
        shareOfPricePoolForMythic, 
        shareOfPricePoolForPlatin);
    }

    function claimFees () external {
        require(payable(msg.sender) == addrContractLotteryGame, "ERROR :: Only the LotteryGame contract can call this function");
        //If there is money in the contract, we send it to the LotteryGame contract
        if(addrContractMarketplace.balance > 0){
            IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).transferFrom(addrContractMarketplace, 
                                                                            addrContractLotteryGame, 
                                                                            (addrContractMarketplace.balance * (10 ** 18)));
        }

    }

    function disableClaim(uint _id, address addrNftContract) private {
        //True = reward claimed by the NFT
        IRMCTicketInfo(addrNftContract).setPPClaimStatus(true, _id);
        IRMCTicketInfo(addrNftContract).setFeeClaimStatus(true, _id);
    }

    function resetClaimStatus() external onlyLotteryGame {

        //Reset of the claim status of all NFTs
        for(uint i= 0; i < IRMCTicketInfo(addrG).totalSupply(); i++){
            uint id;
            id = IRMCTicketInfo(addrG).tokenByIndex(i);
            IRMCTicketInfo(addrG).setPPClaimStatus(false, id);
            IRMCTicketInfo(addrG).setFeeClaimStatus(false, id);
        }

        for(uint i= 0; i < IRMCTicketInfo(addrSG).totalSupply(); i++){
            uint id;
            id = IRMCTicketInfo(addrSG).tokenByIndex(i);
            IRMCTicketInfo(addrSG).setPPClaimStatus(false, id);
            IRMCTicketInfo(addrSG).setFeeClaimStatus(false, id);
        }

        for(uint i= 0; i < IRMCTicketInfo(addrM).totalSupply(); i++){
            uint id;
            id = IRMCTicketInfo(addrM).tokenByIndex(i);
            IRMCTicketInfo(addrM).setPPClaimStatus(false, id);
            IRMCTicketInfo(addrM).setFeeClaimStatus(false, id);        
        }

        for(uint i= 0; i < IRMCTicketInfo(addrP).totalSupply(); i++){
            uint id;
            id = IRMCTicketInfo(addrP).tokenByIndex(i);
            IRMCTicketInfo(addrP).setPPClaimStatus(false, id);
            IRMCTicketInfo(addrP).setFeeClaimStatus(false, id);
        }
    }

    //Function to compute the gain for the owner of special NFT and disabling the claim afterward
    function computeGainForAdvantages(address addrClaimer) external onlyLotteryGame returns (uint _totalGain) {

        uint cptG = 0;
        uint cptSG = 0;
        uint cptM = 0;
        uint cptP = 0;
        
        uint gain_PP = 0;
        uint gain_D = 0;
        uint totalGain = 0;

        uint id = 0;

        uint _pricepool = addrContractLotteryGame.balance;
        uint _balanceDealsFees = addrContractMarketplace.balance;
        
        uint supplySGG = IRMCTicketInfo(addrSG).totalSupply() + IRMCTicketInfo(addrG).totalSupply();

        if (IRMCTicketInfo(addrG).balanceOf(addrClaimer) > 0 ){
            for (uint i = 0; i < IRMCTicketInfo(addrG).balanceOf(addrClaimer); i++){
                
                id = IRMCTicketInfo(addrG).tokenOfOwnerByIndex(addrClaimer, i);
                (_claimed, ) = IRMCTicketInfo(addrG).getClaimedRewardStatus(id);
                if(_claimed == false) {
                    disableClaim(id, addrG);
                    cptG ++;
                }

            }
            gain_PP += (cptG / supplySGG) * shareOfPricePoolForGoldAndSuperGold;
            gain_D += (cptG / IRMCTicketInfo(addrG).totalSupply()) * 20;
        }

        if (IRMCTicketInfo(addrSG).balanceOf(addrClaimer) > 0 ){
            for (uint i = 0; i < IRMCTicketInfo(addrSG).balanceOf(addrClaimer); i++){
                
                id = IRMCTicketInfo(addrSG).tokenOfOwnerByIndex(addrClaimer, i);
                (_claimed, ) = IRMCTicketInfo(addrSG).getClaimedRewardStatus(id);

                if(_claimed == false){
                    disableClaim(id, addrSG);
                    cptSG ++;
                }
            }
            gain_PP += (cptSG / supplySGG) * shareOfPricePoolForGoldAndSuperGold;
            gain_D += (cptSG / IRMCTicketInfo(addrSG).totalSupply()) * 20;
        }

        if (IRMCTicketInfo(addrM).balanceOf(addrClaimer) > 0 ){
            for (uint i = 0; i < IRMCTicketInfo(addrM).balanceOf(addrClaimer); i++){
                
                id = IRMCTicketInfo(addrM).tokenOfOwnerByIndex(addrClaimer, i);
                (_claimed, ) = IRMCTicketInfo(addrM).getClaimedRewardStatus(id);

                if(_claimed == false){
                    disableClaim(id, addrM);
                    cptM ++;
                }
            }
            gain_PP += (cptM / IRMCTicketInfo(addrM).totalSupply()) * shareOfPricePoolForMythic;
            gain_D += (cptM / IRMCTicketInfo(addrM).totalSupply()) * 0;
        }

        if (IRMCTicketInfo(addrP).balanceOf(addrClaimer) > 0 ){
            for (uint i = 0; i < IRMCTicketInfo(addrP).balanceOf(addrClaimer); i++){
                
                id = IRMCTicketInfo(addrP).tokenOfOwnerByIndex(addrClaimer, i);
                (_claimed, ) = IRMCTicketInfo(addrP).getClaimedRewardStatus(id);

                if(_claimed == false){
                    disableClaim(id, addrP);
                    cptP ++;
                }
            }
            gain_PP += (cptP / IRMCTicketInfo(addrP).totalSupply()) * shareOfPricePoolForPlatin;
            gain_D += (cptP / IRMCTicketInfo(addrP).totalSupply()) * 20;
        }


        gain_PP = gain_PP * _pricepool / 100;
        //Todo: Partage des fees mis en brute, à mettre plus tard dans LotteryManager.
        gain_D = gain_D * _balanceDealsFees / 100;
        totalGain = gain_PP + gain_D;
        
        return (totalGain);

    }

    function computeGainForWinner(uint _idWinner, 
                                  address _claimer) external onlyLotteryGame returns(uint _gain) {

        address payable _winner = payable(IRMCTicketInfo(addrN).ownerOf(_idWinner));
        require(payable(_claimer) == _winner, "ERROR :: you don't have the winning ticket"); 
        
        IRMCTicketInfo(addrN).approve(address(0), _idWinner);
        IRMCTicketInfo(addrN).safeTransferFrom(_claimer, address(0), _idWinner);

        _gain = shareOfPricePoolForWinner * addrContractLotteryGame.balance / 100;

        return _gain;

    }
 
} 