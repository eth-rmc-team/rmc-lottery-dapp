// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import "hardhat/console.sol";

import "./Whitelisted.sol";
import "./Interfaces/ITicketRegistry.sol";
import "../Tickets/Interfaces/ITicketMinter.sol";
import "./Interfaces/IDiscoveryService.sol";


contract PrizepoolDispatcher is Whitelisted
{
    IDiscoveryService discoveryService;

    bool private _claimed;
    
    //To be divided by 100 in the appropriated compute function
    //Every rewards are claim WHEN a game period is done (triggered by the winner claiming his gain
    //or the protocole after a delay).
    //It remains claimable UNTIL a new cycle begins.
    //NFT merged during chase period can't received rewards from previous cycles.

    uint8 winnerSharePrizepool;
    uint8 goldSharePrizepool;
    uint8 superGoldSharePrizepool;
    uint8 mythicSharePrizepool;
    uint8 platinSharePrizepool;
    uint8 protocolSharePrizepool;

    constructor() 
    {        
        winnerSharePrizepool = 33;
        goldSharePrizepool = 7;
        superGoldSharePrizepool = 7;
        mythicSharePrizepool = 3;
        platinSharePrizepool = 5;
        protocolSharePrizepool = 33;
    }

    modifier onlyLotteryGame 
    {
        require(
            msg.sender == discoveryService.getLotteryGameAddr(), 
            "ERROR :: Only LotteryGame contract can call this function"
        );
        _;
    }

    function setDiscoveryService(address _address) external onlyAdmin 
    {
        discoveryService = IDiscoveryService(_address);
    }

    function setWinnerSharePrizepool(uint8 _share) public onlyAdmin 
    {
        require(
            _share + protocolSharePrizepool + 
            platinSharePrizepool + 
            mythicSharePrizepool +
            goldSharePrizepool +
            superGoldSharePrizepool < 100, 
            "WARNING :: the total share must be less than 100"
        );

        require(
            _share > 15 && _share < 51, 
            "WARNING :: the share must be between 15 and 51"
        );
        
        winnerSharePrizepool = _share;
    }

    function setProtocolSharePrizepool(uint8 _share) public onlyAdmin 
    {
        require(
            _share + winnerSharePrizepool + 
            platinSharePrizepool + 
            mythicSharePrizepool +
            goldSharePrizepool +
            superGoldSharePrizepool < 100,  
            "WARNING :: the total share must be less than 100"
        );
        
        require(
            _share > 15 && _share < 40, 
            "WARNING :: the share must be between 15 and 40"
        );
        
        protocolSharePrizepool = _share;
    }

    function setGoldSharePrizepool(uint8 _share) public onlyAdmin 
    {
        require(
            _share + winnerSharePrizepool + 
            superGoldSharePrizepool +
            platinSharePrizepool + 
            mythicSharePrizepool +
            protocolSharePrizepool < 100, 
            "WARNING :: the total share must be less than 100"
        );
            
        require(
            _share > 5 && _share < 10, 
            "WARNING :: the share must be between 5 and 10"
        );
        goldSharePrizepool = _share;
    }

    function setSuperGoldSharePrizepool(uint8 _share) public onlyAdmin 
    {
        require(
            _share + winnerSharePrizepool + 
            goldSharePrizepool +
            platinSharePrizepool + 
            mythicSharePrizepool +
            protocolSharePrizepool < 100, 
            "WARNING :: the total share must be less than 100"
        );
            
        require(
            _share > 5 && _share < 10, 
            "WARNING :: the share must be between 5 and 10"
        );
        superGoldSharePrizepool = _share;
    }

    //Same function but for the Mythic
    function setMythicSharePrizepool(uint8 _share) public onlyAdmin 
    {
        require(
            _share + winnerSharePrizepool + 
            platinSharePrizepool + 
            goldSharePrizepool +
            superGoldSharePrizepool +
            protocolSharePrizepool < 100, 
            "WARNING :: the total share must be less than 100"
        );
            
        require(
            _share > 1 && _share < 5, 
            "WARNING :: the share must be between 2 and 5"
        );
        mythicSharePrizepool = _share;
    }

    //Same function but for the Platin
    function setPlatinSharePrizepool(uint8 _share) public onlyAdmin 
    {            
        require(
            _share + winnerSharePrizepool + 
            mythicSharePrizepool + 
            goldSharePrizepool +
            superGoldSharePrizepool +
            protocolSharePrizepool < 100, 
            "WARNING :: the total share must be less than 100"
        );
            
        require(
            _share > 1 && _share < 7, 
            "WARNING :: the share must be between 1 and 5"
        );
        platinSharePrizepool = _share;
    }

    //Function get for the different shares
    function getShares() external view returns (
        uint8, 
        uint8, 
        uint8, 
        uint8, 
        uint8,
        uint8
    ) 
    {
        return (
            protocolSharePrizepool, 
            winnerSharePrizepool, 
            goldSharePrizepool, 
            superGoldSharePrizepool,
            mythicSharePrizepool, 
            platinSharePrizepool
        );
    }

    //Function called by LotteryGame contract to claim the rewards from "Marketplace" contract
    function claimFees() external onlyWhitelisted
    {
        //If there is money in the contract, we send it to the LotteryGame contract
        if(discoveryService.getRmcMarketplaceAddr().balance > 0){
            IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).transferFrom(
                discoveryService.getRmcMarketplaceAddr(), 
                discoveryService.getLotteryGameAddr(), 
                (discoveryService.getRmcMarketplaceAddr().balance)
            );
        }
    }

    //Function used to disable the claim ability of a NFT after the claim
    function disableClaim(uint _id) private 
    {
        //True = reward claimed by the NFT
        ITicketRegistry(discoveryService.getTicketRegistryAddr())
        .setPrizepoolClaimStatus(true, _id);
        ITicketRegistry(discoveryService.getTicketRegistryAddr())
        .setFeesClaimStatus(true, _id);
    }

    //Function resetting the claim ability. Called by the LotteryGame contract for a new cycle
    function resetClaimStatus() external onlyWhitelisted 
    {

        //Get the total supply for each NFT contract and loop through them
        for(uint i = 0; i < ITicketMinter(discoveryService.getGoldTicketAddr()).totalSupply(); i++) {
            uint id;
            id = ITicketMinter(discoveryService.getGoldTicketAddr()).tokenByIndex(i);
            ITicketRegistry(discoveryService.getGoldTicketAddr()).setPrizepoolClaimStatus(false, id);
            ITicketRegistry(discoveryService.getGoldTicketAddr()).setFeesClaimStatus(false, id);
        }

        for(uint i = 0; i < ITicketMinter(discoveryService.getSuperGoldTicketAddr()).totalSupply(); i++) {
            uint id;
            id = ITicketMinter(discoveryService.getSuperGoldTicketAddr()).tokenByIndex(i);
            ITicketRegistry(discoveryService.getSuperGoldTicketAddr()).setPrizepoolClaimStatus(false, id);
            ITicketRegistry(discoveryService.getSuperGoldTicketAddr()).setFeesClaimStatus(false, id);
        }

        for(uint i = 0; i < ITicketMinter(discoveryService.getMythicTicketAddr()).totalSupply(); i++) {
            uint id;
            id = ITicketMinter(discoveryService.getMythicTicketAddr()).tokenByIndex(i);
            ITicketRegistry(discoveryService.getMythicTicketAddr()).setPrizepoolClaimStatus(false, id);
            ITicketRegistry(discoveryService.getMythicTicketAddr()).setFeesClaimStatus(false, id);        
        }

        for(uint i = 0; i < ITicketMinter(discoveryService.getPlatiniumTicketAddr()).totalSupply(); i++) {
            uint id;
            id = ITicketMinter(discoveryService.getPlatiniumTicketAddr()).tokenByIndex(i);
            ITicketRegistry(discoveryService.getPlatiniumTicketAddr()).setPrizepoolClaimStatus(false, id);
            ITicketRegistry(discoveryService.getPlatiniumTicketAddr()).setFeesClaimStatus(false, id);
        }
    }

    //Function computing the gain for the owner of "Special NFT" and disabling the claim afterward
    function computeGainForAdvantages(
        address addrClaimer
    ) external onlyWhitelisted returns (uint _totalGain) 
    {
        uint cptG = 0;
        uint cptSG = 0;
        uint cptM = 0;
        uint cptP = 0;
        
        uint gain_PP = 0;
        uint gain_D = 0;
        uint totalGain = 0;

        uint id = 0;

        uint _pricepool = discoveryService.getLotteryGameAddr().balance;
        uint _balanceDealsFees = discoveryService.getRmcMarketplaceAddr().balance;
        
        uint supplySGG = ITicketMinter(discoveryService.getSuperGoldTicketAddr())
        .totalSupply() + ITicketMinter(discoveryService.getGoldTicketAddr()).totalSupply();

        //Get the amount of NFT owned by the address and loop through them
        //Disable the claim ability of the NFT
        //Increase the counter for the NFT type
        //Calculate the gain knowing the share of the price pool for each type of NFT and the number of NFT owned
        if (ITicketMinter(discoveryService.getGoldTicketAddr()).balanceOf(addrClaimer) > 0 ) {
            for (uint i = 0; i < ITicketMinter(discoveryService.getGoldTicketAddr()).balanceOf(addrClaimer); i++) {
                id = ITicketMinter(discoveryService.getGoldTicketAddr()).tokenOfOwnerByIndex(addrClaimer, i);
                (_claimed, ) = ITicketRegistry(discoveryService.getGoldTicketAddr()).getClaimedRewardStatus(id);
                if(_claimed == false) {
                    disableClaim(id);
                    cptG ++;
                }

            }
            gain_PP += (cptG / supplySGG) * goldSharePrizepool;
            gain_D += (cptG / ITicketMinter(discoveryService.getGoldTicketAddr()).totalSupply()) * 20;
        }

        if (ITicketMinter(discoveryService.getSuperGoldTicketAddr()).balanceOf(addrClaimer) > 0 ) {
            for (uint i = 0; i < ITicketMinter(discoveryService.getSuperGoldTicketAddr()).balanceOf(addrClaimer); i++) {
                
                id = ITicketMinter(discoveryService.getSuperGoldTicketAddr()).tokenOfOwnerByIndex(addrClaimer, i);
                (_claimed, ) = ITicketRegistry(discoveryService.getSuperGoldTicketAddr()).getClaimedRewardStatus(id);

                if(_claimed == false) {
                    disableClaim(id);
                    cptSG ++;
                }
            }
            gain_PP += (cptSG / supplySGG) * superGoldSharePrizepool;
            gain_D += (cptSG / ITicketRegistry(discoveryService.getSuperGoldTicketAddr()).totalSupply()) * 20;
        }

        if (ITicketMinter(discoveryService.getMythicTicketAddr()).balanceOf(addrClaimer) > 0 ){
            for (uint i = 0; i < ITicketMinter(discoveryService.getMythicTicketAddr()).balanceOf(addrClaimer); i++) {
                
                id = ITicketMinter(discoveryService.getMythicTicketAddr()).tokenOfOwnerByIndex(addrClaimer, i);
                (_claimed, ) = ITicketRegistry(discoveryService.getMythicTicketAddr()).getClaimedRewardStatus(id);

                if(_claimed == false) {
                    disableClaim(id);
                    cptM ++;
                }
            }
            gain_PP += (cptM / ITicketMinter(discoveryService.getMythicTicketAddr()).totalSupply()) * mythicSharePrizepool;
            gain_D += (cptM / ITicketMinter(discoveryService.getMythicTicketAddr()).totalSupply()) * 0;
        }

        if (ITicketMinter(discoveryService.getPlatiniumTicketAddr()).balanceOf(addrClaimer) > 0 ){
            for (uint i = 0; i < ITicketMinter(discoveryService.getPlatiniumTicketAddr()).balanceOf(addrClaimer); i++) {
                
                id = ITicketMinter(discoveryService.getPlatiniumTicketAddr()).tokenOfOwnerByIndex(addrClaimer, i);
                (_claimed, ) = ITicketRegistry(discoveryService.getPlatiniumTicketAddr()).getClaimedRewardStatus(id);

                if(_claimed == false) {
                    disableClaim(id);
                    cptP ++;
                }
            }
            gain_PP += (cptP / ITicketMinter(discoveryService.getPlatiniumTicketAddr()).totalSupply()) * platinSharePrizepool;
            gain_D += (cptP / ITicketMinter(discoveryService.getPlatiniumTicketAddr()).totalSupply()) * 20;
        }


        gain_PP = gain_PP * _pricepool / 100;
        //Todo: Partage des fees mis en brute, à mettre plus tard dans LotteryManager.
        gain_D = gain_D * _balanceDealsFees / 100;
        totalGain = gain_PP + gain_D;
        
        return (totalGain);

    }

    //Function computin the gain for the winner
    function computeGainForWinner(
        uint _idWinner, 
        address _claimer
    ) external view onlyWhitelisted returns(uint)
    {
        address payable _winner = payable(ITicketMinter(discoveryService.getNormalTicketAddr()).ownerOf(_idWinner));
        require(
            payable(_claimer) == _winner, 
            "ERROR :: you don't have the winning ticket"
        ); 

        return protocolSharePrizepool * discoveryService.getLotteryGameAddr().balance / 100;
    }
} 