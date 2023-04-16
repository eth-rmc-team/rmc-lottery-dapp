// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './Interfaces/IRMCTicketInfo.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract FeeManager {

    address private owner;
    address private addrContractTicketManager;
    address private addrContractLotteryGame;
    address private addrContractMarketplace;

    address private _addrN;
    address private _addrG;
    address private _addrSG;
    address private _addrM;
    address private _addrP;

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
        require(msg.sender == owner, "WARNING :: Only owner can call this function");
        _;
    }

    modifier onlyLotteryGame {
        require(msg.sender == addrContractLotteryGame, "ERROR :: Only LotteryGame contract can call this function");
        _;
    }

    function setAddr(address _addrTM, address _addrLG, address _addrMP)  external onlyOwner {
        addrContractTicketManager = _addrTM;
        addrContractLotteryGame = _addrLG;
        addrContractMarketplace = _addrMP;

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

    function disableClaim(uint _id) private {
        IRMCTicketInfo(addrContractTicketManager).setPPClaimStatus(true, _id);
        IRMCTicketInfo(addrContractTicketManager).setFeeClaimStatus(true, _id);
    }

    function enableClaim(uint _id) private {
        IRMCTicketInfo(addrContractTicketManager).setPPClaimStatus(false, _id);
        IRMCTicketInfo(addrContractTicketManager).setFeeClaimStatus(false, _id);
    }

    function resetClaimStatus() external onlyLotteryGame {

        //Reset of the claim status of all NFTs
        ( _addrN, _addrG, _addrSG, _addrM, _addrP) = IRMCTicketInfo(addrContractTicketManager).getAddrTicketContracts();
        for(uint i= 0; i < IRMCTicketInfo(_addrG).totalSupply(); i++){
            uint id;
            id = IRMCTicketInfo(_addrG).tokenByIndex(i);
            IRMCTicketInfo(addrContractTicketManager).setPPClaimStatus(false, id);
            IRMCTicketInfo(addrContractTicketManager).setFeeClaimStatus(false, id);
        }

        for(uint i= 0; i < IRMCTicketInfo(_addrSG).totalSupply(); i++){
            uint id;
            id = IRMCTicketInfo(_addrSG).tokenByIndex(i);
            IRMCTicketInfo(addrContractTicketManager).setPPClaimStatus(false, id);
            IRMCTicketInfo(addrContractTicketManager).setFeeClaimStatus(false, id);
        }

        for(uint i= 0; i < IRMCTicketInfo(_addrM).totalSupply(); i++){
            uint id;
            id = IRMCTicketInfo(_addrM).tokenByIndex(i);
            IRMCTicketInfo(addrContractTicketManager).setPPClaimStatus(false, id);
            IRMCTicketInfo(addrContractTicketManager).setFeeClaimStatus(false, id);        
        }

        for(uint i= 0; i < IRMCTicketInfo(_addrP).totalSupply(); i++){
            uint id;
            id = IRMCTicketInfo(_addrP).tokenByIndex(i);
            IRMCTicketInfo(addrContractTicketManager).setPPClaimStatus(false, id);
            IRMCTicketInfo(addrContractTicketManager).setFeeClaimStatus(false, id);
        }
    }

    //Function to compute the gain for the owner of special NFT and disabling the claim afterward
    function computeGainForAdvantages(address _addrClaimer) external onlyLotteryGame returns (uint _totalGain) {

        (,_addrG, _addrSG, _addrM, _addrP) = IRMCTicketInfo(addrContractTicketManager).getAddrTicketContracts();

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
        
        uint supplySGG = IRMCTicketInfo(_addrSG).totalSupply() + IRMCTicketInfo(_addrG).totalSupply();

        if (IRMCTicketInfo(_addrG).balanceOf(_addrClaimer) > 0 ){
            for (uint i = 0; i < IRMCTicketInfo(_addrG).balanceOf(_addrClaimer); i++){
                
                id = IRMCTicketInfo(_addrG).tokenOfOwnerByIndex(_addrClaimer, i);
                (_claimed, ) = IRMCTicketInfo(addrContractTicketManager).getClaimedRewardStatus(id);
                if(_claimed == false) {
                    disableClaim(id);
                    cptG ++;
                }

            }
            gain_PP += (cptG / supplySGG) * shareOfPricePoolForGoldAndSuperGold;
            gain_D += (cptG / IRMCTicketInfo(_addrG).totalSupply()) * 20;
        }

        if (IRMCTicketInfo(_addrSG).balanceOf(_addrClaimer) > 0 ){
            for (uint i = 0; i < IRMCTicketInfo(_addrSG).balanceOf(_addrClaimer); i++){
                
                id = IRMCTicketInfo(_addrSG).tokenOfOwnerByIndex(_addrClaimer, i);
                (_claimed, ) = IRMCTicketInfo(addrContractTicketManager).getClaimedRewardStatus(id);

                if(_claimed == false){
                    disableClaim(id);
                    cptSG ++;
                }
            }
            gain_PP += (cptSG / supplySGG) * shareOfPricePoolForGoldAndSuperGold;
            gain_D += (cptSG / IRMCTicketInfo(_addrSG).totalSupply()) * 20;
        }

        if (IRMCTicketInfo(_addrM).balanceOf(_addrClaimer) > 0 ){
            for (uint i = 0; i < IRMCTicketInfo(_addrM).balanceOf(_addrClaimer); i++){
                
                id = IRMCTicketInfo(_addrM).tokenOfOwnerByIndex(_addrClaimer, i);
                (_claimed, ) = IRMCTicketInfo(addrContractTicketManager).getClaimedRewardStatus(id);

                if(_claimed == false){
                    disableClaim(id);
                    cptM ++;
                }
            }
            gain_PP += (cptM / IRMCTicketInfo(_addrM).totalSupply()) * shareOfPricePoolForMythic;
            gain_D += (cptM / IRMCTicketInfo(_addrM).totalSupply()) * 0;
        }

        if (IRMCTicketInfo(_addrP).balanceOf(_addrClaimer) > 0 ){
            for (uint i = 0; i < IRMCTicketInfo(_addrP).balanceOf(_addrClaimer); i++){
                
                id = IRMCTicketInfo(_addrP).tokenOfOwnerByIndex(_addrClaimer, i);
                (_claimed, ) = IRMCTicketInfo(addrContractTicketManager).getClaimedRewardStatus(id);

                if(_claimed == false){
                    disableClaim(id);
                    cptP ++;
                }
            }
            gain_PP += (cptP / IRMCTicketInfo(_addrP).totalSupply()) * shareOfPricePoolForPlatin;
            gain_D += (cptP / IRMCTicketInfo(_addrP).totalSupply()) * 20;
        }


        gain_PP = gain_PP * _pricepool / 100;
        //Todo: Partage des fees mis en brute, à mettre plus tard dans LotteryManager.
        gain_D = gain_D * _balanceDealsFees / 100;
        totalGain = gain_PP + gain_D;
        
        return (totalGain);

    }

    function computeGainForWinner(uint _idWinner, 
                                  address _claimer) external onlyLotteryGame returns(uint _gain) {

        address payable _winner = payable(IRMCTicketInfo(addrContractTicketManager).ownerOf(_idWinner));
        require(payable(_claimer) == _winner, "ERROR :: you don't have the winning ticket"); 
        
        IRMCTicketInfo(_addrN).approve(address(0), _idWinner);
        IRMCTicketInfo(_addrN).safeTransferFrom(_claimer, address(0), _idWinner);

        _gain = shareOfPricePoolForWinner * addrContractLotteryGame.balance / 100;

        return _gain;

    }
 
} 